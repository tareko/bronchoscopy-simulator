class_name ProcedureLog
extends RefCounted

## Event-sourced record of a training session, plus derived metrics.
##
## Everything the learner does is appended as a timestamped event. Metrics are
## derived from that log rather than tracked in parallel, so a debrief can be
## replayed, re-scored with a different rubric, or exported for research
## without re-running the case.
##
## Scoring model follows the deliberate-practice / proficiency-based
## progression literature (see docs/01-clinical-evidence.md): a trainee is
## judged on task completion and safety first, efficiency second. Thresholds
## live in the case resources, not in code.

const SCHEMA := "bronchsim.session/1"
const VERSION := 1

var case_id := ""
var airway_name := ""
var scope_radius_mm := 2.9
var learner_id := ""
var started_unix := 0
var events: Array[Dictionary] = []

var _sim_time_s := 0.0
var _max_depth_mm := 0.0
var _insert_travel_mm := 0.0
var _contact_events := 0
var _contact_mm := 0.0
var _segments: Dictionary = {}      # label -> dwell seconds
var _tasks: Dictionary = {}         # task id -> {done: bool, time_s}
var _tools: Dictionary = {}         # tool id -> uses
var _errors: Array[String] = []
var _last_label := ""
var _label_entered_at := 0.0
var _finished := false
## Canonical 18-segment inspection order (supplied by the anatomy tree).
var segment_order: Array[String] = []
## Scored segments entered, in order, one entry per transition.
var _segment_sequence: Array[String] = []
var _segment_first_s: Dictionary = {}   # label -> first entry time


func start(p_case_id: String, p_airway: String, p_learner := "",
		p_segment_order: Array[String] = []) -> void:
	case_id = p_case_id
	airway_name = p_airway
	learner_id = p_learner
	segment_order = p_segment_order.duplicate()
	started_unix = Time.get_unix_time_from_system()
	events.clear()
	_sim_time_s = 0.0
	_max_depth_mm = 0.0
	_insert_travel_mm = 0.0
	_contact_events = 0
	_contact_mm = 0.0
	_segments.clear()
	_tasks.clear()
	_tools.clear()
	_errors.clear()
	_last_label = ""
	_label_entered_at = 0.0
	_finished = false
	_segment_sequence.clear()
	_segment_first_s.clear()
	_append("session_start", {"case_id": case_id, "airway": airway_name, "learner": learner_id})


# --------------------------------------------------------------------------
# Event intake
# --------------------------------------------------------------------------

## Feed one endoscope frame report (see Endoscope.advance).
func track_frame(delta_s: float, report: Dictionary) -> void:
	_sim_time_s += maxf(delta_s, 0.0)

	var inserted := float(report.get("inserted_mm", 0.0))
	_insert_travel_mm += absf(inserted)
	_max_depth_mm = maxf(_max_depth_mm, float(report.get("depth_mm", 0.0)))

	var contact := float(report.get("contact_mm", 0.0))
	if contact > 0.05:
		_contact_events += 1
		_contact_mm += contact
		_append("wall_contact", {"mm": contact, "label": report.get("label", "")})

	if bool(report.get("blocked", false)):
		_append("blocked", {"label": report.get("label", "")})

	var label := str(report.get("label", ""))
	if not label.is_empty() and label != _last_label:
		_on_segment_change(label)

	if not label.is_empty():
		_segments[label] = float(_segments.get(label, 0.0)) + maxf(delta_s, 0.0)


func _on_segment_change(label: String) -> void:
	# Diagnostic completeness counts named bronchopulmonary segments only.
	if segment_order.has(label):
		_segment_sequence.append(label)
		if not _segment_first_s.has(label):
			_segment_first_s[label] = _sim_time_s
	var dwell := _sim_time_s - _label_entered_at
	if not _last_label.is_empty():
		_append("segment_exit", {"label": _last_label, "dwell_s": dwell})
	_append("segment_enter", {"label": label})
	_last_label = label
	_label_entered_at = _sim_time_s


func enter_segment(label: String) -> void:
	## Explicit hook for scoring scripts / scripted demos.
	_on_segment_change(label)


func record_tool_use(tool: String, success := true) -> void:
	_tools[tool] = int(_tools.get(tool, 0)) + 1
	_append("tool_use", {"tool": tool, "success": success})


func record_finding(finding_id: String, label: String, note := "") -> void:
	_append("finding", {"id": finding_id, "label": label, "note": note})


func record_task_completed(task_id: String, quality := 1.0) -> void:
	if _tasks.has(task_id) and bool(_tasks[task_id].get("done", false)):
		return
	_tasks[task_id] = {"done": true, "time_s": _sim_time_s, "quality": quality}
	_append("task_complete", {"task": task_id, "quality": quality})


func record_error(error_id: String, severity := "minor") -> void:
	_errors.append(error_id)
	_append("error", {"id": error_id, "severity": severity})


func record_note(note: String) -> void:
	_append("note", {"text": note})


func finish() -> void:
	if _finished:
		return
	_finished = true
	if not _last_label.is_empty():
		_append("segment_exit", {"label": _last_label, "dwell_s": _sim_time_s - _label_entered_at})
	_append("session_end", {"duration_s": _sim_time_s})


func _append(kind: String, payload: Dictionary) -> void:
	events.append({
		"t_s": snappedf(_sim_time_s, 0.001),
		"kind": kind,
		"data": payload,
	})


# --------------------------------------------------------------------------
# Metrics
# --------------------------------------------------------------------------

func elapsed_s() -> float:
	return _sim_time_s


func max_depth_mm() -> float:
	return _max_depth_mm


func total_travel_mm() -> float:
	return _insert_travel_mm


## 1.0 means the scope travelled only as far as it needed to; lower values
## mean wasted back-and-forth movement.
func path_economy() -> float:
	if _insert_travel_mm <= 0.001:
		return 0.0
	return clampf(_max_depth_mm / _insert_travel_mm, 0.0, 1.0)


func segments_visited(scored_only := true) -> Array[String]:
	var out: Array[String] = []
	for label in _segments.keys():
		if not scored_only or not str(label).is_empty():
			out.append(str(label))
	return out


## Fraction of `targets` the scope actually entered.
func coverage(targets: Array) -> float:
	if targets.is_empty():
		return 0.0
	var seen := 0
	for target in targets:
		if _segments.has(str(target)):
			seen += 1
	return float(seen) / float(targets.size())


## Diagnostic completeness: distinct numbered segments inspected out of 18.
func diagnostic_completeness() -> int:
	return _segment_first_s.size()


func segment_total() -> int:
	return maxi(segment_order.size(), 18)


## Structured progress: how many times inspection advanced to the *next*
## segment in canonical order. Rewards a systematic sweep, not random poking.
func structured_progress() -> int:
	var progressions := 0
	var previous := -1
	for label in _segment_sequence:
		var index := segment_order.find(label)
		if index < 0:
			continue
		if previous >= 0 and index == previous + 1:
			progressions += 1
		previous = index
	return progressions


## Average intersegmental time: mean seconds between first entries of distinct
## segments. Independent of how many segments the case asks for.
func average_intersegmental_time_s() -> float:
	if _segment_first_s.size() < 2:
		return 0.0
	var times: Array = _segment_first_s.values()
	times.sort()
	var first := float(times[0])
	var last := float(times[times.size() - 1])
	return (last - first) / float(times.size() - 1)


func tasks_completed() -> int:
	var count := 0
	for task in _tasks.values():
		if bool(task.get("done", false)):
			count += 1
	return count


func errors() -> Array[String]:
	return _errors.duplicate()


## Aggregate metrics plus a 0-100 score.
##
## `rubric` (all optional):
##   tasks_total         how many tasks the case defines (default: completed)
##   target_segments     Array of segment labels that count for coverage
##   weights             {tasks, coverage, efficiency, safety}, sums to 1
##   mastery_score       pass threshold for "proficient" (default 75)
func compute(rubric: Dictionary = {}) -> Dictionary:
	var targets: Array = rubric.get("target_segments", [])
	var tasks_total: int = int(rubric.get("tasks_total", maxi(tasks_completed(), 1)))
	# Default weights follow the evidence: task completion, then structured
	# progress (more sensitive than completeness), then completeness and safety.
	var weights: Dictionary = rubric.get("weights", {
		"tasks": 0.30, "sp": 0.25, "coverage": 0.25, "safety": 0.20,
	})
	var mastery: float = float(rubric.get("mastery_score", 75.0))

	var task_rate := clampf(float(tasks_completed()) / float(maxi(tasks_total, 1)), 0.0, 1.0)
	var dc := diagnostic_completeness()
	var dc_max := segment_total()
	var coverage_rate := coverage(targets) if not targets.is_empty() else float(dc) / float(dc_max)
	var sp := structured_progress()
	var sp_rate := clampf(float(sp) / float(maxi(dc_max - 1, 1)), 0.0, 1.0)
	var efficiency := path_economy()
	# Contact penalty: 40 wall contacts per procedure is a rough ceiling for a
	# competent operator on the generic tree; scaled by travel so long cases
	# are not punished twice.
	var contact_rate := 0.0
	if _insert_travel_mm > 1.0:
		contact_rate = clampf(_contact_events / (_insert_travel_mm / 100.0) / 40.0, 0.0, 1.0)
	var safety := 1.0 - contact_rate
	safety -= float(_errors.size()) * 0.1
	safety = clampf(safety, 0.0, 1.0)

	var score := 100.0 * (
		task_rate * float(weights.get("tasks", 0.30))
		+ sp_rate * float(weights.get("sp", 0.25))
		+ coverage_rate * float(weights.get("coverage", 0.25))
		+ safety * float(weights.get("safety", 0.20))
	)

	return {
		"case_id": case_id,
		"airway": airway_name,
		"duration_s": snappedf(_sim_time_s, 0.01),
		"max_depth_mm": snappedf(_max_depth_mm, 0.1),
		"travel_mm": snappedf(_insert_travel_mm, 0.1),
		"path_economy": snappedf(efficiency, 0.001),
		"diagnostic_completeness": dc,
		"diagnostic_completeness_max": dc_max,
		"structured_progress": sp,
		"structured_progress_max": maxi(dc_max - 1, 1),
		"average_intersegmental_time_s": snappedf(average_intersegmental_time_s(), 0.01),
		"wall_contacts": _contact_events,
		"wall_contact_mm": snappedf(_contact_mm, 0.1),
		"segments_visited": segments_visited(),
		"coverage": snappedf(coverage_rate, 0.001),
		"tasks_completed": tasks_completed(),
		"tasks_total": tasks_total,
		"errors": _errors.duplicate(),
		"tools_used": _tools.duplicate(),
		"score": snappedf(score, 0.1),
		"mastery_threshold": mastery,
		"passed": score >= mastery,
	}


# --------------------------------------------------------------------------
# Export
# --------------------------------------------------------------------------

func to_dict(rubric: Dictionary = {}) -> Dictionary:
	return {
		"schema": SCHEMA,
		"version": VERSION,
		"case_id": case_id,
		"airway": airway_name,
		"learner_id": learner_id,
		"scope_radius_mm": scope_radius_mm,
		"started_unix": started_unix,
		"metrics": compute(rubric),
		"events": events.duplicate(true),
	}


func save_json(path: String, rubric: Dictionary = {}) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(to_dict(rubric), "  "))
	file.close()
	return OK


## Flat event CSV: easy to drop into a spreadsheet or stats package.
func save_events_csv(path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_line("t_s,kind,payload_json")
	for event in events:
		file.store_line("%.3f,%s,\"%s\"" % [
			float(event["t_s"]),
			str(event["kind"]),
			JSON.stringify(event["data"]).replace("\"", "'"),
		])
	file.close()
	return OK
