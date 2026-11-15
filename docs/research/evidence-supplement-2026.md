# 2026 evidence supplement (via SearXNG/Europe PMC)

Added after the first research pass, when the local Vane engine was pointed at
this project. Two new 2026 studies change details of the design; one existing
claim needed sharpening rather than reversing.

## Research tooling status (for reproducibility)

| Channel | State | Use |
| --- | --- | --- |
| Europe PMC REST (`https://www.ebi.ac.uk/europepmc/webservices/rest/search`) | works | primary source for trials, with abstracts and PMIDs |
| SearXNG JSON API, `http://192.168.1.2:8082` | works, and its **`europepmc` engine is good** | discovery: `?q=…&format=json&engines=europepmc` |
| Vane chat, `http://192.168.1.2:3000` | **retrieval broken** | not usable for evidence yet |
| SearXNG general web engines | degraded | `braveapi: HTTP error`, `google cse: too many requests` |

Vane's chat endpoint returns "retrieval returned no documents" in both `web` and
`academic` focus modes, and before that returned an identical 10 consumer-health
pages regardless of query. SearXNG itself answers distinct queries correctly and
Vane reaches it (HTTP 200 on `/healthz`), so the fault is in Vane's search/ranking
step, not the network or the engine. Workaround while it is unresolved: query
SearXNG directly with `engines=europepmc`.

## New findings

### 1. Strong validity evidence for a "portable VR" bronchoscopy simulator — screen-based, not HMD

**PMID 41963810**, *BMC Anesthesiology* 2026, "Ensuring flexible optical
intubation skills using a portable virtual reality simulator — a validation
study". 12 challenging airway cases; 15 novices vs 15 experienced
anaesthesiologists; all five Messick sources explored.

- internal consistency Cronbach's α = **0.89**;
- generalisability theory: **6 cases** for formative (reliability > 0.7),
  **10 cases** for summative (> 0.8);
- discriminates novices from experts, p < 0.001;
- contrasting-groups pass standard **34.4%**, with 2 false positives and 1 false
  negative.

The device is ORSIM: vendor material describes a video-enabled flexible
bronchoscope, a desktop sensor unit, and a **laptop** for the internal view. "VR"
here means screen-based virtual reality in the classic simulator sense.

**Consequences**

- Our claim that no **head-mounted-display** validity evidence exists stands, and
  is now precise: the strong evidence belongs to a screen-based portable system.
  This is a genuine, publishable gap for the project.
- The 34.4% pass mark recalibrates mastery: a composite percentage threshold like
  75 is arbitrary. Use contrasting-groups standard setting, or adopt the published
  standard for a comparable test.
- **Case count is a statistical requirement, not a content choice:** ~6 cases for
  formative feedback, ~10 for a summative test. Our 8-case plan is formative; a
  summative claim needs at least 10, and preferably ≥ 12 like the cited test.

### 2. A ₹1,000 (≈ US$12) bronchoscopy model has published validity

**PMID 42124767**, *Cureus* 2026, "Development and Validation of a Low-Cost
Simulation Tool for Practical Training in Diagnostic Bronchoscopy for
Otolaryngology Postgraduates". Paediatric-airway model built from locally
available materials (INR 1,000), 26 otolaryngology residents, face/content/
curriculum/transfer validity via Likert survey, significant confidence gain.

**Consequences**

- Low-fidelity, extremely cheap physical models can carry validity evidence. This
  is the same lesson as ORSIM, and it argues against chasing mucosal realism.
- It is the "low-cost/local manufacture" data point the first prior-art pass could
  not find (it flagged Chinese/Indian products as unverified); India is covered by
  this Cureus study, and Chinese vendors remain unverified.

### 3. A 2026 systematic review of airway-simulator validation

**PMID 41826217**, "Validation status of definitive airway management
simulators: a systematic review" (PubMed/Embase/Cochrane to September 2025).
Useful as the umbrella citation for "the field's validity evidence is uneven and
usually not Messick-complete" — cite it rather than re-litigating individual
devices.

## What did *not* change

- No HMD-based bronchoscopy validity study found (screen-based only).
- No normative table of insertion depth by bronchopulmonary segment found; the
  best available anchors remain incisor-to-vocal-cords (~12–15 cm) and
  carina ~24–27 cm, which our generated tree matches by construction, and which
  we still will not present as standards.
- Automated in-sim guidance still not an effective training intervention
  (Su 2025), and canonical-pathway scoring still generates false
  negatives/positives (Sun 2026).

## Follow-ups this opens

1. Instrument the simulator so a **reliability study** is possible: 12-case sets,
   fixed difficulty, metrics export (already done).
2. Add contrasting-groups standard setting to the rubric tooling instead of only
   fixed score thresholds.
3. Investigate Vane's search call (it is a promising local front-end; only its
   retrieval step fails). Not a blocker for the simulator.
