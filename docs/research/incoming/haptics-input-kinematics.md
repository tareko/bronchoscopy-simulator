# Haptics, Input and Real-Time Kinematics for an Open-Source VR Bronchoscopy Simulator

**Scope:** Linux + HTC Vive (lighthouse, wand controllers), Godot 4.x. Target 90 Hz.
**Research date:** 2026-11-15. Every claim links a source; where no primary source was found, the item is marked
**UNVERIFIED** or listed in §5 (Uncertain / verify).

---

## 0. Bottom line up front

1. **No commercial haptic glove can deliver what a bronchoscopy simulator most needs** — axial resistance and
   insertion depth along the scope shaft. Every shipping glove is either vibrotactile (bHaptics, Manus Metagloves Pro
   Haptic) or finger-scale kinesthetic (SenseGlove, Weart, HaptX, Dexmo) — i.e. forces measured in newtons *at the
   fingertips*, not tens of newtons along a 60 cm shaft ([bHaptics TactGlove](https://www.bhaptics.com/tactsuit/tactglove/),
   [Manus](https://www.manus-meta.com/products/metagloves-pro-haptic), [SenseGlove](https://senseglove.com/product/nova-2/)).
2. **Linux support is the binding constraint, and it is thin.** bHaptics' toolchain is Windows/macOS-only
   ([bHaptics docs](https://docs.bhaptics.com/)); SenseGlove ships a native Linux SDK/SenseCom but its **Unity** plugin is
   documented as Windows-only except for the legacy DK1 ([README](https://github.com/Adjuvo/SenseGlove-Unity)); Manus offers
   Linux only in its paid "MANUS Core + SDK Access" tier ([licence comparison](https://www.manus-meta.com/software)).
3. **OpenXR has no ratified mechanism for a custom force-feedback accessory.** Unextended OpenXR supports exactly one haptic
   type, `XrHapticVibration`, applied to an action of type `XR_ACTION_TYPE_VIBRATION_OUTPUT` bound to a device's
   `/output/haptic` path ([OpenXR 1.1 spec](https://registry.khronos.org/OpenXR/specs/1.1/html/xrspec.html)).
   `XR_EXT_haptic_parametric` (reg. no. 776, **not ratified**, last modified 2026-05-15) adds waveform streaming on *existing*
   haptic elements, not new device classes. → Any brake/motor controller must be driven over a **side channel**
   (USB CDC serial / HID), not OpenXR.
4. **A DIY scope controller is the practical route**, and there is direct precedent: the VTEST flexible-endoscopy simulator
   drives two spring-loaded friction wheels pinching the scope shaft with torque-controlled Maxon RE40 DC motors, measures
   insertion with optical encoders, and reports **5.62 N continuous translational force** and **0.190 N·m** torque
   ([IEEE ToH 2016, open access](https://pmc.ncbi.nlm.nih.gov/articles/PMC5026958/)). Measured requirements in that work:
   mean push **4.06 N**, mean pull **1.95 N**, nominal **5.5 N**, peak **25.2 N**; torque nominal 0.026 N·m, peak 0.214 N·m.
5. **Kinematics:** use a **hybrid** — XPBD/PBD chain for the passive shaft + constant-curvature (PCC) arc for the
   tendon-driven distal bending section, colliding against an **analytic spline-tube airway** (centreline + radius per
   station), not a triangle mesh. 24 segments, 4 substeps × 4 iterations, in C++ (GDExtension), is comfortably inside a
   90 Hz budget (estimate, §3.8).
6. **Rendering the scope view:** one extra mono `SubViewport` at 512²–640×480 is affordable; rendering it *stereo* and
   *full-rate with shadows* is not, on an iGPU (§3.9).

---

## 1. Commercial VR haptics / gloves, with Linux reality

### 1.1 Comparison table

| Device | Feedback type | Linux support | OpenXR? | Price | Verdict for bronchoscopy | URL |
|---|---|---|---|---|---|---|
| **bHaptics TactSuit Pro / Air** (vest) | Vibrotactile ERM/LRA only | **No** — Designer/Portal/SDK require "Windows 10+ (x64) or macOS … with bHaptics Player installed"; Player does not work under Wine | No (proprietary SDK: Unity, Unreal, Python, JS, Swift) | $565 (Pro) / $320 (Air) | Irrelevant: cannot produce axial resistance | [store](https://www.bhaptics.com/tactsuit/), [docs](https://docs.bhaptics.com/), [Linux field report](https://moonclaw.eu/posts/bhaptics-hardware-on-linux/) |
| **bHaptics TactSleeve** (arm) / Tactosy | Vibrotactile only | No (same Player app) | No | $225 | Same | [store](https://www.bhaptics.com/tactsuit/) |
| **bHaptics TactGlove DK3** | 7 independently amplitude-controlled LRAs | No | No | $385 | Same | [product](https://www.bhaptics.com/tactsuit/tactglove/) |
| **Manus Quantum Metagloves** | Tracking only, no force feedback | Claimed Windows 10/11 only for the product; Linux appears only in the paid SDK tier | "Open XR Integration" listed **only** in the "Core 3 + XR" licence | Quote only | **End-of-life** ("No longer in production") | [product](https://www.manus-meta.com/products/quantum-metagloves), [licences](https://www.manus-meta.com/software) |
| **Manus Metagloves Pro Haptic** | **Vibrotactile** (embedded actuators) + EMF tracking, 25 DoF | Windows-centric; Linux via "Core 3 + SDK Access" tier | XR tier only | Quote only | Fine finger data, no axial force | [product](https://www.manus-meta.com/products/metagloves-pro-haptic), [licences](https://www.manus-meta.com/software) |
| **SenseGlove Nova 2** | 4 magnetic **friction brakes** (thumb–ring), ≤20 N per finger + voice-coil vibrotactile + active palm strap | **Yes at native level**: SGCore/SGConnect for "Windows, Linux and Android"; SenseCom `x86_64` Linux binary (needs `dialout`). **But** Unity plugin README: "Linux support currently only working for the DK1 blue exoskeleton gloves". ROS 2 Jazzy on Ubuntu 24.04 supported | No native OpenXR device; pose comes from a **Vive Tracker 1.0/2.0/3.0** (SteamVR) mounted on the glove | €6,299 excl. VAT (Nova 2); Nova €4,999 → €3,999 promo | Finger-scale stiffness/size only; **cannot** resist shaft insertion | [product](https://senseglove.com/product/nova-2/), [compat](https://senseglove.gitlab.io/SenseGloveDocs/compatibility.html), [install](https://senseglove.gitlab.io/SenseGloveDocs/sensecom/install-instructions.html), [Unity README](https://github.com/Adjuvo/SenseGlove-Unity) |
| **SenseGlove Nova (1)** / **DK1** | Same brake principle (DK1 = exoskeleton linkage) | DK1 is the *only* glove with documented Unity-on-Linux support | No | €4,999 list | Same | [compat table](https://senseglove.gitlab.io/SenseGloveDocs/compatibility.html) |
| **Weart TouchDIVER Pro** | Servomotor-driven lever → fingertip **force feedback**, texture rendering, thermal 15–42 °C, 6 actuation points | **UNVERIFIED** — no OS statement found in SDK docs | No | Not published (webshop = "Order now", quote) | Fingertip only. G1 **discontinued** | [SDK](https://weart.it/our-technology/sdk/), [webshop](https://weart.it/webshop/) |
| **HaptX Gloves G1** | Pneumatic microfluidic skin displacement + force feedback (enterprise) | **UNVERIFIED** (site returned HTTP 502 during research) | No (HaptX SDK) | Not published; contact sales | Over-specified, closed, expensive | [haptx.com/products](https://haptx.com/products/) (nav lists G1 / Nexus NX1 / HaptX SDK) |
| **Dexmo** (Dexta Robotics) | Linkage-based force feedback, 5 fingers | **UNVERIFIED** (site JS-only) | No | UNVERIFIED (~$1.5–2k historically) | Not applicable | [dextarobotics.com](https://www.dextarobotics.com/) |
| **ContactGlove** (Diver-X) | Pneumatic "contact" haptics + tracking | **UNVERIFIED** (site unreachable: DNS/HTTP 000) | No | UNVERIFIED | Not applicable | — (could not fetch) |
| **Virtual Motion Labs** | Force-feedback exoskeleton gloves | **UNVERIFIED** (site unreachable) | No | UNVERIFIED | Not applicable | — |
| **CyberGlove III** | Tracking only | **UNVERIFIED** | No | UNVERIFIED (historically ~$10k+) | Not applicable | [cyberglovesystems.com](https://www.cyberglovesystems.com/) |
| **LucidGloves** (DIY, open source) | Servo tendon **finger** resistance + finger tracking | **Yes** — MCU firmware + OpenVR driver, no vendor app | **OpenVR, not OpenXR** (opengloves-driver) | ~$60–150 in parts (community estimate, unverified) | Wrong axis, but excellent prior-art for the *software* side | [lucidgloves](https://github.com/LucidVR/lucidgloves), [opengloves-driver](https://github.com/LucidVR/opengloves-driver) |
| **OpenFFBoard** (DIY, open source) | Universal **force-feedback** controller platform (BLDC/DC/stepper + encoders, USB HID FFB) | **Yes** (USB HID / CDC; host-side is OS-agnostic) | No — but has an explicit serial/HID command side channel | Board ~€40–90 (unverified) + motor | **The right software base** for a DIY scope brake | [repo](https://github.com/Ultrawipf/OpenFFBoard), [Ext FFB wiki](https://github.com/Ultrawipf/OpenFFBoard/wiki/External-FFB-mode) |
| **HTC Vive Tracker 3.0** | None (pose only) | **Yes** (SteamVR on Linux) | **Yes**, via `XR_HTCX_vive_tracker_interaction` | $129.99 (US page; structured data shows 149.0 — verify) | **Core of the recommendation** | [product](https://www.vive.com/us/accessory/tracker3/) |

### 1.2 Per-device notes that change the decision

**bHaptics.** Tactile only, and the ecosystem is closed: the "Player" app is a Windows/macOS prerequisite for even the
web-based Designer/Developer Portal ([docs](https://docs.bhaptics.com/)). On Linux the vendor path is dead — their software
"is Windows-only, and it doesn't work under Wine" ([field report, 2026-03](https://moonclaw.eu/posts/bhaptics-hardware-on-linux/)).
That report also documents the viable open workaround: a Rust reimplementation driving the vest over BLE (`freehaptics`), and
the existence of [senseshift-firmware](https://github.com/senseshift/senseshift-firmware) (GPL-3.0, 153★, pushed 2025-10-27)
which lets you *build* a device that speaks the bHaptics protocol. Note the protocol quirks found there: a 16-motor
TactSuit Air accepts 32 nibble values with duplicated motors, and games assume 40 points for the vest. Also relevant:
Godot has **no** bHaptics integration; the vendor SDKs target Unity/Unreal/Python/JS/Swift, and game integrations
are per-title (e.g. [FlyDangerous](https://github.com/jukibom/FlyDangerous) supports TactSuit/Tactosy). Verdict: **do not build the sim around bHaptics**; optionally
add it later as a "cue" channel (impact/thud on the chest) via a BLE side channel.

**SenseGlove.** The most interesting commercial option because it is *force* feedback and it ships real Linux binaries. Two
documented caveats matter: (a) Nova gloves have **no on-board positional sensors** — you must bolt a Vive Tracker to the glove
and the API has hard-coded mounts for Tracker 1.0/2.0/3.0 ([compatibility page](https://senseglove.gitlab.io/SenseGloveDocs/compatibility.html));
(b) the Unity plugin's own README says Linux works only for the DK1 ([README](https://github.com/Adjuvo/SenseGlove-Unity)),
which **contradicts** the docs' merged platform cell "Windows, Linux, Android" (docs last updated 18/09/2025). For a Godot
project you would use the **native C++ API** (SGConnect + SGCore, "Windows, Linux and Android") or the ROS 2 bridge, which
is a real integration project, not a drop-in. Price €6,299/glove set excl. VAT is also an order of magnitude above a DIY rig.

**Manus.** Best-in-class finger tracking, essentially irrelevant here: Metagloves Pro Haptic is vibrotactile only, and the
product family's OS matrix puts the base products on Windows 10/11, with Linux appearing only in the "MANUS Core 3 + SDK
Access" tier (C++ SDK, "MANUS Core 3 Integrated (Windows & Linux)") and OpenXR only in the XR tier
([licences](https://www.manus-meta.com/software)). Quantum is EOL. Note also the corporate context: Meta announced it would
acquire Manus in Dec 2025 ([Wikipedia](https://en.wikipedia.org/wiki/Manus_(AI_agent))) — a procurement risk for a long-lived
open-source project (**context flagged as secondary source**).

**Weart.** Genuinely multimodal (force + texture + thermal) and the SDK is Unity/Unreal + C#/C++ low-level API, with an
explicit "independence from other dependencies or frameworks" claim ([SDK page](https://weart.it/our-technology/sdk/)).
No OS/platform statement was found, and TouchDIVER G1 is discontinued ([webshop](https://weart.it/webshop/)). Treat Linux support
as **unknown** until the vendor answers in writing.

**HaptX / Dexmo / ContactGlove / VML / CyberGlove.** Not viable here: enterprise-quote pricing, closed SDKs, unverified or
absent Linux support, and — decisively — all of them act at the **hand/finger**, not along an instrument shaft. They are
listed for completeness; do not spend evaluation time on them for this project.

**"Open Bionics" — likely a wrong association in the brief.** Open Bionics is a **prosthetic-hand** company (Hero Arm),
not a VR glove: an open-source *bionic hand* lineage, not an input device. It offers nothing for haptics in a simulator;
the relevant open alternatives in this space are LucidGloves and SenseShift (below). (**UNVERIFIED** in the sense that I
did not fetch openbionics.com this session — but the category mismatch is unambiguous.)

**LucidGloves (the well-known DIY project).** MIT-licensed, 2,408★, last push 2025-10-29 → **active and healthy**
([repo](https://github.com/LucidVR/lucidgloves)). It is *finger* tracking + per-finger tendon resistance ("HapticSpool" parts),
using Arduino Nano or ESP32, USB serial/BLE, presented to SteamVR through
[opengloves-driver](https://github.com/LucidVR/opengloves-driver) (MIT, 525★, last push 2026-01-01 — mildly stale). Two
lessons for us: (i) the driver is **OpenVR**, not OpenXR, so it does not appear in a pure OpenXR app without SteamVR
translation (UNVERIFIED how reliably SteamVR surfaces OpenVR driver devices to OpenXR clients); (ii) the servo-tendon
architecture is the wrong axis for a scope, but the firmware/driver split (MCU ↔ host driver ↔ engine) is exactly the
pattern to copy.

### 1.3 The crux: what a bronchoscopy simulator actually needs from "haptics"

Physical truth of the procedure: the operator's hands are on a **handle**; the felt forces are (a) **axial insertion
resistance** along the insertion tube, (b) **torque** about the shaft when twisting, (c) the **angulation lever**'s
spring feel and end-stop, and (d) small **tactile** cues (wall scrape, secretions, instrument channel friction). Force
magnitudes are tens of newtons axially and tenths of N·m in torque (measured data in §2.6).

Assessment against that requirement:

| Device class | Axial insertion force | Shaft torque | Lever feel | Insertion depth sensing | Verdict |
|---|---|---|---|---|---|
| Vibrotactile (bHaptics, Manus Pro Haptic, TactGlove) | No | No | No | No | Cue channel only |
| Finger kinesthetic (SenseGlove, Weart, HaptX, Dexmo) | No (fingers only; ≤20 N/finger on SenseGlove) | No | No | No | Cannot emulate a scope |
| Glove + Vive Tracker (SenseGlove on Vive) | No | No | No | Pose only | Pose pipeline is reusable |
| **Custom brake/motor on the shaft + tracker** | **Yes** | **Yes** (via friction-wheel pair or a second axis) | Yes (spring/damper) | Yes (odometry from the drive wheel) | **Recommended** |

Useful corroborating evidence that force feedback is *worth* building for flexible endoscopy: a study with the
Endoscopic Operation Robot v3 found haptic feedback measurably useful when endoscopists manipulated a flexible endoscope
remotely ([Endoscopy International Open 2018](https://doi.org/10.1055/a-0655-7497)) — while noting the hardware burden.
Conversely, the market leader in bronchoscopy simulation, **ORSIM**, is explicitly a *sensor-only* design: "The sensor
registers movement of the insertion tube and translates this to a three-dimensional virtual airway"
([ORSIM design page](https://www.orsim.com/design)) — no haptic/force-feedback claim appears anywhere on their site
(checked `/`, `/design`, `/features`). So a non-haptic product is commercially sufficient; haptics is the differentiator,
not the entry ticket.

---

## 2. DIY haptic bronchoscope controller

### 2.1 Vive Tracker as the scope tracker (OpenXR facts)

**How a tracker is exposed in OpenXR.** Not as a controller: the tracker arrives through the vendor extension
`XR_HTCX_vive_tracker_interaction`, addressed by *role* paths
`/user/vive_tracker_htcx/role/<ROLE>` where `ROLE ∈ {handheld_object, left_foot, right_foot, left_shoulder,
right_shoulder, left_elbow, right_elbow, left_knee, right_knee, waist, chest, camera, keyboard, left_wrist, right_wrist,
left_ankle, right_ankle}` (wrist/ankle added in rev. 3). The role path "may be changed during the lifetime of instance" and
the runtime must send `XR_TYPE_EVENT_DATA_VIVE_TRACKER_CONNECTED_HTCX` when it does. Role assignment is done in the runtime's
UI (SteamVR → Settings → Controllers → "MANAGE TRACKERS")
([OpenXR 1.1 spec, XR_HTCX_vive_tracker_interaction](https://registry.khronos.org/OpenXR/specs/1.1/html/xrspec.html);
[Godot PR #58921 description](https://github.com/godotengine/godot/pull/58921)).

**Can a tracker be bound to a grip pose? Yes.** The interaction profile `/interaction_profiles/htc/vive_tracker_htcx`
supports `…/input/grip/pose` and `…/output/haptic`, plus `system/click` (may be unavailable), `menu/click`, `trigger/click`,
`trigger/value`, `squeeze/click`, `trackpad/{x,y,click,touch}` — same spec section. So:
`<tracker role path>/input/grip/pose` is a legitimate binding target, and `…/output/haptic` means the tracker can be
vibrated (it has a haptic actuator) — useful as a cheap "contact" cue.

**Godot specifics (verified in source, this is the trap):**
- Godot *does* support HTC trackers: `openxr_htc_vive_tracker_extension.cpp` requests
  `XR_HTCX_VIVE_TRACKER_INTERACTION_EXTENSION_NAME` and lists all role paths including `handheld_object`
  ([source](https://github.com/godotengine/godot/blob/master/modules/openxr/extensions/openxr_htc_vive_tracker_extension.cpp)).
- **But** the *default* action map deliberately **omits** `/user/vive_tracker_htcx/role/handheld_object` from both the
  `default_pose` and `haptic` actions, with the in-source comment `// "...handheld_object," <-- getting errors on this one.`
  ([openxr_action_map.cpp](https://github.com/godotengine/godot/blob/master/modules/openxr/action_map/openxr_action_map.cpp)).
  The same file also does **not** add an `/interaction_profiles/htc/vive_tracker_htcx` profile.
  In the extension file, the *metadata* registration of the handheld-object top-level path is commented out too, while
  `get_suggested_tracker_names()` still returns it first.
- Consequence: if you assign your scope tracker the `handheld_object` role, Godot's stock action map will not give you its
  pose. Two workarounds, both boring and reliable: (a) assign the tracker a role that *is* in the map (e.g. `chest`) and
  treat it as "the scope" — semantically ugly, functionally fine; or (b) author a **custom OpenXR action map** with an
  explicit `default_pose` subaction on `handheld_object` and a `vive_tracker_htcx` interaction profile binding
  `…/input/grip/pose`. Option (b) is the correct, upstream-friendly choice.
- Wrist/ankle role paths were only added to Godot's map in **PR #108511, merged 2025-07-15** (targeting 4.5)
  ([PR](https://github.com/godotengine/godot/pull/108511)) — i.e. this area is under active churn; pin your Godot version.
- Current stable Godot at time of writing: **4.7.2** (2026-08-18) ([releases](https://github.com/godotengine/godot/releases)).

**Tracker hardware (3.0):** 75 g, 70.9 × 79.0 × 44.1 mm, 7.5 h battery, 240° FOV, ships with dongle + USB-C cradle;
requires base stations; tracker count limited by free USB ports ([HTC spec](https://www.vive.com/us/accessory/tracker3/)).
The 240° FOV is the practical risk: a scope handle held low against the body can occlude; mount the tracker on the **top/outer
face** of the printed handle, and keep one wand controller as fallback input.

**Runtime choice on Linux.** Monado supports "HTC Vive, HTC Vive Pro, Valve Index (vive driver)" on Linux but describes
**3DoF** for the Vive HMD, with 6DoF only via the experimental Basalt path and only for Index
([Monado supported hardware](https://monado.freedesktop.org/)). For genuine 6DoF lighthouse tracking of a Vive + Trackers on
Linux the practical runtime is **SteamVR**, used as the app's OpenXR runtime. Whether SteamVR advertises
`XR_HTCX_vive_tracker_interaction` and how it maps a `handheld_object` role is **UNVERIFIED** — before writing code, run
`xrEnumerateInstanceExtensionProperties` and dump the current interaction profile per top-level path (§5).

### 2.2 Actuation: what research and commercial rigs actually use

| Rig / source | Actuator | Sensing | Reported capability |
|---|---|---|---|
| **VTEST** (RPI, flexible endoscopy/NOTES; IEEE ToH 2016) | 2× Maxon **RE40** DC motors (48 V, 0.187 N·m nominal, 0.796 N·m stall) driving **spring-loaded friction wheels** (Ø40 mm) that pinch the scope shaft; 3rd RE40 + 20-inch flexible shaft for rotation; Maxon **ESCON 50/5** torque-mode servo controllers | MicroE CE300-40 rotary encoders on the handle dials; HEDL 5540 (500 CPR) on the motors → linear/angular odometry | **5.62 N** max continuous translation, **0.190 N·m** rotation ([PMC5026958](https://pmc.ncbi.nlm.nih.gov/articles/PMC5026958/)) |
| **Passive-brake catheter interface** (ICCAS-SICE 2009) | "passive brake type. Solenoids and springs are used for force feedback… regulated by voltage change" — mounted on the **instrument channel port of a real endoscope handle** | — | Satisfactory force range for endoscopy per 3 expert endoscopists ([OpenAlex W2133193312](https://openalex.org/W2133193312)) |
| Pneumatic variant (ICCAS 2016) | Pneumatic haptic module for endoscope catheters | — | [DOI](https://doi.org/10.1109/ICCAS.2016.7832334) |
| 2-DoF GI endoscopy haptic interface (Adv. Robotics 2012) | Translation + rotation mechanism for insertion/rotation | — | [DOI](https://doi.org/10.1080/01691864.2012.703300) |
| Colonoscopy simulator w/ "folding guides" (Adv. Robotics 2006) | 2-DoF haptic device transmitting force **through a long flexible tube** | — | [DOI](https://doi.org/10.1163/156855306776014330) |
| Semi-passive injection device (2026) | Elastic element + motor, 0–40 N, ~32 mm stroke | — | [DOI](https://doi.org/10.1016/j.vrih.2026.07.005) |
| **ORSIM** (commercial bronchoscopy) | *None* — sensor unit only | Replica-scope insertion-tube motion | No force feedback claimed ([design](https://www.orsim.com/design)) |

**Motor brake vs magnetic particle brake — the honest answer:**

- The *documented* flexible-endoscopy rigs use **torque-controlled DC/BLDC motors** (VTEST) or **solenoid+spring passive
  brakes** (ICCAS 2009). I found **no** published endoscopy haptic rig using a magnetic particle brake on a scope shaft
  (**absence of evidence, not evidence of absence**).
- Particle/MR brakes are well attested for *hand-scale* passive haptics: an MR-brake glove with a buck-converter current
  controller for force tracking ([IEEE Access 2019](https://doi.org/10.1109/ACCESS.2019.2956954)), an MR-brake 3-DoF wrist
  master with experimental evaluation ([Frontiers in Materials 2019](https://doi.org/10.3389/fmats.2019.00025)), and a
  review of MR fluids for force feedback ([Eng. Res. Express 2026](https://doi.org/10.1088/2631-8695/ae99ad)).
- **Physics that decides it:** a particle brake's torque rises with coil current (field strength), and any *slipping* brake
  dissipates `P = τ·ω` inside the powder → thermal derating, so continuous rating is well below peak. A bronchoscopy session
  is 10–30 min of near-continuous motion, i.e. the worst duty case for a particle brake. A **motor driven in torque mode**
  dissipates far less (it only works against the user's motion, and a backdrivable motor can *assist*), and it can be
  back-driven freely when disabled — which is what you want for the "scope slides freely when nothing is happening" baseline.
- **Conclusion:** use a **torque-controlled motor + friction-wheel pinch** as the primary actuator. Reserve the particle
  brake as an optional "always-on drag" element if you want tissue-friction feel without motor current (cheap, silent,
  inherently safe on power loss). If you do buy one, get the datasheet's *continuous* torque and thermal time constant
  (**UNVERIFIED** — see §5; vendor pages for Placid Industries were WAF-blocked in this session, and Miki Pulley US lists
  only EM/spring-applied brakes, not particle brakes).

### 2.3 Recommended architecture (one page)

```
[3D-printed bronchoscope handle]
  ├─ real/dummy insertion tube Ø5–6 mm, sliding through a printed guide channel
  ├─ SPRING-LOADED FRICTION WHEEL PAIR pinching the shaft (Ø30–40 mm rubber/urethane tyres)
  │     ├─ wheel A on the motor shaft  → applies ±F, and its encoder gives ODOMETRY
  │     └─ wheel B on an AS5600        → redundant odometry / slip detection
  ├─ angulation lever on a pivot: AS5600 + spring-return + end-stops;
  │     optional: small geared motor or solenoid for lever resistance/click
  ├─ in-line LOAD CELL under the guide channel → measured operator push/pull
  ├─ HTC Vive Tracker 3.0 bolted to the outer/top face (role: handheld_object, or chest)
  └─ Teensy 4.1 (600 MHz M7, USB 480 Mbit/s) running a 1 kHz loop
        ── USB CDC serial (or HID) ──► host bridge ──► Godot (GDExtension)
```

Why this shape: (i) the pinch wheels decouple *applying* force from *measuring* travel, and give you insertion depth with
no separate linear encoder (VTEST's approach); (ii) when the motor is disabled the scope slides with only wheel-bearing drag,
so the default feel is a free-floating scope; (iii) the lever stays a *physical* lever with a real spring — the cheapest
convincing haptic is the one the mechanism already provides.

### 2.4 Bill of materials (rough prices, Nov 2026)

| Item | Representative part | Qty | Unit price | Notes / source |
|---|---|---|---|---|
| MCU board | **Teensy 4.1** (600 MHz Cortex-M7, USB device 480 Mbit/s) | 1 | ~$31.50 | [PJRC spec page](https://www.pjrc.com/store/teensy41.html) — **price not shown on the fetched page**, flag |
| Motor (torque mode) | **Pololu 4751** 19:1 37D 12 V gearmotor w/ 64 CPR encoder; stall 8.5 kg·cm (≈0.83 N·m) | 1–2 | **$60.95** | [Pololu 4751](https://www.pololu.com/product/4751). Note: geared ⇒ noticeable backdrive friction; for best feel prefer a **direct-drive BLDC** (gimbal/skate motor) + FOC |
| Motor driver | OpenFFBoard / TMC4671 board, or ODrive/VESC via CAN, or SimpleFOC (DRV8313) | 1 | €40–120 (**UNVERIFIED**) | [OpenFFBoard supported drivers](https://github.com/Ultrawipf/OpenFFBoard) |
| Encoder (odometry, redundant) | **AS5600** 12-bit magnetic rotary (I²C) + diametric magnet | 2 | ~$3–6/module (**UNVERIFIED**) | Cheap, 0.088° resolution; adequate for a 30–40 mm wheel |
| *Alternative depth sensing* | Magnetic tape + linear Hall strip, or a 600 mm optical/magnetic **linear encoder** scale along the insertion axis | (0–1) | ~$20–60 (**UNVERIFIED**) | Only if pinch-wheel slip proves unacceptable; adds length/friction to the mechanism. Odometry is simpler and is what VTEST does |
| Load cell | 5 kg / 10 kg thin-beam strain gauge, in-line with the guide channel | 1 | ~$10–20 (**UNVERIFIED**) | Only needed for assessment/closed-loop realism |
| Load-cell amp | HX711 (10/80 Hz — **too slow for 1 kHz**), or an INA333/ADS1232 front end into the Teensy ADC | 1 | ~$3–15 (**UNVERIFIED**) | Design note: prefer sampling at ≥200 Hz; HX711's 80 Hz mode is borderline |
| Friction wheels | 30–40 mm urethane/polyurethane tyres, spring-loaded pinch block | 2 | ~$5–15 (**UNVERIFIED**) | 3D-print the carriers; VTEST used Ø40 mm wheels |
| Angulation lever sensor | AS5600 or a 10 kΩ pot on the lever pivot | 1 | ~$3–6 | Also gives the *real* lever its spring feel for free |
| Lever return/click | Compression/torsion spring + optional 12 V solenoid or SG90/MG996R servo | 1 | ~$2–20 | Passive spring first; motorise later |
| Tracker | **HTC Vive Tracker 3.0** (dongle + cradle included) | 1 | **$129.99** (US page; JSON-LD shows 149.0) | [HTC](https://www.vive.com/us/accessory/tracker3/) |
| 3D printing | PETG/PLA, ~300–500 g + fasteners/heat-set inserts | — | ~$15–30 | — |
| PSU | 12 V 5 A (motor) + 5 V for logic | 1 | ~$15–25 | — |
| **Total (one axis, motor-based)** | | | **≈ $300–420** | Excluding printer, PC, Vive |

Notes: (a) the **Angulation lever needs no haptics beyond a spring** for v1; (b) a **second axis (shaft torque)** is a
nice-to-have using the same wheel pair rotated 90° or VTEST's flexible-shaft trick — defer it; (c) if you want the
"always-on drag" feel, add a small particle/MR brake in series with the wheel (**verify continuous torque**).

### 2.5 Latency and the host-side path

- **Frame budget:** 90 Hz ⇒ **11.1 ms** per frame; a 1 kHz device loop ⇒ 1 ms granularity, so up to ~10 control updates per
  rendered frame. That is the standard haptics arrangement (fast inner loop, slow render loop); label the 1 kHz target as
  *design convention* (VTEST relies on Maxon servo controllers rather than stating a rate).
- **USB:** Teensy 4.1 offers USB device at 480 Mbit/s ([PJRC](https://www.pjrc.com/store/teensy41.html)); USB HID interrupt
  endpoints commonly run at a 1 ms interval (1000 Hz) — feasible but **not verified on this specific stack**.
- **Two sane transports:** (1) **USB CDC serial** @ ~1 kHz, newline-delimited frames (`seq,force_N,depth_mm,lever_deg,load_N`)
  — simplest, debuggable with any serial terminal; (2) **HID** if you want the OS to treat it as a controller.
  For Godot, neither is built in: use a **GDExtension (C++)** with a background reader thread (libserialport or raw
  `termios`) and publish the latest sample to the main thread; do **not** poll serial from GDScript in `_process`.
- **Do not** try to route force through OpenXR: only `XrHapticVibration` exists unextended, and a brake is not a vibration
  output ([spec](https://registry.khronos.org/OpenXR/specs/1.1/html/xrspec.html)). The OpenXR path is for the *tracker pose*.
- **Optional shortcut:** OpenFFBoard's **External FFB mode** ("a normal HID gamepad without PID effects… effects can be
  managed using serial or HID commands") already implements constant force (type 1), spring (8), damper (9), inertia (10),
  friction (11) with per-axis coefficients, plus Python host examples
  ([wiki](https://github.com/Ultrawipf/OpenFFBoard/wiki/External-FFB-mode)). Motor driver + encoder + command parser are
  solved; you supply the mechanism and the engine-side sender.

### 2.6 Force levels (measured data — the numbers to design to)

| Quantity | Value | Source |
|---|---|---|
| Colonoscopy axial push/pull, "vast majority" band | **−5 N … +5 N** | Wireless colonoscopy force monitor, 30 patients, 6 experts, 7.5 Hz logging ([PMC2822026](https://pmc.ncbi.nlm.nih.gov/articles/PMC2822026/)) |
| Colonoscopy torque, same band | ±0.2 N·m | same |
| Flexible endoscopy (NOTES) mean push / pull resistance | **4.06 N** (σ 3.25) / **1.95 N** (σ 1.97) | VTEST requirements study ([PMC5026958](https://pmc.ncbi.nlm.nih.gov/articles/PMC5026958/)) |
| Nominal (75th pct) / peak axial force | **5.5 N** / **25.2 N** | same |
| Nominal / peak torque | 0.026 N·m / 0.214 N·m | same |
| Demonstrated continuous renderable force | 5.62 N / 0.190 N·m | VTEST hardware, same paper |
| Bronchoscope-specific insertion force | **not found** — no published measurement located in this session | — (§5) |

**Sizing math (mine, from the numbers above):** with a Ø40 mm friction wheel (r = 0.020 m), `τ = F·r`:
nominal 5.5 N ⇒ **0.11 N·m**; peak 25 N ⇒ **0.50 N·m**. VTEST's 0.187 N·m-nominal motors produced 5.62 N measured
(≈60 % of the naive `τ/r`), so budget **~1.7×** the naive torque. The Pololu 4751 (0.83 N·m stall) is sufficient at stall
but will be near its limit for sustained 25 N; a direct-drive BLDC with ~0.5–1 N·m continuous is the safer choice.

### 2.7 Open-source prior art worth reading (licences + activity, checked via GitHub API)

| Project | What it is | Licence | Activity |
|---|---|---|---|
| [Ultrawipf/OpenFFBoard](https://github.com/Ultrawipf/OpenFFBoard) | Universal FFB firmware: BLDC (TMC4671), DC (PWM), stepper; ABZ/BISS-C/MagTek/SSI encoders; HID FFB wheel/joystick + **External FFB** command mode | **MIT** (hardware repo also MIT w/ per-subfolder overrides) | 1,055★, pushed **2026-10-22** — very active |
| [Ultrawipf/OpenFFBoard-configurator](https://github.com/Ultrawipf/OpenFFBoard-configurator) | Qt GUI for the above | GPL-3.0 | 128★, pushed 2026-10-24 |
| [LucidVR/lucidgloves](https://github.com/LucidVR/lucidgloves) | DIY finger-tracking + servo-tendon haptic glove, Arduino/ESP32 | **MIT** | 2,408★, pushed 2025-10-29 |
| [LucidVR/opengloves-driver](https://github.com/LucidVR/opengloves-driver) | OpenVR driver for DIY gloves | **MIT** | 525★, pushed 2026-01-01 |
| [senseshift/senseshift-firmware](https://github.com/senseshift/senseshift-firmware) | Open firmware for VR accessories (vest/gloves); can emulate bHaptics | **GPL-3.0** | 153★, pushed 2025-10-27 |
| [sofa-framework/BeamAdapter](https://github.com/sofa-framework/BeamAdapter) | Kirchhoff/Cosserat rod plugin for SOFA | **LGPL-2.1** | 36★, pushed 2026-11-11 |
| [GazzolaLab/PyElastica](https://github.com/GazzolaLab/PyElastica) | Cosserat rod simulation (Python) | **MIT** | 369★, pushed 2026-11-13 |
| [SINTEFMedtek/Fraxinus](https://github.com/SINTEFMedtek/Fraxinus) | Open research platform for image-guided bronchoscopy (adjacent prior art, not haptics) | BSD-3-Clause | 7★, pushed 2026-11-13 |

Note that OpenFFBoard is a **sim-racing-derived** project: it assumes a wheel/joystick with an axis and PID effects. Using it
for a scope means either (a) treating the scope as a 1-axis "wheel" and mapping constant force to insertion resistance, or
(b) using External FFB mode and ignoring PID entirely. Both are supported by the firmware's architecture.

---

## 3. Real-time flexible-endoscope kinematics at 90 Hz

### 3.1 First, get the anatomy right (this changes the model)

A flexible **bronchoscope** is *not* a two-section continuum robot in the way a colonoscope is:

- It has **one** actively controlled bending section at the distal tip, driven by a single angulation lever (up/down), plus
  **rotation** of the shaft by wrist roll, plus **insertion/withdrawal** → 4 usable DoF. The distal section can bend to
  nearly **180°** ([Nature Communications 2024, AI co-pilot bronchoscope](https://www.nature.com/articles/s41467-023-44385-7)).
- The rest of the insertion tube is **passively compliant**: it conforms to the airway. Robotic bronchoscopes exploit
  exactly this by making "the proximal section … substantially increased stiffness in comparison to the distal section"
  (same paper).
- A **colonoscope** has two knobs (up/down + left/right) and much longer passive looping — different model.

So the correct decomposition is **1 active PCC section + a passive compliant shaft**, not "two PCC sections". Model the
passive shaft as a rod/chain solved against the airway, and the distal section as a constant-curvature arc whose curvature is
a function of lever angle. This is also cheaper than a two-section PCC solve.

### 3.2 Constant-curvature / piecewise-constant-curvature (PCC)

Canonical reference: **Webster & Jones, "Design and Kinematic Modeling of Constant Curvature Continuum Robots: A Review",
IJRR 2010** ([DOI](https://doi.org/10.1177/0278364910368147)) — note the venue is IJRR, not IEEE T-RO (a common citation error).
Broader context: **Burgner-Kahrs, Rucker, Choset, "Continuum Robots for Medical Applications: A Survey", IEEE T-RO 2015**
([DOI](https://doi.org/10.1109/TRO.2015.2489500)).

- **Cost:** closed-form; per section it is a handful of trig/division ops → microseconds. No iteration, no time step,
  perfectly stable, trivially differentiable for IK.
- **Fit to a bronchoscope:** excellent for the *distal* section (tendon-driven, roughly constant curvature when unloaded).
  Poor for the *shaft* in a curved bronchus, because the shaft takes the airway's shape, not an arc.
- **Weakness:** collision response. To make a PCC robot "not penetrate the wall" you must solve for the curvature parameters
  (or segment lengths) that satisfy contact — an outer iteration, and arcs cannot represent an S-shaped shaft.

### 3.3 Cosserat rod / geometrically exact beams

- **Discrete Elastic Rods** (Bergou et al., ACM TOG 2008, [DOI](https://doi.org/10.1145/1360612.1360662)) — the standard
  graphics formulation: discrete positions + material frames, stretch/shear and bending/twist energies, implicit integration.
- **Real-time medical implementations:** SOFA's **BeamAdapter** implements Kirchhoff rods ("Plugin implementing Kirchhoff rods
  to simulate any 1D flexible structure"), LGPL-2.1, active ([repo](https://github.com/sofa-framework/BeamAdapter)); SOFA
  itself is LGPL-2.1 and active ([repo](https://github.com/sofa-framework/sofa)). SOFA is used for exactly this class of
  medical-instrument simulation and has an active bronchoscopy/interventional community.
- **Contact with implicit surfaces** — the most relevant recent result for us: Jilani, Villard, Kerrien,
  "Quasi-Static Cosserat Rods in Contact With Implicit Surfaces", IEEE RA-L 2025
  ([DOI](https://doi.org/10.1109/LRA.2025.3570131)); and the dynamic/frictional variant, IROS 2024
  ([DOI](https://doi.org/10.1109/IROS58592.2024.10801774)). This is precisely "rod vs airway-as-SDF", and the same group
  works on bronchoscopy navigation.
- **Cost:** implicit solve of a banded system per rod; typically 1–10 ms for tens of nodes in C++ unless heavily optimised.
  **Not a good fit for a Godot iGPU target** as a first implementation, and there is no drop-in Godot port.
- **"Cosserat rod real-time GPU":** I did **not** locate a verified GPU implementation with published timings in this
  session (searches surfaced the CPU/SOFA and Python lines only). Treat any "GPU Cosserat at 90 Hz" claim as unverified;
  the practical GPU win here would be batching many *independent* rods, which a single-scope simulator does not have.
  (**UNVERIFIED / flagged**.)
- Practical note: PBD-style stiff-rod solvers exist that get Cosserat-like behaviour without a linear solve —
  "Direct Position-Based Solver for Stiff Rods" (Deul, Kugelstadt, Weiler, Bender, CGF 2018,
  [DOI](https://doi.org/10.1111/cgf.13326)).

### 3.4 Position-Based Dynamics / XPBD

- **PBD:** Müller, Heidelberger, Hennix, Ratcliff, "Position based dynamics", JVCIR 2007
  ([DOI](https://doi.org/10.1016/j.jvcir.2007.01.005)).
- **XPBD:** Macklin, Müller, Chentanez, "XPBD: position-based simulation of compliant constrained dynamics", MIG 2016
  ([DOI](https://doi.org/10.1145/2994258.2994272)) — makes stiffness **time-step independent** via a compliance parameter α̃,
  so a 90 Hz sim with substeps behaves the same as 60 Hz. That property matters if you ever drop frames.
- **Small steps:** Macklin, Storey, Lu, Terdiman, "Small steps in physics simulation", SIGGRAPH/Eurographics SCA 2019
  ([DOI](https://doi.org/10.1145/3309486.3340247)) — argues for many substeps with 1 iteration rather than few substeps with
  many iterations. This is the single most useful tuning paper for our case.
- **Cost:** O(substeps × iterations × constraints), all scalar math on contiguous arrays. For 24 segments × (1 distance +
  1 bend) constraints, 4 substeps × 4 iterations = **768 constraint projections per frame** — microseconds-to-tens-of-µs in
  C++ (estimate).
- **Fit:** ideal for the passive shaft, including self-thinning behaviour against walls, and it is *the* natural model for a
  "segment chain with distance + bending constraints" (which is what §3.5 describes — PBD *is* the principled version of it).

### 3.5 Spring-mass / chain-of-segments (the pragmatic game-engine version)

- Nodes (point masses, or capsules) linked by **distance constraints** (inextensibility) and **bending constraints**
  (angle between consecutive segment directions, or a 3-node "triangle stiffness").
- Explicit spring integration is stiff at 90 Hz and blows up for inextensible rods; **use PBD/XPBD projection instead** —
  same look, unconditionally stable, and it is ~20 lines of code per constraint.
- This is the right level of ambition for a game-engine implementation: no linear solver, no material frames, no twist DoF.
  Twist can be handled as a **scalar** (roll angle) transported along the chain — which is exactly what a bronchoscope needs
  (you roll the handle; the tip rolls with it).

### 3.6 Comparison and verdict

| Model | Cost/frame (24 seg) | Stability | Effort in Godot | Handles airway contact | Verdict |
|---|---|---|---|---|---|
| **PCC (analytic)** | ~µs | Perfect (no integration) | Low (~100 LOC) | Only via outer iteration; can't do S-shape | Use for the **distal tip** only, driven by lever angle |
| **Cosserat / DER** | 1–10 ms typical (C++, implicit solve) | Good with implicit integrator | High (no Godot port; would be a research project) | Yes, incl. twist/friction | Overkill for v1; revisit if realism is contested |
| **XPBD chain** | ~10–100 µs (est.) | Unconditionally stable | **Low–medium** (~300–600 LOC C++) | Yes, cheaply, with substeps | **Core of the recommendation** |
| **Spring-mass (explicit)** | ~µs | **Unstable** for stiff rods at 90 Hz | Low | Yes | Don't; use XPBD instead |

### 3.7 Collision strategy — airway as a spline tube, not a mesh

- **Author the airway as a skeleton + radius**: a polyline/spline centreline per bronchus with a radius (or elliptical
  radii) per station. This is exactly how airway trees are extracted from CT — segmentation + centreline + local radius
  (Aykac et al., IEEE TMI 2003, [DOI](https://doi.org/10.1109/TMI.2003.815905)). It also gives you the geometry the
  *navigation* code needs (arc-length ↔ anatomical location) for free.
- **Collision test:** for each rod node, find nearest spline station `s` (walk a cached index ± window, clamp so the search is
  O(1) amortised), compute `d = |p − C(s)|`, and push out if `d + r_scope > R(s)` along the local normal. Cost per node ≈ a
  few dozen flops; with a sliding index window there is no broadphase at all.
- **Self-collision:** skip it for v1. A bronchoscope in an airway rarely self-contacts; if you need it (looping in the
  trachea), do **capsule–capsule** between segment pairs whose index distance > 2, restricted to a spatial hash — cheap.
- **Substeps:** 3–6 per 90 Hz frame for the shaft (Macklin's "small steps" argument,
  [DOI](https://doi.org/10.1145/3309486.3340247)). Wall contact only needs to be resolved once per substep.
- **One-sided collision** is fine: the airway is a convex-ish tube; you only need to prevent the scope leaving it.
- **Do not** use Godot's Jolt/Godot Physics triangle mesh for this: mesh-vs-capsule on a 100k-tri airway is the classic
  iGPU/CPU sink, and you gain nothing over the analytic tube.

### 3.8 Recommendation for 90 Hz on an iGPU

**Model:** hybrid.
1. **Shaft:** XPBD chain, **N = 24** nodes (2.5 cm spacing over ~60 cm working length) — enough to bend smoothly through
   4th–5th generation bronchi without visible faceting, and small enough to be trivially cheap. Use 1 distance constraint +
   1 bending constraint per interior node, and pin node 0 to the tracked handle pose (with the insertion offset from
   odometry).
2. **Distal section:** the last 3–4 nodes are overridden by a **PCC arc** whose curvature `κ = f(lever_angle)` and whose
   arc length is fixed (bending section length). Blend the PCC arc into the XPBD chain with a soft positional constraint at
   the junction so it doesn't pop.
3. **Twist/roll:** one scalar roll angle, driven by handle roll from the tracker, propagated to the tip (no torsional
   dynamics in v1).
4. **Substeps:** 4 per frame, 4 iterations (or 8 substeps × 1 iteration per the "small steps" paper). Expected cost
   **< 0.5 ms/frame** on one core in C++ (**estimate** — this is my sizing, not a measured benchmark).
5. **Where it runs:** a **GDExtension (C++)** with a fixed-size struct-of-arrays for nodes, called from
   `_physics_process`. Do **not** implement this in GDScript: Godot's default physics tick is **60 Hz**
   (`physics/common/physics_ticks_per_second`, default 60 — [ProjectSettings docs](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html)),
   so either raise it to 90 or run the rod solver once per rendered XR frame inside `_process` and interpolate. GDScript
   per-frame loops over 24 nodes × 16 substep-iterations would likely dominate the frame (**estimate**).
6. **Caveat on the iGPU:** the kinematics is CPU-side and negligible; the risk is **rendering** the airway + the scope
   camera (§3.9), not the rod. Keep the airway low-poly, bake lighting, avoid shadows, and prefer the Mobile renderer if
   measurements demand it.

### 3.9 The endoscope camera view (RenderTexture / second camera) in VR

**What it is:** a second camera at the scope tip rendering into a texture (`SubViewport` in Godot — "an interface to a game
world that doesn't create a window or draw to the screen directly" ([docs](https://docs.godotengine.org/en/stable/classes/class_subviewport.html))),
displayed either on a virtual monitor in the world or as an inset HUD.

**Cost model (estimate, arithmetic):** a HMD at ~2160×1200 total = ~2.6 MP per frame. A 640×480 tip view = 0.31 MP, i.e.
~12 % of *one* eye's pixels — but you pay **the whole scene submission again** (culling, draws, lighting), so the practical
cost is closer to "one extra mono pass ≈ 40–60 % of one eye pass" if the airway is draw-call heavy. Two things blow this up:
*stereo* tip rendering (2×) and *shadows/SSAO/volumetric fog* in the tip viewport (multi-pass). Do neither.

**Recommendations:**
- Render the tip view **monoscopically** — real bronchoscopy is a 2D monitor image, so mono is also the *correct* look.
- 512² or 640×480, **no MSAA**, shadows off, short far plane (0.5 m), a dedicated low-detail LOD for the airway interior.
- Update every frame (interaction latency matters more than resolution); if profiling demands it, update at 45 Hz and
  reproject — but measure first.
- Alternative that costs ~nothing: render the tip view **on the same camera** by stencil/portal tricks — not worth the
  complexity in Godot; a SubViewport is the pragmatic choice.

---

## 4. Recommended path (summary)

1. **Input/tracking:** HTC Vive Tracker 3.0 on a printed handle, role `handheld_object` (custom OpenXR action map) or
   `chest` (stock map) as the fallback; wand controller retained as alternate input. Insertion depth from **pinch-wheel
   odometry**, not from tracker translation.
2. **Haptics:** torque-controlled motor + spring-loaded friction wheels on the shaft (VTEST architecture), 1 kHz Teensy loop,
   USB CDC to a GDExtension. Design force range 0–25 N, nominal 5–6 N; torque 0–0.2 N·m. Optional passive particle/MR brake
   for baseline drag only after datasheet verification.
3. **Skip commercial gloves.** If a glove is ever wanted for finger-level cues, SenseGlove Nova 2 is the only credible
   force-feedback option with native Linux support — but budget €6.3k, an integration project, and it still won't do axial
   force.
4. **Kinematics:** XPBD shaft (24 nodes, 4 substeps) + PCC distal section + analytic spline-tube airway collision, in C++.
5. **Rendering:** mono 512²–640×480 tip SubViewport, shadows/AA off, low-poly airway.

---

## 5. Uncertain / verify before committing

| # | Item | Why uncertain | How to verify |
|---|---|---|---|
| 1 | **SteamVR on Linux advertising `XR_HTCX_vive_tracker_interaction`** | Not tested; Godot's own PR history shows SteamVR had to be fixed first ([PR #58921](https://github.com/godotengine/godot/pull/58921)) | `xrEnumerateInstanceExtensionProperties` on the target machine; dump `xrGetCurrentInteractionProfile` per top-level path |
| 2 | **`handheld_object` role usable end-to-end in Godot** | Default action map omits it (source comment: "getting errors on this one"); metadata registration commented out | Build a custom action map + SteamVR role assignment test; confirm pose arrives at `XRController3D` |
| 3 | **SenseGlove Unity-on-Linux** | Docs say "Windows, Linux, Android"; the Unity README says Linux = DK1 only ([comparison](https://senseglove.gitlab.io/SenseGloveDocs/compatibility.html) vs [README](https://github.com/Adjuvo/SenseGlove-Unity)) | Ask SenseGlove in writing; test SenseCom + native C++ sample on Ubuntu |
| 4 | **Weart Linux support** | No OS statement found on the SDK/webshop pages | Vendor query; ask for the SDK's supported-platform matrix |
| 5 | **HaptX G1 price & Linux** | Site returned HTTP 502 repeatedly; enterprise quote-only | Vendor contact |
| 6 | **Dexmo / ContactGlove / VML / CyberGlove current specs & price** | Sites JS-only or DNS-unreachable in this session | Vendor contact; treat historical prices as folklore |
| 7 | **Vive Tracker 3.0 price** | US page shows `$129.99` but structured data shows `149.0` | Check regional store at purchase time |
| 8 | **Bronchoscope insertion force in Newtons** | **No published measurement found.** Closest analogues: colonoscopy ±5 N and NOTES endoscopy 5.5 N nominal / 25.2 N peak | Either instrument a real bronchoscope (load cell in the handle) or state the borrowed numbers as an assumption |
| 9 | **Magnetic particle brake: continuous torque, thermal time constant, price** | Placid Industries blocked automated access (WAF); Miki Pulley US lists only EM/spring brakes; Ogura US lists clutches | Datasheet request; consider MR brake vendors instead |
| 10 | **1 kHz USB HID on Teensy 4.1 with this exact stack** | USB 480 Mbit/s is documented; end-to-end jitter is not | Measure round-trip with a scope/logic analyser; compare CDC vs HID |
| 11 | **Godot 4.7 tracker/OpenXR behaviour stability** | Tracker plumbing changed as recently as PR #108511 (2025-07) | Pin the engine version; keep a regression scene that asserts tracker pose |
| 12 | **ORSIM / CAE / Simbionix "EndoVR" haptic hardware** | CAE product URLs 404; Immersion Medical's AccuTouch line is long discontinued | Historical brochures only; do **not** cite as current |
| 13 | **Manus–Meta acquisition** | Only a secondary source (Wikipedia) located | Primary announcement if it matters to procurement |
| 14 | **Cost estimate "≈$300–420" BOM** | Several line items are unverified module prices | Re-quote at order time; the verified anchors are Pololu $60.95 and Tracker $129.99 |
| 15 | **Performance estimates (§3.8/3.9)** | My sizing arithmetic, not benchmarks | Build a 24-node XPBD prototype and profile on the target iGPU |
| 16 | **GPU Cosserat rod implementations** | No verified GPU-accelerated Cosserat/DER implementation with published timings was found | Search graphics literature (DER GPU solvers exist in research code) if this path is pursued |
| 17 | **Open Bionics as a "VR glove"** | Category mismatch: it is a prosthetic-hand project, not an input device | Confirm the brief's intent; the useful open references are LucidGloves/SenseShift |

---

## 6. Reference list (grouped)

**OpenXR / platform**
- OpenXR 1.1 spec (haptics, `XR_HTCX_vive_tracker_interaction`, `XR_EXT_haptic_parametric`): https://registry.khronos.org/OpenXR/specs/1.1/html/xrspec.html
- Godot tracker support PR: https://github.com/godotengine/godot/pull/58921 · role paths PR: https://github.com/godotengine/godot/pull/108511
- Godot action map: https://github.com/godotengine/godot/blob/master/modules/openxr/action_map/openxr_action_map.cpp · tracker extension: https://github.com/godotengine/godot/blob/master/modules/openxr/extensions/openxr_htc_vive_tracker_extension.cpp
- Godot releases (4.7.2): https://github.com/godotengine/godot/releases · physics tick default: https://docs.godotengine.org/en/stable/classes/class_projectsettings.html · SubViewport: https://docs.godotengine.org/en/stable/classes/class_subviewport.html
- Monado hardware matrix: https://monado.freedesktop.org/
- HTC Vive Tracker 3.0: https://www.vive.com/us/accessory/tracker3/

**Devices**
- bHaptics store: https://www.bhaptics.com/tactsuit/ · TactGlove: https://www.bhaptics.com/tactsuit/tactglove/ · docs: https://docs.bhaptics.com/ · Linux report: https://moonclaw.eu/posts/bhaptics-hardware-on-linux/
- SenseGlove Nova 2: https://senseglove.com/product/nova-2/ · compatibility: https://senseglove.gitlab.io/SenseGloveDocs/compatibility.html · SenseCom install: https://senseglove.gitlab.io/SenseGloveDocs/sensecom/install-instructions.html · Unity SDK: https://github.com/Adjuvo/SenseGlove-Unity · native API: https://github.com/Adjuvo/SenseGlove-API
- Manus: https://www.manus-meta.com/products/quantum-metagloves · https://www.manus-meta.com/products/metagloves-pro-haptic · https://www.manus-meta.com/software
- Weart: https://weart.it/webshop/ · https://weart.it/our-technology/sdk/
- HaptX: https://haptx.com/products/ · Dexmo: https://www.dextarobotics.com/ · CyberGlove: https://www.cyberglovesystems.com/

**DIY / open source**
- OpenFFBoard: https://github.com/Ultrawipf/OpenFFBoard · Ext FFB mode: https://github.com/Ultrawipf/OpenFFBoard/wiki/External-FFB-mode
- LucidGloves: https://github.com/LucidVR/lucidgloves · OpenGloves driver: https://github.com/LucidVR/opengloves-driver
- SenseShift firmware: https://github.com/senseshift/senseshift-firmware
- Teensy 4.1: https://www.pjrc.com/store/teensy41.html · Pololu 4751: https://www.pololu.com/product/4751

**Haptic endoscopy prior art**
- VTEST haptic interface (IEEE ToH 2016): https://pmc.ncbi.nlm.nih.gov/articles/PMC5026958/
- Passive-brake catheter interface (ICCAS-SICE 2009): https://openalex.org/W2133193312 · pneumatic variant: https://doi.org/10.1109/ICCAS.2016.7832334
- GI endoscopy 2-DoF interface (2012): https://doi.org/10.1080/01691864.2012.703300 · colonoscopy simulator (2006): https://doi.org/10.1163/156855306776014330
- Colonoscopy force measurements: https://pmc.ncbi.nlm.nih.gov/articles/PMC2822026/
- Haptic feedback in remote flexible endoscopy (EIO 2018): https://doi.org/10.1055/a-0655-7497
- MR-brake glove: https://doi.org/10.1109/ACCESS.2019.2956954 · MR wrist master: https://doi.org/10.3389/fmats.2019.00025 · MR review: https://doi.org/10.1088/2631-8695/ae99ad

**Kinematics**
- Webster & Jones (IJRR 2010): https://doi.org/10.1177/0278364910368147 · Burgner-Kahrs et al. (T-RO 2015): https://doi.org/10.1109/TRO.2015.2489500
- Bergou et al., Discrete Elastic Rods (TOG 2008): https://doi.org/10.1145/1360612.1360662
- Müller et al., PBD (2007): https://doi.org/10.1016/j.jvcir.2007.01.005 · Macklin et al., XPBD (2016): https://doi.org/10.1145/2994258.2994272 · Small steps (2019): https://doi.org/10.1145/3309486.3340247 · Stiff rods PBD (2018): https://doi.org/10.1111/cgf.13326
- SOFA: https://github.com/sofa-framework/sofa · BeamAdapter: https://github.com/sofa-framework/BeamAdapter · PyElastica: https://github.com/GazzolaLab/PyElastica
- Cosserat + implicit surfaces (RA-L 2025): https://doi.org/10.1109/LRA.2025.3570131 · IROS 2024: https://doi.org/10.1109/IROS58592.2024.10801774
- Airway centreline from CT (TMI 2003): https://doi.org/10.1109/TMI.2003.815905
- Robotic bronchoscope stiffness/180° bending (Nat. Commun. 2024): https://www.nature.com/articles/s41467-023-44385-7
- ORSIM (sensor-only commercial bronchoscopy sim): https://www.orsim.com/design
