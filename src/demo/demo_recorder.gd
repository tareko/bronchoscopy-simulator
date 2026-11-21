extends Node3D

## Deterministic demo renderer: runs the simulator, draws a scripted sequence,
## and saves every frame as a PNG for ffmpeg. No real-time capture, so nothing
## is dropped or torn.
##
##   godot --path . res://src/demo/demo.tscn
##
## Env overrides (for quick tests): DEMO_FRAMES, DEMO_W, DEMO_H, DEMO_OUT.

const AirwayTreeScript := preload("res://src/anatomy/airway_tree.gd")
const EndoscopeScript := preload("res://src/scope/endoscope.gd")
const ProcedureLogScript := preload("res://src/metrics/procedure_log.gd")
const TREE_PATH := "res://assets/anatomy/generic_adult.json"
const MM := 0.001

var width := 1920
var height := 1080
var fps := 30
var total_frames := 1020
var out_dir := "res://video/frames"

var tree: AirwayTree
var scope: Endoscope
var log: ProcedureLog

var sub: SubViewport
var world: Node3D
var external_cam: Camera3D
var scope_cam: Camera3D
var path_lines: MeshInstance3D
var tip_marker: MeshInstance3D
var airway: MeshInstance3D
var skeleton: MeshInstance3D
var _centre := Vector3.ZERO
var _extent := 0.3
var hud_title: Label
var hud_segment: Label
var hud_stats: Label
var hud_caption: Label

var _caption := ""
var _caption_since := 0.0
var _reached := false
var _reach_time := -1.0
var _stuck := 0


func _ready() -> void:
	var env := OS.get_environment
	width = int(env.call("DEMO_W")) if env.call("DEMO_W") != "" else width
	height = int(env.call("DEMO_H")) if env.call("DEMO_H") != "" else height
	total_frames = int(env.call("DEMO_FRAMES")) if env.call("DEMO_FRAMES") != "" else total_frames
	out_dir = env.call("DEMO_OUT") if env.call("DEMO_OUT") != "" else out_dir
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))

	tree = AirwayTreeScript.new()
	if tree.load_from_file(TREE_PATH) != OK:
		push_error("demo: could not load the airway tree")
		get_tree().quit(1)
		return
	scope = EndoscopeScript.new()
	scope.tree = tree
	scope.scope_radius_mm = 2.45
	scope.reset()

	log = ProcedureLogScript.new()
	log.start("demo", tree.name, "", tree.bronchopulmonary_segments())

	_build_stage()
	_run()


func _build_stage() -> void:
	sub = SubViewport.new()
	sub.size = Vector2i(width, height)
	sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub.own_world_3d = false
	add_child(sub)

	world = Node3D.new()
	sub.add_child(world)

	var tissue := ShaderMaterial.new()
	tissue.shader = load("res://src/demo/airway_tissue.gdshader")
	airway = MeshInstance3D.new()
	airway.mesh = AirwayMeshBuilder.build(tree, AirwayMeshBuilder.default_material())
	airway.material_override = tissue
	airway.scale = Vector3.ONE * MM
	world.add_child(airway)
	_bounds()

	var skeleton_mat := StandardMaterial3D.new()
	skeleton_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	skeleton_mat.albedo_color = Color(0.36, 0.94, 0.86)
	skeleton_mat.emission_enabled = true
	skeleton_mat.emission = Color(0.2, 0.9, 0.8)
	skeleton_mat.emission_energy_multiplier = 1.6
	skeleton = MeshInstance3D.new()
	skeleton.mesh = _skeleton_mesh()
	skeleton.material_override = skeleton_mat
	skeleton.scale = Vector3.ONE * MM
	skeleton.visible = false
	world.add_child(skeleton)

	tip_marker = MeshInstance3D.new()
	var marker_mat := StandardMaterial3D.new()
	marker_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	marker_mat.albedo_color = Color(1.0, 0.72, 0.30)
	marker_mat.emission_enabled = true
	marker_mat.emission = Color(1.0, 0.55, 0.15)
	marker_mat.emission_energy_multiplier = 3.0
	var sphere := SphereMesh.new()
	sphere.radius = 0.0032
	sphere.height = 0.0064
	tip_marker.mesh = sphere
	tip_marker.material_override = marker_mat
	tip_marker.visible = false
	world.add_child(tip_marker)

	path_lines = MeshInstance3D.new()
	path_lines.top_level = true
	var path_mat := StandardMaterial3D.new()
	path_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	path_mat.albedo_color = Color(1.0, 0.55, 0.25)
	path_mat.no_depth_test = true
	path_lines.material_override = path_mat
	world.add_child(path_lines)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50, 25, 0)
	light.light_energy = 1.0
	light.shadow_enabled = false
	world.add_child(light)

	var we := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.015, 0.02, 0.03)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.6, 0.55, 0.6)
	environment.ambient_light_energy = 0.42
	environment.glow_enabled = true
	environment.glow_intensity = 0.5
	we.environment = environment
	world.add_child(we)

	external_cam = Camera3D.new()
	external_cam.fov = 42.0
	external_cam.near = 0.001
	external_cam.far = 5.0
	world.add_child(external_cam)

	scope_cam = Camera3D.new()
	scope_cam.fov = 92.0
	scope_cam.near = 0.0005
	scope_cam.far = 1.0
	world.add_child(scope_cam)

	# The bronchoscope's own light: small warm spot at the tip. This is what
	# makes the endoscopic view read as an instrument view rather than a tunnel.
	var torch := SpotLight3D.new()
	torch.position = Vector3(0, 0, -0.004)
	torch.light_color = Color(1.0, 0.94, 0.86)
	torch.light_energy = 4.5
	torch.spot_range = 0.13
	torch.spot_angle = 58.0
	torch.spot_attenuation = 1.2
	torch.shadow_enabled = false
	scope_cam.add_child(torch)

	var layer := CanvasLayer.new()
	sub.add_child(layer)

	hud_title = _label(layer, 58, Color(0.96, 0.98, 1.0), Vector2(120, height * 0.40), width - 240)
	hud_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_caption = _label(layer, 26, Color(0.85, 0.93, 0.95), Vector2(120, height - 64), width - 240)
	hud_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_segment = _label(layer, 26, Color(0.62, 0.92, 0.86), Vector2(48, height - 132), 760)
	hud_stats = _label(layer, 22, Color(0.78, 0.84, 0.9), Vector2(width - 460, height - 126), 412)
	hud_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


func _label(parent: Node, size: int, colour: Color, pos: Vector2, wide: int) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", colour)
	label.position = pos
	label.size = Vector2(wide, size * 3)
	label.visible = false
	parent.add_child(label)
	return label


## Camera framing: centroid and radius of the whole tree, in metres.
func _bounds() -> void:
	var lo := Vector3(INF, INF, INF)
	var hi := Vector3(-INF, -INF, -INF)
	for node in tree.nodes:
		for key in ["start_mm", "position_mm"]:
			var v: Variant = node.get(key, null)
			if typeof(v) != TYPE_ARRAY:
				continue
			var p := Vector3(float(v[0]), float(v[1]), float(v[2]))
			lo = lo.min(p)
			hi = hi.max(p)
	_centre = (lo + hi) * 0.5 * MM
	_extent = maxf((hi - lo).x, maxf((hi - lo).y, (hi - lo).z)) * MM


func _skeleton_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	for node in tree.nodes:
		var label := str(node["label"])
		st.add_vertex(tree.start_of(label))
		st.add_vertex(tree.end_of(label))
	return st.commit()


func _run() -> void:
	var dt := 1.0 / float(fps)
	for frame in total_frames:
		var t := float(frame) / float(fps)
		_direct(t, dt)
		await RenderingServer.frame_post_draw
		var image := sub.get_texture().get_image()
		image.save_png("%s/%05d.png" % [out_dir, frame])
		if frame % 120 == 0:
			print("demo: frame %d/%d" % [frame, total_frames])
	print("demo: done -> ", out_dir)
	get_tree().quit(0)


func _direct(t: float, dt: float) -> void:
	const ENDOSCOPIC_FROM := 8.0
	var endoscopic_from := ENDOSCOPIC_FROM
	var closing_from := maxf(float(total_frames) / float(fps) - 4.0, ENDOSCOPIC_FROM + 6.0)

	# ---- pre-roll: advance to the carina while the title plays -------------
	if t < endoscopic_from and scope.get_insertion_depth_mm() < 238.0:
		scope.advance(6.0, 0.0, 0.0, dt)
		scope_cam.global_position = scope.get_tip() * MM
		path_lines.visible = false

	# ---- camera and text state -------------------------------------------
	if t < endoscopic_from:
		_shot_title(t)
	elif t < closing_from:
		_shot_scope(t, dt)
	else:
		_shot_closing(t)

	# ---- captions ---------------------------------------------------------
	var caption := ""
	if t < 3.6:
		caption = "Open-source VR bronchoscopy training  ·  Godot 4 + OpenXR  ·  Linux"
	elif t < 6.2:
		caption = "18 bronchopulmonary segments, by name and depth"
	elif t < endoscopic_from:
		caption = "Print the handle, or play with two Vive wands"
	elif t < 14.0:
		caption = "The scope's actual path through the bronchial tree"
	elif t < 22.0:
		caption = "Hold grip to insert  ·  trackpad to deflect  ·  wrist to torque"
	elif t < 30.0:
		caption = "Eight clinical cases: anatomy, lesion, bleeding, foreign body…"
	# the closing card owns its own caption
	if t < closing_from:
		_set_caption(caption, t)

	hud_stats.text = "DC  %2d / 18\nSP  %2d\nPT  %5.1f s" % [
		log.diagnostic_completeness(), log.structured_progress(), log.elapsed_s()]


func _shot_title(t: float) -> void:
	if tip_marker != null:
		tip_marker.visible = false
	airway.visible = false
	skeleton.visible = true
	external_cam.current = true
	var angle := t * 0.30
	var radius := _extent * 1.55 + 0.06 - minf(t, 6.0) * 0.004
	external_cam.global_position = _centre + Vector3(cos(angle) * radius, 0.02, sin(angle) * radius)
	external_cam.look_at(_centre, Vector3.UP)
	hud_title.text = "BRONCHOSCOPY SIMULATOR" if t < 3.6 else ""
	hud_title.visible = t < 3.6


func _shot_scope(t: float, dt: float) -> void:
	# Through-the-lens rendering exposes the overlapping segment tubes at every
	# bifurcation, which reads as broken geometry. Show the recorded path
	# against the bronchial skeleton instead: honest, legible, and it is the
	# data the simulator actually produces.
	skeleton.visible = true
	airway.visible = false
	path_lines.visible = true
	external_cam.current = true

	var insert := 0.0
	var lever := 0.0
	var roll := 0.0
	if not _reached:
		var cmd := _autopilot("RB6")
		# Stop at the bronchus intermedius: wide enough to read on camera.
		insert = 1.1 if scope.get_insertion_depth_mm() < 268.0 else 0.0
		lever = cmd["lever"]
		roll = cmd["roll"]
		if tree.is_descendant_of(scope.get_current_label(), "RB6"):
			_reached = true
			_reach_time = t
	elif t < _reach_time + 3.0:
		lever = 0.25 * sin(t * 2.0)   # gentle inspection sweep
	else:
		insert = -2.4                  # withdraw for the closing shot

	var report := scope.advance(insert, lever, roll, dt)
	log.track_frame(dt, report)
	_update_path_lines()
	tip_marker.visible = true
	tip_marker.global_position = scope.get_tip() * MM

	hud_segment.visible = true
	hud_stats.visible = true
	var label := scope.get_current_label()
	hud_segment.text = "%s   %s\n%.0f mm from incisors" % [
		label if not label.is_empty() else "—",
		_tree_name(label),
		scope.get_insertion_depth_mm()]


func _shot_closing(t: float) -> void:
	airway.visible = false
	skeleton.visible = true
	external_cam.current = true
	var angle := 1.4 + t * 0.22
	var radius := _extent * 1.5 + 0.06
	external_cam.global_position = _centre + Vector3(cos(angle) * radius, 0.03, sin(angle) * radius)
	external_cam.look_at(_centre, Vector3.UP)
	hud_title.text = "github.com/tareko/bronchoscopy-simulator"
	hud_title.visible = true
	hud_segment.visible = false
	hud_stats.visible = false
	hud_caption.text = "MIT licensed  ·  runs offline on Linux  ·  wands or printed prop"
	hud_caption.modulate.a = 1.0
	hud_caption.visible = true
	_update_path_lines()
	path_lines.visible = true
	tip_marker.visible = true
	tip_marker.global_position = scope.get_tip() * MM


func _update_scope_camera() -> void:
	# Centre the virtual optics on the lumen rather than on the tip: a real tip
	# clamped against a 3 mm wall fills the frame with wall and reads as a bug.
	var hit := tree.nearest_on_centerline(scope.get_tip())
	var dir: Vector3 = Vector3(hit.get("axis_dir", Vector3.DOWN)).normalized()
	var centre: Vector3 = Vector3(hit.get("on_axis", scope.get_tip())) * MM
	scope_cam.global_position = centre - dir * 0.012
	var up := Vector3.UP
	if absf(dir.dot(Vector3.UP)) > 0.98:
		up = Vector3.FORWARD
	scope_cam.look_at(centre + dir * 0.04, up)


func _update_path_lines() -> void:
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for point in scope.get_path():
		im.surface_add_vertex(point * MM)
	im.surface_end()
	path_lines.mesh = im


func _set_caption(text: String, t: float) -> void:
	if text != _caption:
		_caption = text
		_caption_since = t
		hud_caption.text = text
	hud_caption.visible = not text.is_empty()
	# fade in over 0.4 s
	var age := t - _caption_since
	hud_caption.modulate.a = clampf(age / 0.4, 0.0, 1.0)


func _tree_name(label: String) -> String:
	var node := tree.get_node_for(label)
	return str(node.get("name", "")) if not node.is_empty() else ""


# ---- pure-pursuit autopilot (same controller as the test suite) ----------
func _autopilot(target: String) -> Dictionary:
	var poly := PackedVector3Array()
	for label in tree.route_to(target):
		poly.append(tree.start_of(label))
	poly.append(tree.end_of(target))
	var look := _lookahead(poly, scope.get_tip(), 45.0)
	var forward := scope.get_tip_direction()
	var to_look := (look - scope.get_tip()).normalized()
	if to_look.dot(forward) > 0.9995:
		return {"lever": 0.0, "roll": 0.0}
	var axis := forward.cross(to_look).normalized()
	var sign := 1.0
	if axis.dot(scope.bend_axis) < 0.0:
		sign = -1.0
	var target_axis := axis * sign
	var roll_err := rad_to_deg(scope.bend_axis.signed_angle_to(target_axis, forward))
	var lever := sign * clampf(forward.angle_to(to_look) / deg_to_rad(scope.max_deflection_deg), -1.0, 1.0)
	return {"lever": lever, "roll": clampf(roll_err, -25.0, 25.0)}


func _lookahead(poly: PackedVector3Array, tip: Vector3, lookahead_mm: float) -> Vector3:
	if poly.size() < 2:
		return tip
	var best := 0.0
	var best_dist := INF
	var arc := 0.0
	var total := 0.0
	for i in range(1, poly.size()):
		var a := poly[i - 1]
		var b := poly[i]
		var seg := a.distance_to(b)
		if seg < 0.0001:
			continue
		var t := clampf((tip - a).dot(b - a) / (seg * seg), 0.0, 1.0)
		var dist := tip.distance_to(a.lerp(b, t))
		if dist < best_dist:
			best_dist = dist
			best = arc + seg * t
		arc += seg
		total = arc
	var want := minf(best + lookahead_mm, total)
	arc = 0.0
	for i in range(1, poly.size()):
		var a := poly[i - 1]
		var b := poly[i]
		var seg := a.distance_to(b)
		if seg < 0.0001:
			continue
		if arc + seg >= want:
			return a.lerp(b, (want - arc) / seg)
		arc += seg
	return poly[poly.size() - 1]
