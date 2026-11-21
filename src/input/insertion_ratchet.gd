class_name InsertionRatchet
extends RefCounted

## Turns a handheld controller's motion into scope insertion, without a rail.
##
## A desk-scale arm cannot push 30 cm, so insertion is clutched and scaled:
## hold the grip, push the controller along its own forward axis, release and
## reposition to keep going. Every step re-anchors, so there is no accumulated
## drift and no hidden limit on how far the trainee can insert.
##
## Pure logic: takes positions in metres, returns millimetres. No VR required,
## which is why it can be tested headless.

var scale := 2.5            ## scope mm per hand mm (2.5x feels close to a real scope)
var max_step_mm := 6.0      ## per-frame clamp, keeps a fast flick from jumping
var invert := false         ## push-to-insert vs pull-to-insert

var _anchor := Vector3.ZERO
var _has_anchor := false


func reset(hand_position := Vector3.ZERO) -> void:
	_anchor = hand_position
	_has_anchor = true


## Advance one frame. Returns the insertion delta in millimetres.
##
## `hand_position` is the controller position in metres, `axis` the insertion
## direction (unit), `clutch` whether the grip is held.
func step(hand_position: Vector3, axis: Vector3, clutch: bool) -> float:
	if not _has_anchor:
		reset(hand_position)
		return 0.0
	if not clutch:
		# Re-anchor while disengaged so repositioning the hand inserts nothing.
		_anchor = hand_position
		return 0.0
	if axis.length_squared() < 0.000001:
		_anchor = hand_position
		return 0.0

	var direction := axis.normalized()
	if invert:
		direction = -direction

	var delta_m: float = (hand_position - _anchor).dot(direction)
	_anchor = hand_position
	return clampf(delta_m * 1000.0 * scale, -max_step_mm, max_step_mm)
