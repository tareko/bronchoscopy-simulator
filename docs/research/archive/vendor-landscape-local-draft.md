# The Bronchoscopy Simulator Landscape

### Design research for an open-source VR bronchoscopy simulator — HTC Vive, Linux, Godot/OpenXR

**Prepared:** 2026 · **Method:** vendor site inspection, distributor pages, seller listings, and peer-reviewed literature via PubMed/Europe PMC. **Evidence tags used throughout:** `[MARKETING]` = vendor claim, not independently verified · `[EVIDENCE]` = peer-reviewed, citation given · `[OBSERVED]` = my inference from documentation/photos/spec sheets · `[UNVERIFIED]` = could not confirm at source.

---

## 0. Method note and its limits

Two things about sourcing matter for how much weight to give each claim.

**What worked.** Vendor sites were reachable and gave module lists, hardware descriptions, and marketing claims. The Europe PMC REST API proved far more reliable than any web search engine for the literature and gave me full abstracts and open-access full texts. Several 2025–2026 trials turned out to be directly relevant, including two head-to-head simulator comparisons and one trial on *guide-path UX* that changes a core design decision (see §5.6).

**What did not work.** I could **not** retrieve YouTube video descriptions or transcripts. YouTube search results are JavaScript-rendered and the transcript endpoints require an API key; every attempt returned an empty shell. Vendor pages do host demo videos (ORSIM's "Watch the video"; the BRONCH Mentor page's interview with Dr. Carla Lamb; MentorLearn's walkthrough video), but I could not transcribe them. **No claim in this report rests on video content.** Likewise, no review-site scraping (G2/Glassdoor-style) was possible; the "voice of the customer" section below therefore draws on peer-reviewed critiques, published RCTs that comment on usability, and secondary resale listings, not consumer reviews.

**One subagent failed.** The literature-mining subagent died before returning. I re-did that work directly via Europe PMC, so the evidence base below is complete and primary.

---

## 1. Executive summary

1. **The market-leading "VR bronchoscopy simulator" is not headset VR.** ORSIM — the device with the best validation evidence in the field — is a 9 kg case containing a replica video bronchoscope, a sensor box, and a dedicated **laptop**. CAE's EndoVR is a cart. Surgical Science's BRONCH Mentor is a panel plus scopes. Almost all the fidelity in this market comes from the *physical scope interface*, not from the display. `[OBSERVED]`

2. **Nobody ships Linux.** ORSIM runs on a bundled Lenovo Windows laptop; CAE and Surgical Science ship Windows systems; CAE's only localisation is English + Simplified Chinese. A Linux + OpenXR product is a genuine differentiator, not a compromise. `[MARKETING/OBSERVED]`

3. **There is no commercial headset-native bronchoscopy simulator.** The closest work is research: Apple Vision Pro / HoloLens 2 mixed-reality navigation (Japan) and one Quest 3 training framework paper. This is white space — and it means there is no incumbent UX to copy for the thing you are actually building.

4. **A free, CC-BY prior implementation already exists.** BronchSim (Stanford, `github.com/andreajonas/bronchsimulator`) is a Three.js bronchoscope trainer over a **CT-derived, centreline-extracted airway mesh** with a schematic map and a quiz mode. Its pipeline (3D Slicer + VMTK → branch tree → glTF) is the single most reusable artefact in this space. Read it before writing your airway importer.

5. **Do not build a single rigid "correct path".** An RCT found that continuous simulator guidance was no better than **no feedback at all**, and worse than a human tutor. A second study documents the exact failure mode: simulators that score proximity to one pre-defined path give false negatives to experts who take an equally valid route and false positives to novices who learn to "beat the simulator". `[EVIDENCE]` (§5.6)

6. **Case *variety* beats case *polish*.** The strongest recent RCT in this field (n=60 novices) found training on **multiple patient-derived CT airway trees** transferred significantly better to a *new* CT-derived tree than training on one standard tree, and the advantage persisted at 3 months.

7. **The validated metric set is small, cheap, and needs no machine learning:** diagnostic completeness (segments/18), structured progress (correct sequential progressions), procedure time, mean intersegmental time, segments revisited, wall hits, mid-lumen time. Implement these and you can plug into the existing validity literature immediately.

8. **Anatomy is the weak point of every physical trainer.** Multiple studies find airway manikins' anatomy diverges measurably from human CT. Digital anatomy is the open-source project's structural advantage, and it should be marketed as such.

9. **Haptics claims in this market are narrower than they sound.** "Haptic feedback" almost always means **axial insertion/withdrawal resistance**, not instrumented tip-articulation torque. True lever-and-knob force feedback is rare and undocumented in public specs. `[UNVERIFIED]` for most products — this is the largest single evidence gap in the sector.

10. **Cost is the sector's acknowledged Achilles heel.** A peer-reviewed review states plainly that "the main disadvantage of virtual simulators is their high cost", citing list prices of $46k–$114k for the endoscopy platforms. A free, Linux, Vive-based trainer is a real answer to a documented complaint.

---

## 2. Comparison table

| # | Product | Vendor / country | Hardware & scope interface | Display | Case library | Metrics / debrief | Platform | Pricing model | Published validity |
|---|---|---|---|---|---|---|---|---|---|
| 1 | **BRONCH Mentor** (ENDO Suite) | Surgical Science (ex-Simbionix), Sweden/Israel; rebranded in Japan as Kyoto Kagaku **KAD-4/KAD-5** | Endoscopy cart; **one real bronchoscope**, haptic feedback (触覚機能), 27" touchscreen, foot switch, master tool, 10 cc syringe; **225 kg**, 700 W, W57–87×L130–186×H135–180 cm `[MARKETING, JP spec sheet]` | Monitor | 5 modules: Essential Bronchoscopy (AABIP), Diagnostic, Emergency, CHEST Curriculum, Essential EBUS | Aided/unaided cases; performance feedback per task; MentorLearn LMS: OSATS/GOALS-style metrics, learning-curve graphs `[MARKETING]` | Windows cart | Quote-only, capital purchase + module licences | Pastis 2014 construct validity (partial); Konge 2015 EBUS RCT |
| 2 | **BRONCH Express** | Surgical Science + CHEST (ACCP) | Portable/affordable variant, co-developed with CHEST `[MARKETING]` | Monitor | Essential Bronchoscopy, Diagnostic, Essential EBUS (no Emergency module listed) | As above | Windows | Quote-only | inherits BRONCH Mentor evidence, not platform-specific |
| 3 | **CAE EndoVR** (ex-AccuTouch, ex-Immersion Medical) | CAE Healthcare, Canada/US | Cart; replica flexible endoscopy scopes; "height adjustable haptic device"; dedicated scope holder | Monitor | Bronchoscopy, EBUS-TBNA, upper GI, lower GI | Time, cases completed, proficiency, dexterity, complications; curriculum builder; export to Excel/Word/PDF `[MARKETING]` | Windows; English + Simplified Chinese | Quote-only; historically ~$46,750 (upper GI) / $74,750 (lower GI) + modules $7,175–8,650 | Rowe 2002 predictive; Samuelson 2016 warm-up RCT |
| 4 | **ORSIM** | Airway Simulation Ltd, New Zealand | **9 kg case**: video-enabled replica bronchoscope + desktop sensor unit + **dedicated laptop** | Laptop screen | 30 scenarios incl. 12 difficult airways; +12 paediatric; +15 pulmonology | Procedure duration, collisions-avoidance %, final score; session recording + playback `[MARKETING]` | Windows laptop | Perpetual hardware + paid modules; free software/firmware updates | **Strongest in field**: Baker 2016 construct; Wong 2019 predictive RCT (LoR 2); Sun 2026 full Messick validation |
| 5 | **Ambu Broncho Simulator / BPS** | Ambu, Denmark | Real single-use scope (aScope 5) in a physical phantom (Koken LM-099) + **AR overlay** on the video monitor | Monitor with AR overlay | Single endobronchial phantom view; 18 segment labels | Live segment ID, position in lung tree, structured-progress score; per-run feedback `[EVIDENCE]` | Windows + Ambu monitor | Device-adjacent / training package | Cold 2024 RCT; Agbontaen 2025 RCT (beat expert tutors on efficiency) |
| 6 | **Kyoto Kagaku MW19** | Kyoto Kagaku, Japan | Physical manikin; real fibrescope inserted; adjustable difficulty (mouth opening, stiff neck, oedematous tongue, laryngospasm) | None (direct scope view) | Trachea + both main bronchi to **B1–B10 bifurcations** incl. internal folds; 3 incisors, 2 tongues, lubricant | None — instructor-assessed | n/a | **USD 2,150 list** (SKU 11393-100) | none found for MW19 |
| 7 | **Koken LM-092 / LM-099** | Koken Co., Japan (Tokyo — **not** Kyoto Kagaku) | Physical silicone airway phantoms used with real scopes (aScope 5 in published work) | Scope monitor | LM-092: tree to **V-order bronchi** (e.g. B1aiα), distal open for washing. LM-099 adds **EBUS-TBNA** with embedded lymph nodes, real puncture/cartilage feel, outer-sheath technique, head model for oral insertion | None native; gains metrics only when paired with AR/AI overlay | n/a | Quote | **J Anesth 2013** (LM-092 educational benefit); used as test model in Naik 2026, Okachi 2026 |
| 8 | **TruCorp AirSim Bronchi** | TruCorp, N. Ireland | Physical bronchial-tree add-on to AirSim manikins; down to 4th-generation bronchi; adult + child | None | n/a | None | n/a | Quote | McCarthy 2026: TruCorp AirSim has *concurrent anatomical* validity studies that largely **failed** to match human CT |
| 9 | **Softmimics Virtual Bronchoscopy Simulator** | Softmimics LLC | Electromagnetic-navigation bronchoscope + **1:1 physical airway model** + positioning device; claims "realistic endoscopic haptics" | Monitor | 3D bronchial software `[MARKETING]` | not stated | not stated | Quote | **none found** `[UNVERIFIED — site unreachable]` |
| 10 | **BronchSim** | Stanford (A. Jonas), free | **Browser**, on-screen joystick | Screen | 1 CT-derived airway; segment labels; quiz mode | Quiz scoring; free navigation | Web (Three.js) | **Free, CC BY 4.0** | none (teaching tool) |
| 11 | **BronchoSim** | independent, free | Browser | Screen | Procedurally modelled tracheobronchial tree | Scored navigation + identification tasks | Web | Free | none |
| 12 | **PIE Virtual Bronchoscopy** | U. Toronto / UHN | Browser (Flash via Ruffle) | Screen | Video-clip path through lungs, labels A–Z | Post-test with scores + peer comparison | Web (Flash) | Free | none |
| 13 | **AVP / Holoeyes MR bronchoscopy** | Fujita Health Univ. + Nagoya Univ., Japan | Apple Vision Pro or HoloLens 2; real scope + Koken phantom; live video via NDI | Headset | 10 patient-derived CT datasets, one per segment | time-to-target, reach success, SSQ | visionOS (research) | research prototype | Okachi 2026 phantom feasibility (no clinical benefit claimed) |

---

## 3. Per-product notes

### 3.1 Surgical Science / Simbionix — BRONCH Mentor

The reference product for the specialty. Now sold as **ENDO Suite – BRONCH Mentor** ([product page](https://surgicalscience.com/simulators/gi-bronch-mentor/)), with a portable sibling, **BRONCH Express**, [co-developed with CHEST](https://surgicalscience.com/simulators/bronch-express/).

**Platforms** ([platforms page](https://surgicalscience.com/simulators/gi-bronch-mentor/bronch-mentor-platforms/)): ENDO Suite "combines GI endoscopy, flexible bronchoscopy, endourology and hysteroscopy simulation training. A designated Bronchoscopy panel and scopes enable practicing flexible bronchoscopy." So the scope is a physical, instrumented interface, not a game controller. BRONCH Express is positioned as "affordable, portable training."

**Modules** — five, each with a documented learning-objective list, which is unusually transparent for this industry:

| Module | Content | Notable detail |
|---|---|---|
| **Essential Bronchoscopy** ([link](https://surgicalscience.com/simulators/bronch-express/essential-bronchoscopy-module/)) | Skill tasks: scope control, "3D cognitive perception", anatomy, systematic inspection | AABIP-endorsed. Objectives explicitly include **naming every bronchial segment** and **IASLC 2009 lymph-node stations**; sub-tasks include forceps biopsy, cytology brushing, TBNA. Sub-sections: *Bronchial Anatomy*, *Cyberscopy*, *Diagnostic Maneuvers* |
| **Diagnostic Bronchoscopy** ([link](https://surgicalscience.com/simulators/bronch-express/diagnostic-bronchoscopy-module/)) | Patient cases needing inspection + sampling | Tools: biopsy forceps, cytology brush, aspiration needle, BAL. Includes **moderate sedation management** with haemodynamic/respiratory complications; cases have "unique anatomy, pathologies and altering response to moderate sedation" |
| **Emergency Bronchoscopy** ([link](https://surgicalscience.com/simulators/gi-bronch-mentor/emergency-bronchoscopy/)) | Endobronchial bleeding, aspirated foreign bodies, therapeutic aspiration ("pulmonary toilet") | Tools: grasping forceps, balloons, electrocautery probes. Explicitly lets the trainee "err, without consequences such as pneumothorax, bleeding, hypoxemia, hypotension, arrhythmia, or cardiac arrest" |
| **CHEST Standardized Curriculum** ([link](https://surgicalscience.com/simulators/gi-bronch-mentor/chest-standardized-curriculum/)) | Two segments: Essential Skills + Clinical | Runs in **Training Mode or Assessment Mode**; the Clinical segment **interleaves knowledge quizzes with hands-on performance** so cognitive and psychomotor skills are assessed "as one continuous entity" |
| **Essential EBUS** ([link](https://surgicalscience.com/simulators/bronch-express/essential-ebus-module/)) | EBUS-TBNA workflow | Uses an "actual (modified) needle". Simulated US console with **Doppler, depth, gain, contrast**, external display, **multi-plane CT correlation**, tutorial movies, anatomical labels, real-time guidance. Sub-sections include *Ultrasound-CT Relations* and *LN Stations Demonstration* |

**Assessment/debrief**: MentorLearn ([page](https://surgicalscience.com/mentorlearn/)) is the LMS: class/curriculum assignment, pre-reading, "proficiency-based training", "simulation debriefing … comprehensive objective metrics", reports based on "OSATS and GOALS", and **learning-curve graphs**. MentorLearn Cloud is the web version. Society partnerships named: SAGES, EAES, AABIP.

**Validity** `[EVIDENCE]`:
- **Pastis NJ et al., *J Bronchology Interv Pulmonol* 2014;21(4):314–321** ([doi](https://doi.org/10.1097/LBR.0000000000000111)). 4 tasks, 3 groups (novice <10, experienced 200–1000, expert >1000 bronchoscopies). **Tasks 1 (scope manipulation) and 3 (airway anatomy) discriminated**; discriminative sub-metrics were *final score, time, mid-lumen time, wall hits* (task 1) and *time, segments identified, segments incorrectly identified, segments skipped* (task 3). **Tasks 2 (guided anatomic navigation) and 4 (lymph node anatomy) did NOT discriminate.** This is the most useful single paper for choosing metrics — and a warning that "orientation" is hard to assess automatically.
- **Konge L et al., *Eur Respir J* 2015;46:1140–1149** ([doi](https://doi.org/10.1183/13993003.02352-2015)). EBUS RCT: simulator-trained novices scored higher on EBUS-STAT-style assessment than apprenticeship-trained novices (24.2 vs 20.2, p=0.006); pass/fail 28.9 points via contrasting groups.

**Honest caveat:** the vendor also cites Pastis 2014 as evidence that the simulator "did not discriminate skill levels in anatomic orientation or identification of lymph nodes" — they quote the negative finding, which is creditable.

### 3.2 CAE Healthcare — AccuTouch EndoscopyVR → EndoVR

**Lineage.** AccuTouch was an **Immersion Medical** product (Gaithersburg, MD), acquired by CAE and renamed **EndoVR** around 2012 with "a new, more realistic haptic sense of endoscopy" ([Triantafyllou 2014, PMC3921444](https://pmc.ncbi.nlm.nih.gov/articles/PMC3921444/)).

**Documented capability.**
- AccuTouch modules: **flexible bronchoscopy**, EGD, colonoscopy, ERCP; "All modules contain didactic teaching modules that include pathology atlases. Endoscopic procedures modules have a variety of test cases of increasing difficulty that include the possibility of perforation" (GIE technology review, quoted in the same PMC review). `[EVIDENCE-adjacent: review article]`
- "State-of-the-art haptic technology provides **active force feedback during insertion and removal of the scope from the mannequin** as well as correct anatomic and physiologic responses" ([RFH simulator centre](https://rfh-simulator-centre.co.uk/pages/our-simulators/accutouch/35/)). Note what this does and does not claim: axial insertion/withdrawal force, **not** tip-deflection torque.
- CAE EndoVR current page ([link](https://www.caehealthcare.com/surgical-simulation/EndoVR/)): modules bronchoscopy, EBUS-TBNA, upper GI, lower GI (corroborated by [McGill RIMUHC](https://rimuhc.ca/-/cae-endovr-interventional-simulator) and the [EndoVR tech sheet](https://www.hadimedical.com/sites/default/files/EndoVR-TechSheet.pdf), the latter being a PDF I could not parse). "Replica flexible endoscopy scopes"; "Dedicated scope holder"; "Reproduction endoscope accessories"; "Height adjustable haptic device"; **"Available in English & Simplified Chinese"**.
- Metrics named: "time, cases completed, learner proficiency, dexterity and complications". Curriculum: drag-and-drop pathway builder, learner groups, parameter levels, supplemental multimedia, reports exportable to Excel/Word/PDF.
- Virtual patient: "Clinical cases developed from real patient data and physiological models"; endoscopy starts with patient history, vitals change during the procedure, and the trainee is tasked with achieving "ideal virtual sedation without reducing the patient's oxygen saturation".

**Validity** `[EVIDENCE]`: Rowe & Cohen 2002 (*Anesth Analg*) predictive validity on the AccuTouch; Samuelson 2016 (*BJA*) warm-up RCT on EndoVR. Both rated **LoR 3** by McCarthy 2026, which notes improvements "may represent procedural priming rather than sustained skill acquisition."

**Pricing (historical but concrete)** `[EVIDENCE, 2011 list prices via Triantafyllou 2014]`: upper GI package **$46,750** (+$19,000 bleeding mode); lower GI **$74,750**; advanced modules **$7,175–8,650** each. For comparison, GI Mentor started at **$64,500** and rose to **$114,000** with ERCP/EUS.

**Status note:** the CAE Healthcare site is frozen in ~2021 content (masthead "CAE Healthcare 2021"), and used EndoVR units appear on the secondary market (e.g. relinkonline, eBay), which suggests an ageing installed base and hardware refresh cycle rather than active new-product investment.

### 3.3 ORSIM — Airway Simulation Limited (New Zealand)

**This is the product to study most closely.** It has the best validation evidence in bronchoscopy simulation and the most thoughtful hardware compromise.

**Hardware** ([design page](https://www.orsim.com/design)): three components —
1. a **video-enabled replica bronchoscope**,
2. a **desktop sensor unit** ("registers movement of the insertion tube and translates this to a three-dimensional virtual airway"),
3. a **dedicated laptop**, pre-loaded.

Weight **9 kg / 19 lb**; fits "in a drawer"; hard case; "rapid start-up". The [features page](https://www.orsim.com/features) claims a "fully functional bronchoscope", "robust construction" designed to avoid "expensive damage to clinical bronchoscopes during training", and "recording and evaluation … metrics for objective scoring … Instant feed-back through session recording."

**Case library** `[MARKETING]`: the base bundle ships **30 scenarios including 12 common and uncommon difficult airways**; add-on modules of **12 paediatric** and **15 pulmonology** scenarios ([software updates page](https://www.orsim.com/software-updates/) — modules are paid, software and firmware updates are free).

**Metrics** `[EVIDENCE — this is the valuable part]`: Sun et al. 2026 list ORSIM's built-in metrics as **procedure duration (seconds)**, **collisions avoidance (percentage)**, and **final score (percentage)**. A published ORSIM validation test used all 12 adult upper-airway cases, with a 7-minute per-case cap.

**Validity** `[EVIDENCE]` — the strongest stack in the field:
- **Baker PA et al., *BJA* 2016;117(S1):i87–i91** — aspects of validity and reliability for assessment.
- **Wong DT et al., *Eur J Anaesthesiol* 2019;36:227–233** — RCT: VR bronchoscopy simulator training improved performance of bronchoscopic-guided intubation **in patients**. McCarthy 2026 rates this **LoE 1b, LoR 2** — the only bronchoscopy simulator to reach that level.
- **Samuelson ST et al., *BJA* 2016;116:398–404** — 5-minute warm-up immediately before live fibre-optic intubation produced ~30% gains in speed and accuracy. (ORSIM's homepage markets this as "perform up to 30% better when you warm-up using the ORSIM" — `[MARKETING]` built on `[EVIDENCE]`.)
- **Krogh CL et al., *Clin Respir J* 2013** — training on a "new, portable, simple simulator transfers to performance of complex bronchoscopy procedures."
- **van Haperen M et al., *J Clin Med* 2023;12:5195** — RCT on regular practice, experts and novices.
- **Sun M et al., *BMC Anesthesiol* 2026;26:320** ([PMC13188312](https://pmc.ncbi.nlm.nih.gov/articles/PMC13188312/)) — full Messick-framework validation in a Chinese centre: Cronbach α=0.89; **6 cases for formative reliability (>0.7), 10 cases for summative (>0.8)**; novices vs experienced p<0.001 on every case; credible pass/fail **34.4%** via contrasting groups.
- **Naik A et al., *Respiration* 2026** ([PMC13221171](https://pmc.ncbi.nlm.nih.gov/articles/PMC13221171/)) — RCT vs an AR system (see §3.4). ORSIM's version in the trial: **v2.1.2.220923 on a Lenovo IdeaPad Gaming 3**.

**Two published usability criticisms** — quote these in any design review:
- *Feedback format*: "the ORSIM® VR simulator … had a more complex and arguably unclear format of feedback for novices" (Naik 2026, Discussion).
- *Single-path scoring*: Sun 2026 explains that scoring is tied to "a specific, fixed pathway"; experienced bronchoscopists who take a clinically valid alternative route "do not attempt correcting because the pathway of their selection would be acceptable in clinical practice", producing false negatives, while novices who "figure out how to 'beat the simulator'" produce false positives. The authors' recommendation: **more valid pathways, and scoring that emphasises "quality and thoughtfulness of decisions, instead of sole reliance on proximity to a pre-defined pathway."**

**Cost** `[EVIDENCE]`: a 2024 paper reports the ORSIM was "purchased in 2017 for **$30,000 CDN**" ([PMC10995860](https://pmc.ncbi.nlm.nih.gov/articles/PMC10995860/)).

### 3.4 Ambu Broncho Simulator / BPS (Denmark) — the AR counter-model

Worth a full entry because it is the only *validated* alternative architecture to VR, and because it directly informs your tracking question.

**Architecture** `[EVIDENCE]`: a real single-use flexible bronchoscope (**Ambu aScope 5 Broncho HD 5.0/2.2**) inserted into a **Koken LM-099** airway phantom, viewed on an **Ambu aView 2 Advance** monitor, with an **AR overlay** on that monitor showing labelled bronchial segments, the participant's position in the lung tree, and a live structured-progress score (Naik 2026, Methods and Fig. 1).

**Evidence** `[EVIDENCE]`:
- **Cold KM et al., *Chest* 2024;165:405–413** — RCT, novices on a mannequin. AI segment-ID feedback group beat written-instruction controls on all three outcomes: diagnostic completeness **+3.5 segments**, structured progress **+13.5 progressions**, procedure time **−214 s** (all p<.001/=.002).
- **Agbontaen KO et al., *Crit Care Med* 2025;53:e1105–e1115** ([PMC12047642](https://pmc.ncbi.nlm.nih.gov/articles/PMC12047642/)) — RCT, 40 critical-care physicians, 30 min training: AI-guided group beat **expert human tutors** on mean intersegmental time (−7.9 s, p=.027), procedure time (−77 s, p=.022) and segments revisited (−7, p=.019).

**Why this matters to you:** it is evidence that *automatic segment labelling on top of real anatomy* is a powerful teaching device — and it is the counterweight to the Su 2025 finding that continuous VR guidance is useless (§5.6). The difference is that Ambu's guidance is **identifying what you are already looking at**, not **telling you where to steer next**.

### 3.5 Physical and hybrid trainers

**Kyoto Kagaku MW19** — "Difficult Airway Management Simulator for Bronchofiberscopy", ref **11393-100** ([product page](https://www.kyotokagaku.com/en/products_data/mw19dam/)). Anatomically correct trachea and bronchi "include trachea bifurcation for segmental bronchi"; skills are "insertion and management of a fibrescope", "recognition of bifurcations", airway-opening techniques and sniffing position. Set includes manikin, 3 upper incisors, 2 tongues, lubricant, syringe, carry bag. 45×20×25 cm, **2.65 kg**, soft resin, latex-free. Retail listing around **$2,150** ([distributor](https://simtrainingresource.com/product/mw19-difficult-airway-management-simulator-for-bronchofiberscopy/)). Notably, the *difficulty adjustment* advertised by distributors (mouth opening, stiff neck, oedematous tongue, laryngospasm) is what makes it educationally useful — a design idea that transfers directly to software (a "difficulty dial" per case).

**Koken LM-099** — Japanese airway phantom, used as the physical substrate in both the Naik 2026 RCT and the Okachi 2026 AVP study (scope: aScope 5 Broncho 4.2/2.2). It has no electronics of its own; its metrics come entirely from whatever overlay you put on it.

**TruCorp AirSim Bronchi** ([page](https://trucorp.com/bronchoscopy-simulators/)) — bronchial-tree add-on compatible with AirSim Advance X / Difficult Airway / Combo X, and AirSim Child X / Combo X. Anatomy "down to the fourth generation bronchi". Training scenarios listed: orientation, navigation drills, **scope handling fundamentals ("tip control, rotation, insertion technique")**, secretion management/suction, complication preparedness (loss of view, obstruction), paediatric navigation, lung isolation with bronchial blockers. Purely physical. `[MARKETING]`

**Important counter-evidence for physical trainers** `[EVIDENCE]`: McCarthy 2026 (BJA) reports repeated findings that airway manikins diverge from human CT anatomy — Schalk 2015 (*Resuscitation*), Blackburn 2021 (*Anaesthesia*), Schebesta 2012 (*Anesthesiology*) — and that this "challenge[s] their assumed educational realism and highlight[s] the need for independent verification of manufacturers' claims of anatomical accuracy." TruCorp AirSim appears in that review with concurrent-validity studies that largely failed to match human anatomy.

**3D-printed bronchial trees** `[EVIDENCE]`: Liu WL et al., *Respir Care* 2023;68:527–530 ([PMC10173112](https://pmc.ncbi.nlm.nih.gov/articles/PMC10173112/)) — a 3D-printed high-fidelity bronchial tree; and Lee CT et al., *BMC Med Educ* 2026;26:1179 ([PMC13386945](https://pmc.ncbi.nlm.nih.gov/articles/PMC13386945/)) — single-centre RCT of 3D-printed difficult-airway models for fibreoptic intubation training in anaesthesia residents (Taiwan). A plausible low-cost hardware path for an open-source project: **print the phantom from your own CT-derived mesh**, so hardware and software share one source of truth.

### 3.6 Japan — spatial computing and MR navigation

Japan is the most interesting source of *interface* ideas, because the work is about putting 3D anatomy next to the live scope image rather than replacing the scope.

- **Okachi S et al., *JMIR XR Spat Comput* 2026;3:e103880** ([PMC13722140](https://pmc.ncbi.nlm.nih.gov/articles/PMC13722140/)) — a native visionOS app that ingests the bronchoscope feed over **NDI** and renders it as a plane **co-located with a patient-specific 3D airway model** (two STL meshes per case: airway tree in pink, target nodule in green), repositionable/rescalable/hideable via **ARKit hand tracking**. 10 patient-derived CT datasets (0.5–1.0 mm slices, Ziostation REVORAS), 10 trials, one 20-year bronchoscopist, all 10 target segments reached, mean time-to-target 37.5 s (SD 5.0). **Measured latency 250 ms median (≈261 ms sensor-to-display)**; SSQ rose from 0 to 7.5, confined to oculomotor (fatigue/eyestrain). The authors are explicit that this is feasibility only: "cannot determine whether the integrated display confers any benefit". **Latency is the key number for you** — 250 ms is not acceptable for a training loop; it is fine for an information overlay.
- **Ina T, Okachi S et al., *Respiration* 2026;105:967–977** ([PMC13134840](https://pmc.ncbi.nlm.nih.gov/articles/PMC13134840/)) — 3D holographic virtual bronchoscopy with MR (HoloLens 2 + **Holoeyes MD**) for peripheral lesions, retrospective feasibility.
- **Okachi S et al., *Respiration* 2026** ([doi](https://doi.org/10.1159/res/aepag014)) — motion capture of bronchoscopist kinematics using a spatial computing device. Directly relevant to instrumenting hand/scope motion without a sensor box.
- **BronchoBot** — Cold KM et al., *ERJ Open Res* 2026;12:970-2025 ([PMC13080710](https://pmc.ncbi.nlm.nih.gov/articles/PMC13080710/)): an autonomous AI-controlled bronchoscopy robot outperformed experienced bronchoscopists in a simulated setting. Not a training product, but it establishes a benchmark target for what "expert-level" motion looks like.
- Physical: Kyoto Kagaku (§3.5), Koken (§3.5), Olympus (bronchoscope vendor; its Endo TS-1 colonoscopy simulator is the analogue in GI, not bronchoscopy).

### 3.7 China

China is where the most energetic recent *research* on bronchoscopy simulation is happening, and it is almost entirely digital-twin / CT-derived.

- **Deng M et al., *Thorax* 2026;81:483–491** ([doi](https://doi.org/10.1136/thorax-2025-223147)) — **"Digital twin-based bronchoscopy simulator improves training performance and skill retention of novices: a randomised controlled study."** 60 bronchoscopy-naive participants, three arms: control (written instruction), **anatomic-uniformity** (one standard bronchial model), **anatomic-variety** (multiple patient-derived bronchial models). Test 1 on the standard model: no difference. **Test 2 on a new CT-derived model: anatomic-variety scored significantly higher on diagnostic completeness (+2.5 segments, p<0.001) and structured progress (+9 progressions, p<0.001).** At 3 months, the advantage persisted on both tests. Multi-centre author list (China-Japan Friendship Hospital, Ruijin, Chaoyang, Guangzhou, PLA General, Zhejiang) plus F. Herth (Heidelberg). **This is the single most design-relevant RCT in the field.**
- **Su P et al., *Respiration* 2025;104:701–707** ([doi](https://doi.org/10.1159/000546827)) — RCT, 36 residents, **"EndoSim" simulator**, three arms (VR guidance / tutor guidance / control), 12 consecutive sessions. Tutor > VR guidance on structured progress (18±0 vs 15.0±5.3, p=0.026); **VR-guidance group did not outperform the control group (p=1.00)**. See §5.6.
- **Sun M et al., *BMC Anesthesiol* 2026** — ORSIM validation at Yunnan University of TCM; co-authors include L. Konge and Z. Wang of the **Guangdong Academy for Medical Simulation (GAMS)**, Guangzhou — an actual Chinese simulation-training institution with Danish collaboration.
- **Deng M et al., *J Med Internet Res* 2026;28:e81382** — digital-twin-assisted **risk disclosure** for patients undergoing elective bronchoscopy, multicentre RCT ([PMC13641757](https://pmc.ncbi.nlm.nih.gov/articles/PMC13641757/)). Interesting side-application: the same patient-specific model used for consent, not just training.
- **Wang W et al., *Eur J Med Res* 2025;30:768** — review of VR in anaesthesia simulation, Chinese perspective.
- I could **not** verify a specific Chinese commercial VR bronchoscopy SKU. Candidates repeatedly surfacing in trade contexts (Tellyes/天堰, Honglian/弘联, Yimo/医模) sell physical and screen-based simulators, but no bronchoscopy-specific product page was retrievable. Treat "Chinese commercial VR bronchoscopy product" as **`[UNVERIFIED]`** until someone confirms a SKU. Note also that CAE ships EndoVR in Simplified Chinese, which implies real demand there.

### 3.8 Korea, Taiwan, India, and the rest

- **Korea:** no commercial VR bronchoscopy product found in indexed literature. Korean work is adjacent: Kwon K et al., *J Korean Med Sci* 2020;35:e90 ([PMC7105510](https://pmc.ncbi.nlm.nih.gov/articles/PMC7105510/)) on virtual anatomical/endoscopic exploration for training simulators; Kim Y et al., *Clin Endosc* 2023;56:1–13 on simulator-based GI endoscopy training generally; Han SH et al., *Korean J Anesthesiol* 2025;78:105–117 on extended reality in anaesthesia. Korean bronchoscopy training appears to rely on imported platforms (ORSIM/BRONCH Mentor) and physical models. **Finding: Korea = market, not manufacturer, for this specialty.**
- **Taiwan:** strong low-cost manufacturing angle — Lee CT 2026 (3D-printed difficult airway RCT) and Liu WL 2023 (3D-printed bronchial tree), above.
- **India:** Jothir Surya Teja Y et al., *Cureus* 2026;18:e106843 ([PMC13159498](https://pmc.ncbi.nlm.nih.gov/articles/PMC13159498/)) — "Development and Validation of a **Low-Cost** Simulation Tool for Practical Training in Diagnostic Bronchoscopy for Otolaryngology Postgraduates." Indicative of the price-sensitive segment.
- **Brazil:** Vieira LMN et al., *Pediatr Pulmonol* 2023;58:3227–3234 — the "modelling example" RCT, below.
- **Netherlands/Denmark:** Gerretsen ECF et al., *Anaesth Intensive Care* 2025;53:369–378 ([PMC12619847](https://pmc.ncbi.nlm.nih.gov/articles/PMC12619847/)) — development and evaluation of a bronchoscopy simulation training programme for ICU fellows; Denmark via CAMES is the methodological heart of the field (Konge, Cold).
- **Poland:** Pirozynski M & Jakimowicz J, *Adv Simul* 2026;11:55 ([PMC13470932](https://pmc.ncbi.nlm.nih.gov/articles/PMC13470932/)) — how bronchoscopy simulation went from prototype to a **mandatory national component of postgraduate pulmonary training** in 2024: 402 physicians, 85 certified instructors, 184 training cycles, 5,999 instructional hours, 186 pulmonary trainees of whom 185 completed. Useful as a real-world curriculum-integration template.

### 3.9 Companies that do *not* have a bronchoscopy product — and why it matters

The brief asked about Mentice, VirtaMed, Medical-X, InSimo, AnatomyX, FundamentalVR, Osso VR/Precision OS, SimX, Arch Virtual, ImmersiveTouch. The honest answer, verified by inspecting their own sites, is that **almost none of them sell bronchoscopy**:

| Company | What they actually sell | Bronchoscopy? |
|---|---|---|
| **Mentice** ([simulators](https://www.mentice.com/simulators)) | Endovascular / image-guided intervention (VIST G7, haptics) | No |
| **VirtaMed** ([site](https://www.virtamed.com/en)) | Robotics, orthopaedics, OB/GYN, urology, general surgery; "hyper-realistic digital twins"; Connect cloud LMS; NPS >90 claim | No |
| **Medical-X** ([site](https://medical-x.com/)) | Patient simulators (ADAM-X, NENASim), laparoscopic simulators, task trainers, **webshop with public prices** | No |
| **InSimo** ([site](https://www.insimo.com/)) | diSplay U/S ultrasound, ROBOTiS robotic surgery, Sim&Care punctures/injections; SOFA-based soft-tissue biomechanics out of Inria/IHU Strasbourg | No — but has a "Pulmonary" specialty and thoracentesis |
| **Fundamental XR** (formerly FundamentalVR) ([site](https://www.fundamentalxr.com/)) | Custom XR + haptics across ophthalmology, endovascular, robotics, gene therapy, urology; 500k+ training hours claimed | No |
| **SimX** ([site](https://www.simxvr.com/)) | VR *patient encounters*: Virtual Manikin, AI assistant, marketplace, patented multiplayer, offline mode, scenario editor | No |
| **Osso VR / Precision OS** | Orthopaedic / procedural VR with haptic hand-controllers | No (ortho only, as expected) |
| **ImmersiveTouch, Arch Virtual, "AnatomyX"** | Could not retrieve product pages; no bronchoscopy evidence found | `[UNVERIFIED]` — treat as absent |

**Interpretation.** Bronchoscopy is a small, high-specialisation niche with one dominant validated platform (ORSIM), one legacy cart (CAE), one premium curriculum platform (BRONCH Mentor), and physical manikins. The big generalist VR surgical-simulation companies have all stayed out. That is both encouragement (no giant will crush an open-source entrant) and warning (the market is small; the winning products are *deeply* specialty-specific, not generic).

### 3.10 Free and web-based tools — your actual prior art

- **BronchSim** — [live](https://bronchsimulator.com), [source](https://github.com/andreajonas/bronchsimulator). **CC BY 4.0.** Three static files, no build step: `index.html` (Three.js via CDN), `airway.data.js` (flight path centreline + anatomy labels), `airway.model.js` (**3D airway mesh inlined as base64 glTF**). Pipeline documented in the README: "A watertight CT-derived airway surface was centerline-extracted (**3D Slicer / VMTK**), processed into a navigable branch tree, and paired with the mesh for a first-person fly-through. Segmental labels were placed on the mesh sub-branches and reviewed for anatomical accuracy." Features: on-screen joystick, schematic map, anatomy/quiz mode. Authors: Andrea Jonas MD (Stanford); airway model courtesy of Dr Henry Guo and Chris Le Castillo; anatomical review by Dr Brian Shaller. **"For education only — not for clinical use or diagnosis."**
- **BronchoSim** — [broncho-sim.vercel.app](https://broncho-sim.vercel.app/simulator): "procedurally modelled tracheobronchial tree (trachea → segmental and subsegmental bronchi)", free mode plus "scored navigation and identification tasks", plus an airway atlas, equipment guide and self-assessment. Procedural generation rather than CT-derived — a different, defensible trade-off.
- **PIE Virtual Bronchoscopy** (University of Toronto / UHN, [page](https://pie.med.utoronto.ca/VB/VB_content/simulation.html)) — a Flash-era classic, now runnable via the Ruffle emulator. Its design is worth copying conceptually even though the tech is dead: directional arrows to advance/withdraw/torque, clickable **A–Z anatomical labels**, and a **"Bronchial Tree Navigational Map"** showing the scope's current position as an orange line. The companion post-test gives scores and compares the learner against "the mean scores of others taking the test with similar levels of bronchoscopy experience."

### 3.11 Notes on claims I could not verify

- **Softmimics** "Virtual Bronchoscopy Simulator" (electromagnetic navigation bronchoscope + 1:1 physical airway model + "realistic endoscopic haptics") — the site refused connections on repeated attempts; I have only a search-result description. `[UNVERIFIED]`
- **ORSIM tip-articulation instrumentation** — the vendor says "fully functional bronchoscope" and photos show a lever, but no public spec states whether lever angle and torque are measured or cosmetic. `[UNVERIFIED]`
- **CAE EndoVR current module count and case list** — the "Available Procedural Modules" block on the live page renders empty; brochure PDFs were unparseable. `[UNVERIFIED]`
- **BRONCH Mentor scope hardware** — "designated bronchoscopy panel and scopes" is as specific as Surgical Science gets publicly. No published force-feedback specification. `[UNVERIFIED]`
- **MDPI, "Simulation-Based VR Bronchoscopy Training: ADDIE-Driven…"** (2813-141X/5/3/94, Meta Quest 3 + controllers) — exists per search metadata but the page returned an empty body and I could not verify its content. If it is what the snippet says, it is the only Quest-native bronchoscopy training paper and you should chase it.

---

## 4. The evidence base

### 4.1 What the meta-reviews say

| Study | Design | Finding |
|---|---|---|
| **Kennedy CC et al., *Chest* 2013;144:183–192** ([PMC3707173](https://pmc.ncbi.nlm.nih.gov/articles/PMC3707173/)) | Systematic review + meta-analysis, 17 studies | vs no intervention: **large** benefit on skills/behaviours (ES 1.21, 95% CI 0.82–1.60), **moderate** on time (0.62). vs clinical instruction with real patients: **non-significant** (time 0.61, process 0.33; n=2 each). Instructional-design analysis: longer/more structured training is better, authentic clinical context adds value, and **"animal models and plastic part-task models may be superior to more costly virtual-reality simulators"** |
| **Gerretsen ECF et al., *Chest* 2023;164:952–962** ([PMC10645598](https://pmc.ncbi.nlm.nih.gov/articles/PMC10645598/)) | Systematic review, 14 studies | 11/14 positive, but risk of bias moderate/high in 8, only 6 high-quality. **Only 4 studies measured behavioural outcomes in patients.** "Definitive conclusions regarding training effectiveness on actual bronchoscopy performance in patients could not be made." The highest-quality programmes all had **curriculum integration + a range of task difficulty** |
| **McCarthy R et al., *BJA* 2026;136:1595–1605** ([PMC13197900](https://pmc.ncbi.nlm.nih.gov/articles/PMC13197900/)) | Systematic review of airway-simulator validation, 17 studies, 29 simulators | "**Predictive validity … was rarely evaluated.**" "Validation quality did **not** consistently correlate with simulator fidelity, and several low-fidelity models demonstrated short-term skill transfer comparable with more complex systems." ORSIM = "the most comprehensive validation" among high-fidelity VR. Improvements from AccuTouch/EndoVR "may represent procedural priming rather than sustained skill acquisition." Most predictive studies tested clinical performance **<1 week** after training |
| **Bejani M et al., *Health Sci Rep* 2023;6:e1398** ([PMC10320745](https://pmc.ncbi.nlm.nih.gov/articles/PMC10320745/)) | Systematic review of VR bronchoscopy learning outcomes | Positive for novices; "further studies are needed" |

### 4.2 Studies that change design decisions

| Study | Design | Finding | Design consequence |
|---|---|---|---|
| **Deng M et al., *Thorax* 2026** | RCT, n=60 novices, 3 arms, 3-month retention | **Multiple CT-derived trees > one standard tree** for transfer to a novel tree (DC +2.5 segments, SP +9 progressions, p<0.001), retained at 3 months | Ship **many** patient-derived cases, not one beautiful one. Case *variety* is the pedagogy |
| **Su P et al., *Respiration* 2025** | RCT, n=36 residents, 12 sessions, 3 arms | Tutor > VR guidance > (VR guidance = control on SP) | **Do not** make continuous automatic steering guidance the default; it teaches nothing |
| **Naik A et al., *Respiration* 2026** | RCT, n=30, VR (ORSIM) vs AR (Ambu) | VR slightly better on diagnostic completeness (17 vs 16/18, p=0.0022); no difference on SP/PT/MIT; VR lower mental demand, **higher physical demand** | Headset ergonomics/neck load is a real cost; measure NASA-TLX in your own pilots |
| **Cold KM et al., *Chest* 2024** | RCT, n=20 novices | AI segment-ID feedback: DC +3.5 segments, SP +13.5, PT −214 s | **Segment identification overlay** is the highest-value teaching aid per unit of work |
| **Agbontaen KO et al., *Crit Care Med* 2025** | RCT, n=40 physicians | AI guidance beat expert tutors on MIT/PT/segments-revisited | Automated feedback can beat scarce experts *for efficiency* — but see Su 2025 for sequencing |
| **Vieira LMN et al., *Pediatr Pulmonol* 2023** | RCT, n=47 students, 12-month follow-up | **"Modelling example"** (expert demonstration) beat a video lesson on all metrics at post-test, 15 days and 12 months; lower cognitive load | **Expert-run replay / worked example is the strongest cheap UX intervention available** |
| **Sun M et al., *BMC Anesthesiol* 2026** | Validation, n=30 | 6 cases for formative reliability, 10 for summative; pass/fail 34.4% | Case *count* requirements are known — plan for ≥10 cases per summative exam |
| **Konge L et al., *Eur Respir J* 2015** | RCT, EBUS | Simulator > apprenticeship on EBUSAT (24.2 vs 20.2) | EBUS is the highest-value advanced module |

---

## 5. Synthesis

### 5.1 Must-have features across successful products

| Feature | Who has it | Why it matters |
|---|---|---|
| **Physical, scope-shaped input device** | ORSIM (replica scope), CAE EndoVR (replica scopes + haptic device + scope holder), BRONCH Mentor (panel + scopes), Softmimics (EM-navigable scope) | Every validated product has one. It is the single strongest predictor of product success in this category. It carries proprioceptive fidelity the display cannot |
| **Axial insertion/withdrawal force feedback** | CAE AccuTouch/EndoVR explicitly; BRONCH Mentor/ORSIM claim haptics `[MARKETING]` | Teaches the "push gently, don't shove" habit; the only haptic that is unambiguously claimed in public specs |
| **Structured, named anatomy with segment labels** | BRONCH Mentor (IASLC nodes + segment naming), Ambu AR overlay (18 segments), BronchSim (segmental labels), PIE (A–Z labels) | Segment naming is a validated learning objective and a validated metric (Pastis task 3 discriminated) |
| **Schematic map / position indicator** | BRONCH Mentor ("scope locator" in GI line), PIE ("Bronchial Tree Navigational Map" with orange line), BronchSim ("schematic map"), Ambu AR ("position within the lung tree") | Solves the core perceptual problem: the operator cannot see where the scope is. Present in every product that teaches orientation |
| **Skill tasks separated from clinical cases** | BRONCH Mentor Essential Bronchoscopy vs Diagnostic/Emergency; CHEST curriculum's Essential Skills vs Clinical segments; ORSIM's "learning anatomy" vs "freestyle" | Novices need part-task practice; Procedural tasks need cognitive load. Mixing them is why novices stall |
| **Instant per-run feedback + scoring** | ORSIM (instant feedback, score), Ambu (per-run SP/DC/PT), CAE (dynamic performance reporting), BRONCH Mentor (post-task feedback) | Feedback immediacy is the mechanism, not the metric |
| **Session recording + playback** | ORSIM explicitly ("session recording", "play-back") | Lets a tutor debrief without being present; underpins the "modelling example" effect |
| **Curriculum / LMS layer** | MentorLearn (Surgical Science), VirtaMed Connect, CAE curriculum builder, SimX marketplace | Institutions buy programmes, not boxes. Learning-curve graphs and cohort reporting are procurement requirements |
| **Case library with real patient data** | CAE ("real patient data … physiological models"), BRONCH Mentor ("reactive virtual patients"), Deng's digital twins (CT-derived) | Variety transfers (Deng 2026); realism claims are marketing until anatomy is verified |
| **Sedation / physiology model** | BRONCH Mentor (moderate sedation + dynamic complications), CAE (vitals, sedation titration without desaturation) | Bronchoscopy is a sedation procedure; teaching scope handling alone is incomplete |
| **Portability** | ORSIM (9 kg, hard case, "stored in a drawer"), BRONCH Express | Determines whether the device actually gets used between courses |
| **Society endorsement** | BRONCH Mentor (AABIP, CHEST), ORSIM (airway-society courses), CAE (institutional) | Endorsement is what turns a simulator into a curriculum |
| **Non-Windows option** | **Nobody** | Your opening |

### 5.2 Common weaknesses and complaints

Grounded in published critiques where possible, since consumer reviews were unavailable.

1. **Cost.** "The main disadvantage of virtual simulators is their high cost" (Triantafyllou 2014). Concrete: $46k–$114k for endoscopy platforms; ~$30k CDN for ORSIM. `[EVIDENCE]`
2. **Windows-only, cart-bound, laptop-tethered.** ORSIM requires its bundled laptop; CAE and Surgical Science are Windows carts. No Linux support anywhere. `[OBSERVED]`
3. **Single-path scoring that punishes valid alternatives.** Documented in detail by Sun 2026 — false negatives for experts, and novices who "beat the simulator" rather than learn anatomy. `[EVIDENCE]`
4. **Unclear feedback UI for novices.** Naik 2026 on ORSIM: "more complex and arguably unclear format of feedback for novices." `[EVIDENCE]`
5. **Guidance that replaces thinking.** Schmidt & Wulf's guidance hypothesis, invoked by Naik 2026; Su 2025 shows continuous VR guidance ≈ no guidance. `[EVIDENCE]`
6. **Weak or absent haptics on VR, and overconfidence when haptics are missing.** "A lack of haptic feedback is said to lead to overconfidence in VR users' skill level" (Naik 2026, citing Drascic & Milgram). `[EVIDENCE]`
7. **VR ranks poorly on learner preference.** Naik 2026: "Participants most commonly rank VR as the least useful in terms of skills acquisition and that training on other models yielded a greater sense of satisfaction." `[EVIDENCE]`
8. **Physical trainers' anatomy is measurably wrong.** Schalk 2015, Blackburn 2021, Schebesta 2012 — manikin airways diverge from human CT. `[EVIDENCE]`
9. **Simulators fail to discriminate expert skill.** Kim S et al., *Surg Endosc* 2010 — "Lack of a discriminatory function for endoscopy skills on a computer-based simulator"; Phitayakorn 2009 found wide expert score ranges. Pastis 2014 found two of four BRONCH Mentor tasks non-discriminative. `[EVIDENCE]`
10. **Evidence stops at short-term transfer.** McCarthy 2026: predictive studies mostly <1 week; "procedural priming" rather than durable skill. Gerretsen 2023: only 4 studies measured patient-setting behaviour. `[EVIDENCE]`
11. **Limited case libraries.** ORSIM's 30-scenario base, +12/+15 paid modules, is generous by market standards — and still small relative to the anatomy a bronchoscopist must learn. `[OBSERVED]`
12. **Poor debrief depth.** Where debrief exists it is metric tables and learning curves (MentorLearn) rather than replay-with-commentary. Only ORSIM documents recording/playback. `[MARKETING/OBSERVED]`
13. **Ageing hardware.** Used EndoVR units on eBay/resale sites; CAE's site content frozen at 2021. `[OBSERVED]`

### 5.3 How they model the bronchoscope

This is the least documented part of the market. What can be established:

**Tip articulation (up/down lever; left/right).** Real flexible bronchoscopes articulate the distal tip in two planes via a thumb lever (up/down) and torque/rotation of the shaft (left/right). Note the asymmetry that matters for your controller design: **there is no left/right lever on a bronchoscope** — left/right is achieved by *rotating the shaft*. Products that claim "left/right" controls are usually abstracting. No vendor publishes whether the lever's angle is sensed or its torque fed back. `[UNVERIFIED across the sector]` Softmimics is the only vendor explicitly claiming a "real bronchoscope" with "realistic endoscopic haptics" in a hybrid rig.

**Insertion/withdrawal.** The best-documented modality. ORSIM: a sensor unit "registers movement of the insertion tube" — i.e. a translation sensor on the shaft, not a force sensor. `[MARKETING]` CAE AccuTouch/EndoVR: "active force feedback during insertion and removal of the scope from the mannequin" — motorised resistance on the shaft. `[MARKETING]`

**Rotation / torque.** Undocumented in every product. Physically, rotation is what makes bronchoscopy hard (the "torque the shaft to steer the tip" skill), so its absence is likely why orientation tasks fail to discriminate (Pastis tasks 2 and 4).

**Suction and working channel.** BRONCH Mentor documents the tools rather than the physics: biopsy forceps, cytology brush, aspiration needle, BAL (Diagnostic); grasping forceps, balloons, electrocautery (Emergency); "actual (modified) needle" with a simulated US console (EBUS). CAE lists "reproduction endoscope accessories". ORSIM's pulmonology module implies tools but publishes no list. `[MARKETING]`

**Collision with airway walls.** Present as a *metric*, not a *force*: ORSIM reports "collisions avoidance (%)"; Pastis 2014 measured "wall hits"; BronchSim/BronchoSim penalise deviation. Nobody publishes a wall-contact model with friction/compliance. This is the clearest technical gap you can exploit: **real collision response (haptic + visual blanching/mucosal deformation + bleed risk) is unclaimed territory**.

**Physiological coupling.** BRONCH Mentor couples scope handling to a "reactive virtual patient" with sedation, haemodynamics and complications (hypoxaemia, hypotension, arrhythmia, cardiac arrest, pneumothorax, bleeding). CAE couples to vitals and sedation titration. Nothing couples *scope contact* to physiology (e.g. traumatic bleeding from wall collision). Also unclaimed.

### 5.4 How they present anatomy and orientation

**Anatomy source:**
- **Generic parametric model** — BronchoSim (procedural tree), most physical manikins.
- **Single CT-derived model** — BronchSim (one watertight CT surface, centreline-extracted), Koken/Kyoto phantoms (moulded from a nominal anatomy).
- **Multiple patient-derived CT models** — Deng 2026 "digital twin" simulator (the only one with RCT evidence that variety helps); Okachi 2026 (10 datasets, one per segment, from thin-slice CT via Ziostation REVORAS).
- **"Real patient data + physiological models"** — CAE's claim, unverifiable.

**Orientation aids actually shipped:**
| Aid | Products | Notes |
|---|---|---|
| Schematic 2D bronchial tree with current position | PIE (orange line), BronchSim (schematic map), Ambu AR (position in lung tree), BRONCH Mentor (scope locator) | The most universal aid. Cheap, effective |
| Segment labels overlaid on the live view | Ambu AR (labelled segments on monitor), BronchSim (labels on mesh), PIE (A–Z clickable labels) | Strongest evidence base: Cold 2024, Agbontaen 2025 |
| Lymph-node station labelling (IASLC 2009) | BRONCH Mentor Essential Bronchoscopy | Explicit learning objective; note Pastis 2014 found node anatomy **did not** discriminate |
| CT correlation | BRONCH Mentor EBUS ("multi-plane CT scans", "Ultrasound-CT Relations"); Okachi AVP (STL tree + nodule in green) | Bridges the 2D-CT-to-3D-route translation problem Okachi names explicitly |
| Depth markers / insertion depth | none found in public specs | Gap |
| Fluoroscopy / X-ray | none found in public specs for bronchoscopy training; EBUS modules use US + CT instead | Gap. Real peripheral bronchoscopy uses fluoro; a simulator that teaches fluoro interpretation would be novel |
| 3D model co-located with live video in a headset | Okachi 2026 (AVP, NDI) | Research-grade; latency 250 ms |
| Holographic/MR overlay on patient | Ina 2026, Okachi/Sugimoto (HoloLens 2 + Holoeyes MD) | Clinical navigation, not training |

**Key insight:** every successful product solves orientation *outside* the endoscopic view (map, labels, co-located model). None solves it *inside* the view (e.g. subtle in-lumen wayfinding cues). That is a design space.

### 5.5 Case and task types shipped

| Case/task type | BRONCH Mentor | CAE EndoVR | ORSIM | Ambu/phantom | Notes |
|---|---|---|---|---|---|
| Normal anatomy tour / systematic inspection | ✔ (Essential, AABIP) | ✔ (basic bronchoscopy) | ✔ | ✔ | Universal first task |
| Segment naming / identification quiz | ✔ | ✔ (anatomy plates) | ✔ (learning anatomy mode) | ✔ (AI labels) | Strong evidence (Cold 2024) |
| Lymph node stations (IASLC) | ✔ | EBUS-TBNA module | ✘ | ✘ | Niche but credentialing-relevant |
| Secretions / suction / pulmonary toilet | ✔ (therapeutic aspiration) | ✔ | ✔ (pulmonology) | ✔ (TruCorp) | |
| Biopsy of a lesion (endobronchial) | ✔ | ✔ | ✔ (pulmonology) | ✘ | |
| Transbronchial biopsy / TBNA | ✔ | ✔ (EBUS-TBNA) | ✔ | ✘ | |
| BAL | ✔ | ✘ | ✔ | ✘ | |
| Cytology brushing | ✔ | ✔ | ✔ | ✘ | |
| Foreign body removal | ✔ (Emergency) | ✘ | ✘ | ✘ | Differentiator: forceps, balloons, electrocautery |
| Endobronchial bleeding | ✔ (Emergency) | ✘ | ✘ | ✘ | Differentiator: multiple tools, complication cascade |
| Difficult airway / intubation via scope | ✘ (not its focus) | ✘ | ✔✔✔ (core: 12 difficult airways) | ✔ | ORSIM's core market is anaesthesia, not pulmonology |
| Paediatric airway | ✘ | ✘ | ✔ (12-scenario module) | ✔ (TruCorp Child) | |
| EBUS-TBNA stations | ✔ (Essential EBUS) | ✔ | ✘ | ✘ | Highest-value advanced module (Konge 2015) |
| Sedation management / complications | ✔ | ✔ | ✘ | ✘ | BRONCH Mentor's "reactive virtual patient" |
| Emergency/ICU scenarios (hypoxaemia, arrest) | ✔ | partial | ✘ | ✘ | |
| Peripheral nodule navigation / bronchoscopy | ✘ | ✘ | ✘ | ✘ | **Nobody simulates this well** — yet it is the hardest real-world skill and the subject of Okachi/Deng's work. Big opportunity |
| Cryobiopsy, stents, valves, BLVR | ✘ | ✘ | ✘ | ✘ | Untouched in simulation; VSTAT (Soliman 2026) is a new BLVR assessment tool needing a platform |
| Team/multiplayer training | ✘ | ✘ | ✘ | ✘ | SimX has multiplayer but no bronchoscopy |

**The white space:** peripheral nodule navigation, EBUS station completeness with a proper US image model, therapeutic/interventional procedures beyond bleeding and foreign body, and multiplayer/team bronchoscopy (bronchoscopist + assistant + nurse) — the latter is how bronchoscopy is actually performed and no simulator models it.

### 5.6 UX patterns for teaching scope handling

The evidence here is unusually clear, and it partly contradicts what most simulators do.

**Patterns in use:**

| Pattern | Who uses it | Evidence verdict |
|---|---|---|
| **Free navigation mode, no aids** | ORSIM "freestyle"; BRONCH Mentor "aided/unaided" cases; BronchSim free mode | **Essential.** Naik 2026 trained the VR group on freestyle precisely because metrics wouldn't be available in the test; Su 2025's control group improved simply by practising |
| **Continuous automatic steering guidance (ghost path)** | "VR-guidance" arm in Su 2025; broadly the default in simulator design | **Negative.** VR guidance ≈ no feedback (SP 15.0 vs 15.5, p=1.00); worse than tutor (18.0, p=0.026). Guidance hypothesis: continuous concurrent feedback degrades learning |
| **Segment identification overlay** | Ambu AR (live labels + SP score); ORSIM anatomy mode | **Strongly positive** (Cold 2024; Agbontaen 2025 — the latter beat expert tutors) |
| **Post-run scorecard with DC/SP/PT** | All | Positive, but *format* matters: novices found ORSIM's unclear and preferred Ambu's simple per-run format (Naik 2026) |
| **Expert demonstration / "modelling example"** | Rare as a product feature; BRONCH Mentor has tutorial movies (EBUS) | **Strongest cheap intervention in the literature.** Vieira 2023: better at post-test, 15 days, *and* 12 months; lower cognitive load. Under-exploited commercially |
| **Recording and playback of own run** | ORSIM (explicit) | Enables tutor-free debrief; the substrate for the modelling-example effect |
| **Proficiency-based progression / mastery learning gates** | MentorLearn; BRONCH Mentor CHEST curriculum (Training vs Assessment mode); ORSIM validation test with pass/fail 34.4% | Standard of care in this field. Needs a defensible pass/fail standard, not "you finished" |
| **Cognitive quiz interleaved with psychomotor task** | BRONCH Mentor CHEST Clinical segment | Distinctive and sensible: assess knowledge and handling "as one continuous entity" |
| **Difficulty dial per case** | Kyoto Kagaku MW19 (mouth opening, stiff neck, oedematous tongue, laryngospasm); ORSIM's 12 graded airways | Visible in the best physical trainer; rare in software. Cases should have adjustable difficulty, not fixed difficulty |
| **Leaderboard / peer comparison** | PIE post-test ("mean scores of others … with similar levels of bronchoscopy experience") | Cheap motivation; use cohort-relative norms, not absolute |
| **Transparency / ghost anatomy / scope shadow** | none found | **Gap.** No product lets you fade the airway wall or see a translucent scope inside a solid lung — the obvious wayfinding aid for a headset |
| **Haptic collision cue** | none found | **Gap** |
| **In-view (inside-the-lumen) wayfinding cues** | none found | **Gap** |

**The synthesis for your UX:** sequence it as (1) free exploration with segment labels and a map, (2) expert modelling example replay, (3) deliberate practice with post-run metrics, (4) unaided test. Guidance should be *episodic and on demand* ("show me the map", "show me the labels"), never continuous and default-on.

---

## 6. Prioritised "steal this" list

Ordered by value-per-effort for a Linux/Vive/Godot OpenXR clone. Effort is my estimate: S ≈ days, M ≈ weeks, L ≈ months.

### P0 — build these first; they define whether the thing works at all

| # | Steal this | From whom | Why | Effort |
|---|---|---|---|---|
| 1 | **CT-derived airway mesh pipeline** — watertight surface → centreline (3D Slicer + VMTK) → branch tree → glTF + segment labels | BronchSim (CC BY, reusable) | Deng 2026 proves CT-derived *variety* transfers; BronchSim proves the pipeline is tractable in a browser. Don't reinvent it | M |
| 2 | **A physical, scope-shaped controller** — 3D-printed bronchoscope handle with a working thumb lever + tracked Vive tracker, plus keyboard/mouse fallback | ORSIM / CAE pattern | Every validated product has one; it is the category's actual product. Your Vive tracker is the cheap version of ORSIM's sensor box | M–L |
| 3 | **Segment-identification overlay** (label what the camera is looking at, with confidence) | Ambu BPS | Best evidence-per-effort in the literature: DC +3.5 segments, SP +13.5, PT −214 s (Cold 2024); beat expert tutors for efficiency (Agbontaen 2025) | M |
| 4 | **The validated metric set** — DC (segments/18), SP (correct sequential progressions), PT, MIT = PT/DC, segments revisited, wall hits, mid-lumen time | ORSIM + Pastis 2014 BRONCH Mentor study | Instantly makes your output comparable to the published literature and certifiable. No ML needed | S–M |
| 5 | **Schematic map with live scope position and insertion depth** | PIE (orange line), BronchSim, Ambu | Solves the core perceptual problem; present in every product that teaches orientation; trivially cheap in 2D UI | S |
| 6 | **Free-navigation mode with zero aids**, as a first-class mode | ORSIM freestyle; Naik 2026 test conditions | Required for transfer testing; and Su 2025 shows practice alone produces learning | S |
| 7 | **Post-run scorecard with explicit pass/fail standard** (contrasting-groups derived, not arbitrary) | ORSIM validation (34.4%); MentorLearn proficiency gates | Mastery learning is the standard of care; a defensible standard is what makes it credentialling-relevant | M |

### P1 — the things that make it *better* than the incumbents

| # | Steal this | From whom | Why | Effort |
|---|---|---|---|---|
| 8 | **Expert-run replay ("modelling example") with ghost-scope overlay** | Vieira 2023 evidence; BRONCH Mentor tutorial movies | Best cheap intervention in the literature; works at 12 months; almost nobody sells it | M |
| 9 | **Recording + playback of the learner's own run** with metric timeline scrubbing | ORSIM | Enables tutor-free debrief; prerequisite for #8 | M |
| 10 | **Multiple valid pathways + decision-quality scoring** instead of single-path proximity | Sun 2026's explicit recommendation | Removes the field's most documented scoring pathology (false negatives for experts, "beat the simulator" gaming) | M |
| 11 | **Episodic, on-demand guidance** (hold a button to reveal the map/labels; never continuous) | Su 2025 (negative result), Naik 2026 (guidance hypothesis) | Continuous guidance actively harms learning; this is the correction | S |
| 12 | **Difficulty dial per case** (airway narrowing, secretions, bleeding tendency, sedation sensitivity) | Kyoto Kagaku MW19's adjustable mouth opening/stiff neck/tongue/laryngospasm | Lets one mesh serve a novice and an expert; Gerretsen 2023 found task-difficulty range characterises high-quality programmes | M |
| 13 | **Physiology/sedation model coupled to scope handling** | BRONCH Mentor ("reactive virtual patients"), CAE (vitals, sedation titration) | Bronchoscopy is a sedation procedure; without this you teach a lab skill, not a clinical one | L |
| 14 | **Collision response, not just collision counting** — haptic resistance, mucosal blanching, and a bleed-risk model | Nobody (gap) | Turns your Vive haptics/USB device into a differentiator; couples handling to consequence, which no incumbent does | M–L |
| 15 | **Multiplayer / team roles** (bronchoscopist, assistant, nurse) | SimX's patented multiplayer (different specialty) | Bronchoscopy is a team procedure; no bronchoscopy simulator models it. Vive's multi-headset setup makes it natural | L |

### P2 — differentiators with longer payback

| # | Steal this | From whom | Why | Effort |
|---|---|---|---|---|
| 16 | **EBUS module with a real US console model** — Doppler, depth, gain, contrast, external display, multi-plane CT correlation, LN station demo | BRONCH Mentor Essential EBUS (the most detailed public module spec in the market) | Konge 2015 is a genuine RCT showing simulator > apprenticeship; highest credentialling value | L |
| 17 | **Peripheral nodule navigation with fluoroscopy + radial EBUS + virtual bronchoscopy roadmap** | Nobody (adjacent: Okachi MR/AVP work; Deng digital twins) | The hardest real skill, the biggest clinical need, and completely unserved by simulation | L |
| 18 | **Mixed-reality mode**: colocate the live endoscopic view with the patient-specific 3D tree in-headset | Okachi 2026 (AVP/NDI) | Vive + OpenXR can do this without Apple's stack; watch the 250 ms latency lesson — keep overlay rendering local | M–L |
| 19 | **Curriculum/LMS layer**: cohort management, learning-curve graphs, OSATS/GOALS-style rubrics, export | MentorLearn, VirtaMed Connect, CAE curriculum builder | Procurement requirement; also what makes the project adoptable by a training programme | L |
| 20 | **Free, CC-BY airway model + case library with attribution discipline** | BronchSim's licensing model | Enables the network effect an open-source project needs; sets the ethical standard for CT-derived anatomy | S–M |
| 21 | **3D-printable phantom export from the same mesh** | Liu 2023 / Lee 2026 (3D-printed bronchial trees) | One source of truth for software and hardware; makes the project usable by low-resource programmes | M |
| 22 | **In-view wayfinding cues** (subtle lumen-direction hints, depth ring, translucent scope) | Nobody (gap) | Solves orientation *inside* the view rather than beside it — genuinely novel | M |

### Explicitly do **not** steal

- **Continuous default-on ghost paths** (Su 2025: no better than nothing).
- **Single-path scoring** (Sun 2026: systematically wrong for experts and gameable by novices).
- **A proprietary LMS lock-in** — keep the metric schema open and exportable.
- **A Windows-only dedicated laptop** — that is precisely the incumbent weakness you are answering.
- **A purely game-controller interface** — the evidence says scope-shaped hardware is the category's product.

---

## 7. Open questions worth testing with users before you commit

1. **Tracker-on-handle vs tracker-in-handle**: does a Vive tracker strapped to a 3D-printed scope give acceptable angular resolution for tip articulation, or do you need an IMU in the handle? No vendor data exists; this needs a bench test.
2. **How much haptics is enough?** The literature says haptics may not matter much for novices (Thompson 2011; Salkini 2010, cited in Naik 2026) but may prevent overconfidence. Test: same curriculum with and without collision resistance, measure confidence calibration, not just skill.
3. **Does a headset actually beat a screen for this?** Naik 2026 found VR had *lower* mental demand but *higher* physical demand than AR. Run your own NASA-TLX comparison early — a headset may be the wrong display for a 20-minute procedure.
4. **What is the right case count for your summative test?** Sun 2026 says 10 for reliability >0.8 — validate your own, don't assume.
5. **Which orientation aid actually helps?** Nobody has compared map vs labels vs translucent-scope in a headset. This is an easy, publishable within-subject study.

---

## 8. Source list

**Vendor / marketing** (accessed 2026)
- Surgical Science — [BRONCH Mentor](https://surgicalscience.com/simulators/gi-bronch-mentor/) · [platforms](https://surgicalscience.com/simulators/gi-bronch-mentor/bronch-mentor-platforms/) · [BRONCH Express](https://surgicalscience.com/simulators/bronch-express/) · [Essential Bronchoscopy](https://surgicalscience.com/simulators/bronch-express/essential-bronchoscopy-module/) · [Diagnostic](https://surgicalscience.com/simulators/bronch-express/diagnostic-bronchoscopy-module/) · [Essential EBUS](https://surgicalscience.com/simulators/bronch-express/essential-ebus-module/) · [Emergency](https://surgicalscience.com/simulators/gi-bronch-mentor/emergency-bronchoscopy/) · [CHEST Curriculum](https://surgicalscience.com/simulators/gi-bronch-mentor/chest-standardized-curriculum/) · [MentorLearn](https://surgicalscience.com/mentorlearn/)
- CAE Healthcare — [EndoVR](https://www.caehealthcare.com/surgical-simulation/EndoVR/) · [tech sheet](https://www.hadimedical.com/sites/default/files/EndoVR-TechSheet.pdf) (PDF, unparsed) · [distributor page](https://oniko.cz/en/products/simulators-and-trainers/cae-healthcare/virtualni-hirurgichni-simulyatori/endovr---trenager-gastrointestinalnoi-ta-bronhialnoi-endoskopii.html) · [hadimedical](https://hadimedical.com/content/cae-endovr) · [RFH AccuTouch](https://rfh-simulator-centre.co.uk/pages/our-simulators/accutouch/35/)
- ORSIM — [home](https://www.orsim.com/) · [features](https://www.orsim.com/features) · [design](https://www.orsim.com/design) · [software updates](https://www.orsim.com/software-updates)
- Kyoto Kagaku — [MW19](https://www.kyotokagaku.com/en/products_data/mw19dam/) · [distributor price](https://simtrainingresource.com/product/mw19-difficult-airway-management-simulator-for-bronchofiberscopy/)
- TruCorp — [bronchoscopy simulators](https://trucorp.com/bronchoscopy-simulators/)
- Koken — [English site](https://www.kokenmpc.co.jp/english/)
- Mentice [simulators](https://www.mentice.com/simulators) · VirtaMed [site](https://www.virtamed.com/en) · Medical-X [site](https://medical-x.com/) · InSimo [site](https://www.insimo.com/) · Fundamental XR [site](https://www.fundamentalxr.com/) · SimX [site](https://www.simxvr.com/) · Softmimics (unreachable)
- Free tools — [BronchSim live](https://bronchsimulator.com) · [BronchSim source, CC BY 4.0](https://github.com/andreajonas/bronchsimulator) · [BronchoSim](https://broncho-sim.vercel.app/simulator) · [PIE Virtual Bronchoscopy](https://pie.med.utoronto.ca/VB/VB_content/simulation.html)

**Peer-reviewed** (all links verified; full texts read unless noted)
- Pastis NJ et al. Construct validity of the Simbionix BRONCH Mentor. *J Bronchology Interv Pulmonol* 2014;21:314–321. [doi](https://doi.org/10.1097/LBR.0000000000000111)
- Konge L et al. Simulator training for endobronchial ultrasound: RCT. *Eur Respir J* 2015;46:1140–1149. [doi](https://doi.org/10.1183/13993003.02352-2015)
- Kennedy CC, Maldonado F, Cook DA. Simulation-based bronchoscopy training: systematic review and meta-analysis. *Chest* 2013;144:183–192. [PMC3707173](https://pmc.ncbi.nlm.nih.gov/articles/PMC3707173/)
- Gerretsen ECF et al. Effectiveness of flexible bronchoscopy simulation-based training: systematic review. *Chest* 2023;164:952–962. [PMC10645598](https://pmc.ncbi.nlm.nih.gov/articles/PMC10645598/)
- McCarthy R, Maher L, O'Dea A. Validation status of definitive airway management simulators: systematic review. *BJA* 2026;136:1595–1605. [PMC13197900](https://pmc.ncbi.nlm.nih.gov/articles/PMC13197900/)
- Deng M et al. Digital twin-based bronchoscopy simulator … RCT. *Thorax* 2026;81:483–491. [doi](https://doi.org/10.1136/thorax-2025-223147)
- Su P et al. Feedback from human instructors is superior to guidance by a VR simulator … RCT. *Respiration* 2025;104:701–707. [doi](https://doi.org/10.1159/000546827)
- Naik A et al. VR versus AR bronchoscopy simulation-based training: RCT. *Respiration* 2026 (online). [PMC13221171](https://pmc.ncbi.nlm.nih.gov/articles/PMC13221171/)
- Sun M et al. Ensuring flexible optical intubation skills using a portable VR simulator — validation study. *BMC Anesthesiol* 2026;26:320. [PMC13188312](https://pmc.ncbi.nlm.nih.gov/articles/PMC13188312/)
- Cold KM et al. AI improves novices' bronchoscopy performance: RCT. *Chest* 2024;165:405–413. [doi](https://doi.org/10.1016/j.chest.2023.08.015)
- Agbontaen KO et al. AI-guided bronchoscopy superior to human expert instruction: RCT. *Crit Care Med* 2025;53:e1105–e1115. [PMC12047642](https://pmc.ncbi.nlm.nih.gov/articles/PMC12047642/)
- Vieira LMN et al. Simulation-based bronchoscopy training: randomized trial comparing worked example to video introduction. *Pediatr Pulmonol* 2023;58:3227–3234. [doi](https://doi.org/10.1002/ppul.26648)
- Baker PA et al. Evaluating the ORSIM simulator … validity and reliability. *BJA* 2016;117(S1):i87–i91.
- Wong DT et al. Effect of VR bronchoscopy simulator training on performance of bronchoscopic-guided intubation in patients: RCT. *Eur J Anaesthesiol* 2019;36:227–233.
- Samuelson ST et al. Simulation as a set-up for technical proficiency: can a virtual warm-up improve live fibre-optic intubation? *BJA* 2016;116:398–404.
- Krogh CL et al. Training on a new, portable, simple simulator transfers to performance of complex bronchoscopy procedures. *Clin Respir J* 2013;7:237–244.
- van Haperen M et al. Does regular practice with a "flexible bronchoscopy simulator" improve fibreoptic intubation skills? RCT. *J Clin Med* 2023;12:5195. [PMC10455177](https://pmc.ncbi.nlm.nih.gov/articles/PMC10455177/)
- Okachi S et al. Real-time integration of bronchoscope video and 3D airway models on Apple Vision Pro. *JMIR XR Spat Comput* 2026;3:e103880. [PMC13722140](https://pmc.ncbi.nlm.nih.gov/articles/PMC13722140/)
- Okachi S et al. Motion capture of bronchoscopist kinematics using a spatial computing device. *Respiration* 2026. [doi](https://doi.org/10.1159/res/aepag014)
- Ina T et al. 3D holographic virtual bronchoscopy using mixed reality. *Respiration* 2026;105:967–977. [PMC13134840](https://pmc.ncbi.nlm.nih.gov/articles/PMC13134840/)
- Cold KM et al. Autonomous bronchoscopy robot (BronchoBot) outperforms experienced bronchoscopists. *ERJ Open Res* 2026;12:970-2025. [PMC13080710](https://pmc.ncbi.nlm.nih.gov/articles/PMC13080710/)
- Triantafyllou K et al. Virtual reality simulators for gastrointestinal endoscopy training. *World J Gastrointest Endosc* 2014;6:6–12. [PMC3921444](https://pmc.ncbi.nlm.nih.gov/articles/PMC3921444/)
- Liu WL et al. A 3D-printed high-fidelity bronchial tree for bronchoscopy. *Respir Care* 2023;68:527–530. [PMC10173112](https://pmc.ncbi.nlm.nih.gov/articles/PMC10173112/)
- Lee CT et al. 3D-printed difficult airway models for flexible bronchoscopic intubation training: RCT. *BMC Med Educ* 2026;26:1179. [PMC13386945](https://pmc.ncbi.nlm.nih.gov/articles/PMC13386945/)
- Jothir Surya Teja Y et al. Low-cost simulation tool for diagnostic bronchoscopy training. *Cureus* 2026;18:e106843. [PMC13159498](https://pmc.ncbi.nlm.nih.gov/articles/PMC13159498/)
- Pirozynski M, Jakimowicz J. From prototype to national standard: governance framework for scaling simulation-based bronchoscopy training. *Adv Simul* 2026;11:55. [PMC13470932](https://pmc.ncbi.nlm.nih.gov/articles/PMC13470932/)
- Gerretsen ECF et al. Bronchoscopy simulation training programme for ICU fellows and intensivists. *Anaesth Intensive Care* 2025;53:369–378. [PMC12619847](https://pmc.ncbi.nlm.nih.gov/articles/PMC12619847/)
- Soliman MA et al. VSTAT: BLVR competency assessment tool. *J Bronchology Interv Pulmonol* 2026;33:e01089. [doi](https://doi.org/10.1097/LBR.0000000000001089)
- Kwon K et al. Virtual anatomical and endoscopic exploration method … for training simulator. *J Korean Med Sci* 2020;35:e90. [PMC7105510](https://pmc.ncbi.nlm.nih.gov/articles/PMC7105510/)
- Bejani M et al. Effects of VR-based bronchoscopy simulator on learning outcomes: systematic review. *Health Sci Rep* 2023;6:e1398. [PMC10320745](https://pmc.ncbi.nlm.nih.gov/articles/PMC10320745/)
- Han SH et al. Extended reality in anesthesia: narrative review. *Korean J Anesthesiol* 2025;78:105–117.

**Cited within those papers but not independently verified here** (flagged for follow-up): Kim S et al. *Surg Endosc* 2010 (lack of discriminatory function); Phitayakorn R et al. *Surg Endosc* 2009 (expert benchmarks); Davoudi M et al. *Respiration* 2010 (low vs high fidelity TBNA); Colt HG et al. *Chest* 2001; Ost D et al. *AJRCCM* 2001; Moorthy K et al. *Respiration* 2003; Schalk R et al. *Resuscitation* 2015; Blackburn MB et al. *Anaesthesia* 2021; Schebesta K et al. *Anesthesiology* 2012; Schmidt RA & Wulf G. *Hum Factors* 1997 (guidance hypothesis); Rowe R & Cohen RA. *Anesth Analg* 2002.

---

*Prepared for the open-source VR bronchoscopy simulator project. Where this report says "no published validity evidence found", that is a genuine gap in the literature, not a failure to look — and it is an opportunity, because it means a well-run open validation study would be a first.*
