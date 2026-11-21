class_name TorqueTracker
extends RefCounted

## Wrist rotation about the instrument axis, from controller orientation.
##
## A bronchoscope has no left/right joint: you steer laterally by torquing the
## shaft. In wand mode the physical analogue is rotating the controller about
## its own forward axis, so this returns the signed roll relative to a reference
## pose captured when the trainee took hold.

## Signed rotation of `current` about `axis` relative to `reference`, degrees
## in [-180, 180]. Uses the controllers' up-vectors projected onto the plane
## perpendicular to the axis, with a fallback for the degenerate case where the
## up-vector is parallel to the axis.
static func roll_degrees(current: Basis, reference: Basis, axis: Vector3) -> float:
	if axis.length_squared() < 0.000001:
		return 0.0
	var a := axis.normalized()

	var ref_up := _project(reference.y, a)
	var cur_up := _project(current.y, a)
	if ref_up.length_squared() < 0.0001 or cur_up.length_squared() < 0.0001:
		ref_up = _project(reference.x, a)
		cur_up = _project(current.x, a)
	if ref_up.length_squared() < 0.0001 or cur_up.length_squared() < 0.0001:
		return 0.0

	return rad_to_deg(ref_up.normalized().signed_angle_to(cur_up.normalized(), a))


static func _project(v: Vector3, axis: Vector3) -> Vector3:
	return v - axis * v.dot(axis)
