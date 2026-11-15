# Incoming agent work — inventory and provenance

Everything the research subagents produced, what it was worth, and where it
ended up. Kept so nothing is lost when agents are stopped, resumed or superseded.

Legend: **canonical** = supersedes drafts and is cited by the project docs;
**superseded** = kept for provenance only; **scratch** = raw source material an
agent left behind.

## Canonical reports (`docs/research/`)

| File | Produced by | Topic | Integrated into |
| --- | --- | --- | --- |
| `../clinical-evidence.md` | cloud research pass | simulation evidence, metrics, nomenclature | `docs/01`, `docs/05` |
| `../prior-art.md` | cloud research pass | commercial/academic prior art | `docs/08` |
| `../linux-vr-stack.md` | cloud research pass | runtime, engine, budget, assets | `docs/07`, `docs/06` |
| `../evidence-supplement-2026.md` | this session, via SearXNG/Europe PMC | 2026 studies, HMD-vs-screen nuance, case-count reliability | `docs/01`, `docs/05`, `docs/09` |

## This directory (final agent reports)

| File | Produced by | Topic | What was taken |
| --- | --- | --- | --- |
| `haptics-input-kinematics.md` | haptics & kinematics subagent | gloves on Linux, OpenXR haptic reality, measured force/torque, PCC vs Cosserat vs XPBD, collision strategy, scope-view rendering | force sizing table, V2 hybrid kinematics and mono `SubViewport` budget → `docs/04`; side-channel haptics → `docs/07` |
| `linux-vr-stack-final.md` | XR stack subagent | runtime, engines, performance, prior art, titles, risk table | Monado 6-DoF build flags + startup assertion, Unity exclusion, action-map gap, bandwidth-not-VRAM → `docs/07`; runtime disagreement presented as a comparison |
| `medical-3d-assets.md` | asset subagent | anatomy licences, CT datasets, Slicer/VMTK tooling, DICOM→glTF | BodyParts3D dual licence, AeroPath, ATM'22 contradiction, TCIA absence, TotalSegmentator per-task terms, Z-Anatomy → `docs/06` |
| `scratch-monado.md` | XR stack subagent | Monado build/usage notes | background for `docs/07` |
| `scratch-vmtk.md` | XR stack subagent | VMTK install/usage (centreline extraction) | background for `docs/06` |
| `scratch-za.md` | asset subagent | Z-Anatomy licence and Blender-version trap | `docs/06` |
| `raw_search_godotsurg.json` | XR stack subagent | GitHub search | **empty** (`total_count: 0`), no value |
| `raw_search_openxrmed.json` | XR stack subagent | GitHub search | reviewed, no usable hits |

## Archive (superseded drafts)

`../archive/` holds three drafts from local-model runs — vendor landscape,
tech-stack scoping, prior-art note. They are longer than the canonical reports
but contain unverified vendor claims. `docs/08` carries one clearly flagged
section derived from the landscape draft; nothing else there is cited. Note in
particular that the archive's "portable VR ORSIM" framing is wrong: it is a
laptop + sensor box + video scope, not a headset.

## Corrections applied to the project docs

| Claim | Where it landed |
| --- | --- |
| Monado Vive 6-DoF needs `XRT_BUILD_DRIVER_SURVIVE` or `..._STEAMVR_LIGHTHOUSE`; default build is 3-DoF | `docs/07` + `src/xr/tracking_sanity.gd` (startup assertion, unit-tested) |
| Unity has no Linux OpenXR build target | `docs/07` |
| Godot's default action map omits `vive_tracker` `handheld_object` | `docs/07` |
| 890M is bandwidth-bound (~128 GB/s), VRS present but eye-tracked foveation impossible | `docs/07` |
| BodyParts3D dual licence; AeroPath is the clean CT source; ATM'22 forbids redistribution; TCIA has no airway collection; TotalSegmentator licensing is per-task | `docs/06` |

## Housekeeping

- Stray `research/haptics-input-kinematics-scoping.md` (byte-identical duplicate)
  deleted, along with the now-empty `research/` directory.
- `docs/research/anatomy-sources-and-mesh-pipeline.md` (duplicate original of
  `medical-3d-assets.md`) removed; the `incoming/` copy is the one of record.

## Remaining uncertainty (carried forward honestly)

Performance figures in both stack reports are estimates from cited hardware
limits, not measurements, and need a 90 Hz spike test on the 890M. Unverified:
whether Godot's XR VRS works end-to-end on Monado; whether SteamVR advertises
`XR_HTCX_vive_tracker_interaction`; bronchoscopy-specific insertion force in
newtons (no published measurement found anywhere).
