# Linux VR setup and performance

## Runtime for an original HTC Vive

**The project ships a pure OpenXR application; the runtime is a deployment
choice.** Two research passes disagreed about which runtime to prefer, and the
disagreement is real rather than resolvable on paper:

| Route | What one review found | What the other found |
| --- | --- | --- |
| **SteamVR for Linux** | only practical route for Lighthouse; still labelled a development release; RADV/compositor crash class, base-station power bugs | keep as a **tested fallback**, not the default |
| **Monado / Envision** | partial fallback: for Lighthouse HMDs it loads Valve's driver (`STEAMVR_LH_ENABLE=true`), so SteamVR must stay installed | **documented default**, and Vive 6DoF works if built correctly |

The Monado point matters because an earlier claim ("Monado is 3DoF on a Vive")
is a **build artefact**, not a limitation. In Monado's `CMakeLists.txt`:

- `XRT_BUILD_DRIVER_VIVE` alone → **3 DoF**
- add `XRT_BUILD_DRIVER_SURVIVE` (libsurvive, MIT) or
  `XRT_BUILD_DRIVER_STEAMVR_LIGHTHOUSE` → **6 DoF**

A silent 3DoF fallback would destroy depth judgement in a bronchoscopy trainer,
so **the app asserts 6DoF at startup** (see `src/xr/tracking_sanity.gd`) and says
so plainly instead of letting the trainee wonder why every airway feels flat.

Other Linux runtime facts worth knowing:

- **No hotplug.** Start the runtime before the app; attaching a headset later is
  not detected reliably.
- **AMD reprojection** in SteamVR benefits from `CAP_SYS_NICE`
  (`setcap cap_sys_nice+ep` on the binary) to avoid frame-pacing stalls.
- **Unity is excluded categorically**, not by taste: Unity's own OpenXR plugin
  lists Win64 / Android / UWP build targets and no Linux target.

### Checklist### Checklist

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

Godot's default OpenXR action map has two gaps:

1. it does **not** bind `/interaction_profiles/htc/vive_controller`;
2. it deliberately omits the `/user/vive_tracker_htcx/role/handheld_object` path
   (the engine source carries a "getting errors on this one" note), which is
   exactly the role a Vive-Tracker scope prop wants.

So a props-based build needs a custom action map (or the `chest` role as a
workaround) **and a pinned Godot version**, because the default map can change
between releases. Before hardware testing, open
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
- **No eye-tracked foveation on the original Vive** — there is no eye tracking.
  However AMD's RADV on this machine exposes `VK_KHR_fragment_shading_rate` and
  `VK_EXT_direct_mode_display` (verified on Mesa 26.0.8), so *fixed* VRS is
  possible in principle; whether Godot's XR VRS survives Monado end-to-end is
  untested. Treat it as an experiment, not a plan.
- **The 890M constraint is bandwidth, not VRAM** (~128 GB/s shared, 61 GB
  unified): texture *memory* is nearly free, fill rate is not. Reducing overdraw
  and render scale buys more than compressing textures.
- **No shadows, no post-processing** in the airway scene; lighting is a single
  directional light plus ambient.

## Performance budget (AMD Radeon 890M, 90 Hz)

| Quantity | Budget |
| --- | --- |
| Frame time | 11.11 ms (90 Hz) |
| Vive default resolution | 1.4× → 1512 × 1680 per eye ≈ **457 Mpx/s** |
| Render scale | 0.7–0.9 (start at 0.8 and measure) |
| Memory bandwidth | ~128 GB/s shared → ~1.4 GB/frame at 90 Hz; **bandwidth is the limit, not VRAM** |
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
