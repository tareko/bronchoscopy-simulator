class_name Endoscope
extends RefCounted

## Kinematic flexible bronchoscope.
##
## Deliberately not a rigid-body physics toy. A real bronchoscope is a bending
## tube with one deflection lever and no independent left/right joint: lateral
## steering is done by torquing the shaft, and the airway itself guides the
## instrument. The model reproduces that:
##
##   * `lever`  (-1..1) sets tip deflection relative to the local lumen axis,
##   * `roll`   (degrees) torques the shaft, rotating the bending plane,
##   * insertion advances the tip along its current heading,
##   * the lumen clamps the tip so the scope cannot pass through airway wall,
##   * the travelled path (`path`) is the source of truth and the visible shaft
##     (`body`) is a resampled, clamped view of it.
##
## `path` stays separate from `body` because a blocked tip must not erase the
## shaft's history, and because withdrawal is a truncation of that history.
##
## Limits of this approximation are documented in docs/04-scope-model.md;
## a position-based (Cosserat) shaft is the planned V2.
##
## Units: millimetres and degrees.

signal blocked(segment_label: String)

const SCOPE_LENGTH_MM := 600.0

var tree: AirwayTree
var scope_radius_mm := 2.45     ## 4.9 mm diagnostic scope; 2.9 for a therapeutic one
var node_spacing_mm := 8.0
var max_deflection_deg := 80.0
var deflect_rate_deg_s := 170.0
var align_rate_deg_s := 55.0    ## how strongly the airway guides a free tip
var wall_margin_mm := 0.25
## How much the airway wall redirects a jammed tip (0 = rigid wall, 1 = the
## tip always follows the lumen). Real cartilaginous airway is compliant: a
## scope pushed against the wall slides along it rather than stopping dead.
var wall_slide_bias := 0.65
var substep_mm := 3.0
var entry_label := "ENTRY"

## Full travelled centreline, proximal -> distal. Source of truth.
var path := PackedVector3Array()
## Evenly spaced, lumen-clamped samples of `path`, proximal -> distal.
var body := PackedVector3Array()
## Current tip heading.
var tip_dir := Vector3.DOWN
## Pitch axis of the bending plane; rotated by torque, parallel-transported
## when the tip follows the airway.
var bend_axis := Vector3.RIGHT

var _lever := 0.0
var _old_path := PackedVector3Array()


func reset() -> void:
	path = PackedVector3Array()
	body = PackedVector3Array()
	_old_path = PackedVector3Array()
	_lever = 0.0
	if tree == null:
		return
	var entry := tree.start_of(entry_label)
	path.append(entry)
	tip_dir = tree.direction_of(entry_label).normalized()
	bend_axis = _orthogonalise(Vector3.RIGHT, tip_dir)
	_resample()


# --------------------------------------------------------------------------
# Main update
# --------------------------------------------------------------------------

## Advance the simulation by one frame.
##
## `insert_mm`  how far the operator pushed (positive) or pulled (negative).
## `lever`      tip deflection request, -1 .. +1.
## `roll_deg`   torque applied to the shaft this frame.
func advance(insert_mm: float, lever := 0.0, roll_deg := 0.0, dt := 1.0 / 90.0) -> Dictionary:
	var report := {
		"inserted_mm": 0.0,
		"contact_mm": 0.0,
		"blocked": false,
		"label": get_current_label(),
		"depth_mm": get_insertion_depth_mm(),
		"tip": get_tip(),
		"tip_dir": tip_dir,
		"centrality": _tip_centrality(),
	}
	if tree == null or path.is_empty():
		return report

	_old_path = path.duplicate()
	_lever = clampf(lever, -1.0, 1.0)
	if not is_zero_approx(roll_deg):
		_apply_roll(roll_deg)

	var contact := 0.0
	var inserted := 0.0
	if insert_mm > 0.0:
		var result := _insert(insert_mm)
		inserted = result["inserted"]
		contact += result["contact"]
		report["blocked"] = result["blocked"]
		if result["blocked"]:
			blocked.emit(get_current_label())
	elif insert_mm < 0.0:
		inserted = -_withdraw(-insert_mm)

	_update_tip_direction(dt)
	_resample()

	report["inserted_mm"] = inserted
	report["contact_mm"] = contact
	report["label"] = get_current_label()
	report["depth_mm"] = get_insertion_depth_mm()
	report["tip"] = get_tip()
	report["tip_dir"] = tip_dir
	report["centrality"] = _tip_centrality()
	return report


func _insert(distance_mm: float) -> Dictionary:
	var remaining := distance_mm
	var moved := 0.0
	var contact := 0.0
	var was_blocked := false
	var budget := int(SCOPE_LENGTH_MM - _polyline_length(path))

	while remaining > 0.0001 and budget > 0:
		var step: float = minf(minf(substep_mm, remaining), float(budget))
		var target := get_tip() + tip_dir * step
		var hit := tree.nearest_on_centerline(target)
		if hit.is_empty():
			break
		var clearance: float = float(hit["radius_mm"]) - scope_radius_mm - wall_margin_mm
		if clearance <= 0.05:
			was_blocked = true
			break
		var radial: float = target.distance_to(Vector3(hit["on_axis"]))
		if radial > clearance:
			contact += radial - clearance
			target = Vector3(hit["on_axis"]) + (target - Vector3(hit["on_axis"])).normalized() * clearance
			step = get_tip().distance_to(target)
			if step < minf(substep_mm, remaining) * 0.4:
				# Jammed against the wall: let the lumen redirect the push.
				var axis: Vector3 = Vector3(hit["axis_dir"]).normalized()
				var slide_dir: Vector3 = (tip_dir * (1.0 - wall_slide_bias)
					+ axis * wall_slide_bias).normalized()
				var slide_target := get_tip() + slide_dir * minf(substep_mm, remaining)
				var slide_hit := tree.nearest_on_centerline(slide_target)
				if not slide_hit.is_empty():
					var slide_clearance: float = float(slide_hit["radius_mm"]) \
						- scope_radius_mm - wall_margin_mm
					if slide_clearance > 0.05:
						var slide_offset: Vector3 = slide_target - Vector3(slide_hit["on_axis"])
						if slide_offset.length() > slide_clearance:
							slide_target = Vector3(slide_hit["on_axis"]) \
								+ slide_offset.normalized() * slide_clearance
						target = slide_target
						step = get_tip().distance_to(target)
			if step < 0.05:
				was_blocked = true
				break

		path.append(target)
		bend_axis = _orthogonalise(bend_axis, tip_dir)
		moved += step
		remaining -= step
		budget -= int(ceil(step))
	return {"inserted": moved, "contact": contact, "blocked": was_blocked}


## Pull back by truncating the travelled path.
func _withdraw(distance_mm: float) -> float:
	var old_tip := get_tip()
	var new_length := maxf(_polyline_length(_old_path) - distance_mm, 0.0)
	path = _truncate(_old_path, new_length)
	if path.is_empty():
		path.append(tree.start_of(entry_label))
	var travelled := old_tip.distance_to(get_tip())
	if path.size() >= 2:
		tip_dir = (path[path.size() - 1] - path[path.size() - 2]).normalized()
	return travelled


## Rebuild `body` as evenly spaced, lumen-clamped samples of `path`.
func _resample() -> void:
	if path.size() < 2:
		body = path.duplicate()
		return
	var max_points := int(SCOPE_LENGTH_MM / node_spacing_mm) + 1
	var source := path
	for pass_index in 2:
		var total := _polyline_length(source)
		var count := mini(int(total / node_spacing_mm), max_points - 1)
		var distal_first := PackedVector3Array()
		for k in range(count + 1):
			var point := _point_at_length(source, total - float(k) * node_spacing_mm)
			if pass_index == 1:
				point = tree.clamp_to_lumen(point, wall_margin_mm, scope_radius_mm)
			distal_first.append(point)

		var proximal_first := PackedVector3Array()
		proximal_first.resize(distal_first.size())
		for k in distal_first.size():
			proximal_first[k] = distal_first[distal_first.size() - 1 - k]
		body = proximal_first
		if pass_index == 0:
			source = body


func _point_at_length(points: PackedVector3Array, length_mm: float) -> Vector3:
	if points.is_empty():
		return Vector3.ZERO
	if length_mm <= 0.0:
		return points[0]
	var travelled := 0.0
	for i in range(1, points.size()):
		var seg := points[i].distance_to(points[i - 1])
		if travelled + seg >= length_mm:
			var t := (length_mm - travelled) / maxf(seg, 0.0001)
			return points[i - 1].lerp(points[i], t)
		travelled += seg
	return points[points.size() - 1]


func _update_tip_direction(dt: float) -> void:
	var hit := tree.nearest_on_centerline(get_tip())
	if hit.is_empty():
		return
	var lumen_dir := Vector3(hit["axis_dir"]).normalized()
	bend_axis = _orthogonalise(bend_axis, tip_dir)

	var desired := lumen_dir
	if absf(_lever) > 0.001:
		desired = lumen_dir.rotated(bend_axis, _lever * deg_to_rad(max_deflection_deg))

	var rate := deflect_rate_deg_s
	if absf(_lever) <= 0.001:
		rate = align_rate_deg_s
	tip_dir = _rotate_toward(tip_dir, desired, deg_to_rad(rate) * dt)


func _apply_roll(roll_deg: float) -> void:
	bend_axis = _orthogonalise(bend_axis.rotated(tip_dir.normalized(), deg_to_rad(roll_deg)), tip_dir)


# --------------------------------------------------------------------------
# Queries
# --------------------------------------------------------------------------

func get_tip() -> Vector3:
	if path.is_empty():
		return Vector3.ZERO
	return path[path.size() - 1]


func get_tip_direction() -> Vector3:
	return tip_dir


func get_body() -> PackedVector3Array:
	return body


func get_path() -> PackedVector3Array:
	return path


func get_insertion_depth_mm() -> float:
	var hit := tree.nearest_on_centerline(get_tip())
	return float(hit.get("depth_mm", 0.0))


func get_current_label() -> String:
	if tree == null or path.is_empty():
		return ""
	return tree.label_for_point(get_tip())


## How centred the tip is in the lumen: 1 on the axis, 0 at the wall.
func _tip_centrality() -> float:
	var hit := tree.nearest_on_centerline(get_tip())
	if hit.is_empty():
		return 1.0
	var radius: float = maxf(float(hit["radius_mm"]), 0.001)
	return clampf(1.0 - float(hit["radial_mm"]) / radius, 0.0, 1.0)


## Clearance to the wall at the tip in mm; negative means penetration.
func get_wall_clearance_mm() -> float:
	var hit := tree.nearest_on_centerline(get_tip())
	if hit.is_empty():
		return INF
	return float(hit["radius_mm"]) - float(hit["radial_mm"]) - scope_radius_mm


func get_route_labels() -> Array[String]:
	var label := get_current_label()
	if tree == null or label.is_empty():
		return []
	return tree.route_to(label)


func remaining_mm_to(label: String) -> float:
	if tree == null or not tree.has_label(label):
		return -1.0
	return tree.depth_of(label) - get_insertion_depth_mm()


func is_tip_inside(label: String) -> bool:
	return tree != null and tree.is_descendant_of(get_current_label(), label)


# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

func _polyline_length(points: PackedVector3Array) -> float:
	var total := 0.0
	for i in range(1, points.size()):
		total += points[i].distance_to(points[i - 1])
	return total


## Portion of `points` (proximal first) up to `length_mm` of arc.
func _truncate(points: PackedVector3Array, length_mm: float) -> PackedVector3Array:
	var out := PackedVector3Array()
	if points.is_empty():
		return out
	out.append(points[0])
	if length_mm <= 0.0:
		return out
	var travelled := 0.0
	for i in range(1, points.size()):
		var seg := points[i].distance_to(points[i - 1])
		if travelled + seg <= length_mm:
			out.append(points[i])
			travelled += seg
		else:
			var t := (length_mm - travelled) / maxf(seg, 0.0001)
			out.append(points[i - 1].lerp(points[i], t))
			return out
	return out


func _orthogonalise(axis: Vector3, forward: Vector3) -> Vector3:
	var f := forward.normalized()
	var a := axis - f * axis.dot(f)
	if a.length_squared() < 0.0001:
		a = f.cross(Vector3.UP)
		if a.length_squared() < 0.0001:
			a = f.cross(Vector3.RIGHT)
	return a.normalized()


func _rotate_toward(from: Vector3, to: Vector3, max_radians: float) -> Vector3:
	var a := from.normalized()
	var b := to.normalized()
	var angle := a.angle_to(b)
	if angle <= max_radians or angle < 0.00001:
		return b
	var axis := a.cross(b)
	if axis.length_squared() < 1e-8:
		return b
	return a.rotated(axis.normalized(), max_radians)
