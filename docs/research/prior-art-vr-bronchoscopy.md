# Prior art: open-source VR bronchoscopy / flexible-endoscopy simulation

**Compiled 2026-11-15.** Target context: Linux, OpenXR, small team, open-source, Godot-based project.

## Method & confidence note

Findings below come from direct fetches of primary sources: GitHub REST API (`api.github.com`), GitLab API
(`gitlab.kitware.com`, `gitlab.sintef.no`), raw `README`/`LICENSE` files, official vendor pages, the Steam
Store JSON API, and the Harvard Dataverse API. **Star counts, issue counts and last-push dates are from the
GitHub/GitLab API responses fetched on 2026-11-15**, not from a rendered HTML page, so they are point-in-time
snapshots of the API, not of a page render.

**Tooling caveat that affects coverage:** the `web_search` tool in this environment returned unrelated/spam
results for every medical query, and DuckDuckGo/Brave/Bing HTML endpoints returned empty result sets or HTTP
429. So discovery was done through GitHub/GitLab search APIs plus known canonical URLs. This means:
- Coverage of **GitHub-hosted** projects is good (search API worked).
- Coverage of **non-GitHub web pages** is only as good as the URLs I guessed. Anything I could not reach is
  listed explicitly in [§8 Could not verify](#8-could-not-verify--uncertain).
- I did **not** browse the Meta Quest Store catalogue (see §7).

---

## 1. Master table

`Activity` = stars / last push or release, as of API fetch 2026-11-15. "Abandoned" = no push > 2 years or
explicit sunset notice.

### 1.1 Frameworks (the ones with real engineering behind them)

| Project | What it does | Licence (exact) | Activity / date | Reusable for us? | URL |
|---|---|---|---|---|---|
| **iMSTK** (Interactive Medical Simulation Toolkit) | C++ surgical-simulation toolkit: position-based dynamics (rigid/deformable/fluid, two-way), FEM, SPH, level-set, collision detection, 3D haptic rendering, VTK rendering, Unity/C# SWIG bindings | **Apache-2.0** | GitHub mirror `Kitware/iMSTK`: 38★, **archived**, last push 2025-05-02, 0 issues. Canonical GitLab `iMSTK/iMSTK`: 26★, 63 forks, last release **v7.0.0 (2023-09-29)**, last commits 2025-05-02. **SUNSET NOTICE: development discontinued as of 2025-05-02** | **Yes, as a code source (algorithm harvesting), not as a dependency.** Apache-2.0 lets us port modules into Godot GDExtension | [gitlab.kitware.com/iMSTK/iMSTK](https://gitlab.kitware.com/iMSTK/iMSTK) · [github.com/Kitware/iMSTK](https://github.com/Kitware/iMSTK) |
| **SOFA** | Real-time multi-physics FEM framework for medical simulation & robotics; plugin architecture; standalone `runSofa` + embeddable libraries | **LGPL-2.1** (README: "SOFA is LGPL, except: applications/projects (GPL), applications/tutorials (GPL), directories with a license file specifying a different license") | `sofa-framework/sofa` **1.3k★**, 371 forks, 27,655 commits, 351 open issues, last push **2026-11-12** | Partially: as a *physics service* or reference. LGPL + heavy dependency make it awkward to embed in a game engine | [github.com/sofa-framework/sofa](https://github.com/sofa-framework/sofa) |
| **BeamAdapter** (SOFA plugin) | 1-D FEM based on **Kirchhoff rod theory** — "simulate any 1D flexible structure, like catheters, guidewires or coils"; adaptive multi-tool concentric deployment; collision with vessel triangulation | **LGPL-2.1** | **36★**, 28 forks, 23 open issues, last push **2026-11-11** (active) | **Yes — highest-value physics reuse.** Closest open-source mechanical model of a flexible scope shaft | [github.com/sofa-framework/BeamAdapter](https://github.com/sofa-framework/BeamAdapter) |
| **BeamPlastic** (SOFA plugin) | Co-rotational elasto-**plastic** Timoshenko beam model (permanent deformation of tools) | LGPL-2.1 | 2★, last push 2025-04-07 | Marginal (plasticity not needed for scope) | [github.com/sofa-framework/BeamPlastic](https://github.com/sofa-framework/BeamPlastic) |
| **Sofa.IGTLink** | OpenIGTLink integration into SOFA (tracker/device streaming) | LGPL-2.1 | 3★, last push 2026-10-15 | Yes if we adopt SOFA | [github.com/sofa-framework/Sofa.IGTLink](https://github.com/sofa-framework/Sofa.IGTLink) |
| **SofaHapticAvatar** | Driver plugin for the Haptic Avatar device | LGPL-2.1 | 4★, last push 2026-10-05 | Only if we buy that hardware | [github.com/sofa-framework/SofaHapticAvatar](https://github.com/sofa-framework/SofaHapticAvatar) |
| **SofaGLFW** | Quick/simple SOFA GUI on GLFW + optional Dear ImGui | **LGPL-3.0** | 15★, last push 2026-11-14 | Reference for a lightweight (non-Qt) SOFA viewer | [github.com/sofa-framework/SofaGLFW](https://github.com/sofa-framework/SofaGLFW) |
| **SlicerIGT** | 3D Slicer extension modules for image-guided interventions: tracking, tool calibration, registration, workflow | **BSD-3-Clause** | **118★**, 80 forks, 35 open issues, last push **2026-09-28** (created 2012) | Yes for **tracker + calibration**, not for simulation | [github.com/SlicerIGT/SlicerIGT](https://github.com/SlicerIGT/SlicerIGT) |
| **Plus toolkit** (`PlusLib`/`PlusApp`) | Acquisition, calibration & real-time streaming for ultrasound-guided intervention; optical tracker drivers, stylus/frame calibration, OpenIGTLink server | **Custom BSD-style licence** ("The Plus license below is a BSD style license, with extensions to cover contributions…"), GitHub reports `NOASSERTION` | `PlusLib` **158★**, 118 forks, **122 open issues**, last push **2026-11-11**. `PlusApp` 21★, push 2026-07-09. `PlusBuild` 24★ | **Yes** for endoscope/tool calibration + tracking plumbing | [github.com/PlusToolkit/PlusLib](https://github.com/PlusToolkit/PlusLib) · [plustoolkit.org](http://www.plustoolkit.org) |
| **ndicapi** | NDI Polaris optical tracker driver | MIT | 62★, push 2026-09-08 | Yes if using NDI hardware | [github.com/PlusToolkit/ndicapi](https://github.com/PlusToolkit/ndicapi) |

### 1.2 The bronchoscopy-specific projects (the real prior art)

| Project | What it does | Licence (exact) | Activity / date | Reusable for us? | URL |
|---|---|---|---|---|---|
| **Fraxinus** (SINTEF Medical Technology / St. Olavs Hospital) | **Open-source image-guided bronchoscopy platform.** Full pipeline: (1) import chest CT → AI segmentation of airways, lungs, lymph nodes, vessels, tumours (Raidionics + TotalSegmentator); (2) click a target → **automatic optimal route through the airway tree**; (3) **virtual bronchoscopy fly-through** synchronised with CT cross-sections, incl. **EBUS simulator**; (4) procedure planning in 2D/3D. Built on CustusX; uses Elastix for registration | **BSD-3-Clause** ("Copyright (c) 2008-2026, St. Olav's University Hospital and SINTEF Digital"; file is `License.txt`) | GitHub mirror: **7★**, 3 forks, 0 open issues, last push **2026-11-13**. Canonical GitLab `custusx/fraxinus`: 2★, last activity 2026-11-13, **latest release v26.09 (2026-10-02)**, prior v26.08 (2026-08-31) → roughly monthly releases. Prebuilt installers for Ubuntu 22.04/24.04 + Windows | **YES — most valuable single project.** BSD-3, actively maintained, bronchoscopy-native, Linux-first | [gitlab.sintef.no/custusx/fraxinus](https://gitlab.sintef.no/custusx/fraxinus) · [github.com/SINTEFMedtek/Fraxinus](https://github.com/SINTEFMedtek/Fraxinus) · [docs](https://custusx.pages.sintef.no/Fraxinus/) |
| **CustusX** (base of Fraxinus) | Research platform for image-guided therapy (DICOM, tracking, navigation, ultrasound, live video) | **BSD-3-Clause** | **78★**, 6 open issues, last push **2026-11-13** | Yes as a reference architecture / DICOM+tracking layer | [github.com/SINTEFMedtek/CustusX](https://github.com/SINTEFMedtek/CustusX) |
| **BronchSim** (`andreajonas/bronchsimulator`) | "A free virtual bronchoscopy trainer": drive a scope through a **CT-derived airway**, trachea → carina → lobar/segmental bronchi; on-screen joystick, schematic map, anatomy/quiz mode. Ships as 3 static files: `index.html` (Three.js), `airway.data.js` (centreline + anatomy labels), `airway.model.js` (base64 glTF mesh) | **CC BY 4.0** ("BronchSim, Copyright (c) 2026 Andrea Jonas, MD (Stanford University School of Medicine)… Creative Commons Attribution 4.0 International") | 1★, last push **2026-08-01**; live at bronchsimulator.com | **Yes — very practical.** Airway mesh + labelled centreline usable in prototype with attribution. Web-only (no VR/haptics) | [github.com/andreajonas/bronchsimulator](https://github.com/andreajonas/bronchsimulator) · [bronchsimulator.com](https://bronchsimulator.com) |
| **BronchoX** (IAM-CVC) | DICOM-based virtual bronchoscopy software for airway navigation & biopsy planning (C++) | `NOASSERTION` (not verified) | 0★, last push 2026-10-01 | Maybe — unverified quality | [github.com/IAM-CVC/BronchoX](https://github.com/IAM-CVC/BronchoX) |
| **BronchOpt** | Synthetic bronchoscopy benchmark: sequences `bronch_real_aero1..15` with paired RGB, poses, depth, 3D meshes + evaluation framework | **Apache-2.0** | 8★, last push 2026-09-03 | Yes for **validation/ground truth**, not for rendering | [github.com/Soooooda69/BronchOpt](https://github.com/Soooooda69/BronchOpt) |
| **SynAirG** | "Generative Worlds for Adaptive Training of Bronchoscopy SLAM Models" (IROS 2026 SurgTwin) — synthetic bronchoscopy worlds | **Apache-2.0** | 1★, last push 2026-09-24 | Marginal (SLAM training) | [github.com/hcltech-robotics/synairg](https://github.com/hcltech-robotics/synairg) |
| **BronchoDrift** | Synthetic CT-to-body divergence generator for bronchoscopy navigation + interactive viewer | none detected | 2★, last push 2026-07-20 | Marginal (realism of CT-to-body divergence) | [github.com/FadiZahar/BronchoDrift](https://github.com/FadiZahar/BronchoDrift) |
| **Bronchoscopy-Simulator-RL-testing-demo** | VTK-based simple bronchoscope-handle-controlled endoscope sim + PPO RL training loop | **none** (no licence file) | 0★, created 2026-06-15, last push 2026-06-16 | **No** (unlicensed) — reference only | [github.com/Easy1over/Bronchoscopy-Simulator-RL-testing-demo](https://github.com/Easy1over/Bronchoscopy-Simulator-RL-testing-demo) |
| **BronchoscopySim** | Unknown/minimal | none | 0★, push 2025-06-10 | No | [github.com/BibBig-Bob/BronchoscopySim](https://github.com/BibBig-Bob/BronchoscopySim) |
| **virtual-bronchoscopy** | Python/ParaView script generating a virtual bronchoscopy video from neonatal MR UTE images | none | 3★, push **2023-01-15** (stale) | Small: ParaView camera-path recipe | [github.com/deepgandhi95/virtual-bronchoscopy](https://github.com/deepgandhi95/virtual-bronchoscopy) |
| **Visually_Navigated_Bronchoscopy** (SNRLab) | GAN-based depth estimation for bronchoscopy visual navigation (MedIA 2021); releases ex-vivo bronchoscopic image dataset | `NOASSERTION` | 6★, last push **2026-11-14** | Dataset yes (CC BY-SA 4.0); code licence unclear | [github.com/SNRLab/Visually_Navigated_Bronchoscopy](https://github.com/SNRLab/Visually_Navigated_Bronchoscopy) |
| **CT-Bronchial-Branch-Tracing** | 3D Slicer workflow for CT-derived virtual bronchoscopy + bronchial branch tracing | Apache-2.0 | 0★, push 2026-10-06 | Maybe (Slicer-based) | [github.com/ttoma1068/CT-Bronchial-Branch-Tracing](https://github.com/ttoma1068/CT-Bronchial-Branch-Tracing) |
| **bronchoscopy-dataset-and-benchmark** (SIRGLab) | Real bronchoscopy video + feature-based visual-odometry benchmark (IROS'23), PySLAM harness | **GPL-3.0** (repo) | 16★, 3 issues, last push 2024-03-19 | Dataset yes (terms unclear); GPL code contaminates | [github.com/SIRGLab/bronchoscopy-dataset-and-benchmark](https://github.com/SIRGLab/bronchoscopy-dataset-and-benchmark) |

### 1.3 Endoscopy/colonoscopy simulators found on GitHub

| Project | What it does | Licence (exact) | Activity / date | Reusable? | URL |
|---|---|---|---|---|---|
| **VR-Caps** (`VirtualCapsuleEndoscopy`) | Unity environment for **active capsule endoscopy**: synthetic data generation, pose/depth estimation, area coverage, autonomous navigation, magnetic-field capsule control, super-resolution | **NO LICENCE** — repo has only `README.md`; GitHub licence = none ⇒ all rights reserved by default | **210★**, 52 forks, 10 open issues, last push **2022-06-23** → **abandoned (~4.5 yrs)** | **No — legally unusable.** Study the design only | [github.com/CapsuleEndoscope/VirtualCapsuleEndoscopy](https://github.com/CapsuleEndoscope/VirtualCapsuleEndoscopy) |
| **Endora** | "Video Generation Models as Endoscopy Simulators" (MICCAI 2024) — generative video, not interactive | **none** | **149★**, 3 issues, last push 2026-02-04 | No (unlicensed, and it's video generation) | [github.com/CUHK-AIM-Group/Endora](https://github.com/CUHK-AIM-Group/Endora) |
| **EndoSLAM** | Endoscopic SLAM dataset + unsupervised monocular VO/depth method (capsule & standard endoscopy) | **MIT** (code) | **309★**, last push 2022-06-21 | Dataset/code yes (MIT) | [github.com/CapsuleEndoscope/EndoSLAM](https://github.com/CapsuleEndoscope/EndoSLAM) |
| **Virtual Endoscope** (`doitrous`) | Browser-based upper-GI endoscopy **teaching prototype**: guided oesophagus→duodenum route, independent viewing direction, **insufflation/suction/irrigation/lens-wash**, visible motility, circular optics/illumination, 20 normal/disease views, real-image comparison galleries | **MIT** | 2★, 2 issues, last push **2026-10-13** | **Yes as a UX reference** — closest open-source feature set to real scope controls. Web/JS, no VR | [github.com/doitrous/virtualendoscope](https://github.com/doitrous/virtualendoscope) |
| `IlmunIslam/vr-colon`, `Stomach_URP`, `Stomach_HDRP`, `StomachFolds_HDRP` | Unity 6 HDRP/URP stomach & colon visualisation, "first-person scope navigation", decimated rugae meshes | **MIT** | 0★ each, pushes 2026-07-16 … 2026-09-04 | Small: Unity scope-navigation pattern + MIT mesh/scripts | [vr-colon](https://github.com/IlmunIslam/vr-colon) |
| `3abra14/upper-gi-endoscopy-simulator` | "High-fidelity Upper GI Endoscopy Simulator — React Three Fiber + GLSL shaders" | none | 0★, push 2026-05-21 | No (unlicensed) | [github](https://github.com/3abra14/upper-gi-endoscopy-simulator) |
| `ktj9279/CapsuleEndoscopy_Simulator` | C++ capsule endoscopy sim | none | 1★, push **2017-09-27** | No (dead, unlicensed) | — |
| `dcasbol/HysTrainer` | Hysteroscopy VR trainer prototype w/ Simball 4D device | `NOASSERTION` | 1★, push **2014-04-04** | No (dead) | — |

### 1.4 Named candidates from the brief — existence check (definitive)

| Name asked about | Verdict |
|---|---|
| `VR-Caps` | **Exists** — see §1.3. Unity, no licence, abandoned 2022. |
| `EndoVis` | Not a simulator; it is the MICCAI **endoscopic vision challenge** series (datasets/benchmarks). See §6. |
| `SimEndo` | **Not found** on GitHub. No verifiable project. |
| `BronchoscopySimulator` | **No repo of that name.** Closest: `Bronchoscopy-Simulator-RL-testing-demo` (0★, unlicensed) and `BibBig-Bob/BronchoscopySim` (0★). |
| `MedSim` | **Not a real project.** GitHub hits are unrelated student apps (`dhchenx/MedSim3D` 4★, 2022; `pianojet/medsim` 3★, 2017). |
| `SurgicalSIM` | **Not a real project.** 8 hits, all ≤2★ toys/demos (`evansneath/surgicalsim` 2★, 2014). |
| `VRMed` | **Not found** as a medical-simulation repo. |
| `OpenMBEE` | **Exists but irrelevant** — `Open-MBEE/*` is Model-Based Systems Engineering tooling (SysML v2, Cameo/MagicDraw sync). Nothing medical. |
| `OpenSurgiSim` | **Could not verify existence at all.** GitHub search `OpenSurgiSim` → **total_count 0**; GitLab.com project search → empty; `opensurgisim.org/.com/.in` → no DNS/connection; Crossref bibliographic query → no items. Treat as non-existent or private unless someone produces a URL. |
| Godot-based medical/endoscopy sims | **None found.** GitHub search `godot medical simulation` → 4 hits, all 0★ unrelated; `godot surgery simulation` → **total 0**. |
| OpenXR + Godot medical sims | **None found.** `openxr medical simulation` → 1 hit (`sambhav302005-coder/XR-Medical-Tabletop`, 1★, **Unity** OpenXR, 2026-05-06). |

**Implication:** there is **no Godot medical-simulation ecosystem at all**. If we build in Godot, we are the first;
nothing to lean on, but nothing to compete with either.

---

## 2. The three projects genuinely worth learning from / reusing

### #1 — Fraxinus (BSD-3-Clause, active, bronchoscopy-native) → reuse the *pipeline*, not the renderer

This is the only actively maintained open-source project that solves the actual bronchoscopy problem, and its
licence is the most permissive of the serious candidates.

**Verified capabilities** (from `README.md`, fetched 2026-11-15):
1. Import chest CT → AI segmentation of airways/lungs/lymph nodes/vessels/tumours via **Raidionics** +
   **TotalSegmentator**.
2. Click a target in the CT → **automatically computes the optimal route through the airway tree**.
3. **Virtual bronchoscopy fly-through** on the segmented airway tree, synchronised with CT cross-sections,
   including an **EBUS simulator**.
4. Combined 2D/3D procedure-planning review.

**What to reuse concretely**
- **The CT→airway-tree→route planning stage.** This is the expensive, clinically-credible part and it is
  engine-agnostic in principle. Export the segmented airway surface mesh + the centreline/route as a graph, then
  consume it in Godot. That is exactly the data `BronchSim` already ships as `airway.data.js` + a glTF mesh.
- **The concept of synchronising the endoscopic view with CT cross-sections** — a strong training affordance we
  should copy (split view: scope camera + CT slice at scope tip position).
- **The EBUS simulator concept** for later expansion (EBUS-TBNA is a core bronchoscopy skill).
- **The AI segmentation stack choices** are documented and both components are open source, so we can call them
  from our own tooling rather than reverse-engineering Fraxinus internals.

**What *not* to reuse:** the CustusX/Qt desktop architecture and its OpenGL viewer. It is not VR, has no OpenXR,
and porting it is more work than building a Godot viewer around its outputs. Fraxinus `README` contains **no
mention of VR, OpenXR, Oculus, SteamVR or haptics** (grep verified). Fraxinus is a *planning/rehearsal* tool, not
an immersive simulator — which is precisely the gap our project fills.

**Caveat:** BSD-3-Clause is permissive, but the repo bundles/links third-party components with their own terms
(Elastix, Raidionics, TotalSegmentator, CustusX). Check each before shipping. Also note its disclaimer: research
tool, **not** FDA/CE approved.

### #2 — BeamAdapter (LGPL-2.1) → reuse the *flexible-shaft physics*

A bronchoscope is a long flexible shaft that buckles, transmits torque, and whose tip bends under a pull-wire.
That is a Cosserat/Kirchhoff rod problem, and BeamAdapter is the most mature open implementation of it that is
still alive.

**Verified**: "1-dimensional FEM based on the **Kirchhoff rod theory** … simulate any 1D flexible structure, like
catheters, guidewires or coils"; adaptive implementation for "interactive deployment of one or several concentric
tools"; designed for "interventional radiology … catheter deployment". Last push **2026-11-11**, 36★, 23 open
issues. Examples include `3instruments_collis.scn` — three instruments deployed **in a vessel triangulation
structure with collisions** — i.e. exactly our topology (a rod inside a branching tubular mesh).

**What to reuse**
- The **rod formulation + adaptive beam discretisation** (beam length adapts as the tool advances — essential for
  insertion, where you cannot pre-mesh the whole scope).
- The **collision response of a rod against a triangulated lumen** — this is the hard part of endoscopy haptics.
- Its **regression-tested scenes** as a validation oracle for our own implementation.

**Two honest options.** (a) Link SOFA+BeamAdapter as a separate physics process and stream tip pose/contact
forces to Godot over IPC — cleanest for LGPL compliance (LGPL-2.1 permits this if the library stays replaceable).
(b) **Read the source and re-implement the rod solver in C++/GDExtension** — LGPL allows studying it, but
re-implementing avoids shipping LGPL binaries. For a small team, (b) is usually less work than fighting SOFA's
build/ABI.

**Caveat:** BeamAdapter requires SOFA, and SOFA plugins are compiled against a specific installed SOFA (ABI
coupling). Expect version-matching pain.

### #3 — iMSTK (Apache-2.0) → reuse *algorithms and the haptics/VR integration pattern*, not the framework

Apache-2.0 is the cleanest licence here for a small open-source team, and iMSTK contains a lot of directly
relevant, well-tested machinery — but **the project is dead**, so it is a quarry, not a dependency.

**Verified state**: `Kitware/iMSTK` on GitHub is an **archived mirror** (38★, last push 2025-05-02, 0 issues).
The canonical repo is GitLab (26★, 63 forks), latest release **v7.0.0, 2023-09-29**. The README opens with:
> *"**SUNSET NOTICE** — Support and development of Interactive Medical Simulation Toolkit (iMSTK) has been
> discontinued as of May-02-2025. This project is no longer under active development or support."*

Last substantive commits: 2025-02-25 (CI only); the final commit is literally the sunset-notice README edit.

**What to reuse**
- **PBD constraint/scene design** — iMSTK's unified position-based dynamics handles two-way rigid↔deformable↔fluid
  interaction, which is what a scope-tip-pressing-on-mucosa needs (FEM/SPH/LSM/RBD in iMSTK are one-way only,
  per the docs).
- **Collision detection algorithms and the "collision matrix"** of which geometry pairs are supported — a useful
  specification to port (surface-mesh↔surface-mesh, SDF↔mesh, etc.).
- **SDF-based haptic rendering** (`SDFHaptics` example) — the standard technique for stable 6-DOF force feedback
  at high servo rates.
- **Device abstraction**: `DeviceManagerFactory`/`DeviceClient` covering 3D Systems Touch (OpenHaptics), Haply
  Inverse3, and VRPN trackers — a good model for our input layer.
- **The VR integration pattern** (see below) and the Unity/C# SWIG binding approach if we ever add a C# path.

**VR support — the critical correction:** iMSTK uses **OpenVR (SteamVR), not OpenXR.**
`CMake/External/External_OpenVR.cmake` is present; there is **no OpenXR dependency**. VR access is via the VTK
OpenVR render window: `viewer->getVRDeviceClient(OPENVR_RIGHT_CONTROLLER)` (left/right/hmd variants), per the
official docs. So iMSTK cannot be reused as an OpenXR backend; it is only a reference for how to wire head +
controller poses into a simulation loop.

**Build difficulty on Linux — moderate, mostly waiting:** CMake **superbuild** (it checks out, builds and links
all deps, incl. VTK, Assimp, Eigen, VRPN). Prereqs are light
(`build-essential libgl1-mesa-dev libxt-dev libusb-1.0-0-dev git-lfs`, CMake ≥3.15); `git-lfs` is mandatory for
example/test data. Build with `cmake ../iMSTK && make -j4` or Ninja. Because it is sunset, expect stale
dependency pins to break against modern compilers/distros — build it in a container pinned to ~2023 toolchains.

**Note on the brief's premise:** iMSTK does **not** contain an endoscopy or colonoscopy *simulation* example.
`Examples/` contains 24 directories; the colon-related one is `RenderingColon`, which is a **fly-through rendering
demo only** — it advances a camera along a `catmullRom` spline with a spotlight attached to the eye
(`RenderingColonExample.cpp`, 280 lines; no `PbdModel`, no collision, no haptics). VR is represented by
`VRLapToolControl` (laparoscopic tool control). This is a factual correction worth carrying forward.

**Honourable mention — BronchSim (CC BY 4.0):** for a small team this may be the fastest path to a credible
airway. It is a CC BY 4.0 licensed, CT-derived, **labelled** airway mesh + centreline, already packaged as
`airway.model.js` (base64 glTF) and `airway.data.js`, made with 3D Slicer + VMTK. Attribution is the only
obligation. Caveat: it is one patient's anatomy, single-author, 1★, and the anatomical labelling is only
"reviewed for accuracy" by the author, not clinically validated.

---

## 3. SOFA: detailed answers

- **Licence:** LGPL-2.1 (GitHub licence field + `LICENSE-LGPL.md`). **Exceptions:** `applications/projects` and
  `applications/tutorials` are **GPL**; any directory with its own licence file overrides. `SofaGLFW` is
  **LGPL-3.0**, not 2.1.
- **Activity:** 1.3k★, 371 forks, 27,655 commits, **351 open issues**, 97 open PRs, last push **2026-11-12**.
  The ecosystem is genuinely alive: `SofaPython3` 66★ (2026-11-13), `SofaGLFW` 15★ (2026-11-14), plugins
  refreshed 2026-10-15 in bulk.
- **BeamAdapter:** see §2. Kirchhoff rods; catheter/guidewire/coil deployment; last push 2026-11-11.
- **Endoscopy/colonoscopy examples: none.** `examples/` contains `Component`, `Demos`, `Objects`, `SimpleAPI`,
  `Tutorials`, `Benchmark`, `Validation` etc.; filtering those listings for `endosc|colon|catheter|beam` produced
  **nothing**. The only interventional scenarios are BeamAdapter's interventional-radiology catheter scenes
  (`3instruments*.scn`, `SingleBeamDeployment*.scn`).
- **VR support: none in the current ecosystem.** I enumerated all **67** repos in the `sofa-framework` GitHub org
  and filtered for `vr|openvr|openxr|haptic|igtl`: the only hits are `SofaHapticAvatar` (device driver) and
  `Sofa.IGTLink` (tracking). There is **no OpenXR or OpenVR viewer plugin**. `SofaVRViewer` and `SofaOpenVR` do
  not exist on GitHub (search `total_count` 0 for both). Historically there were Oculus-DK2-era viewers, but I
  could not verify any surviving one — treat "SOFA has VR" as false today.
- **Build difficulty on Linux: low via Pixi, high manually.** Official guidance: SOFA "policy is to support only
  the latest Ubuntu LTS". Fast path needs only Git + Pixi
  (`git clone` then `pixi run -e supported-plugins runSofa`). Manual path wants GCC ≥7 / Clang ≥5,
  `build-essential`, and the full dependency list; plugins (incl. BeamAdapter) are then built **separately
  against the installed SOFA**, which is the main source of friction.

---

## 4. SlicerIGT / Plus: tracking, ultrasound, calibration

Both are **image-guided-intervention plumbing, not simulators** — worth integrating only for the tracking layer.

- **SlicerIGT** (BSD-3-Clause, 118★, 35 open issues, push 2026-09-28, since 2012): 3D Slicer modules for
  tracked interventions. What we'd want: **stylus/pivot and frame calibration**, transform handling, registration,
  and workflow state machine.
- **Plus toolkit** (`PlusLib` 158★, 122 open issues, push 2026-11-11): the acquisition/calibration daemon.
  Provides optical-tracker drivers (incl. NDI), **tool calibration algorithms**, and an **OpenIGTLink** server that
  any client (Godot included) can subscribe to for live tool poses. Licence is a **BSD-style licence with
  contribution extensions** (hence `NOASSERTION`) — read `License.txt` before shipping; it is BSD-3-like in
  effect but adds a contribution agreement.
- **Relevance to an endoscope tracker:** high, for a *physical* scope. Plus can calibrate the scope's camera
  intrinsics + a rigid body on the handle, then stream pose over OpenIGTLink. Two caveats: (a) it is built for
  ultrasound/IGT workflows and its config is XML-heavy; (b) 122 open issues signals thin maintainer bandwidth.
- **For VR, none of this is needed** — OpenXR gives you the head/controller pose directly. Plus/SlicerIGT only
  pays off if we add real-instrument tracking (e.g. a tracked physical bronchoscope handle, which is how the
  commercial simulators do it).

---

## 5. GitHub sweep summary (what the landscape actually looks like)

Searches run via GitHub search API on 2026-11-15, with total hit counts:

| Query | Total | Verdict |
|---|---|---|
| `bronchoscopy simulator` | **1** | One 0★ unlicensed demo. |
| `bronchoscopy` | 72 | Thin; best hits are Fraxinus (7★), SIRGLab dataset (16★), BronchOpt (8★). |
| `virtual bronchoscopy` | **5** | All ≤3★ except none. |
| `endoscopy simulator` | **5** | Best: Endora 149★ (unlicensed, video-gen), virtualendoscope 2★ (MIT). |
| `colonoscopy simulator` | **5** | All 0★ toys. |
| `flexible endoscope simulation` | **1** | 0★. |
| `endoscopy unity` | 7 | VR-Caps 210★ dominates; rest 0★. |
| `godot surgery simulation` | **0** | Empty. |
| `godot medical simulation` | 4 | All 0★, unrelated. |
| `openxr medical simulation` | **1** | 1★ Unity project. |
| `VR-Caps capsule endoscopy` | 2 | VR-Caps + one RL paper. |

**Conclusion:** the open-source flexible-endoscopy-simulation space is effectively **empty** — the two substantial
artefacts (VR-Caps 210★, EndoSLAM 309★) are research dataset generators from 2022 and one has **no licence**. The
only serious, maintained, *clinical-pipeline* project is **Fraxinus**, and it is planning software rather than an
immersive simulator. Languages seen: C++ (SOFA/Fraxinus/iMSTK/CustusX), C#/Unity (VR-Caps, IlmunIslam), JS/Three.js
(BronchSim, virtualendoscope), Python (datasets/SLAM). **No Godot project anywhere.**

---

## 6. Surgical video datasets — and the bronchoscopy gap

| Dataset | Content | Licence | Access | Relevance |
|---|---|---|---|---|
| **Cholec80** (CAMMA, Strasbourg) | 80 laparoscopic cholecystectomy videos, phase/tool annotations | **CC BY-NC-SA 4.0** (stated on CAMMA datasets page; the page also says it "has been released under license CC-BY-NC-SA 4.0 and can be downloaded here") | Request/download via [camma.unistra.fr/datasets](https://camma.unistra.fr/datasets/) | Texture + workflow realism reference. **NC + SA ⇒ cannot ship commercially** |
| **CholecT50** (CAMMA) | 50 cholecystectomy videos, 1 fps, `<instrument, verb, target>` action triplets, tool-tip boxes for 5 videos | **CC BY-NC-SA 4.0** — explicit in [CAMMA-public/cholect50](https://github.com/CAMMA-public/cholect50): "released for public use under CC BY-NC-SA 4.0… cannot be used for commercial purposes… redistributed under the same license" | Download via that repo (registration) | Action-recognition training; also a labelling-scheme model for our skill metrics |
| **CholecTrack20 / Endoscapes / MultiBypass140 / SSG-VQA / SAGES-CVS** (CAMMA) | Tool tracking, scene segmentation + CVS assessment, bypass phases, surgical VQA | Each has its own terms on CAMMA pages (not individually verified) | Per-dataset pages | Lower priority for bronchoscopy |
| **EndoSLAM** | Capsule + standard endoscopy recordings, 10 organs, with pose/depth ground truth | **MIT** for the code repo; dataset terms not stated separately | [github.com/CapsuleEndoscope/EndoSLAM](https://github.com/CapsuleEndoscope/EndoSLAM) | Good for synthetic-vs-real validation methodology |
| **SCARED** (EndoVis 2019 sub-challenge) | Stereo endoscopic video + registered CT point clouds, ex-vivo/phantom | Per-challenge EndoVis terms — **not verified** | [endovissub2019-scared.grand-challenge.org](https://endovissub2019-scared.grand-challenge.org/) (registration) | Best analogue for "camera inside a tubular organ with CT ground truth" — closest methodological match to bronchoscopy |
| **EndoVis (MICCAI)** | Umbrella benchmark series (e.g. FetReg — placental vessel segmentation/registration); registration-based | Per-sub-challenge; **not verified** | [endovis.grand-challenge.org](https://endovis.grand-challenge.org/) | Benchmark methodology |
| **Hamlyn Centre endoscopic video** | Classic handheld endoscopic video sequences | **Could not verify** — `hamlyn.doc.ic.ac.uk` did not respond from this environment | — | — |
| **Cataract-101** | 101 cataract surgery videos, phase labels | **Could not verify** — `cataract-101.github.io` returns **404**; only a third-party mirror (`matinmoqadas/Cataract-101`, 1★, no licence) exists | — | Low (different domain) |
| **AutoLaparo** (MICCAI'22) | Hysterectomy videos, multi-task (phase, tool, automation) | Repo `ziyiwangx/AutoLaparo` (21★) has **no licence**; dataset terms on `AutoLaparo.github.io` not verified | Registration | Moderate |
| **SurgToolLoc** (MICCAI 2022/2023, SurgVU 2025) | Endoscopic surgical tool localisation challenge data | Example repos generally **no licence**; data via challenge registration — **not verified** | Registration | Tool-detection methodology |

### Does a bronchoscopy-specific video dataset exist? **Yes — small ones. No large corpus.**

- **`SIRGLab/bronchoscopy-dataset-and-benchmark`** (IROS'23) — **real bronchoscopy video** with visual-odometry
  benchmark; repo **GPL-3.0**, 16★, last push 2024-03-19; data distributed via a Google Drive link in the README.
  The **dataset's own licence is not stated** separately from the GPL code — treat as unclear.
- **Ex-vivo Bronchoscopic Images for Visual Navigation** (Banach et al., MedIA 2021) — ex-vivo bronchoscopic image
  sequences for depth/navigation; **CC BY-SA 4.0**, verified via Harvard Dataverse API
  (`doi:10.7910/DVN/8MNI49`, version 2). **This is the cleanest licensed bronchoscopy image dataset I found.**
- **Synthetic** (not video of patients, but usable for validation): **BronchOpt** (Apache-2.0, RGB+depth+pose+mesh,
  15 sequences), **SynAirG** (Apache-2.0), **BronchoDrift** (no licence).
- **There is no public bronchoscopy video corpus comparable to Cholec80/CholecT50** — no multi-centre,
  thousands-of-frames, annotated airway-procedure dataset surfaced in any search. This is a real gap, and it also
  means we cannot train/validate skill metrics from public bronchoscopy video the way laparoscopy projects can.

**Licence consequence for us:** every large surgical video dataset found is **CC BY-NC-SA 4.0** (non-commercial +
share-alike). They are fine for internal research/validation and for studying realism, but they **cannot** be
baked into shipped textures or a commercial build, and share-alike would infect derivative datasets. For shippable
textures we need either our own captures, CC0/CC BY assets, or procedural/synthetic mucosa.

---

## 7. Commercial / Steam / Quest landscape

### Steam (verified via the Steam Store JSON API, 2026-11-15)

| Search term | Result |
|---|---|
| `bronchoscopy` | **0 results** |
| `endoscopy` | **0 results** |
| `medical training` | **0 results** |
| `surgery` | Ghost Productions *Wraith VR Total Knee Replacement* (appid 1136210, 2019-10-01), *VR TKA Surgery Simulator* (Kliniker, appid 2651810, Early Access, 2024-01-04), *Marion Surgical Robot Simulator* (appid 3457580, 2025-02-18), plus irrelevant games |
| `Osso VR`, `FundamentalVR`, `PrecisionOS`, `Touch Surgery`, `Simbionix` | **0 results each** — none of the major surgical-VR vendors ship on Steam |
| `anatomy` | Several anatomy viewers: *Medicalholodeck* (appid 754010, 2017-12-02, **Windows only**), *The Body VR*, *VR Anatomy*, *Vesalii Anatomy VR Student* |

**Verified:** all these titles list **Windows only** in `platforms` — **no Linux build of any medical VR title on
Steam.** (Relevant to us: our Linux-first positioning is unoccupied on Steam.)

### Commercial vendors

| Vendor / product | Status as verified | Platform / engine | Notes |
|---|---|---|---|
| **BRONCH Mentor** (Simbionix → 3D Systems → **Surgical Science**) | **Exists and current** — `surgicalscience.com/systems/bronch-mentor/` returns HTTP 200 ("BRONCH Mentor – brochure thank you"). Simbionix was acquired by Surgical Science | Desktop simulator with a proprietary haptic interface (historically Immersion/3D Systems devices). **Engine not disclosed** | The dominant commercial bronchoscopy simulator; the benchmark our project would be compared against. **I did not verify VR/engine claims** — do not assert them |
| **CAE Healthcare** (incl. EndoVR / Vimedix) | `cae.com/healthcare/` returns **HTTP 200 but a 404 page** — they restructured; current product URLs unverified | — | Could not verify EndoVR's current status |
| **Osso VR** | Site live (`ossovr.com`), enterprise VR surgical training, "Request pricing", "Custom Developed VR Modules" | VR (headset-based); engine undisclosed | Orthopaedic/general surgery focus, not bronchoscopy |
| **FundamentalVR** | Site live; **rebranded "Fundamental XR"**; markets "AR, AI, **Haptics**, Web & Apps, Virtual Reality" | VR + haptics | Haptics-led; relevant as a benchmark for feel |
| **PrecisionOS** | **Could not verify.** `precisionos.tech` → DNS failure; `precisionos.com` is an unrelated dental clinic | — | Do not cite without a working URL |
| **Touch Surgery** (Medtronic) | `touchsurgery.com` returns HTTP 200 but no usable content extracted (JS shell) | Mobile/web cognitive rehearsal, **not** VR | Different product category (procedure walkthroughs) |
| **Anatomage** | Site live — digital 3D anatomy tables | Anatomage Table hardware; not VR bronchoscopy | Not a competitor |
| **Fundamentals of Bronchoscopy / Bronchoscopy VR / GIBLIB / Simulab / Body Interact** | **Not verified.** No Steam presence; no verified product URL surfaced | — | Listed in the brief; I could not confirm they exist as named products |

### Meta Quest Store — **not verified**

`https://www.meta.com/experiences/search/?q=bronchoscopy` returns an HTTP 200 **JavaScript shell** (74 bytes of
text). The Quest catalogue has no unauthenticated public JSON API that I could find. Therefore **I cannot confirm
or deny** whether any bronchoscopy title exists on the Quest Store. Anyone citing Quest availability should check
manually in a browser. Everything above about Osso/FundamentalVR being "VR" comes from their own marketing sites,
not from store listings.

### What tech approach these products typically use — **inference, clearly labelled**

I could not obtain engineering detail from any vendor. The following is the *typical* architecture for this class
of product, inferred from (a) Fraxinus's verified pipeline, (b) BronchSim's verified construction method, and
(c) the general literature — **not** from vendor disclosures:

1. **Patient-specific CT** → airway segmentation → **surface mesh + centreline skeleton graph**.
2. Scope tip pose parameterised as **arc-length along the centreline** (a "rail" model) with a local bend/torque
   model; collisions resolved against the lumen mesh.
3. **Pre-segmented anatomy library** for generic cases, patient CT import for case-specific rehearsal (this is
   precisely Fraxinus's four-step flow, verified).
4. **Haptics** via a commercial 6-DOF force-feedback device or a motorised scope handle, running at ≫1 kHz
   separately from rendering (the SDF-haptics pattern iMSTK implements).
5. Rendering in **Unity or UE** (VR-Caps and the Unity medical demos confirm this is the default industry choice),
   with a headlight/spotlight attached to the scope camera — exactly what iMSTK's `RenderingColon` does.

**Flag:** points 2–4 are inference. Only points 1 and 5 are directly evidenced (Fraxinus/BronchSim, and
VR-Caps/iMSTK respectively).

---

## 8. Could not verify / uncertain

Ordered by how much it matters to us.

1. **OpenSurgiSim does not appear to exist.** GitHub search → 0 repos; GitLab.com search → empty; `.org/.com/.in`
   → no DNS; Crossref → nothing. **Either the name is wrong or the project is private.** Ask whoever supplied the
   name for a URL before spending more time.
2. **Meta Quest Store availability** — catalogue is a JS app with no unauthenticated API; **could not enumerate**.
   Includes whether any bronchoscopy/endoscopy title exists there at all.
3. **Hamlyn Centre endoscopic video dataset** — host unreachable from this environment (connection failure, not
   404). Licence and access procedure **unverified**.
4. **Cataract-101** — official site (`cataract-101.github.io`) returns **404**; licence and access **unverified**.
5. **SCARED / EndoVis dataset licences** — grand-challenge pages are JS apps and their per-challenge terms pages
   404'd on the paths I tried. Registration is definitely required; the exact licence text is **unverified**.
   The SCARED landing page did confirm the content (stereo video + registered CT models, ex-vivo/phantom).
6. **AutoLaparo / SurgToolLoc licences** — the GitHub mirrors carry **no licence file**; the datasets are
   registration-gated. **Unverified**.
7. **VR-Caps licensing intent** — repo has **no LICENSE file** at all (verified by listing its root contents:
   only `README.md` plus code). Legally that is "all rights reserved", regardless of the authors' intent. If we
   wanted it, we would have to ask the authors for a licence grant.
8. **iMSTK GitLab issue count / open-issue state** — the GitLab API returned `null` for `open_issues_count` and
   `license`; the licence is confirmed from `README.md` + Apache-2.0 headers in source files, and issues could not
   be counted (blob search and some endpoints require auth → `401 Unauthorized`).
9. **iMSTK "last activity" discrepancy** — GitLab `last_activity_at` says **2026-04-10**, but the newest *commit*
   is **2025-05-02** and the project is explicitly sunset. `last_activity_at` evidently counts non-code events
   (issues/web). Trust the commit date, not the activity field. This is a good example of why I quote commit dates.
10. **Fraxinus VR/haptics** — **no** VR/OpenXR/Oculus/SteamVR/haptic mention in its README (grep verified), but I
    did not audit its full docs site, so "no VR at all" is asserted only for the README-level description.
11. **CustusX/Fraxinus third-party bundle licensing** — the top-level licence is BSD-3-Clause, but Elastix,
    Raidionics, TotalSegmentator and any CustusX sub-components may carry different terms. Not audited.
12. **BronchSim anatomical validity** — labels "reviewed for anatomical accuracy" per its README, single author,
    1★; not clinically validated. Usable as a prototype asset, not as ground truth.
13. **Plus toolkit licence** — BSD-style with a contribution agreement; GitHub reports `NOASSERTION`. The
    `License.txt` I read is a BSD-3-style text plus a contribution agreement, but I did not read it in full.
14. **Commercial vendors' engines** — **no** primary source disclosed Unity/UE for BRONCH Mentor, Osso VR, or
    FundamentalVR. Any "they use Unity" claim is unsourced.
15. **PrecisionOS** — domain dead/mismatched; existence as a surgical-VR vendor **unverified**.
16. **CAE EndoVR / Vimedix current status** — CAE restructured its site; current product pages **unverified**.
17. **Steam star/review counts** — I used `storesearch`/`appdetails`, which do not return review counts, so I have
    no popularity metric for the Steam titles listed.

---

## 9. Bottom line for a Linux/OpenXR/Godot team

- **Nothing to fork.** There is no open-source VR bronchoscopy simulator to build on. The nearest artefacts are a
  desktop planning tool (Fraxinus), a dead toolkit (iMSTK), a physics plugin (BeamAdapter), and web toys
  (BronchSim, virtualendoscope). This is greenfield.
- **Reuse Fraxinus's pipeline outputs** (BSD-3): airway segmentation + centreline + route planning, consumed by a
  Godot viewer. Do not port CustusX.
- **Reuse BronchSim's airway asset** (CC BY 4.0) to get a credible labelled airway in-engine on day one.
- **Solve the flexible-shaft physics properly** — study BeamAdapter (LGPL-2.1) and either run it as a separate
  service or re-implement a Kirchhoff/Cosserat rod solver in a GDExtension. This, plus stable haptics, is the real
  engineering risk.
- **Harvest iMSTK (Apache-2.0) for PBD/collision/SDF-haptics** — permissively licensed and dead, so no support
  burden and no licence risk. Do **not** adopt it as a framework, and remember it is OpenVR, not OpenXR.
- **Licence hygiene:** Apache-2.0 + BSD-3 + MIT + CC BY 4.0 are safe to build on. LGPL-2.1 is fine if kept
  separable/replaceable. **CC BY-NC-SA 4.0 datasets (Cholec80, CholecT50) are research-only — never ship them.**
  VR-Caps and Endora have **no licence**: unusable without a written grant.
- **Expect no dataset to carry you.** The only clean bronchoscopy image set is one ex-vivo CC BY-SA 4.0 Dataverse
  release; there is no bronchoscopy Cholec80. Plan for self-capture or synthetic mucosa.
- **Linux + OpenXR looks unoccupied** — of the four medical VR titles I checked via `appdetails`, **all four** list
  Windows only (`linux:false`). That is a sample of four, not a proof that no medical VR title ships Linux.
