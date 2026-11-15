# Roadmap

Each milestone has an acceptance criterion that can be demonstrated, not a date.
Order is chosen so the riskiest assumptions fail early.

## M0 — Research and engine core ✅ (v0.1, this repository)

- [x] Evidence review, prior-art review, stack review (`docs/research/`)
- [x] Anatomy as a labelled graph, procedurally generated and validated
- [x] Scope kinematics: lever + torque + insertion, lumen clamping, wall slide
- [x] Event-sourced metrics with DC, SP, PT, AIT, wall contacts
- [x] Desktop mode, procedural airway mesh, OpenXR bootstrap
- [x] 46 headless checks including a scripted navigation autopilot and CI

## M1 — VR interaction (next)

- [x] Printed scope prop designed: lever + AS5600 + Tracker shoe (`hardware/prop`)
- [ ] Build and dry-fit the printed prop; measure the real lever throw
- [ ] OpenXR action map with `/interaction_profiles/htc/vive_controller` bindings
- [ ] Ratchet insertion mapping on grip; trackpad lever; wrist-rotation torque
- [ ] Controller rumble proportional to wall contact
- [ ] Seated panel view and standing immersive view
- [ ] In-VR menu: case select, reset, quit, comfort options

**Acceptance:** a Vive user, without a mouse, can insert to 30 cm depth, navigate
to RB6, feel wall contact, and quit — in under five minutes from launch.
**Risk being retired:** wand-only control is usable. If it is not, the fallback is
a printed scope prop with a Vive Tracker (see docs/04).

## M2 — Vertical slice: cases 1 and 2

- [ ] Case data format + `CaseRunner`
- [ ] Segment label panel on approach, orientation map, depth readout
- [ ] Tool framework: forceps, brush, suction; working-channel advance
- [ ] Lesion volumes, sample confirmation, sight-of-lesion rule
- [ ] Debrief screen (timeline, path overlay, metrics) + JSON/CSV export
- [ ] Mastery criteria per case

**Acceptance:** `anatomy_tour` and `peripheral_lesion` are completable
end-to-end in VR; the debrief shows DC/SP/PT/AIT and names three specific
improvements; the session exports.

## M3 — Airway behaviour: cases 3 and 4

- [ ] Mucus volumes and suction clearance
- [ ] Lens soiling and cleaning (unscored by any commercial product)
- [ ] Bleeding: vessel damage, particle blood, pooling, soiling
- [ ] Wedge detection, cold saline, balloon tamponade, escalation actions
- [ ] Vitals model (saturation trace) and time-critical scoring

**Acceptance:** in `bleeding`, a competent user regains view within 20 s and
controls or escalates within 60 s; the debrief shows time-to-view and
time-to-control; blind instrument use is logged as an error.

## M4 — Tools and fluid: cases 5 and 6

- [ ] Graspable rigid bodies (foreign body), forceps bite, drops, distal migration
- [ ] Fluid instillation/aspiration for BAL, return-fraction metric
- [ ] Case 5 and 6 scripts and rubrics

**Acceptance:** both cases completable with correct metrics and debriefs.

## M5 — Advanced: cases 7 and 8

- [ ] Ultrasound fan rendering, mediastinal station volumes, Doppler overlay
- [ ] EBUS needle throw and pass counting
- [ ] Per-segment radius overrides (stenosis), contact-position histogram
- [ ] Case 7 and 8 scripts and rubrics

**Acceptance:** EBUS station identification is scored; stenosis case rewards a
contact-free pass with a visible histogram.

## M6 — Teaching infrastructure

- [ ] Instructor view: spectator window + free camera
- [ ] Optional remote watch over WebSocket (MJPEG) for teaching at a distance
- [ ] Printable HTML debrief → PDF
- [ ] Learner history: attempt-over-attempt comparison
- [ ] Multiple anatomy variants shipped by default

**Acceptance:** an instructor on another machine can watch a session live; a
learner can compare this week's attempt to last month's.

## M7 — Real anatomy

- [ ] `tools/ct_pipeline` implemented (Slicer + TotalSegmentator + skeleton)
- [ ] Clinician labelling workflow with markup files
- [ ] Two CT-derived cases under a redistribution-permitting licence
- [ ] Provenance metadata enforced at load time

**Acceptance:** a CT-derived tree loads with no engine change and passes the same
validation as the synthetic one; a clinician confirms all 18 labels.

## M8 — Distribution

- [ ] AppImage build with bundled export templates
- [ ] Flatpak manifest (Flathub submission when stable)
- [ ] Signed session files / reproducible builds where practical
- [ ] Release notes and a 2-minute demo video

**Acceptance:** a fresh Ubuntu machine can install and run without Godot.

## Explicitly deferred

- Force-feedback scope prop (hardware; better evidence needed first)
- Multiplayer / networked assessment
- Rigid bronchoscopy, stents, cryotherapy
- Console/mobile/Windows builds
- Any validity claim beyond "practice tool"

## Why eight cases, and what a summative claim would need

Generalizability data from a 12-case bronchoscopy test show **6 cases** support
formative reliability > 0.7 and **10 cases** support summative reliability > 0.8
(PMID [41963810](https://pubmed.ncbi.nlm.nih.gov/41963810/)). Eight cases is
therefore a *formative* set. If an exam/credentialing claim is ever wanted, the
package needs at least 10 comparable-difficulty cases, fixed test conditions and a
contrasting-groups standard-setting exercise — a separate project, not a v1
feature.

## Validation study (post-M6)

A small prospective study — resident cohort, mastery criteria, DC/SP measured in
the simulator and compared with supervisor ratings on real procedures — is the
only way to make a defensible training claim. The metrics export and event log
exist now so this is possible later without redesign. It needs local ethics
approval and a clinical collaborator; neither exists yet, and the README says so.
