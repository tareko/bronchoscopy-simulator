# Clinical evidence review: VR / computer-based bronchoscopy simulation

**Purpose.** Inform the design of an open-source VR bronchoscopy trainer (HTC Vive, Godot 4.7 + OpenXR,
eight cases: anatomy tour, peripheral lesion, secretions/suction, bleeding, foreign body, BAL,
EBUS-TBNA, difficult airway/stenosis) aimed at pulmonary and critical-care fellows.

**Scope and method.** Literature was retrieved via the Europe PMC REST API (which indexes PubMed,
MEDLINE and PMC) and PMC full text, supplemented by publisher and guideline pages. Queries covered:
bronchoscopy + simulation/VR/virtual reality; systematic reviews and meta-analyses; RCTs; assessment
instruments (BSTAT, BSET, EBUS-STAT, EBUSAT); instructional design (mastery learning, deliberate
practice, distributed practice, feedback); named commercial simulators; airway/bronchopulmonary
anatomy and nomenclature; cybersickness; haptics; transfer of training. The newest records retrieved
carry 2026 publication years; several are very recent and should be treated as provisional.

**A note on what "VR" means in this literature.** Almost all validated bronchoscopy "virtual reality"
simulators are **screen-based platforms driven by a real or instrumented endoscope handle**
(AccuTouch/Immersion, BRONCH Mentor, EndoSim, ORSIM) — not head-mounted immersive VR. Studies using
head-mounted displays with hand controllers are rare and recent. This distinction matters for every
claim below and is returned to in §7 and in the caveats.

---

## 1. Does simulator training improve performance versus traditional, animal or bench models?

### 1.1 The meta-analytic picture

| Review | Studies / participants | Pooled result |
|---|---|---|
| Cook 2011, *JAMA* — technology-enhanced simulation vs no intervention ([PMID 21900138](https://pubmed.ncbi.nlm.nih.gov/21900138/)) | 609 studies, 35,226 trainees | Process skills ES **1.09** (95% CI 1.03–1.16); time skills **1.14**; knowledge **1.20**; **direct effects on patients 0.50** (0.34–0.66). Heterogeneity I²>50% throughout. |
| Kennedy 2013, *Chest* — bronchoscopy-specific ([PMID 23370487](https://pubmed.ncbi.nlm.nih.gov/23370487/), [PMC3707173](https://pmc.ncbi.nlm.nih.gov/articles/PMC3707173/)) | 17 studies | vs no intervention: skills/behaviours ES **1.21** (0.82–1.60), n=8; time **0.62** (0.12–1.13), n=7. **vs clinical instruction on real patients: non-significant** — time 0.61 (95% CI −1.47 to 2.69), process 0.33 (−1.46 to 2.11), n=2 each. |
| Cook 2013, *Acad Med* — mastery learning ([PMID 23807104](https://pubmed.ncbi.nlm.nih.gov/23807104/)) | 82 studies | vs no intervention: skills **1.29** (1.08–1.50), patient outcomes **0.73** (0.36–1.10). vs non-mastery simulation: skills **1.17** (0.29–2.05), but takes more time. |
| Cook 2013, *Med Teach* — instructional design features ([PMID 22938677](https://pubmed.ncbi.nlm.nih.gov/22938677/)) | 289 studies, 18,971 trainees | See §4. |
| Brydges 2015, *Acad Med* — simulator scores vs workplace outcomes ([PMID 25374041](https://pubmed.ncbi.nlm.nih.gov/25374041/)) | 33 studies, 1,203 participants | Pooled r = **0.51** for provider behaviours (0.38–0.62); **0.44** for time behaviours; **0.24 for patient outcomes** (95% CI −0.02 to 0.47 — crosses zero). |
| Naur 2017, *Respiration* — bronchoscopy + EBUS ([PMID 28343219](https://pubmed.ncbi.nlm.nih.gov/28343219/)) | 30 publications | Simulation-based training "more efficient than the traditional apprenticeship model"; physical and VR models **complementary**; recommends mastery learning + distributed practice. |
| Gerretsen 2023, *Chest* — flexible bronchoscopy SBT ([PMID 37178972](https://pubmed.ncbi.nlm.nih.gov/37178972/), [PMC10645598](https://pmc.ncbi.nlm.nih.gov/articles/PMC10645598/)) | 14 studies (from 544), n=5–54 per study | 11/14 positive on most outcomes; **risk of bias moderate–high in 8**; only 6 of high quality; **only 4 measured behaviour with real patients**. Formal meta-analysis *not possible* — interventions and outcomes too heterogeneous. |
| Bejani 2023, *Health Sci Rep* — VR bronchoscopy simulator ([PMID 37415680](https://pubmed.ncbi.nlm.nih.gov/37415680/)) | 8 studies | 5/5 studies measuring dexterity improved; 2/3 measuring speed improved; improved accuracy and reduced need for verbal/physical assistance. No pooled estimate. |
| McCarthy 2026, *BJA* — airway simulator validation ([PMID 41826217](https://pubmed.ncbi.nlm.nih.gov/41826217/)) | 17 articles, 29 simulators | Most studies assess only 1–2 validity domains; **predictive validity rarely evaluated**; validation quality did not track fidelity. |

**Reading.** The evidence that simulation beats *nothing* is strong and consistent (ES ≈ 1.1–1.3).
The evidence that it beats *traditional apprenticeship on patients* is weak: Kennedy's pooled
comparison against clinical instruction was null with only two studies per outcome, and Gerretsen
could not pool at all. Any claim that a VR trainer is *superior to* supervised patient-based training
is not supported.

### 1.2 Bronchoscopy-specific randomised and controlled studies

Full details in the master table (§9). Headline results:

- **Ost 2001** (n=28 for validation; then an RCT in new fellows): simulator-trained fellows were faster
  on their **first real bronchoscopy** — 815 vs 1,168 s (p=0.001) — with higher nurse-rated quality
  (7.7 vs 3.7, p=0.05) and a higher quantitative quality score (0.119 vs 0.046, p=0.03).
- **Blum 2004** (n=10, RCT): 1 hour of simulator training reduced evaluator verbal cues from 6.2 to 3.2
  and physical cues from 1.6 to 0.2, and improved systematic-examination rating from 2.6 to 4.4/5.
  Procedure time did **not** differ, because the evaluator paced the examination.
- **Konge 2015** (n=16, RCT, EBUS): VR simulator training beat apprenticeship on real patients —
  EBUSAT 24.2 ± 7.9 vs 20.2 ± 9.4 points, p=0.006. **But 67% of simulator-trained and 83% of
  apprenticeship-trained procedures still failed the 28.9-point pass standard** — a reminder that
  "better than apprenticeship" ≠ "competent".
- **Wahidi 2010** (n=44, two cohorts): adding simulation to a fellowship curriculum improved BSTAT at
  **7 of 8** milestone bronchoscopies (p<0.05); an online curriculum did not improve written scores and
  compliance was low.
- **Siow 2021** (n=18, non-randomised two-group): a 3-month structured curriculum with simulation
  produced better modified-BSTAT, MCQ and airway-anaesthesia scores despite **fewer** patient
  procedures; simulator training was the only factor correlating with BSTAT (r=0.80), MCQ (r=0.85) and
  airway anaesthesia (r=0.83).
- **Su 2025** (n=36, three-arm RCT): **tutor feedback beat in-simulator VR guidance**. Structured
  progress was 18 ± 0 vs 15.0 ± 5.3 (p=0.026) for VR guidance and 15.5 ± 4.5 (p=0.017) for no
  feedback; **VR guidance was indistinguishable from no feedback** (p=1.00). All arms improved over 12
  sessions and retained at 3 weeks.
- **Deng 2026** (n=60, three arms): training on **multiple CT-derived anatomies** beat repeated practice
  on one standard model when tested on a *new* anatomy (diagnostic completeness +2.5 segments,
  structured progress +9 correct progressions, both p<0.001), with partial retention at 3 months.
- **Naik 2026** (n=30, VR vs AR, mastery-learning protocols): VR produced slightly better diagnostic
  completeness on the first test model (median difference 1 segment, p=0.0022) but no difference in
  structured progress, procedure time or intersegmental time; AR-trained participants were faster on
  the model they trained on (−48 s, p=0.0377). VR had lower mental demand (15 NASA-TLX points,
  p=0.023) but higher physical demand (+35 points, p=0.004).
- **O'Grady 2026** (n=20, randomised pilot): 2 hours of supervised ORSIM practice beat 10-minute
  familiarisation on simulator composite scores (68.1% vs 45.5% in the hardest scenario), but
  consultant-rated Global Rating Scale scores were "similar" for oral bronchoscopy and only "modestly
  higher" elsewhere. The authors explicitly state this does not establish clinical proficiency.

### 1.3 VR versus animal and bench models

This is the least favourable evidence for a VR-first design and should be confronted openly:

- Kennedy 2013 concluded from inductive analysis that **"animal models and plastic part-task models may
  be superior to more costly virtual-reality simulators"** ([PMID 23370487](https://pubmed.ncbi.nlm.nih.gov/23370487/)).
- Davoudi 2010 (randomised crossover at CHEST 2008) found learners and instructors **preferred
  low-fidelity models** over a high-fidelity VR platform for conventional TBNA — for realism (23 vs 17),
  ease of learning (20 vs 6), and as the ideal model overall (19 vs 11); instructors 8–0 and 9–0 in
  favour of low fidelity ([PMID 20616534](https://pubmed.ncbi.nlm.nih.gov/20616534/)). These are
  *perceptions*, not performance, but the direction is consistent.
- McCarthy 2026 found that "several low-fidelity models demonstrated short-term skill transfer
  comparable with more complex systems" ([PMID 41826217](https://pubmed.ncbi.nlm.nih.gov/41826217/)).
- Conversely, Feng 2020 showed *unstructured* practice on a low-fidelity model produced learning gain
  and some retention ([PMID 32168034](https://pubmed.ncbi.nlm.nih.gov/32168034/)), and Byrne 2016 built
  a CT-derived 3D-printed trainer rated realistic by experienced bronchoscopists
  ([PMID 27070341](https://pubmed.ncbi.nlm.nih.gov/27070341/)) — cost, not fidelity, is the differentiator.

**Implication:** the case for a VR trainer is *access, repeatability, standardisation, automatic
metrics and rare-event rehearsal* — not superior skill transfer per hour. The report should not claim
otherwise, and the trainer should not try to out-fidelity a £200 3D-printed airway for basic
navigation; it should win on measurement and on scenarios a plastic model cannot do (bleeding,
desaturation, variant anatomy, remote/distributed practice).

### 1.4 Validity evidence in the Messick framework

Messick's five sources (content, response process, internal structure, relations to other variables,
consequences) are the accepted organising scheme; Cook et al. reviewed how rarely each is actually
reported ([PMID 23636643](https://pubmed.ncbi.nlm.nih.gov/23636643/)). The single best bronchoscopy-
adjacent exemplar is a 2026 ORSIM flexible-optical-intubation validation that explicitly explored all
five sources ([PMID 41963810](https://pubmed.ncbi.nlm.nih.gov/41963810/), [PMC13188312](https://pmc.ncbi.nlm.nih.gov/articles/PMC13188312/)).

| Messick source | Status in bronchoscopy simulation | Evidence |
|---|---|---|
| **Content** | **Moderate–strong.** Instruments are built by expert task decomposition and map onto a taught procedure sequence. | BSTAT and BSET developed as objective task-based instruments ([Davoudi 2008](https://pubmed.ncbi.nlm.nih.gov/18408359/)); the "four landmarks" systematic bronchoscopy sequence and its three outcome measures are used at all Danish simulation centres ([Cold 2023](https://pubmed.ncbi.nlm.nih.gov/37427954/)); a six-landmark EBUS sequence underpins the ERS EBUS certification programme ([Nielsen 2023](https://pubmed.ncbi.nlm.nih.gov/37590526/)). |
| **Response process** | **Weak.** Almost never studied — no think-aloud or rater-cognition work in bronchoscopy simulation located. | Brydges 2015: response-process evidence in only **2 of 33** simulation-assessment studies ([PMID 25374041](https://pubmed.ncbi.nlm.nih.gov/25374041/)). |
| **Internal structure** | **Strong where reported.** | BSTAT/BSET inter-rater ICC **0.98**; test–retest **0.86 / 0.85** ([Davoudi 2008](https://pubmed.ncbi.nlm.nih.gov/18408359/)). EBUS-STAT inter-tester r = **0.9991** ([Davoudi 2012](https://pubmed.ncbi.nlm.nih.gov/22837376/)). EBUSAT Cronbach α **0.95**, G-coefficient **0.86** ([Konge 2015](https://pubmed.ncbi.nlm.nih.gov/26160875/)). ORSIM FOI test α **0.89**; generalisability analysis required **6 cases for formative** (reliability >0.7) and **10 cases for summative** (>0.8) assessment ([Sun 2026](https://pubmed.ncbi.nlm.nih.gov/41963810/)). |
| **Relations to other variables** | **Moderate.** Known-groups discrimination is the workhorse; correlation with real-patient performance is sparse. | Ost 2001 (experts > intermediates > novices on time, % segments, red-out, collisions); Davoudi 2008 (novice < fellow/attending, p<0.001); Davoudi 2012 (EBUS-STAT 31.1 / 74.9 / 93.6 in beginners / intermediates / experienced, non-overlapping; self-assessment r²=0.81); Pastis 2014 (BRONCH Mentor discriminated on 2 of 4 tasks); Veaudor 2018 (novices reached experienced-level scores). |
| **Consequences** | **Absent.** No bronchoscopy study shows that simulator-based certification changes downstream patient outcomes. | Brydges 2015: consequences evidence in **1 of 33** studies. The Polish national programme that made bronchoscopy simulation mandatory reports only acceptability and self-reported confidence, and explicitly labels these as *not* evidence of clinical competence ([Pirozynski 2026](https://pubmed.ncbi.nlm.nih.gov/42260687/)). |

---

## 2. Which skills are trainable and measurable — and what to build first

| Skill | Trainable on a screen/HMD simulator? | Metric with published validity? | Evidence strength |
|---|---|---|---|
| Scope manipulation (lever + torque + insertion) | Yes | Time, mid-lumen time, **wall hits**, "economy of performance" | **Strong** — discriminates across three independent simulator generations (HT Medical [Moorthy 2003](https://pubmed.ncbi.nlm.nih.gov/12740517/); AccuTouch-class [Ost 2001](https://pubmed.ncbi.nlm.nih.gov/11751195/); BRONCH Mentor task 1 [Pastis 2014](https://pubmed.ncbi.nlm.nih.gov/25321450/)) |
| Systematic navigation / inspection order | Yes | **Structured progress (SP)**, diagnostic completeness (DC), procedure time (PT), average intersegmental time (AIT) | **Strong** — SP correlates with DC (r=0.62) and inversely with AIT (r=−0.52) ([Cold 2020](https://pubmed.ncbi.nlm.nih.gov/33282381/)); SP detected the tutor-feedback effect while DC did not ([Su 2025](https://pubmed.ncbi.nlm.nih.gov/40494327/)) |
| Bronchopulmonary segment identification | Yes | % segments visualised / DC out of 18, segments incorrectly identified, segments skipped | **Strong** — [Ost 2001](https://pubmed.ncbi.nlm.nih.gov/11751195/), [Pastis 2014](https://pubmed.ncbi.nlm.nih.gov/25321450/) (task 3), [Veaudor 2018](https://pubmed.ncbi.nlm.nih.gov/30086734/) |
| Airway anatomy recognition (incl. variants) | Yes | Same as above; identification score | **Moderate** — but note Pastis 2014 task 2 (guided anatomic navigation) and task 4 (lymph node anatomy) **failed to discriminate** |
| Lesion localisation (peripheral) | Partly — depends on a lesion model | No bronchoscopy-specific validated metric located | **Weak** — surrogate metrics only (segmental accuracy, tool-to-target) |
| Suctioning / secretion clearance | Yes mechanically | **None located** | **Absent** — no validated instrument |
| BAL / lavage | Yes | **None located** as a simulator metric; clinical parameters exist (volume, recovery) | **Absent** for simulation; clinical norms in §6.4 |
| Transbronchial biopsy / brush | Yes (bench and VR) | Conventional TBNA learning shown on low- and high-fidelity models; no VR-specific validity | **Weak–moderate** |
| EBUS-TBNA station sampling | Partly — station anatomy is spatial, not luminal | **EBUS-STAT** (0–100; items incl. atraumatic introduction, image optimisation, nodal/vascular identification, sampling, CT/EBUS image recognition); **EBUSAT** (pass/fail 28.9) | **Strong** for the instruments; **weak** for VR-as-the-platform |
| Non-technical / crisis skills (bleeding, lost airway) | Yes, uniquely | **None located** in bronchoscopy | **Absent** |

### What to simulate first, and why

1. **Normal anatomy tour + systematic navigation (case 1).** This is the only domain with repeated
   independent known-groups validation across different simulators and countries
   ([Ost 2001](https://pubmed.ncbi.nlm.nih.gov/11751195/); [Moorthy 2003](https://pubmed.ncbi.nlm.nih.gov/12740517/);
   [Pastis 2014](https://pubmed.ncbi.nlm.nih.gov/25321450/); [Veaudor 2018](https://pubmed.ncbi.nlm.nih.gov/30086734/);
   [Cold 2020](https://pubmed.ncbi.nlm.nih.gov/33282381/)). It is also the **prerequisite** for every
   other case: biopsy, BAL and EBUS all require the trainee to reach a named segment deliberately.
   Sequencing evidence supports it explicitly — the four-landmarks approach is the taught sequence and
   all Danish simulation centres use it ([Cold 2023](https://pubmed.ncbi.nlm.nih.gov/37427954/)).
2. **EBUS-TBNA station sampling (case 7).** The best-instrumented procedure in the field, with two
   independent validated tools and an ERS recommendation that competence be acquired in a simulated
   environment ([Korevaar 2026 ERS/ESGE/ESTS guideline](https://pubmed.ncbi.nlm.nih.gov/42167778/)).
   Build it second because its scoring is already specified. Note the caveat that *station* knowledge
   did not discriminate in one study — teach stations explicitly rather than assuming they emerge.
3. **Peripheral lesion + biopsy/brush (case 2).** Follows navigation naturally; instrument handling on
   airway models has some evidence but no VR-specific validity.
4. **Suction / secretions (case 3) and BAL (case 6).** Mechanically easy to simulate, but **no validated
   metrics exist** — building them means inventing the assessment, which must then be validated
   in-house.
5. **Bleeding (case 4), foreign body (case 5), difficult airway/stenosis (case 8).** These are the
   highest-value *and* least-evidenced modules. They teach decision-making and escalation, not a
   measurable psychomotor construct. Build them, but do not present their scores as validated.

---

## 3. Metrics with published validity evidence

| Metric | What it measures | Instrument / source | Validity evidence |
|---|---|---|---|
| **Procedure time (PT)** | Efficiency; global | Simulator timer, or video review | Discriminated experts from novices ([Ost 2001](https://pubmed.ncbi.nlm.nih.gov/11751195/)); improved with training ([Veaudor 2018](https://pubmed.ncbi.nlm.nih.gov/30086734/): 561→216 s, p=0.002); used in every modern bronchoscopy trial |
| **Structured progress (SP)** | Number of times the operator moves from one segment to the *correct next* segment in ascending order — i.e. systematic rather than arbitrary inspection | Checklist scored by trained rater ([Cold 2020](https://pubmed.ncbi.nlm.nih.gov/33282381/)) | r=0.62 with DC, r=−0.52 with AIT (both p<0.001); **more sensitive than DC** to tutor feedback ([Su 2025](https://pubmed.ncbi.nlm.nih.gov/40494327/)); adopted as a primary outcome in the Thorax and Respiration RCTs |
| **Diagnostic completeness (DC) / % segments inspected** | Number of the 18 named segments actually visualised | Rater checklist or simulator log | Discriminated expertise ([Ost 2001](https://pubmed.ncbi.nlm.nih.gov/11751195/)); denominated **out of 18** in [Naik 2026](https://pubmed.ncbi.nlm.nih.gov/41861064/); the outcome that responded to anatomical variety ([Deng 2026](https://pubmed.ncbi.nlm.nih.gov/41207791/)) |
| **Average intersegmental time (AIT)** | Navigation fluency independent of total case length | Derived from segment-entry timestamps ([Cold 2020](https://pubmed.ncbi.nlm.nih.gov/33282381/)) | Inversely correlated with SP (r=−0.52); used in [Naik 2026](https://pubmed.ncbi.nlm.nih.gov/41861064/) |
| **Airway wall collisions / wall hits** | Atraumatic technique | Simulator event counter | Discriminated experts ([Ost 2001](https://pubmed.ncbi.nlm.nih.gov/11751195/)); novices improved by attempt 6 and the difference from experts disappeared by attempt 5 ([Moorthy 2003](https://pubmed.ncbi.nlm.nih.gov/12740517/)); discriminative in BRONCH Mentor task 1 (p=0.014) ([Pastis 2014](https://pubmed.ncbi.nlm.nih.gov/25321450/)) |
| **Economy of movement / economy of performance** | Path efficiency | Simulator-derived (path length or instrument-travel ratio) | **The only bronchoscopy-specific "economy" metric with construct validity** — discriminated novices from experts and improved by attempt 6 ([Moorthy 2003](https://pubmed.ncbi.nlm.nih.gov/12740517/)). Beyond that, path-length validity evidence is laparoscopic, not bronchoscopic. |
| **"Time in red-out"** | Seconds with the airway wall filling the view (mucosal contact / lost lumen) | Simulator | Discriminated expertise ([Ost 2001](https://pubmed.ncbi.nlm.nih.gov/11751195/)) |
| **BSTAT** | Task-based checklist of bronchoscopic skill. Scored **0–24** (or 0–10 in the short classroom form) | [Davoudi 2008](https://pubmed.ncbi.nlm.nih.gov/18408359/); used as the outcome in [Wahidi 2010](https://pubmed.ncbi.nlm.nih.gov/19858234/) and (modified) in [Siow 2021](https://pubmed.ncbi.nlm.nih.gov/33876525/) and [Gerretsen 2023](https://pubmed.ncbi.nlm.nih.gov/37178972/) | ICC 0.98 inter-rater, 0.86 test–retest, known-groups p<0.001 |
| **BSET** (Bronchoscopy Step-by-Step Evaluation Tool) | Stepwise inspection *technique* — the "did you look properly" counterpart to BSTAT's task completion | [Davoudi 2008](https://pubmed.ncbi.nlm.nih.gov/18408359/) | ICC 0.98 inter-rater, 0.85 test–retest, concurrent validity vs experience |
| **EBUS-STAT** | 0–100. Items: atraumatic airway introduction and navigation, ultrasound image acquisition/optimisation, identification of mediastinal nodal and vascular structures, EBUS-TBNA sampling, recognition of EBUS/CT images | [Davoudi 2012](https://pubmed.ncbi.nlm.nih.gov/22837376/) | r=0.9991 inter-tester; groups 31.1 / 74.9 / 93.6 (p<0.0001, non-overlapping); self-assessment r²=0.81. Subscore analysis: pre-training score **<79** predicts benefit ([Scarlata 2017](https://pubmed.ncbi.nlm.nih.gov/28323724/)) |
| **EBUSAT** | EBUS-TBNA performance on real patients, video-scored | [Konge 2015](https://pubmed.ncbi.nlm.nih.gov/26160875/) | α=0.95; G=0.86; pass/fail **28.9** by contrasting groups |
| **Global Rating Scale (GRS)** | Holistic technique rating | Used as a co-primary outcome in [O'Grady 2026](https://pubmed.ncbi.nlm.nih.gov/42980987/) | **Weak discrimination** in that study (similar scores for oral bronchoscopy) — treat as secondary |
| **DOPS** | Workplace-based direct observation | — | **No bronchoscopy-specific validity study located.** DOPS is used generically; no published bronchoscopy validity evidence found. Do not cite it as validated for bronchoscopy. |
| **NASA-TLX** | Cognitive workload | Used in [Su 2025](https://pubmed.ncbi.nlm.nih.gov/40494327/) and [Naik 2026](https://pubmed.ncbi.nlm.nih.gov/41861064/) | Sensitive to input modality (VR lower mental demand, higher physical demand); a *process* measure, not a competence measure |
| **Complication rate** | Patient safety | [Ouellette 2006](https://pubmed.ncbi.nlm.nih.gov/17035454/): 3,538 supervised training bronchoscopies, **2.06%** complications; first-trimester fellows **3.1%** vs 1.57% later (p<0.05). [Stather 2013](https://pubmed.ncbi.nlm.nih.gov/23485608/): 967 procedures, **4.5% with a trainee vs 1.2% without** (p=0.048); procedure 50.8 vs 32.5 min | Real, but **cannot be measured in a simulator** — only as a downstream consequence. No simulator study has shown a reduction. |

**What this means for scoring.** The four-metric core (DC, SP, PT, AIT) plus wall-contact count is
defensible today and maps directly onto published instruments. Complication-rate change is the outcome
that would actually matter clinically and is the one nobody has shown.

---

## 4. Instructional design evidence

### 4.1 Which features actually have effect sizes

Cook 2013 pooled 289 studies / 18,971 trainees ([PMID 22938677](https://pubmed.ncbi.nlm.nih.gov/22938677/)):

| Feature | Pooled ES (skills) | Studies | p |
|---|---|---|---|
| Range of difficulty | **0.68** | 20 | <0.001 |
| Repetitive practice | **0.68** | 7 | 0.06 |
| Distributed (spaced) practice | **0.66** | 6 | 0.03 |
| Interactivity | 0.65 | 89 | <0.001 |
| Multiple learning strategies | 0.62 | 70 | <0.001 |
| Individualised learning | 0.52 | 59 | <0.001 |
| Mastery learning | 0.45 | 3 | 0.57 (ns) |
| Feedback | 0.44 | 80 | <0.001 |
| Longer time | 0.34 | 23 | 0.005 |
| Clinical variation | 0.20 | 16 | 0.24 (ns) |
| Group training | −0.22 | 8 | 0.09 |

Issenberg's BEME review of 109 studies ranks **feedback** first (47% of articles), repetitive practice
second (39%), curriculum integration third (25%), range of difficulty fourth (14%)
([PMID 16147767](https://pubmed.ncbi.nlm.nih.gov/16147767/)).

### 4.2 Mastery learning and score thresholds

- Mastery SBME beats no intervention (skills ES 1.29) and beats non-mastery simulation (ES 1.17) but
  **costs more time** ([Cook 2013](https://pubmed.ncbi.nlm.nih.gov/23807104/)). The 0.45 point estimate
  in the instructional-design review rests on only 3 studies and is not significant — the feature is
  plausible but thinly evidenced.
- **Published pass/fail standards in this field:** EBUSAT **28.9** points (contrasting groups)
  ([Konge 2015](https://pubmed.ncbi.nlm.nih.gov/26160875/)); ORSIM flexible-optical-intubation test
  **34.4%**, yielding 2 false positives and 1 false negative among 30 participants
  ([Sun 2026](https://pubmed.ncbi.nlm.nih.gov/41963810/)); pre-training EBUS-STAT **<79** as a
  "will benefit from simulation" cut-off ([Scarlata 2017](https://pubmed.ncbi.nlm.nih.gov/28323724/)).
- **Competency frameworks are moving from volume to criteria.** The CHEST expert panel explicitly
  recommends societies abandon volume-based certification for skill-acquisition and knowledge-based
  competency assessment, with simulation as one component
  ([Ernst 2015](https://pubmed.ncbi.nlm.nih.gov/25674901/)). Poland made simulation a mandatory
  component of postgraduate pulmonary training in 2024 ([Pirozynski 2026](https://pubmed.ncbi.nlm.nih.gov/42260687/)).

### 4.3 How many repetitions to competence — for bronchoscopy specifically

**There is no defensible single number, and the field has moved away from counts.**

- Ost 2001 found measurable improvement after **20 simulated cases**, which was enough to change
  first-real-patient performance ([PMID 11751195](https://pubmed.ncbi.nlm.nih.gov/11751195/)).
- Wahidi 2010 used the then-standard **50th bronchoscopy** as the competency milestone and found
  *significant variation between fellows at that point* — volume did not predict skill
  ([PMID 19858234](https://pubmed.ncbi.nlm.nih.gov/19858234/)).
- Siow 2021 found competency was *not* driven by volume: the simulation group performed **fewer**
  patient procedures yet scored better ([PMID 33876525](https://pubmed.ncbi.nlm.nih.gov/33876525/)).
- Training-dose anchors in recent RCTs: **12 practice sessions** ([Su 2025](https://pubmed.ncbi.nlm.nih.gov/40494327/)),
  **up to 2 hours to reach mastery criteria** ([Naik 2026](https://pubmed.ncbi.nlm.nih.gov/41861064/)),
  **2 hours supervised** ([O'Grady 2026](https://pubmed.ncbi.nlm.nih.gov/42980987/)),
  **60 simulated cases across three groups** ([Deng 2026](https://pubmed.ncbi.nlm.nih.gov/41207791/) — 20 per group).
- Kennedy 2013's inductive conclusion: "longer or more structured training is more effective"
  ([PMID 23370487](https://pubmed.ncbi.nlm.nih.gov/23370487/)).

**Design consequence:** gate on a *criterion* (e.g. DC ≥ 17/18, SP ≥ 16 correct progressions, zero
unrecovered wall jams, PT below a norm-referenced ceiling), not on a repetition count, and set the
threshold by contrasting-groups standard setting once local novice/expert data exist.

### 4.4 Feedback, spacing, and social learning

- **Human feedback beats automated in-simulator guidance.** The single most actionable trial for this
  project: VR arrow/highlight guidance produced SP 15.0 ± 5.3, statistically indistinguishable from
  **no feedback at all** (p=1.00), while a tutor produced 18 ± 0 ([Su 2025](https://pubmed.ncbi.nlm.nih.gov/40494327/)).
  This echoes an earlier student study in which tutor-guided short training beat simulator-guided
  training ([Schertel 2021](https://pubmed.ncbi.nlm.nih.gov/33618680/)).
- **Spacing:** distributed practice has a pooled ES of 0.66, and spacing across consecutive days
  appeared better than shorter or longer intervals in a 7-study VR review
  ([Fahl 2023](https://pubmed.ncbi.nlm.nih.gov/36907871/)). But the only bronchoscopy-specific spacing
  RCT found **no difference** between one-day and weekly schedules (n=20)
  ([Bjerrum 2016](https://pubmed.ncbi.nlm.nih.gov/27172423/)). Don't over-claim a schedule.
- **Dyad practice:** two trainees sharing one simulator learned as much as individuals at the same
  instructor cost (n=36) ([Bjerrum 2014](https://pubmed.ncbi.nlm.nih.gov/24909532/)) — directly relevant
  to a free, hardware-limited trainer.
- **Modelling examples** improve complex procedural skill acquisition in bronchoscopy simulation
  ([Bjerrum 2013](https://pubmed.ncbi.nlm.nih.gov/23931538/)) — an argument for recorded expert runs
  inside the trainer.
- **Baseline ability confounds training outcomes:** in novices, bronchoscopic observation time
  correlated with video-game completion time (r=0.453, p=0.030) and gamers were much faster than
  non-gamers (median 200 s vs 281 s, p=0.005); no such correlation in experienced bronchoscopists
  ([Shimoda 2024](https://pubmed.ncbi.nlm.nih.gov/38280910/)). Any novice study must record prior
  gaming/dexterity.

---

## 5. Named simulators studied in the literature

| Platform | Type | Published evidence |
|---|---|---|
| **Immersion Medical "PreOp Flexible Bronchoscopic Simulator"** (later CAE Healthcare) | Screen-based VR with instrumented scope | RCT: 1 hour of training improved systematic examination and reduced cueing in PGY-1 surgical residents ([Blum 2004](https://pubmed.ncbi.nlm.nih.gov/15223446/)) |
| **HT Medical Systems** bronchoscopy simulator | Screen-based VR, instrumented scope | Established face, construct and content validity; % segments, wall collisions and "economy of performance" discriminated novices from experts ([Moorthy 2003](https://pubmed.ncbi.nlm.nih.gov/12740517/)) |
| **Immersion Medical / AccuTouch-class platform** (device not named in the abstract) | Screen-based VR | Multicentre validation + RCT in new fellows ([Ost 2001](https://pubmed.ncbi.nlm.nih.gov/11751195/)) |
| **CAE AccuTouch EndoscopyVR** | Screen-based VR | Cited across reviews of the field as one of the established platforms ([Gerretsen 2023](https://pubmed.ncbi.nlm.nih.gov/37178972/); [McCarthy 2026](https://pubmed.ncbi.nlm.nih.gov/41826217/)) — but I located **no dedicated bronchoscopy validity or transfer trial naming this device**. Treat the "AccuTouch" branding in reviews as generic lineage, not as device-specific evidence. |
| **Simbionix BRONCH Mentor** (now SurgicalScience, Sweden) | Screen-based VR, real scope handle; "Essential Bronchoscopy" module with lung-anatomy/segments task | **Construct validity**: n=20 across 3 experience levels, 4 tasks — scope manipulation and airway anatomy discriminated; **guided anatomic navigation and lymph-node anatomy did not** ([Pastis 2014](https://pubmed.ncbi.nlm.nih.gov/25321450/)). In routine use in the Maastricht/Netherlands ICU programme ([Gerretsen 2025](https://pubmed.ncbi.nlm.nih.gov/40615353/)) and in EBUS fellowship evaluation ([Cureus 2024](https://pubmed.ncbi.nlm.nih.gov/39559658/)). |
| **Surgical Science EndoSim** | Screen-based VR | Used as the training platform in the tutor-vs-VR-feedback RCT ([Su 2025](https://pubmed.ncbi.nlm.nih.gov/40494327/)) |
| **ORSIM** (portable VR, airway/intubation focus) | Screen-based portable VR | Best-validated airway simulator in McCarthy's review (with SimMan) ([McCarthy 2026](https://pubmed.ncbi.nlm.nih.gov/41826217/)); 12-case FOI test with all five Messick sources and a 34.4% pass standard ([Sun 2026](https://pubmed.ncbi.nlm.nih.gov/41963810/)); 2-hour training pilot ([O'Grady 2026](https://pubmed.ncbi.nlm.nih.gov/42980987/)) |
| **Koken "BronchoBoy"** and similar physical airway models | Physical part-task | Used as the **test** phantoms (not the intervention) in [Naik 2026](https://pubmed.ncbi.nlm.nih.gov/41861064/); all Danish simulation centres use physical phantoms for assessment ([Cold 2023](https://pubmed.ncbi.nlm.nih.gov/37427954/)) |
| **Kyoto Kagaku** | Physical anatomical models | **No bronchoscopy-specific validity or training study located.** Their airway models appear in anaesthesia/airway-management research, not in bronchoscopy simulation outcome studies. Do not cite Kyoto Kagaku as an evidence-backed bronchoscopy simulator. |
| **CT-derived 3D-printed airways** | Physical part-task | Low-cost, high-anatomical-fidelity trainer built from a patient CT with free software; rated realistic and useful by experienced bronchoscopists ([Byrne 2016](https://pubmed.ncbi.nlm.nih.gov/27070341/)); used to add fluid aspiration to a VR curriculum ([Gerretsen 2025](https://pubmed.ncbi.nlm.nih.gov/40615353/)) |
| **Custom digital-twin simulators** | CT-derived VR | Anatomical variety improved transfer to a new anatomy and 3-month retention ([Deng 2026](https://pubmed.ncbi.nlm.nih.gov/41207791/)) |

**Cost and access note.** None of the commercial platforms is open, Linux-native, or HMD-based. That is
precisely the gap this project fills — but it also means **the project inherits no device-specific
validity evidence** and must generate its own.

---

## 6. Realism requirements

### 6.1 Nomenclature: use Collins/Jackson–Huber–Boyden, and get the left side right

The 1987 international nomenclature (Collins et al.), still in use, is the reference standard and is
reproduced in a 204-case anatomical dissection study ([Akdeniz 2021](https://pubmed.ncbi.nlm.nih.gov/33871335/),
[PMC8051302](https://pmc.ncbi.nlm.nih.gov/articles/PMC8051302/)):

| No. | Right lung (10 segments) | Left lung (8 segments) |
|---|---|---|
| 1 | b1 apical (upper lobe) | **b1+2 apicoposterior** — a single fused segment |
| 2 | b2 posterior | *no separate segment* — fused into b1+2 |
| 3 | b3 anterior | b3 anterior |
| 4 | b4 lateral (middle lobe) | b4 superior lingular |
| 5 | b5 medial (middle lobe) | b5 inferior lingular |
| 6 | b6 apical basal (lower lobe) | b6 apical basal (lower lobe) |
| 7 | b7 medial basal | **b7+8 anteromedial basal** — a single fused segment |
| 8 | b8 anterior basal | *no separate segment* — fused into b7+8 |
| 9 | b9 lateral basal | b9 lateral basal |
| 10 | b10 posterior basal | b10 posterior basal |

**10 + 8 = 18 named segments.** This is not pedantry: it is why diagnostic completeness is scored
"out of 18" ([Naik 2026](https://pubmed.ncbi.nlm.nih.gov/41861064/)) and it means a graph that models
left b1 and b2 (or left b7 and b8) as separate nodes is **anatomically wrong** and will mis-teach the
single most examinable point of left-sided anatomy. The lingula is b4/b5, not a separate lobe.

Note also that nomenclature has layers: Jackson & Huber (1943) first classified the tree, Boyden (1945)
described intrahilar and segmental anatomy, Ikeda (1974) added distal generation designations for
bronchoscopy, and Collins (1987) produced the current international table
([Akdeniz 2021](https://pubmed.ncbi.nlm.nih.gov/33871335/)). Cite Boyden for segmental anatomy, Collins
for the numbering actually used in reports.

### 6.2 Variant anatomy is the norm, not the exception

From 204 adult dissections ([Akdeniz 2021](https://pubmed.ncbi.nlm.nih.gov/33871335/)):

- Anatomical variation present in **200/204 (98%)**.
- Right upper lobe: total variation **56.8%**; trifurcation b1+b2+b3 **16.6%**; (b1+b2)+b3 **10.8%**;
  b1+(b2+b3) **16.2%**; quadrivial pattern **3.9%**.
- Middle lobe with three segments **14.2%**.
- Left upper lobe trifurcate division **15.1%**; three segments in the lingula **16.2%**.
- b6 with two subsegments **39.7%** (right and left); left lower lobe mediobasal segment present **14.2%**.
- Tracheal bronchus is a recognised hazard in anaesthesia and is reported as a cause of tube
  misplacement ([case report, PMID 38221699](https://pubmed.ncbi.nlm.nih.gov/38221699/)).

**Design consequence:** shipping one canonical tree contradicts the anatomy literature *and* the only
RCT that tested anatomical variety directly ([Deng 2026](https://pubmed.ncbi.nlm.nih.gov/41207791/)).
Minimum viable realism is 3–5 distinct trees, at least one containing a right-upper-lobe bifurcation
variant and one with a three-segment lingula.

### 6.3 Insertion depths (cm from the incisors) — an honest gap

**I could not locate a peer-reviewed normative table of bronchoscopic insertion depth in centimetres
from the incisors for each lobar and segmental orifice.** Textbook figures circulate (carina commonly
quoted at roughly 24–26 cm in adults), but I found no primary dataset I am willing to cite for that.
What *is* published:

- **Tracheal length** by HRCT in 503 normal adults: **109.5 ± 8.9 mm (male)** vs **100.5 ± 7.4 mm
  (female)**, p<0.001; distal tracheal area 311.3 ± 111.1 vs 227.6 ± 92.9 mm²
  ([Adhikari 2025](https://pubmed.ncbi.nlm.nih.gov/41034943/), [PMC12487123](https://pmc.ncbi.nlm.nih.gov/articles/PMC12487123/)).
- **The right main bronchus is short**: <23 mm in **49.5%** of adults — the anatomical reason
  right-sided double-lumen tubes and blockers misplace, and the reason the simulator should make the
  right main bronchus a genuinely short, easily overshot segment.
- **54.5% had a more vertical left main bronchus than classical teaching describes** — a direct warning
  against hard-coding "textbook" angles.
- Bronchoscopic **distance measurement has no reliable simple instrument**; a 2025 device (the LJ
  system) was validated in vitro against a digital caliper and then in only **10 patients**
  ([Sestakova 2025](https://pubmed.ncbi.nlm.nih.gov/40310363/)). The clinical need for measuring
  distance from the vocal cords and stenosis length is real, and the tooling is immature.

**Recommendation:** derive geometry from CT/anatomical specimens, display depth *relative to your own
model* and label it as such; calibrate against a phantom (e.g. a 3D-printed tree of known dimensions)
before showing any centimetre readout to trainees. Do not present hard-coded "cm from incisors" as
factual.

**Other dimensions worth modelling:** adult diagnostic scope OD 4.9–5.9 mm, working length ~60 cm,
working channel 1.2–2.8 mm (already in `docs/04-scope-model.md`); deflection ~180° up / 130° down on
therapeutic scopes. These are consistent with the project's existing scope model.

### 6.4 Case mix and procedural reality

- **Indications (worldwide survey, 879 respondents, 64 countries):** suspicion of cancer **78.6%**,
  suspected non-TB infection **10.6%**, suspected TB **6.7%**
  ([Quadrelli 2025](https://pubmed.ncbi.nlm.nih.gov/40788098/)). Only **11%** perform routine
  bronchoscopy without anaesthesia; only **39.3%** had ≥6 months of formal training.
- **ICU practice (266 respondents, 73 countries):** **41% report no formal training**; only 61% have
  24/7 bronchoscopy access; BAL is the commonest sampling method with a median **60–120 mL** of saline
  and a recovery of **48 ± 18%**; microbiological findings changed therapy in 48 ± 21% of cases
  ([Fisser 2026](https://pubmed.ncbi.nlm.nih.gov/41953760/)).
- **EBUS:** systematic staging is recommended over targeted staging; combined EBUS-TBNA + EUS(-B)-FNA
  preferred over EBUS alone; **competence should be acquired in a simulation-based environment and
  assured using valid assessment methods**; 21G/22G needles are standard
  ([ERS/ESGE/ESTS 2026](https://pubmed.ncbi.nlm.nih.gov/42167778/)). Station naming follows the IASLC
  lymph node map ([radiologic atlas and review, PMID 26175770](https://pubmed.ncbi.nlm.nih.gov/26175770/)).

### 6.5 Sedation and awake considerations

- Practice is heterogeneous: WABIP shows only 11% do routine bronchoscopy without anaesthesia;
  FLEXICARE documents widely varying sedation and ventilation strategies across ICUs.
- When a trainee participates, sedation requirements rise: midazolam 6.34 vs 5.73 mg (p=0.01) and
  propofol 153.1 vs 111.6 mg (p=0.001), with procedures 50.8 vs 32.5 min
  ([Stather 2013](https://pubmed.ncbi.nlm.nih.gov/23485608/)).
- The BTS guideline for diagnostic flexible bronchoscopy in adults remains the reference standard for
  sedation, topical anaesthesia, monitoring and safety ([Du Rand 2013](https://pubmed.ncbi.nlm.nih.gov/23860341/)).
- **Airway anaesthesia is itself a scored competency** — Siow 2021 used a dedicated airway-anaesthesia
  score, and simulator training correlated with it at r=0.83
  ([PMID 33876525](https://pubmed.ncbi.nlm.nih.gov/33876525/)). A trainer that omits topicalisation
  omits a scored step.

### 6.6 Safety-critical behaviours to encode

Derived from the complication data and the assessment instruments:

1. **Atraumatic introduction and navigation** — scored item in EBUS-STAT; wall-collision metrics are
   validated discriminators. First-trimester trainees have the highest complication rate
   ([Ouellette 2006](https://pubmed.ncbi.nlm.nih.gov/17035454/)) — that is the window the trainer targets.
2. **Maintaining the lumen / avoiding red-out** — "time in red-out" discriminated expertise
   ([Ost 2001](https://pubmed.ncbi.nlm.nih.gov/11751195/)); red-out is the visual signature of
   mucosal trauma.
3. **Never advancing against resistance without visual confirmation** — the mechanism behind most
   perforations and pneumothoraces; the project's own wall-slide model must *penalise* blind pushing
   rather than silently smoothing it (see the "wall_slide_bias" trade-off in `docs/04-scope-model.md`).
4. **Recognising and controlling bleeding** before it obscures the field; escalation (wedge the scope,
   cold saline, vasoconstrictor, balloon tamponade, rigid scope/thoracic surgery) is the actual skill.
5. **Oxygenation monitoring** — desaturation is the commonest intraprocedural adverse event; the
   simulator should model SpO₂ falling with suction time and occlusion, not as a scripted timer.
6. **Topical anaesthetic dose tracking** — a real cause of toxicity; if scored, needs its own counter.
7. **Suction discipline** — prolonged suction causes atelectasis and hypoxia; BAL volume/recovery should
   be tracked (§6.4).
8. **Team communication / call for help** — no validated bronchoscopy instrument exists; borrow from
   crisis-resource-management frameworks and label as unvalidated.

---

## 7. 3D fidelity, haptics, and cybersickness

### 7.1 CT-derived versus artist-built anatomy

- **Evidence favours CT-derived variety.** Training across multiple patient-derived bronchial trees beat
  training on a single standardised tree when novices were tested on a *new* CT-derived anatomy
  (DC +2.5 segments, SP +9 progressions, both p<0.001), with partially maintained gains at 3 months
  (n=60) ([Deng 2026](https://pubmed.ncbi.nlm.nih.gov/41207791/)).
- CT-derived 3D-printed models are perceived as realistic by experienced bronchoscopists, at low cost
  ([Byrne 2016](https://pubmed.ncbi.nlm.nih.gov/27070341/)).
- **But anatomical fidelity does not automatically buy measurement validity.** On the BRONCH Mentor,
  the explicit lymph-node anatomy task did **not** discriminate experience levels, nor did guided
  anatomic navigation ([Pastis 2014](https://pubmed.ncbi.nlm.nih.gov/25321450/)). Fidelity to
  *appearance* is not the same as fidelity to *the task* — the argument Hamstra et al. make for
  replacing "fidelity" with **physical resemblance** and **functional task alignment**
  ([PMID 24448038](https://pubmed.ncbi.nlm.nih.gov/24448038/)).
- Surface realism (mucosal texture, vascularity, secretions): **no study located shows it affecting
  bronchoscopy learning outcomes.** Do not spend the budget there before the metrics work.

### 7.2 Are haptics necessary?

- The most complete review (87 articles) found **variable** added value: haptics matters most for
  complex tasks, the interface does **not** need the highest fidelity, and haptic feedback is associated
  with a shorter, steadier learning curve; for novices the improvements are minor
  ([Overtoom 2019](https://pubmed.ncbi.nlm.nih.gov/30082239/)).
- In a direct comparison, expert laparoscopists performed better *with* haptics on selected tasks
  (accuracy, economy of movement, avoidance of over-stretch) but the study "does not demonstrate an
  advantage in skills acquisition" ([Siu 2023](https://pubmed.ncbi.nlm.nih.gov/37563347/)).
- In bronchoscopy specifically, learners and instructors **preferred low-fidelity** over a high-fidelity
  VR platform for TBNA training ([Davoudi 2010](https://pubmed.ncbi.nlm.nih.gov/20616534/)).
- Wall-contact events, however, are a **validated discriminator** without any force feedback at all —
  a distance-based collision proxy was enough for Ost 2001, Moorthy 2003 and Pastis 2014.

**Conclusion for v1: force feedback is not required.** What is required is (a) honest contact
detection and counting, (b) resistance/wedging behaviour that punishes blind pushing, and (c) a rigid,
scope-shaped physical controller so that lever and torque proprioception resemble the real instrument.
That last point is the one place where "haptics" genuinely matters and it is cheap.

### 7.3 Cybersickness

- Pooled meta-analysis of 55 studies / 3,016 participants using head-mounted displays: mean total
  Simulator Sickness Questionnaire score **28.00 (95% CI 24.66–31.35)** — high relative to recommended
  cut-offs; gaming content was worst at **34.26 (29.57–38.95)**; profiles were influenced by visual
  stimulation, locomotion and exposure time; older samples scored lower; **no sex difference**
  ([Saredakis 2020](https://pubmed.ncbi.nlm.nih.gov/32300295/), [PMC7145389](https://pmc.ncbi.nlm.nih.gov/articles/PMC7145389/)).
- In a clinical-education VR study (n=91), sickness was **low** (mean SSQ 4.59/48 for a high-movement
  opioid-overdose simulation vs 3.10/48 for a low-movement suicide-risk simulation), with nausea
  significantly higher in the high-movement scenario (p=0.0275) and no oculomotor difference
  ([Ng 2025](https://pubmed.ncbi.nlm.nih.gov/40468438/)).
- **No bronchoscopy-specific cybersickness data were located.** This is a genuine gap: bronchoscopy
  simulation combines continuous forward translation, rotational optic flow, close-up surfaces and
  frequent near-field object motion — a profile closer to the "gaming" category than to static ward
  training.

**Design consequences:** keep default sessions short (10–15 min) with a natural break at case end;
offer teleport/snap-style reorientation between segments rather than smooth camera snaps; avoid
accelerating the camera when the scope advances; make the horizon stable (the airway is a tube, so
provide a visible lumen reference); instrument SSQ before/after in any pilot; allow seated play with a
standing option.

---

## 8. Transfer of simulator skill to real bronchoscopy and to the operating room

| Study | Design | Transfer finding |
|---|---|---|
| [Ost 2001](https://pubmed.ncbi.nlm.nih.gov/11751195/) | RCT, new fellows, first real bronchoscopies | Simulator group faster (815 vs 1,168 s, p=0.001), higher nurse quality rating (7.7 vs 3.7, p=0.05), higher quality score (0.119 vs 0.046, p=0.03). Very small (3 vs 3 fellows). |
| [Blum 2004](https://pubmed.ncbi.nlm.nih.gov/15223446/) | RCT, PGY-1 surgical residents, intraoperative bronchoscopy via LMA | Fewer verbal cues (3.2 vs 6.2) and physical cues (0.2 vs 1.6); better systematic examination (4.4 vs 2.6/5). n=5 per arm. Procedure time unchanged (evaluator-paced). |
| [Konge 2015](https://pubmed.ncbi.nlm.nih.gov/26160875/) | RCT, EBUS on 3 real patients each | 24.2 vs 20.2 EBUSAT points (p=0.006) in favour of simulation; **but most procedures in both arms failed the standard**. |
| [Wahidi 2010](https://pubmed.ncbi.nlm.nih.gov/19858234/) | Prospective multicentre, 2 cohorts, n=44 | Simulation accelerated BSTAT acquisition at 7/8 milestones. |
| [Siow 2021](https://pubmed.ncbi.nlm.nih.gov/33876525/) | Non-randomised 2-group, n=18, video-scored real procedures | Simulator curriculum better on modified BSTAT (r=0.80) with fewer patient procedures. |
| [Krogh 2013](https://pubmed.ncbi.nlm.nih.gov/22823900/) | RCT, n=20 medical students | Training on a **new, portable, simple** simulator transferred to performance of complex bronchoscopy procedures. |
| [Kennedy 2013](https://pubmed.ncbi.nlm.nih.gov/23370487/) | Meta-analysis | vs clinical instruction on patients: **no significant benefit** (2 studies per outcome). |
| [Brydges 2015](https://pubmed.ncbi.nlm.nih.gov/25374041/) | Meta-analysis, 33 studies | Simulator scores correlate r=0.51 with workplace behaviours but only **r=0.24 with patient outcomes** (CI −0.02 to 0.47). |
| [Cook 2011](https://pubmed.ncbi.nlm.nih.gov/21900138/) | Meta-analysis, 609 studies | Pooled ES for direct effects on patients **0.50** (0.34–0.66) — moderate, not large. |

**To the operating room specifically:** no bronchoscopy study measures OR performance or patient
outcomes as a function of simulator training. The closest proxies are the EBUS-on-patient studies
above and the meta-analytic correlations. Anyone claiming "VR bronchoscopy training improves patient
outcomes" is extrapolating.

**The counter-argument the project must answer:** in the apprenticeship model, trainees cause
measurable harm — complication rate 4.5% with a trainee vs 1.2% without, and first-trimester fellows
have the highest rate (3.1%). Even if simulation only moves the steep part of the learning curve off
patients, the expected benefit is real. That is the strongest defensible claim, and it is an argument
from mechanism plus complication epidemiology, not from an outcome trial.

---

## 9. Master table of key studies

| Study | Design | n | Outcome measure(s) | Result |
|---|---|---|---|---|
| Colt 2001, *Chest* ([PMID](https://pubmed.ncbi.nlm.nih.gov/11591579/)) | Prospective pre-post + comparison group | 5 novices vs 4 experienced | Dexterity, accuracy, segments missed, wall contacts, time | Novices improved and matched/exceeded experienced peers; missed fewer segments, fewer wall contacts; **no** improvement in speed or non-visualising time |
| Ost 2001, *AJRCCM* ([PMID](https://pubmed.ncbi.nlm.nih.gov/11751195/)) | Multicentre validation + RCT | 28 (9/8/11) + fellows | Time, % segments, red-out, collisions; then real-patient quality | Experts > intermediates > novices; 20 simulations improved all four metrics; RCT: 815 vs 1,168 s (p=0.001); nurse score 7.7 vs 3.7 (p=0.05); quality 0.119 vs 0.046 (p=0.03) |
| Moorthy 2003, *Respiration* ([PMID](https://pubmed.ncbi.nlm.nih.gov/12740517/)) | Comparative | 18 (9 novices / 9 experienced) | % segments, wall collisions, economy of performance | All three discriminated. Within novices: segments improved by attempt 3, economy and collisions by attempt 6. Difference from experts disappeared by attempt 3 for % segments and economy, by attempt 5 for collisions |
| Blum 2004, *Ann Thorac Surg* ([PMID](https://pubmed.ncbi.nlm.nih.gov/15223446/)) | RCT | 10 (+3 experienced) | Cue counts, systematic-exam rating, time | Cues 3.2 vs 6.2 verbal, 0.2 vs 1.6 physical; exam 4.4 vs 2.6/5; time unchanged |
| Davoudi 2008, *Respiration* ([PMID](https://pubmed.ncbi.nlm.nih.gov/18408359/)) | Validation | 22 (7/8/7) | BSTAT, BSET | ICC 0.98 inter-rater (both); test–retest 0.86 / 0.85; known-groups p<0.001 |
| Davoudi 2010, *Respiration* ([PMID](https://pubmed.ncbi.nlm.nih.gov/20616534/)) | Randomised crossover survey | Conference attendees + instructors | Preference ratings | Low-fidelity preferred over high-fidelity for realism (23 vs 17), ease (20 vs 6) and overall (19 vs 11); instructors 8–0 |
| Wahidi 2010, *Chest* ([PMID](https://pubmed.ncbi.nlm.nih.gov/19858234/)) | Prospective multicentre, 2 cohorts | 44 fellows | BSTAT 0–24 + MCQ at milestones to 50th bronchoscopy | Wide variation at 50th; simulation cohort improved at 7/8 milestones (p<0.05); online curriculum non-contributory (low compliance) |
| Davoudi 2012, *AJRCCM* ([PMID](https://pubmed.ncbi.nlm.nih.gov/22837376/)) | Validation, 3 institutions | 24 (8/8/8) | EBUS-STAT (0–100) | Inter-tester r=0.9991; 31.1 / 74.9 / 93.6, non-overlapping; self-assessment r²=0.81 |
| Bjerrum 2013, *Med Educ* ([PMID](https://pubmed.ncbi.nlm.nih.gov/23931538/)) | RCT | — | Bronchoscopy simulation performance | Modelling examples improve complex procedural skill acquisition |
| Bjerrum 2014, *Med Educ* ([PMID](https://pubmed.ncbi.nlm.nih.gov/24909532/)) | RCT | 36 students | Validated simulator measures, 3-week retention | No difference dyad vs individual; dyad as effective at half the simulator time — more efficient |
| Pastis 2014, *J Bronchol* ([PMID](https://pubmed.ncbi.nlm.nih.gov/25321450/)) | Cohort, 2 centres | 20 (7/6/7) | BRONCH Mentor 4 tasks | Tasks 1 (manipulation: score, time, mid-lumen time, wall hits) and 3 (anatomy: time, segments identified/incorrect/skipped) discriminated; **tasks 2 and 4 did not** |
| Konge 2015, *ERJ* ([PMID](https://pubmed.ncbi.nlm.nih.gov/26160875/)) | RCT | 16 physicians × 3 patients | EBUSAT on real patients | 24.2 ± 7.9 vs 20.2 ± 9.4 (p=0.006); α=0.95, G=0.86; pass 28.9; 67% vs 83% failed |
| Bjerrum 2016, *Med Educ Online* ([PMID](https://pubmed.ncbi.nlm.nih.gov/27172423/)) | RCT | 20 physicians | Validated simulator measures + 4-week retention | No difference between one-day and weekly distributed schedules |
| Scarlata 2017, *J Bronchol* ([PMID](https://pubmed.ncbi.nlm.nih.gov/28323724/)) | Pre-post, VR only | 15 experienced bronchoscopists | EBUS-STAT | Significant improvement after a 7-hour course; pre-score <79 predicts benefit |
| Veaudor 2018, *BMC Med Educ* ([PMID](https://pubmed.ncbi.nlm.nih.gov/30086734/)) | Prospective cohort | 34 (8 novice / 17 moderate / 9 high) | Time, visualisation/identification score | Novices 561 → 216 s (p=0.002); overall score 5.9% → 25.5% (p=0.002), comparable to experienced (25.3%, 22.2%) |
| Cold 2020, *J Thorac Dis* ([PMID](https://pubmed.ncbi.nlm.nih.gov/33282381/)) | Prospective comparative | 33 (12/11/10) | DC, SP, AIT | SP correlated with DC (r=0.62) and AIT (r=−0.52), both p<0.001 |
| Siow 2021, *Respirology* ([PMID](https://pubmed.ncbi.nlm.nih.gov/33876525/)) | Non-randomised 2-group | 18 trainees | Modified BSTAT, MCQ, airway anaesthesia, video-scored real procedures | Simulator curriculum better despite fewer patient procedures; r=0.80 / 0.85 / 0.83 |
| Gerretsen 2023, *Chest* ([PMID](https://pubmed.ncbi.nlm.nih.gov/37178972/)) | Systematic review | 14 studies | Multiple | 11/14 positive; 8 moderate/high risk of bias; only 4 behavioural patient-level; no meta-analysis possible |
| Su 2025, *Respiration* ([PMID](https://pubmed.ncbi.nlm.nih.gov/40494327/)) | 3-arm RCT | 36 residents × 12 sessions | SP, DC, PT, NASA-TLX | Tutor SP 18 ± 0 vs VR guidance 15.0 ± 5.3 (p=0.026) and control 15.5 ± 4.5 (p=0.017); **VR guidance = control (p=1.00)** |
| Deng 2026, *Thorax* ([PMID](https://pubmed.ncbi.nlm.nih.gov/41207791/)) | 3-arm RCT | 60 novices | DC, SP, PT on 2 test anatomies + 3-month retention | Anatomic-variety group superior on test 2 (DC +2.5, SP +9, p<0.001) with partial retention |
| Naik 2026, *Respiration* ([PMID](https://pubmed.ncbi.nlm.nih.gov/41861064/)) | RCT, VR vs AR | 30 | DC/18, SP, PT, AIT, NASA-TLX | VR better DC on model 1 (p=0.0022); AR faster on its own model (−48 s, p=0.0377); VR lower mental (+15), higher physical (+35) demand |
| O'Grady 2026, *Ir J Med Sci* ([PMID](https://pubmed.ncbi.nlm.nih.gov/42980987/)) | Randomised pilot | 20 medical students | ORSIM composite + consultant GRS | 2 h better than 10-min familiarisation (68.1% vs 45.5% in macroglossia); GRS similar/modestly higher |
| Sun 2026, *BMC Anesthesiol* ([PMID](https://pubmed.ncbi.nlm.nih.gov/41963810/)) | Validation, all 5 Messick sources | 30 (15/15) | 12-case FOI test on portable VR | α=0.89; 6 cases formative / 10 summative; pass 34.4%; 2 false positives, 1 false negative |
| Ouellette 2006, *Chest* ([PMID](https://pubmed.ncbi.nlm.nih.gov/17035454/)) | Retrospective QI | 3,538 procedures | Complications | 2.06% overall; first trimester 3.1% vs 1.57% later (p<0.05) |
| Stather 2013, *Respiration* ([PMID](https://pubmed.ncbi.nlm.nih.gov/23485608/)) | Retrospective QI | 967 procedures | Time, sedation, complications | Trainee present: 50.8 vs 32.5 min; complications 4.5% vs 1.2% (p=0.048); more midazolam and propofol |

---

## 10. Where the evidence is weak, absent, or actively unhelpful

State these plainly in the project's own documentation:

1. **No bronchoscopy simulator has been shown to change patient outcomes.** Zero studies. The chain is
   simulator → validated metric → (correlation with) workplace behaviour; the last link runs at r≈0.24
   with a confidence interval crossing zero for patient outcomes.
2. **"Superior to traditional training" is unsupported for real-patient outcomes.** Kennedy's pooled
   comparison was null; Gerretsen could not pool; the positive trials are small (n=16–44) and mostly
   measure simulator or video-scored performance.
3. **Head-mounted immersive VR with hand controllers is essentially unvalidated for bronchoscopy.**
   The validated archetype is a screen + instrumented scope. Naik 2026 is one of very few HMD-adjacent
   comparisons and it is n=30.
4. **No validated metrics exist** for suctioning, BAL, bleeding control, foreign-body retrieval, or
   stenosis navigation. Any score the project invents for cases 3–6 and 8 is, by definition, unvalidated.
5. **DOPS has no bronchoscopy-specific validity evidence** that I could find; BSTAT/BSET, EBUS-STAT and
   EBUSAT do. Do not present DOPS as validated for this procedure.
6. **Normative insertion-depth data are missing** (§6.3). Textbook centimetre figures should not be
   presented as measurements.
7. **Response-process and consequences evidence is nearly absent** across the whole field (2/33 and
   1/33 studies respectively in Brydges' review).
8. **Cybersickness in bronchoscopy VR is unstudied**, and the general HMD literature reports mean SSQ
   scores well above recommended cut-offs.
9. **Many of the most relevant papers are from 2025–2026** and several are small, single-centre, or in
   lower-visibility journals. Treat effect sizes as provisional until replicated.
10. **Publication and citation slippage:** I located no dedicated bronchoscopy validity trial naming
    "CAE AccuTouch EndoscopyVR" or any bronchoscopy outcome study using Kyoto Kagaku models. Reviews
    that mention these brands are not device-level evidence.

---

## 11. Design implications

Ordered roughly by expected impact on learning outcomes per unit of engineering effort.

1. **Make the segment graph 18 nodes, Collins-named.** Right b1–b10; left b1+2, b3, b4, b5, b6,
   b7+8, b9, b10. No separate left b1/b2 or b7/b8. Score diagnostic completeness out of 18. This alone
   prevents a class of teaching errors that no amount of visual fidelity can fix.
2. **Ship DC, SP, PT and AIT as the primary metrics from day one**, plus wall-contact count and a
   red-out timer. Every one of these has published construct validity, and together they reproduce the
   Danish "four landmarks" assessment, which is the closest thing the field has to a standard.
3. **Promote structured progress to the headline navigation score.** It is more sensitive than
   diagnostic completeness to instructional differences (Su 2025), correlates with both completeness
   and speed (Cold 2020), and is cheap to compute from the existing segment-entry log.
4. **Gate progression on criteria, not counts.** Use a contrasting-groups pass/fail standard once you
   have local novice/expert data; publish the standard and its false-positive/false-negative rates, as
   Sun 2026 did. Do not require "N bronchoscopies".
5. **Keep a human in the feedback loop; do not let in-sim arrows replace the tutor.** The strongest
   negative finding in this field is that automated VR guidance performed exactly like no feedback
   (Su 2025). Build the trainer as a *debriefing instrument*: record the run, replay the path, show DC /
   SP / collisions, and let an instructor interpret it. Automated guidance, if included, must be
   opt-in at beginner level and switched off before mastery testing.
6. **Bundle 3–5 CT-derived or CT-modelled anatomies per task, including common variants.** Anatomical
   variety is the one design feature with a positive RCT ([Deng 2026](https://pubmed.ncbi.nlm.nih.gov/41207791/)),
   and the dissection data say variation is near-universal. Include a right-upper-lobe bifurcation
   variant, a three-segment lingula, and a case where the left mediobasal segment is present.
7. **Provide a scope-shaped tracked controller as the primary input; treat the Vive wand as a fallback.**
   The construct being trained is a two-DOF motor task (lever + insertion) plus torque; a 6-DoF wand on
   a floating camera removes the torque problem, which is most of the skill. This is reasoned from the
   instrument mechanics and from the fact that "scope manipulation" is a validated, discriminative
   task on physical-interface simulators — but note it is an *inference*, not an RCT result. A 3D-printed
   handle plus a Vive tracker is the cheap version.
8. **Do not build force feedback for v1; do build honest contact physics.** Haptic evidence is
   equivocal and low-fidelity models are preferred by bronchoscopy learners, whereas wall-contact
   counting is validated and free. Make blind pushing *cost* something: log it, show it in debrief,
   and make wedging actually stop the scope.
9. **Do not "help" the trainee at bifurcations by default.** The current `wall_slide_bias` assist
   (0.65) exists for playability; it also removes the failure mode that teaches atraumatic technique.
   Keep it as a beginner setting and expose expert mode with near-zero bias.
10. **Model the patient, not just the airway.** SpO₂ falling with suction time and occlusion, cough on
    stimulation, sedation depth, and topical-anaesthetic dose. Trainees' procedures run longer and use
    more sedative (Stather 2013); the first trimester of training carries the highest complication rate
    (Ouellette 2006). This is where a VR trainer beats a plastic model outright.
11. **Build the emergency cases, but label their scores unvalidated.** Bleeding, foreign body and
    critical stenosis are the highest-value scenarios and the ones with zero metric evidence. Use them
    for decision-making and escalation practice, and say so in the UI and the docs.
12. **Design for cybersickness from the start.** Short default sessions, stable horizon, no camera
    acceleration, snap reorientation between segments, seated option, and an SSQ before/after in the
    first pilot. No bronchoscopy-specific norms exist, so collect your own.
13. **Write a validity plan into the repo.** Cover all five Messick sources, not just known-groups:
    content (map every scored item to the BSTAT/BSET/four-landmarks items), response process (rater
    training and think-aloud on a sample of runs), internal structure (inter-rater ICC and a
    generalisability study — Sun 2026 suggests **6 cases for formative and 10 for summative**
    reliability), relations to other variables (novice vs expert; correlation with instructor rating on
    the same run), consequences (does mastery-gated progression predict supervisor entrustment?).
14. **Log everything, forever.** DC, SP, PT, AIT, collisions, red-out, path, tool use, suction time,
    SpO₂. The cheapest route to validity evidence is retrospective known-groups analysis on data you
    already collected — which is exactly how Ost 2001 and Pastis 2014 established their claims.
15. **Do not display absolute centimetre depths** until calibrated against a phantom; if depth is
    shown, label it as model-relative and document the calibration.
16. **Calibrate difficulty explicitly.** Range of difficulty is one of the two largest instructional-
    design effects (ES 0.68). Build a parameter (airway calibre, variant complexity, secretion load,
    stenosis severity) and expose it rather than relying on hand-authored "easy/hard" cases.

---

## Appendix: quick reference links

- Assessment instruments: BSTAT/BSET — [Davoudi 2008](https://pubmed.ncbi.nlm.nih.gov/18408359/);
  EBUS-STAT — [Davoudi 2012](https://pubmed.ncbi.nlm.nih.gov/22837376/); EBUSAT —
  [Konge 2015](https://pubmed.ncbi.nlm.nih.gov/26160875/); structured progress —
  [Cold 2020](https://pubmed.ncbi.nlm.nih.gov/33282381/).
- Procedure sequence: [four landmarks](https://pubmed.ncbi.nlm.nih.gov/37427954/),
  [six landmarks (EBUS)](https://pubmed.ncbi.nlm.nih.gov/37590526/).
- Anatomy: [Collins nomenclature + 204 dissections](https://pmc.ncbi.nlm.nih.gov/articles/PMC8051302/),
  [HRCT airway dimensions](https://pmc.ncbi.nlm.nih.gov/articles/PMC12487123/),
  [IASLC nodal map](https://pubmed.ncbi.nlm.nih.gov/26175770/).
- Guidelines: [BTS diagnostic flexible bronchoscopy](https://pubmed.ncbi.nlm.nih.gov/23860341/),
  [CHEST bronchoscopy training](https://pubmed.ncbi.nlm.nih.gov/25674901/),
  [ERS/ESGE/ESTS endosonography 2026](https://pubmed.ncbi.nlm.nih.gov/42167778/).
- Practice data: [WABIP worldwide survey](https://pubmed.ncbi.nlm.nih.gov/40788098/),
  [FLEXICARE ICU survey](https://pubmed.ncbi.nlm.nih.gov/41953760/).
- Education meta-analyses: [Cook 2011](https://pubmed.ncbi.nlm.nih.gov/21900138/),
  [Cook 2013 design features](https://pubmed.ncbi.nlm.nih.gov/22938677/),
  [Cook 2013 mastery](https://pubmed.ncbi.nlm.nih.gov/23807104/),
  [Brydges 2015](https://pubmed.ncbi.nlm.nih.gov/25374041/),
  [Kennedy 2013](https://pubmed.ncbi.nlm.nih.gov/23370487/).
