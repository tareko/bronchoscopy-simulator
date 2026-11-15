# Incoming agent work — inventory and provenance

Everything the research subagents produced, what it was worth, and where it
ended up. Kept so nothing is lost when agents are stopped, resumed or superseded.

Legend: **canonical** = supersedes drafts and is cited by the project docs;
**superseded** = kept for provenance only; **scratch** = raw source material an
agent left behind; **pending** = agent still working at the time of writing.

## Canonical reports (one directory up)

| File | Produced by | Topic | Integrated into |
| --- | --- | --- | --- |
| `../clinical-evidence.md` | cloud research pass | simulation evidence, metrics, nomenclature | `docs/01`, `docs/05` |
| `../prior-art.md` | cloud research pass | commercial/academic prior art | `docs/08` |
| `../linux-vr-stack.md` | cloud research pass | runtime, engine, budget, assets | `docs/07`, `docs/06` |
| `../evidence-supplement-2026.md` | this session, via SearXNG/Europe PMC | 2026 studies, HMD-vs-screen nuance, case-count reliability | `docs/01`, `docs/05`, `docs/09` |

## This directory

| File | Produced by | Topic | Verdict / use |
| --- | --- | --- | --- |
| `haptics-input-kinematics.md` | haptics & kinematics subagent | glove/hardware survey on Linux, OpenXR haptic reality, measured force and torque, PCC vs Cosserat vs XPBD, collision strategy, scope-view rendering | **used**: force targets and V2 kinematics folded into `docs/04` |
| `scratch-monado.md` | XR stack subagent | Monado build/usage notes | background for `docs/07` |
| `scratch-vmtk.md` | XR stack subagent | VMTK install/usage (centreline extraction) | background for the CT pipeline (`docs/06`) |
| `scratch-za.md` | asset subagent | Z-Anatomy (CC BY-SA 4.0, Blender `.blend`, ~291 MB, breaks on Blender ≥ 4.5) | licence row added to `docs/06` |
| `raw_search_godotsurg.json` | XR stack subagent | GitHub search for Godot surgical projects | **empty result** (`total_count: 0`), no value |
| `raw_search_openxrmed.json` | XR stack subagent | GitHub search for OpenXR medical projects | needs review; no obvious hits in the file header |

## Archive (superseded drafts)

`../archive/` holds three drafts from local-model runs — the vendor landscape,
the tech-stack scoping and a prior-art note. They are longer than the canonical
reports but contain unverified vendor claims (prices, hardware specs, "portable
VR" framing). `docs/08` now carries a short, clearly flagged section derived from
the landscape draft; nothing else from the archive is cited.

## Pending at hand-off

| Agent | Topic | Status |
| --- | --- | --- |
| medical 3D asset sources | licences and pipeline for anatomy meshes | running |
| haptics & endoscopy kinematics | (report above already on disk) | running, finalising |

Their outputs will be appended here and folded into `docs/06` / `docs/04` when
they land. The depth-2 agents covering Asian products and the validity
literature have finished; their findings are reflected in the archived landscape
draft and in `docs/01`, but the vendor table there remains unverified.
