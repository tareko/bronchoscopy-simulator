class_name VRScopeInput
extends RefCounted

## Wand-only control of the scope, with the printed prop as an optional upgrade.
##
## This is the default input path: two Vive wands are enough to train.
##
##   scope hand (right)   push/pull while holding grip  -> insertion (ratcheted)
##                        wrist roll about the wand axis -> shaft torque
##   lever hand (left)    trackpad Y                     -> deflection lever
##
## If a joystick is connected it is assumed to be the printed prop's AS5600
## controller and takes over the lever; everything else is unchanged.
##
## Written defensively because Godot's default OpenXR action map does not bind
## Vive controllers: every action is looked up from a list of candidate names
## and missing bindings degrade to "no input" with a warning, not a crash.

const PAD_ACTIONS := ["trackpad", "thumbstick", "primary"]
const GRIP_ACTIONS := ["grip", "grip_click"]
const TRIGGER_ACTIONS := ["trigger"]

var scope_hand: XRController3D
var lever_hand: XRController3D
var joystick_device := -1          ## >= 0 when a prop controller is present
var joystick_axis := JOY_AXIS_LEFT_Y

var ratchet := InsertionRatchet.new()
var lever_mapper := LeverMapper.new()

var _pad_action := ""
var _grip_action := ""
var _torque_ref := Basis.IDENTITY
var _roll_last := 0.0
var _engaged := false
var _warned := false


func setup(scope: XRController3D, lever: XRController3D) -> void:
	scope_hand = scope
	lever_hand = lever
	var pads := Input.get_connected_joypads()
	if not pads.is_empty():
		joystick_device = pads[0]
		print("input: joystick %d present, using it for the deflection lever" % joystick_device)


## Probe which action names this runtime actually exposes. Safe to call often.
func _ensure_actions() -> bool:
	if not _pad_action.is_empty():
		return true
	if scope_hand == null:
		return false
	for candidate in PAD_ACTIONS:
		if scope_hand.get_vector2(candidate) != Vector2.ZERO:
			_pad_action = candidate
			break
	for candidate in GRIP_ACTIONS + TRIGGER_ACTIONS:
		if scope_hand.is_button_pressed(candidate) or scope_hand.get_float(candidate) > 0.0:
			_grip_action = candidate
			break
	if _pad_action.is_empty():
		# fall back to the first name so get_vector2() at least returns zero
		_pad_action = PAD_ACTIONS[0]
	if _grip_action.is_empty():
		_grip_action = GRIP_ACTIONS[0]
		if not _warned:
			_warned = true
			push_warning("input: no Vive controller bindings found; add the "
				+ "/interaction_profiles/htc/vive_controller bindings to the OpenXR action map")
	return true


## One frame of input. Returns {insert_mm, lever, roll_deg, mode}.
func update(_delta: float) -> Dictionary:
	var out := {"insert_mm": 0.0, "lever": 0.0, "roll_deg": 0.0, "mode": "wand"}
	if not _ensure_actions():
		return out

	# ---- deflection -------------------------------------------------------
	if joystick_device >= 0:
		out["lever"] = lever_mapper.map_axis(Input.get_joy_axis(joystick_device, joystick_axis))
		out["mode"] = "prop"
	elif lever_hand != null:
		var pad: Vector2 = lever_hand.get_vector2(_pad_action)
		# Godot reports "up" on the pad as negative Y; pushing the thumb forward
		# should deflect the tip up, so negate.
		out["lever"] = lever_mapper.map_axis(-pad.y)

	# ---- insertion and torque --------------------------------------------
	if scope_hand == null:
		return out

	var grip_value: float = scope_hand.get_float(_grip_action)
	var clutch: bool = grip_value > 0.5 or scope_hand.is_button_pressed(_grip_action)
	var basis: Basis = scope_hand.global_basis
	var forward: Vector3 = -basis.z          # Godot forward

	if clutch and not _engaged:
		# capture the reference orientation when the trainee takes hold
		_engaged = true
		_torque_ref = basis
		_roll_last = 0.0
		ratchet.reset(scope_hand.global_position)
	elif not clutch and _engaged:
		_engaged = false

	out["insert_mm"] = ratchet.step(scope_hand.global_position, forward, clutch)

	if _engaged:
		var roll: float = TorqueTracker.roll_degrees(basis, _torque_ref, forward)
		out["roll_deg"] = roll - _roll_last
		_roll_last = roll

	return out
