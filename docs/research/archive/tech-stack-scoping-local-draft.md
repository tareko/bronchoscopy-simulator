# Technical stack scoping: VR bronchoscopy simulator on Linux

**Research date:** 2026-11-15. Every "current" claim below is as of that date.
**Target:** original HTC Vive (wand controllers, Lighthouse 1.0), Ubuntu 26.04, AMD Radeon 890M
(RDNA 3.5, 16 CU), 61 GB unified RAM. Secondary goal: other OpenXR headsets.
**Scope:** runtime, engine, performance budget, anatomy assets, haptics/kinematics, prior art,
commercial titles — plus a risk table.

**How to read this.** Claims backed by a fetched source are linked. Numbers I derived are marked
**[estimate]** with the method. Things I could not verify are marked **[unverified]** and collected
in §8. The Linux VR stack changes monthly; several sources are community wikis, not vendor docs.

**Two things worth knowing up front:**

1. I verified the target hardware empirically, on this machine, not from spec sheets:
   `AMD Radeon 890M Graphics (radeonsi, strix1, ACO, DRM 3.64)`, Mesa **26.0.8**, Vulkan **1.4.341**,
   unified memory. `VK_KHR_fragment_shading_rate` (rev 2), `VK_EXT_direct_mode_display` and
   `VK_KHR_present_wait` are all present — so hardware variable-rate shading and Monado's direct
   mode are both available here.
2. Ubuntu 26.04 ships the OpenXR loader (`libopenxr-loader1` 1.1.47) but **no Monado, no WiVRn,
   no Envision, and no Godot 4** (`godot3` 3.6.2 is the only Godot in the archive). Runtime and
   engine both come from outside apt. Plan for that in contributor docs.

---

## 0. Recommendations at a glance

| Question | Recommendation | Confidence |
| --- | --- | --- |
| VR runtime | Write a pure **OpenXR** app; run it on **Monado via Envision**. SteamVR as documented fallback. | High for the app, medium for the dev-setup default |
| Engine | **Godot 4.7.x**, **Mobile renderer**, `godot-xr-tools`, built-in OpenXR | High |
| Perf target | 90 Hz / 11.11 ms; **0.7–1.0×** render scale; ≤300 draw calls; ≤300k visible tris | Medium — must be measured |
| Foveated rendering | Fixed only (Godot VRS / compositor supersample). **No eye-tracked FR** on an OG Vive | High |
| Anatomy | **BodyParts3D** (CC BY 4.0) as the shipped base; CT pipeline (TotalSegmentator/nnU-Net + 3D Slicer/VMTK) for patient cases | Medium-high |
| Haptics v1 | Wand rumble + a **DIY motor-braked scope handle** (Vive Tracker + ESP32); skip commercial gloves | Medium |
| Scope kinematics | **Piecewise constant curvature + XPBD/collision**, not Cosserat, for real time | High |
| Reuse | **Fraxinus** (BSD-3) for CT→airway-tree→route planning; **godot-xr-tools** (MIT); **BeamAdapter** (LGPL-2.1) as a model to reimplement, not depend on | Medium-high |
| Avoid | Unity 6 (no Linux VR target), UE5 (no Linux VR path), iMSTK (sunset), WiVRn/ALVR (wireless only) | High |

---

## 1. VR runtime status on Linux, 2025–2026

### 1.1 What the hardware actually needs

The original Vive is a 2016 headset: 1080×1200 per eye, 90 Hz, ~110° nominal FOV, OLED, Lighthouse
1.0 tracking, and "wand" controllers
([Wikipedia: HTC Vive](https://en.wikipedia.org/wiki/HTC_Vive)). Linux support was added in
February 2017 on the SteamVR side.

The critical architectural fact for our project: **we do not need SteamVR at all.** SteamVR is only
required by apps that speak OpenVR (Valve's older API). A Godot/OpenXR app talks to whatever OpenXR
runtime is installed. That removes the single largest source of Linux VR pain from our dependency
graph.

### 1.2 The options, and what each is actually for

| Route | What it is | Relevance to a tethered Vive | Verdict |
| --- | --- | --- | --- |
| **Monado** ([docs](https://monado.pages.freedesktop.org/monado/)) | Open-source OpenXR runtime, BSL-1.0, Linux-first | Native. Drives Vive via `survive` (libsurvive) or `steamvr_lh` | **Recommended** |
| **Envision** ([GitLab](https://gitlab.com/gabmus/envision)) | AGPLv3 GUI orchestrator that builds/runs Monado + an OpenVR shim | The practical way to get Monado on Ubuntu | **Recommended** |
| **SteamVR for Linux** | Valve's native runtime | Works with Vive, but is Valve's lowest-priority platform | **Fallback only** |
| **WiVRn** ([site](https://wivrn.github.io/)) | GPL-3.0 Monado-based runtime that *streams* to standalone headsets | Not applicable — the Vive is tethered | N/A (matters only for Quest) |
| **ALVR** | Older wireless streaming stack | Largely superseded by WiVRn in this community | Not recommended |
| **xrizer** / OpenComposite | GPL-3.0 OpenVR→OpenXR translation layers | Only needed to run *Steam/OpenVR games* | **Not needed by us** |

That last row matters: the LVRA wiki warns application developers explicitly that these OpenVR
reimplementations are incomplete and that new software should use OpenXR directly
([xrizer page](https://vronlinux.org/docs/fossvr/xrizer/)). So the usual "you must install xrizer"
advice does not apply to our own build.

### 1.3 What the community consensus actually is (and where it disagrees)

The Linux VR Adventures wiki (last edited 2026-11-13) is blunt: for wired headsets "use Envision to
run or compile the latest Monado and xrizer", and SteamVR "is still an option, but we don't recommend
it… SteamVR for Linux is listed as a 'development release'; it is not intended for end-users. Expect
worse results" ([vronlinux.org](https://vronlinux.org/)). Its SteamVR page goes further: "the Linux
version is riddled with bugs, missing features and bad performance"
([SteamVR page](https://vronlinux.org/docs/steamvr/)).

**⚠️ This contradicts `linux-vr-stack.md` in this same folder**, which names SteamVR for Linux as the
*primary* runtime with Monado as fallback. Both positions are defensible, and the disagreement is
worth resolving deliberately rather than by accident:

* **For SteamVR:** it is Valve's own runtime, has the most complete Vive support, best-in-class
  Lighthouse tracking, and is the thing most VR users already have installed. An OG Vive has worked
  with it since 2017.
* **For Monado:** it is open source (auditable, scriptable, packageable), lighter on the GPU
  (matters on a 16-CU iGPU), has no account/login dependency, and is the only route a contributor
  without a Vive licence can debug. It is also what the community that actually runs Linux VR
  recommends today.

**My recommendation:** the *application* is runtime-agnostic (pure OpenXR — this is the real
decision, and it is low-risk either way). For the *documented default developer setup*, prefer
Monado+Envision, and ship a working SteamVR path as a documented alternative. Rationale: our app is
the only thing we control, and a contributor who can `git clone` and run without Steam is a
contributor retained. Do not hard-code either one.

### 1.4 Monado specifics you must know

From the [LVRA Monado page](https://vronlinux.org/docs/fossvr/monado/):

* **Lighthouse tracking:** `STEAMVR_LH_ENABLE=true` makes Monado use SteamVR's lighthouse driver
  (better tracking than libsurvive, but it loads SteamVR's proprietary driver files — SteamVR must be
  *installed*, not running). Envision sets this for you. The fully-FOSS alternative is the `survive`
  driver built on [libsurvive](https://github.com/collabora/libsurvive) (**MIT**), which is what
  Monado uses natively.
* **No hotplug.** "You must turn on all your devices before starting Monado." Power the headset,
  both wands and any tracker first.
* **Run SteamVR Room Setup once** to fix floor height, even if you then use Monado.
* **AMD + reprojection needs a capability:** the compute compositor wants
  `CAP_SYS_NICE` on `monado-service` (`sudo setcap CAP_SYS_NICE=eip …`). Envision and the AUR package
  do this automatically; a hand-built Monado will not.
* **Disable SteamVR auto-launch** (`power.autoLaunchSteamVROnButtonPress = false`) or SteamVR will
  start and fight Monado for the hardware whenever a wand wakes up.

Release reality check: the latest **tagged** Monado is **v25.1.0 (2025-12-09)**, while `main` gets
commits daily (GitLab API: last activity 2026-11-15). LVRA's Envision page says the quiet part out
loud — distro "stable" packages "quickly become out-of-date and so are unsuitable for most setups",
which is why the AppImage with **development profiles** (builds Monado from source) is the
recommended path ([Envision page](https://vronlinux.org/docs/fossvr/envision/)).

### 1.5 SteamVR specifics, if you use it

* SteamVR **2.15** appears to have shipped around 2026-03-26 (community release-notes thread
  **[unverified — community-maintained]**).
* For an OpenXR app launched *through Steam*, you need
  `PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1 %command%` because the Steam Linux Runtime container
  does not expose OpenXR by default ([LVRA](https://vronlinux.org/docs/fossvr/monado/)). This does
  **not** apply if you launch the app directly from a shell — another reason to make the direct
  launch the documented default.
* SteamVR's room setup app is bug-prone; LVRA documents a "quick calibration" (put headset and
  controllers on the floor at the centre, then Settings → Developer → Room and Tracking) that works
  in both SteamVR and Envision.

### 1.6 The 2026 landscape change: Steam Frame

Valve's **Steam Frame** launched 2026-09-14/18 at $1,059–1,299, running **SteamOS on ARM64**
(Snapdragon 8 Gen 3), 2160×2160 per eye, with eye tracking and "foveated streaming"
([Wikipedia: Steam Frame](https://en.wikipedia.org/wiki/Steam_Frame)). Two consequences:

* SteamVR is once again being actively developed **for Linux** — but for ARM64 standalone, not
  primarily for x86 desktops with 2016-era Lighthouse hardware. Do not read the Steam Frame work as
  a revival of desktop Linux SteamVR quality.
* The same Wikipedia article now lists the **Valve Index under "Discontinued"**. Treat Lighthouse as
  a legacy input path **[unverified — verify against Valve's store before relying on it]**. This
  strengthens the case for keeping everything OpenXR-generic: our Vive support is a compatibility
  floor, not a platform bet.

---

## 2. Engine options

### 2.1 Godot 4 (recommended)

| Fact | Detail |
| --- | --- |
| Licence | **MIT** |
| Current stable | **4.7.2** (2026-08-18) ([GitHub releases API](https://api.github.com/repos/godotengine/godot/releases)) |
| OpenXR | Built in, not a plugin — "out of the box support for OpenXR… desktop headsets like the Valve Index" ([feature list](https://docs.godotengine.org/en/stable/about/list_of_features.html)) |
| Renderer for VR | "**Mobile** renderer for any desktop VR project… XR projects will run with the Forward+ renderer, but it isn't well optimized for XR right now" ([setting up XR](https://docs.godotengine.org/en/stable/tutorials/xr/setting_up_xr.html)) |
| `godot-xr-tools` | **MIT**, 749★, releases 4.5.2 (2026-10-08) and 4.6.0-dev2; last commit 2026-10-10 ([repo](https://github.com/GodotVR/godot-xr-tools)) |
| `godot_openxr_vendors` | **MIT**, 198★, pushed 2026-11-10 — but this is for **Android vendor** extensions (Meta/Pico/Magic Leap). Not needed for desktop VR ([docs](https://godotvr.github.io/godot_openxr_vendors/)) |
| VRS / fixed foveation | Supported; "AMD RDNA2 and newer (both integrated and dedicated)" ([VRS docs](https://docs.godotengine.org/en/stable/tutorials/3d/variable_rate_shading.html)) — the 890M qualifies, and `VK_KHR_fragment_shading_rate` is present on this machine |

Why it wins for a small open-source project: a single self-contained editor binary with no account,
no licence server, no seat management and no install approval chain; MIT throughout so contributions
are unencumbered; GDScript lowers the barrier for clinician-contributors who are not professional
developers; and the XR tooling has a long-term maintainer (Bastiaan Olij) and is genuinely active.
Building from source is only needed if a contributor wants engine changes.

Known Godot XR rough edges (all open issues, verified via GitHub API 2026-11-15):

* **#66994** "Vulkan: Enabling FSR and XR results in a black screen" — open since 2023. **Do not use
  FSR in XR.**
* **#75229** "subviewport image corruption with XR" — open since 2023. Directly relevant, because
  the endoscope-camera-view-into-a-monitor design wants a `SubViewport`. Budget time to test this
  early.
* **#124135** `XR_MND_headless` support — open. Would help CI/headless testing on Monado.

### 2.2 Unity 6 — not viable on Linux

The decisive fact is in Unity's own OpenXR documentation: the runtime support table lists **Windows
64-bit (DX11), Android arm64/x64, and UWP** — there is **no Linux build target** for the OpenXR
plugin ([Unity OpenXR manual](https://docs.unity3d.com/Packages/com.unity.xr.openxr@1.19/manual/index.html)).
The same page lists foveated rendering among the things "Unity does not yet provide out-of-the-box".

So a Unity Linux VR build is not a supported configuration. Secondary problems for an open-source
project: the engine is proprietary and closed, so contributors must install Unity Hub, create an
account and accept a licence just to read the code; diffs are binary `.unity`/`.prefab` YAML that
merge badly; and licence terms must be re-checked each cycle. (Unity's 2026 licensing chatter about
a "4% of revenue" fee appears to be an **Enterprise-tier** condition for very large organisations,
not something that hits a small open-source project — **[unverified, community reporting only]**,
but irrelevant here since the platform support already rules it out.)

### 2.3 Bevy — promising, too immature for VR UI

`bevy_mod_openxr` (dual MIT/Apache-2.0) is real and maintained: **0.6.0 released 2026-06-20**, 425★,
6 open issues, ~22k total downloads ([crates.io](https://crates.io/crates/bevy_mod_openxr),
[repo](https://github.com/awtterpip/bevy_oxr)). But it is a thin OpenXR binding, not an XR
application framework: there is no equivalent of godot-xr-tools' locomotion, grab/throw, pointers,
hands or UI. Bevy's own UI is not designed for in-world VR panels, and Bevy breaks API on most
releases, so every engine upgrade is a contributor-tax. For a medical training tool with a dense
debrief UI, this is the wrong trade.

### 2.4 StereoKit — viable, but a one-maintainer risk

MIT, 1.1k★, and genuinely Linux-friendly: it ships Linux x64 binaries in the NuGet package and
supports "Monado, and essentially everywhere OpenXR is"; needs the .NET 9 SDK, and `dotnet new
sk-multi` gives a running app in minutes
([repo](https://github.com/StereoKit/StereoKit),
[getting started](https://stereokit.net/Pages/Guides/Getting-Started.html)). It even has a flat-screen
simulator for contributors without a headset, which is genuinely attractive.

Against it: 141 open issues against a very small core team, a C#/.NET toolchain that is a heavier
ask for clinician-contributors than Godot's editor, no scene-editor workflow (everything is code),
and a much smaller ecosystem to hire/borrow from. Reasonable second choice; Godot is the safer
default.

### 2.5 Unreal Engine 5 — not viable on Linux for VR

UE5 ships Linux binaries and supports packaging Linux games, but Epic's XR support is oriented to
Win64 and Android (Quest); VR Preview and the OpenXR path are not a supported Linux configuration,
and the editor on Linux generally means building from source. **[unverified — Epic's XR docs page is
JS-rendered and I could not extract a platform table; treat as "no known supported Linux VR path"
rather than "proven impossible".]** For a small team this is disqualifying on build time alone: UE5
source builds are hours, not minutes, and contributors would need a Epic account and ~100 GB.

### 2.6 WebXR / three.js — not for the primary build

WebXR would be the lightest-weight distribution story, but on Linux desktop it is a poor fit:

* **Wolvic**, the open-source XR browser, targets "AOSP-based, stand-alone XR systems and HarmonyOS
  tethered systems" only — Quest, Pico, Lynx, Magic Leap ([wolvic.com](https://wolvic.com/)). There
  is no desktop-Linux build.
* Chrome/Chromium on Linux can do WebXR through an OpenXR runtime, but this is a second-class path
  with a thin debugging story and no way to see the actual swapchain behaviour. **[unverified for
  current Chrome version.]**
* Meta/Oculus-style WebXR gamepad mapping for Vive wands is limited, and we would lose the ability to
  read raw controller state we need for instrument handling.

Verdict: not the primary target. Worth revisiting later as a "no-install demo" if the core ships.

### 2.7 Recommendation

**Godot 4.7.x + Mobile renderer + built-in OpenXR + `godot-xr-tools` (MIT), with the airway rendered
as a single procedurally generated mesh.**

Because it is the only option that is simultaneously: MIT-licensed end to end, fully supported for
Linux desktop OpenXR today, editable by a clinician without a licence server, and light enough to
have a chance at 90 Hz on a 16-CU iGPU. Unity is excluded by platform support; UE5 by build cost;
Bevy by missing XR interaction infrastructure; StereoKit is a credible alternate but concentrates
risk in one maintainer.

---

## 3. Performance realities on a Radeon 890M

### 3.1 The actual budget

Verified hardware (AMD spec page + local `vulkaninfo`/`glxinfo`):

| Parameter | Value | Source |
| --- | --- | --- |
| GPU | Radeon 890M, **16 CUs**, 2900 MHz | [AMD Ryzen AI 9 HX 370 specs](https://www.amd.com/en/products/processors/laptop/ryzen/ai-300-series/amd-ryzen-ai-9-hx-370.html) |
| Memory | LPDDR5X-8000, **2 channels**, shared with CPU | same |
| Measured driver | Mesa 26.0.8, RADV (`radeonsi, strix1, ACO`) | local |
| Panel | 1080×1200/eye, 90 Hz → **2.59 Mpix/frame, 233 Mpix/s** | [Wikipedia](https://en.wikipedia.org/wiki/HTC_Vive) |

The binding constraint is **memory bandwidth, not VRAM**. At ~128 GB/s shared and 90 Hz, everything
the machine does per frame — rendering, compositor, reprojection, CPU traffic — must fit in roughly
**1.4 GB/frame** **[estimate: 128 GB/s ÷ 90 Hz]**. That reframes the usual advice: on a 61 GB
unified-memory machine, *texture memory is nearly free*; *texture bandwidth and fill rate are not*.

Frame budget (11.11 ms), split **[estimate — to be validated with profiling]**:

| Slice | Target | Why |
| --- | --- | --- |
| App GPU | ≤ 8 ms | Leaves room for Monado's compositor + reprojection on the same 16 CUs |
| App CPU | ≤ 6 ms | Leaves room for compositor pacing; Godot's Vulkan submission is single-threaded per view |
| Compositor | ~2–3 ms | LVRA advises iGPU users to raise `U_PACING_COMP_MIN_TIME_MS` into "the double digits" if stutter persists |

That compositor note is important and easy to miss: on weak GPUs the fix is not "render less", it is
giving the compositor more headroom — `U_PACING_COMP_MIN_TIME_MS=8` (or higher) in the Monado
environment ([LVRA performance page](https://vronlinux.org/docs/performance/)).

### 3.2 Budgets for the target scene (procedural tube geometry)

Starting budgets to design against, then measure:

| Resource | Budget | Notes |
| --- | --- | --- |
| Draw calls | **≤ 300** target, 800 hard ceiling | **[estimate]** At ~5–10 µs CPU per draw on RADV, 500 draws ≈ 3–5 ms — most of the CPU budget. One merged airway mesh + a handful of instruments should land near 30–60. |
| Visible triangles | **≤ 300k/eye**, ~1M submitted | **[estimate]** 16 CUs handle vertex work cheaply; fill/overdraw is the real cost. A decimated bronchial tree is ~65k tris (see §4). |
| Materials / shaders | ≤ 10 unique, 1–2 texture atlases | Shader switches break batching; procedural geometry means you can bake almost everything into vertex colour + one atlas. |
| Texture set | ≤ 512 MB resident, streamed | Memory is cheap here; bandwidth is not. Prefer fewer, smaller, BC-compressed textures. |
| Overdraw | ≤ 2× average | Interior tube geometry is exactly the case where layered transparent surfaces kill an iGPU. |
| Lights | 1 headlight + 1 ambient; **no** real-time shadows | Godot Mobile renderer is deliberately limited; fake shadows with baked vertex AO. |
| Post-processing | none | Also: Godot's foveation is "disabled if post effects are used such as glow, bloom, or DOF" ([OpenXR settings](https://docs.godotengine.org/en/stable/tutorials/xr/openxr_settings.html)). |

### 3.3 Foveated rendering: what is actually available

Be precise about this, because marketing claims confuse three different things:

* **Eye-tracked foveated rendering: not available.** The OG Vive has no eye tracking. Fixed FR only.
  Eye-tracked FR needs a Vive Pro Eye, PSVR2, or Steam Frame.
* **Fixed foveated rendering via VRS: available in principle.** Hardware supports it (RDNA2+,
  confirmed extension present on this machine), and Godot exposes it — for Mobile/Forward+ set
  `Viewport.vrs_mode = VRS_XR` ([docs](https://docs.godotengine.org/en/stable/tutorials/xr/openxr_settings.html)).
  Whether the density map is honoured end-to-end through Monado on a wired Vive is **[unverified]** —
  test it early, and treat it as an optimisation, never a requirement.
* **Compositor supersampling is the better lever.** LVRA explicitly recommends avoiding MSAA and
  instead raising Monado's compositor scale: "AA is found to increase the latency of delivered frames
  quite noticeably… far more than simple super sample"
  ([performance page](https://vronlinux.org/docs/performance/)). On an iGPU, dropping render scale to
  0.7–0.9× and letting the compositor upscale is usually a bigger win than VRS.

### 3.4 What to avoid (specific to this project)

* **The Forward+ renderer.** Godot's own docs say it is not well optimised for XR.
* **MSAA.** Costs bandwidth you do not have; use compositor supersampling instead.
* **FSR in XR.** Open Godot bug → black screen (#66994).
* **Per-frame mesh regeneration.** Build the airway `ArrayMesh` once at load with `SurfaceTool`;
  never rebuild per frame. This is the single biggest CPU trap for "procedural tube geometry".
* **Thousands of `MeshInstance3D` nodes for tube segments.** One merged mesh per airway tree; use
  `MultiMeshInstance3D` only for genuinely repeated props
  ([MultiMesh docs](https://docs.godotengine.org/en/stable/tutorials/optimization/using_multimesh.html)).
* **Runtime CSG.** Useful for prototyping; expensive in a frame loop. Bake to a mesh.
* **Transparent interior surfaces / heavy overdraw.** Two-sided tube walls with alpha will destroy
  fill rate. Render lumen interior with opaque backfaces.
* **Real-time GI, SSAO, SSR, volumetric fog, DOF, glow** — all off.
* **Trusting "it runs at 90" without measurement.** Use Monado's debug GUI + Vulkan timestamps; the
  iGPU shares bandwidth with the CPU, so editor-time smoothness predicts nothing.

---

## 4. Open anatomy / medical 3D assets

<!-- SECTION_PENDING_ASSETS -->

---

## 5. Haptics, input, and endoscope kinematics

<!-- SECTION_PENDING_HAPTICS -->

---

## 6. Existing open-source projects to learn from or reuse

Most of this section comes from a dedicated prior-art survey; the full 93-row table is in
`docs/research/prior-art-vr-bronchoscopy.md`. Headline findings, several of which **correct common
assumptions**:

### 6.1 iMSTK — sunset, and not what it was assumed to be

The Interactive Medical Simulation Toolkit (Apache-2.0) is **discontinued**: its README opens with a
"SUNSET NOTICE" dated 2025-05-02; the GitHub repo is an archived mirror; the canonical GitLab project
last released **v7.0.0 in 2023-09-29**. It is also **OpenVR-based, not OpenXR** (`External_OpenVR.cmake`,
no OpenXR dependency), so it cannot serve as a VR backend for us. And it has **no endoscopy
simulation**: the colon example (`RenderingColon`) is a 280-line fly-through *rendering* demo with no
physics, collision or haptics.

Still valuable as a quarry — Apache-2.0, dead code carries no support burden: PBD constraints, SDF
haptics, the collision-pair matrix, and the device abstraction.

### 6.2 Fraxinus — the most important find

`gitlab.sintef.no/custusx/fraxinus` (mirror `SINTEFMedtek/Fraxinus`), from SINTEF Medical Technology
/ St. Olavs Hospital. **BSD-3-Clause**, actively maintained (release **v26.09** on 2026-10-02, roughly
monthly, last push 2026-11-13), Ubuntu-first with prebuilt installers.

It is an open-source **image-guided bronchoscopy** platform with the exact pipeline we need:
chest CT → AI segmentation of airways/lungs/vessels/lymph nodes/tumours (Raidionics +
TotalSegmentator) → click a target → **automatic optimal route through the airway tree** → **virtual
bronchoscopy fly-through** synced to CT cross-sections, including an **EBUS simulator** → procedure
planning.

It has **no VR, no OpenXR and no haptics** — which is precisely the gap this project fills. Reuse the
CT→airway-tree→centreline/route outputs (export mesh + graph, consume in Godot), and the
scope-view-synced-with-CT-slice presentation, rather than porting CustusX/Qt.

### 6.3 SOFA + BeamAdapter — the closest open model of a flexible shaft

[SOFA](https://github.com/sofa-framework/sofa) is very much alive (1301★, LGPL-2.1, pushed
2026-11-12) but has **no endoscopy examples and no VR support at all**. Its
[BeamAdapter](https://github.com/sofa-framework/BeamAdapter) plugin (**LGPL-2.1**, pushed 2026-11-11)
implements 1-D FEM on **Kirchhoff rod theory** explicitly for "catheters, guidewires or coils", with
adaptive multi-tool deployment and collision against vessel triangulation — its
`3instruments_collis.scn` is three instruments colliding inside a vessel, i.e. our exact topology.

**Use it as a reference implementation, not a dependency.** Options are a separate physics process
over IPC (heavy, fragile) or reimplementing a rod solver in a GDExtension (recommended for a small
team).

### 6.4 Other reusable pieces

| Project | Licence | Use |
| --- | --- | --- |
| **BronchSim** (`andreajonas/bronchsimulator`) | **CC BY 4.0** | CT-derived, **labelled** airway mesh + centreline shipped as glTF (built with 3D Slicer + VMTK). Attribution only — fastest route to a credible airway asset. |
| **virtualendoscope** (`doitrous`) | MIT | Best open reference for real scope controls (insufflation, suction, irrigation, lens wash, circular optics). Web/JS. |
| **SlicerIGT** / Plus / ndicapi | BSD-3 / custom BSD / MIT | Tracking + calibration plumbing **if** we build a physical tracked handle. Irrelevant for pure OpenXR VR. |
| **VR-Caps** | **no licence file** | **Do not use** — no licence means all rights reserved; abandoned 2022. |

### 6.5 The landscape is empty — which is good news

GitHub search totals (2026-11-15): `bronchoscopy simulator` **1**, `virtual bronchoscopy` **5**,
`endoscopy simulator` **5**, `colonoscopy simulator` **5**, `flexible endoscope simulation` **1**,
`godot surgery simulation` **0**, `godot medical simulation` 4 (all unrelated/0★),
`openxr medical simulation` **1** (Unity, 1★).

**No Godot medical-simulation ecosystem exists.** There is nothing to fork and nothing to compete
with; the cost is that there is also no upstream to borrow fixes from.

**`OpenSurgiSim` appears not to exist** — zero GitHub/GitLab results, no DNS, no Crossref record.
Treat as non-existent unless someone produces a URL.

---

## 7. Commercial VR bronchoscopy / medical training titles

Verified via the Steam Store search API on 2026-11-15:

* Steam search for **`bronchoscopy` → 0 results**, **`endoscopy` → 0**, **`medical training` → 0**.
* None of the major surgical-VR vendors ship on Steam: `Osso VR`, `FundamentalVR`, `PrecisionOS`,
  `Touch Surgery`, `Simbionix` → 0 each.
* The only medical-VR-adjacent Steam titles found are **Windows-only** (`linux: false`):
  Medicalholodeck (2017), Wraith VR TKA (2019), VR TKA Surgery Simulator (Early Access 2024),
  Marion Surgical Robot Simulator (2025). Linux looks unoccupied — a sample of four, not proof.
* **Meta Quest Store could not be enumerated** (JS-only, no unauthenticated API): no claim made
  either way.

**BRONCH Mentor** (Simbionix → 3D Systems → **Surgical Science**) is the dominant commercial
bronchoscopy simulator and is still current
([surgicalscience.com](https://surgicalscience.com/systems/bronch-mentor/)). It is a desktop system
with proprietary haptics. Its engine and any VR claims are **[unverified]** — do not assert Unity or
Unreal.

Typical tech approach across this class of product (labelled inference; only parts evidenced):
CT → segmentation → surface mesh + centreline graph; scope pose as arc-length along the centreline
with a local bend model and lumen collisions; a pre-segmented anatomy library plus optional patient
CT import (exactly Fraxinus's verified flow); haptics on a separate kHz-loop with a motorised handle;
rendering with a headlight on the scope camera.

---

## 8. Risk table

| # | Risk | Likelihood | Impact | Mitigation / decision |
| --- | --- | --- | --- | --- |
| R1 | **90 Hz unachievable** on the 890M for the intended scene | Medium | High | Design to budgets in §3 from day one; render scale 0.7–1.0×; single merged airway mesh; **measure in week 1** on real hardware, not at the end. Fallback: 72 Hz / reduced FOV view. |
| R2 | **Monado unstable / regresses** (no stable release since 2025-12) | Medium | Medium | Pin a known-good Monado commit in Envision dev profile; keep a tested SteamVR path documented; app stays runtime-agnostic so the runtime is swappable. |
| R3 | **Sibling docs disagree on the runtime** (SteamVR-primary vs Monado-primary) | High (already true) | Low-medium | Resolve explicitly; my recommendation is OpenXR-only app + Monado/Envision as documented default + SteamVR as tested fallback. |
| R4 | **Contributor can't run it** (no headset, no Steam, no Monado on Ubuntu) | High | High | Ship a flat-screen mode (desktop window + mouse) like StereoKit's simulator; document Envision AppImage setup; no apt packages exist so the doc must be explicit. |
| R5 | **Airway mesh licence contamination** (CT-derived meshes are derivative works) | Medium | High | Ship BodyParts3D (CC BY 4.0) or BronchSim (CC BY 4.0) as the base; keep patient-CT-derived meshes **out** of the repo and out of shipped assets; never ship CC BY-NC-SA (Cholec80/T50). |
| R6 | **BodyParts3D surfaces are open, not watertight** (verified: 11,482 boundary edges) | High | Low-medium | Budget a mesh-repair step (hole fill / union / shell) before VR lumen use; it is a known cleanup task, not a blocker. |
| R7 | **iMSTK assumption baked into earlier docs** (it is sunset + OpenVR) | High (already true) | Medium | Remove iMSTK as a dependency; harvest Apache-2.0 algorithms only; correct `docs/02-architecture.md` if it leans on it. |
| R8 | **Godot XR bugs bite the design** (FSR black screen #66994, SubViewport corruption #75229) | Medium | Medium | Never enable FSR in XR; prototype the scope-camera-into-SubViewport path early; keep a fallback of rendering the scope feed as a texture on a quad. |
| R9 | **Eye-tracked foveation assumed but unavailable** on OG Vive | Medium | Low-medium | Fixed FR only; treat VRS as an optional optimisation; document clearly so nobody plans around it. |
| R10 | **Lighthouse hardware is legacy** (Index now listed discontinued; OG Vive is 2016) | High | Medium | Target OpenXR generally; keep the Vive as compatibility floor; do not build features that require Lighthouse specifics. |
| R11 | **DIY haptic hardware stalls** the interaction work | Medium | Medium | Ship v1 with wand rumble only; design an input abstraction so a motorised prop can be added later without touching case logic. |
| R12 | **Performance advice from wikis, not vendors** (LVRA is community-maintained) | Medium | Low | Treat §3 numbers as starting budgets; validate with GPU timestamps; re-check after each Mesa/Monado upgrade. |
| R13 | **No public bronchoscopy video corpus** (no Cholec80 equivalent) | High | Medium | Plan for self-capture or synthetic mucosa for realism/validation; do not promise metric validation from public video. |
| R14 | **Scope physics is the hard part**, not rendering | High | High | Budget most engineering on the shaft model + collisions (§5); reuse BeamAdapter's approach; keep the solver in a GDExtension, decoupled from case logic. |

---

## 9. Uncertain / verify-yourself list

Grouped honestly, so nothing here is mistaken for settled fact:

**Runtime**
* SteamVR 2.15 release date — community release-notes thread, not Valve's changelog.
* Valve Index "discontinued" status — Wikipedia's navbox; verify with Valve.
* Whether Godot's `VRS_XR` density map is honoured through Monado on a wired Vive — untested here.
* Whether Chrome/Chromium WebXR-on-Linux works acceptably with a Vive today — not verified.

**Engines**
* UE5's exact Linux VR support status — Epic's XR docs are JS-rendered; I could not extract a
  platform table. Treated as "no known supported path".
* Unity's 2026 licensing changes — community reporting only, and moot given the platform gap.

**Assets / datasets** — see §4 and `prior-art-vr-bronchoscopy.md` for the full list, including:
Hamlyn dataset (site unreachable), Cataract-101 (official site 404s), EndoVis/SCARED licence text
(registration definitely required), and Fraxinus's third-party bundle terms (Elastix/Raidionics/
TotalSegmentator not audited).

**Performance**
* All §3 numbers are **[estimate]** derived from cited hardware limits, not measured on this scene.
  The first sprint task should be a 90 Hz spike test, on this machine, in this headset.
