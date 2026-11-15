# Case catalogue

Eight cases ship in v1. Each is a data file (`assets/cases/<id>.json`) plus a
`CaseRunner` script; the engine knows nothing case-specific. Every case declares
its learner level, pathology anchors (by anatomical label), tasks, success
criteria and rubric.

Common structure:

```json
{
  "id": "bleeding_rll",
  "title": "Brisk bleeding after transbronchial biopsy",
  "level": "fellow",
  "scope": { "radius_mm": 2.45, "length_mm": 600 },
  "briefing": "…",
  "pathology": [ { "kind": "bleeding", "label": "RB8", "severity": 0.7 } ],
  "tasks": [ { "id": "locate_bleed", "label": "RB8", "time_limit_s": 120 } ],
  "success": { "tasks_total": 4, "target_segments": ["RB8"], "mastery_score": 75 },
  "rubric": { "weights": { "tasks": 0.35, "sp": 0.2, "coverage": 0.2, "safety": 0.25 } }
}
```

---

## 1. `anatomy_tour` — normal anatomy and segment identification

- **Level:** resident / novice. **Anatomy:** any variant (randomised).
- **Objective:** name the segment you are in; inspect all 18 systematically.
- **Tasks:** identify the main carina; enter each lobe; name 10 random segments
  from the in-VR panel; complete a full 18-segment sweep.
- **Success:** DC ≥ 16/18, SP ≥ 14, no red-out (tip against wall > 3 s).
- **Measures:** DC, SP, PT, AIT, wall contacts, identification accuracy.
- **Engine needs:** segment labels on approach, orientation map. *No guidance
  arrows* — see docs/01.

## 2. `peripheral_lesion` — lesion localisation, biopsy and brush

- **Level:** fellow. **Anatomy:** CT-derived or generic; lesion in RB8.
- **Objective:** reach a peripheral lesion, confirm position, sample it.
- **Tasks:** navigate to RB8; bring lesion into view for ≥ 2 s; deploy forceps and
  take 3 samples; brush the lesion; document location.
- **Success:** 3/3 samples confirmed, lesion in view at each deployment, no
  sampling while the lesion is out of view.
- **Measures:** sample count, view-confirmation ratio, DC/SP, PT, wall contacts.
- **Engine needs:** working channel tool deployment, lesion volume, sample
  confirmation rule, forceps open/close visuals.

## 3. `secretions` — mucus plugging and suction

- **Level:** resident. **Anatomy:** generic; mucus in RB6 and the basal trunk.
- **Objective:** recognise obstruction, clear it without bleeding the airway.
- **Tasks:** locate the plug; suck it clear from RB6 and one basal segment; avoid
  contact with the wall at high suction.
- **Success:** both segments patent (clearance > 80%), no iatrogenic bleeding.
- **Measures:** clearance fraction, suction time, wall contacts during suction,
  SP/DC, PT.
- **Engine needs:** mucus volumes with opacity, suction removal rate, lens
  soiling (a scored consequence nobody else measures — see docs/08).

## 4. `bleeding` — brisk haemorrhage management

- **Level:** fellow. **Anatomy:** generic; bleeding at RB8 after a biopsy.
- **Objective:** in the first 60 s: suction to keep the field visible, wedge the
  scope in the bleeding segment, instil cold saline, escalate correctly.
- **Tasks:** clear blood to regain view; wedge the scope; cold saline; escalate
  (call for help / balloon tamponade) within 60 s; keep the patient's simulated
  saturation above threshold.
- **Success:** view regained within 20 s, bleed controlled or escalated within
  60 s, no blind instrument use.
- **Measures:** time-to-view, time-to-control, suction duty cycle, saturation
  trace, safety-critical action log, wall contacts.
- **Engine needs:** bleeding particle system fed by vessel damage, blood pooling
  and lens soiling, wedge detection (tip in a segment with air leak blocked),
  escalation actions, vital-sign model.

## 5. `foreign_body` — retrieval

- **Level:** fellow. **Anatomy:** generic; a tooth in the bronchus intermedius.
- **Objective:** visualise, grasp, and extract without pushing it distally.
- **Tasks:** locate the object; grasp with forceps (or basket); withdraw without
  dropping it more than twice; keep the object in view during withdrawal.
- **Success:** extracted, ≤ 2 drops, no distal migration.
- **Measures:** grasps, drops, distal migration events, PT, wall contacts.
- **Engine needs:** graspable rigid body with friction, forceps bite detection,
  withdrawal with an object (collision radius grows).

## 6. `bal` — bronchoalveolar lavage

- **Level:** resident. **Anatomy:** generic; target LB4 (lingula).
- **Objective:** wedge the scope in the target segment and lavage correctly.
- **Tasks:** reach LB4; wedge (no air leak); instil 100 mL in aliquots; retrieve
  ≥ 40% return; label the specimen.
- **Success:** correct segment, wedge confirmed, return fraction ≥ 40%,
  specimen labelled with the right segment.
- **Measures:** return fraction, aliquot discipline, wedge quality, DC/SP, PT.
- **Engine needs:** fluid instillation/aspiration model, wedge detection, fluid
  level visuals.

## 7. `ebus` — EBUS-TBNA station sampling

- **Level:** fellow / advanced. **Anatomy:** generic plus mediastinal stations
  (4R, 7, 10R, 11R).
- **Objective:** identify stations, sample with the needle under ultrasound.
- **Tasks:** identify station 7 and 4R; sample each with 3 passes; avoid
  puncturing vessels (simulated Doppler overlay).
- **Success:** 2 stations sampled, 3 passes each, no vascular puncture.
- **Measures:** station accuracy, passes, puncture events, PT.
- **Engine needs:** ultrasound fan rendering, station volumes, needle throw,
  doppler overlay. Advanced: build after case 2's tool framework.

## 8. `stenosis` — difficult airway navigation

- **Level:** fellow. **Anatomy:** generic with a distal tracheal stenosis
  (8 mm lumen) and a tortuous left main bronchus.
- **Objective:** navigate a narrowed, distorted airway without contact.
- **Tasks:** pass the stenosis without wall contact; reach LB6; return.
- **Success:** zero contacts through the stenosis, DC ≥ 8, no red-out.
- **Measures:** contact count at the stenosis, insertion smoothness, PT.
- **Engine needs:** segment-level radius override, contact-position histogram.

---

## Case dependencies and build order

```
M2  anatomy_tour        (needs: labels, orientation map, DC/SP scoring)
M2  peripheral_lesion   (needs: tool framework, lesion volumes, sampling rules)
M3  secretions          (needs: suction + lens soiling)
M3  bleeding            (needs: blood VFX, wedge detection, escalation, vitals)
M4  foreign_body        (needs: graspable bodies)
M4  bal                 (needs: fluid model, wedge detection — shares M3 work)
M5  ebus                (needs: ultrasound view, mediastinal stations)
M5  stenosis            (needs: per-segment radius override)
```

Cases 1 and 2 are the vertical slice: they prove anatomy, navigation, tools,
scoring and debrief end to end. Cases 3 and 4 carry the safety-training claim, so
they come before the technically easier but less defensible foreign body case.
