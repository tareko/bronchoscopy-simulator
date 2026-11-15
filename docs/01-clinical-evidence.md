# Clinical evidence review — what we build, and what we refuse to claim

Full review with citations: [docs/research/clinical-evidence.md](research/clinical-evidence.md)
(~8.4k words, 9 tables, PMID/PMC-linked throughout). This page is the decision
summary: what the evidence changed about the design.

## The four findings that reshaped the design

### 1. Automated in-sim guidance is not a training intervention

A three-arm RCT of 36 residents found VR arrow/guidance feedback produced
structured progress of 15.0 ± 5.3 versus 15.5 ± 4.5 with **no feedback at all**
(p = 1.00), while a human tutor reached 18 ± 0 (p = 0.026 vs guidance).
[PMID 40494327](https://pubmed.ncbi.nlm.nih.gov/40494327/)

**Consequence:** the simulator is a *debriefing instrument*, not an
arrow-follower. Guidance is limited to orientation support (where am I, what am
I looking at), and the teaching value lives in the after-action report. This
killed the planned "ghost path / waypoint arrow" as a primary feature.

### 2. Measure the metrics that have construct validity — and nothing else first

| Metric | Definition | Evidence |
| --- | --- | --- |
| **DC** — diagnostic completeness | distinct numbered segments inspected / 18 | correlates with SP (r = 0.62) |
| **SP** — structured progress | count of transitions to the *correct next* segment in canonical order | **more sensitive than DC** to instructional differences |
| **PT** — procedure time | total seconds | used as primary outcome in 2026 RCTs |
| **AIT** — average intersegmental time | mean seconds between first entries | r = −0.52 with SP |
| Wall contacts | collisions with airway wall | validated as a skill marker |

Source: [PMID 33282381](https://pubmed.ncbi.nlm.nih.gov/33282381/) (Cold 2020),
adopted as primary outcomes by the Naik 2026 and Deng 2026 RCTs.

**Consequence:** `ProcedureLog` implements DC, SP, PT, AIT and wall-contact count
today, and the rubric weights SP above raw completeness. Composite "fun" scores
are secondary and always shown next to the primary metrics.

### 3. Get the nomenclature right, or every score is wrong

There are **18** numbered bronchopulmonary segments: 10 right (B1–B10) and
**8 left**, because the left side fuses B1+B2 (apicoposterior) and B7+B8
(anteromedial-basal). Splitting them is not a rounding error — it corrupts the DC
denominator on every single session.

**Consequence:** `AirwayTree.bronchopulmonary_segments()` returns exactly 18
labels in canonical order, regression-tested. The generated tree has `LB1+2` and
`LB8` and no `LB2`/`LB7`.

### 4. Anatomical variety is the only design feature with a positive RCT

Training across multiple different anatomies beat training on one standard model
when tested on a novel anatomy: DC +2.5 segments, SP +9 correct progressions
(both p < 0.001), with partial retention at 3 months, n = 60 novices.
[PMID 41207791](https://pubmed.ncbi.nlm.nih.gov/41207791/)

Anatomic variation is near-universal (200/204 dissections in the cited series).

**Consequence:** shipping one fixed airway is a design error. The generator is
seeded so several labelled trees can ship in v1, with CT-derived real-anatomy
cases as the roadmap item that matters most (see docs/06).

## What we will not claim

- **No simulator has ever been shown to change patient outcomes.** Zero studies.
  Cochrane 2025 found insufficient evidence to replace conventional training.
- Simulator scores correlate only weakly with real-patient performance
  (r ≈ 0.24, CI −0.02–0.47).
- **No HMD-based bronchoscopy validity evidence exists.** The validated
  archetype is a screen + instrumented scope, not a headset + wand controllers.
  This project inherits no validity from that literature; it has to generate its
  own. Hence the metrics export: every session is a dataset row, and a
  validation study is a stated goal, not a marketing line.
- Our generated insertion depths are **model-derived, not normative**. No
  reliable table of "cm from the incisors" by segment could be located; the
  literature gives means with wide spread. Do not present them as standards.

## Where the training benefit is most defensible

Trainee involvement is associated with more complications (4.5% vs 1.2%;
first-trimester fellows 3.1%) — [PMID 17035454](https://pubmed.ncbi.nlm.nih.gov/17035454/).
A trainee who arrives at the patient having already inspected 18 segments a
hundred times, and who has rehearsed a bleed, is the plausible mechanism for
benefit. Nothing in this project claims more than that.

## Implications carried into the roadmap

1. Debrief first-class: replay, per-segment timeline, DC/SP/PT/AIT, wall-contact
   map, tool-use log. Export JSON + CSV.
2. Orientation aids are *reference*, not autopilot: segment labels on approach,
   a miniature airway map with current position, depth readout.
3. Mastery criteria are explicit and configurable (e.g. DC ≥ 17/18, SP ≥ 16,
   no red-out) rather than a vague percentage.
4. Case scripts emphasise safety-critical behaviours that the evidence names:
   recognise and manage bleeding, keep the tip off the wall, confirm the target
   segment before sampling.
5. Haptics are optional (force feedback has no proven effect); wall-contact
   counting plus a scope-shaped controller matters more. This is why v1 is
   controller-only and phase 2 adds a tracked prop, not a force-feedback rig.
6. Log everything, forever — path, collisions, suction time, tool use, dwell
   per segment — because the future validation study needs it and cannot be
   reconstructed afterwards.
