extends Node3D

## Desktop entry point and VR bootstrap.
##
## Runs headless-friendly: with no headset the scene is driven from the
## keyboard so the scope model, anatomy and metrics can be developed and
## tested on a laptop. Launch with `scripts/run.sh --vr` to bring up OpenXR.

const AirwayTreeScript := preload("res://src/anatomy/airway_tree.gd")
const EndoscopeScript := preload("res://src/scope/endoscope.gd")
const ProcedureLogScript := preload("res://src/metrics/procedure_log.gd")
const TrackingSanityScript := preload("res://src/xr/tracking_sanity.gd")
const VRScopeInputScript := preload("res://src/xr/vr_scope_input.gd")
const TREE_PATH := "res://assets/anatomy/generic_adult.json"
const MM_TO_M := 0.001

var tree: AirwayTree
var scope: Endoscope
var log: ProcedureLog

var _airway_mesh: MeshInstance3D
var _scope_mesh: MeshInstance3D
var _camera: Camera3D
var _scope_camera: Camera3D
var _hud: Label
var _origin: XROrigin3D
var _xr_camera: XRCamera3D
var _scope_view := false
var _vr_input: RefCounted = null
var _left_hand: XRController3D = null
var _right_hand: XRController3D = null

# head-tracking sanity sampling (see src/xr/tracking_sanity.gd)
var _track_elapsed := 0.0
var _track_started := false
var _track_first_pos := Vector3.ZERO
var _track_first_quat := Quaternion.IDENTITY
var _track_pos_span := 0.0
var _track_rot_span := 0.0
var _track_verdict := ""


func _ready() -> void:
	_register_desktop_actions()

	tree = AirwayTreeScript.new()
	if tree.load_from_file(TREE_PATH) != OK:
		push_error("Failed to load airway tree; see console for details")
		return
	print(tree.summary())

	scope = EndoscopeScript.new()
	scope.tree = tree
	scope.reset()

	log = ProcedureLogScript.new()
	log.start("free_flight", tree.name, "", tree.bronchopulmonary_segments())

	_build_scene()
	_setup_xr_if_available()
	_update_visuals()


func _register_desktop_actions() -> void:
	var bindings := {
		"sim_insert": KEY_W,
		"sim_withdraw": KEY_S,
		"sim_deflect_left": KEY_A,
		"sim_deflect_right": KEY_D,
		"sim_roll_left": KEY_Q,
		"sim_roll_right": KEY_E,
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = bindings[action]
		InputMap.action_add_event(action, event)
	if not InputMap.has_action("sim_reset"):
		InputMap.add_action("sim_reset")
		var reset_key := InputEventKey.new()
		reset_key.physical_keycode = KEY_R
		InputMap.action_add_event("sim_reset", reset_key)
	if not InputMap.has_action("sim_toggle_view"):
		InputMap.add_action("sim_toggle_view")
		var tab_key := InputEventKey.new()
		tab_key.physical_keycode = KEY_TAB
		InputMap.action_add_event("sim_toggle_view", tab_key)


func _build_scene() -> void:
	_airway_mesh = MeshInstance3D.new()
	_airway_mesh.name = "Airway"
	_airway_mesh.mesh = AirwayMeshBuilder.build(tree, AirwayMeshBuilder.default_material())
	_airway_mesh.scale = Vector3.ONE * MM_TO_M
	add_child(_airway_mesh)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, 30, 0)
	light.light_energy = 1.1
	light.shadow_enabled = false
	add_child(light)

	var ambient := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.02, 0.03)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.5, 0.58)
	env.ambient_light_energy = 0.55
	ambient.environment = env
	add_child(ambient)

	_camera = Camera3D.new()
	_camera.name = "PreviewCamera"
	_camera.near = 0.001
	_camera.far = 4.0
	add_child(_camera)
	_camera.current = true

	_scope_camera = Camera3D.new()
	_scope_camera.name = "ScopeCamera"
	_scope_camera.fov = 95.0
	_scope_camera.near = 0.0005
	_scope_camera.far = 1.0
	add_child(_scope_camera)

	var hud_layer := CanvasLayer.new()
	add_child(hud_layer)
	_hud = Label.new()
	_hud.position = Vector2(16, 12)
	_hud.add_theme_font_size_override("font_size", 16)
	hud_layer.add_child(_hud)


func _setup_xr_if_available() -> void:
	var interface := XRServer.find_interface("OpenXR")
	if interface == null or not interface.is_initialized():
		print("XR: no OpenXR interface (desktop mode)")
		return
	get_viewport().use_xr = true
	_origin = XROrigin3D.new()
	_origin.name = "XROrigin"
	add_child(_origin)
	_xr_camera = XRCamera3D.new()
	_xr_camera.name = "XRCamera"
	_origin.add_child(_xr_camera)
	for hand in ["left_hand", "right_hand"]:
		var controller := XRController3D.new()
		controller.name = hand.to_pascal_case()
		controller.tracker = hand
		_origin.add_child(controller)
		if hand.begins_with("left"):
			_left_hand = controller
		else:
			_right_hand = controller

	# Wands are enough to play; the printed prop is an optional lever upgrade.
	_vr_input = VRScopeInputScript.new()
	_vr_input.setup(_right_hand, _left_hand)
	print("XR: OpenXR active")


func _process(delta: float) -> void:
	if tree == null:
		return

	if Input.is_action_just_pressed("sim_reset"):
		scope.reset()
		_reset_log()
		return
	if Input.is_action_just_pressed("sim_toggle_view"):
		_scope_view = not _scope_view

	# VR takes over when a runtime is live; otherwise the keyboard drives it.
	if _vr_input != null:
		var command: Dictionary = _vr_input.update(delta)
		var vr_report := scope.advance(
			float(command["insert_mm"]), float(command["lever"]), float(command["roll_deg"]), delta)
		log.track_frame(delta, vr_report)
		_sample_tracking(delta)
		_update_visuals()
		return

	var insert := 0.0
	if Input.is_action_pressed("sim_insert"):
		insert += 22.0 * delta   # realistic hand speed, mm/s
	if Input.is_action_pressed("sim_withdraw"):
		insert -= 30.0 * delta

	var lever := 0.0
	if Input.is_action_pressed("sim_deflect_left"):
		lever -= 1.0
	if Input.is_action_pressed("sim_deflect_right"):
		lever += 1.0

	var roll := 0.0
	if Input.is_action_pressed("sim_roll_left"):
		roll -= 90.0 * delta
	if Input.is_action_pressed("sim_roll_right"):
		roll += 90.0 * delta

	var report := scope.advance(insert, lever, roll, delta)
	log.track_frame(delta, report)
	_sample_tracking(delta)
	_update_visuals()


func _update_visuals() -> void:
	var tip := scope.get_tip() * MM_TO_M
	var forward := scope.tip_dir

	if _scope_view:
		_scope_camera.current = true
		_scope_camera.global_position = tip - forward * 0.004
		_aim(_scope_camera, tip + forward * 0.05, forward)
	else:
		_camera.current = true
		var back := -forward * 0.18 + Vector3.UP * 0.06
		_camera.global_position = tip + back
		_aim(_camera, tip + forward * 0.05, forward)

	var label := scope.get_current_label()
	var depth := scope.get_insertion_depth_mm()
	var clearance := scope.get_wall_clearance_mm()
	_hud.text = "segment %s   depth %.0f mm   clearance %.1f mm\nW/S insert-retract  A/D steer  Q/E torque  R reset  Tab view" % [
		label if not label.is_empty() else "-", depth, clearance,
	]
	if _track_verdict == "3dof_suspected":
		_hud.text += "\n3-DoF TRACKING: rebuild Monado with the Lighthouse driver"


## Sample head motion for a few seconds and warn if the headset is running in
## 3-DoF (rotation without translation). Silently continuing would make every
## airway feel flat and wreck the trainee's depth judgement.
func _sample_tracking(delta: float) -> void:
	if _xr_camera == null or not _track_verdict.is_empty():
		return
	_track_elapsed += delta
	if not _track_started:
		if _track_elapsed < 0.3:
			return
		_track_started = true
		_track_first_pos = _xr_camera.global_position
		_track_first_quat = _xr_camera.global_basis.get_rotation_quaternion()
		return
	_track_pos_span = maxf(_track_pos_span,
		_xr_camera.global_position.distance_to(_track_first_pos) * 1000.0)
	var quat := _xr_camera.global_basis.get_rotation_quaternion()
	_track_rot_span = maxf(_track_rot_span, rad_to_deg(quat.angle_to(_track_first_quat)))
	if _track_elapsed > 6.0:
		_track_verdict = TrackingSanityScript.classify(_track_pos_span, _track_rot_span)
		print("XR tracking check: %s (pos span %.0f mm, rot span %.0f deg)" % [
			_track_verdict, _track_pos_span, _track_rot_span])
		if _track_verdict == "3dof_suspected":
			push_warning(TrackingSanityScript.advice(_track_verdict))


## Look at `target` without degenerating when the view direction is vertical
## (the trachea is straight down, which is exactly colinear with UP).
func _aim(camera: Camera3D, target: Vector3, forward: Vector3) -> void:
	var up := Vector3.UP
	if absf(forward.normalized().dot(Vector3.UP)) > 0.98:
		up = Vector3.FORWARD
	camera.look_at(target, up)


## A session ends with the scope back at the incisors or on an explicit reset;
## the previous log is exported before starting a fresh one.
func _reset_log() -> void:
	if log != null:
		log.finish()
		var reports_dir := ProjectSettings.globalize_path("user://sessions")
		DirAccess.make_dir_recursive_absolute(reports_dir)
		var stamp: String = Time.get_datetime_string_from_system().replace(":", "-")
		log.save_json("%s/%s_session.json" % [reports_dir, stamp])
	log = ProcedureLogScript.new()
	log.start("free_flight", tree.name, "", tree.bronchopulmonary_segments())
