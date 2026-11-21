# Bronchoscopy Simulator

Open-source virtual-reality bronchoscopy training for Linux and OpenXR headsets
(HTC Vive first). Eight clinical cases, a CT-derived anatomy pipeline, and a
metrics/debrief system designed around published bronchoscopy assessment tools.

**Status: v0.1 — research + engine core.** The airway data model, scope
kinematics, metrics log, procedural airway renderer and headless test suite work
today. The VR interaction layer, cases and debrief UI are the current build
target (see [docs/09-roadmap.md](docs/09-roadmap.md)).

[![tests](https://img.shields.io/badge/tests-46%20passing-brightgreen)](tests/run_tests.gd)
[![licence](https://img.shields.io/badge/licence-MIT-blue)](LICENSE)

---

## Why

Flexible bronchoscopy is a psychomotor skill: you steer a 60 cm bending tube with
one thumb lever and torque, find a 6 mm ostium at 30 cm depth, and keep the tip
off the wall while you work. Trainees get few supervised repetitions, and
assessment is subjective. VR gives unlimited repetitions with objective,
replayable measurement — if the simulator models the *instrument-airway
interaction* honestly and measures what educators already score.

This project is not affiliated with any vendor and is not a credentialing
device. It is a training adjunct, built so that the anatomy, the scope model and
the scoring rules are inspectable and improvable.

## Quick start (Linux)

```bash
# Godot 4.7+ required; install the editor or a headless build and put it on PATH
git clone https://github.com/tareko/bronchoscopy-simulator
cd bronchoscopy-simulator

./scripts/run.sh                # desktop mode: keyboard-driven, no headset
./scripts/run.sh --vr           # OpenXR on (HTC Vive via SteamVR or Monado)
./scripts/run.sh --editor       # open in the Godot editor
```

Two Vive wands are enough to train — the printed scope prop is an optional
upgrade, not a requirement. Wand mapping: grip + push to insert, trackpad Y for
deflection, wrist roll for torque (details in
[docs/04](docs/04-scope-model.md#wand-only-mode-the-default)).

Desktop controls: `W`/`S` push and pull the scope, `A`/`D` deflect the tip,
`Q`/`E` torque the shaft, `R` reset, `Tab` toggles between the external preview
camera and the endoscopic view.

OpenXR is deliberately **off** in `project.godot`: with no runtime installed the
engine otherwise pops an "OpenXR was requested but failed to start" alert on
every launch. Enable it per run with `--vr`, or tick *Project Settings → XR →
OpenXR → Enabled* while the headset is connected.

### Headless tests

```bash
godot --headless --path . --script tests/run_tests.gd
```

46 checks covering anatomy loading, laterality, lumen clamping, passability,
insertion/withdrawal, blocking, DC/SP metrics, and a scripted autopilot that
navigates to the right lower lobe's superior segment (RB6).

## Current capabilities

| Area | State |
| --- | --- |
| Bronchial tree model (85 segments, Boyden nomenclature, depths from incisors) | working |
| Lumen-aware scope kinematics (lever + torque + insertion, wall contact) | working |
| Procedural airway mesh (runtime, no binary assets) | working |
| Session event log, metrics, rubric scoring, JSON/CSV export | working |
| Desktop preview mode + keyboard control | working |
| 3D-printable scope prop: spring lever, AS5600, Tracker shoe | designed (STLs committed) |
| Lever mapping (deadzone/invert/expo) with tests | working |
| Wand-only VR input: ratcheted insertion, trackpad lever, wrist torque | implemented (needs hardware test) |
| Optional printed prop: auto-detected as the lever source | implemented |
| Eight cases, guidance/minimap, debrief UI | next |
| CT → airway pipeline (3D Slicer + TotalSegmentator) | designed, not implemented |
| Instructor/observer view, AppImage/Flatpak packaging | planned |

## Repository layout

```
assets/anatomy/        generic_adult.json (generated, CC0-safe synthetic tree)
docs/                  design, evidence review, roadmap, VR setup
src/anatomy/           airway_tree.gd (graph + queries), airway_mesh_builder.gd
src/scope/             endoscope.gd (lever/torque/insertion kinematics)
src/metrics/           procedure_log.gd (event sourcing, rubric, export)
src/main.gd            desktop entry point and VR bootstrap
hardware/prop/         printable scope prop: OpenSCAD source, STLs, firmware, BOM
tests/run_tests.gd     dependency-free headless suite
tools/gen_anatomy/     procedural airway generator
tools/ct_pipeline/     DICOM → airway graph (designed; see docs/06)
```

## Design documents

- [Vision and non-goals](docs/00-vision.md)
- [Clinical evidence review](docs/01-clinical-evidence.md)
- [Architecture](docs/02-architecture.md)
- [Case catalogue](docs/03-case-catalog.md)
- [Scope model and VR input mapping](docs/04-scope-model.md)
- [Metrics, rubric and debrief](docs/05-metrics.md)
- [Anatomy assets and the CT pipeline](docs/06-anatomy-pipeline.md)
- [Linux VR setup and performance](docs/07-vr-linux-setup.md)
- [Prior art: commercial, academic and open-source](docs/08-prior-art.md)
- [Roadmap](docs/09-roadmap.md)

## Hardware

**Optional**: a printable bronchoscope prop (spring-centred lever + Vive Tracker
shoe, ~€30 of parts plus a Tracker) lives in [`hardware/prop/`](hardware/prop/README.md) with a
parametric OpenSCAD source, committed STLs, an RP2040/AS5600 firmware sketch and
a printability validator. The evidence for why a physical handle matters more
than force feedback is in [docs/08](docs/08-prior-art.md).

## Contributing

Pull requests are welcome — especially airway dimensions with citations,
clinical case scripts, GDScript tests, and anyone who owns a Vive and can test
on hardware. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Licence

MIT. The bundled airway tree is synthetic (generated by
`tools/gen_anatomy/generate_generic_tree.py`) and contains no patient data.
Patient-derived cases are never committed; see the data policy in
[docs/06-anatomy-pipeline.md](docs/06-anatomy-pipeline.md).
