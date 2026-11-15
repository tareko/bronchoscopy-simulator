# Metrics, rubric and debrief

## Why event sourcing

Every interaction is appended to a log as `{t_s, kind, data}`. Metrics are
derived from that log on demand. Consequences:

- a session can be re-scored later with a better rubric without re-running it,
- the debrief can replay the procedure from the timeline,
- exported sessions are usable as research data,
- tests construct synthetic event sequences to check scoring.

`ProcedureLog` is a plain `RefCounted` object: no scene tree, no singletons.

## Event kinds

| Kind | Data | Emitted when |
| --- | --- | --- |
| `session_start` | case_id, airway, learner | session begins |
| `segment_enter` | label | nearest segment changes to a new label |
| `segment_exit` | label, dwell_s | previous segment left |
| `wall_contact` | mm, label | tip clamped by the lumen |
| `blocked` | label | tip could not advance |
| `tool_use` | tool, success | forceps/brush/needle/suction action |
| `finding` | id, label, note | learner documents anatomy/pathology |
| `task_complete` | task, quality | case task satisfied |
| `error` | id, severity | safety-critical mistake |
| `session_end` | duration_s | session finishes |

## Primary metrics (evidence-backed)

| Metric | Definition | Implementation |
| --- | --- | --- |
| **DC** — diagnostic completeness | distinct numbered segments inspected / 18 | `_segment_first_s.size()` in canonical order |
| **SP** — structured progress | transitions to the *next* segment in canonical order (max 17) | `structured_progress()` |
| **PT** — procedure time | seconds from start to finish | `elapsed_s()` |
| **MIT** — mean intersegmental time | **PT ÷ DC** (the validated definition), reported as the headline fluency number | `mean_intersegmental_time_s()` |
| **Segments revisited** | segments entered more than once; reported, not punished | `segments_revisited()`, `revisit_events()` |
| **Mid-lumen fraction** | share of procedure time with the tip in the central half of the lumen | `mid_lumen_fraction()` |
| **Wall contacts** | count of frames where the tip was clamped by the wall | `_contact_events` |
| **Path economy** | max depth ÷ total travel (1.0 = no backtracking) | `path_economy()` |

A timestamp-based intersegmental time (`average_intersegmental_time_s()`) is
also logged, for fluency analysis that is independent of DC. The PT/DC
definition is the one to report as MIT.

Rationale and citations: [docs/01-clinical-evidence.md](01-clinical-evidence.md).

## Composite score

Only used for grading a case, never as the headline. Default weights:

```json
{ "tasks": 0.30, "sp": 0.25, "coverage": 0.25, "safety": 0.20 }
```

### More than one valid route

Scoring only a canonical pathway produces false negatives for experienced
operators who take an equally valid route, and false positives for novices who
learn to "beat" a fixed path (Sun 2026). Cases can therefore declare the
inspection orders they accept:

```json
"rubric": { "inspection_order": ["RB1","RB2","RB3","RB5","RB6","LB1+2"] }
```

`structured_progress(order)` scores against it; the debrief always shows the
route the learner actually took alongside the accepted ones.

where `coverage` is DC/18 when the case does not specify target segments, and
`safety` is 1 − contact penalty − 0.1 per logged error. Weights are case data: an
educator can change them without touching code, and the raw metrics are always
exported alongside the score.

## Mastery learning

The literature supports criterion gating rather than fixed hours. A case may
declare:

```json
"mastery": {
  "diagnostic_completeness_min": 17,
  "structured_progress_min": 16,
  "max_wall_contacts": 40,
  "must_complete_tasks": ["reach_target", "sample_3x", "no_blind_deployment"]
}
```

A session passes only when every criterion holds; the debrief shows which failed
and by how much.

**Where the numbers come from.** A mastery threshold should be set by
contrasting-groups standard setting, not chosen for tidiness. The only published
bronchoscopy-simulator pass mark is **34.4%** (contrasting groups, 15 novices vs
15 experienced, PMID
[41963810](https://pubmed.ncbi.nlm.nih.gov/41963810/)); a 75% composite is
arbitrary until we have our own data. That study also shows reliability needs
**6 cases** for formative and **10** for summative assessment, which constrains
how many cases a "test" mode must present. This mirrors the proficiency-based progression studies, and it
gives a trainee a reason to repeat a case rather than scrape through.

## Debrief contents

1. **Headline:** pass/fail against the case's mastery criteria, with the failing
   criteria listed first.
2. **Timeline:** segment entries on a horizontal time axis, with tool uses and
   events marked; hovering shows depth and clearance.
3. **Where you went:** a path overlay on the airway graph (3D or 2D projection),
   colour-coded by wall contact density.
4. **Comparisons:** DC/SP/PT/AIT against the case target and against the
   learner's own history (first attempt vs best), not against other people.
5. **Three specific improvements,** generated from the log (e.g. "you entered
   RML three times; inspect RB4 then RB5 in order"), never generic praise.
6. **Export:** session JSON + flat CSV of events, plus a printable HTML report.

## Export format

```json
{
  "schema": "bronchsim.session/1",
  "version": 1,
  "case_id": "bleeding_rll",
  "airway": "generic_adult",
  "learner_id": "anon-8f21",
  "started_unix": 1794000000,
  "metrics": { "diagnostic_completeness": 11, "structured_progress": 7, "score": 62.4, "…": "…" },
  "events": [ { "t_s": 0.0, "kind": "session_start", "data": {} } ]
}
```

`learner_id` is a local pseudonym, never a name. No data leaves the machine
unless the user exports it deliberately.

## Privacy and ethics

- Sessions are written to `user://sessions/`, never uploaded.
- No patient data can enter a session: cases reference anatomy labels, not
  imaging.
- CT-derived cases carry provenance metadata naming the source dataset and its
  licence; patient-derived trees are not committed (docs/06).
- Any study using exported sessions needs local ethics approval; the export
  format is deliberately audit-friendly for that process.

## Known gaps

- No validated metrics exist for suction, BAL, bleeding management, foreign-body
  retrieval or stenosis navigation. Cases 3–8 use *provisional* metrics derived
  from task completion and safety events, and are labelled as such in the debrief
  so nobody mistakes them for validated instruments.
- SP depends on the canonical order; variant anatomy may make a different order
  correct, which is a case-level `inspection_order` override we have not yet
  implemented.
- Wall-contact counting is a proxy for force, not force itself.
