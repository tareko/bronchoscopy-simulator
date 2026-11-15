# VR / physical bronchoscopy simulators in Asia — verified survey

**Method note.** General web search was unreliable in this session (Bing endpoint returned
unrelated results for every query; DuckDuckGo/SearX/Naver later rate-limited the IP). Everything
below comes from (a) pages actually fetched, (b) OpenAlex/PubMed metadata, (c) regional engines
(Yahoo! Japan, Naver/Daum, Sogou) while they responded, and (d) OCR of a scanned AIIMS tender PDF.
Items seen only in a search snippet are tagged **[snippet only]**.

Legend: **[V]** = fetched/verified page · **[P]** = published paper metadata verified ·
**[OCR]** = read out of a scanned primary document.

---

## JAPAN

### Kyoto Kagaku MW19 "DAM Simulator — Bronchofiberscopy model" (part 11393-100) **[V]**
- https://www.kyotokagaku.com/en/products_data/mw19dam/ · JP: https://www.kyotokagaku.com/jp/products_data/mw19dam/
- Physical manikin only. Real fiberscope is inserted. JP page: interior reproduces trachea, both
  main bronchi down to **B1–B10 bifurcations**, including internal folds.
- Materials: soft special resin + hard resin, latex-free. 2.65 kg, W45 x D20 x H25 cm.
  Set = manikin, 3 upper incisors, 2 tongues II, lubricant, syringe, bag.
- No electronics, no scoring. Priced "quote"; **US reseller list USD 2,150** (SKU 11393-100)
  — https://simtrainingresource.com/product/mw19-difficult-airway-management-simulator-for-bronchofiberscopy/
- Not classified as a medical device in Japan.
- Evidence: no device-specific validation study found.

### Kyoto Kagaku KAD-4 ENDO Mentor Suite BRONCH (basic, 11448-000) / KAD-5 BRONCH Express (11449-000) **[V]**
- https://www.kyotokagaku.com/jp/products_data/kad-4/
- This is Kyoto Kagaku distributing/rebranding **Simbionix BRONCH Mentor** (page links
  "English maker site (Simbionix)"; the platform is now **Surgical Science AB, Sweden, Nasdaq SUS**).
- Hardware: dedicated platform, 27" touchscreen, motorised height adjustment, **one real
  bronchoscope**, foot switch, **haptic feedback ("触覚機能")**, master tool, 10 cc syringe.
  225 kg. 100–240 V, 700 W. W57–87 x L130–186 x H135–180 cm. Japan: *not* a medical device (class なし).
- Modules: Basic bronchoscopy (co-developed with **AABIP**), Diagnostic bronchoscopy (incl. scope);
  optional **11448-010 Emergency bronchoscopy**, **11448-020 EBUS**, **11448-030 CHEST standard curriculum**.
- Marketing claims: real patients as virtual patients; sedation/local anaesthesia; reactive vitals,
  cough, complications; metrics covering patient safety, procedural validity, clinical judgement,
  diagnostic yield, instrument safety.
- Price: quote only; no public list price for BRONCH Mentor anywhere.
- Evidence: platform-level, not vendor-specific — Surgical Science + CHEST "10 years" press release
  (2026-10-21). Most Western VR-bronch literature uses this device class.

### Koken LM-092 / LM-099 — Tokyo, **not** Kyoto Kagaku (frequent mis-attribution) **[V]**
- https://www.koken-educational-medical-models.com/products/931 (LM-092) · /932 (LM-099)
- **LM-092**: special-process silicone bronchial tree reproduced to **V-order bronchi** (e.g. B1aiα);
  ultrathin bronchoscope can reach V-order; special silicone rubber gives near-human insertion feel;
  bronchi are anatomically coloured; distal tree open so it can be washed; demountable from stand.
  Supervised by Ibaraki Prefectural Central Hospital; endorsed by Asano Fumihiro (Gifu) and
  Saka Hideo (Nagoya Medical Center).
- **LM-099**: adds **EBUS-TBNA** — lymph nodes embedded in puncture sites, real puncture/cartilage
  feel, supports the outer-sheath (外筒法) technique; includes a **head model for oral insertion**
  with tracheo-oesophageal bifurcation landmark. Developed with St. Marianna University
  (Kurimoto Noriaki, Inoue Takeo).
- Evidence: **"The bronchoscopy model LM-092 has educational benefits", J Anesth 2013,
  doi:10.1007/s00540-013-1687-4** **[P]**

### Olympus — vertical integration, but no VR trainer **[V]**
- **Bf-NAVI virtual bronchoscopy software**, launched in Japan 2008-08-01.
  https://www.olympus.co.jp/jp/news/2008a/nr080612bfnavij.html
  - Windows PC software; developed/manufactured by **KGT** (Shinjuku; Cybernet Systems subsidiary).
  - DICOM import → automatic 3D virtual bronchoscopy; auto-searches **up to 3 insertion routes**;
    video playback with advance/withdraw, left-right rotation, frame-by-frame.
  - Licensing: single-licence set (1 install CD, 1 editor HASP, 1 viewer HASP) and multi-licence set
    (2 editor + 3 viewer HASP); **PC not included** → hardware-key licensing, i.e. seat-based.
  - It is a *planning / rehearsal* tool, not a hands-on trainer.
- **EBUSモデルアドバンス** — Olympus's own physical EBUS training model.
  https://www.olympusprofed.com/jp/31093/
  - Submerged structure for stable ultrasound image; target/ bronchus positions movable by training
    level; perfusion circuit simulates blood flow; for Olympus EBUS scope/probe and instruments.
  - Teaching videos by Matsumoto Yuji (National Cancer Center Hospital): EBUS-TBNA 4L node puncture,
    EBUS-TBNA staging, EBUS-GS peripheral sampling.

### Nagoya University (Okachi et al.) — Japan's strongest academic VR/AR line **[P]**
- **2022 Surg Innov**, doi:10.1177/15533506211068928 — **Epson Moverio BT-35E** binocular see-through
  smart glasses (720p, HDMI) fed fluoroscopy (live + reference), VBN and bronchoscopy video through a
  converter, used while scoping a *training model*; 4 experienced pulmonologists x 5 cases; all reached
  target bronchus; no eye/body fatigue. Feasibility only; not a product.
- **2023 Surg Innov 30(5):685-686**, doi:10.1177/15533506231160201 — research letter, mixed reality
  feasibility; Nagoya University **Medical xR Center** + Aichi Cancer Center.
- **2026 Surg Innov**, doi:10.1177/15533506261441953 — navigational bronchoscopy training with spatial
  computing (**Apple Vision Pro**).
- **2026 Respiration**, doi:10.1159/res/aepag014 — bronchoscopist kinematics motion capture with a
  spatial-computing device (methodological proof of concept).

### Japanese channel
- Gadelius Medical sells **BRONCH Mentor Express** (portable).
- Adachi Inc (https://adachi-inc.co.jp) — GI + bronchoscopy endoscopy training simulators on real scope models.
- Japan Light Service (https://medical-sim.jp) — **ORSIM** (New Zealand) distributor.
- Public hospital inventories name devices: Osaka Medical & Pharmaceutical Univ. Hospital lists
  "GI/Bronch Mentor"; Nagasaki Univ. Hospital lists 2x Koken EBUS models. **[V]**

---

## CHINA

### Preclinic Medtech 上海璞临医疗 (Shanghai, Qingpu) — clearest Chinese virtual+physical hybrid **[V]**
- https://www.preclinic.net (new domain preclinic.com; also preclinic-sim.com)
- **IPSIM 支气管镜手术培训虚拟模拟器, model PLHX3002XN-TC**
  https://www.preclinic.net/products/ipsimzhiqiguanjingshoushupeixunxunimoniqi/
  - CT-reconstructed high-fidelity bronchial model made by **3D printing**, plus "internal vision
    reproduction" and **"虚实结合" (virtual-real combination)** technology, plus "real-texture
    operating instrument"; claims hand-feel and endoscopic scene close to clinical.
  - Structure: training module / assessment module / case module; **customisable scoring weights**;
    separate teacher account and per-student accounts; case library expanded from real clinical cases.
  - Also a **portable version** of the same simulator.
- Physical models: **PLHX1001** bronchoscopy training model — high-soft silicone **18A–30A**,
  28 x 28 x 14 cm, **15-day lead time, made in Shanghai**; works with fibreoptic/video bronchoscope,
  biopsy forceps, brush; replaceable simulated foreign bodies.
  https://www.preclinic.net/products/bronchoscopy-training-model/
- Catalogue around it: paediatric bronchoscopy model, respiratory endoscopy model, intraluminal
  therapy model, **EBUS** model, lung-nodule navigation puncture model, medical thoracoscopy model.
- MedicalExpo also lists a Preclinic "virtual bronchoscope simulator **PLHXNJ102TC**" described as
  hardware + simulation software + **AI engine** **[snippet only]** (medicalexpo.com is behind Cloudflare).
- Evidence: none published. Pricing: contact-quote.

### Trandomed 宁波创导三维医疗科技 (Ningbo) **[V]**
- https://www.trandomed.com/products_detail/35.html (CN) · trando-med.com EN / ja. / ko. mirrors
- "呼吸系统支气管镜训练模拟器": portable high-fidelity model built from **real CT/MRI data**, customisable
  to individual patient data.
- Anatomy: left/right main bronchi, **five lobes / eighteen segments**, tracheal cartilage rings,
  carina; **some branches to 7th order**.
- Material: flexible soft silicone, hardness **40A**. 30 x 26 x 19 cm. Build time **7–10 days**.
- New revision adds a **conformal support frame** so the silicone tree does not collapse/deform under
  scope insertion. Distal end open, whole structure demountable for cleaning. Replaceable simulated
  foreign bodies / lesions.
- Claimed skills: fibreoptic *and* video bronchoscope inspection, foreign-body finding, suction,
  lavage, biopsy, brushing, insertion/advance/rotation, and explicitly **"bronchoscope tip control and
  centring"** training.
- B2B posture: JA/KO pages advertise "10% off", wholesale, free samples. No price. No validation.

### Xi'an Human-tech 西安休曼科技 **[V]**
- https://www.human-tech.art/products/51.html
- **BR-S1 支气管镜手术训练模型**: 3D reconstruction from **Chinese standard adult CT**; medical silicone;
  full path **oral and nasal** → trachea → carina → **5th-order bronchi**; cartilage rings and carina as
  endoscopic landmarks; works with a real bronchoscope and accessories.
- Product family (same vendor, all CT/MRA-derived, explicitly *not* scaled adult anatomy):
  - 支气管狭窄手术训练模型 — stenosis at defined sites, wall-thickness/lumen variation
  - 支气管腔内治疗手术训练模型 — intraluminal lesions with different hardness for grasping/cutting
  - 超声支气管手术训练模型 (EBUS) — simulated mediastinal tissue, lymph nodes and vessels with
    ultrasound-visible material properties, for EBUS + needle puncture
  - 儿童支气管镜手术培训模型 — built from a **6-year-old child's CT/MRA**, not a shrunk adult
- No validation evidence. Quote-only.

### Beijing Beidestar 北京贝德思达 **[V]**
- http://www.beidestar.com/product/206.html — **BDS-Bronchoscopy**, "支气管镜检查思维训练系统"
  (bronchoscopy *clinical-thinking* training system).
- Filed under "医学软件与信息化产品系列" (medical software & informatics) — a screen-based trainer for the
  whole arc: pre-op assessment → intra-op decisions → post-op handling, not a scope-handling trainer.
- Same vendor sells "虚拟腔镜数据管理云平台" (cloud data-management platform for virtual endoscopy) and
  "VR手术情景教学系统". No published specs, metrics or validation.

### Tianjin Tellyes 天津天堰科技 (NEEQ: 833047) **[V/partial]**
- https://www.tellyes.com — "支气管内窥镜训练模型 **TY4612.100**" (part number from the JD listing and a
  Douyin product demo; the product page itself is not linked from their catalogue index).
- CN patent application **"一种四级支气管模型的制作方法"** (method of making a **4th-order bronchial model**),
  published ~2026-07 — they are building IP around casting 4th-order bronchial trees.
- Portfolio is manikin-centric with "虚实结合" AI platforms (e.g. TY8167.10 虚实结合AI护理实训平台,
  TY8164.1 AI medical learning platform, OSCE management platform). Bronchoscopy is a minor SKU.
- No bronchoscopy-specific metrics or validation.

### Others in China (lower confidence)
- **Zhejiang UE Medical Corp** — MedicalExpo lists a bronchoscopy/EBUS training simulator **[snippet only]**;
  site not reachable in this session. Unverified.
- **Nanjing AMIS Medical Technology** — "3D respiratory endoscopy simulator" per made-in-china listing **[snippet only]**.
- **KyrenMed** — bronchoscopy training simulator on Alibaba **[snippet only]**.
- 上海弘联 / 医博士 / 好医生 / Anke 安卓: no verifiable bronchoscopy simulator SKU surfaced. Anke is imaging
  equipment, 好医生 is a CME platform, 医博士 is exam-prep software. Do not cite them as bronchoscopy vendors.

### Chinese published evidence — this is where China actually leads **[P]**
- **Thorax 2025**, doi:10.1136/thorax-2025-223147 — "Digital twin-based bronchoscopy simulator improves
  training performance and skill retention of novices: a randomised controlled study."
  60 bronchoscopy-naive participants, 3 arms (control = written instruction; anatomic-uniformity = one
  standard model; anatomic-variety = multiple patient-derived CT bronchial trees). Multicentre:
  CAMS-PUMC, China-Japan Friendship Hospital, Wuhan Sixth, Shanghai Jiao Tong/Ruijin, Beijing Chao-Yang,
  Guangzhou First Affiliated + State Key Lab of Respiratory Disease.
  Metrics: **diagnostic completeness (DC, segments), structured progress (SP, correct progressions),
  procedure time**; retested at 3 months.
  Result: no difference on the standard model; on a *new* CT-derived model the variety group scored
  +2.5 segments DC and +9 SP (p<0.001); gains partly retained at 3 months. **Device vendor not named.**
- **Respiration 2025**, doi:10.1159/000546827 — RCT, First People's Hospital of Foshan + Copenhagen Academy
  (Konge, Cold): **human instructor feedback beat VR-simulator guidance** when learning flexible
  bronchoscopy. Important counter-evidence to "VR replaces teaching".
- **BMC Anesthesiology 2026**, doi:10.1186/s12871-026-03809-9 — portable VR flexible-bronchoscopy simulator
  validation for flexible optical intubation (Yunnan Univ. of TCM + Guangdong Academy of Medical Sciences +
  Copenhagen). 12 challenging adult airway cases; 15 novices vs 15 experienced; Cronbach α = 0.89;
  G-theory: 6 cases for formative (>0.7), 10 for summative (>0.8); pass/fail 34.4% by contrasting groups;
  2 false positives, 1 false negative. **Device not named** (almost certainly ORSIM).
- **J Thorac Dis 2025;17(9):7406-7413**, doi:10.21037/jtd-2025-565 — narrative review of MR in bronchoscopy
  education (Peking Union Medical College Hospital), CNKI-inclusive.
- Also: high-fidelity simulator refresher-training study 2024; several AI-feedback RCTs 2024 that are
  Copenhagen/Fudan collaborations rather than Chinese products.

---

## KOREA — the honest finding: no domestic bronchoscopy simulator

- Searched Naver, Daum, and OpenAlex (institution country = KR) for 기관지내시경 시뮬레이터 /
  bronchoscopy simulator / bronchoscopy training. **No Korean manufacturer of a bronchoscopy (VR or
  physical) trainer surfaced**, and no Korean bronchoscopy-simulation validation paper.
- **ALDAVER 알데바** (Daejeon; https://aldaver.co.kr) is the visible Korean sim manufacturer:
  tissue-mimicking materials ("reverse engineering via machine learning" for material properties) +
  multi-layer 3D printing from patient CT/MRI; ~20 models; urology (TURBT, RIRS, partial nephrectomy,
  prostatectomy, BPH) plus head&neck / chest / abdomen / pelvis / vascular / skin. The "chest" and
  "other" categories contain **no bronchoscopy SKU**. **[V]** (site is behind a JS cookie gate, CUPID/AES —
  needs the computed cookie to fetch.)
- Korean adoption looks import-based: Cheongnyeonuisa 2026-07-02 profiles regional hospital simulation
  centres where **internal-medicine residents train on GI and bronchoscopy endoscopy simulators**;
  contemporaneous SNU Bundang / Samsung Medical Center publicity is about **robotic bronchoscopy
  (Intuitive Ion)** and a "virtual hospital simulator" for AI validation — not bronchoscopy simulation. **[V]**
- Only Korean academic VR-endoscopy work found: **J Korean Med Sci 2020;35:e90**, doi:10.3346/jkms.2020.35.e90 —
  gesture-driven virtual dissection + virtual endoscopy with camera-vs-wall collision warning; generic,
  not bronchoscope-specific, no bronchoscopy validation. **[P]**
- Korea's real strength is adjacent: GI endoscopy simulators, box trainers, 3D-printed silicone ESD/ERCP
  models (Clin Endosc 2023 review; Sci Rep 2025 ERCP silicone).
- Consequence for the report: any Korean "VR bronchoscopy" claim should be treated as imported or
  aspirational until a product is named.

---

## TAIWAN

- **NTU CBBS (2006)** — the only Asian computer-based bronchoscopy simulator with a formal validation paper
  found. Chen JS et al., *J Formos Med Assoc* 2006;105(7):569-76, doi:10.1016/S0929-6646(09)60152-2,
  PMID 16877237. NTU Hospital + NTU + National Taipei Univ. of Technology; "NTUSEC" collaborative group.
  - 20 novices (randomised: conventional vs CBBS) + 10 experts.
  - **Metrics that discriminated expertise**: total procedure time (p=0.002); % bronchial segments
    entered (0.012); % segments identified (<0.001); % repeated segments entered (0.004);
    % pathologies identified (<0.001); **number of bronchoscope-tip collisions with airway wall** (0.013);
    number of oral instructions needed (0.01).
  - Experts rated both **mechanical and visual** realism. Hardware not named in the abstract, but a
    mechanical interface was clearly part of it. **[P]**
- **Fu Jen Catholic Univ. + NTU 3D-printed bronchial tree (2023)** — *Respir Care*,
  doi:10.4187/respcare.10671 (Liu WL, Lee IH, Lee LN, Yang SH, Chao KY).
  - Built in **Materialise Magics 22.02**, but the geometry was **reverse-engineered by scanning
    commercially available bronchial models with an EinScan Pro 2X Plus handheld white-light scanner
    (Shining 3D, Hangzhou)** plus a royalty-free Sketchfab CT lung file.
  - i.e. a deliberate cost-avoidance strategy: clone the imported commercial tree locally. **[P]**
- **Changhua Christian Hospital 彰基 臨床技能訓練中心 runs an ORSIM** (NZ) — public equipment page
  https://dpt.cch.org.tw/layout/layout_1/sitepage.aspx?Key=7027&ID=4613, describing the scope probe +
  desktop sensor + dedicated laptop, 3D virtual airway, real-time feedback/scoring, recording and video
  replay. **[V]**
- Channels: **Young Tah 永達儀器** (Taipei, "77 years") sells **BRONCH Express** (Simbionix) with
  Basic bronchoscopy (4 skill-acquisition tasks + endobronchial navigation), Diagnostic bronchoscopy
  (4 cases), **Essential EBUS** (4 tasks + 3 virtual patients) —
  https://www.youngtah.com.tw/bronchexpress支氣管鏡檢查模擬器 **[V]**
  **MedSim Healthcare** (HK/TW) sells ORSIM plus **SkillupVR**, a web-managed headset VR platform that is
  Norwegian-origin (references Norwegian hospitals) — https://medsimhealth.com **[V]**
- **Regulatory/credentialing driver**: the Taiwan Society of Pulmonary and Critical Care Medicine (TSPCCM)
  runs a **支氣管鏡技術師 (bronchoscopy technician) certification** with published 甄審辦法 (qualification
  rules), 教育訓練學分給予辦法 (training-credit rules) and annual lecture sets —
  https://www.tspccm.org.tw/dir/28550 **[V]**

---

## SINGAPORE — high-end importer + 3D-printing research hub

- **NUS/NUHS ORSIM RCT (2018)** — Wong DT, Mehta A, Singh KP, Leong SM, Ooi A, Niazi AU, You-Ten E,
  Okrainec A. *Eur J Anaesthesiol* 2019;36(3):227-233, doi:10.1097/EJA.0000000000000890.
  Institutions: National University of Singapore + Mount Sinai/Toronto Western + UCL.
  VR bronchoscopy simulator training improved **bronchoscopic-guided intubation performance in actual
  patients**. Device = **ORSIM** (New Zealand — note: not an Asian product). **[P]**
- **National multicentre curriculum (2021)** — Siow WT et al., *Respirology*, doi:10.1111/resp.14054.
  NUH + SGH + Changi General + Ng Teng Fong. 18 trainees, 3-month structured curriculum with simulator
  training vs apprenticeship; videos scored with modified **BSTAT**. Simulator training was the **only**
  factor correlating with better BSTAT (r = 0.80), MCQ (r = 0.85) and airway-anaesthesia scores (r = 0.83)
  despite fewer patient procedures. **[P]**
- **Tan Tock Seng + NTU multi-material 3D printing (2019)** — Ho BHK, Mogali SR et al., *BMC Med Educ*,
  doi:10.1186/s12909-019-1677-9. Material-jetting print + polymer amalgamation of patient-specific airways
  from 3 CTs (normal; right-main-bronchus tumour; goitre external compression). 5 expert respiratory
  physicians validated; flexible, life-size, patient-specific; explicitly critiques existing commercial
  models as "expensive or deficient in anatomical accuracy, clinical fidelity and patient representation". **[P]**
- No Singaporean bronchoscopy-simulator manufacturer found.

---

## INDIA — public procurement of imported VR + ultra-low-cost academic fabrication

- **AIIMS New Delhi 2019 tender — primary source [OCR]**
  https://www.aiims.edu/images/pdf/tender/anaes-31-10-19.pdf
  (scanned, 6 pp., file created 2019-10-31; text extracted by OCR — quoted content is OCR-accurate
  but check page images before quoting verbatim).
  - Title: **"Bronchoscopy Simulator System"**. Specs demand: **replica flexible bronchoscope + desktop
    sensor + processor with display monitor**; software auto-tracks the replica scope and renders
    computer-generated airway images; image quality must resemble normal anatomy; must reach **"at least
    4th generation bronchial tree"**; ≥15" HD monitor; second monitor for teaching; certification from a
    "renowned world body"; CAMC/AMC per AIIMS rules.
  - Scenario list: normal oral and nasal bronchoscopy + **13 difficult-airway scenarios** (airway trauma,
    angioneurotic oedema, carcinoma of tongue, distorted larynx, epiglottic cyst, false-cord cyst, gross
    papilloma, macroglossia, retropharyngeal abscess, severe epiglottis, unexpected difficult airway,
    vestibular lesion).
  - Appended: **ORSIM proprietary certificate** (Airway Simulation Ltd, Auckland NZ, dated 1 Aug 2019 —
    "sole licensee for the manufacture of the ORSIM; no other individual or company is authorized to
    manufacture the ORSIM") and a manufacturer's authorisation letter.
  - → India's flagship public hospital bought imported NZ VR under sole-source authorisation.
- **JIPMER low-cost model (2026)** — *Cureus*, doi:10.7759/cureus.106843. Paediatric-airway model built from
  locally available materials for **INR 1,000 (~USD 12)**; 26 ENT residents; face/content/curriculum/
  transfer validity on 5-point Likert (median ≥4); confidence rose p<0.001. **[P]**
- **GSVM Medical College broncho-trainer (2014)** — *Indian J Anaesth*, doi:10.4103/0019-5049.139020 —
  earliest Indian anatomical-model broncho-trainer paper. **[P]**
- **3D-printed airway model (2020)** — doi:10.47009/ajmrr.2020.8.2.8; and *Indian J Anaesth* 2024 review of
  simulation-based training in thoracic anaesthesia (doi:10.4103/ija.ija_1235_23). **[P]**
- **Domestic manufacturer**: **Maverick Simulation** (New Delhi; DSIR-recognised; https://mavericksimulation.com)
  builds patient simulators, task trainers, a generic **"Virtual Reality Simulation Trainer"**, and
  distributes LuSi/TestChest. **No bronchoscopy trainer in the catalogue.** **[V]**
- Net: India = imported VR in public institutions + INR-1,000 academic fabrication; no native product.

---

## Corrections on the two products named in the brief

- **"AnatomyX"** → https://www.anatomyx.com is **MediVis** (United States). AR anatomy *education*
  (HoloLens 2, Quest 3/3S, Vision Pro "coming soon"), 5,000–8,000 anatomy models, 13,000 assessments,
  multi-user shared sessions, **annual subscription** plus headset. **No bronchoscopy procedure trainer,
  no scope model, no airway navigation.** Not Asian. **[V]**
- **"InSimo"** → InSimo SAS, Strasbourg, **France** (Inria / IHU Strasbourg spin-out).
  Products: diSplay U/S (ultrasound), ROBiTIS (robotic surgery), Sim&Care (punctures/injections).
  Their "Pulmonary" speciality = **lung ultrasound**, *not* bronchoscopy. Not Asian, not a bronchoscopy
  product. **[V]**
- Also worth flagging: **ORSIM is New Zealand** (Airway Simulation Ltd, Auckland) and **TruCorp is UK
  (Belfast)**. Both appear heavily in Asian searches and Chinese-language catalogues and are easily
  mistaken for Asian products.

---

## What is genuinely different in Asia vs the West

1. **Physical-model-first, virtual-second.** The dominant Chinese architecture is **"虚实结合"**: a
   CT-reconstructed silicone bronchial tree that accepts a *real clinical bronchoscope*, with a screen
   layer reproducing the endoscopic view and scoring on top (Preclinic, Trandomed, Human-tech). Western
   vendors invert this — BRONCH Mentor / ORSIM are haptic-device-plus-virtual-airway, with physical models
   as a separate catalogue.
2. **Bimodal, much lower price lattice.** AIIMS bought ORSIM-class VR sole-source; Kyoto Kagaku MW19 is
   **USD 2,150** list; JIPMER built a validated trainer for **USD 12**; Chinese trees are quoted per unit
   with **7–15 day** build times and explicit B2B "10% off / free samples" wholesale language. Asia's
   volume market is the **sub-$5k physical tree**, not the $50k+ haptic platform.
3. **Localised anatomy as a selling point.** Chinese vendors market "基于中国人标准成年人CT数据" and paediatric
   trees made from a **6-year-old's CT/MRA** rather than adult anatomy scaled down — a claim Western
   catalogues almost never make.
4. **Web/LMS delivery is assumed, not optional.** Tellyes sells a whole "信息化" product line plus OSCE and
   training-centre management platforms; Beidestar sells a "虚拟腔镜数据管理云平台"; Preclinic ships
   teacher/student account hierarchies with editable scoring weights. The West sells a box with a local LMS.
5. **Evidence style differs.** China now produces multicentre pulmonology-led RCTs on **case-library
   diversity** (Thorax 2025: training across anatomically varied CT-derived trees beats one standard model,
   partly retained at 3 months) — a content/software contribution. The West produces device-engineering and
   validity-framework papers (Messick five sources, G-theory, pass/fail standards). Japan produces
   feasibility letters wrapping consumer HMDs (Moverio, Vision Pro) around existing scopes and models.
6. **Japan's structure is unusual:** the scope maker (Olympus) sells planning software (Bf-NAVI) and a
   physical EBUS model but **no VR trainer**, while the model maker (Kyoto Kagaku) **rebrands** the
   Israeli/Swedish Simbionix platform (KAD-4/KAD-5), and Koken owns the high-order silicone trees
   (LM-092/LM-099). So Japan = vertical integration on the scope side + distribution/rebrand on the
   simulator side.
7. **Korea is the gap.** Strong in urology/GI physical sims and in robotic-bronchoscopy adoption, with
   essentially no domestic bronchoscopy simulator and no Korean bronchoscopy-simulation validation literature.
8. **Adoption is driven by credentialing and state procurement, not vendor validation.** Taiwan's TSPCCM
   bronchoscopy-technician certification with mandated training credits, and India's AIIMS tender with
   manufacturer-authorisation paperwork, are stronger adoption signals than any Asian marketing page.
9. **Honest gaps.** No Chinese/Korean manufacturer publishes device-specific validity evidence; the Chinese
   RCTs that show benefit **do not name the device**; I could not verify knob/torque articulation modelling
   for any Asian product (none of the Chinese pages claim modelled knob ergonomics — they claim "real
   instrument feel", "tip centring" and resistance); no Asian vendor publishes prices.
