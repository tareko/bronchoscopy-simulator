# Architecture

## Constraints that drove the design

| Constraint | Consequence |
| --- | --- |
| AMD 890M iGPU laptop as one target machine | GL Compatibility renderer, no post-processing reliance, procedural geometry, 90 Hz physics tick |
| HTC Vive on Linux (SteamVR *or* Monado) | OpenXR only, no vendor SDK |
| No headset attached most of the time | Full simulation runs headless; desktop mode drives the same model |
| CT-derived patient cases later | Anatomy is data; nothing in the engine assumes the synthetic tree |
| Educators change scoring | Rubric thresholds live in case data, not code |
| Small contributor base | Godot + GDScript, no C++ build step, no asset-store dependencies |

## Module map

```
assets/anatomy/generic_adult.json      airway graph (labels, radii, depths, mm)
        │
        ▼
src/anatomy/airway_tree.gd             graph + analytic queries
        │       ├── nearest_on_centerline(point) → {label, radial, radius, depth}
        │       ├── clamp_to_lumen(point, margin, scope_radius)
        │       ├── route_to / descendants_of / is_passable
        │       └── scored_labels()
        ├────────────────────────────┐
        ▼                            ▼
src/anatomy/airway_mesh_builder.gd   src/scope/endoscope.gd
(procedural tube mesh, inward       (lever + torque + insertion,
 normals, runtime-built)             path/body, wall contact)
        │                            │
        │                            ▼ per-frame report
        │                    src/metrics/procedure_log.gd
        │                    (event log → metrics → rubric → JSON/CSV)
        ▼                            ▼
src/main.gd  ────────────────────────┘
(desktop input, cameras, HUD, OpenXR bootstrap)
```

### Why the airway is a graph, not a mesh collider

Collision against a triangle soup needs a BVH, produces jitter at bifurcation
spurs, and has no notion of "which segment am I in" for scoring. The centreline
graph answers all three cheaply and analytically:

- **Lumen test:** distance from the point to the nearest centreline segment,
  compared with the interpolated radius.
- **Segment identity:** the label of that nearest segment (with `route_to` giving
  the anatomical path from the incisors).
- **Depth:** interpolated along the segment's cumulative depth, which is how
  bronchoscopists actually think ("that is 31 cm").

Cost: 85 segments × ~40 shaft samples = a few thousand float operations per
frame, negligible on any GPU-adjacent CPU, and it makes headless testing
trivial. The visual mesh is only ever cosmetic.

### Why the scope keeps `path` and derives `body`

`path` is the full travelled centreline: append on insertion, truncate on
withdrawal. `body` is a resampled, lumen-clamped view used for rendering and
haptics. Separating them fixed a real bug: when the tip jams against a wall,
resampling *from the body* collapsed the shaft's history to a single point,
because a blocked tip produces no new geometry. The travelled path is the
authoritative state; everything else is derived.

## Data flow per frame

1. `main.gd` reads input → `insert_mm` (mm this frame), `lever` (−1..1), `roll_deg`.
2. `Endoscope.advance()` substeps insertion (≤3 mm), clamps into the lumen, applies
   wall-slide, updates tip heading with rate limits, resamples the body.
3. Returns a report: `inserted_mm`, `contact_mm`, `blocked`, `label`, `depth_mm`,
   `tip`, `tip_dir`.
4. `ProcedureLog.track_frame(delta, report)` appends events and accumulates.
5. Rendering reads `body`/`tip`; a case script (v0.2) reads the same report to
   trigger pathology, task completion and feedback.

The per-frame report is the only coupling between the scope and everything
else. That is deliberate: cases, AI guidance, haptics and scoring all consume
the same information, so none of them can drift out of sync.

## Determinism and testing

- Physics tick is fixed at 90 Hz (`project.godot`), matching the Vive refresh.
- `advance()` takes `dt` explicitly and performs no wall-clock lookups, so tests
  drive it in a loop and get identical results.
- `tests/run_tests.gd` extends `SceneTree`, needs no addon, and exits non-zero on
  failure, which is what CI runs.
- `_autopilot_command()` in the tests is a pure-pursuit controller over the
  anatomical route. It is the regression test for navigation: if a change to the
  scope model makes RB6 unreachable, CI fails.

## OpenXR and the "no headset" problem

Godot initialises OpenXR at startup when `xr/openxr/enabled` is true and pops a
modal alert when no runtime answers. Most development happens on a laptop with
no headset (and CI has no display at all), so:

- `xr/openxr/enabled=false` in `project.godot` — the project opens and runs
  anywhere.
- `scripts/run.sh --vr` passes `--xr-mode on` for real training sessions.
- `main.gd` checks `XRServer.find_interface("OpenXR").is_initialized()` and
  builds `XROrigin3D`/`XRCamera3D`/`XRController3D` only when a runtime is live,
  logging `XR: no OpenXR interface (desktop mode)` otherwise.

## Growth points

| Extension | Where it plugs in |
| --- | --- |
| New case | `assets/cases/*.json` + a `CaseRunner` script reading the frame report |
| CT-derived anatomy | `tools/ct_pipeline` emits the same `airway_tree` schema |
| Physical scope prop | replaces the input adapter in `src/xr/`, no engine change |
| Instructor view | second `Camera3D` → `SubViewport` → window or MJPEG stream |
| Debrief PDF | `ProcedureLog.to_dict()` → HTML template → print-to-PDF |
| Position-based shaft (V2) | replace `_insert`/`_resample` internals behind the same API |

## Anti-goals

- No singleton soup: `AirwayTree`, `Endoscope` and `ProcedureLog` are plain
  `RefCounted` objects that can be instantiated in a test without a scene tree.
- No global mutable state: a session owns its tree, scope and log.
- No binary blobs in git: anatomy is text, meshes are generated.
