extends SceneTree

## Headless test suite. Run with:
##
##   godot --headless --path . --script tests/run_tests.gd
##
## Exits non-zero on the first failed expectation. Keeping this dependency-free
## means CI needs nothing but a Godot binary.

const AirwayTreeScript := preload("res://src/anatomy/airway_tree.gd")
const EndoscopeScript := preload("res://src/scope/endoscope.gd")
const ProcedureLogScript := preload("res://src/metrics/procedure_log.gd")
const LeverMapperScript := preload("res://src/scope/lever_mapper.gd")

const TREE_PATH := "res://assets/anatomy/generic_adult.json"

var _checks := 0
var _failures: Array[String] = []
var _current := ""


func _initialize() -> void:
	print("== bronchoscopy simulator: headless tests ==")

	_test_tree_loads()
	_test_tree_laterality_and_depth()
	_test_nearest_point_and_clamp()
	_test_passability()
	_test_scope_insert_and_withdraw()
	_test_scope_blocks_on_narrow_airway()
	_test_metrics_and_export()
	_test_evidence_metrics()
	_test_lever_mapper()
	_test_scripted_run()

	print("")
	if _failures.is_empty():
		print("PASS  %d checks" % _checks)
		quit(0)
	else:
		print("FAIL  %d/%d checks failed" % [_failures.size(), _checks])
		for failure in _failures:
			print("  - " + failure)
		quit(1)


# --------------------------------------------------------------------------
# Tests
# --------------------------------------------------------------------------

func _test_tree_loads() -> void:
	_begin("tree loads")
	var tree = _load_tree()
	if tree == null:
		return
	_check(tree.nodes.size() >= 60, "expected at least 60 centreline segments, got %d" % tree.nodes.size())
	_check(tree.has_label("RMB"), "missing right main bronchus")
	_check(tree.has_label("LB10"), "missing left posterior basal segment")
	_check(tree.scored_labels().size() == 26, "expected 26 scored segments, got %d" % tree.scored_labels().size())
	_check(tree.entry_label() == "ENTRY", "entry should be ENTRY, got %s" % tree.entry_label())


func _test_tree_laterality_and_depth() -> void:
	_begin("tree laterality and depth")
	var tree = _load_tree()
	if tree == null:
		return
	# +X is the subject's left, so right-lung branches are negative X.
	_check(tree.end_of("RB10").x < 0.0, "RB10 should lie in the right lung (-X), got %.1f" % tree.end_of("RB10").x)
	_check(tree.end_of("LB10").x > 0.0, "LB10 should lie in the left lung (+X), got %.1f" % tree.end_of("LB10").x)
	_check(tree.depth_of("RB10") > tree.depth_of("TRACH"), "segments must be deeper than the trachea end")
	_check(absf(tree.depth_of("TRACH") - 245.0) < 30.0,
		"carina depth should be near 245 mm, got %.1f" % tree.depth_of("TRACH"))
	_check(tree.descendants_of("RMB").has("RB10"), "RB10 should descend from RMB")
	_check(tree.route_to("RB10").size() >= 4, "route to RB10 should pass several segments")
	_check(tree.max_depth_mm() < 600.0, "tree must fit inside a 600 mm scope")


func _test_nearest_point_and_clamp() -> void:
	_begin("nearest point and lumen clamp")
	var tree = _load_tree()
	if tree == null:
		return

	var on_axis: Vector3 = tree.end_of("RB6")
	var hit: Dictionary = tree.nearest_on_centerline(on_axis)
	_check(float(hit["radial_mm"]) < 1.0, "point on the centreline should have ~0 radial distance")
	_check(str(hit["label"]) == "RB6", "nearest segment should be RB6, got %s" % hit["label"])

	var radius: float = float(hit["radius_mm"])
	var outside: Vector3 = on_axis + Vector3(radius * 4.0, 0.0, 0.0)
	var clamped: Vector3 = tree.clamp_to_lumen(outside, 0.0, 0.0)
	var after: Dictionary = tree.nearest_on_centerline(clamped)
	_check(float(after["radial_mm"]) <= radius + 0.1,
		"clamped point should sit inside the lumen (radial %.2f > radius %.2f)" % [after["radial_mm"], radius])

	var scope_clamped: Vector3 = tree.clamp_to_lumen(outside, 0.35, 2.9)
	var scope_after: Dictionary = tree.nearest_on_centerline(scope_clamped)
	# Judge against the segment the clamped point actually lands on: near a
	# bifurcation the projection can switch to a narrower child.
	var clearance_after: float = float(scope_after["radius_mm"]) - 0.35 - 2.9
	_check(float(scope_after["radial_mm"]) <= maxf(clearance_after, 0.05) + 0.15,
		"scope radius should be accounted for in the clamp (radial %.2f, allowance %.2f)" % [
			scope_after["radial_mm"], clearance_after])


func _test_passability() -> void:
	_begin("passability by scope diameter")
	var tree = _load_tree()
	if tree == null:
		return
	_check(tree.is_passable("TRACH", 2.9), "therapeutic scope must pass the trachea")
	_check(tree.is_passable("RMB", 2.9), "therapeutic scope must pass the right main bronchus")
	_check(not tree.is_passable("RB6a", 2.9), "subsegmental airway should be too narrow for a 5.8 mm scope")
	_check(tree.is_passable("RB6a", 1.2), "2.4 mm scope should pass subsegmental airways")


func _test_scope_insert_and_withdraw() -> void:
	_begin("scope insert and withdraw")
	var tree = _load_tree()
	if tree == null:
		return
	var scope = _new_scope(tree)

	scope.reset()
	_check(scope.get_tip().distance_to(Vector3.ZERO) < 0.01, "tip should start at the incisors")

	# Push down the trachea, keeping the lever neutral.
	for i in 120:
		scope.advance(4.0, 0.0, 0.0, 1.0 / 90.0)
	var depth: float = scope.get_insertion_depth_mm()
	_check(depth > 120.0, "expected >120 mm insertion, got %.1f" % depth)
	_check(depth < 460.0, "insertion should stay within scope length, got %.1f" % depth)
	_check(scope.get_body().size() > 4, "scope body should have several nodes")
	_check(scope.get_wall_clearance_mm() > -0.5, "tip should not penetrate the wall")

	var deep_tip: Vector3 = scope.get_tip()
	# Pull back 100 mm and expect the tip to move back up.
	for i in 25:
		scope.advance(-4.0, 0.0, 0.0, 1.0 / 90.0)
	_check(scope.get_insertion_depth_mm() < depth - 50.0,
		"withdrawal should reduce depth (%.1f -> %.1f)" % [depth, scope.get_insertion_depth_mm()])
	_check(scope.get_tip().distance_to(deep_tip) > 10.0, "tip should move when withdrawing")


func _test_scope_blocks_on_narrow_airway() -> void:
	_begin("scope blocks at a narrowing")
	var tree = _load_tree()
	if tree == null:
		return
	var scope = _new_scope(tree)
	scope.scope_radius_mm = 6.5   # deliberately fatter than most segments
	scope.reset()
	var blocked := false
	for i in 200:
		var report: Dictionary = scope.advance(4.0, 0.0, 0.0, 1.0 / 90.0)
		if bool(report.get("blocked", false)):
			blocked = true
			break
	_check(blocked, "an oversized scope must eventually be blocked")
	_check(scope.get_insertion_depth_mm() < 300.0, "oversized scope should not reach the periphery")


func _test_metrics_and_export() -> void:
	_begin("metrics and export")
	var tree = _load_tree()
	if tree == null:
		return
	var scope = _new_scope(tree)
	var log = ProcedureLogScript.new()
	log.start("test.case", tree.name, "", tree.bronchopulmonary_segments())

	var total := 0.0
	for i in 60:
		var report: Dictionary = scope.advance(3.0, 0.0, 0.0, 1.0 / 90.0)
		log.track_frame(1.0 / 90.0, report)
		total += 1.0 / 90.0
	log.record_tool_use("suction", true)
	log.record_task_completed("inspect_trachea")
	log.finish()

	var metrics: Dictionary = log.compute({"target_segments": ["TRACH"], "tasks_total": 1})
	_check(absf(float(metrics["duration_s"]) - total) < 0.05,
		"duration should be ~%.2f s, got %.2f" % [total, metrics["duration_s"]])
	_check(float(metrics["score"]) >= 0.0 and float(metrics["score"]) <= 100.0,
		"score must be 0-100, got %.1f" % metrics["score"])
	_check(float(metrics["path_economy"]) <= 1.0, "path economy cannot exceed 1")
	_check(not log.events.is_empty(), "events should be recorded")
	_check(log.segments_visited().size() >= 1, "at least one segment should be visited")

	var path := "user://test_session.json"
	_check(log.save_json(path, {"target_segments": ["TRACH"]}) == OK, "session JSON should save")
	var text := FileAccess.get_file_as_string(path)
	_check(text.length() > 100, "session JSON should not be empty")
	var parsed: Variant = JSON.parse_string(text)
	_check(typeof(parsed) == TYPE_DICTIONARY and parsed.get("schema", "") == ProcedureLogScript.SCHEMA,
		"session JSON should round-trip with the expected schema")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _test_evidence_metrics() -> void:
	_begin("diagnostic completeness and structured progress")
	var tree = _load_tree()
	if tree == null:
		return
	var order: Array[String] = tree.bronchopulmonary_segments()
	_check(order.size() == 18, "there should be 18 numbered bronchopulmonary segments, got %d" % order.size())
	_check(order.has("LB1+2"), "left B1+2 must be fused as apicoposterior")
	_check(not order.has("LB7"), "left B7 must not exist (fused into B8)")
	_check(not order.has("LB2"), "left B2 must not exist as a separate segment")
	_check(order.find("RB10") == 9, "RB10 should be 10th in canonical order")

	var log = ProcedureLogScript.new()
	log.start("test.dc", tree.name, "", order)
	# RB1 -> RB2 -> RB3 (two correct progressions), skip to RB5 -> RB6
	# (one more), then jump to LB1+2 (not consecutive), then re-inspect RB2.
	for label in ["RB1", "RB2", "RB3", "RB5", "RB6", "LB1+2", "RB2"]:
		log.enter_segment(label)
	# four seconds of frame time, mostly mid-lumen
	for i in 4:
		log.track_frame(1.0, {"centrality": 0.9})
	log.track_frame(1.0, {"centrality": 0.1})
	log.finish()

	var metrics: Dictionary = log.compute({"target_segments": order})
	_check(int(metrics["diagnostic_completeness"]) == 6,
		"DC should count 6 distinct segments, got %s" % metrics["diagnostic_completeness"])
	_check(int(metrics["structured_progress"]) == 3,
		"SP should count 3 correct progressions, got %s" % metrics["structured_progress"])
	_check(int(metrics["diagnostic_completeness_max"]) == 18, "DC denominator should be 18")
	_check(int(metrics["segments_revisited"]) == 1, "one segment was revisited, got %s" % metrics["segments_revisited"])
	_check(int(metrics["revisit_events"]) == 1, "one extra entry, got %s" % metrics["revisit_events"])
	# MIT is PT/DC: 5 s over 6 inspected segments.
	_check(absf(float(metrics["mean_intersegmental_time_s"]) - (5.0 / 6.0)) < 0.02,
		"MIT should be PT/DC = 0.83 s, got %.2f" % metrics["mean_intersegmental_time_s"])
	_check(absf(float(metrics["mid_lumen_fraction"]) - 0.8) < 0.02,
		"mid-lumen fraction should be 4/5, got %.2f" % metrics["mid_lumen_fraction"])

	# Some cases accept more than one valid inspection order; scoring only the
	# canonical route produces false negatives for experts (Sun 2026).
	var alt_order: Array[String] = ["RB1", "RB2", "RB3", "RB5", "RB6", "LB1+2"]
	var alt_metrics: Dictionary = log.compute({
		"target_segments": order,
		"inspection_order": alt_order,
	})
	_check(int(alt_metrics["structured_progress"]) == 5,
		"a valid alternative order should score 5 progressions, got %s" % alt_metrics["structured_progress"])


func _test_lever_mapper() -> void:
	_begin("physical lever mapping")
	var mapper = LeverMapperScript.new()
	_check(is_zero_approx(mapper.map_axis(0.0)), "centred lever must read exactly 0")
	_check(is_zero_approx(mapper.map_axis(0.02)), "inside the deadzone must read 0")
	_check(absf(mapper.map_axis(1.0) - 1.0) < 0.001, "full travel must read 1")
	_check(absf(mapper.map_axis(-1.0) + 1.0) < 0.001, "full travel the other way must read -1")
	_check(absf(mapper.map_axis(2.5) - 1.0) < 0.001, "out-of-range input must clamp")
	var mid: float = mapper.map_axis(0.5)
	_check(mid > 0.4 and mid < 0.5, "half travel should stay close to 0.48, got %.3f" % mid)
	mapper.invert = true
	_check(mapper.map_axis(0.5) < 0.0, "invert must flip the sign")
	mapper.invert = false
	mapper.expo = 2.0
	_check(mapper.map_axis(0.5) < mid, "expo > 1 must soften mid travel")
	# calibrated encoder path: 2048 centre, 900 half span (fresh mapper, no expo)
	var flat = LeverMapperScript.new()
	var mapped: float = flat.map_angle(2048 + 450, 2048, 900)
	_check(mapped > 0.4 and mapped < 0.6, "half-deflected encoder should read ~0.48, got %.3f" % mapped)
	_check(is_zero_approx(flat.map_angle(2048, 2048, 900)), "encoder at centre must read 0")
	_check(is_zero_approx(flat.map_angle(2048 + 450, 2048, 0)), "uncalibrated encoder must read 0")


func _test_scripted_run() -> void:
	_begin("scripted run reaches the right lower lobe")
	var tree = _load_tree()
	if tree == null:
		return
	var scope = _new_scope(tree)
	var log = ProcedureLogScript.new()
	log.start("test.scripted", tree.name, "", tree.bronchopulmonary_segments())

	# A simple autopilot: steer the tip toward the lumen direction of the
	# segment we want, and push. This exercises the whole stack end to end.
	var target := "RB6"
	var reached := false
	var stuck := 0
	# Advance at a realistic hand speed: ~1.2 mm per 90 Hz frame is 108 mm/s,
	# still brisk, but slow enough for the tip to articulate into a branch.
	for i in 1800:
		var command := _autopilot_command(tree, scope, target)
		var report: Dictionary = scope.advance(command["insert"], command["lever"], command["roll"], 1.0 / 90.0)
		log.track_frame(1.0 / 90.0, report)
		if tree.is_descendant_of(scope.get_current_label(), target):
			reached = true
			log.record_task_completed("reach_rb6")
			break
		var current: String = scope.get_current_label()
		if not current.is_empty() and current != target \
				and not tree.is_descendant_of(target, current):
			# Wandered into a branch that cannot lead to the target: back out
			# rather than pressing on. (RUL is the easy way to do this.)
			var back_out: Dictionary = scope.advance(-20.0, 0.0, 0.0, 1.0 / 90.0)
			log.track_frame(0.0, back_out)
			continue
		if bool(report.get("blocked", false)):
			stuck += 1
			if stuck >= 3:
				# overshot the ostium: back up and line up again
				var back: Dictionary = scope.advance(-15.0, 0.0, 0.0, 1.0 / 90.0)
				log.track_frame(0.0, back)
				stuck = 0
		else:
			stuck = 0
	log.finish()

	_check(reached, "autopilot should reach RB6; ended at %s (depth %.0f mm)" % [
		scope.get_current_label(), scope.get_insertion_depth_mm()])
	_check(log.max_depth_mm() > 280.0, "RB6 should be deeper than 280 mm, got %.0f" % log.max_depth_mm())


# --------------------------------------------------------------------------
# Autopilot used by the scripted test
# --------------------------------------------------------------------------

## Pure-pursuit steering for the scripted test: follow the centreline route
## toward the target with a fixed lookahead, rolling the bending plane onto it.
func _autopilot_command(tree, scope, target: String) -> Dictionary:
	var poly := PackedVector3Array()
	for label in tree.route_to(target):
		poly.append(tree.start_of(label))
	poly.append(tree.end_of(target))

	var look := _lookahead_point(poly, scope.get_tip(), 45.0)
	var forward: Vector3 = scope.get_tip_direction()
	var to_look: Vector3 = (look - scope.get_tip()).normalized()
	if to_look.dot(forward) > 0.9995:
		return {"insert": 1.2, "lever": 0.0, "roll": 0.0}

	var desired_axis: Vector3 = forward.cross(to_look).normalized()
	var sign := 1.0
	if desired_axis.dot(scope.bend_axis) < 0.0:
		sign = -1.0
	var target_axis: Vector3 = desired_axis * sign
	var roll_err: float = rad_to_deg(scope.bend_axis.signed_angle_to(target_axis, forward))
	var lever: float = sign * clampf(forward.angle_to(to_look) / deg_to_rad(scope.max_deflection_deg), -1.0, 1.0)
	# Keep pushing at a steady hand speed; the steering loop plus wrong-branch
	# recovery is enough on this anatomy. (Gating insertion on alignment made
	# the tip dwell at the carina and drift into the upper lobe instead.)
	var insert := 1.2
	return {
		"insert": insert,
		"lever": lever,
		"roll": clampf(roll_err, -25.0, 25.0),
	}


## Point `lookahead_mm` further along the polyline, measured by arc length
## from the tip's projection (not from the nearest vertex, which makes the
## controller cut corners through the airway wall).
func _lookahead_point(poly: PackedVector3Array, tip: Vector3, lookahead_mm: float) -> Vector3:
	if poly.size() < 2:
		return tip

	var best_s := 0.0
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
		var proj := a.lerp(b, t)
		var dist := tip.distance_to(proj)
		if dist < best_dist:
			best_dist = dist
			best_s = arc + seg * t
		arc += seg
		total = arc

	var s := minf(best_s + lookahead_mm, total)
	arc = 0.0
	for i in range(1, poly.size()):
		var a := poly[i - 1]
		var b := poly[i]
		var seg := a.distance_to(b)
		if seg < 0.0001:
			continue
		if arc + seg >= s:
			return a.lerp(b, (s - arc) / seg)
		arc += seg
	return poly[poly.size() - 1]


# --------------------------------------------------------------------------
# Harness
# --------------------------------------------------------------------------

func _load_tree():
	var tree = AirwayTreeScript.new()
	var err: Error = tree.load_from_file(TREE_PATH)
	if err != OK:
		_failures.append("could not load %s (error %d)" % [TREE_PATH, err])
		return null
	return tree


func _new_scope(tree):
	var scope = EndoscopeScript.new()
	scope.tree = tree
	scope.reset()
	return scope


func _begin(name: String) -> void:
	_current = name
	print("-- " + name)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append("[%s] %s" % [_current, message])
