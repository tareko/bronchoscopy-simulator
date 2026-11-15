# Prior art: bronchoscopy simulators and VR medical trainers

**Status:** research note for v0.1 scoping · **Date:** 2026-11-15 · **Author:** research subagent
**Scope:** commercial bronchoscopy simulators, physical/hybrid trainers, adjacent VR medical
training companies, open-source projects, and the published validation literature.
**Audience:** the maintainers of this repo (Godot 4.7 + OpenXR, HTC Vive wands, Linux, eight
cases, synthetic labelled airway graph now / CT pipeline later).

---

## 0. How to read this document

Every non-obvious claim carries a URL. Where a statement comes from a vendor's own marketing
it is marked **(vendor claim)**; where it comes from a peer-reviewed study it is marked
**(published)**. Internal physics, per-case counts, prices and installed base are, for the
closed commercial systems, **not publicly documented** — where that is the case I say so
rather than guessing.

**Method note / limitation.** The hosted `web_search` tool in this environment returned
unrelated results for every query (it appears to be proxied to a broken search backend), and
`html.duckduckgo.com` / Bing / Mojeek were likewise unusable. Research was therefore done by
fetching primary sources directly (`web_fetch` plus direct HTTPS from the shell): vendor sitemaps
and WordPress REST APIs for product inventories, the Europe PMC REST API for literature,
the Steam storefront search API, and the GitHub REST API. That means the bibliography below is
strong on things that have a canonical URL and weak on things that only exist in a magazine
article or a distributor's price list. Treat absence of a product as "not found in this
vendor's published catalogue", not "does not exist".

---

## 1. Executive summary — the eight findings that should change decisions

1. **Everyone who is serious about bronchoscopy uses a scope-shaped input device.** The
   AccuTouch/EndoVR line drives a physical bronchoscope tube with "integrated haptic
   technology" ([CAE tech sheet](https://caehealthcare.com/media/files/TechSheets/EndoVR-TechSheet.pdf));
   the BRONCH Mentor uses "authentic scope, tactile feedback" on an ENDO Suite platform that
   "uses real endoscopes modified for simulation purposes"
   ([brochure](https://surgicalscience.com/wp-content/uploads/2025/11/BRONCH-Mentor-Brochure-2025_10-Web.pdf),
   [ENDO Suite](https://surgicalscience.com/endo-suite-2/)); ORSIM ships a "video-enabled replica
   bronchoscope" plus a desktop sensor unit ([ORSIM design](https://www.orsim.com/design)); the
   newest entrant, Smiloscopy, requires you to supply *any single-use bronchoscope* and senses it
   ([smiloscopy.com](https://smiloscopy.com/)). **None of the products surveyed is
   controller-only.** Our wand-only v1 is therefore an outlier against the entire field, and the
   single highest-value hardware addition is a tracked proxy scope (Vive tracker on a 3D-printed
   or real handle) rather than more rendering.

2. **The field's outcome vocabulary is already standardised, and we should adopt it verbatim.**
   Danish groups score *diagnostic completeness* (DC, segments inspected / 18),
   *structured progress* (SP, correct sequential segment-to-segment progressions / 18),
   *procedure time* (PT) and *mean intersegmental time* (MIT). These are the primary outcomes in
   the 2026 VR-vs-AR RCT ([Naik 2026, Respiration](https://doi.org/10.1159/000551106)) and in the
   2026 digital-twin RCT ([Deng 2026, Thorax](https://doi.org/10.1136/thorax-2025-223147)), and
   are used by AI-scored clinical studies ([BMJ Open 2025](https://doi.org/10.1136/bmjopen-2025-109756)).
   Older commercial metrics — wall hits, mid-lumen time, "red-out" time, segments missed — are
   complementary and also evidence-backed (see §3).

3. **Anatomical *variety* beats anatomical *realism*, and there is an RCT for it.** Novices trained
   on multiple CT-derived bronchial models, rather than one standard model, scored significantly
   higher on a *novel* CT-derived anatomy (DC +2.5 segments, SP +9 progressions, both p<0.001) and
   partly retained the advantage at 3 months ([Deng 2026](https://doi.org/10.1136/thorax-2025-223147)).
   This is the strongest published argument for our planned CT-derived pipeline, and it argues for
   shipping *several* graph variants in v1, not one canonical tree.

4. **The commercial market is converging on exactly our eight-case scope — as five modules.**
   BRONCH Mentor ships: Essential Bronchoscopy (segment naming, IASLC 2009 lymph-node stations,
   forceps/brush/needle/BAL, sedation), Diagnostic Bronchoscopy, Essential EBUS (with a "modified"
   physical needle), Emergency Bronchoscopy (bleeding, foreign body, therapeutic aspiration,
   electrocautery, balloons, grasping forceps) and a CHEST co-developed curriculum with
   Training vs Assessment modes. That is our cases 1, 2, 4, 5, 6, 7 and part of 3 and 8. **The
   differentiation available to us is not "more cases"; it is openness, Linux/OpenXR, CT-derived
   variety, and automated debrief.**

5. **Published head-to-head evidence is thin, small and mostly single-centre — and the best of it
   is about *transfer*, not fidelity.** Strongest: an RCT in anaesthetised patients showing 60 min
   of ORSIM practice improved fibreoptic intubation GRS and time versus no training
   ([Wong 2019, EJA](https://doi.org/10.1097/EJA.0000000000000890)); a crossover trial showing a
   5-minute simulator warm-up cut live FOI time by 37%/26% ([Samuelson 2016, BJA](https://doi.org/10.1093/bja/aev436)).
   The Cochrane review of VR endoscopy finds only moderate-certainty benefit over *no* training and
   insufficient evidence to replace conventional training
   ([Sabrie 2025, CDSR](https://doi.org/10.1002/14651858.CD008237.pub4)). Nobody has published a
   trial isolating *haptics* as the active ingredient.

6. **Experienced bronchoscopists do not think the expensive computer simulator is more realistic
   than a bag of pig lungs.** 26 bronchoscopists rated a low-cost ventilated porcine-lung
   biosimulator as realistic (4.64/5) and "compared favourably to the computer simulator"
   (4.84/5, i.e. versus CAE AccuTouch) ([Garner 2019, ERJ Open Res](https://doi.org/10.1183/23120541.00035-2019)).
   Corollary: airway *behaviour* (compliance, secretions, cough, lens soiling) buys credibility
   more cheaply than photoreal mucosa. Spend the effort there.

7. **The commercial simulator's own validation found the weak spots — and they are our targets.**
   The BRONCH Mentor construct-validity study discriminated expertise on scope manipulation
   (wall hits, mid-lumen time) and airway anatomy, but **failed to discriminate** on "guided
   anatomic navigation" and lymph-node identification ([Pastis 2014, J Bronchology](https://doi.org/10.1097/LBR.0000000000000111)).
   Orientation and station knowledge are the parts the market leader does least well.

8. **There is no open-source VR bronchoscopy trainer, and nothing on Steam.** Steam's storefront
   API returns **zero** results for "bronchoscopy", "bronchoscope" and "endoscopy"; the only
   adjacent hits are a single "VR TKA Surgery Simulator"
   ([Steam app 2651810](https://store.steampowered.com/app/2651810/)) and anatomy viewers. On
   GitHub the closest thing is **BronchSim**, a browser Three.js trainer with a CT-derived airway,
   a schematic map, labels and a quiz mode, CC BY 4.0 — desktop, not VR
   ([repo](https://github.com/andreajonas/bronchsimulator), [live](https://bronchsimulator.com)).
   The open-source *content pipeline* is much stronger than the open-source *trainers*:
   **Fraxinus** (SINTEF, BSD-3-Clause) already does CT → AI segmentation → target → route →
   virtual-bronchoscopy fly-through synchronised with CT + an EBUS simulator, Ubuntu-first
   ([repo](https://github.com/SINTEFMedtek/Fraxinus)).

---

## 2. Comparison tables

### 2.1 Systems, hardware, platform, price

| System | Vendor / status | Input device | Display | OS / platform | Price | Evidence status |
|---|---|---|---|---|---|---|
| **BRONCH Mentor** (+ ENDO Suite) | Surgical Science (Sweden); Simbionix acquisition completed 2021 ([news](https://surgicalscience.com/news/surgical-science-completes-the-acquisition-of-simbionix/)) | "Authentic scope", real endoscopes modified for simulation; "tactile feedback" **(vendor claim)**; EBUS module includes an "actual (modified) needle" | 2D monitor(s) on a cart; ENDO Suite is shared with GI/HYST/URO | Proprietary turnkey cart; no Linux/OpenXR; no published OS requirement | Quote-only (site routes to demo/contact; separate "simulation financing" offer) | Construct validity ([Pastis 2014](https://doi.org/10.1097/LBR.0000000000000111)); no independent fidelity benchmark found |
| **BRONCH Express** | Surgical Science, co-developed with CHEST | Table-top portable ("portable table-top version of the BRONCH Mentor") | 2D monitor | Proprietary | Quote-only; marketed as "affordable" **(vendor claim)** | None found specific to Express |
| **CAE AccuTouch EndoscopyVR** | Immersion Medical → CAE; **legacy**: no longer named anywhere in CAE's current site (sitemap scan, 4,236 URLs, 0 hits) | Flexible scope + face-interface mannequin; hardware "capable of simulating the mechanical resistance of a real examination, as well as coughing and the respiratory movements" ([review](https://doi.org/10.36416/1806-3756/e20210361)) | 2D monitor | Proprietary | Not sold by CAE (superseded by EndoVR) | The 2000s validation base ([Ost 2001](https://doi.org/10.1164/ajrccm.164.12.2102087), [Colt 2001](https://doi.org/10.1378/chest.120.4.1333)) |
| **CAE EndoVR** | CAE Healthcare (current bronchoscopy product) | Cart "with integrated haptic technology"; optional **bronchoscopy module with bronchoscope tube**; EBUS tool kit + needle accessory | two 24-inch monitors (datasheet lists `2– 24” flat screen monitors`); touchscreen UI | Proprietary cart; 100–120 V on the US datasheet | Quote-only | One pre-post student study (Gopal, summarised in [SR 2023](https://doi.org/10.1002/hsr2.1398)); classed high-fidelity fibreoptic sim in [BJA 2026 SR](https://doi.org/10.1016/j.bja.2026.01.027) |
| **ORSIM** | Airway Simulation Ltd (Auckland, NZ) | "Video-enabled **replica** bronchoscope" + desktop sensor unit; sensor registers insertion-tube movement; **no force feedback claimed** | **Laptop screen** (2D) | "Dedicated laptop — pre-loaded" (Windows implied, not stated) | Not published (distributor quote) | Best-evidenced bronchoscopy VR sim: [Baker 2016](https://doi.org/10.1093/bja/aew059), [Samuelson 2016](https://doi.org/10.1093/bja/aev436), [Wong 2019 RCT](https://doi.org/10.1097/EJA.0000000000000890), [Sun 2026](https://doi.org/10.1186/s12871-026-03809-9) |
| **Smiloscopy** | Genuine Smile Simulators GbR (Germany); pre-order, app released 2026-04 | **Your own single-use bronchoscope** + "smart sensors"; gamified "miniature world" | Phone/tablet app (iOS/Android) + sensors | App-based; portable, "hard case + battery" | "Budget-smart", pre-order, price not published **(vendor claim)** | None yet (no publications found) |
| **Kyoto Kagaku MW19** | Kyoto Kagaku (Japan) | None — **physical mannequin**; you insert a real fibrescope | Direct optics | N/A | Not published in the catalogue excerpt used | None specific; MW19 is a trainer, not a simulator |
| **TruCorp AirSim Bronchi** | TruCorp (Belfast) | Physical mannequin + real scope/ bronchoscope | Direct optics; visual indicators of lung expansion | N/A | Quote-based | TruCorp AirSim rated LoR 3 in [BJA 2026 SR](https://doi.org/10.1016/j.bja.2026.01.027) (construct + face validity yes, concurrent no) |
| **BronchoBoy / Koken manikins** | Nakhosteen CLA (Coburg) / Koken (Tokyo) | Physical | Direct optics | N/A | **USD 3,734** (BronchoBoy), **USD 7,181** (Koken) ([BMC Pulm Med 2024](https://doi.org/10.1186/s12890-024-02846-9)) | Used as the reference phantom in [Naik 2026](https://doi.org/10.1159/000551106), [BronchoBot 2026](https://doi.org/10.1183/23120541.00970-2025) |
| **Cadaver / porcine lung** | Wet lab | Real scope | Direct optics | N/A | ~**USD 1,000/day** (Thiel cadaver), **USD 215** (preserved porcine lung) ([BMC 2024](https://doi.org/10.1186/s12890-024-02846-9)) | Reference standard for realism in [Garner 2019](https://doi.org/10.1183/23120541.00035-2019) |
| **Fraxinus** | SINTEF (Norway), open source | Mouse/keyboard; no haptics | 2D + 3D views | **Ubuntu-first**, Windows build available ([repo](https://github.com/SINTEFMedtek/Fraxinus)) | Free | Used as a research/planning platform; not a validated trainer |
| **BronchSim** | A. Jonas (Stanford), open source | On-screen joystick (no hardware) | Browser (Three.js) | Web, no install | Free | None (educational tool) |

### 2.2 Content, scope model, metrics and teaching features

| System | Case library (published module names) | Tool / working channel | Metrics & debrief | Curriculum & teaching features |
|---|---|---|---|---|
| **BRONCH Mentor** | Essential Bronchoscopy, Diagnostic Bronchoscopy, Essential EBUS, Emergency Bronchoscopy, CHEST Standardized Curriculum ([product](https://surgicalscience.com/simulators/gi-bronch-mentor/)) | Biopsy forceps, cytology brush, aspiration needle, BAL; grasping forceps, balloons, electrocautery probes; EBUS needle ("actual (modified) needle") | "Performance metrics for self-assessment and competence demonstration"; MentorLearn Cloud: "simulation video capture, ideal for debriefing" ([brochure](https://surgicalscience.com/wp-content/uploads/2025/11/BRONCH-Mentor-Brochure-2025_10-Web.pdf)) | Aided/un-aided cases; skill tasks vs procedural tasks; didactic "demos"/tutorial movies; Training Mode vs Assessment Mode; clinical decision-making quizzes inside the case ([CHEST module](https://surgicalscience.com/simulators/gi-bronch-mentor/chest-standardized-curriculum/)) |
| **CAE EndoVR** | Bronchoscopy package: Introduction, BAL, TBNA, paediatric difficult airways, endobronchial sampling; plus EBUS-TBNA module ([package page](https://www.caehealthcare.com/surgical-simulation/surgical-cases/bronchoscopy-pathology-package/)) | Scope tube; EBUS needle accessory; medications, vitals, accessories per case | "Metrics to track time, proficiency, dexterity and complications for each task and **compare a learner's results with the instructor's established acceptable results**"; per-learner usage summaries ([tech sheet](https://caehealthcare.com/media/files/TechSheets/EndoVR-TechSheet.pdf)) | Didactic content per task: objectives, instructions, **demos**, case history, pre-procedure parameters, post-procedure review; printed "oral and lower GI anatomy plates" as a physical reference |
| **ORSIM** | 30 scenarios incl. 12 common/uncommon difficult airways; **Paediatrics I (12 scenarios)**; **Pulmonology I (15 scenarios)** ([orsim.com](https://www.orsim.com/), [software updates](https://www.orsim.com/software-updates)) | Not documented (bronchoscopy-only tasks) | "Metrics for objective scoring… instant feedback is provided through session recording"; recording + **play-back** ([features](https://www.orsim.com/features)) | Part-task practice + full scenarios; designed for 5-minute warm-up use (that is what the published trials tested) |
| **Smiloscopy** | Missions with "storylines"; each unlockable challenge has its own plot | Real scope mechanics; no tissue interaction modelled | Timer, per-user progress tracking, leaderboard; "precision matters" | Gamification: missions, competition mode, leaderboards; "learn, laugh, master" positioning for break-room use |
| **Kyoto Kagaku MW19** | Single anatomical model: "trachea and bronchi anatomically correct, including the tracheal bifurcation down to the segmental bronchi" | Real fibrescope; no tools | None (physical) | Techniques listed: fibreoptic insertion and handling, **recognition of bifurcations**, airway-opening manoeuvres, sniffing position ([catalogue, p.105](https://www.kyotokagaku.com/downloads/2024_catalogo_de_productos_es.pdf)) |
| **TruCorp AirSim Bronchi** | Diagnostic bronchoscopy, single-lung isolation, oral/nasal intubation, supraglottic devices, fibreoptic exam ([product](https://trucorp.com/product/airsim-bronchi/)) | Real scope/tube; inflatable tongue bulb for oedema; visual lung/stomach indicators | No digital metrics; "real-time feedback" is mechanical/visual | Neck locks for positioning; <5 min setup; rated to 80,000 intubation cycles, 3-year warranty |
| **Fraxinus** | Patient-specific, from any chest CT | n/a (planning + virtual fly-through); **EBUS simulator** | Route length, target, CT cross-sections | Four-step workflow: import CT → AI segmentation → set target/route → virtual bronchoscopy + planning review ([repo](https://github.com/SINTEFMedtek/Fraxinus)) |
| **BronchSim** | One CT-derived airway, segmentally labelled | n/a | None beyond quiz | On-screen joystick, schematic map, **on-demand anatomy/quiz mode** ([repo](https://github.com/andreajonas/bronchsimulator)) |

### 2.3 Which of our eight cases already has prior art

Legend: ● shipped as an explicit module/case type · ◐ partial or inferable · ○ not found

| Our case | BRONCH Mentor | CAE EndoVR | ORSIM | Physical models | Fraxinus / BronchSim | Clinical nav systems |
|---|---|---|---|---|---|---|
| 1. Anatomy tour + segment ID | ● (segments by name, IASLC stations, "Cyberscopy") | ● (intro) | ◐ (airway anatomy, not segment drill) | ◐ (BronchoBoy RB1/RB6 checks) | ● BronchSim (labels + quiz); ● Fraxinus (CT anatomy) | ○ |
| 2. Peripheral lesion + biopsy/brush | ◐ (transbronchial sampling; no documented RP-EBUS/peripheral module) | ◐ (endobronchial sampling, TBNA) | ○ | ◐ (BronchoBoy sampling) | ● Fraxinus (target + route) | ● (ENB / shape-sensing / CBCT-AF) |
| 3. Secretions / mucus plug + suction | ● (Emergency: "therapeutic aspiration… bronchoscopic pulmonary toilet") | ○ | ○ | ◐ (cadaver/porcine have secretions) | ○ | ○ |
| 4. Airway bleeding | ● (Emergency: endobronchial bleeding + tools) | ○ | ○ | ◐ (wet lab) | ○ | ○ |
| 5. Foreign body retrieval | ● (Emergency: "foreign body removal using a selection of tools") | ○ | ○ | ◐ | ○ | ○ |
| 6. BAL / lavage | ● (Essential + Diagnostic) | ● (BAL) | ○ | ◐ (volume/leak/retrieval checks in [BMC 2024](https://doi.org/10.1186/s12890-024-02846-9)) | ○ | ○ |
| 7. EBUS-TBNA stations | ● (Essential EBUS + physical needle) | ● (EBUS-TBNA module) | ○ | ○ | ● Fraxinus EBUS simulator | ◐ (convex-probe EBUS integrated) |
| 8. Difficult airway / stenosis | ◐ (case-dependent, not a named module) | ● (paediatric difficult airways) | ● (12 difficult airways + 12 paediatric) | ● (MW19, AirSim Bronchi) | ○ | ◐ |

**Read-across:** cases 3, 4 and 5 are shipped *only* by BRONCH Mentor's Emergency module — the
least-evidenced and most differentiated corner of the market. Cases 2 and 7 are where the
clinical-world technology (ENB, shape sensing) is racing ahead of the training simulators.

---

## 3. What has actually been shown (evidence table)

| Study | Design / n | What it tested | Result | Caveats |
|---|---|---|---|---|
| [Ost 2001, AJRCCM](https://doi.org/10.1164/ajrccm.164.12.2102087) | Multicentre prospective cohort, experts (n=9) vs intermediate (8) vs novice (11), + learning-curve phase | AccuTouch-era bronchoscopy simulator validity | Simulator metrics distinguished experience groups; subsequent training improved novices | Older device; simulator-only outcomes |
| [Colt 2001, Chest](https://doi.org/10.1378/chest.120.4.1333) | Prospective, 5 novices vs senior trainees | VR skill-centre training | Novices rapidly acquired basic skills "comparable" to conventionally trained seniors | Tiny n, no randomisation |
| [Pastis 2014, J Bronchology](https://doi.org/10.1097/LBR.0000000000000111) | 2 centres, 20 bronchoscopists in 3 experience groups | **BRONCH Mentor** construct validity, 4 tasks | Discriminated on scope manipulation (final score, time, **mid-lumen time**, **wall hits**) and airway anatomy; **did not** discriminate on guided navigation or LN anatomy | No transfer outcome; small groups |
| [Baker 2016, BJA](https://doi.org/10.1093/bja/aew059) | 28 subjects (novice/trainee/expert), 196 videos, 3 blinded raters | **ORSIM** validity & reliability | Expert–novice differences p<0.0001; inter-rater reliability >0.8 | Assessment validity, not training effect |
| [Samuelson 2016, BJA](https://doi.org/10.1093/bja/aev436) | Crossover, 33 anaesthesia residents, live patients | 5-min simulator **warm-up** before live FOI | Time −37% (CA1) / −26% (CA2); skill score +4.8/+5.1 points | Warm-up effect, not curriculum effect |
| [Wong 2019, EJA](https://doi.org/10.1097/EJA.0000000000000890) | RCT, NCT02699242, novices, **patients** | 60 min ORSIM vs no simulation | GRS 22.9→28.2 (p=0.04); intubation time 177.6→119.3 s (p=0.01); control unchanged | Single centre; intubation task, not diagnostic bronchoscopy |
| [Sun 2026, BMC Anesthesiol](https://doi.org/10.1186/s12871-026-03809-9) | 15 novices vs 15 experts, 12-case ORSIM test, Messick framework | Can a portable VR sim support summative assessment? | Cronbach α 0.89; 6 cases enough formatively, 10 summatively; pass mark 34.4%; 2 false positives, 1 false negative | One centre, one device |
| [Naik 2026, Respiration](https://doi.org/10.1159/000551106) | RCT, 30 novices, mastery learning on VR vs AR | Navigation performance + cognitive load | VR better DC on first test; AR faster on its own model; VR lower mental demand but higher **physical** demand (NASA-TLX) | Short training window (≤2 h); two different phantoms |
| [Deng 2026, Thorax](https://doi.org/10.1136/thorax-2025-223147) | RCT, 60 novices, 3 arms | Training on **one** vs **many** CT-derived models | Variety > uniformity on a novel CT anatomy (DC +2.5 segments, SP +9, p<0.001); partly retained at 3 months | Digital-twin device not commercially named |
| [Sabrie 2025, Cochrane](https://doi.org/10.1002/14651858.CD008237.pub4) | 20 trials, 500 participants, GI endoscopy | VR vs no training / vs conventional | VR vs none: independent completion RR 1.62 (moderate certainty). VR vs conventional: RR 0.45 (fewer completions, low certainty). **Insufficient evidence to replace** conventional training | GI, not bronchoscopy; heterogeneous |
| [SR 2023, Health Sci Rep](https://doi.org/10.1002/hsr2.1398) | Systematic review, only **8** studies | VR bronchoscopy learning outcomes | All positive on dexterity; speed mixed; no negative effects reported | Small, methodologically weak primary studies |
| [BJA 2026 SR](https://doi.org/10.1016/j.bja.2026.01.027) | 17 articles, 29 simulator evaluations | Validation quality of airway simulators | Only ORSIM (with SimMan/HPS) reached level of recommendation 2; AccuTouch and others fell in the 3–4 band | Airway management, not diagnostic bronchoscopy |
| [Garner 2019, ERJ Open Res](https://doi.org/10.1183/23120541.00035-2019) | 26 bronchoscopists, Likert vs CAE AccuTouch | Low-cost porcine-lung biosimulator | Realistic 4.64/5; "compared favourably to the computer simulator" 4.84/5 | Subjective ratings, single device |
| [BMC Pulm Med 2024](https://doi.org/10.1186/s12890-024-02846-9) | 7 experienced physicians × 4 models | BronchoBoy vs Koken vs Thiel cadaver vs porcine lung | Detailed practical differences (generations, secretions, BAL leakage, sampling feasibility) and prices | Small expert panel |

**What is *not* established anywhere:** that haptic force feedback improves bronchoscopy skill;
that photoreal rendering improves transfer; that any simulator shortens time-to-competency in
patients (as opposed to improving a simulator or a single intubation task); and any head-to-head
comparison between BRONCH Mentor and EndoVR.

---

## 4. Per-product notes

### 4.1 BRONCH Mentor (Surgical Science; formerly Simbionix, then 3D Systems)

The market leader and the only product that covers almost our whole case list.

- **Lineage.** Simbionix's simulator business was owned by 3D Systems (papers from that era cite
  "3D Systems by Simbionix"), and Surgical Science completed its acquisition of Simbionix in 2021
  ([Surgical Science news](https://surgicalscience.com/news/surgical-science-completes-the-acquisition-of-simbionix/);
  naming per [J Minim Invasive Gynecol 2022](https://doi.org/10.1016/j.jmig.2022.01.016)).
  Older papers call it the "Simbionix Bronch Mentor" or "GI-Bronch Mentor".
- **Hardware.** Runs on the **ENDO Suite** platform, which "uses real endoscopes modified for
  simulation purposes" and is shared across GI Mentor, BRONCH Mentor, HYST Mentor and URO Mentor
  ([ENDO Suite](https://surgicalscience.com/endo-suite-2/)). The brochure claims "authentic scope,
  tactile feedback, and flexible setup for solo or team training", plus "virtual patient cases
  modeled after real patients" and "sedation, anesthesia, vital signs, cough, and complications"
  ([brochure PDF](https://surgicalscience.com/wp-content/uploads/2025/11/BRONCH-Mentor-Brochure-2025_10-Web.pdf)).
  The **EBUS module uses an "actual (modified) needle"** ([EBUS module](https://surgicalscience.com/simulators/gi-bronch-mentor/essential-ebus-module-2/))
  — i.e. the company's answer to haptics is *real hardware*, not a rendered force model.
- **Modules.**
  - *Essential Bronchoscopy* — developed with and endorsed by **AABIP**. Biopsy forceps, cytology
    brush, aspiration needle, BAL; user manages moderate sedation, topical anaesthesia, vitals, level
    of consciousness, oxygen; reactive complications. Learning objectives explicitly include
    "identify each bronchial segment **by name**" and the **IASLC 2009** lymph-node map. Sub-sections
    are "Bronchial Anatomy", "**Cyberscopy**", "Diagnostic Maneuvers"
    ([module page](https://surgicalscience.com/simulators/gi-bronch-mentor/essential-bronchoscopy/)).
    "Cyberscopy" is the name they use for a pure scope-handling drill — the commercial equivalent of
    a hole-in-target task.
  - *Diagnostic Bronchoscopy* — BAL, endobronchial biopsy, needle TBNA; "variety of virtual patients,
    each exhibiting unique anatomy, pathologies and altering response to moderate sedation"
    ([module page](https://surgicalscience.com/simulators/gi-bronch-mentor/diagnostic-bronchoscopy/)).
  - *Emergency Bronchoscopy* — endobronchial bleeding, aspirated foreign bodies, therapeutic
    aspiration; tools include grasping forceps, balloons, electrocautery probes; complications
    include pneumothorax, bleeding, hypoxaemia, hypotension, arrhythmia, cardiac arrest
    ([module page](https://surgicalscience.com/simulators/gi-bronch-mentor/emergency-bronchoscopy/)).
  - *Essential EBUS* — skills tasks + clinical cases for EBUS-TBNA; Doppler, US depth/gain/contrast,
    external display, **multi-plane CT**, tutorial movies, **anatomical labels**, "real-time guidance"
    ([module page](https://surgicalscience.com/simulators/gi-bronch-mentor/essential-ebus-module-2/)).
  - *CHEST Standardized Curriculum* — co-developed with the American College of Chest Physicians;
    Essential Skills segment + Clinical segment; **Training Mode vs Assessment Mode**; clinical
    decision-making quizzes interleaved with hands-on performance
    ([module page](https://surgicalscience.com/simulators/gi-bronch-mentor/chest-standardized-curriculum/)).
- **Teaching/admin tooling.** *MentorLearn* (cloud LMS: course administration, remote learning,
  results monitoring, "simulation video capture, ideal for debriefing"). *MScore* (documented for
  FlexVR): scoring derived from the FLS system, web dashboards, "instantly understand how a
  trainee's performance compares to that of an expert"
  ([MScore page](https://surgicalscience.com/simulators/flexvr/mscore-portal/)). Note FlexVR itself
  uses **3D shutter glasses, not a headset** ([FlexVR platform](https://surgicalscience.com/simulators/flexvr/platform/))
  — "VR" in this market often means stereoscopic desktop, not OpenXR.
- **Portable tier.** *BRONCH Express* is a "portable table-top version", co-developed with CHEST,
  carrying Essential Bronchoscopy / Diagnostic / Essential EBUS
  ([page](https://surgicalscience.com/simulators/bronch-express/), [modules](https://surgicalscience.com/simulators/bronch-express/essential-bronchoscopy-module/)).
  The AABIP's Certificate of Added Qualification in Advanced Diagnostic Bronchoscopy reportedly uses
  simulation in its assessment ([same page](https://surgicalscience.com/simulators/bronch-express/)) — vendor claim.
- **What is *not* public:** the scope kinematics model, how the lever is instrumented, force-feedback
  actuator design, number of cases per module, prices, installed base.

### 4.2 CAE Healthcare — AccuTouch EndoscopyVR (legacy) and EndoVR (current)

- **AccuTouch** is the product the bronchoscopy literature refers to. A 2022 review describes it as
  a flexible scope plus a computer, with "an interface [that] is a replica of the human face, with an
  access area in the nasal region for insertion of the scope", hardware "capable of simulating the
  mechanical resistance of a real examination, as well as coughing and the respiratory movements",
  returning procedure time, **"red out" time**, wall-contact count, segments inspected and suction
  use, with lidocaine injection, biopsy and multiple scenarios
  ([J Bras Pneumol 2022](https://doi.org/10.36416/1806-3756/e20210361)).
- **Status.** The name no longer appears anywhere in CAE's current sitemap; CAE's live endoscopy
  product is **EndoVR** ([product page](https://www.caehealthcare.com/surgical-simulation/EndoVR/)).
- **EndoVR hardware** (from the [tech sheet PDF](https://caehealthcare.com/media/files/TechSheets/EndoVR-TechSheet.pdf)):
  cart with "integrated haptic technology", UI software, **two 24″ monitors**, keyboard + trackball,
  printed anatomy plates, and optional modules including a "bronchoscopy module with **bronchoscope
  tube**" and an EBUS-TBNA module with "EBUS-TBNA needle accessory". Marketing: "virtual reality,
  haptics, and real patient cases"; "haptic technology that accurately replicates the use of a scope".
- **Metrics.** "time, proficiency, dexterity and complications for each task", plus **comparison of a
  learner's results with the instructor's established acceptable results**, and per-learner usage
  summaries. Pedagogically this is the "expert benchmark" pattern — worth copying.
- **Content.** Bronchoscopy package = Introduction, BAL, TBNA, **paediatric difficult airways**,
  endobronchial sampling ([package page](https://www.caehealthcare.com/surgical-simulation/surgical-cases/bronchoscopy-pathology-package/)).
- **Evidence.** Weaker than BRONCH Mentor's and ORSIM's: the 2023 systematic review includes one
  pre-post study of 47 medical students (Gopal) reporting improved skills/knowledge
  ([SR 2023, Table 1](https://doi.org/10.1002/hsr2.1398)); the 2026 BJA review classes EndoVR as
  high-fidelity but in a lower recommendation band than ORSIM.

### 4.3 ORSIM (Airway Simulation Ltd, New Zealand) — the most evidenced device

- **Form factor.** Three parts: a **video-enabled replica bronchoscope**, a **desktop sensor unit**,
  and a **dedicated laptop**; "the sensor registers movement of the insertion tube and translates this
  to a three-dimensional virtual airway displayed through the software on the laptop screen". 9 kg,
  hard case, "rapid start-up" ([design](https://www.orsim.com/design)). **No haptic/force feedback is
  claimed anywhere** — the realism comes from the replica handle's own mechanics plus a real
  insertion sensor. This is a very important data point for us: the best-validated bronchoscopy
  simulator in the literature has *no* active force feedback.
- **Content.** 30 scenarios including 12 common and uncommon difficult airways; paid add-on modules
  **Paediatrics I (12 scenarios)** and **Pulmonology I (15 scenarios)**
  ([home](https://www.orsim.com/), [software updates](https://www.orsim.com/software-updates)).
- **Metrics/feedback.** "Metrics for objective scoring… instant feedback… through session recording",
  "recording and play-back" ([features](https://www.orsim.com/features)).
- **Evidence.** The deepest of any device: validity/reliability (Baker 2016), warm-up transfer
  (Samuelson 2016), a patient-outcome RCT (Wong 2019), and a 12-case summative test with a defensible
  pass mark (Sun 2026). Independent rating: the only bronchoscopy-specific device in the highest
  recommendation band of the 2026 BJA airway-simulator review
  ([BJA 2026](https://doi.org/10.1016/j.bja.2026.01.027)).
- **Why it matters to us.** ORSIM proves that a *sensor + replica handle + laptop* is enough to
  produce transferable skill. It is the architecture we should emulate for input, then upgrade the
  display to HMD and the anatomy to CT-derived variety.

### 4.4 Smiloscopy (Germany) — the newest entrant, and the cheapest credible haptic answer

- **Concept.** "Gamified" bronchoscopy trainer: **an actual bronchoscope is your game controller**,
  "smart sensors recognise your progress", an "immersive miniature world", missions with storylines,
  a timer, per-user progress tracking, team competition/leaderboards, and leaderboard-driven
  repeat play designed for "10 minutes between routine tasks"
  ([site](https://smiloscopy.com/), [App Store listing](https://apps.apple.com/us/app/smiloscopy/id6743859420)).
- **Hardware.** Hard case + battery, "works with any single-use bronchoscope", "Made in Germany",
  accompanied by a free iOS/Android app. Pre-order; no price published; "budget-smart" **(vendor claim)**.
- **Why it matters.** It removes the expensive part of haptics by using the trainee's real scope and
  selling only sensing + software. If our project ever wants a physical input, a 3D-printed handle
  with a Vive tracker is the DIY version of the same idea.
- **Evidence.** None yet. No publications, no validation. Treat as a design signal, not a benchmark.

### 4.5 Kyoto Kagaku MW19 — the physical difficult-airway trainer

- Kyoto Kagaku's English product listing and catalogue contain **no bronchoscopy *simulator***, but they
  do ship **MW19, "Difficult Airway Management Simulator for Bronchofibroscopy"**: anatomically
  correct trachea and bronchi "including the tracheal bifurcation down to the segmental bronchi",
  soft resin, latex-free, 2.65 kg, designed for "insertion and handling of the fibrescope",
  "recognition of the bifurcations with the fibrescope", airway-opening manoeuvres and sniffing
  position; **instruments not included**
  ([catalogue PDF, p.105](https://www.kyotokagaku.com/downloads/2024_catalogo_de_productos_es.pdf)).
- Also relevant from the same catalogue: airway suction trainers (for our secretions case), and the
  usual airway-management manikins.
- **Reading:** Kyoto Kagaku competes on *anatomical fidelity of the physical tree*, not on VR. The
  MW19 is a useful reference for how much branching detail is enough for "bifurcation recognition".

### 4.6 TruCorp AirSim Bronchi and the "BronchoBoy" family

- **AirSim Bronchi** — physical mannequin for "diagnostic bronchoscopy, single lung isolation
  techniques, oral/nasal intubation", adjustable neck locks, an **inflatable tongue bulb** to create
  tongue oedema, integrated visual indicators of stomach inflation and lung expansion, <5 min setup,
  certified for 80,000+ intubation cycles, 3-year warranty
  ([product page](https://trucorp.com/product/airsim-bronchi/), [category](https://trucorp.com/bronchoscopy-simulators/)).
  This is the "hybrid" many centres actually buy: real scope, real airway feel, no software.
- **BronchoBoy (Nakhosteen CLA, Coburg)** and **Koken Bronchoscopy Training Model** — the two
  manikins used as the reference phantom in the Danish VR-vs-AR trial and the BronchoBot study.
  Public characteristics and prices are tabulated in [BMC Pulm Med 2024](https://doi.org/10.1186/s12890-024-02846-9):
  BronchoBoy USD 3,734, rubber, **4 bronchial generations**, no secretions; Koken USD 7,181, silicone,
  **5 generations**, no secretions; Thiel cadaver ~USD 1,000/day, 20+ generations, secretions;
  preserved porcine lung USD 215, 20+ generations, secretions.
- The same paper's observation checklist is a ready-made competency rubric and is worth reading in
  full: segments identified; can you reach **RB1 and RB6** with and without an instrument in the
  channel; how far can you advance in RLL and LUL; **how many times did you have to clean the lens**;
  BAL instilled volume, leakage, and whether ≥30% was retrieved; three successful sampling procedures.

### 4.7 Adjacent commercial platforms with **no** bronchoscopy product

Checked because the brief asked; each is a potential partner/competitor for *platform* ideas rather
than content.

| Company | What they actually sell | Bronchoscopy? |
|---|---|---|
| **Mentice** | Vascular/interventional simulation: VIST hardware, clinical learning modules, physiological flow systems, Ankyras decision-support ([mentice.com](https://www.mentice.com/)) | No product found |
| **VirtaMed** | ArthroS, GynoS, LaparoS, RoboS, UroS ([simulator list](https://www.virtamed.com/en/products-and-solutions/simulators/arthros)) | No product found |
| **Medical-X** | ADAM-X, MARCH-X, NenaSim, Lap-X (box/VR/hybrid) ([products](https://medical-x.com/products/lap-x-vr)) | No product found |
| **InSimo** | SOFA-based soft-tissue simulation; ultrasound, puncture/injection, thoracentesis, robotic surgery, HelpMeSee cataract ([insimo.com](https://www.insimo.com/)) | No product found; their **thoracentesis** and soft-tissue tech is the closest transferable asset |
| **Fundamental XR** (formerly FundamentalVR) | "HapticVR" ophthalmology, robotics, interventional cardiology (coming), orthopaedics (coming) ([clinical areas](https://www.fundamentalxr.com/clinical-areas)) | No product found |
| **Osso VR** | Orthopaedic/procedural VR with enterprise + academy tiers ([ossovr.com](https://ossovr.com/)) | No |
| **Precision OS** | Immersive VR orthopaedic modules (e.g. femoral IMN), used in medical-student and resident curricula ([J Surg Educ 2026](https://doi.org/10.1016/j.jsurg.2025.103791)); no verified product page found from this environment | No |
| **SimX** | VR clinical/team scenario training, subscription ([simx.com](https://www.simx.com/)) | No |
| **Arch Virtual** | Custom medical VR development + Acadicus platform ([archvirtual.com](https://www.archvirtual.com/)) | No off-the-shelf product |
| **ImmersiveTouch** | ImmersiveView / ImmersiveAR — patient-specific DICOM→VR for planning and rehearsal ([immersivetouch.com](https://www.immersivetouch.com/)) | No; but their patient-specific pipeline is the closest analogue to our CT-later plan |
| **AnatomyX** | Full-body 3D anatomy in AR on Quest 3/3S and HoloLens 2 ([anatomyx.com](https://anatomyx.com/)) | No (anatomy education only) |
| **Level Ex** | Was the maker of **Airway Ex**, a bronchoscopy mobile game; the life-sciences division is now **Relevate Health Games** ([levelex.com](https://www.levelex.com/)) | Historical only — see below |

**Airway Ex** deserves a footnote because it is the only *mobile* bronchoscopy trainer with an RCT:
adding 30 minutes of self-directed Airway Ex to conventional manikin training was tested in a
randomised trial of emergency-department doctors
([Yau 2021, Ann Acad Med Singap](https://doi.org/10.47102/annals-acadmedsg.2020431)). Its existence
and subsequent corporate pivot is a caution: content-only apps without hardware, curriculum or
institutional reporting do not sustain a business in this market.

### 4.8 Clinical navigation systems — UX prior art, not trainers

Trainees will meet electromagnetic navigation, shape-sensing robotic bronchoscopy (Intuitive Ion),
and cone-beam CT with augmented fluoroscopy in the suite. The relevant transferable UX is:
a **virtual airway map with live tip position and a planned route to a target**, plus **CT/fluoroscopy
correlation**, with the known failure mode being **CT-to-body divergence**
([Diagnostics 2026 review](https://doi.org/10.3390/diagnostics16193151);
[CBCT augmented-fluoroscopy study](https://doi.org/10.21037/jtd-2026-2065)).
A 2026 phantom study colocated a **live bronchoscope video stream with patient-specific 3D airway
models on Apple Vision Pro** — evidence that HMD-based anatomy overlay is technically feasible, with
no clinical benefit claimed ([JMIR XR 2026](https://doi.org/10.2196/103880)).

**Design implication:** the map/route/tip overlay is the pattern trainees already see in the OR. Our
minimap and ghost path should deliberately *look like* the navigation systems they will use, and we
should model divergence (a "CT was taken at full inspiration, patient is now supine" error) as an
advanced case rather than pretending the map is always true.

---

## 5. Synthesis

### 5.1 Recurring must-have features across successful products

| Feature | Products that have it | Why it matters (evidence or reasoning) |
|---|---|---|
| **Scope-shaped physical input** (real, modified, or replica handle with a sensor) | BRONCH Mentor, AccuTouch/EndoVR, ORSIM, Smiloscopy | The skill is lever + torque + insertion (see `docs/04-scope-model.md`); every credible product instruments a real handle. ORSIM achieves strong validity with **no** force feedback — the handle mechanics and sensor are what count. |
| **Named segment-level anatomy** | BRONCH Mentor (segments by name, IASLC stations), CAE, BronchSim, Fraxinus | DC/SP scoring is defined over the 18 segments ([Naik 2026](https://doi.org/10.1159/000551106), [Deng 2026](https://doi.org/10.1136/thorax-2025-223147)); "identify each bronchial segment by name" is a stated learning objective of the market leader. |
| **Objective metrics beyond time** | BRONCH Mentor (wall hits, mid-lumen time), AccuTouch (red-out time, contacts, segments, suction use), ORSIM (composite scores) | Wall hits and mid-lumen time are the measures that actually discriminated expertise on the market leader ([Pastis 2014](https://doi.org/10.1097/LBR.0000000000000111)). |
| **Record + replay debrief** | ORSIM (recording/play-back), MentorLearn Cloud (video capture for debriefing), CAE (compare to instructor benchmark) | Replay is the cheapest way to convert metrics into learning; every mature product does it. |
| **Benchmark against expert** | CAE ("instructor's established acceptable results"), MScore ("compares to an expert") | Gives a novice an interpretable reference, not just a number. |
| **Training mode vs assessment mode** | CHEST curriculum (BRONCH Mentor), ORSIM test protocol | Mastery learning needs a test with a defensible pass mark — Sun 2026 shows how (contrasting-groups standard setting). |
| **Case variety / differing anatomy** | BRONCH Mentor ("unique anatomy… each patient"), ORSIM (30 + 12 + 15 scenarios), Deng 2026 | Variety generalises to unseen anatomy; uniformity does not ([Deng 2026](https://doi.org/10.1136/thorax-2025-223147)). |
| **Working-channel tools** | BRONCH Mentor (forceps/brush/needle/BAL/balloon/electrocautery), CAE (BAL/TBNA/EBUS needle), Fraxinus (EBUS) | The procedure *is* the tool choreography; a navigation-only trainer cannot teach sampling. |
| **Patient state that reacts** (sedation, vitals, cough, complications) | BRONCH Mentor, CAE | Distinguishes a procedure trainer from a simulator; underpins our bleeding case's "first 60 seconds". |
| **Portable / lower-cost tier** | BRONCH Express, ORSIM (9 kg), Smiloscopy (hard case, battery) | Access and dose: the evidence for benefit is dose-dependent (2 h > 10 min familiarisation in [O'Grady 2026](https://doi.org/10.1007/s11845-026-04720-5)). |
| **Institutional reporting** | MentorLearn, MScore | Educators buy programmes; a single-user app cannot be timetabled, tracked, or QA'd. |

### 5.2 Common weaknesses and reviewer complaints

1. **Tactile realism is the acknowledged weak point.** A 2022 review of bronchoscopy simulators says
   outright that "even the most up-to-date models reproduce the tactile sensitivity of the examination
   in a rudimentary way, and tactile sensitivity is important"
   ([J Bras Pneumol 2022](https://doi.org/10.36416/1806-3756/e20210361)). Yet no RCT isolates haptics
   as the active ingredient; the transfer evidence (Wong 2019, Samuelson 2016) comes from a device
   (ORSIM) that does not claim force feedback at all.
2. **Cost and procurement friction.** Only the physical models publish prices (USD 215–7,181 in
   [BMC 2024](https://doi.org/10.1186/s12890-024-02846-9)); every VR system is quote-only, cart-based
   capital equipment. The 2023 SR notes the cost argument explicitly, citing Jiang et al. that VR was
   inferior to mannequin training on cost in a Chinese setting ([SR 2023](https://doi.org/10.1002/hsr2.1398)).
   A low-cost porcine-lung model was rated *better than* the CAE simulator by 26 bronchoscopists
   ([Garner 2019](https://doi.org/10.1183/23120541.00035-2019)) — an embarrassing benchmark for
   six-figure carts.
3. **Closed, Windows/proprietary, cart-bound.** ENDO Suite and EndoVR are turnkey carts with vendor
   monitors; ORSIM bundles a laptop; admin data lives in vendor clouds (MentorLearn, MScore). There is
   no published API, no Linux support, and no ability for a teaching department to inspect or edit the
   case content.
4. **Limited anatomy variety and case libraries.** Module *names* are published but not case counts.
   The field's own literature now argues that single-standard-model training does not generalise
   ([Deng 2026](https://doi.org/10.1136/thorax-2025-223147)) — i.e. the commercial model of one curated
   anatomy per case is pedagogically backwards.
5. **Weak discrimination on orientation and station knowledge.** The BRONCH Mentor validity study
   found no significant differences between experience groups on "guided anatomic navigation" or
   lymph-node anatomy ([Pastis 2014](https://doi.org/10.1097/LBR.0000000000000111)). These are exactly
   the skills fellows struggle with.
6. **Emergency/secretions realism is thin.** Only BRONCH Mentor ships bleeding/foreign body/pulmonary
   toilet, and only as a module; lens soiling is a real and measurable burden in physical models
   ([BMC 2024](https://doi.org/10.1186/s12890-024-02846-9)) but is not a documented metric in any VR
   product.
7. **Evidence quality.** Most studies are single-centre, pre-post, unblinded, and measure simulator
   performance rather than patient outcomes. The best available synthesis (Cochrane 2025, GI) rates
   certainty low to moderate and explicitly declines to recommend VR as a replacement for conventional
   training ([Sabrie 2025](https://doi.org/10.1002/14651858.CD008237.pub4)).
8. **HMD ergonomics.** In the only VR-vs-AR bronchoscopy RCT, VR training produced **higher physical
   demand** (NASA-TLX) and longer training time than AR, despite lower mental demand
   ([Naik 2026](https://doi.org/10.1159/000551106)). Aiming a scope while wearing a headset is
   physically taxing — a design constraint for our comfort/teleport/rest posture choices.
9. **Gamification without assessment.** Smiloscopy's leaderboards are engaging, but timers and
   leaderboards can reward speed over completeness — the opposite of DC/SP scoring. Any competitive
   mode we add must be scored on completeness first.

### 5.3 How they model the scope

**Honest caveat:** none of the commercial vendors publish their kinematics, lever instrumentation,
haptic actuator design or collision response. The table below separates *public interface facts* from
*inference*.

| System | Tip articulation | Insertion | Rotation / torque | Force feedback | Wall collision | Suction / tools |
|---|---|---|---|---|---|---|
| BRONCH Mentor | Via a real modified endoscope's own lever (public: "authentic scope") | Real scope shaft fed through the platform | Real shaft torque | Mechanical feel of the real scope; "tactile feedback" **(vendor claim)**; no actuator details published | Not documented; complications imply collision modelling | Physical tools incl. "actual (modified) needle" for EBUS; forceps/brush/needle/BAL; balloon, electrocautery, grasping forceps |
| CAE EndoVR | Bronchoscope tube (module) with "integrated haptic technology" | Physical tube | Physical | Active haptics claimed; no technical detail published | Not documented; "complications" scored | Scope tube + EBUS needle accessory; medications/vitals |
| AccuTouch | Physical flexible scope | Physical | Physical | Hardware "capable of simulating the mechanical resistance… coughing and respiratory movements" ([review](https://doi.org/10.36416/1806-3756/e20210361)) | Contact count metric implies collision detection | Suction button use is a scored metric; lidocaine, biopsy |
| ORSIM | Replica handle's own lever (unpowered) | Insertion tube sensed by desktop unit | Sensed from the tube | **None claimed** — passive mechanics only | Metrics imply it; details unpublished | Minimal (bronchoscopy tasks) |
| Smiloscopy | Real single-use scope (mechanics are the real thing) | Sensed | Sensed | None (scope moves in free air) | Not modelled (game world) | Not documented |
| BronchSim | On-screen joystick steering along a centreline "flight path" | Implicit along path | n/a | None | n/a (path-following) | n/a |
| Fraxinus | Virtual fly-through along computed route | Route parameter | n/a | None | n/a | EBUS simulator |
| **Our model** (`docs/04-scope-model.md`) | Heading vector, lever → 80° desired deflection, 170°/s chase rate, relax-to-lumen assist | Substeps ≤3 mm with wall clamping and wall-slide bias 0.65 | `bend_axis` rotated by roll | None (distance proxy) | Capsule lumen clamp; radial overshoot logged | Not yet |

**The most important technical finding for us:** the open-source world already has the honest
mechanics implemented and reusable. **BeamAdapter** (SOFA plugin, **LGPL-2.1**) implements Kirchhoff
rods for "any 1D flexible structure" — i.e. catheter/guidewire/scope bending — and **SlicerIGT**
(BSD-3-Clause) provides the image-guidance plumbing
([BeamAdapter](https://github.com/sofa-framework/BeamAdapter), [SlicerIGT](https://github.com/SlicerIGT/SlicerIGT)).
If our V2 position-based chain proves insufficient, BeamAdapter's formulation is the reference
implementation to port (respecting LGPL if we link rather than copy).

### 5.4 How anatomy is presented, and how orientation is taught

| Pattern | Seen in | Notes |
|---|---|---|
| **Generic curated anatomy per case** | BRONCH Mentor ("virtual patient cases modeled after real patients"), CAE ("developed using real patient data"), ORSIM ("virtual patients with difficult airways") | Marketing language; no published provenance per case. Effective but limited variety. |
| **Patient-specific CT-derived anatomy** | Fraxinus (any CT, AI segmentation, route), BronchSim (one CT-derived tree), Deng 2026 digital-twin platform | The only pattern with RCT support for generalisation ([Deng 2026](https://doi.org/10.1136/thorax-2025-223147)). |
| **Anatomical labels on demand** | BRONCH Mentor EBUS (labels, multi-plane CT), BronchSim (segment labels + quiz) | Labels-as-scaffold, then removed, is the obvious progression. |
| **Schematic map / minimap** | BronchSim ("schematic map"), Fraxinus (2D/3D views), clinical ENB systems | No commercial VR bronchoscopy trainer documents a live minimap — a gap we can fill. |
| **Route / ghost path to a target** | Fraxinus (computed route), clinical navigation | Standard in the OR; absent from VR trainers as a *teaching* overlay. |
| **Depth markers** | Not documented in any product | Our `depth_mm` is free telemetry; visualising it (and asking trainees to call depth) is a differentiator. |
| **CT/fluoro correlation** | BRONCH Mentor EBUS (multi-plane CT), clinical CBCT-AF | Teaches the radiologic-spatial mapping that BRadSTAT tries to assess ([BRadSTAT 2022](https://doi.org/10.1159/000526011)). |
| **Fluoroscopy** | Clinical only; not in any VR bronchoscopy trainer | Reasonable v2 feature for peripheral lesion work. |
| **Fantastical/gamified world** | Smiloscopy ("miniature world") | Engagement play; explicitly not anatomical, so unsuitable for segment teaching. |

**Orientation is the weakest-taught skill in the market.** The one validity study of the market
leader failed to discriminate expertise on guided navigation ([Pastis 2014](https://doi.org/10.1097/LBR.0000000000000111)),
and no product documents a deliberate orientation curriculum beyond labels and a CT thumbnail. Our
"navigate to a named segment from memory, then verify" loop is a defensible niche.

### 5.5 Shipped case and task types (union across the market)

- **Anatomy / segment identification drills** — BRONCH Mentor Essential ("Bronchial Anatomy",
  "Cyberscopy"), CAE introduction, BronchSim quiz.
- **Pure scope-handling tasks** (hole-in-target style) — BRONCH Mentor "Cyberscopy"; research
  "choose-the-hole"/clock-face bench models ([12-hole clock model RCT 2024](https://doi.org/10.1097/MD.0000000000038510)).
- **Diagnostic bronchoscopy with sampling** — BRONCH Mentor Diagnostic, CAE.
- **BAL** — BRONCH Mentor, CAE, and physical models (with leakage/retrieval checks).
- **EBUS-TBNA** — BRONCH Mentor Essential EBUS (physical needle), CAE EBUS-TBNA, Fraxinus EBUS sim.
- **Emergency/therapeutic** — bleeding, foreign body, pulmonary toilet (BRONCH Mentor Emergency only).
- **Difficult airway / FOI** — ORSIM (30 + paeds 12), CAE paediatric difficult airways, Kyoto MW19,
  TruCorp AirSim Bronchi.
- **Lung isolation / DLT positioning** — TruCorp AirSim Bronchi, thoracic-anaesthesia curricula
  ([J Clin Med 2024 review](https://doi.org/10.3390/jcm13071848)).
- **Patient management / sedation** — BRONCH Mentor, CAE.
- **Non-technical/team training** — vendor "team training" modes (BRONCH Mentor, ANGIO/LAP Mentor);
  no bronchoscopy-specific team evidence found.

### 5.6 UX patterns for teaching scope handling

| Pattern | Who does it | What it looks like | Should we copy? |
|---|---|---|---|
| **Aided vs unaided cases** | BRONCH Mentor ("aided/un-aided clinical cases") | Same case with hints/labels on or off | **Yes** — cheap to implement, high pedagogical value |
| **Didactic demo before attempt** | BRONCH Mentor ("tutorial movies", "demos"), CAE ("demos", "instructions") | Short expert clip, then hands-on | Yes (recorded, not live) |
| **Training vs assessment mode** | CHEST curriculum | Practice with feedback vs silence + score | **Yes** (this is our `--assessment` mode) |
| **Expert benchmark comparison** | CAE (instructor's acceptable results), MScore (expert comparison) | Your trace/score vs a stored reference | **Yes** — a stored expert run is cheap and powerful |
| **Record + replay** | ORSIM (play-back), MentorLearn Cloud (video capture) | Scrub through the run; see where time went | **Yes** (we already log events; add a scrubber) |
| **Real-time guidance overlay** | BRONCH Mentor EBUS ("real-time guidance", labels, CT) | Labels/route drawn over the live view | Yes, but toggleable and scored when off |
| **Quizzes interleaved with performance** | CHEST clinical segment | "Which station is this?" mid-case | **Yes** — cheapest way to test knowledge *in situ* |
| **Gamified missions/leaderboards** | Smiloscopy, Osso-style enterprise modules | Timer, story, competition | Only for optional warm-up; never for summative scoring |
| **Ghost path / expert trace overlay** | **Not documented in any commercial bronchoscopy product**; analogous to clinical "route" lines in Fraxinus/ENB | A translucent tube showing the ideal path, or an expert's recorded trace | **Yes — this is a genuine differentiator** (the brief asks for it; nobody ships it) |
| **Scoring overlays during the run** | Not documented (scores are post-hoc) | Live wall-hit flash / "unsafe" warning | Yes as an optional training aid; off in assessment |
| **Comfort/ratchet ergonomics** | ORSIM (small sensor, laptop), Smiloscopy (break-room form factor) | Low-friction setup, short sessions | Yes — VR-specific: implement our "scope-follows-hand ratchet", seated/standing calibration |

---

## 6. Steam, GitHub and open source

### 6.1 Steam

Queried the public storefront search API (`store.steampowered.com/api/storesearch`, terms: `bronchoscopy`,
`bronchoscope`, `endoscopy`, `medical simulator`, `surgery simulator`, `anatomy`; cc=us, 2026-11-15):
**"bronchoscopy", "bronchoscope" and "endoscopy" each return 0 titles**; "medical simulator" returns 1
(*Medical Diagnostic Simulator*, app 2925880); "surgery simulator" returns 1
(*VR TKA Surgery Simulator*, [app 2651810](https://store.steampowered.com/app/2651810/)); "anatomy"
returns consumer anatomy viewers (*VR Anatomy*, *Vesalii Anatomy VR*, *Kinetic Anatomy 3D*).
**Conclusion:** there is no consumer VR bronchoscopy market. Medical simulation here is sold B2B with
quote-based pricing, not on storefronts. This matters for our distribution model: we should not
expect discoverability from a store listing; the buyers are programme directors.

### 6.2 GitHub / open source

| Project | What it does | Licence | Relevance |
|---|---|---|---|
| **[BronchSim](https://github.com/andreajonas/bronchsimulator)** ([live](https://bronchsimulator.com)) | Browser (Three.js) trainer: drive a scope through a CT-derived airway with an on-screen joystick, schematic map, segment labels, anatomy/quiz mode. Built with 3D Slicer/VMTK centreline extraction. | **CC BY 4.0** | **Closest prior art to our project.** Desktop/web, not VR, no tools/metrics — but the same pedagogy (map + labels + quiz) and a reusable model of what "CT-derived" costs. |
| **[Fraxinus](https://github.com/SINTEFMedtek/Fraxinus)** | Open platform for image-guided bronchoscopy: CT import, AI segmentation (Raidionics, TotalSegmentator), target placement, automatic route, virtual bronchoscopy synchronised with CT, EBUS simulator, planning review. Ubuntu-first, Windows builds available. | **BSD-3-Clause** | The best open pipeline for our CT phase; also a source of route/target UX. Research tool, not FDA/CE. |
| **[BronchoscopyAR](https://github.com/Fueredoriku/BronchoscopyAR)** | HoloLens AR visualisation of a Fraxinus-segmented bronchial tree; thesis comparing 3D AR vs 2D screen for depth perception. | **MIT** | Precedent for AR overlay from our anatomy graph. |
| **[deepgandhi95/virtual-bronchoscopy](https://github.com/deepgandhi95/virtual-bronchoscopy)** | Python/ParaView script generating a virtual-bronchoscopy video from CT. | none stated | Cheap way to preview CT-derived trees. |
| **[IAM-CVC/BronchoX](https://github.com/IAM-CVC/BronchoX)** | DICOM-based virtual bronchoscopy / airway navigation software. | none stated | Research-grade viewer. |
| **[SNRLab/Visually_Navigated_Bronchoscopy](https://github.com/SNRLab/Visually_Navigated_Bronchoscopy)** | Visual odometry/localisation inside the airway (navigation research). | NOASSERTION | Relevant later if we ever do video-based localisation. |
| **[csuet/bronchoscopy_nsd](https://github.com/csuet/bronchoscopy_nsd)**, **[SIRGLab/bronchoscopy-dataset-and-benchmark](https://github.com/SIRGLab/bronchoscopy-dataset-and-benchmark)** | Datasets/benchmarks for bronchoscopy computer vision. | MIT / GPL-3.0 | Data for automated video analysis later. |
| **[VR-Caps](https://github.com/CapsuleEndoscope/VirtualCapsuleEndoscopy)** | Unity VR environment for **active capsule endoscopy** (★210) — the most popular open VR endoscopy simulator. | **none stated** | Good Unity-VR reference; licence makes reuse risky. |
| **[BeamAdapter](https://github.com/sofa-framework/BeamAdapter)** | SOFA plugin: Kirchhoff rods for 1D flexible structures (catheters, guidewires, scopes). | **LGPL-2.1** | Reference formulation for honest scope bending. |
| **[SlicerIGT](https://github.com/SlicerIGT/SlicerIGT)** | 3D Slicer modules for image-guided interventions. | **BSD-3-Clause** | Plumbing if we add tracked tools/phantoms. |
| **[Open-Source-Visuo-Haptic-Simulator-for-Surgical-Training](https://github.com/ChiaraSapo/Open-Source-Visuo-Haptic-Simulator-for-Surgical-Training)** | Student project: visual + haptic surgical training. | none stated | Only haptics-focused open project found; small. |

**Gap statement:** I found **no open-source VR (OpenXR/HMD) bronchoscopy trainer**, in Godot or
otherwise. A GitHub search for `medical simulation godot` returns four repositories, all unrelated
student projects. Our project would be the first of its kind — an opportunity, and a warning that
there is no codebase to lean on for VR interaction patterns.

---

## 7. Prioritised "steal this" list for the open-source implementation

Ordered by (decision value × cheapness). Each item names its source so it can be defended in a
curriculum meeting.

### P0 — do in v1, they are cheap and evidence-backed

1. **Adopt DC / SP / PT / MIT as the scoring core.** Diagnostic completeness (segments /18),
   structured progress (correct progressions /18), procedure time, mean intersegmental time. This is
   the outcome set used by the strongest 2026 RCTs and by AI-scored clinical work, so our numbers will
   be comparable to the literature.
   *Steal from:* [Naik 2026](https://doi.org/10.1159/000551106), [Deng 2026](https://doi.org/10.1136/thorax-2025-223147),
   [BMJ Open 2025](https://doi.org/10.1136/bmjopen-2025-109756).
2. **Add the older, complementary metrics that actually discriminate:** wall contacts (per 100 mm
   travelled), **mid-lumen time %**, "red-out"/airway-obstruction time, segments skipped, suction
   usage, and **lens-soiling events**.
   *Steal from:* [Pastis 2014](https://doi.org/10.1097/LBR.0000000000000111) (mid-lumen time, wall hits),
   AccuTouch's metric list ([review](https://doi.org/10.36416/1806-3756/e20210361)), lens-cleaning counts in
   [BMC 2024](https://doi.org/10.1186/s12890-024-02846-9).
3. **Ship *several* labelled anatomy variants, not one tree.** Even before real CT data, vary branching
   angles, lengths and ostium sizes across 3–6 graph variants, and score the final test on a variant
   the trainee has not seen. This is the single best-evidenced design choice available to us.
   *Steal from:* [Deng 2026](https://doi.org/10.1136/thorax-2025-223147).
4. **Aided vs unaided, training vs assessment, and a stored expert run.** Three toggles and one JSON
   file per case. Copy the CHEST "Training Mode / Assessment Mode" split and CAE's "compare with the
   instructor's acceptable results".
   *Steal from:* [CHEST curriculum](https://surgicalscience.com/simulators/gi-bronch-mentor/chest-standardized-curriculum/),
   [EndoVR tech sheet](https://caehealthcare.com/media/files/TechSheets/EndoVR-TechSheet.pdf).
5. **Debrief = replay scrubber + event timeline + segment coverage map.** We already log events; make
   the log the product. ORSIM's play-back and MentorLearn's video capture are the commercial proof
   that this is what teachers use.
   *Steal from:* [ORSIM features](https://www.orsim.com/features), [brochure](https://surgicalscience.com/wp-content/uploads/2025/11/BRONCH-Mentor-Brochure-2025_10-Web.pdf).
6. **Make the case list structurally identical to BRONCH Mentor's module map, then add what they
   don't ship.** Diagnostic + sampling (forceps/brush/needle/BAL), EBUS station sampling, emergency
   (bleeding/foreign body/pulmonary toilet), difficult airway — plus our secretions-with-lens-soiling
   case, which no commercial VR product models as a scored task.
   *Steal from:* the five module pages in §4.1; absence confirmed across [all simulators](https://surgicalscience.com/all_modules/).
7. **Instrument the handle, even if it is a wand.** If v1 must be wand-only, then (a) implement the
   grip-ratchet "scope-follows-hand" insertion already specified in `docs/04-scope-model.md`,
   (b) render a virtual lever with a numeric angulation read-out so the trainee learns the
   lever↔angulation mapping, and (c) design the input layer so a tracked proxy scope can be dropped in
   without touching the scope model. The evidence that handles matter is that *every* competitor
   instruments one, and that the best-validated one uses a passive replica with a sensor.
   *Steal from:* [ORSIM design](https://www.orsim.com/design), [Smiloscopy](https://smiloscopy.com/).

### P1 — v1.x, where the differentiation lives

8. **Schematic minimap + segment labels + depth marker + optional ghost route**, each independently
   toggleable and each contributing to an "assistance used" score.
   *Steal from:* BronchSim's map/labels ([repo](https://github.com/andreajonas/bronchsimulator)),
   Fraxinus's route + CT sync ([repo](https://github.com/SINTEFMedtek/Fraxinus)), and the OR's ENB
   "map + tip + target" idiom ([Diagnostics 2026](https://doi.org/10.3390/diagnostics16193151)).
9. **Expert-trace overlay ("ghost scope") and automated error flags** (wall-riding, oscillation,
   missed segment, re-entering an inspected segment). No commercial product documents this; it is our
   clearest pedagogical differentiator.
   *Steal from:* the concept of expert comparison in CAE/MScore, upgraded from a score to a trajectory.
10. **A defensible pass mark.** Use the contrasting-groups method on novice vs expert runs and publish
    the standard; that is how Sun 2026 produced a 34.4% cut score with 2 false positives and 1 false
    negative.
    *Steal from:* [Sun 2026](https://doi.org/10.1186/s12871-026-03809-9).
11. **A light patient-state layer** (SpO₂, HR, cough, bleeding score, sedation level) sufficient to
    teach the first 60 seconds of a bleed, without becoming an ICU simulator. Copy the *scope* of the
    BRONCH Mentor emergency module, not its depth.
    *Steal from:* [Emergency module](https://surgicalscience.com/simulators/gi-bronch-mentor/emergency-bronchoscopy/).
12. **Educator export**: per-trainee JSON/CSV, cohort roll-up, case completion matrix. MentorLearn and
    MScore exist because departments need this; a Markdown/JSON export is our 5% version.
    *Steal from:* [MentorLearn](https://surgicalscience.com/mentorlearn/), [MScore](https://surgicalscience.com/simulators/flexvr/mscore-portal/).
13. **Make the airway behave, not just look.** Compliance (wall-slide, already implemented), cough
    transients, secretions that occlude and soil the lens, and bleeding that pools and obscures.
    *Steal from:* [Garner 2019](https://doi.org/10.1183/23120541.00035-2019) — experienced users rated a
    cheap perfused-lung model above a commercial VR simulator on realism.

### P2 — later, and only with a reason

14. **Physical proxy scope**: 3D-printed handle + Vive tracker (or a real single-use scope + tracker
    collar, the Smiloscopy approach). Highest-value hardware upgrade; no software change if item 7 is
    done properly.
    *Steal from:* [Smiloscopy](https://smiloscopy.com/), [ORSIM](https://www.orsim.com/design).
15. **CT-derived pipeline** modelled on Fraxinus (TotalSegmentator/Raidionics → centreline → graph →
    labels), keeping our synthetic graph as the fast fallback.
    *Steal from:* [Fraxinus](https://github.com/SINTEFMedtek/Fraxinus), [BronchSim](https://github.com/andreajonas/bronchsimulator).
16. **Honest scope mechanics** — replace the heading-vector tip with a position-based chain or a
    Kirchhoff rod (BeamAdapter formulation) once the metrics layer is stable.
    *Steal from:* [BeamAdapter](https://github.com/sofa-framework/BeamAdapter).
17. **Passive haptic friction module** (a braked drum on the insertion axis) rather than active force
    feedback: cheap, quiet, and attacks the #1 realism complaint without an actuator-development
    project. No competitor publishes an actuator design we could copy, so treat this as our own R&D.
18. **Fluoroscopy / radial-EBUS view** for the peripheral lesion case, and **CBCT-style overlay** as an
    advanced mode, mirroring what trainees will meet clinically
    ([CBCT-AF study](https://doi.org/10.21037/jtd-2026-2065)).

### Explicitly do **not** copy

- **Sedation pharmacology depth** and multi-drug management (BRONCH Mentor/CAE): high effort, low
  marginal skill gain for our audience; a three-parameter patient state is enough.
- **Cart + dual-monitor form factor** and quote-only pricing.
- **Vendor-cloud-only data** (MentorLearn/MScore): keep everything local and exportable.
- **Leaderboards as the primary motivator** (Smiloscopy): speed-first scoring contradicts DC/SP.
- **Fantastical worlds** instead of anatomy: they cannot teach segment naming.
- **"VR" that is really stereoscopic desktop** (FlexVR's shutter glasses): if we say OpenXR, mean HMD.

---

## 8. Caveats and open questions

1. **Marketing vs evidence.** Vendor pages are the only source for hardware claims (haptics,
   "authentic scope", "real patient data"). No independent teardown or fidelity benchmark of BRONCH
   Mentor or EndoVR exists in the literature. Treat every "realistic" as unquantified.
2. **Numbers we could not obtain:** case counts per module, prices, installed base, Windows version
   requirements, force-feedback specifications, and whether BRONCH Mentor's tip is physically
   actuated or passively sprung.
3. **Currency of the market.** Ownership has changed twice in this space (Immersion Medical → CAE; Simbionix → Surgical Science), and at least one product (Airway Ex) was discontinued
   after a corporate pivot. Any build-vs-buy analysis should be re-checked before purchase.
4. **Evidence geography.** The strongest bronchoscopy-simulation evidence is Scandinavian/UK
   (Copenhagen, Auckland, Toronto, London) and focuses on anaesthesia FOI, not diagnostic
   bronchoscopy. Our audience (pulmonary/critical care) is comparatively under-studied.
5. **VR-vs-AR is unsettled.** One RCT favours VR on completeness and mental demand, AR on speed and
   physical demand ([Naik 2026](https://doi.org/10.1159/000551106)). Do not over-invest in HMD-specific
   cleverness until our own usability data says it helps.
6. **Wand-only input has no precedent.** Every product instruments a scope. Our usability risk is
   concentrated in this one decision; prototype the tracked-handle path early even if v1 ships wands.
7. **Search limitations** (§0): a broken `web_search` backend means this review may miss products that
   have no crawlable site (e.g. regional distributors, hospital-built trainers, Chinese domestic
   simulators). A follow-up pass with a working search engine is warranted, especially for the Chinese
   and Indian markets, where low-cost simulators are being published actively
   (e.g. [Cureus 2026 low-cost model](https://doi.org/10.7759/cureus.106843)).

---

## Appendix A — source index

**Vendor / product**
- Surgical Science BRONCH Mentor: [product](https://surgicalscience.com/simulators/gi-bronch-mentor/) ·
  [platforms](https://surgicalscience.com/simulators/gi-bronch-mentor/bronch-mentor-platforms/) ·
  [essential](https://surgicalscience.com/simulators/gi-bronch-mentor/essential-bronchoscopy/) ·
  [diagnostic](https://surgicalscience.com/simulators/gi-bronch-mentor/diagnostic-bronchoscopy/) ·
  [emergency](https://surgicalscience.com/simulators/gi-bronch-mentor/emergency-bronchoscopy/) ·
  [EBUS](https://surgicalscience.com/simulators/gi-bronch-mentor/essential-ebus-module-2/) ·
  [CHEST curriculum](https://surgicalscience.com/simulators/gi-bronch-mentor/chest-standardized-curriculum/) ·
  [brochure PDF](https://surgicalscience.com/wp-content/uploads/2025/11/BRONCH-Mentor-Brochure-2025_10-Web.pdf) ·
  [ENDO Suite](https://surgicalscience.com/endo-suite-2/) ·
  [BRONCH Express](https://surgicalscience.com/simulators/bronch-express/) ·
  [MentorLearn](https://surgicalscience.com/mentorlearn/) ·
  [MScore](https://surgicalscience.com/simulators/flexvr/mscore-portal/) ·
  [FlexVR platform](https://surgicalscience.com/simulators/flexvr/platform/) ·
  [Simbionix acquisition](https://surgicalscience.com/news/surgical-science-completes-the-acquisition-of-simbionix/)
- CAE: [EndoVR](https://www.caehealthcare.com/surgical-simulation/EndoVR/) ·
  [bronchoscopy package](https://www.caehealthcare.com/surgical-simulation/surgical-cases/bronchoscopy-pathology-package/) ·
  [tech sheet PDF](https://caehealthcare.com/media/files/TechSheets/EndoVR-TechSheet.pdf)
- ORSIM: [home](https://www.orsim.com/) · [features](https://www.orsim.com/features) ·
  [design](https://www.orsim.com/design) · [software updates](https://www.orsim.com/software-updates)
- Smiloscopy: [site](https://smiloscopy.com/) · [App Store](https://apps.apple.com/us/app/smiloscopy/id6743859420)
- Kyoto Kagaku: [MW19 in product catalogue, p.105](https://www.kyotokagaku.com/downloads/2024_catalogo_de_productos_es.pdf)
- TruCorp: [AirSim Bronchi](https://trucorp.com/product/airsim-bronchi/) ·
  [bronchoscopy category](https://trucorp.com/bronchoscopy-simulators/)
- Adjacent platforms: [Mentice](https://www.mentice.com/) · [VirtaMed](https://www.virtamed.com/en/products-and-solutions/simulators/arthros) ·
  [Medical-X](https://medical-x.com/products/lap-x-vr) · [InSimo](https://www.insimo.com/) ·
  [Fundamental XR](https://www.fundamentalxr.com/clinical-areas) · [Osso VR](https://ossovr.com/) ·
  Precision OS ([J Surg Educ 2026](https://doi.org/10.1016/j.jsurg.2025.103791)) · [SimX](https://www.simx.com/) ·
  [Arch Virtual](https://www.archvirtual.com/) · [ImmersiveTouch](https://www.immersivetouch.com/) ·
  [AnatomyX](https://anatomyx.com/) · [Level Ex](https://www.levelex.com/)

**Literature and repositories** — all cited inline with DOI/PMCID or GitHub URL.
Key syntheses: [J Bras Pneumol 2022 review](https://doi.org/10.36416/1806-3756/e20210361),
[Health Sci Rep 2023 SR](https://doi.org/10.1002/hsr2.1398),
[Cochrane 2025 GI endoscopy](https://doi.org/10.1002/14651858.CD008237.pub4),
[BJA 2026 airway-simulator validation SR](https://doi.org/10.1016/j.bja.2026.01.027),
[BMC Pulm Med 2024 four models](https://doi.org/10.1186/s12890-024-02846-9),
[Breathe 2026 AI/digital bronchoscopy review](https://pmc.ncbi.nlm.nih.gov/articles/PMC13659361/).

**Storefronts / APIs**
- Steam search API: `https://store.steampowered.com/api/storesearch/?term=<term>&l=en&cc=us`
  (0 results for bronchoscopy/endoscope/endoscopy, checked 2026-11-15).
- GitHub REST search API: `https://api.github.com/search/repositories?q=<query>`.
- Europe PMC REST: `https://www.ebi.ac.uk/europepmc/webservices/rest/search`.

---

## Appendix B — one-page decision summary

| Question | Answer |
|---|---|
| Does a mature commercial product cover our 8 cases? | Yes — BRONCH Mentor (5 modules). It is the benchmark, not a gap. |
| What should we *not* try to beat? | Rendering fidelity, sedation pharmacology, module catalogue breadth. |
| What can we beat them on? | Openness, Linux/OpenXR, CT-derived anatomy *variety*, automated debrief/expert traces, cost, and published psychometrics. |
| What is the biggest UX risk? | Wand-only input. No competitor uses controllers; prototype a tracked proxy handle early. |
| What is the biggest evidence opportunity? | Publishing DC/SP/PT/MIT norms and a pass mark for a free simulator, and showing anatomy-variety generalisation. |
| What is the cheapest realism win? | Airway behaviour: wall compliance, cough, secretions + lens soiling, bleeding that obscures. |
| What should the first debrief screen show? | Segment coverage map, DC/SP/PT/MIT, wall-hit rate, mid-lumen %, event timeline, replay scrubber, expert comparison. |
