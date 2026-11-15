# Vision and non-goals

## The problem

Flexible bronchoscopy is a core competency for pulmonologists, critical-care
physicians and thoracic surgeons, but procedural training is constrained:

- **Few repetitions.** Airway time is scarce and supervised by one consultant
  at a time; trainees may perform a handful of bronchoscopies before
  independent practice.
- **Subjective assessment.** Feedback is often a global impression. Formal
  instruments exist (BSTAT, DOPS, checklists) but are rarely used per procedure.
- **No failure rehearsal.** Emergency scenarios — brisk bleeding, a lost
  airway, a foreign body — are rare and cannot be practised on demand.
- **Patient-specific difficulty.** A rigid, narrow airway cannot be simulated on
  a mannequin, yet that is exactly the anatomy where navigation skill matters.

Commercial simulators solve parts of this, but they are expensive, Windows-only,
closed, and their internal assumptions cannot be audited or extended by the
people who teach with them.

## What this project is

A free, open-source VR bronchoscopy trainer for desktop Linux and OpenXR
headsets (HTC Vive first, since that is the hardware in hand), covering eight
common bronchoscopic tasks:

1. normal anatomy tour and segment identification,
2. peripheral lesion localisation with biopsy/brush,
3. secretions and mucus plugging, with suction and clearance,
4. airway bleeding, with suction, tamponade and escalation,
5. foreign-body retrieval,
6. BAL/lavage of a target segment,
7. EBUS-TBNA station sampling,
8. difficult airway / stenosis navigation.

It measures what bronchoscopists already teach: does the trainee reach the right
segment, by a safe path, in reasonable time, without beating up the airway, and
does the documented finding match the simulated pathology?

## Who it is for

Primary audience: **pulmonary and critical-care fellows and residents**, plus
anaesthesia trainees learning bronchoscopic intubation-adjacent skills.

Secondary audiences: medical students (anatomy recognition), practising
pulmonologists refreshing technique or learning a new platform, and educators
who need a measurable, repeatable training station.

## Success criteria

The project is useful when a trainee can say, honestly:

1. "I can navigate to any bronchopulmonary segment by name, on the first or
   second attempt, without a wrong turn."
2. "I can recognise an abnormal segment and perform the correct sampling
   manoeuvre on a lesion."
3. "I know what to do in the first 60 seconds of a brisk airway bleed."

And when an educator can say:

4. "The simulator's metrics agree with what I see in the room" — path economy,
   wall contact, segment coverage, task completion and time.
5. "It runs on the hardware we already own, offline, with no licence server."

## Design principles

1. **Honest instrument model.** A bronchoscope has one deflection lever, no
   left/right joint, and is steered by torque plus airway guidance. Faking a
   six-axis joystick teaches the wrong motor pattern.
2. **Measurable by construction.** Every interaction is an event; every metric
   derives from the event log. Scoring rules are data, not code, so educators can
   change thresholds without touching the engine.
3. **Anatomy is data.** The airway is a labelled graph with radii and depths.
   Rendering, collision and scoring all read that graph, so CT-derived cases
   work identically to the synthetic default.
4. **Works without a headset.** Everything must be diagnosable and testable on a
   laptop: headless tests, desktop mode, and a scripted autopilot that proves
   navigation still works.
5. **No patient data in git.** Deliberate, documented policy (see docs/06).

## Non-goals (v1)

- **Not a credentialing or certification tool.** Passing a case is practice, not
  proof of competence. Any validity claim needs a study we have not run.
- **Not a high-fidelity force model.** Haptic realism is delivered by wall
  contact and controller vibration, not by a $40k haptic interface. Phase 2 can
  add a physical scope prop (see docs/04).
- **Not a surgical simulator for rigid bronchoscopy, stents or airway
  interventions** — those are separate skills with different tools.
- **Not an anatomy atlas.** The airway is deliberately schematic at
  subsegmental level until CT cases land.
- **Not a networked assessment platform.** Single-user sessions export local
  files; a central scoring service is out of scope.
- **Not Windows/macOS first.** Linux is the primary platform because that is the
  development and training hardware; other platforms may work but are untested.
