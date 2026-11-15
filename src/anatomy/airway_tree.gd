class_name AirwayTree
extends RefCounted

## Bronchial tree graph: geometry queries, nomenclature and navigation helpers.
##
## The tree is a set of straight centreline segments (parent -> child). Every
## segment carries a clinically recognisable label, an inner lumen radius and a
## cumulative insertion depth from the incisors. Collision, guidance and
## scoring are all answered analytically from these segments, so the simulator
## needs no mesh colliders to know where the airway wall is.
##
## Units: millimetres, matching the anatomy JSON.

const SCHEMA := "bronchsim.airway_tree/1"

var source_path := ""
var name := ""
var display_name := ""
var units := "mm"

## Raw node dictionaries, in file order (parents precede children).
var nodes: Array[Dictionary] = []
var by_label: Dictionary = {}          # label -> Dictionary node
var child_labels: Dictionary = {}      # label -> Array[String]
var _scored: Array[String] = []


func load_from_file(path: String) -> Error:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("AirwayTree: cannot read %s" % path)
		return ERR_FILE_CANT_READ
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("AirwayTree: %s is not a JSON object" % path)
		return ERR_PARSE_ERROR
	var err := load_from_dict(parsed)
	if err == OK:
		source_path = path
		name = parsed.get("name", name)
		display_name = parsed.get("display_name", display_name)
		units = parsed.get("units", "mm")
	return err


func load_from_dict(data: Dictionary) -> Error:
	if str(data.get("schema", "")) != SCHEMA:
		push_error("AirwayTree: unsupported schema '%s'" % data.get("schema", ""))
		return ERR_INVALID_DATA

	nodes.clear()
	by_label.clear()
	child_labels.clear()
	_scored.clear()

	var raw: Variant = data.get("tree", [])
	if typeof(raw) != TYPE_ARRAY:
		return ERR_INVALID_DATA

	for entry in raw:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var node: Dictionary = entry.duplicate(true)
		var label := str(node.get("label", ""))
		if label.is_empty():
			continue
		if not node.has("radius_mm") or float(node["radius_mm"]) <= 0.0:
			push_error("AirwayTree: node %s has no positive radius" % label)
			return ERR_INVALID_DATA
		nodes.append(node)
		by_label[label] = node
		if bool(node.get("scored", false)):
			_scored.append(label)

	for node in nodes:
		var parent := _as_string(node.get("parent"))
		if parent.is_empty():
			continue
		if not by_label.has(parent):
			push_error("AirwayTree: node %s references unknown parent %s" % [node["label"], parent])
			return ERR_INVALID_DATA
		if not child_labels.has(parent):
			child_labels[parent] = []
		child_labels[parent].append(str(node["label"]))

	if nodes.is_empty():
		return ERR_INVALID_DATA
	return OK


# --------------------------------------------------------------------------
# Basic geometry
# --------------------------------------------------------------------------

func has_label(label: String) -> bool:
	return by_label.has(label)


func get_node_for(label: String) -> Dictionary:
	return by_label.get(label, {})


func start_of(label: String) -> Vector3:
	return _vec3(by_label[label].get("start_mm", [0, 0, 0]))


func end_of(label: String) -> Vector3:
	return _vec3(by_label[label].get("position_mm", [0, 0, 0]))


func direction_of(label: String) -> Vector3:
	return _vec3(by_label[label].get("direction", [0, -1, 0])).normalized()


func radius_of(label: String) -> float:
	return float(by_label[label].get("radius_mm", 5.0))


func depth_of(label: String) -> float:
	return float(by_label[label].get("depth_mm", 0.0))


func level_of(label: String) -> String:
	return str(by_label[label].get("level", ""))


func label_for_point(point: Vector3) -> String:
	return str(nearest_on_centerline(point).get("label", ""))


func entry_label() -> String:
	for node in nodes:
		if _as_string(node.get("parent")).is_empty():
			return str(node["label"])
	return ""


func scored_labels() -> Array[String]:
	return _scored.duplicate()


## The 18 numbered bronchopulmonary segments in the canonical inspection order
## (right 1-10, then left). Left B1+2 is apicoposterior and left B8 is
## anteromedial-basal (the left side fuses B1/B2 and B7/B8), which is why there
## are 10 right and 8 left, not 20.
func bronchopulmonary_segments() -> Array[String]:
	const ORDER := [
		"RB1", "RB2", "RB3", "RB4", "RB5", "RB6", "RB7", "RB8", "RB9", "RB10",
		"LB1+2", "LB3", "LB4", "LB5", "LB6", "LB8", "LB9", "LB10",
	]
	var out: Array[String] = []
	for label in ORDER:
		if by_label.has(label):
			out.append(label)
	return out


## Position of `label` in the canonical inspection order, or -1.
func segment_index(label: String) -> int:
	return bronchopulmonary_segments().find(label)


## Labels of all segments strictly below `label` (children, grandchildren, ...).
func descendants_of(label: String) -> Array[String]:
	var out: Array[String] = []
	var stack: Array[String] = []
	for child in child_labels.get(label, []):
		stack.append(str(child))
	while not stack.is_empty():
		var current: String = stack.pop_back()
		out.append(current)
		for child in child_labels.get(current, []):
			stack.append(str(child))
	return out


func is_descendant_of(label: String, ancestor: String) -> bool:
	var cursor := label
	var guard := 0
	while not cursor.is_empty() and guard < 256:
		if cursor == ancestor:
			return true
		cursor = _as_string(by_label.get(cursor, {}).get("parent"))
		guard += 1
	return false


## Labels from the root down to `label` (inclusive).
func route_to(label: String) -> Array[String]:
	var out: Array[String] = []
	var cursor := label
	var guard := 0
	while not cursor.is_empty() and guard < 256:
		out.push_front(cursor)
		cursor = _as_string(by_label.get(cursor, {}).get("parent"))
		guard += 1
	return out


# --------------------------------------------------------------------------
# Nearest-point queries
# --------------------------------------------------------------------------

## Closest point on the centreline to `point`.
##
## Returns a dictionary with:
##   label        segment id the projection falls on
##   t            normalised position along that segment (0..1)
##   on_axis      the projected centreline point
##   axis_dir     unit direction of the segment
##   radial_mm    distance from the axis
##   radius_mm    lumen radius at that projection
##   depth_mm     insertion depth at that projection
##   inside       0..1 clearance remaining (1 = on axis, 0 = touching wall)
func nearest_on_centerline(point: Vector3) -> Dictionary:
	var best_dist := INF
	var best: Dictionary = {}
	for node in nodes:
		var a := _vec3(node.get("start_mm", [0, 0, 0]))
		var b := _vec3(node.get("position_mm", [0, 0, 0]))
		var ab := b - a
		var len_sq := ab.length_squared()
		var t := 0.0
		if len_sq > 0.0001:
			t = clampf((point - a).dot(ab) / len_sq, 0.0, 1.0)
		var proj := a + ab * t
		var dist := point.distance_to(proj)
		if dist < best_dist:
			var r_start := float(node.get("radius_mm", 5.0))
			var parent := _as_string(node.get("parent"))
			var r_end := r_start
			if not parent.is_empty() and by_label.has(parent):
				r_end = r_start * 0.92
			var radius := lerpf(r_start, r_end, t)
			best_dist = dist
			best = {
				"label": str(node.get("label", "")),
				"t": t,
				"on_axis": proj,
				"axis_dir": ab.normalized() if len_sq > 0.0001 else Vector3.DOWN,
				"radial_mm": dist,
				"radius_mm": radius,
				"depth_mm": _depth_at(node, t),
				"inside": clampf(1.0 - dist / maxf(radius, 0.001), 0.0, 1.0),
			}
	return best


## Push `point` back inside the lumen, keeping its axial position.
## `margin_mm` is added to the effective wall so the scope never visually
## intersects the wall.
func clamp_to_lumen(point: Vector3, margin_mm := 0.0, scope_radius_mm := 0.0) -> Vector3:
	var current := point
	# Two iterations: clamping can move the point close enough to a different
	# segment (bifurcation) that the first projection's radius no longer
	# applies.
	for _iteration in 2:
		var hit := nearest_on_centerline(current)
		if hit.is_empty():
			return current
		var allowed: float = maxf(float(hit["radius_mm"]) - margin_mm - scope_radius_mm, 0.05)
		var offset: Vector3 = current - Vector3(hit["on_axis"])
		var dist := offset.length()
		if dist <= allowed:
			return current
		if dist < 0.0001:
			current = Vector3(hit["on_axis"])
			continue
		current = Vector3(hit["on_axis"]) + offset / dist * allowed
	return current


## True when the scope of the given radius can physically enter the segment.
func is_passable(label: String, scope_radius_mm: float) -> bool:
	if not by_label.has(label):
		return false
	return radius_of(label) > scope_radius_mm + 0.25


## Deepest depth the scope can reach from a label, following passable children.
func reachable_labels(scope_radius_mm: float) -> Array[String]:
	var out: Array[String] = []
	for node in nodes:
		var label := str(node["label"])
		if is_passable(label, scope_radius_mm):
			out.append(label)
	return out


## Segment label whose depth bracket contains `depth_mm` along the route to
## `target`; useful for the "you are here" panel.
func guidance_label(depth_mm: float, target: String) -> String:
	var route := route_to(target)
	var last := entry_label()
	for label in route:
		if depth_of(label) <= depth_mm + 1.0:
			last = label
		else:
			break
	return last


func _depth_at(node: Dictionary, t: float) -> float:
	var end_depth := float(node.get("depth_mm", 0.0))
	var length := float(node.get("length_mm", 0.0))
	return lerpf(end_depth - length, end_depth, t)


## JSON nulls arrive as `null`; treat them as empty strings.
static func _as_string(value: Variant) -> String:
	if value == null:
		return ""
	return str(value)


func _vec3(value: Variant) -> Vector3:
	if typeof(value) == TYPE_ARRAY and value.size() >= 3:
		return Vector3(float(value[0]), float(value[1]), float(value[2]))
	if typeof(value) == TYPE_VECTOR3:
		return value
	return Vector3.ZERO


func max_depth_mm() -> float:
	var deepest := 0.0
	for node in nodes:
		deepest = maxf(deepest, float(node.get("depth_mm", 0.0)))
	return deepest


func summary() -> String:
	return "%s: %d segments, %d scored, max depth %.0f mm" % [
		display_name if not display_name.is_empty() else name,
		nodes.size(), _scored.size(), max_depth_mm(),
	]
