# Linux VR stack, engines, performance, assets and prior art — final scoping report

**Research date:** 2026-11-15. All "current" statements are as of that date.
**Target:** original HTC Vive (wand controllers, Lighthouse 1.0), Ubuntu 26.04, AMD Radeon 890M
(RDNA 3.5, 16 CU), 61 GB unified RAM. Secondary goal: other OpenXR headsets.
**Status:** final report from the stack-scoping agent. Supersedes
`../archive/tech-stack-scoping-local-draft.md`. Companion files in this directory:
`haptics-input-kinematics.md` (§5 detail) and `medical-3d-assets.md` (§4 detail).

**How to read this.** Linked claims come from a fetched source. Derived numbers are marked
**[estimate]** with the method. Unverified items are marked **[unverified]** and collected in §8.
I did not repeat what `../linux-vr-stack.md` already covers well (Vive hardware mechanics, the Godot
project skeleton, the renderer choice) except where I found it wrong or incomplete — those points are
marked **⚠️ correction**.

**Verified on this machine, not from spec sheets** (useful because it means the numbers are ours, not
a vendor's):
`AMD Radeon 890M Graphics (radeonsi, strix1, ACO, DRM 3.64)`, Mesa **26.0.8**, Vulkan **1.4.341**,
kernel 7.0.0-43, unified memory. `VK_KHR_fragment_shading_rate` (rev 2),
`VK_EXT_direct_mode_display`, `VK_KHR_present_wait` all present — hardware variable-rate shading and
Monado direct mode are both available here.

**Packaging reality on Ubuntu 26.04** (checked with `apt-cache policy`):
`libopenxr-loader1` **1.1.47** is available; **monado, wivrn-server, envision and godot4 are not in
the archive** (`godot3` 3.6.2 is the only Godot). Runtime and editor both come from outside apt, so
contributor docs must say so explicitly rather than assume `apt install`.

---

## 0. Recommendations

| Question | Recommendation | Confidence |
| --- | --- | --- |
| VR runtime | Ship a pure **OpenXR** app; document **Monado via Envision** as the default dev setup, SteamVR as tested fallback | High on the app, medium on the default |
| Engine | **Godot 4.7.x**, **Mobile renderer**, `godot-xr-tools`, built-in OpenXR | High |
| Perf | 90 Hz / 11.11 ms; 0.7–1.0× render scale; ≤300 draw calls; ≤300k visible tris/eye | Medium — must be measured |
| Foveated rendering | Fixed only (Godot VRS or compositor supersample). **No eye-tracked FR** on an OG Vive | High |
| Anatomy | **BodyParts3D** (CC BY 4.0) as shipped base; **BronchSim** (CC BY 4.0) as a labelled alternative; CT pipeline for patient cases | Medium-high |
| Haptics v1 | Wand rumble, with an input abstraction ready for a DIY motorised handle | Medium |
| Scope kinematics | **1 active PCC section + passive compliant shaft**, XPBD solver in a GDExtension | High |
| Reuse | **Fraxinus** (BSD-3) for CT→airway-tree→route planning; **godot-xr-tools** (MIT); **BeamAdapter** (LGPL-2.1) as a model to reimplement | Medium-high |
| Avoid | Unity 6, UE5, iMSTK (sunset), WiVRn/ALVR (wireless only) | High |

---

## 1. VR runtime on Linux, 2025–2026

### 1.1 The architectural point that decides everything

**We do not need SteamVR.** SteamVR is required only by software that speaks OpenVR (Valve's older
API). A Godot/OpenXR app talks to whatever OpenXR runtime is installed. Choosing a pure OpenXR app
removes the single largest source of Linux VR pain from our dependency graph, and makes the
runtime choice a *deployment* detail rather than an architectural one. The LVRA wiki makes this
explicit, warning app developers that the OpenVR→OpenXR shims are incomplete and that new software
should use OpenXR directly ([xrizer page](https://vronlinux.org/docs/fossvr/xrizer/)).

### 1.2 The options, and what each is actually for

| Route | What it is | Relevance to a tethered Vive | Verdict |
| --- | --- | --- | --- |
| **Monado** ([docs](https://monado.pages.freedesktop.org/monado/)) | Open-source OpenXR runtime, BSL-1.0, Linux-first, commits daily | Native, two independent Lighthouse paths | **Recommended** |
| **Envision** ([GitLab](https://gitlab.com/gabmus/envision)) | AGPLv3 GUI orchestrator that builds/runs Monado | The practical way to get Monado on Ubuntu | **Recommended** |
| **SteamVR for Linux** | Valve's native runtime | Works, but lowest-priority platform | **Fallback** |
| **WiVRn** ([site](https://wivrn.github.io/)) | GPL-3.0, Monado-based, *streams* to standalone headsets | N/A — the Vive is tethered | Only for Quest-class headsets |
| **ALVR** | Older wireless streaming | Superseded by WiVRn in this community | Not recommended |
| **xrizer** / OpenComposite | GPL-3.0 OpenVR→OpenXR shims | Only to run *Steam/OpenVR games* | **Not needed by us** |

### 1.3 ⚠️ Correction: Monado's Vive 6DoF is build-dependent, not absent

A claim circulated in this project's research that "Monado supports the Vive HMD only at 3DoF, with
6DoF only via experimental Basalt (Index)". That is **half right, and the half that is right matters
a lot.**

Monado has **three separate, build-time-optional** Lighthouse paths. From
[`CMakeLists.txt`](https://gitlab.freedesktop.org/monado/monado/-/raw/main/CMakeLists.txt):

| CMake option | Line | What it gives you |
| --- | --- | --- |
| `XRT_BUILD_DRIVER_VIVE` | 387 | "driver for HTC Vive, Vive Pro, Valve Index, and their controllers" — device + IMU. **Alone, this is 3DoF.** |
| `XRT_BUILD_DRIVER_SURVIVE` | 383 | libsurvive driver — **6DoF from Lighthouse**, but depends on `SURVIVE_FOUND` |
| `XRT_BUILD_DRIVER_STEAMVR_LIGHTHOUSE` | 382 | Uses SteamVR's own Lighthouse driver — **6DoF**, requires SteamVR installed |

So the correct statement is: **6DoF head tracking on a Vive requires either libsurvive to be present
at build time or `STEAMVR_LH_ENABLE=true`.** A build without either silently degrades to 3DoF — which
for our simulator would be fatal, since insertion depth and where you are looking in the airway both
depend on positional tracking. Practical consequences:

* Envision sets `STEAMVR_LH_ENABLE=true` for you, which is why the community path works out of the box.
* Anyone hand-building Monado must confirm `SURVIVE_FOUND` or set that variable — put this in the
  contributor docs as a first-run check, and add a runtime assertion that the pose is 6DoF.
* The fully-FOSS path is [libsurvive](https://github.com/collabora/libsurvive) (**MIT**), which does
  its own Lighthouse pose solving. Its README warns to **close SteamVR** when using it, or the two
  compete for USB bandwidth.

I could not reproduce the "Basalt/Index-only 6DoF" claim from a primary source; Basalt is Monado's
camera-SLAM path, which is a different mechanism from Lighthouse. Treat the 3DoF claim as **an
artefact of a build without SURVIVE/STEAMVR_LH**, not as a property of Monado.

### 1.4 Where the community consensus sits (and where it disagrees with our own docs)

The Linux VR Adventures wiki (last edited 2026-11-13) recommends, for wired headsets, "use Envision to
run or compile the latest Monado and xrizer", and says SteamVR "is still an option, but we don't
recommend it… SteamVR for Linux is listed as a 'development release'; it is not intended for
end-users" ([vronlinux.org](https://vronlinux.org/)). Its SteamVR page: "the Linux version is riddled
with bugs, missing features and bad performance"
([SteamVR page](https://vronlinux.org/docs/steamvr/)).

**⚠️ This disagrees with `../linux-vr-stack.md`**, which names SteamVR as primary with Monado as
fallback. Both are defensible:

* *For SteamVR* — Valve's own runtime, most complete Vive support, best Lighthouse tracking, already
  installed on most VR machines, and it is what an OG Vive has used since 2017.
* *For Monado* — open source (auditable, scriptable, packageable), lighter on a 16-CU iGPU, no
  account dependency, and debuggable by a contributor who owns no proprietary runtime.

**Resolution I recommend:** the app is runtime-agnostic (that is the real, low-risk decision). For the
*documented default*, prefer Monado+Envision, and keep SteamVR as a **tested** alternative rather than
an untested claim. Reason: the only artifact we control is the app, and a contributor who can
`git clone && run` without Steam is a contributor retained. Because the Monado path depends on
STEAMVR_LH or libsurvive anyway, documenting both costs little.

### 1.5 Monado specifics worth pinning in the docs

From the [LVRA Monado page](https://vronlinux.org/docs/fossvr/monado/):

* **No hotplug.** "You must turn on all your devices before starting Monado." Power headset, wands
  and any tracker first.
* **Run SteamVR Room Setup once** to fix floor height, even when using Monado afterwards.
* **AMD reprojection needs a capability:** `sudo setcap CAP_SYS_NICE=eip …/monado-service`. Envision
  and the AUR package do this; a hand-built Monado does not. Without it, reprojection is unreliable —
  which on an iGPU is exactly where we cannot afford stutter.
* **Disable SteamVR auto-launch** (`power.autoLaunchSteamVROnButtonPress = false`), or SteamVR will
  start and fight Monado whenever a wand wakes.
* **Version drift is the norm:** latest *tagged* Monado is **v25.1.0 (2025-12-09)** while `main` gets
  daily commits (GitLab API: last activity 2026-11-15). LVRA: distro "stable" packages "quickly become
  out-of-date and so are unsuitable for most setups", which is why the Envision AppImage with
  **development profiles** (builds Monado from source) is the recommended path
  ([Envision page](https://vronlinux.org/docs/fossvr/envision/)).
* **Homebrew-XR is deprecated** — "no longer receiving updates", will likely not build
  ([LVRA](https://vronlinux.org/docs/distros/homebrew/)). Do not put it in our docs.

### 1.6 SteamVR specifics, if used

* Launching an OpenXR app *through Steam* needs
  `PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1 %command%`, because the Steam Linux Runtime container
  does not expose OpenXR by default ([LVRA](https://vronlinux.org/docs/fossvr/monado/)). Launching
  from a shell avoids this entirely — another argument for making direct launch the default.
* SteamVR 2.15 appears to have shipped ~2026-03-26 **[unverified — community release thread]**.
* SteamVR's room-setup app is bug-prone; LVRA documents "quick calibration" (headset and controllers
  on the floor at the centre → Settings → Developer → Room and Tracking), which works in SteamVR and
  Envision alike.

### 1.7 2026 landscape change: Steam Frame, and the Index's end

Valve's **Steam Frame** launched 2026-09-14/18 at $1,059–1,299: **SteamOS on ARM64** (Snapdragon 8
Gen 3), 2160×2160/eye, eye tracking, "foveated streaming"
([Wikipedia](https://en.wikipedia.org/wiki/Steam_Frame)). Two implications:

* SteamVR is being actively developed for Linux again — but for ARM64 standalone, not for x86
  desktops driving 2016 Lighthouse hardware. Do not read this as a revival of desktop Linux SteamVR
  quality.
* The same article lists the **Valve Index as discontinued**. Treat Lighthouse as a legacy input path
  **[unverified — check Valve's store]**. This strengthens the case for keeping everything
  OpenXR-generic: Vive support is a compatibility floor, not a platform bet.

---

## 2. Engine options

### 2.1 Godot 4 — recommended

| Fact | Detail |
| --- | --- |
| Licence | **MIT** |
| Stable | **4.7.2** (2026-08-18) ([releases API](https://api.github.com/repos/godotengine/godot/releases)) |
| OpenXR | Built in, not a plugin — "out of the box support for OpenXR… desktop headsets like the Valve Index" ([features](https://docs.godotengine.org/en/stable/about/list_of_features.html)) |
| Renderer | "**Mobile** renderer for any desktop VR project… Forward+… isn't well optimized for XR right now" ([XR setup](https://docs.godotengine.org/en/stable/tutorials/xr/setting_up_xr.html)) |
| `godot-xr-tools` | **MIT**, 749★, 4.5.2 (2026-10-08), 4.6.0-dev2, last commit 2026-10-10 |
| `godot_openxr_vendors` | **MIT**, 198★, pushed 2026-11-10 — **Android vendor** extensions only (Meta/Pico/Magic Leap). Not needed for desktop. |
| VRS | Supported; "AMD RDNA2 and newer (both integrated and dedicated)" ([VRS docs](https://docs.godotengine.org/en/stable/tutorials/3d/variable_rate_shading.html)) |

Why it wins for a small open-source project: one self-contained editor binary, no account, no licence
server, no seat management; MIT end to end; GDScript lowers the barrier for clinician-contributors;
XR tooling has a long-term maintainer and is active. Building the engine from source is only needed
for engine-level changes.

Known XR rough edges (open issues via GitHub API, 2026-11-15):

* **#66994** "Vulkan: Enabling FSR and XR results in a black screen" — open since 2023. **Do not use
  FSR in XR.**
* **#75229** "subviewport image corruption with XR" — open since 2023. Directly relevant: the
  endoscope-feed-into-a-monitor design wants a `SubViewport`. Prototype early.
* **#124135** `XR_MND_headless` — open. Would help headless CI on Monado.

### 2.2 ⚠️ Godot-specific trap for the DIY scope prop (from the haptics research)

Godot's **default OpenXR action map deliberately omits** `/user/vive_tracker_htcx/role/handheld_object`
from both `default_pose` and `haptic`, with the source comment `// "...handheld_object," <-- getting
errors on this one.`, and does not register the `vive_tracker_htcx` interaction profile at all
(`modules/openxr/action_map/openxr_action_map.cpp`). Fixes: supply a custom action map binding
`handheld_object/input/grip/pose`, or assign the tracker the `chest` role (which is in the map). Wrist
and ankle paths only landed in Godot via PR #108511 (merged 2025-07-15), so **pin the engine version**.
This is a real, verified cost of the Godot choice specifically for a tracked scope handle — budget a
day for it, and test before committing to the tracker design.

### 2.3 Unity 6 — not viable on Linux

Unity's own OpenXR documentation lists supported build targets as **Windows 64-bit (DX11), Android
arm64/x64 and UWP** — there is **no Linux build target**
([Unity OpenXR manual](https://docs.unity3d.com/Packages/com.unity.xr.openxr@1.19/manual/index.html)).
The same page lists foveated rendering among things Unity "does not yet provide out-of-the-box".
Secondary problems for open source: proprietary and closed, so contributors need Unity Hub, an account
and a licence acceptance just to read code; binary/YAML assets that merge badly. (Unity's 2026
"4% of revenue" chatter appears to be an Enterprise-tier condition for very large organisations
**[unverified]** — and moot, since platform support already rules it out.)

### 2.4 Bevy — promising, too immature for VR UI

`bevy_mod_openxr` (dual MIT/Apache-2.0): **0.6.0 on 2026-06-20**, 425★, 6 open issues, ~22k downloads
([crates.io](https://crates.io/crates/bevy_mod_openxr)). It is a thin OpenXR binding, not an XR
application framework — no equivalent of godot-xr-tools' grab/throw/locomotion/pointers/UI. Bevy's UI
is not designed for in-world VR panels, and Bevy breaks API on most releases, taxing every upgrade.
Wrong trade for a debrief-heavy training tool.

### 2.5 StereoKit — viable, but concentrated risk

MIT, 1.1k★, genuinely Linux-friendly (Linux x64 binaries in NuGet; "Monado, and essentially everywhere
OpenXR is"; `dotnet new sk-multi` gives a running app in minutes; flat-screen simulator for
contributors without a headset) ([repo](https://github.com/StereoKit/StereoKit),
[guide](https://stereokit.net/Pages/Guides/Getting-Started.html)). Against: 141 open issues on a very
small core team, a heavier .NET toolchain for clinician-contributors, no scene editor (everything is
code), smaller ecosystem. Credible second choice; Godot is the safer default.

### 2.6 Unreal Engine 5 — not viable

UE5 ships Linux binaries and packages Linux games, but Epic's XR support targets Win64 and Android;
VR Preview and OpenXR are not a supported Linux configuration, and the Linux editor generally means a
source build. **[unverified — Epic's XR docs are JS-rendered; I could not extract a platform table.
Treat as "no known supported path", not "proven impossible".]** Disqualifying for a small team on build
time and disk alone.

### 2.7 WebXR / three.js — not for the primary build

**Wolvic**, the open-source XR browser, targets "AOSP-based, stand-alone XR systems and HarmonyOS
tethered systems" only — Quest, Pico, Lynx, Magic Leap ([wolvic.com](https://wolvic.com/)); no
desktop-Linux build. Chromium on Linux can do WebXR through OpenXR, but it is a second-class path with
no swapchain-level debugging, and WebXR gamepad mapping for Vive wands is limited — we would lose raw
controller state needed for instrument handling. **[unverified for current Chrome.]** Revisit later
as a no-install demo.

---

## 3. Performance realities on a Radeon 890M

### 3.1 The budget, derived from verified limits

| Parameter | Value | Source |
| --- | --- | --- |
| GPU | Radeon 890M, **16 CUs**, 2900 MHz | [AMD HX 370 specs](https://www.amd.com/en/products/processors/laptop/ryzen/ai-300-series/amd-ryzen-ai-9-hx-370.html) |
| Memory | LPDDR5X-8000, **2 channels**, shared with CPU (~128 GB/s) | same + **[estimate]** for the GB/s |
| Panel | 1080×1200/eye, 90 Hz → **2.59 Mpix/frame, 233 Mpix/s** | [Wikipedia](https://en.wikipedia.org/wiki/HTC_Vive) |

The binding constraint is **bandwidth, not VRAM**. At ~128 GB/s and 90 Hz, everything per frame —
rendering, compositor, reprojection, CPU traffic — must fit in roughly **1.4 GB/frame**
**[estimate]**. So on a 61 GB unified-memory machine, *texture memory is nearly free; texture bandwidth
and fill rate are not.* That inverts the usual advice.

Frame budget (11.11 ms) **[estimate — validate by profiling]**:

| Slice | Target | Why |
| --- | --- | --- |
| App GPU | ≤ 8 ms | Leaves room for Monado's compositor + reprojection on the same 16 CUs |
| App CPU | ≤ 6 ms | Vulkan submission per view; physics must not run on the main thread |
| Compositor | 2–3 ms | LVRA advises iGPU users to raise `U_PACING_COMP_MIN_TIME_MS` into "the double digits" if stutter persists |

That last point is easy to miss: on weak GPUs the fix is often not "render less" but giving the
compositor headroom (`U_PACING_COMP_MIN_TIME_MS=8` or more) in the Monado environment
([LVRA performance](https://vronlinux.org/docs/performance/)).

### 3.2 Budgets for procedural tube geometry

| Resource | Budget | Notes |
| --- | --- | --- |
| Draw calls | **≤300** target, 800 ceiling | **[estimate]** At ~5–10 µs/draw on RADV, 500 draws ≈ 3–5 ms — most of the CPU budget. One merged airway mesh + a few instruments should sit at 30–60. |
| Visible triangles | **≤300k/eye**, ~1M submitted | **[estimate]** Vertex work is cheap on 16 CUs; fill/overdraw is the cost. A decimated bronchial tree is ~65k tris (§4). |
| Materials | ≤10 unique, 1–2 atlases | Shader switches break batching; bake into vertex colour + one atlas. |
| Textures | ≤512 MB resident | Cheap in RAM; bandwidth is the limit. Smaller, BC-compressed. |
| Overdraw | ≤2× average | Interior tube geometry is exactly where layered transparent surfaces kill an iGPU. |
| Lights | 1 headlight + ambient; **no** real-time shadows | Mobile renderer is deliberately limited; fake with vertex AO. |
| Post-processing | none | Also: Godot foveation is "disabled if post effects are used such as glow, bloom, or DOF" ([docs](https://docs.godotengine.org/en/stable/tutorials/xr/openxr_settings.html)). |

### 3.3 Foveated rendering: be precise about three different things

* **Eye-tracked FR: unavailable.** The OG Vive has no eye tracking. Eye-tracked FR needs Vive Pro Eye,
  PSVR2 or Steam Frame.
* **Fixed FR via VRS: available in principle.** Hardware supports it (RDNA2+; extension confirmed
  present here), and Godot exposes it — Mobile/Forward+ use `Viewport.vrs_mode = VRS_XR`
  ([docs](https://docs.godotengine.org/en/stable/tutorials/xr/openxr_settings.html)). Whether the
  density map survives end-to-end through Monado on a wired Vive is **[unverified]** — test early,
  never plan around it.
* **Compositor supersampling is the better lever.** LVRA: avoid MSAA, raise compositor scale — "AA is
  found to increase the latency of delivered frames quite noticeably… far more than simple super
  sample" ([performance](https://vronlinux.org/docs/performance/)). Dropping render scale to 0.7–0.9×
  and letting the compositor upscale usually beats VRS on an iGPU.

### 3.4 What to avoid here specifically

* **Forward+ renderer** — Godot's own docs say it is not well optimised for XR.
* **MSAA** — bandwidth we do not have.
* **FSR in XR** — open Godot bug → black screen (#66994).
* **Per-frame mesh regeneration** — build the airway `ArrayMesh` once at load with `SurfaceTool`. This
  is the biggest CPU trap for "procedural tube geometry".
* **Thousands of `MeshInstance3D` nodes** for tube segments — one merged mesh per airway tree; use
  `MultiMeshInstance3D` only for genuinely repeated props
  ([MultiMesh](https://docs.godotengine.org/en/stable/tutorials/optimization/using_multimesh.html)).
* **Runtime CSG** — prototype only; bake before the frame loop.
* **Transparent interior surfaces / heavy overdraw** — render the lumen interior with opaque backfaces.
* **Real-time GI, SSAO, SSR, volumetric fog, DOF, glow** — all off.
* **Trusting "it feels 90"** — iGPU shares bandwidth with the CPU; editor smoothness predicts nothing.
  Measure with GPU timestamps.

---

## 4. Open anatomy / medical 3D assets

Full detail, licences and the CT pipeline: **`medical-3d-assets.md`** in this directory. Summary of
what changes decisions:

* **BodyParts3D** (DBCLS Japan) is still downloadable and the archive licence page (updated
  2025-02-27) now says **CC BY 4.0**, attribution only. It contains a ready-made **tracheobronchial
  tree** (FMA7393, 95 element OBJs, 65,240 tris, 38,912 verts), including all 18 bronchopulmonary
  segmental bronchial trees, so segment-level naming for navigation and QA scoring comes free. Two
  caveats: the surfaces are **open, not watertight** (~11.5k boundary edges, no UVs, no textures), so
  hole-filling/union/shell-thickening is a required pre-step; and the 2013 OBJ files still carry the
  **legacy "CC BY-SA 2.1 Japan" header**, so the safest reading is to attribute both licences and ship
  the meshes as a **separate asset pack** rather than merging them into MIT source. Ask DBCLS to
  confirm before any commercial deployment.
* **BronchSim** (`andreajonas/bronchsimulator`, **CC BY 4.0**) ships a CT-derived, **labelled** airway
  mesh + centreline as glTF (built with 3D Slicer + VMTK) — the fastest route to a credible airway
  asset, attribution only.
* **TotalSegmentator's licence is per-task, not blanket.** Code and the `total`/`lung_vessels`/
  `lung_vessels_LEGACY` tasks are Apache-2.0; other tasks need a licence (free non-commercial),
  and `brain_aneurysm` is CC BY-NC with no commercial option. PyPI metadata still claims Apache-2.0
  for everything, which is misleading. **Our airway path is in the free set**: `lung_vessels` →
  `lung_airways` + `lung_airways_wall`; `total` → `trachea` (class 16). So an airway tree is obtainable
  without ATM'22. Pin the version and record `totalseg_info --list-tasks` in provenance.
* **CT datasets:** **AeroPath** (27 CTs with airway + lung masks, **CC BY 4.0**, Zenodo
  10.5281/zenodo.10069289) is the recommended CT source. **ATM'22 is contradictory** — the challenge
  says redistribution is "strictly prohibited" while the organisers' own Zenodo deposits are CC BY 4.0;
  do not ship it, internal evaluation only. **EXACT'09** is effectively stale (submission format page
  only, no dataset endpoint). **TCIA has no airway or bronchoscopy collection at all** (156 collections
  enumerated).
* **Never ship** CC BY-NC-SA datasets (Cholec80/CholecT50) or anything with no licence (VR-Caps,
  Endora, SlicerAirwaySegmentation). Patient-CT-derived meshes are derivative works of the dataset
  licence — keep them out of the repo and out of shipped assets.

---

## 5. Haptics, input, and endoscope kinematics

Full detail: **`haptics-input-kinematics.md`** in this directory. The points that affect the stack or
architecture:

* **OpenXR cannot carry custom haptics.** Unextended OpenXR has exactly one haptic type,
  `XrHapticVibration`, bound to `/output/haptic`; `XR_EXT_haptic_parametric` is **unratified** and only
  streams waveforms to existing haptic elements. A brake or motorised handle must therefore run over a
  **side channel** (USB CDC/HID); OpenXR carries only the tracker pose. This is an architectural
  constraint, not an implementation detail.
* **Commercial gloves are the wrong axis.** Everything shipping is vibrotactile (bHaptics, Manus
  Metagloves Pro Haptic) or finger-scale kinesthetic (SenseGlove ≤20 N/finger, Weart, HaptX, Dexmo).
  None produce axial insertion resistance along a 60 cm shaft. Linux support is also the binding
  constraint: bHaptics needs a Windows/macOS Player (broken under Wine); SenseGlove has a native Linux
  SDK but its Unity-on-Linux support covers only the legacy DK1; Manus gates Linux behind a paid SDK
  tier.
* **DIY is the practical route**, and there is precedent with hard numbers: VTEST (IEEE ToH 2016,
  open access) used two spring-loaded friction wheels pinching the shaft, torque-controlled Maxon
  RE40 motors, delivering **5.62 N** continuous translation and **0.190 N·m** torque; measured
  requirement was mean push 4.06 N with **peak 25.2 N**. Particle brakes are a poor fit (thermal
  derating under continuous slip, and no free-wheeling); motor + friction wheels is the better design.
  **[No bronchoscopy-specific force measurement was found — this is an assumption carried from
  colonoscopy.]**
* **OpenFFBoard** (MIT, ~1k★, active) is the ready-made FFB firmware base, with an "external FFB" mode
  already implementing constant force/spring/damper/inertia/friction over serial/HID.
* **Anatomy correction that changes the model:** a bronchoscope has **one** actively controlled distal
  bending section (a single angulation lever, ~180°) plus rotation and insertion — 4 DoF — with a
  passively compliant shaft. That is *not* a colonoscope's two-knob architecture, so model **one active
  PCC section + passive shaft**, not two PCC sections.
* **Solver:** XPBD chain of **24 nodes** over ~60 cm, 1 distance + 1 bending constraint, 4 substeps ×
  4 iterations, node 0 pinned to the tracked handle pose. Run it in a **GDExtension**: Godot's physics
  tick defaults to 60 Hz (`physics/common/physics_ticks_per_second`), and GDScript would dominate the
  frame. Estimated <0.5 ms/frame **[estimate, not benchmarked]**.
* **Collision:** model the airway as a **spline centreline + radius per station** with analytic
  push-out and a sliding station index — O(1) amortised, no broadphase, no triangle-mesh physics. This
  is also exactly how CT airway trees are extracted, so the same structure serves rendering, collision
  and scoring.
* **Scope view:** mono `SubViewport` at 512²–640×480, no shadows/MSAA, short far plane. Mono is also
  the correct look (real bronchoscopy is a 2D monitor). Budget ~40–60% of one eye pass **[estimate]**.

---

## 6. Existing open-source projects to reuse

Full 93-row survey: `prior-art-vr-bronchoscopy.md` (one directory up). Headline corrections and reuse:

### 6.1 iMSTK — sunset, and not what it was assumed to be

Apache-2.0 but **discontinued**: README carries a "SUNSET NOTICE" dated 2025-05-02; the GitHub repo is
an archived mirror; canonical GitLab last released **v7.0.0 (2023-09-29)**. It is **OpenVR, not
OpenXR** (`External_OpenVR.cmake`, no OpenXR dependency), so it cannot be our VR backend. It has **no
endoscopy simulation** — the colon example (`RenderingColon`) is a 280-line fly-through *rendering*
demo with no physics, collision or haptics.

Still a useful quarry (Apache-2.0, dead code, no support burden): PBD constraints, SDF haptics, the
collision-pair matrix, the device abstraction.

### 6.2 Fraxinus — the most important find

`gitlab.sintef.no/custusx/fraxinus` (mirror `SINTEFMedtek/Fraxinus`), SINTEF Medical Technology /
St. Olavs Hospital. **BSD-3-Clause**, actively maintained (**v26.09**, 2026-10-02; ~monthly; last push
2026-11-13), Ubuntu-first with prebuilt installers.

An open-source **image-guided bronchoscopy** platform with the exact pipeline: chest CT → AI
segmentation (Raidionics + TotalSegmentator) → click a target → **automatic optimal route through the
airway tree** → **virtual bronchoscopy fly-through** synced to CT cross-sections, including an **EBUS
simulator** → planning.

It has **no VR, no OpenXR, no haptics** — precisely our gap. Reuse its CT→airway-tree→centreline/route
outputs (export mesh + graph, consume in Godot) and the scope-view-synced-with-CT-slice presentation;
do not port CustusX/Qt.

### 6.3 SOFA + BeamAdapter — the closest open model of a flexible shaft

[SOFA](https://github.com/sofa-framework/sofa) is alive (1301★, LGPL-2.1, pushed 2026-11-12) but has
**no endoscopy examples and no VR at all**. Its
[BeamAdapter](https://github.com/sofa-framework/BeamAdapter) (**LGPL-2.1**, pushed 2026-11-11)
implements 1-D FEM on **Kirchhoff rod theory** explicitly for "catheters, guidewires or coils", with
collision against vessel triangulation — `3instruments_collis.scn` is three instruments colliding
inside a vessel, our exact topology.

**Use as a reference implementation, not a dependency**: either a separate physics process over IPC
(heavy, fragile) or reimplement the rod solver in a GDExtension (recommended).

### 6.4 The landscape is empty

GitHub search totals (2026-11-15): `bronchoscopy simulator` **1**, `virtual bronchoscopy` **5**,
`endoscopy simulator` **5**, `colonoscopy simulator` **5**, `flexible endoscope simulation` **1**,
`godot surgery simulation` **0**, `godot medical simulation` 4 (unrelated/0★), `openxr medical
simulation` **1**. No Godot medical-sim ecosystem exists: nothing to fork, nothing to compete with —
and no upstream to borrow fixes from.

**`OpenSurgiSim` appears not to exist** — zero GitHub/GitLab results, no DNS, no Crossref record.

---

## 7. Commercial VR bronchoscopy / medical training titles

Steam Store search API, 2026-11-15: **`bronchoscopy` → 0 results**, `endoscopy` → 0, `medical
training` → 0. None of the major surgical-VR vendors ship on Steam (`Osso VR`, `FundamentalVR`,
`PrecisionOS`, `Touch Surgery`, `Simbionix` → 0 each). The only medical-VR-adjacent Steam titles found
are **Windows-only** (`linux: false`): Medicalholodeck (2017), Wraith VR TKA (2019), VR TKA Surgery
Simulator (Early Access 2024), Marion Surgical Robot Simulator (2025). Linux looks unoccupied — a
sample of four, not proof. The **Meta Quest Store could not be enumerated** (JS-only, no
unauthenticated API): no claim made either way.

**BRONCH Mentor** (Simbionix → 3D Systems → **Surgical Science**) is the dominant commercial
bronchoscopy simulator and is current
([surgicalscience.com](https://surgicalscience.com/systems/bronch-mentor/)); desktop + proprietary
haptics. Its engine and any VR claim are **[unverified]** — do not assert Unity or Unreal.

Notably, **ORSIM** — the market-leading bronchoscopy trainer — advertises **sensor-only** insertion
measurement with no haptic/force claim. So non-haptic is commercially sufficient; haptics is a
differentiator, not an entry ticket.

---

## 8. Risk table

| # | Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- | --- |
| R1 | **90 Hz unachievable** on the 890M for the intended scene | Medium | High | Design to §3 budgets; scale 0.7–1.0×; single merged mesh; **measure in week 1** on real hardware. Fallback: 72 Hz. |
| R2 | **Monado 6DoF silently degrades to 3DoF** (no SURVIVE, no STEAMVR_LH) | Medium | High | Assert 6DoF pose at startup; document `STEAMVR_LH_ENABLE=true` or libsurvive as a hard requirement. |
| R3 | **Monado regressions** (no stable tag since 2025-12) | Medium | Medium | Pin a known-good commit in the Envision dev profile; keep a tested SteamVR path; app stays runtime-agnostic. |
| R4 | **Runtime choice disagreement in the docs** (SteamVR-primary vs Monado-primary) | High — already true | Low-medium | Resolve explicitly (§1.4): OpenXR-only app, Monado/Envision as documented default, SteamVR as tested fallback. |
| R5 | **Contributor cannot run it** (no headset, no Steam, no Monado in apt) | High | High | Ship a flat-screen mode; document the Envision AppImage explicitly; state that apt has no Monado/Godot 4. |
| R6 | **Airway mesh licence contamination** (CT-derived = derivative work) | Medium | High | Ship BodyParts3D or BronchSim (both CC BY 4.0); keep patient-CT meshes out of the repo; never ship CC BY-NC-SA. |
| R7 | **BodyParts3D surfaces are open, not watertight** | High | Low-medium | Budget a mesh-repair step (hole fill / union / shell) before lumen use; known task, not a blocker. |
| R8 | **Godot XR bugs bite the design** (FSR black screen #66994; SubViewport corruption #75229) | Medium | Medium | Never enable FSR in XR; prototype scope-feed-via-SubViewport early; fallback to a texture on a quad. |
| R9 | **Vive-tracker action map trap in Godot** (`handheld_object` omitted) | High if DIY tracker used | Medium | Custom action map or `chest` role; pin engine version (wrist/ankle only via PR #108511). |
| R10 | **Lighthouse is legacy** (Index listed discontinued; OG Vive is 2016) | High | Medium | Target OpenXR generally; Vive as compatibility floor; avoid Lighthouse-specific features. |
| R11 | **DIY haptic hardware stalls** | Medium | Medium | v1 ships wand rumble only; input abstraction so a motorised prop can be added without touching case logic. |
| R12 | **Performance guidance is community-sourced, not vendor** | Medium | Low | Treat §3 as starting budgets; validate with GPU timestamps; re-check after each Mesa/Monado upgrade. |
| R13 | **No public bronchoscopy video corpus** (no Cholec80 equivalent) | High | Medium | Plan self-capture or synthetic mucosa; do not promise metric validation from public video. |
| R14 | **Scope physics is the hard part**, not rendering | High | High | Budget most engineering on shaft model + collision (§5); reimplement BeamAdapter's approach in a GDExtension. |

---

## 9. Uncertain / verify-yourself list

**Runtime**
* SteamVR 2.15 release date — community thread, not Valve's changelog.
* Valve Index "discontinued" — Wikipedia navbox; verify with Valve.
* Whether Godot's `VRS_XR` density map survives through Monado on a wired Vive — untested here.
* Whether current Chrome/Chromium WebXR-on-Linux is usable with a Vive — not verified.
* Whether SteamVR advertises `XR_HTCX_vive_tracker_interaction` — dump extension list before relying on it.

**Engines**
* UE5's exact Linux VR status — Epic's XR docs are JS-rendered; treated as "no known supported path".
* Unity's 2026 licensing chatter — community reporting only, and moot given the platform gap.

**Assets / datasets** — full list in `medical-3d-assets.md` and `prior-art-vr-bronchoscopy.md`:
Hamlyn (site unreachable), Cataract-101 (official site 404s), EndoVis/SCARED licence text (registration
required), Fraxinus third-party bundle terms (Elastix/Raidionics/TotalSegmentator not audited).

**Performance**
* All §3 numbers are **[estimate]** from cited hardware limits, not measured on this scene. The first
  sprint task should be a 90 Hz spike test, on this machine, with this headset.
