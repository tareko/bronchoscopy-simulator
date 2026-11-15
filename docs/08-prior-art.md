# Prior art: what exists, what to steal, what to avoid

Full review: [docs/research/prior-art.md](research/prior-art.md) (9.3k words,
11 tables, 85 URLs, all 28 DOIs verified via Crossref). This page is the
decision summary.

## The uncomfortable finding

**No commercial bronchoscopy trainer is controller-only.** Every serious product
instruments a real handle:

| Product | Scope input |
| --- | --- |
| Surgical Science **BRONCH Mentor** | real flexible endoscopes, modified EBUS needle |
| CAE **EndoVR** (successor to AccuTouch) | scope tube + haptics, mannequin, screen |
| **ORSIM** | passive replica scope handle with sensors |
| **Smiloscopy** | your own single-use scope plus tracking sensors |
| Kyoto Kagaku | physical airway model, no VR |

Our wand-controller v1 is therefore the field's outlier. That is a deliberate
trade (cheap, portable, no proprietary hardware) but it means we cannot borrow
their interaction model — and the highest-value hardware addition is a tracked
proxy scope, not better graphics.

## What to steal, in priority order

1. **Their outcome vocabulary, verbatim.** DC (segments/18), SP, PT, MIT/AIT.
   These are the primary outcomes of both 2026 RCTs; aligning means our numbers
   are comparable to published work.
2. **Multiple anatomies.** The one positive RCT (Deng 2026) used training across
   several CT-derived airways. Ship several labelled trees.
3. **The CHEST-style curriculum structure** (BRONCH Mentor): basic navigation →
   inspection → sampling → haemorrhage management, with a summative test.
4. **ORSIM's lesson:** the cheapest-looking device (passive replica, no force
   feedback) owns the only patient-outcome RCT and a 12-case summative
   examination with a 34.4% pass mark. Haptics are an unproven active
   ingredient; assessment design is not.
5. **Reusable software:** BronchSim (browser, CT-derived, CC BY 4.0) and
   Fraxinus (BSD-3, CT → centreline route → virtual bronchoscopy + EBUS,
   Ubuntu-first) — Fraxinus is the pipeline to study for the CT phase.

## Where the open corners are

- **Lens soiling and secretions scoring** — nobody scores it; it is a real
  reason for failed procedures and our case 3 covers it.
- **Orientation teaching** — the market leader's own validity study failed to
  discriminate on guided navigation, so nobody has demonstrated good
  orientation training. We have a defensible reason to try (and a reason to be
  humble about it).
- **Open source, Linux, OpenXR, offline.** There is no open-source VR
  bronchoscopy trainer, and Steam returns zero results for bronchoscopy.
- **Data export** for educators and researchers, which closed platforms do not
  offer.

## What nobody sells anymore (do not copy their pricing/positioning)

Mentice, VirtaMed, Medical-X, InSimo, FundamentalVR, Osso VR, Precision OS,
SimX, Arch Virtual, ImmersiveTouch and AnatomyX sell **no** bronchoscopy
product. CAE's AccuTouch has left the catalogue; Simbionix is now Surgical
Science; Level Ex's Airway Ex has pivoted. The market is one incumbent plus
niche devices — which is why an open, Linux-first trainer has room.

## Evidence-quality warnings

- Vendor hardware/haptic claims are marketing; no independent fidelity benchmark
  exists for any of them.
- Case counts, prices and force-feedback designs are largely unpublished.
- The clinical literature is dominated by small, single-centre studies, mostly
  anaesthesia fibreoptic intubation rather than diagnostic bronchoscopy.
- Cochrane 2025: insufficient evidence to replace conventional training.
