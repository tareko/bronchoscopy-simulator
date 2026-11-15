# Scope model and VR input mapping

## What a flexible bronchoscope actually does

Adult flexible bronchoscopes used for diagnosis are typically 4.9–5.9 mm outer
diameter, ~60 cm working length, with:

- **one deflection lever** for up/down tip angulation (roughly 180° up, 130°
  down on therapeutic scopes),
- **no independent left/right joint** — lateral steering comes from *torquing*
  the shaft (rotating the whole instrument about its long axis), often helped by
  letting gravity act on the handle,
- **a working channel** (1.2–2.8 mm) carrying suction, biopsy forceps, brushes,
  needles, balloon catheters or lavage fluid,
- **a compliant tip** that slides along airway wall rather than stopping dead.

Real navigation is therefore a two-degree-of-freedom motor task plus insertion:
lever for the vertical plane, torque to rotate that plane, and push/pull for
depth. This is why a "6-DoF joystick on a floating camera" feels wrong to anyone
who has held a scope: it removes the torque problem, which is most of the skill.

## What we simulate

`src/scope/endoscope.gd` models the tip as a heading vector advanced along the
airway, with the shaft as a resampled history of that path.

State:
- `path` — travelled centreline, proximal → distal (authoritative),
- `body` — evenly spaced, lumen-clamped samples of `path` (rendered),
- `tip_dir` — current heading,
- `bend_axis` — pitch axis of the bending plane (parallel-transported, rotated by
  torque).

Per frame, given `insert_mm`, `lever` (−1..1) and `roll_deg`:

1. **Insert** in ≤3 mm substeps. The candidate point is tested against the lumen;
   if it would penetrate the wall it is clamped, and radial overshoot is logged
   as wall contact.
2. **Wall slide.** If a clamped step yields less than 40% of the requested
   advance, the push direction is blended with the local lumen axis by
   `wall_slide_bias` (0.65). This reproduces the compliant-airway behaviour where
   a pushed scope slides along the wall instead of jamming — without it, every
   bifurcation becomes a hard stop, which is unpleasant and unlike reality.
3. **Steer.** Desired heading = local lumen axis rotated by `lever × 80°` about
   `bend_axis`. Actual heading chases it at `deflect_rate_deg_s` (170°/s). With
   the lever centred the tip relaxes toward the lumen at `align_rate_deg_s`
   (55°/s) — a tunable "airway guidance" assist.
4. **Torque.** `bend_axis` is rotated about `tip_dir` by `roll_deg`, so the
   vertical articulation plane follows the shaft.
5. **Resample** the body at 8 mm intervals, clamped into the lumen.

### Deliberate simplifications (and their costs)

| Simplification | Why | Cost |
| --- | --- | --- |
| Tip heading is a vector, not a bendable rod | stable, cheap, testable | no true minimum bend radius for the distal 5 cm; a 180° curl-back is impossible |
| Lumen = capsules around the centreline | analytic queries, branch identity for scoring | no carpal spurs, no wall deformation, no mucosal texture |
| Wall slide bias | playability at bifurcations | slightly "helpful"; expert mode sets it to ~0.2 |
| Contact force is a distance proxy | no force sensor | haptics are qualitative |
| Single scope radius | simpler collision | no tool-dependent stiffness (forceps stiffen the scope in reality) |

V2 replaces steps 1–5 with a position-based chain (distance + bending constraints,
collision against the capsule lumen) or a Cosserat rod, behind the same public
API (`advance()`, `get_tip()`, `get_body()`), so nothing else changes.

## Input mapping on HTC Vive wands

The original Vive wands have: trigger, grip, trackpad, menu button, and 6-DoF
pose. Mapping (planned for the VR layer):

| Action | Wand input | Notes |
| --- | --- | --- |
| Insert / withdraw | Move the controller along its own forward axis while holding **grip** | "Scope-follows-hand" ratchet: because a room-scale arm cannot push 30 cm continuously, the insertion anchor re-zeroes when grip is released. |
| Tip deflection | **Trackpad Y** | Absolute lever position, matching the real lever (spring-centred). |
| Shaft torque | **Trackpad X** or physical wrist rotation | Both accepted; wrist rotation of the controller is the more transferable cue. |
| Suction | **Trigger**, held | Continuous, with a suction sound and secretion removal. |
| Tool deploy/act | **Trigger** when a tool is loaded | Forceps open/close, needle advance, brush. |
| Tool switch | **Menu** | Radial tool selector. |
| Reset / pause | **Grip + Menu** | Confirmation panel. |

Rumble = wall contact magnitude (pulse width proportional to clamp distance,
capped at 40 ms to stay below the Vive's continuous-vibration threshold).

### Why insertion is a ratchet, not absolute tracking

The trachea is 12 cm and the working depth is 25–40 cm from the incisors. A user
cannot physically push their hand 40 cm forward from a comfortable stance. Two
options: (a) scale controller motion (breaks force cues and feels floaty), or
(b) ratchet — grip, push, release, reposition, push again. Option (b) preserves
proprioceptive pacing and is how physical endoscopy trainers with a real scope
work anyway. It also makes "how fast are you inserting" a meaningful metric.

## Physical scope prop (Mk1 designed, files in `hardware/prop/`)

The evidence (docs/01, docs/08) says the *handle* is where commercial trainers
get their fidelity, and that force feedback is an unproven ingredient. So the
prop is passive: a printed clamshell grip with a real spring-centred lever,
carrying a Vive Tracker.

| Axis | Sensor | Maps to |
| --- | --- | --- |
| Lever deflection | AS5600 magnetic encoder, 12-bit, non-contact | `lever`, −1 … +1 |
| Torque / wrist rotation | Tracker 6-DoF pose, rotation about the handle axis | `roll_deg` |
| Insertion | not instrumented in Mk1 | clutch + scaled hand motion |

Design choices worth knowing:

- **Non-contact sensing.** A potentiometer would wear and develop backlash at the
  pivot; a diametric magnet on the lever hub read by an AS5600 through a 3 mm gap
  has no wearing parts.
- **±22° throw**, bounded by the thumb recess. Real scopes reach ±70°; the bigger
  throw needs a deeper grip and is a Mk2 change.
- **Two O-rings** as the return spring: cheap, tunable by swapping cord size, and
  easy to replace when they age. A torsion spring is the upgrade.
- **Insertion stays virtual.** A desk-scale prop cannot be pushed 30 cm, and a
  ratchet feels wrong with a physical handle in hand. Mk1 uses a clutch + scaled
  hand motion from the other hand; Mk2 adds a rail or sprung sheath so insertion
  is measured directly.

Build instructions, BOM, print settings and the wiring table live in
`hardware/prop/README.md`; the STLs are regenerated by
`hardware/prop/build.sh` and gated by `hardware/prop/validate_stl.py`.

## Measured requirements for a haptic instrument

Collected by the haptics research subagent
(`docs/research/incoming/haptics-input-kinematics.md`). These are the numbers any
force-feedback version must hit — not guesses:

| Quantity | Value | Source |
| --- | --- | --- |
| Colonoscopy axial push/pull, bulk of the distribution | −5 … +5 N | in-vivo force monitor, 30 patients, 6 experts |
| Flexible endoscopy mean push / pull | 4.06 N (σ 3.25) / 1.95 N (σ 1.97) | VTEST requirements study |
| Nominal / peak axial force | 5.5 N / 25.2 N | same |
| Nominal / peak torque | 0.026 N·m / 0.214 N·m | same |
| Demonstrated renderable output | 5.62 N and 0.190 N·m | VTEST friction-wheel rig (two Maxon RE40) |
| Bronchoscope-specific insertion force | **no published measurement found** | gap |

Sizing rule (from the same note): a Ø40 mm friction wheel gives `τ = F·r`, so
nominal 5.5 N needs 0.11 N·m and the 25 N peak needs 0.50 N·m — i.e. a pair of
0.19 N·m motors with a 2× margin. This is the Mk2/Mk3 force target; Mk1 is
passive and deliberately does not attempt it.

## V2 kinematics: hybrid XPBD + constant curvature

The current model (docs/02) is a path-follower. The researched replacement,
chosen for 90 Hz on an 890M iGPU:

1. **Shaft:** XPBD chain, **24 nodes** at 25 mm spacing over the ~60 cm working
   length — 1 distance constraint and 1 bending constraint per interior node,
   node 0 pinned to the tracked handle pose.
2. **Distal bending section:** the last 3–4 nodes are overridden by a
   constant-curvature (PCC) arc whose curvature is a function of lever angle,
   blended into the chain with a soft positional constraint so it does not pop.
3. **Collision:** analytic spline tube (centreline + radius per station) with a
   sliding index window; no broadphase, no triangle mesh. Godot's Jolt/Godot
   Physics mesh collision is explicitly rejected — it costs far more and adds
   nothing.
4. **Twist:** one scalar roll angle from the tracker, propagated to the tip.
5. **Substeps:** 3–6 per frame; one-sided collision is sufficient.

Cosserat rods were considered and rejected for v1: 1–10 ms per solve in C++,
high implementation risk, and the visual difference at these scales is small.
Spring-mass chains were rejected as unstable at 90 Hz stiffness.

## Rendering the endoscopic view

One extra **mono** `SubViewport` at 512²–640×480 is affordable on the iGPU;
stereo at full rate with shadows is not. The endoscopic image should therefore
be a camera texture presented on a world-space panel (or one eye), not a second
stereo view.

## Haptics hardware reality (why Mk1 is passive)

- OpenXR supports exactly one haptic output type, `XrHapticVibration`. There is
  no ratified extension for a force-feedback accessory, so any brake or motor
  rig must be driven over a **side channel** (USB CDC serial or HID). The Mk1
  firmware already takes that path: HID joystick, no custom driver.
- Shipping gloves are vibrotactile or fingertip-scale kinesthetic (bHaptics,
  Manus, SenseGlove, Weart, HaptX); none produce tens of newtons along a 60 cm
  shaft. Linux support is thin or paid-tier only.
- Precedent for the DIY route: VTEST's flexible-endoscopy rig uses two
  spring-loaded friction wheels on the shaft with torque-controlled motors and
  optical encoders — the same architecture a Mk3 could adopt.

## Calibration and comfort

- **Units:** world scale 1 unit = 1 m; anatomy is authored in mm and scaled by
  1e-3 at the mesh node, so 30 cm of insertion is 30 cm of hand travel.
- **Entry pose:** the mouth/hand anchor is placed 40 cm in front of the user at
  chest height, so pushing forward matches the real posture.
- **Comfort:** no camera motion except what the user's body does (the scope
  camera is the HMD); vignette optional during rapid head turns; the endoscopic
  view is a world-space texture panel approach for seated play, and full
  immersive view for standing play.
- **Seated vs standing:** both supported; standing needs a 2×2 m play space and
  the ratchet mapping; seated uses the panel view.
