# Linux VR setup and performance

## Runtime for an original HTC Vive

**Use SteamVR for Linux.** It is still labelled a development release, but it is
the only practical runtime for Lighthouse-tracked headsets, and the tracker is
active (bugs and fixes landing in late 2026). Known rough edges: base-station
power management and a RADV/compositor crash class — both documented in the
upstream tracker.

**Monado/Envision is a partial fallback only.** For Lighthouse HMDs it loads
Valve's proprietary driver (`STEAMVR_LH_ENABLE=true`), so SteamVR must remain
installed anyway. Treat Monado as a debugging tool, not a second supported
platform.

**WiVRn and ALVR are standalone-headset streaming only** — not options for a
Vive with base stations.

### Checklist

1. Install Steam and SteamVR; run SteamVR once on the desktop to confirm tracking.
2. Verify the headset is on a USB 3 port; base stations on USB power, channels A/b.
3. `vulkaninfo | grep deviceName` — RADV should list the AMD 890M.
4. Launch the simulator with VR enabled:

   ```bash
   ./scripts/run.sh --vr
   ```

5. If the engine reports `OpenXR: no runtime`, SteamVR's
   `steamvr.vrsettings` may need `"activateMultipleDrivers": true`, or the
   runtime is simply not running yet.

## Why OpenXR is off by default

Godot initialises OpenXR at startup when the project setting is enabled and
shows a modal alert — *"OpenXR was requested but failed to start"* — whenever no
runtime answers. That happens on every launch without a headset, and always in
CI. So:

- `xr/openxr/enabled=false` in `project.godot`;
- `scripts/run.sh --vr` passes `--xr-mode on` for hardware sessions;
- `main.gd` logs `XR: no OpenXR interface (desktop mode)` and continues with the
  keyboard.

To work in the editor with the headset attached, tick *Project Settings → XR →
OpenXR → Enabled*, and untick it before committing.

## Action map: Vive controllers need an explicit binding

Godot's default OpenXR action map does **not** bind
`/interaction_profiles/htc/vive_controller`. Before hardware testing, open
`src/xr/openxr_action_map.tres` (create it once from the editor's OpenXR panel)
and add, for each action:

| Action | Vive binding |
| --- | --- |
| `scope_insert` | grip (bool) + pose |
| `scope_deflect` | trackpad y |
| `scope_roll` | trackpad x |
| `scope_suction` | trigger (float) |
| `tool_deploy` | trigger click |
| `tool_switch` | menu button |

Do not assume the generic controller profile maps the Vive trackpad — it does
not, and the failure mode is "VR works but nothing responds".

## Rendering configuration

- **Renderer:** Godot **Mobile** (Vulkan). Godot's own documentation recommends it
  for desktop VR; `gl_compatibility` is the fallback for drivers without working
  Vulkan (both are one project setting apart).
- **No foveated rendering on Vive.** There is no eye tracking and no runtime
  extension, so per-eye variable rate shading is unavailable. Budget for uniform
  cost.
- **No shadows, no post-processing** in the airway scene; lighting is a single
  directional light plus ambient.

## Performance budget (AMD Radeon 890M, 90 Hz)

| Quantity | Budget |
| --- | --- |
| Frame time | 11.11 ms (90 Hz) |
| Vive default resolution | 1.4× → 1512 × 1680 per eye ≈ **457 Mpx/s** |
| Render scale | 0.7–0.9 (start at 0.8 and measure) |
| Draw calls | ≤ 300 |
| Triangles | 500–800k |
| Materials | 1–3 per scene |
| Textures | one atlas, ≤ 2k², no dynamic lights per lesion |

The airway mesh is a single `ArrayMesh` (85 segments × 14 radial × 3 slices ≈
8k triangles) so draw calls stay near one. Everything expensive (fluid, blood,
mucus) must be a shader or a small fixed pool of particles.

Measure with Godot's profiler (`debug → visible shader time`), and verify with
`vkcube` under SteamVR that the compositor itself is not the bottleneck.

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| "OpenXR was requested but failed to start" | no runtime / headset off | run with `--vr` only when SteamVR is running |
| VR mirror is blurry, headset fine | mirror window at 1× scale | expected; not a rendering bug |
| Tracking drifts | reflective surfaces, base station vibration | mount rigidly, cover mirrors |
| 45 fps with reprojection | over budget | lower render scale first, then materials |
| Controllers present but silent | action map missing Vive bindings | add `/interaction_profiles/htc/vive_controller` |
| Crash in `vrcompositor` | known RADV issue | try `RADV_DEBUG=nocompute`, or Monado/Envision as a diagnostic |

## Desktop mode (the everyday path)

Most development and all CI runs happen without a headset:

```bash
./scripts/run.sh                      # keyboard control, preview + endoscopic camera
godot --headless --path . --script tests/run_tests.gd
```

If desktop mode fails, the bug is in the engine core, not in VR — which is why
the architecture keeps VR input as a thin adapter.
