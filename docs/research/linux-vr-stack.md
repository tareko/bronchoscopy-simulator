# Linux + OpenXR VR stack, assets and frameworks for a bronchoscopy simulator

**Research date:** 2026-11-15 (all "current" statements are as of this date).
**Target:** original HTC Vive (wand controllers, Lighthouse 1.0), Ubuntu 26.04, Godot 4.7 + OpenXR,
AMD Radeon 890M iGPU (RDNA 3.5) on a Framework 13, plus a separate desktop for real use.
**Audience:** pulmonary / critical-care fellows and residents (trainees), plus open-source contributors.

**How to read this document.** Claims that come from a source are linked inline. Numbers I computed
or estimated are marked **[estimate]** with the method shown. Things I could not verify are marked
**[unverified]** and collected in §10. Nothing here is a substitute for measuring on the actual
machine: the hardware, driver and runtime situation on Linux changes monthly, and several of the
sources below are community-maintained wikis rather than vendor documentation.

---

## 0. Bottom line

| Question | Recommendation | Confidence |
| --- | --- | --- |
| Runtime | **SteamVR for Linux as the primary runtime**; Monado + Envision documented as fallback. WiVRn/ALVR are irrelevant to a tethered Vive. | High for the choice, medium for long-term stability |
| Engine | **Godot 4.7.x** with the **Mobile renderer**, `godot-xr-tools`, OpenXR | High |
| Perf target | 90 Hz / 11.11 ms; render scale **0.7–0.9×** of SteamVR's recommended target on the 890M; **no foveated rendering** on Vive | High on the budget, medium on the exact scale |
| Anatomy | Keep the synthetic graph for v1; add a **TotalSegmentator + nnU-Net + 3D Slicer** CT pipeline; **do not ship ATM'22-derived meshes** | High |
| Licence hygiene | MIT code + **separate CC BY-SA asset pack** for BodyParts3D derivatives; avoid CC BY-NC (AnatomyStandard, some TotalSegmentator tasks) | High |
| Haptics v1 | Wand rumble only; design the code so a **DIY scope prop** (Vive Tracker 3.0 + ESP32 + 1-DOF force feedback) can be added without touching case logic | Medium |
| Reuse | `godot-xr-tools` (MIT), Slicer + SlicerIGT (BSD-style) for the CT pipeline, SOFA/BeamAdapter (LGPL-2.1) **offline only**. **iMSTK is sunset — do not depend on it.** | High |

---

## 1. VR runtime on Linux, 2025–2026, for an original HTC Vive

### 1.1 What the hardware needs

The original Vive is a 2016 headset: 2160×1200 total (1080×1200 per eye), 90 Hz, ~110° nominal FOV,
**Lighthouse 1.0** tracking with two base stations, HDMI 1.4 / DisplayPort 1.2 + USB 3.0 through a link
box, and "wand" controllers with trackpad, trigger, grip and menu buttons
([Wikipedia: HTC Vive](https://en.wikipedia.org/wiki/HTC_Vive)). Two hardware facts matter for the
software stack:

* 1.0 base stations and 2.0 base stations are **not interchangeable**, and 2.0 controllers are not
  backwards compatible with the original Vive ([Wikipedia](https://en.wikipedia.org/wiki/HTC_Vive)).
  Spares are a real risk for a 10-year-old device.
* The wands have **no finger tracking and no force feedback** — only a rumble actuator. Any
  "palpation" or "resistance" in the simulation has to be faked visually/audibly at first (see §5).

### 1.2 SteamVR for Linux

SteamVR is the only runtime that supports the Vive "out of the box" in the sense a trainee would
expect. Valve's own README still describes the Linux build as a **development release** with
"limited hardware support", requiring a modern distro (Ubuntu ≥ 20 or Arch), up-to-date Vulkan
drivers, and — on AMD — Mesa from the kisak PPA
([SteamVR-for-Linux README](https://github.com/ValveSoftware/SteamVR-for-Linux)).

It is not abandoned: the issue tracker shows Linux-specific reports filed within days of this
report, referencing **SteamVR 2.19.3** and new Linux-based Valve hardware
([issue #1065, 2026-11-14](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/1065);
[issue #1067, RADV compositor crash, 2026-11-14](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/1067)).
SteamVR also provides an OpenXR runtime on Linux, so an OpenXR app can target it directly
([ArchWiki: Virtual reality](https://wiki.archlinux.org/title/Virtual_reality)).

Known-bug categories that affect this project, all still open at the time of writing:

| Issue | What it means for us | Link |
| --- | --- | --- |
| Base station power management never implemented (open since 2020) | Base stations will not sleep/wake from software; power them by hand | [#320](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/320) |
| Room Setup is buggy | Use "Quick Calibration" or `vrcmd --resetroomsetup` instead of the wizard | [vronlinux SteamVR page](https://vronlinux.org/docs/steamvr/) |
| RADV-specific compositor crash (Room View during load) | Avoid the dashboard/Room View during a case; test on Mesa 25.x | [#1067](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/1067) |
| Vulkan transfer ring-buffer assert | Mitigate by pinning a known-good SteamVR build | [#1006](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/1006) |
| Intel Arc flicker (not us, but shows driver-specific fragility) | Keep a per-GPU note in the setup docs | [#932](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/932) |

A community-maintained wiki is blunter than Valve: "SteamVR runs natively on Linux. Unfortunately
the Linux version is riddled with bugs, missing features and bad performance"
([vronlinux.org/docs/steamvr](https://vronlinux.org/docs/steamvr/)). Treat that as the honest
baseline expectation for a trainee-facing deployment, not as a reason to avoid SteamVR — there is no
alternative that tracks a Vive without it (see §1.4).

### 1.3 Monado (+ Envision, xrizer)

Monado is the cross-platform open-source OpenXR runtime, explicitly targeting Linux
([monado.dev](https://monado.dev/)), licensed **BSL-1.0**; the Arch AUR package is at **25.1.0**
([AUR: monado](https://aur.archlinux.org/packages/monado)).

For a Vive setup, the practical details are:

* **Monado does not track Lighthouse devices itself by default** — it uses Valve's SteamVR Lighthouse
  driver, enabled with `STEAMVR_LH_ENABLE=true`; SteamVR must be *installed* (not running). Envision
  sets this for you ([vronlinux Monado page](https://vronlinux.org/docs/fossvr/monado/)).
  This is the single most important nuance: **Monado is not a full escape from SteamVR on a Vive.**
  It replaces SteamVR's compositor/session management, not the Lighthouse driver.
* Monado has its own `survive` driver (libsurvive) used for some Lighthouse-tracked accessories — the
  ArchWiki table lists DIY "Lucid VR gloves" and "Mercury hand tracking" as working "survive driver
  only" ([ArchWiki](https://wiki.archlinux.org/title/Virtual_reality)). Its maturity for *HMD*
  tracking on the original Vive is **[unverified]**; I would not ship on it.
* No hotplug: all trackers/controllers must be switched on before starting Monado
  ([vronlinux](https://vronlinux.org/docs/fossvr/monado/)).
* Steam games need `PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1 %command%`; Proton titles need
  Proton 9+ and **xrizer** or OpenComposite, because Monado is OpenXR-only
  ([vronlinux](https://vronlinux.org/docs/fossvr/monado/)). xrizer is GPL-3.0-or-later
  ([AUR: xrizer](https://aur.archlinux.org/packages/xrizer)).
* AMD reprojection needs `CAP_SYS_NICE` on `monado-service` (Envision and the AUR package do this)
  ([vronlinux](https://vronlinux.org/docs/fossvr/monado/)).

**Envision** is the GUI orchestrator that installs/configures Monado + xrizer/OpenComposite, sets
`STEAMVR_LH_ENABLE`, and can run Quick Calibration. It lives at
[gitlab.com/gabmus/envision](https://gitlab.com/gabmus/envision) and was active on 2026-11-14
(personal check of the GitLab API). Use it rather than hand-assembling Monado.

### 1.4 WiVRn and ALVR: not applicable to a tethered Vive

Both are **streaming** solutions for standalone Android headsets:

* WiVRn (GPL-3.0) streams from a Linux PC to Quest/Pico/Focus-class headsets; its own support table
  says "Non-Android VR ✖" ([WiVRn README](https://github.com/WiVRn/WiVRn)). ArchWiki notes an
  "experimental PC-to-PC stream client" that "might work" with Monado-supported HMDs
  ([ArchWiki](https://wiki.archlinux.org/title/Virtual_reality)) — experimental, not a plan.
* ALVR (MIT, ~8.1k stars, very active) is a SteamVR driver that streams to standalone headsets
  ([ALVR](https://github.com/alvr-org/ALVR)); it does nothing for a Vive.

Keep both on the roadmap only if the project later adds a Quest/Pico target. For v1 they are noise.

### 1.5 Recommended route and fallbacks

1. **Primary:** SteamVR for Linux (OpenXR runtime), original Vive, Ubuntu 26.04 on an **X11 session**
   if you hit compositor issues (Wayland-related abort reports exist:
   [#1040](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/1040)). Pin the SteamVR version
   in the lab image; do not auto-update mid-course.
2. **Fallback A:** Monado 25.x via Envision, `STEAMVR_LH_ENABLE=true`, xrizer for any OpenVR content.
   Same physical hardware, different compositor. Good for isolating "SteamVR compositor regression"
   from "our app is slow".
3. **Fallback B (no headset at all):** desktop mode. The repo already has this and it is the reason
   the project is testable in CI — keep it a first-class path, not a debug toy.
4. **Strategic note (not a dependency):** Valve's Steam Frame is a Linux/SteamOS-based headset and SteamVR's Linux
   tracker references "Steam Frame" streaming and foveated streaming
   ([#946](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/946),
   [#1047](https://github.com/ValveSoftware/SteamVR-for-Linux/issues/1047)), and Godot 4.7 claims
   day-one production support for Steam Frame
   ([Godot 4.7 release notes](https://godotengine.org/releases/4.7/)). Linux VR is getting *more*
   support from Valve, not less. **[unverified]** — I did not verify Steam Frame hardware details.

---

## 2. Engines for Linux + OpenXR

### 2.1 Godot 4.7 (current: 4.7.2, released 2026-08-18)

* **MIT**, single editor binary that runs natively on Linux
  ([Godot 4.7.2 release](https://github.com/godotengine/godot/releases/tag/4.7.2-stable)).
* OpenXR is a **core** interface in Godot 4, tightly integrated with the Vulkan renderer
  ([Setting up XR](https://docs.godotengine.org/en/stable/tutorials/xr/setting_up_xr.html)).
* Godot's own XR documentation now says: **"The current recommendation is to use the Mobile renderer
  for any desktop VR project"** — Forward+ "isn't well optimized for XR right now"
  ([Setting up XR](https://docs.godotengine.org/en/stable/tutorials/xr/setting_up_xr.html)).
  This is exactly the 890M's use case.
* 4.7 XR changes that matter here ([4.7 release notes](https://godotengine.org/releases/4.7/)):
  - "Vulkan subsampled images" that "dramatically improve[] performance of foveated rendering in the
    Vulkan Mobile render" and reduce memory bandwidth;
  - composition-layer improvements (HUD-style layers locked to the camera);
  - **simplified default action maps** now built around the **generic controller profile** plus Touch,
    Pico 4 and hand-interaction profiles.
* `godot-xr-tools` (MIT, 749 stars, active 2026-10) supplies locomotion, grab/throw, UI pointer,
  hands and comfort features; master targets Godot 4.2+, the 4.5.x release line needs Godot ≥ 4.4
  ([godot-xr-tools](https://github.com/GodotVR/godot-xr-tools)).
* `godot_openxr_vendors` (MIT, 198 stars, active 2026-11) is only needed for vendor extensions
  (Quest/Pico/Meta), **not** for a Vive ([repo](https://github.com/GodotVR/godot_openxr_vendors)).

**Action item found in this repo:** `openxr_action_map.tres` currently contains only
`/interaction_profiles/khr/generic_controller`, `.../oculus/touch_controller`,
`.../bytedance/pico4_controller` and `.../ext/hand_interaction_ext`. There is **no
`/interaction_profiles/htc/vive_controller` entry**. Add it with trigger / trackpad / grip / menu
bindings and test on the real wands; do not assume the generic profile maps the Vive trackpad the way
you expect.

### 2.2 Unity 6 + OpenXR

* **Linux is not a supported OpenXR platform.** Unity's OpenXR plugin 1.15 (linked against
  OpenXR-SDK 1.1.45) lists supported runtimes as Windows 64-bit/DX11 (including "all other conformant
  runtimes, e.g. SteamVR"), Android (Quest, Magic Leap 2), HoloLens 2/UWP — **no Linux entry**
  ([Unity OpenXR manual](https://docs.unity3d.com/Packages/com.unity.xr.openxr@1.15/manual/index.html)).
  A Linux standalone build with OpenXR would be unofficial/unsupported.
* **Licensing (2026):** the Runtime Fee was cancelled on 2024-09-12 and Unity 6 (released
  2024-10-17) raised the Personal threshold to $200k; Pro is $2,310/yr/seat; Enterprise is required
  above $25M ([Unity pricing changes](https://unity.com/products/pricing-updates),
  [Unity pricing](https://unity.com/pricing)).
  Two traps for a *medical* simulator: Unity Personal is described as being "for gaming and
  entertainment applications only", and **Unity Industry** is required for non-game applications when
  the company's total finances exceed $1M ([Unity pricing](https://unity.com/pricing)). If this project
  is ever commercialised by a company above that line, the engine licence becomes a procurement
  problem. For a purely academic/non-commercial open-source project, Personal is free — but the code
  itself is not open source, which conflicts with the repo's MIT/open ethos.
* Verdict: **do not switch to Unity for a Linux-first product in 2026.**

### 2.3 Bevy (Rust)

* `bevy_mod_openxr` 0.6.0 (published 2026-06-20, ~22k downloads) and the underlying `openxr`
  (openxrs) crate 0.22.0 (2026-09-17, ~957k downloads) are alive
  ([crates.io: bevy_mod_openxr](https://crates.io/crates/bevy_mod_openxr),
  [crates.io: openxr](https://crates.io/crates/openxr)). The older `bevy_oxr` is stale (2024).
* No editor, no XR interaction toolkit equivalent, small VR community, and a medical-training
  contributor (a fellow with a weekend) cannot be productive quickly. Verdict: **no** for v1; a fine
  choice for a research prototype by an experienced Rust developer.

### 2.4 StereoKit (C#/.NET, MIT)

* MIT, ~1.1k stars, active (2026-11), OpenXR-based, and its docs explicitly support Linux via the
  .NET SDK and any desktop OpenXR runtime (SteamVR, Monado)
  ([StereoKit getting started](https://stereokit.net/Pages/Guides/Getting-Started.html),
  [repo](https://github.com/StereoKit/StereoKit)).
* Genuinely pleasant for UI-heavy VR and much lighter than Unity. Weaknesses for us: C# toolchain on
  Linux, a smaller asset/anatomy ecosystem, no equivalent of godot-xr-tools' locomotion/comfort
  toolkit, and the project would need to re-implement the current GDScript core.
* Verdict: **credible plan B** if Godot's XR layer becomes a blocker; not worth a rewrite today.

### 2.5 Unreal Engine 5 on Linux

* Epic supports Linux as a **target** with a documented toolchain: Ubuntu 22.04 / Rocky 8, clang
  20.1.8 for 5.7–5.8, Vulkan RADV ≥ 24.2.8 (25.0.0+ recommended) or NVIDIA 570+, and a recommended
  dev GPU of "GeForce 2080" class with 8 GB+
  ([Linux development requirements, UE 5.9 docs](https://dev.epicgames.com/documentation/en-us/unreal-engine/linux-development-requirements-for-unreal-engine)).
  The workflow is source/toolchain based; Epic does not hand you a one-click Linux editor install.
* Epic's OpenXR documentation page is present but its platform matrix was not machine-readable at the
  time of writing; **I could not find an Epic statement that OpenXR VR is supported on Linux**
  ([OpenXR in Unreal Engine](https://dev.epicgames.com/documentation/en-us/unreal-engine/openxr-in-unreal-engine))
  — **[unverified]**, and community reports are mixed. Treat VR-on-Linux in UE5 as unsupported.
* Weigh: multi-GB editor, shader compile times, 8 GB VRAM-class expectations vs. an 890M iGPU that
  shares system RAM. Verdict: **wrong tool** for a 90 Hz iGPU target and a fellow-maintained codebase.

### 2.6 WebXR / three.js on a Linux browser

* caniuse lists WebXR as supported in desktop Chrome/Safari but in Firefox only behind
  `dom.vr.webxr.enabled` ([caniuse: WebXR](https://caniuse.com/webxr)).
* There is no documented, supported path from a Linux OpenXR runtime (SteamVR or Monado) into a Linux
  desktop browser's WebXR device layer; the browser stacks historically depended on platform XR
  services that Linux does not provide. **[unverified]** — I found no primary source claiming a working
  Chrome-on-Linux + SteamVR WebXR path, and I would not bet a clinical training product on it.
* Even if it worked, you would give up: native 90 Hz frame pacing, multiview, controller haptics via
  OpenXR actions, and offline operation on lab machines. Verdict: **no**.

### 2.7 Recommendation and contributor-onboarding cost

**Godot 4.7 + Mobile renderer + OpenXR + godot-xr-tools.** Justification, in order of weight:

1. It is the only mainstream engine where **Linux + OpenXR + a permissively licensed engine** are all
   first-class in 2026 (Godot 4.7 even claims day-one Steam Frame/Android XR support
   ([4.7 notes](https://godotengine.org/releases/4.7/))).
2. Godot explicitly recommends the **Mobile renderer** for desktop VR — the correct default for an
   890M iGPU.
3. The repo is already there, with a working headless test suite; switching engines costs more than
   any benefit.
4. Onboarding: a fellow or resident who knows Python can read GDScript in an afternoon; the editor is a
   single editor download; no licence server, no seat cost, no per-platform build machine. That is
   the lowest onboarding cost of any option here.

Risks: Godot's XR API still moves between minor versions (the 4.7 action-map simplification is exactly
the kind of change that breaks a checked-in `.tres`), and the XR team is small. Mitigation: pin the
engine minor version, keep the XR layer thin and behind interfaces (the current `src/scope/` split is
the right shape), and keep desktop mode working so CI never depends on a headset.

---

## 3. Performance budget: 90 Hz on a Radeon 890M

### 3.1 The numbers we are working with

| Quantity | Value | Source |
| --- | --- | --- |
| Frame budget at 90 Hz | **11.11 ms** | Valve, [Advanced VR Rendering, GDC 2015](http://alex.vlachos.com/graphics/Alex_Vlachos_Advanced_VR_Rendering_GDC2015.pdf) |
| Vive panel | 1080×1200 per eye, 2160×1200 total | [Wikipedia](https://en.wikipedia.org/wiki/HTC_Vive) |
| SteamVR default render target | **1512×1680 per eye** (1.4× linear), 2.54 Mpx/eye, **457 Mpx/s** at 90 Hz | Valve GDC 2015 deck, Vive-spec and pixel-throughput slides |
| Valve's own guidance | "On slower GPUs, scale the recommended render target scalar down" | same deck, "Scale Render Target Resolution" slide |
| 890M compute units / clock | **16 CUs, 2900 MHz** | [AMD Ryzen AI 9 HX 370 specs](https://www.amd.com/en/products/processors/laptop/ryzen/ai-300-series/amd-ryzen-ai-9-hx-370.html) |
| Memory | 2 channels, LPDDR5X-8000 or DDR5-5600, **shared with CPU** | same AMD page |
| Peak memory bandwidth (LPDDR5X-8000, 2×64-bit) | **≈128 GB/s theoretical** **[estimate]** | 8000 MT/s × 16 B |
| Peak FP32 (1024 SP × 2 FLOP × 2.9 GHz) | **≈5.9 TFLOPS** **[estimate]** | derived from AMD CU/clock |
| Default TDP | 28 W (configurable) | AMD page |

The 890M is a competent 1080p-class iGPU, but VR at 1.4× supersampling is roughly **4× the pixel
throughput of 1080p60** (457 vs 124 Mpx/s in Valve's table). Expect to run **below** SteamVR's
recommended render target, not above it.

### 3.2 Proposed budget (v1, procedural tubes, few textures)

Treat these as engineering targets to validate on-device, not measurements. **[estimate]**, derived
from the pixel/bandwidth arithmetic above and Godot's Mobile-renderer guidance.

| Resource | Target | Rationale |
| --- | --- | --- |
| Render scale | **0.7–0.9×** of SteamVR's recommended target (≈1060×1180 to 1360×1510 per eye) | Cuts shaded pixels 20–50% vs. 1.4×; the compositor upscales |
| Frame time (GPU) | ≤ **9 ms**, leaving ~2 ms for compositor/reprojection | 11.11 ms hard cap |
| Draw calls | **≤ 300/frame**, ideally ≤150 | Per-object state changes dominate on small iGPUs; Godot's batching helps only same-material meshes |
| Triangles visible | **≤ 500k–800k/frame** | Tube geometry is cheap per triangle; shading and bandwidth bite first |
| Tube tessellation | **8–12 sides per ring**, segment length ~5–10 mm | 85 segments × 12 sides × ~10 rings ≈ 10k tris for the whole tree |
| Materials | **1–3 total** for the airway, 1 for instruments | Every extra material = extra draw calls, no instancing |
| Textures | **≤ 100–150 MB VRAM total**, ≤ 1k resolution for surface detail | Shared with CPU on an iGPU; keep the "few textures" plan |
| Lights | 1 directional, **no realtime shadows** (or a single static baked shadow if needed) | Shadow maps + lights are the classic XR frame killer |
| Post-processing | **none** — no SSAO, SSR, SSIL, volumetric fog, DOF, glow | Godot Mobile renderer supports some of these; skip them |
| MSAA | **2× max**, or off with render-scale up | Community guidance for Linux VR: prefer compositor supersampling over AA ([vronlinux performance](https://vronlinux.org/docs/performance/)) |
| Stereo | Single-pass multiview | Standard on Vulkan; halves CPU submission |

### 3.3 Foveated rendering: do not count on it

The original Vive has **no eye tracking**, so only *fixed* foveation is even conceptually possible, and
that requires a runtime extension. Godot exposes "Foveation Level" only "provided this feature is
supported by the hardware used", with dynamic foveation tied to GPU load
([OpenXR settings](https://docs.godotengine.org/en/stable/tutorials/xr/openxr_settings.html)). I found
no evidence that SteamVR for Linux implements a foveation extension for a Vive; Godot's 4.7
"subsampled images" optimisation targets headsets/runtimes that *do*
([4.7 notes](https://godotengine.org/releases/4.7/)). **Plan the budget assuming zero foveation
gains.** If you later target Quest/Pico, the same code benefits for free.

### 3.4 What to avoid specifically in this codebase

1. **Per-frame whole-tree mesh rebuilds.** The procedural builder is fine at load; regenerating the
   airway mesh every frame will blow the CPU budget. Rebuild only on case change.
2. **One material per segment.** 85 segments × unique material = 85 draw calls and no batching. Use a
   single material plus vertex colours/UVs, or a small texture atlas.
3. **Transparent airway walls.** The endoluminal view is naturally opaque; transparency costs sorting
   and overdraw. Render the interior with reversed normals / two-sided where needed.
4. **Realtime shadows from the scope light.** A moving point light with shadows in a tube is the worst
   case for an iGPU. Fake it with vertex AO or a baked gradient.
5. **High-frequency normal maps on the mucosa.** Anisotropic filtering helps at low pixel density
   (Valve recommends forcing 8× on colour/normal maps — deck's anisotropic-filtering slide), but the bandwidth cost on
   shared LPDDR5X is real. Prefer geometry + vertex colour detail.
6. **TAA.** Ghosting on a moving endoscope tip is unacceptable clinically; and Godot's XR path
   prefers MSAA.
7. **Unbounded draw distance.** A bronchial tree is a closed space: use occlusion/portal culling and
   only build the sub-tree within N generations of the current segment.

### 3.5 How to validate

* Use SteamVR's own frame timing overlay / Advanced Frame Timing to separate app time from compositor
  time; if the compositor is the problem, no amount of app optimisation helps.
* On AMD, set the GPU power profile to **VR** (`pp_power_profile_mode`) so the iGPU does not
  downclock between frames — this is called out as a real stutter source for VR timewarp
  ([vronlinux performance](https://vronlinux.org/docs/performance/)).
* Test at 1.4× **and** 0.7× render scale and record both; publish the numbers in `docs/07` so future
  contributors can tell a regression from a hardware difference.
* Do not benchmark inside the Godot editor — export a release build.

---

## 4. Open anatomy assets, licences, and a DICOM → labelled airway graph pipeline

### 4.1 Asset landscape

| Source | Licence | Airways? | Usable in an MIT open-source repo? | Notes |
| --- | --- | --- | --- | --- |
| **BodyParts3D / Anatomography** (DBCLS Japan) | **CC BY-SA 2.1 JP** ([licence section](https://lifesciencedb.jp/bp3d/info/)) | FMA-mapped adult anatomy; respiratory tree present as FMA concepts **[unverified for detail/resolution]** | **Yes, with conditions** | Share-alike: derived meshes must stay CC BY-SA → cannot be relicensed MIT. Ship as a separate asset pack. Paper: [Mitsuhashi et al., NAR 2009](https://doi.org/10.1093/nar/gkn613) |
| **AnatomyStandard** | **CC BY-NC 4.0** — "All our original images are licensed under the Creative Commons Attribution-NonCommercial 4.0 International License" ([site](https://www.anatomystandard.com/)) | Illustrations, not meshes | **No** | NC blocks commercial/clinical use and fails the OSI open-definition test. Fine for a slide, not for shipped geometry |
| **NIH 3D** (3d.nih.gov) | **Per-entry**: "many entries … fall under public domain or Creative Commons licenses (e.g., CC-BY), others may have more restrictive terms" ([Terms §4.3](https://3d.nih.gov/terms)) | Varies | **Sometimes** | Must check each model's licence; keep a per-asset licence manifest |
| **Zygote** | Commercial, paid ([zygote.com](https://www.zygote.com/)) | Yes (high quality) | **No** (unless you buy a redistribution licence) | Budget/procurement decision; incompatible with MIT redistribution |
| **LIDC-IDRI** (TCIA) | **CC BY 3.0** + TCIA data usage policy/attribution ([TCIA collection page](https://www.cancerimagingarchive.net/collection/lidc-idri/)) | Thoracic CT, airways visible | **Yes, with attribution** | 1018 cases; nodule-focused, not airway-labelled |
| **ATM'22** (MICCAI airway challenge) | **"The redistribution of this dataset is strictly prohibited"** ([atm22.grand-challenge.org](https://atm22.grand-challenge.org/)) | Yes — dedicated airway segmentation | **No** | Registration + signed data agreement. Can be used locally for training/validation. Successor: [ATM'26](https://atm26.grand-challenge.org/) |
| **EXACT'09** | Historically public challenge data | Yes (airway segmentation) | **Unknown** | Host `image.diku.dk` **timed out** on 2026-11-15; treat as stale/unavailable. **[unverified]** |
| **AVIEW** | — | — | — | **Could not verify that this dataset exists** under that name; queries to Europe PMC, Zenodo and the GitHub API returned nothing matching an airway CT dataset called AVIEW. Ask the requester for the citation, or substitute LIDC-IDRI/ATM'22. **[unverified]** |

**Content warning about BodyParts3D:** the BodyParts3D/Anatomography site itself says "There could be
many ERRORS to be used as ANATOMICAL EDUCATION" ([bp3d info](https://lifesciencedb.jp/bp3d/info/)).
For a bronchoscopy trainer, the *branching topology and segment nomenclature* must come from an
anatomical reference, not from a mesh.

### 4.2 Segmentation tooling (all open source)

| Tool | Licence | Role |
| --- | --- | --- |
| **3D Slicer** | BSD-style "Slicer Licence" ([License.txt](https://github.com/Slicer/Slicer/blob/main/License.txt)) | Viewing, manual correction, DICOM handling, extension host |
| **TotalSegmentator** | **Apache-2.0** tasks; airway classes in `lung_vessels` (`lung_airways`, `lung_airways_wall`) and `lung_vessels_LEGACY` (`lung_trachea_bronchia`) ([README](https://github.com/wasserth/TotalSegmentator)) | Fast out-of-the-box airway mask; note some *other* tasks are licence-gated, these two are not |
| **nnU-Net** | Apache-2.0 ([repo](https://github.com/MIC-DKFZ/nnUNet)) | Fine-tune on ATM'22/LIDC-IDRI for better peripheral airways |
| **dcm2niix** | Open source (GitHub reports NOASSERTION; see repo) ([repo](https://github.com/rordenlab/dcm2niix)) | DICOM → NIfTI |
| **scikit-image** | BSD-3 | `skeletonize_3d` / `medial_axis` for centre-lines ([docs](https://scikit-image.org/docs/stable/api/skimage.morphology.html)) |
| **VMTK** | BSD-style ([vmtk.org](https://www.vmtk.org/)) | Centre-line extraction with radius (vascular tooling, works on airway masks) |
| **SlicerIGT** | **BSD-3-Clause**, active 2026-09 ([repo](https://github.com/SlicerIGT/SlicerIGT)) | Only needed if you later do tracker-based IGT features |

### 4.3 The pipeline (DICOM → labelled airway graph)

```
DICOM series
  │  dcm2niix (NIfTI) or Slicer DICOM import
  ▼
NIfTI volume (0.6–1.0 mm iso)
  │  TotalSegmentator --task lung_vessels   (lung_airways)   [Apache-2.0]
  │  or a fine-tuned nnU-Net (ATM'22/LIDC-IDRI)              [Apache-2.0]
  ▼
binary airway mask
  │  Slicer: manual editing (fill leaks into lung, cut trachea at glottis,
  │          remove oesophagus/stomach leakage), keep-largest-component
  ▼
clean mask
  │  skeletonize_3d (scikit-image) or VMTK centre-lines
  ▼
skeleton voxels + radius from distance transform
  │  graph build (networkx): nodes = branch points/endpoints,
  │  edges = centre-line polylines with per-node radius; prune spurs < 5 mm
  ▼
topological graph  ──►  semi-automatic Boyden labelling
  │                     (rules: lobe from CT lung-lobe mask; depth from carina;
  │                      laterality from x; then human review of RB1–RB10 / LB1–LB10)
  ▼
labelled JSON (same schema as assets/anatomy/generic_adult.json)
  │  Godot: airway_mesh_builder.gd
  ▼
runtime tube mesh (8–12 sides), collision capsules per edge
```

Engineering requirements that are easy to forget:

1. **Depth from incisors** must be assigned anatomically (the clinical convention), not from the mesh
   path length. Validate against published mean depths (e.g. carina ~25–27 cm in an adult) and fail the
   build if the generated tree is off by more than a few cm.
2. **Radius sanity**: a segment with radius < 2 mm is not navigable by a 5.5–6.0 mm scope; mark it as
   terminal in the graph rather than letting the physics jam.
3. **Reproducibility**: pin TotalSegmentator/nnU-Net versions and record the model hash in the JSON
   metadata. A segmentation model update will change the anatomy.
4. **De-identification**: DICOM headers must be scrubbed before any file lands in the repo; for TCIA
   data, follow the TCIA data usage policy and cite the DOI
   ([TCIA LIDC-IDRI](https://www.cancerimagingarchive.net/collection/lidc-idri/)).
5. **Licence hygiene**: keep `assets/anatomy/` MIT/CC0 (synthetic, current state) and put any
   BodyParts3D-derived or LIDC-IDRI-derived geometry in `assets/external/` with its own licence file and
   attribution. Do **not** ship ATM'22-derived meshes at all — redistribution is prohibited.

**Recommendation.** v1 keeps the synthetic graph. Add the CT pipeline as an *offline authoring tool*
(`tools/ct_pipeline/`, Python, Apache-2.0-compatible dependencies) that emits the same JSON schema, so
the simulator never gains a runtime dependency on Slicer or PyTorch. That preserves the "clone and run"
property that makes the project approachable.

---

## 5. Haptics and input hardware

### 5.1 Commercial VR gloves

| Product | Feedback type | Price (public, 2026-11) | Platform | Verdict for this project |
| --- | --- | --- | --- | --- |
| **bHaptics TactGlove DK3** | Vibration only: 7 LRA + 1 voice-coil per hand, 8 points, BLE, <20 ms ([product page](https://www.bhaptics.com/tactglove)) | **$385** | Official **Unity/Unreal** plugins; Python/JS/Android SDKs; **no Linux support documented** | Cheapest way to add "touch" cues; no force feedback, so it cannot resist a scope lever. Needs hand tracking (no internal tracking) — **incompatible with Vive wands** |
| **SenseGlove Nova 2** | **Force feedback**: 4 magnetic friction brakes, up to 20 N per finger, plus palm contact feedback ([product page](https://www.senseglove.com/product/nova-2/)) | **€6,299** excl. VAT (discount tiers listed) | Windows-centric SDK **[unverified for Linux]** | The only credible "feel the resistance" glove here; cost and platform risk are high |
| **Manus Metagloves Pro / Quantum** | Data gloves (+ haptic variant) ([manus-meta.com](https://manus-meta.com/)) | Quote-based (enterprise) | Windows/enterprise; no Linux statement | Overkill for a bronchoscopy trainer; better suited to robotics data collection |
| **Weart TouchDIVER** | Finger-tip force/thermal/vibration ([weart.it](https://www.weart.it/)) | Quote | Unity/Unreal; JS-rendered site, specs not extractable here | Watch list only **[unverified]** |

**Reality check for v1:** the Vive wands give you a trigger, a trackpad, a grip button and rumble. That
is enough for lever deflection, torque and suction, and it costs nothing. Gloves are a v2 research
question, and every commercial option above is Windows-first — a poor fit for a Linux-only lab.

### 5.2 DIY bronchoscope prop

A physical prop is what makes the psychomotor training transfer plausible: the trainee should hold a
handle, squeeze a lever, and feel the shaft resist. A staged build:

**Stage 1 — tracked, passive (a weekend, ~€150–250)**
* 3D-printed handle modelled on a flexible bronchoscope control section (lever + angulation knob).
* **HTC Vive Tracker (3.0)** bolted to the handle for 6DoF; Lighthouse-tracked, works with SteamVR
  natively ([VIVE Tracker 3.0](https://www.vive.com/us/accessory/tracker3/)).
* A potentiometer/ Hall sensor on the lever + a rotary encoder on the insertion wheel, read by an
  **ESP32/Arduino** and sent over USB serial or BLE as a HID joystick. Godot reads it as an ordinary
  input device.
* Insertion depth can be faked (encoder only) or measured with a **linear rail + encoder**.

**Stage 2 — force feedback on the lever (1-DOF)**
* Cheapest credible route: a **Hapkit**-style motor + capstan/cable, open hardware, "less than $50 for
  all components", CC BY-SA 3.0 ([hapkit.stanford.edu](https://hapkit.stanford.edu/)). Good for
  "resistance when the tip contacts a wall".
* Stronger, quieter, and mechanically simpler to fail-safe: a **magnetic particle brake** on the lever
  shaft (a powder/MR brake gives high torque in a small package and defaults to "free" when unpowered;
  see the brake-as-haptic-actuator literature, e.g.
  [exoskeleton haptic device using a powder brake, *Electrical Engineering in Japan* 2020](https://doi.org/10.1002/eej.23311)).
  A brake can only resist, not push — which matches a scope lever surprisingly well.
* Safety: any powered mechanism near the trainee's hand needs a torque limit, a slip clutch, and a
  hardware e-stop. Document it.

**Stage 3 — DIY glove (optional)**
* **LucidVR lucidgloves**: MIT, ~2.4k stars, "Arduino/ESP32 based DIY VR Haptic gloves. Compatible with
  SteamVR via OpenGloves" ([repo](https://github.com/LucidVR/lucidgloves), last push 2025-10-29).
  ArchWiki lists Lucid VR gloves as working with **Monado, survive driver only**
  ([ArchWiki](https://wiki.archlinux.org/title/Virtual_reality)) — i.e. the Linux path exists but is
  narrow. OpenGloves is a SteamVR driver; **Linux support is [unverified]**.

**Software architecture for all of the above:** model the physical control as an abstract
`ScopeController` with `lever`, `torque`, `insertion`, `suction`, `haptic_out`. The keyboard path, the
wand path and the prop path are three implementations. Do not let the hardware leak into case logic —
`docs/04-scope-model.md` already sketches this, keep it that way.

### 5.3 Real-time flexible endoscope modelling

| Approach | What it gives you | Cost | Citations |
| --- | --- | --- | --- |
| **Piecewise constant curvature (CC)** | Closed-form forward kinematics from a few arc parameters; exactly how a bronchoscope's distal bending section behaves; trivially stable at 90 Hz | Very low; no dynamics, no looping, no torque transmission | [Webster & Jones, *IJRR* 2010](https://doi.org/10.1177/0278364910368147) |
| **Position-based dynamics (PBD)** | Fast, unconditionally stable particle/constraint simulation; easy to couple to collision and to the airway mesh | Medium; stiffness is iteration-dependent, needs tuning; can look "rubbery" | [Müller et al., *JVCIR* 2007](https://doi.org/10.1016/j.jvcir.2007.01.005) |
| **XPBD** | PBD with time-step-independent compliance — much easier to tune, the current default for real-time medical threads | Medium | [Macklin et al., MIG 2016](https://doi.org/10.1145/2994258.2994272) |
| **Cosserat rod / discrete elastic rods (DER)** | Physically faithful bending *and* torsion, buckling, looping; the "right" model for a 60 cm shaft you torque | High CPU; stiff systems need small steps or implicit solves — hostile to an 890M's shared CPU/GPU budget | [Bergou et al., *ACM TOG* 2008](https://doi.org/10.1145/1360612.1360662); review: [Continuum Robots for Medical Interventions, *Proc. IEEE* 2022](https://doi.org/10.1109/JPROC.2022.3141338) |
| **SOFA BeamAdapter** (Kirchhoff rods) | A ready-made, validated 1D flexible-instrument model (catheters, guidewires) you can run offline | LGPL-2.1, C++, not embeddable in a Godot app without licence consequences | [BeamAdapter](https://github.com/sofa-framework/BeamAdapter) |

**Recommendation:** hybrid, in this order.

1. **Kinematics:** piecewise constant curvature for the shaft (straight proximal section + one or two
   bendable distal sections), driven directly by lever and torque inputs. This is cheap, predictable,
   and matches how trainees conceptualise the instrument.
2. **Contacts:** PBD/XPBD particles along the centre-line against capsule colliders generated from the
   airway graph, with the CC solution as a *soft constraint* so the shaft springs back to its commanded
   shape. This gives wall contact and "scraping" without a stiff solver.
3. **Haptics:** map the residual contact force at the tip to lever resistance (Stage 2 hardware) and to
   wand rumble (v1).
4. **Offline validation:** if you need to justify the model, reproduce a few cases in SOFA/BeamAdapter
   and compare tip trajectories; do not ship SOFA.

Cosserat/DER is the right answer only if the project later needs realistic *torque transmission along
the shaft* (e.g. "the scope whips when you torque a looped shaft"). That is a v3 research item, not a
v1 requirement — and it is the first thing to cut when the 890M misses frame time.

---

## 6. Open-source projects worth reusing

Activity and licence data were read from the GitHub/GitLab APIs on 2026-11-15.

| Project | Licence | Activity (last commit) | What it gives you | Verdict |
| --- | --- | --- | --- | --- |
| **iMSTK** (Kitware) | Apache-2.0 | **SUNSET**: "Support and development … has been discontinued as of May-02-2025" ([README](https://gitlab.kitware.com/iMSTK/iMSTK/-/raw/master/README.md); last GitLab activity 2026-04-10) | Surgical sim toolkit, haptics, PBD, endoscopy/camera scenes | **Do not depend on it.** Mine it for algorithms (collision, camera) with attribution |
| **SOFA** | **LGPL-2.1** | Active (2026-11-12, ★1.3k) ([repo](https://github.com/sofa-framework/sofa)) | Multi-physics, validated soft-tissue and 1D instrument models | Use **offline** for validation. LGPL + C++ makes it a poor fit for embedding in an MIT Godot app |
| **SOFA BeamAdapter** | **LGPL-2.1** | Active (2026-11-11) ([repo](https://github.com/sofa-framework/BeamAdapter)) | Kirchhoff rods for catheters/guidewires | Reference model for the scope physics; offline only |
| **3D Slicer** | BSD-style | Active (2026-11-11) ([repo](https://github.com/Slicer/Slicer)) | DICOM, segmentation, extension host | **Adopt** for the CT authoring pipeline |
| **SlicerIGT** | **BSD-3-Clause** | Active (2026-09-28, ★118) ([repo](https://github.com/SlicerIGT/SlicerIGT)) | IGT modules, tracker streaming | Adopt later if you add tracked props/IGT |
| **PlusLib / Plus Toolkit** | Open source (GitHub reports NOASSERTION; BSD-style per project) | Active (2026-11-11, ★158) ([repo](https://github.com/PlusToolkit/PlusLib)) | Real-time tracking/ultrasound IGT | Not needed for v1 |
| **godot-xr-tools** | **MIT** | Active (2026-10-10, ★749) ([repo](https://github.com/GodotVR/godot-xr-tools)) | Locomotion, grab, UI, hands | **Adopt** |
| **godot_openxr_vendors** | MIT | Active (2026-11-10, ★198) | Vendor OpenXR extensions (Quest/Pico) | Not needed for Vive |
| **StereoKit** | MIT | Active (2026-11-04, ★1.1k) | Lightweight C# XR engine | Plan B, not a dependency |
| **ALVR** | MIT | Very active (2026-11-14, ★8.1k) | Stream to standalone HMDs | Out of scope for Vive |
| **WiVRn** | **GPL-3.0** | Active (★1.9k) | Stream to standalone HMDs | Out of scope; do not bundle into an MIT release |
| **Monado** | **BSL-1.0** | Active (AUR 25.1.0) | OpenXR runtime | Runtime dependency only (user installs it) |
| **xrizer** | **GPL-3.0-or-later** | Active (AUR 0.6) | OpenVR→OpenXR shim | User-installed runtime component; do not vendor |
| **LucidVR lucidgloves** | MIT | 2025-10-29, ★2.4k | DIY haptic gloves | Reference design for a prop/glove |
| **VR-Caps / VirtualCapsuleEndoscopy** | **No licence** | 2022-06-23, ★210 ([repo](https://github.com/CapsuleEndoscope/VirtualCapsuleEndoscopy)) | Capsule endoscopy VR environment | **No licence = no reuse.** Read for ideas only |
| **OpenSurgiSim** | — | — | Orthopaedic VR trainer | **Could not locate a maintained public repository** at the named project (GitHub search and Europe PMC both empty on 2026-11-15). **[unverified]** — do not cite it as available until someone finds the URL |
| **Endora** | — | 2026-02 | *Video generation* as an endoscopy simulator (MICCAI 2024) | Research interest, not a simulator you can train on |

**Licence-compatibility rule for this repo:** MIT code can *call* BSL-1.0 Monado through the OpenXR
loader (a process boundary), but it cannot absorb LGPL-2.1 (SOFA) or GPL-3.0 (WiVRn/xrizer) code.
Keep those as user-installed runtime components or offline tools, and say so in `README`.

---

## 7. Existing VR medical training titles

### 7.1 On Steam

Steam's medical VR catalogue is dominated by **anatomy viewers**, and as of 2026-11-15 every one I
checked ships **Windows-only builds** (Steam store API, `platforms.linux = false`):

| Title | App ID | Released | Notes |
| --- | --- | --- | --- |
| 3D Organon | 1099550 | 2019-07-17 | Medis Media; "medical XR platform … 3D Anatomy, XR Medical Imaging, Medverse" |
| Medicalholodeck | 754010 | 2017-12-02 | CT/MRI → 3D via AI; anatomy + real-dissection scans |
| Vesalii Anatomy VR Student | 2752780 | 2024-07-31 | "VR Only" |
| The Body VR: Anatomy Viewer | 579620 | unreleased ("Coming soon") | "VR Only"; CT/MRI volumes |
| VR Anatomy | 925830 | 2018-10-04 | "VR Only", small student project |

Two decisive observations:

1. **There is no bronchoscopy simulator on Steam.** A store search for `bronchoscopy` returns
   **"0 results match your search"** ([Steam search](https://store.steampowered.com/search/?term=bronchoscopy)),
   and `bronchoscope`/`endoscope` also return nothing. The niche is unoccupied in the consumer channel.
2. **All of these are Windows-only.** Even the anatomy viewers do not ship a Linux build, which is
   consistent with Unity/Unreal being the usual engines (§2.2, §2.5).

### 7.2 The real incumbents are hardware-in-the-loop, not Steam

* **Surgical Science BRONCH Mentor** — the commercial reference simulator, with a standardised
  curriculum built with the American College of Chest Physicians ("The CHEST Standardized Curriculum
  for Bronchoscopic Essential Skills and Diagnostic Bronchoscopy"), including training and assessment
  modes ([Surgical Science bronchoscopy](https://surgicalscience.com/simulation-training/bronchoscopy/)).
  This is a physical-scope-plus-haptics device with a virtual patient library — the thing a fellowship
  programme would compare you against.
* Evidence base for VR/MR bronchoscopy training is growing but still thin on transfer to patients; a
  2025 narrative review summarises the current state
  ([*J Thorac Dis* 2025, "Bridging traditional gaps in medical training with mixed reality: insights
  from bronchoscopy education"](https://doi.org/10.21037/jtd-2025-565)). Use it to justify the project,
  and to define what you *do not* claim.

### 7.3 Technical approach — what it implies for us

* Consumer VR medical titles are **viewers**: segmented CT meshes + Unity + OpenVR/SteamVR, no
  instrument–tissue physics, no assessment.
* Procedure trainers are **closed appliances**: custom engine/software, physical instrument interface,
  force feedback, validated curricula, sold with service contracts.
* The gap this project fills is exactly the middle: **instrument–airway interaction + objective
  metrics, on commodity hardware, open source.** That is defensible, provided §5's contact model is
  honest and §9's validation plan exists. It also means the project should not try to out-anatomy the
  viewers, nor out-validate BRONCH Mentor — it should out-*inspect* both.

---

## 8. Recommendations

**Stack decision (v1).**

1. Godot **4.7.x**, Mobile renderer, OpenXR; pin the minor version. Desktop mode stays first-class.
2. Runtime: **SteamVR for Linux** (Ubuntu 26.04, X11 session, Mesa 25.x, SteamVR pinned), with
   Envision+Monado documented as fallback. Do not market WiVRn/ALVR as Vive options.
3. Add `/interaction_profiles/htc/vive_controller` to `openxr_action_map.tres`; verify trigger,
   trackpad, grip and menu on hardware; map rumble to wall contact.
4. Performance: budget 9 ms GPU; default render scale 0.8×; no shadows, no post, one material for the
   airway; validate with a release build on the 890M and record numbers in `docs/07`.
5. Physics: constant-curvature shaft + XPBD contacts; abstract `ScopeController` for keyboard/wand/prop.
6. Assets: keep synthetic anatomy MIT; add `assets/external/` with per-asset licence manifests;
   implement `tools/ct_pipeline/` as an offline Python tool using TotalSegmentator (Apache-2.0 tasks)
   + Slicer; never redistribute ATM'22 data.
7. Do **not** add iMSTK, SOFA, Unity, Unreal or WebXR to the runtime dependency graph.

**Sequencing that de-risks the most with the least work.**

| Order | Milestone | Why first |
| --- | --- | --- |
| 1 | Vive wand input + rumble on real hardware | Proves the whole Linux/OpenXR/SteamVR chain before content exists |
| 2 | Frame-time harness + a 90 fps worst-case lumen | Kills perf surprises while the scene is still simple |
| 3 | Case 1 (anatomy tour + segment ID) end-to-end | Forces labels, UI, metrics, debrief skeleton |
| 4 | Suction/secretions (case 3) | First real fluid/particle budget test on the iGPU |
| 5 | DIY prop Stage 1 (tracked handle) | Cheap, big immersion gain, no firmware risk to core code |
| 6 | CT pipeline for one LIDC-IDRI case | Proves the asset route before promising patient-specific anatomy |

---

## 9. Risk table

| # | Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- | --- |
| 1 | SteamVR-for-Linux regression breaks a lab session (RADV crash, ring-buffer assert) | High | High | Pin SteamVR build; keep a second machine image; document Monado+Envision fallback; desktop mode for teaching backup |
| 2 | Monado fallback is not truly independent (needs SteamVR's Lighthouse driver) | Certain | Medium | Say so in docs; do not promise "SteamVR-free Vive support"; keep the survive driver as untested experiment |
| 3 | 890M misses 90 Hz with a realistic airway + instruments | High | High | Render scale 0.7–0.9×, Mobile renderer, no shadows/post, budget in §3, measure at milestone 2 not at the end |
| 4 | Original Vive hardware end-of-life (base stations, wands, cables, link box) | Medium | High | Buy spares now; document 1.0 vs 2.0 incompatibility; the desktop + a second headset (Index/Quest via ALVR*) keep the project alive |
| 5 | AMD iGPU power management causes stutter/timewarp misses | Medium | Medium | Set `pp_power_profile_mode` VR profile; `U_PACING_COMP_MIN_TIME_MS=8` on Monado ([vronlinux](https://vronlinux.org/docs/performance/)) |
| 6 | Wayland session breaks SteamVR | Medium | Medium | Ship an X11-session instruction; test both; log session type in bug template |
| 7 | Licence contamination (BodyParts3D share-alike, ATM'22 no-redistribution, CC BY-NC sources, GPL runtime components) | Medium | High (legal) | Asset manifest + CI check on `assets/external/*/LICENSE`; never vendor ATM'22; keep CC BY-SA assets in a separate pack |
| 8 | Unity/Unreal temptation from a collaborator ("everyone uses Unity") | Medium | Medium | §2.2 shows Linux isn't a supported Unity OpenXR platform; record the decision in an ADR |
| 9 | Godot XR API churn between 4.7 → 4.8 breaks the action map / XR nodes | Medium | Medium | Pin engine; thin XR adapter layer; keep the headless tests free of XR |
| 10 | Clinical over-claim ("validated trainer") | Medium | High (credibility/regulatory) | Explicit non-goals in README (already present); cite the training-evidence review; no credentialing claims |
| 11 | CT pipeline produces anatomically wrong labels that silently ship | Medium | High | Depth-from-incisors validation, radius sanity checks, human review of Boyden labels, golden-case regression test |
| 12 | Haptic prop injures a user (powered mechanism near hands) | Low | High | Torque limit, slip clutch, e-stop, documented build; Stage 1 (passive) first |

\* ALVR only makes sense if the project later targets a standalone headset; it does not help a Vive.

---

## 10. Stale, uncertain, or unverified items

Flagged so nobody repeats the search or, worse, cites them as fact:

1. **AVIEW** — no airway CT dataset by that name found (Europe PMC, Zenodo, GitHub API, 2026-11-15).
   The requester's citation is needed; otherwise use LIDC-IDRI or ATM'22 locally.
2. **EXACT'09** — `https://image.diku.dk/exact/` did not respond (timeout) on 2026-11-15; the original
   challenge is from 2009. Treat as unavailable until someone mirrors it.
3. **OpenSurgiSim** — no maintained repository located. Do not list it as a dependency or prior art
   without a URL.
4. **Monado's native `survive` driver for HMD tracking** on an original Vive — ArchWiki shows HMD
   support "Yes" but the documented path is the SteamVR Lighthouse driver; libsurvive HMD quality is
   unverified here.
5. **Foveated rendering on Vive/SteamVR-Linux** — no evidence of support; budget assumes none.
6. **Glove vendor Linux support** — none of bHaptics/SenseGlove/Manus/Weart documents Linux; absence of
   a statement is not proof of absence, but plan for Windows-only SDKs.
7. **Unreal OpenXR on Linux** — Epic's docs page was not machine-readable here; no explicit support
   statement found. Assumed unsupported.
8. **WebXR on Linux with SteamVR/Monado** — no primary source found for a working path.
9. **Steam Frame / SteamVR 2.19 Linux specifics** — inferred from issue titles, not from Valve
   documentation.
10. **iMSTK's endoscopy components** — the project is sunset; anything you reuse is unmaintained code
    with an Apache-2.0 licence. Good for reading, bad for depending.
11. **890M FP32/bandwidth figures** are derived from AMD's CU count/clock and channel count, not from
    a measured benchmark; the laptop's actual memory configuration and power limits will move them.
12. **Steam Store VR/anatomy survey** was done via the public store API on one day; the catalogue
    changes. It is a snapshot, not a market study.

---

## 11. Link appendix

**Runtimes**
- SteamVR for Linux README — https://github.com/ValveSoftware/SteamVR-for-Linux
- SteamVR Linux issue tracker (base station power mgmt #320) — https://github.com/ValveSoftware/SteamVR-for-Linux/issues/320
- Monado — https://monado.dev/ · AUR package — https://aur.archlinux.org/packages/monado
- Envision — https://gitlab.com/gabmus/envision
- xrizer — https://github.com/Supreeeme/xrizer
- OpenComposite / OpenOVR — https://gitlab.com/znixian/OpenOVR
- WiVRn — https://github.com/WiVRn/WiVRn
- ALVR — https://github.com/alvr-org/ALVR
- ArchWiki Virtual reality (device × runtime table) — https://wiki.archlinux.org/title/Virtual_reality
- Linux VR Adventures wiki: Monado — https://vronlinux.org/docs/fossvr/monado/ · SteamVR — https://vronlinux.org/docs/steamvr/ · Performance — https://vronlinux.org/docs/performance/
- OpenXR loader spec — https://registry.khronos.org/OpenXR/specs/1.1/loader.html

**Engines**
- Godot 4.7 release notes — https://godotengine.org/releases/4.7/ · 4.7.2 release — https://github.com/godotengine/godot/releases/tag/4.7.2-stable
- Godot: Setting up XR — https://docs.godotengine.org/en/stable/tutorials/xr/setting_up_xr.html
- Godot: OpenXR settings — https://docs.godotengine.org/en/stable/tutorials/xr/openxr_settings.html
- godot-xr-tools — https://github.com/GodotVR/godot-xr-tools · godot_openxr_vendors — https://github.com/GodotVR/godot_openxr_vendors
- Unity OpenXR 1.15 manual — https://docs.unity3d.com/Packages/com.unity.xr.openxr@1.15/manual/index.html
- Unity pricing changes — https://unity.com/products/pricing-updates · plans — https://unity.com/pricing
- StereoKit — https://stereokit.net/Pages/Guides/Getting-Started.html · https://github.com/StereoKit/StereoKit
- Bevy OpenXR — https://crates.io/crates/bevy_mod_openxr · https://crates.io/crates/openxr
- Unreal Linux requirements — https://dev.epicgames.com/documentation/en-us/unreal-engine/linux-development-requirements-for-unreal-engine
- Unreal OpenXR — https://dev.epicgames.com/documentation/en-us/unreal-engine/openxr-in-unreal-engine
- caniuse WebXR — https://caniuse.com/webxr

**Performance**
- Valve, *Advanced VR Rendering* (GDC 2015) — http://alex.vlachos.com/graphics/Alex_Vlachos_Advanced_VR_Rendering_GDC2015.pdf
- AMD Ryzen AI 9 HX 370 (Radeon 890M: 16 CUs @ 2900 MHz, 2 memory channels, LPDDR5X-8000) — https://www.amd.com/en/products/processors/laptop/ryzen/ai-300-series/amd-ryzen-ai-9-hx-370.html
- HTC Vive specs — https://en.wikipedia.org/wiki/HTC_Vive

**Anatomy / imaging**
- BodyParts3D (licence CC BY-SA 2.1 JP) — https://lifesciencedb.jp/bp3d/info/ · paper — https://doi.org/10.1093/nar/gkn613
- AnatomyStandard (CC BY-NC 4.0) — https://www.anatomystandard.com/
- NIH 3D — https://3d.nih.gov/ · terms — https://3d.nih.gov/terms
- Zygote — https://www.zygote.com/
- LIDC-IDRI (CC BY 3.0) — https://www.cancerimagingarchive.net/collection/lidc-idri/
- ATM'22 (no redistribution) — https://atm22.grand-challenge.org/ · ATM'26 — https://atm26.grand-challenge.org/
- TotalSegmentator — https://github.com/wasserth/TotalSegmentator · nnU-Net — https://github.com/MIC-DKFZ/nnUNet
- 3D Slicer — https://github.com/Slicer/Slicer · licence — https://github.com/Slicer/Slicer/blob/main/License.txt
- SlicerIGT — https://github.com/SlicerIGT/SlicerIGT · PlusLib — https://github.com/PlusToolkit/PlusLib
- dcm2niix — https://github.com/rordenlab/dcm2niix · scikit-image morphology — https://scikit-image.org/docs/stable/api/skimage.morphology.html · VMTK — https://www.vmtk.org/

**Haptics / props / modelling**
- bHaptics TactGlove — https://www.bhaptics.com/tactglove · SenseGlove Nova 2 — https://www.senseglove.com/product/nova-2/
- Manus — https://manus-meta.com/ · Weart — https://www.weart.it/
- Hapkit (open-hardware 1-DOF haptic device, CC BY-SA 3.0) — https://hapkit.stanford.edu/
- VIVE Tracker 3.0 — https://www.vive.com/us/accessory/tracker3/
- LucidVR lucidgloves (MIT, DIY haptic gloves) — https://github.com/LucidVR/lucidgloves
- Webster & Jones, constant curvature review — https://doi.org/10.1177/0278364910368147
- Müller et al., PBD — https://doi.org/10.1016/j.jvcir.2007.01.005 · Macklin et al., XPBD — https://doi.org/10.1145/2994258.2994272
- Bergou et al., discrete elastic rods — https://doi.org/10.1145/1360612.1360662
- Continuum robots for medical interventions (review) — https://doi.org/10.1109/JPROC.2022.3141338
- Powder-brake haptic actuator example — https://doi.org/10.1002/eej.23311

**Simulation frameworks / prior art**
- iMSTK (sunset notice) — https://gitlab.kitware.com/iMSTK/iMSTK · GitHub mirror — https://github.com/Kitware/iMSTK
- SOFA — https://github.com/sofa-framework/sofa · BeamAdapter — https://github.com/sofa-framework/BeamAdapter
- VR-Caps capsule endoscopy (no licence) — https://github.com/CapsuleEndoscope/VirtualCapsuleEndoscopy
- Surgical Science BRONCH Mentor + CHEST curriculum — https://surgicalscience.com/simulation-training/bronchoscopy/
- Mixed-reality bronchoscopy education review (2025) — https://doi.org/10.21037/jtd-2025-565
- Steam store search ("bronchoscopy": 0 results) — https://store.steampowered.com/search/?term=bronchoscopy
