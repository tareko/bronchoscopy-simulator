# Open anatomy sources, airway CT datasets, and the mesh pipeline

Scoping research for an open-source (MIT) Linux/Godot VR bronchoscopy simulator.
All URLs were fetched on **2026-11-15** unless stated otherwise. Claims marked
*(measured)* were verified by downloading and inspecting the actual data in this
session, not by reading documentation.

---

## 0. Headline findings

1. **A ready-made, openly licensed tracheobronchial tree mesh exists** —
   BodyParts3D `FMA7393` "tracheobronchial tree": 95 OBJ files, **65,240 triangles**,
   millimetre units, including trachea, carina, main bronchi and *all 18
   bronchopulmonary segmental bronchi* with FMA names. *(measured)*
2. **BodyParts3D was relicensed to CC BY 4.0** (archive licence page "Last updated
   2025/02/27") — **not** CC BY-SA 2.1 JP as widely cited. But the OBJ files
   themselves still carry the old CC BY-SA 2.1 JP header text (files unchanged since
   2013). Treat this as an unresolved licence-metadata conflict (§1.1.3).
3. **ATM'22 CT data has contradictory terms**: the challenge site forbids
   redistribution, while its Zenodo record declares CC BY 4.0 (§2.3). Do not ship it.
4. **TCIA has no airway or bronchoscopy collection at all** — site search for
   "tracheobronchial" and "bronchoscopy" returns *no results*; LIDC-IDRI is
   CC BY 3.0 but annotated for lung *nodules*, not airways. *(verified)*
5. **AeroPath is the cleanest open airway CT dataset**: 27 CTs with airway masks,
   **CC BY 4.0**, 5.04 GB on Zenodo. *(verified via Zenodo API)*
6. **Airway segmentation is already Apache-2.0 in TotalSegmentator** via the
   `lung_vessels` task (`lung_airways`), so patient-specific trees can be produced
   from free software end-to-end.

---

## 1. Anatomy mesh sources

| Source | What it gives you | Licence | Open-source compatible? | Status (verified) | URL |
| --- | --- | --- | --- | --- | --- |
| **BodyParts3D** (DBCLS, JP) | Whole-body adult male, 1,258 OBJ parts; full tracheobronchial tree, lungs, lobes, segmental bronchi | **CC BY 4.0** per current licence page (2025-02-27); OBJ files still say CC BY-SA 2.1 JP | **Yes** (attribution; SA variant needs asset-pack separation) | Live, downloads HTTP 200, data frozen at Release 4.0 (2013-05-22) | <https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html> |
| **Zygote / Zygote Body** | Premium anatomy incl. respiratory | Commercial EULA | **No** | Site footer still "2015"; prices not published | <https://www.zygotebody.com/terms> |
| **AnatomyStandard** | Illustrations + paid apps (spine, skull, knee) | **CC BY-NC 4.0** | **No** (NC blocks commercial use) | Site "Last update Sep/04/2025" | <https://anatomystandard.com/> |
| **NIH 3D** (`3d.nih.gov`) | 12,000+ models, GLB/STL/X3D/WRL, WebXR viewer | Per-entry (CC0/CC BY or stricter) | Case by case | Live, rebranded, NIAID-run | <https://3d.nih.gov/terms> |
| **OpenAnatomy** | 6 atlases + Mauritanian **Thoracic Atlas** (CT-derived, incl. respiratory system) | "3D Slicer License section B" | **Yes** (BSD-ish) | Atlas ZIP download **404**; viewer live | <https://www.openanatomy.org/atlas-pages/atlas-mauritania-thorax.html> |
| **Z-Anatomy** | Blender `.blend` (~291 MB) whole-body atlas derived from BodyParts3D | **CC BY-SA 4.0** | Yes, SA (asset pack) | Community "revival" repo, patched 2026-09 | <https://github.com/moueza/Z-Anatomy> |
| **Slicer Sample Data** | `CTChest` etc., downloadable in-app | Per-dataset (not stated in module docs) | Unclear — verify per dataset | Live | <https://slicer.readthedocs.io/en/latest/user_guide/modules/sampledata.html> |
| **Visible Human Project** (NLM) | Cryosections + CT/MR of one male/female | **No licence required since 2019** (public-domain-style) | Yes | Live, direct downloads | <https://www.nlm.nih.gov/research/visible/visible_human.html> |
| **IT'IS Virtual Population** | ViP V3.x/V4.x phantoms, 300+ tissues @0.5 mm | Membership/licence (terms not public) | **No** (assumed) | Live | <https://itis.swiss/virtual-population/virtual-population/overview/> |
| **BioDigital** | Web anatomy platform | Paid SaaS | **No** (no mesh export) | Live; pricing behind JS app | <https://www.biodigital.com/> |
| **Sketchfab CC models** | e.g. "Bronchial Tree" 3,113 faces | Mixed; sampled models are "Standard" | **No** for sampled ones | `isDownloadable: false` *(API-checked)* | <https://api.sketchfab.com/v3/search?type=models&q=bronchial> |
| **BodyParts3D mirrors** | Same meshes, git-friendly | Repo says MIT, **data stays CC BY 4.0** | Yes, with BP3D attribution | Active (2026-11-13) | <https://github.com/Kevin-Mattheus-Moerman/BodyParts3D> |

### 1.1 BodyParts3D — the primary candidate

#### 1.1.1 Hosting status and downloads *(all measured 2026-11-15)*

- Portal: <https://dbarchive.biosciencedbc.jp/en/bodyparts3d/desc.html> — DOI
  `10.18908/lsdba.nbdc00837-000`; "last update date 2013/05"; "Operation start 2007/10".
- Download page lists **only the 99 %-decimated OBJ sets**:
  `isa_BP3D_4.0_obj_99.zip` (142,903,898 B) and `partof_BP3D_4.0_obj_99.zip`
  (64,888,505 B), plus concept/ID tables.
  <https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html>
- Both archives returned **HTTP 200** with `Last-Modified: Wed, 22 May 2013` — i.e.
  the *data* is untouched for 13 years, only the licence text was updated.
- Directory listing confirms no higher-resolution set was ever published at this
  host: <https://dbarchive.biosciencedbc.jp/data/bodyparts3d/LATEST/>
- Update history: `2025/02/27 "License" is updated`; `2013/06/19 3D data (Release 4.0)`.
  <https://dbarchive.biosciencedbc.jp/en/bodyparts3d/update.html>
- Release note (v4.0, 2013/5/16): "Segmented Lung and liver with vessels were added",
  "Pharynx and Larynx parts were added", 1,651 elemental + 1,254 compound concepts.
  <https://dbarchive.biosciencedbc.jp/data/bodyparts3d/LATEST/release_4.0_e.html>

#### 1.1.2 The airway tree — verified by download *(measured)*

`partof_BP3D_4.0_obj_99.zip` unpacks to 1,258 OBJ files named `FJ####.obj`, joined to
concepts via `partof_element_parts.txt` (`concept id → name → element file id`):

| Concept | FMA id | Elements | Verts | Tris |
| --- | --- | --- | --- | --- |
| tracheobronchial tree | FMA7393 | 95 | 38,912 | **65,240** |
| thoracic part of tracheobronchial tree | FMA26572 | 94 | 36,305 | 60,244 |
| right bronchial tree | FMA26661 | 54 | 27,693 | 46,746 |
| left bronchial tree | FMA26662 | 40 | 8,612 | 13,498 |
| trachea | FMA7394 | 1 (`FJ2541`) | 2,607 | 4,996 |
| right main bronchus | FMA7395 | 1 (`FJ2539`) | 2,564 | 4,468 |
| left main bronchus | FMA7396 | 1 (`FJ2450`) | 2,304 | 4,136 |

Also present: right/left lung, 5 lobes, and the 18 named bronchopulmonary segments
(FMA7338–FMA7380, FMA68211–FMA68233) — **segment-level naming that maps directly onto
this project's `RB1…RB10`, `LB1+2…LB10` labels.**

Geometry checks *(measured)*:

- Bounding box **239.4 × 157.6 × 270.6 mm**; all coordinates positive-ish whole-body
  frame, so the tree sits around `(x≈0, y≈−100, z≈1125…1395)` mm — a rigid transform
  is required to reach the simulator's incisor-origin convention.
- Trachea cross-section: **≈19.8 mm** diameter at the upper end, tapering to ≈14 mm at
  the carina — anatomically correct for an adult male (so the mm unit is real, not
  nominal).
- Rendered front/side/top views confirm a proper carina with lobar and segmental
  branching (no stray fragments).
- **Every element is an open surface**: 11,482 boundary edges across the 95 files,
  **0 non-manifold edges**, 0 quads (all triangles). So the "tree" is a set of
  tube-fragments that abut but are not stitched — hole-filling/stitching is required
  before it works as a closed lumen (§4.3).
- Each OBJ has vertex normals (`vn`, one per vertex), **no UVs** (`vt` count = 0),
  one material (`usemtl mtl1`), object name `grp1` → UV unwrap and texturing is our job.

#### 1.1.3 The licence conflict (important)

- Licence page, "Last updated: 2025/02/27": *"The license for this database is specified
  in the Creative Commons Attribution 4.0 International"*, attribution string
  `"BodyParts3D, © The Database Center for Life Science licensed under CC Attribution 4.0 International"`,
  and it explicitly permits redistribution and derivative works.
  <https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html>
- The NBDC archive's database-description page lists the licence simply as "CC BY".
  <https://dbarchive.biosciencedbc.jp/en/bodyparts3d/desc.html>
- **But** every OBJ file's own header (written 2013, never regenerated) says:
  *"The license for this database is specified in the Creative Commons Attribution-Share
  Alike 2.1 Japan… 'BodyParts3D, (c) The Database Center for Life Science licensed under
  CC Attribution-Share Alike 2.1 Japan'"* *(measured)*.

Consequence for us: the files-in-hand advertise **CC BY-SA 2.1 JP**, while the
licensor's current published terms say **CC BY 4.0**. Both are open and
redistributable; they differ in share-alike. Practical handling:

- Attribute as `"BodyParts3D, © The Database Center for Life Science, licensed under
  CC BY 4.0 (archive licence page, 2025-02-27; source files carry a legacy CC BY-SA 2.1 JP
  notice)"` and keep the meshes as a **separately licensed asset pack** under
  CC BY-SA 4.0-compatible terms, never merged into MIT source. That is compatible with
  both readings.
- Or ask DBCLS to confirm in writing (contact on the licence page) — recommended before
  any commercial deployment.

#### 1.1.4 Mesh quality / format summary

- Format: Wavefront OBJ, triangles, per-vertex normals, mm, no materials beyond a stub,
  no textures, 99 % polygon reduction of the original (the full-resolution set is gone).
- Visual density is adequate for VR: 65 k tris for the whole tree is *below* what
  marching cubes would give us from a 1 mm CT (typically 200 k–1 M tris), so no
  decimation is needed — the work is topology repair, not reduction.
- Trachea-only (4,996 tris) is a good scope-path asset; segmental elements (50–350 tris
  each) are ideal for collision proxies.

### 1.2 Zygote / Zygote 3D

- Poly-model catalogue includes a "3D Respiratory" collection, but the product page
  advertises only an "Alveoli 3D Model" — the bronchial tree lives inside the paid
  full-body collections. <https://www.zygote.com/poly-models/3d-human-respiratory>
- **No prices are published anywhere on the site**; product pages have no buy button and
  no price text, and the footer reads "2015 © All Rights Reserved" — a stale site
  *(measured)*. Cost is therefore **quote-only; could not verify**. (Reported industry
  figures of a few thousand USD per collection circulate, but I found no primary source,
  so I will not assert one.)
- ZygoteBody (the free web viewer) is explicitly **not** a data source: the EULA states
  that personal accounts may not create derivative works, that only a Professional
  subscription may publish images/videos, that such use must stop when the subscription
  lapses, and that *"Zygote is, and shall be, the sole and exclusive owner of any such
  derivative content"*. <https://www.zygotebody.com/terms>
- Verdict: **excluded**. Useful only as a visual reference for what "good" looks like.

### 1.3 AnatomyStandard

- Site: *"All our original images are licensed under the Creative Commons
  Attribution-NonCommercial 4.0 International License"*, "Last update: Sep/04/2025".
  <https://anatomystandard.com/>
- Terms of use (last updated **2021-12-09**) repeat CC BY-NC 4.0 for "text, images, and
  video". <https://anatomystandard.com/docs/terms-of-use.html>
- I found **no downloadable 3D mesh** (OBJ/STL/glTF) anywhere on the site — the 3D work is
  delivered through three paid apps (spine, skull/teeth/TMJ, knee). Their anatomy is
  excellent for airway-adjacent structures (larynx, trachea illustrations) but is
  **NC-licensed and mesh-less**, so: **excluded**. (If a mesh download page exists behind
  a login, it is not discoverable without an account — flagged.)

### 1.4 NIH 3D (`3d.nih.gov`) — formerly the NIH 3D Print Exchange

- Status: **live and rebranded** as "NIH 3D", run by NIAID; over 12,000 assets; new
  workflow system with GLB editing and a WebXR (Quest 2/3) viewer; entries carry DOIs.
  <https://3d.nih.gov/>
- Licensing: **per entry**, enforced by the uploader, not by NIH — *"Users are responsible
  for selecting and applying the appropriate license… many entries in NIH 3D fall under
  public domain or Creative Commons licenses (e.g., CC-BY), others may have more
  restrictive terms. Visitors… must review and comply with the licensing terms associated
  with each file."* Also: models are "not intended for medical diagnosis or treatment".
  <https://3d.nih.gov/terms>
- Formats: ".glb, .stl, .x3d, and .wrl"; "Licensing varies"; WebXR loads only < 50 MB.
  <https://3d.nih.gov/faqs>
- Collections (from the site's own nav): Heart Library, Human Reference Atlas, NIAID
  Allergy, TB Portals, Neuroscience, 3D Pollen, e-NABLE, COVID-19 Response, Outbreak,
  Pathogen AR, SARS-CoV-2, VHA OAM. **No respiratory/airway collection.**
- Caveat: search results are client-rendered (Next.js) and the JSON API is undocumented
  (every `/api/...` guess returned 404), so I **could not** enumerate airway/lung entries.
  My working conclusion — "no known ready-made segmented tracheobronchial tree on NIH 3D,
  and per-entry licences make it unattractive for a bundled asset" — is therefore
  *partially unverified*; a logged-in manual search is the way to close it.

### 1.5 Other sources worth noting

- **OpenAnatomy** (<https://www.openanatomy.org/>): BWH Surgical Planning Lab; atlases for
  brain, inner ear, knee, head & neck, abdomen, liver, plus a **Mauritanian Thoracic
  Atlas** (CT-derived, Jan 2021, includes "the respiratory system").
  Licence stated as **"3D Slicer License section B"** — which is the Slicer download
  agreement: royalty-free, sublicensable, allows use/reproduction/**derivative works**/
  display/distribution **including incorporation into proprietary programs**, conditioned
  on attribution, retaining the notice, and clearly marking modified versions.
  <https://raw.githubusercontent.com/Slicer/Slicer/main/License.txt>
  **But** the atlas ZIP `https://www.openanatomy.org/atlases/macbioidi/mauritania/thorax-2020-11-15.zip`
  returns **HTTP 404** *(measured)* while the in-browser viewer
  (`…/viewer/`) returns 200 — i.e. the download path is broken in 2026. Whether the atlas
  contains trachea/bronchi (vs. lungs only) is **unverified**.
- **Slicer Sample Data**: the `CTChest` volume is the dataset used by the AirwaySegmentation
  tutorial, downloaded in-app on demand. The module docs do not state per-dataset licences
  → **verify individually** before shipping anything derived from it.
  <https://slicer.readthedocs.io/en/latest/user_guide/modules/sampledata.html>
- **Z-Anatomy**: a Blender-native atlas (`Startup.blend`, ~291 MB) licensed **CC BY-SA 4.0**,
  built on BodyParts3D geometry; the maintained copy is a "revival" repo because the
  original LFS files were lost. Blender 3.6-compatible; reportedly broken in Blender 4.5.
  <https://github.com/moueza/Z-Anatomy> — attractive if we want *editable* anatomy in
  Blender, but SA and a heavyweight file.
- **Sketchfab**: API search for "bronchial" returns plausible models ("Bronchial Tree",
  3,113 faces; "Human Bronchial Anatomy", 54,332 faces) but both are **not downloadable**
  and the latter is licensed "Standard" (all rights reserved) *(API-measured)*.
  <https://api.sketchfab.com/v3/search?type=models&q=bronchial> → **excluded**.
- **Visible Human Project**: *"As of 2019, a license is no longer required to access the VHP
  datasets"*; direct downloads (male, female, head, sample) at
  `data.lhncbc.nlm.nih.gov/public/Visible-Human/…`.
  <https://www.nlm.nih.gov/research/visible/visible_human.html>
  Value: photographic ground truth for airway colour/appearance; **not** a mesh — you would
  have to segment the cryosections yourself.
- **IT'IS Virtual Population**: ViP V3.x/V4.x (Ella, Duke, Billie, Thelonious), 300+ tissues
  at 0.5 mm, used in FDA regulatory-science contexts; distribution is via membership /
  licence agreement and the terms are not published on the overview page
  (<https://itis.swiss/virtual-population/virtual-population/overview/>). Assumed
  **commercial / not redistributable** → **excluded**, flagged as unverified.
- **BioDigital**: paid web platform; no offline mesh export for redistribution; pricing
  behind a JS app and sales contact → **excluded**.
- **BodyParts3D mirrors**: e.g. `Kevin-Mattheus-Moerman/BodyParts3D` (repo MIT, data still
  CC BY 4.0), `ashemag/human-atlas`, `jixiangyang/anatomy` — convenient for CI because you
  can pin a git commit instead of a 62 MB zip from a 2013 FTP host. Do **not** inherit the
  mirror's MIT label for the data.
- **"asklepieion / Open3DModel medical sets"**: I could not verify either name as a real,
  licensed medical-mesh collection (searches resolved to unrelated sites). **Unverified —
  treat as not existing until someone produces a URL.**

### 1.6 Is there an open, ready-made segmented tracheobronchial tree?

**Yes — BodyParts3D `FMA7393`.** Verified hands-on: 95 OBJ elements, 65,240 triangles,
trachea + carina + main/lobar/segmental bronchi, mm units, CC BY 4.0 (with the caveat in
§1.1.3). It is the only source I could verify that provides an actual *segmented airway
tree mesh* under an open licence. Nothing else came close:

- OpenAnatomy thorax atlas: download broken, contents unverified.
- Z-Anatomy: derived from BodyParts3D, so the same tree is in there but buried in a 291 MB
  blend with SA licensing.
- NIH 3D / Sketchfab / Zygote / AnatomyStandard: no downloadable open airway tree found.

Second-best option — and the one that gives *patient-specific* anatomy — is to **segment
our own** from AeroPath (CC BY 4.0) with TotalSegmentator (`lung_airways`, Apache-2.0).

---

## 2. Open CT datasets with airway content

| Dataset | Size / content | Licence | Access | Airway masks? | Status (verified 2026-11-15) | URL |
| --- | --- | --- | --- | --- | --- | --- |
| **LIDC-IDRI** (TCIA) | 1,010 subjects, 133.16 GB, thoracic CT (mostly thin-section) | **CC BY 3.0** | Public download (TCIA Data Retriever / NBIA); no DUA | **No** — nodule annotations only | Complete, last updated 2020-09-21 | <https://www.cancerimagingarchive.net/collection/lidc-idri/> |
| **AeroPath** | 27 CTs + airway + lung masks, 5.04 GB | **CC BY 4.0** | Zenodo + HF Hub, open | **Yes** (airway masks) | Live (record dated 2023-11-03) | <https://doi.org/10.5281/zenodo.10069289> |
| **ATM'22** | 500 CTs, 3-radiologist airway labels; batches of ~32 GB | Zenodo says **CC BY 4.0**; challenge site says **redistribution prohibited** | Registration + signed data agreement e-mailed to organisers | **Yes** | Challenge closed, long-term validation still running; **ATM'26 now open** | <https://atm22.grand-challenge.org/> |
| **ATM'26** | Track 1 binary airway seg, Track 2 branch-wise labelling, Track 3 bronchoscopy-video landmark recognition | Not published yet | Registration + signed agreement; dataset page "coming soon" | **Yes** | Active 2026 (MICCAI 2026 Strasbourg) | <https://atm26.grand-challenge.org/> |
| **EXACT'09** | 20 train + 20 test CT with airway reference | Not stated on site | No public download link visible | **Yes** (historically) | Site responds 200 but only shows submission-formats; **likely stale/unavailable** | <https://exact09.grand-challenge.org/> |
| **AirWSeg** (aggregator) | EXACT'09 + ATM'22/BAS, preprocessed NIfTI | **No licence file** | GitHub | Yes | Active repo, licence unclear | <https://github.com/BioMedIA-repo/AirWSeg> |
| **CrossAir-1K** | Cross-species airway benchmark | **No licence file** | GitHub | Yes | Active | <https://github.com/JianjunZhu/crossair1k_benchmark> |
| **BifDet** | 3D airway *bifurcation* detection dataset | Not stated in abstract | Paper 2026-04-27 | Bifurcation labels | New | <http://arxiv.org/abs/2604.24999> |
| **TCIA airway / bronchoscopy collections** | — | — | — | — | **Do not exist** (search returns "no results") | <https://www.cancerimagingarchive.net/> |
| **Visible Human** | Cryosections + CT/MR, one male/female | No licence required (2019→) | Direct HTTP | No | Live | <https://www.nlm.nih.gov/research/visible/visible_human.html> |

### 2.1 LIDC-IDRI

- 1,010 subjects / 1,308 studies / 244,527 images, 133.16 GB, DOI
  `10.7937/K9/TCIA.2015.LO9QL9SX`; data types DX, CT, CR, Measurement, Radiomic Feature,
  Diagnosis; **CC BY 3.0** for every table row on the collection page *(verified)*.
- Access: **public**, via TCIA Data Retriever/NBIA; no per-collection data-use agreement
  (the TCIA-wide usage policy still applies). Attribution text ("Data Citation Required")
  and the acknowledgement sentence are mandatory.
- Airway relevance: thoracic CT, plenty of them thin-section, so *proximal* airways
  (trachea → lobar) are segmentable; but there are **no airway annotations**, and slice
  thickness varies between series — a widely repeated claim of "mostly 1.25 mm, some
  2.5–3 mm" that I did **not** verify from the collection page; check thickness per series
  before planning segmental-level work. Nodule XML annotations are irrelevant to us.
- Good use: a licence-clean corpus to *test* our own segmentation pipeline and to source
  "realistic CT noise" for synthetic data — **not** to ship meshes without doing our own
  segmentation (which is legally fine: see §5).

### 2.2 AeroPath — the recommended CT source

- Repo: <https://github.com/raidionics/AeroPath> (code **MIT**), dataset on Zenodo
  <https://doi.org/10.5281/zenodo.10069289> and Hugging Face `andreped/AeroPath`.
- Paper: *AeroPath: An airway segmentation benchmark dataset with challenging pathology*,
  <https://arxiv.org/abs/2311.01138>.
- Content: **27 CTs with corresponding airway and lung annotations**, 5.04 GB
  (`AeroPath.zip`) *(Zenodo API: `license: cc-by-4.0`, `access_right: open`)*.
- Why it matters: it is the only *airway-labelled* dataset I verified that is
  unambiguously redistributable. Pathology-rich cases (atelectasis, mucus plugs,
  bronchiectasis) are exactly the hard cases a training simulator should show.
- Limitation: 27 cases is small for training a network, fine for validation and for
  building a handful of patient-specific case meshes.

### 2.3 ATM'22 — good data, contradictory licence

- Site facts: 500 CT scans from multiple sites, labelled by three radiologists with >5 yrs
  experience; targets trachea, main, lobar and distal segmental bronchi; open call,
  long-term validation phase still running; benchmark paper *Multi-site, Multi-domain
  Airway Tree Modeling*, MedIA 90:102957 (2023).
- **"Important News: The redistribution of this dataset is strictly prohibited."** and
  "transfer of the dataset to others is not allowed"; registration requires e-mailing a
  signed data-agreement PDF to `IMR-ATM22@outlook.com`.
  <https://atm22.grand-challenge.org/>
- Yet the organisers' own Zenodo deposits are marked **CC BY 4.0 / open**:
  TrainBatch1 `10.5281/zenodo.6590745` (32.28 GB `.rar`), updated TrainBatch1
  `10.5281/zenodo.7949582`, TrainBatch2 `10.5281/zenodo.6590774` and `…7949571`,
  Validation Images `10.5281/zenodo.6590026` *(Zenodo API, all `cc-by-4.0`)*. The
  benchmark-manuscript deposit `10.5281/zenodo.6362170` is `cc-by-nd-4.0`.
- **Reading**: the CC BY 4.0 metadata contradicts the "no redistribution" text. For a
  shipped open-source asset this is unacceptable risk → **use ATM'22 only for internal
  evaluation, never commit masks/meshes derived from it** (this matches the project's
  existing licence map). Ask the organisers in writing if you need it cleanly.
- Related code: `EndoluminalSurgicalVision-IMR/ATM-22-Related-Work` (repo **MIT**) links the
  challenge's papers/results and a "BAS" binary-airway-segmentation dataset
  <https://github.com/EndoluminalSurgicalVision-IMR/ATM-22-Related-Work>.

### 2.4 EXACT'09 — flag as stale

- Page is up (<https://exact09.grand-challenge.org/, HTTP 200>) but its "Introduction"
  only lists the *submission* file naming convention and says it was "Part of ISMI18"
  (a 2018 workshop re-run). No dataset download endpoint is exposed.
- Original reference: Lo P, van Ginneken B, Reinhardt JM et al., *Extraction of airways
  from CT (EXACT'09)*, IEEE TMI 31(11):2093–2107, 2012 — 20 training + 20 test scans.
- Practical availability today is via third-party re-hosting (e.g. the AirWSeg repo ships
  preprocessed EXACT'09 NIfTI). **Licence of those copies is unknown** → do not ship.

### 2.5 Newer airway / bronchoscopy datasets

- **ATM'26** (active): adds Track 2 *branch-wise anatomical labelling* (segmental labels —
  directly useful for our scoring) and **Track 3: landmark recognition for endobronchial
  intervention from monocular bronchoscopy video**, predicting branch names such as `RB6`,
  `LB7a`. Dataset access requires registration + signed agreement; "dataset access and
  submission guidelines are coming soon" as of 2026-11-15.
  <https://atm26.grand-challenge.org/>
- **Bronchoscopy video**: no openly licensed, annotated *video* dataset verified. Papers
  exist (BronchoPose 2022 <https://arxiv.org/abs/2204.11982>; weakly supervised airway
  orifice segmentation 2022 <https://arxiv.org/abs/2208.11468>; BronchoLumen 2026
  <http://arxiv.org/abs/2605.11748>; BREATH-VL 2026 <http://arxiv.org/abs/2601.03713>) —
  arXiv listings only; dataset access and licences not verified. Treat as "contact authors".
- **CrossAir-1K** <https://github.com/JianjunZhu/crossair1k_benchmark> (cross-species
  airway segmentation benchmark) and **BifDet** <http://arxiv.org/abs/2604.24999>
  (bifurcation-detection dataset, 2026-04) are worth monitoring but have no stated licence.

---

## 3. Segmentation and mesh tooling on Linux

| Tool | Licence | Airway capability | Status (verified) | URL |
| --- | --- | --- | --- | --- |
| **3D Slicer** | BSD-style (Slicer Licence Part B) | Segment Editor; airway extensions below; **core "Extract Skeleton"** module | Current tag **v5.12.4**; site last updated 2026-11-13 | <https://slicer.readthedocs.io/en/latest/user_guide/about.html#license> |
| **Slicer `AirwaySegmentation`** ext | **no licence file in repo** | region-growing + auto threshold, one seed point in trachea | created 2015, last push **2024-06-17**, 12 stars; still in ExtensionsIndex | <https://github.com/Slicer/SlicerAirwaySegmentation> |
| **SlicerCIP** (Chest Imaging Platform) | BSD-3-Clause | `SegmentLungAirways` CLI (improved version of the above) | last push **2022-11-04** (stale-ish) | <https://github.com/Slicer/SlicerCIP> |
| **SlicerLungCTAnalyzer** | Apache-2.0 | grow-cut airway segmentation + lung analysis | last push 2024-10-04 | <https://github.com/rbumm/SlicerLungCTAnalyzer> |
| **SlicerVMTK** | Apache-2.0 | **Extract Centerline** (network extraction + branch splitting), vesselness, level sets | active (push 2026-11-09) | <https://github.com/vmtk/SlicerExtension-VMTK> |
| **SlicerOpenAnatomy** | (PerkLab ext; tier 5) | **the only glTF writer in Slicer** | push 2025-10-08 | <https://github.com/PerkLab/SlicerOpenAnatomy> |
| **SlicerUpperAirwaySegmentator** | Apache-2.0 | upper airway (nasal cavity, pharynx) via NNUNet extension | active 2026-05 | <https://github.com/capenaka/SlicerUpperAirwaySegmentator> |
| **SlicerMedialSkeleton** | — | medial-axis skeleton extraction | in ExtensionsIndex | <https://github.com/JolleyLab/SlicerMedialSkeleton> |
| **TotalSegmentator** | **Apache-2.0** (code + open tasks) | `lung_vessels` → `lung_airways`, `lung_airways_wall`; `total` → `trachea` | **v2.18.0** | <https://github.com/wasserth/TotalSegmentator> |
| **nnU-Net** | **Apache-2.0** | framework; airway weights come from challenge repos | active (push 2026-11-12) | <https://github.com/MIC-DKFZ/nnUNet> |
| **ITK-SNAP** | GPL (assumed; site does not state it plainly) | manual editing, active contour | **4.0** current ("first major release since 2020"), page updated 2025-09-09 | <http://www.itksnap.org/> |
| **MITK** | BSD-3-Clause | segmentation/registration workbench | active (push 2026-11-14) | <https://github.com/MITK/MITK> |
| **Seg3D** | **no licence file in repo** | voxel editing | active (push 2026-01-15) | <https://github.com/SCIInstitute/Seg3D> |
| **VMTK** | BSD | centreline/network extraction, tube meshing | active (push 2026-09-28) | <https://github.com/vmtk/vmtk> |
| **SimVascular** | BSD | centreline, lofted surface construction | active (push 2026-06-10) | <https://github.com/SimVascular/SimVascular> |
| **CGAL** | LGPL/GPL dual (docs claim; site 403, not re-verified) | skeletonisation (straight skeleton / medial axis) | — | <https://www.cgal.org/> |
| **MeshLab** | GPL-3.0 | decimation, hole filling, normal fixing, UV unwrap | active (push 2026-11-02) | <https://github.com/cnr-isti-vclab/meshlab> |
| **Blender** | GPL (application), glTF exporter GPL | decimation, UV, texture bake, glTF export | current | <https://projects.blender.org/blender/blender/raw/branch/main/COPYING> |

### 3.1 3D Slicer specifics

- **Licence**: BSD-style "Slicer Contribution and Software License Agreement".
  Part B (downloads) grants a royalty-free, sublicensable right to use, reproduce, make
  derivative works, display and distribute — **including incorporation into proprietary
  programs** — provided you keep the notice, mark modified versions, and accept that
  clinical use is not advised. <https://raw.githubusercontent.com/Slicer/Slicer/main/License.txt>
- **Version**: latest tag `v5.12.4` (`v5.12.0…v5.12.4` all present); the download page
  lists 5.12.x installers. <https://github.com/Slicer/Slicer/tags>
- **Airway tools present as extensions today** (ExtensionsIndex entries
  `AirwaySegmentation.json`, `SlicerVMTK.json`, `MedialSkeleton.json`,
  `UpperAirwaySegmentator.json`, `Chest_Imaging_Platform.json`, `LungCTAnalyzer.json`,
  `SlicerOpenAnatomy.json`).
  <https://github.com/Slicer/ExtensionsIndex>
- **AirwaySegmentation** is *not* a deep-learning tool: it is a modified
  `itkConnectedThresholdImageFilter` region grow from a single tracheal seed, with the
  threshold inferred automatically and DICOM convolution kernel taken into account. It
  leaks into lung parenchyma on thin walls and stops at stenosis — good as a fast first
  pass / baseline, not as the production segmenter. Note it **has no licence file**
  (flag for our licence audit).
- **Extract Skeleton** is a core Slicer module
  <https://slicer.readthedocs.io/en/latest/user_guide/modules/extractskeleton.html>;
  **Extract Centerline** (SlicerVMTK) is the better tool — it does network extraction,
  detects/marks non-manifold edges, is "typically 5–20 seconds", and measures
  cross-sections. <https://github.com/vmtk/SlicerExtension-VMTK>
- **glTF**: Slicer's data-loading docs list "SlicerOpenAnatomy extension: GL Transmission
  Format (.glTF, **writing only**)". So glTF/GLB export is *not* in Slicer core; either
  install that tier-5 extension or route through Blender.
  <https://slicer.readthedocs.io/en/latest/user_guide/data_loading_and_saving.html>

### 3.2 TotalSegmentator — licence detail (this changed, and it matters)

- Current version **2.18.0**; `LICENSE` file is Apache 2.0; PyPI metadata says
  "Apache 2.0" for 1.5.7, 2.0.0 and 2.11.0 alike *(checked)*.
- The README, however, now **tiers the tasks**:
  - *"Openly available for any usage (Apache-2.0 license)"*: `total` (117 classes),
    `total_mr`, **`lung_vessels`**, **`lung_vessels_LEGACY`**.
  - Everything else: *"Available with a license (free licenses available for
    non-commercial usage… For a commercial license contact…)"*, and `brain_aneurysm` is
    CC BY-NC 4.0 with no commercial option.
  <https://github.com/wasserth/TotalSegmentator>
- Airway-relevant classes *(from `totalsegmentator/map_to_binary.py`)*: `total` includes
  **`trachea`** (id 43); `lung_vessels` adds **`lung_airways`** and **`lung_airways_wall`**;
  `lung_vessels_LEGACY` has `lung_trachea_bronchia`.
- Weights provenance: `lung_vessels` is partly based on the *Scientific Data* dataset
  "A Custom Annotated Dataset for Segmentation of Pulmonary Veins, Arteries, and Airways"
  (open access, published 2025-11-18) <https://www.nature.com/articles/s41597-025-06074-6>
  and arXiv 2404.03010.
- Compute: runs on **CPU or GPU** (Ubuntu/Mac/Windows); the README's timing guidance is
  ~30 s on GPU / ~70 s on CPU at reduced resolution for a large CT, and recommends
  `--fast` or `--roi_subset` on CPU, `--device cpu|gpu|gpu:X` to choose. Exact GPU memory
  table is in the README "Requirements" section — read it before provisioning.
- **Takeaway**: our airway path (`lung_vessels`) really is Apache-2.0, so masks *and*
  derived meshes can be redistributed. But the *licence of the version installed* should be
  pinned in `tools/ct_pipeline/` (record `totalseg_info --list-tasks` output with a hash),
  because the tiering means "TotalSegmentator is Apache-2.0" is only true for some tasks.

### 3.3 nnU-Net and airway-specific weights

- nnU-Net itself: **Apache-2.0**, actively developed (push 2026-11-12)
  <https://github.com/MIC-DKFZ/nnUNet>.
- Airway-specific weights: no official nnU-Net airway checkpoint. Third-party options:
  ATM'22 top-5 teams' code (publication required by the challenge rules), `AirRC`
  <https://github.com/b-niu/AirRC> (reimplements the ATM'22 winning approach),
  AeroPath's Raidionics model (MIT repo, weights hosted with the dataset), and
  `SlicerUpperAirwaySegmentator` for the *upper* airway (nasal cavity/pharynx — useful
  because VR bronchoscopy starts at the nose/mouth).
- Cautions: third-party weights inherit *their* training data's licence (usually ATM'22 →
  non-redistributable), so treat those checkpoints as tools, not as shippable assets.

### 3.4 Centreline / skeleton tooling

- **SlicerVMTK Extract Centerline** — best-in-class for a segmented tree: quick network
  extraction or accurate branch-by-branch computation between endpoints, marks
  non-manifold mesh errors, outputs centreline + radius, then "Cross-Section Analysis" for
  per-branch area. This is the shortest route from `airway mask` to our `airway_tree` graph.
- **Slicer core Extract Skeleton** — thin-plate/medial skeletons from a label map; no
  branching semantics, needs pruning.
- **VMTK CLI** (`vmtknetworkextraction`, `vmtksurfacereader`) — same algorithms headless,
  BSD licence, good for CI.
- **CGAL** — `CGAL::Straight_skeleton_2` / medial-axis packages; heavy dependency, LGPL/GPL
  dual (verify: cgal.org returned 403 to my fetches).
- **scikit-image** `skeletonize_3d` — simplest, pure-Python, BSD; sufficient for our
  tube-based tree if we add spur pruning and radius from the EDT.

---

## 4. Concrete pipeline: DICOM → Godot-ready glTF

### 4.1 Stage-by-stage

```
0. Provenance gate
   record dataset DOI + licence + SHA-256 of every input; refuse non-redistributable
   datasets (ATM'22) for anything that will be committed.

1. DICOM → volume
   Slicer (headless: `Slicer --no-main-window --python script.py`),
   DICOM module or `dcm2niix`; resample to isotropic ~1 mm (or 0.7 mm for segmental work).

2. Segmentation
   a) TotalSegmentator `lung_vessels` (Apache-2.0)  → lung_airways (+ wall)
      CPU: `TotalSegmentator -i ct.nii.gz -o seg -ta lung_vessels --fast`
      GPU: add `--device gpu:0`
   b) refine in Slicer Segment Editor (Level tracing / Grow from seeds / scissors),
      with `SlicerVMTK` Level Set for leaks.
   c) QC: single connected component, no parenchyma leak, segmental reach ≥ desired depth.

3. Surface extraction
   Slicer: Segment Editor → "Export to files" (or Segmentations module → Export)
   → STL / OBJ / PLY / VTK. Equivalent: `vtkMarchingCubes` or `skimage.measure.marching_cubes`.
   Expect 200 k–1 M triangles at 1 mm — decimation is mandatory at this step.

4. Smoothing
   Slicer "Surface Toolbox" (Laplacian/Taubin, 10–20 iterations),
   or MeshLab "Laplacian Smooth", or Blender Smooth modifier.
   Avoid over-smoothing: < 2 mm radius branches vanish.

5. Decimation
   MeshLab "Quadric Edge Collapse Decimation", Blender Decimate (COLLAPSE, ratio),
   or Slicer "Surface Toolbox → Decimate".
   Budgets: whole tree 35–70 k tris; per-segment 0.4–3 k; ≤ 2 k for collision proxies.

6. Topology repair  (do this *before* decimation if the mesh is open)
   − fill holes (MeshLab "Close Holes", Blender "Fill Holes")
   − remove non-manifold edges/verts (MeshLab "Repair non-manifold", Blender 3D-Print toolbox)
   − unify normals outward (MeshLab "Re-orient all faces coherently")
   − optional: boolean union of BodyParts3D elements into one lumen (Blender Exact Boolean,
     or `manifold`/`trimesh`), then shell-offset inward ~1 mm for wall thickness.

7. UV unwrap
   Blender Smart UV Project (angle limit 66°, island margin 0.02) or MeshLab
   "Parameterization + texture = trivial per-triangle".
   Airways are near-cylinders: cylindrical unwrap per branch gives better texel density
   than a global unwrap.

8. Texturing / baking
   Procedural mucosa (Blender shader: noise + subsurface, pinkish #C98C86 → pale #E8CFC9,
   roughness 0.55, subtle vein rings) → bake base colour + normal + roughness to 2 k or 4 k.
   Bake from a high-poly source if you want micro-detail; otherwise bake procedural only.
   BodyParts3D ships no textures and no UVs, so this step is entirely ours.

9. glTF export
   Blender glTF 2.0 exporter: +Y up, −Z forward (glTF convention), apply modifiers,
   export tangents, "Material: Principled BSDF", textures as PNG/WebP (KTX2/Basis for VR).
   Target: single .glb < 25 MB per case; Draco or meshopt compression optional
   (Godot 4 imports both).

10. Engine import (Godot 4.7, GL Compatibility renderer, per project.godot)
    import as scene; verify winding/normals, disable backface culling only where needed,
    set collision from a decimated proxy (≤ 2 k tris), keep the visual mesh separate.
```

### 4.2 Measured numbers to plan against

- BodyParts3D whole airway tree: 65,240 tris / 38,912 verts *(measured)* → fits a VR
  budget with no decimation; the trachea alone is 4,996 tris.
- A 1 mm marching-cubes surface of the same tree from CT typically lands at 3–10× that;
  assume decimation from ~300 k → 60 k.
- Godot 4 GL Compatibility on a Quest-class device: rule of thumb (engineering guidance,
  not a sourced figure) — keep the *whole* scene (airway + lungs + OR context) under
  ~150 k tris and ≤ 60 draw calls; use one material per organ group with an atlas texture.

### 4.3 Pitfalls (each one has bitten someone)

| Pitfall | Symptom | Mitigation |
| --- | --- | --- |
| **Open surfaces** | camera sees through the wall; collision lets you leave the lumen | detect boundary edges (BodyParts3D has 11,482 of them *(measured)*), then close/union; Blender 3D-Print toolbox "Make Manifold" |
| **Non-manifold edges/verts** | slicer/boolean failures, black shading | MeshLab repair filters; assert `non_manifold_edges == 0` in CI |
| **Inside-out normals** | lumen looks black or lit from inside only | recalc outside; in Godot check with cull_front temporarily |
| **Marching-cubes triangle explosion** | 1 M tris, 5 fps | decimate at extraction time, not at the end; keep a high-poly "master" out of git (LFS or regenerate) |
| **Thin airway walls** | wall thinner than a voxel → holes / leaks | offset the lumen inward rather than segmenting the wall; keep wall ≥ 1.2 mm for VR |
| **Self-intersections at bifurcations** | shading artefacts, failed boolean | voxel remesh (Blender Remesh, 0.4 mm) then decimate — robust, loses sharp carina |
| **Segmental branches vanishing under smoothing** | < 2 mm branches disappear | smooth before decimating, use Taubin (volume-preserving-ish), cap iterations, keep radii ≥ 1.5 mm |
| **No UVs / no textures** (BodyParts3D) | flat untextured look | Smart UV + procedural mucosa bake (§4.1 step 7–8) |
| **Unit/axis mismatch** | anatomy 1000× too big or rotated | BodyParts3D is mm in a whole-body frame; project convention is mm, incisor origin, +X subject-left/+Y superior/+Z anterior → apply one documented rigid transform, keep it in the pipeline script |
| **Licence of derived meshes** | accidental relicensing of restricted data | provenance block per asset + CI check (§5) |

---

## 5. Are CT-derived meshes derivative works? (the licence trap)

Short answer: **treat a mesh segmented from a dataset as a derivative work of that
dataset**, i.e. it inherits the dataset licence. Consequences per source:

- **CC BY 3.0 / CC BY 4.0 datasets (LIDC-IDRI, AeroPath)** — derivative meshes may be
  redistributed, **including commercially**, provided attribution + DOI citation are given
  and modifications indicated. This is explicitly the TCIA position: *"Most data are freely
  available to browse, download, and use for commercial, scientific and educational
  purposes as outlined in the Creative Commons Attribution 3.0 Unported License or the
  Creative Commons Attribution 4.0 International License."*
  <https://www.cancerimagingarchive.net/data-usage-policies-and-restrictions/>
  → Compatible with our MIT repo **as a separately licensed asset pack** with an
  attribution file, plus a note in `docs/`. Attribution must use the dataset's DOI, not the
  web page URL.
- **Restricted / DUA datasets (ATM'22 as written on the challenge site)** — no
  redistribution of data *or* derivatives. Even if the Zenodo metadata says CC BY 4.0,
  shipping would be indefensible. Internal validation only.
- **No-licence datasets (EXACT'09 re-hosts, AirWSeg, CrossAir-1K, BifDet)** — cannot ship.
- **BodyParts3D** — CC BY 4.0 (per licence page) / CC BY-SA 2.1 JP (per file headers). Both
  allow redistribution with attribution; if the SA reading applies, the *mesh asset pack*
  must be distributed under a compatible SA licence (fine for us: MIT code + CC BY-SA 4.0
  assets), and must not be merged into MIT-licensed source files.
- **OpenAnatomy / Slicer-licensed atlas data** — Slicer Part B allows derivatives and
  distribution, requires notice retention and marking of modifications.
- **TotalSegmentator masks** — the *software* is Apache-2.0 and produces masks from *your*
  input; the mask's licence follows the input dataset, not TotalSegmentator. No additional
  restriction from the tool for the `lung_vessels` task.

Machine-checkable policy (suggested for `tools/`): every asset directory carries
`provenance.json` = `{source, doi, licence, licence_url, retrieved, sha256, tool_versions}`,
and CI fails if a shipped mesh has `licence in {proprietary, unknown, cc-by-nc*, "ATM22"}`.

---

## 6. Recommendation

### Use these three (and only these) for shippable anatomy

1. **BodyParts3D (CC BY 4.0, `FMA7393`)** — the base anatomy: trachea, carina, main, lobar
   and all 18 segmental bronchi, 65 k tris, mm units. Ship as a **separate asset pack**
   with `LICENSE-BodyParts3D.txt` (CC BY 4.0 attribution string from the licence page) plus
   a note about the legacy CC BY-SA 2.1 JP file headers. This alone makes the simulator
   anatomically credible without any patient data.
2. **AeroPath (CC BY 4.0, Zenodo 10069289)** — the source of *patient-specific* cases.
   Segment with TotalSegmentator `lung_vessels`, keep provenance, ship 3–5 cases as the
   "real anatomy" tier. Attribution + DOI.
3. **3D Slicer + TotalSegmentator + SlicerVMTK (BSD / Apache-2.0)** — the toolchain. All
   permissive, all Linux-native, all scriptable headless for CI.

Add **Z-Anatomy** only if you want hand-editable Blender anatomy, and **OpenAnatomy's
thoracic atlas** only after the broken download is fixed and the licence/labels are
confirmed.

### Explicitly do not use

Zygote (EULA + no pricing), AnatomyStandard (NC, no meshes), BioDigital, IT'IS ViP,
Sketchfab samples (not downloadable), ATM'22 data in shipped assets (contradictory terms),
EXACT'09 re-hosts (unknown licence).

### Recommended concrete pipeline for the simulator

```
BodyParts3D partof OBJ (95 files, FMA7393)
  → join 95 elements, weld coincident verts (0.01 mm), fill holes, unify normals
  → voxel remesh 0.3 mm (robust boolean-free union)  |  Blender Remesh
  → decimate to 50–60 k tris, keep carina detail (planar decimate on low-curvature areas)
  → cylindrical UV per branch + Smart UV fallback
  → procedural mucosa bake (base colour 2 k + normal 2 k + roughness)
  → glTF 2.0 .glb, +Y up, Draco, < 25 MB
  → Godot 4.7 import; collision proxy 2 k tris; centreline from SlicerVMTK
    "Extract Centerline" on a temporary voxelisation for scope navigation + depth scoring
```

Then, in parallel and reusing the same downstream steps, the CT path from AeroPath:

```
CT → TotalSegmentator lung_vessels → Slicer Segment Editor QC
   → Export to files (STL/OBJ) → Surface Toolbox smooth → decimate
   → same UV/bake/glTF steps → case asset + provenance.json
```

Integration with what already exists: the shipped `assets/anatomy/generic_adult.json`
synthetic tree stays as the deterministic, licence-free default; BodyParts3D becomes the
"realistic geometry" tier; AeroPath cases become the "patient-specific" tier. All three can
share the same `bronchsim.airway_tree/1` schema if the BodyParts3D centreline is exported
with the same `label`/`parent`/`radius_mm`/`depth_mm` fields — the FMA segmental names map
onto `RB1…RB10` / `LB1+2…LB10` cleanly (one mapping table, checked by a clinician).

---

## 7. Uncertain — verify yourself

1. **BodyParts3D licence**: page says CC BY 4.0 (2025-02-27), shipped OBJ headers say
   **CC BY-SA 2.1 JP**. Ask DBCLS which governs; plan for SA until answered.
2. **BodyParts3D quality ceiling**: only the 99 %-reduced mesh survives; the full-resolution
   set (used by Anatomography) is no longer published. If we need finer carinal detail we
   must remesh/refine ourselves. Also: release note admits *"The data may still contain many
   ERRORS to be used as CANONICAL MODEL"*.
3. **BodyParts3D is one adult male**, not a population — no paediatric, no variant anatomy.
4. **AnatomyStandard**: whether a mesh (OBJ/STL) download exists behind a login. The public
   site shows none; even if it exists, CC BY-NC blocks us.
5. **Zygote cost**: no published prices anywhere on zygote.com or zygotebody.com. Any figure
   needs a quote. The zygote.com site looks abandoned (footer "2015") — confirm the company
   still sells poly models.
6. **NIH 3D airway content**: search is client-rendered; I could not query it or its API
   (all endpoint guesses 404). Do a logged-in manual search for "trachea", "bronchi",
   "airway", "lungs" and check each entry's per-model licence.
7. **OpenAnatomy thoracic atlas contents + broken download**: ZIP returns 404, viewer works.
   Whether it contains trachea/bronchi (vs lungs only) is unverified; and the atlas is one
   38-year-old male from a single CT.
8. **Slicer Sample Data licences**: the module docs do not state them; check each dataset's
   original source before deriving anything from `CTChest`.
9. **IT'IS Virtual Population terms**: not public; assumed commercial. Confirm before ruling
   out.
10. **AVIEW**: I could not verify any airway dataset by that name. PubMed's five
    "AVIEW + airway" hits are quantitative-CT *software* papers, and no dataset/repo is
    named AVIEW. **Treat "AVIEW dataset" as unconfirmed** — ask whoever named it for a URL.
11. **EXACT'09 availability/licence**: site up, downloads not exposed; the AirWSeg copies
    have no stated licence. Assume unusable for shipped assets.
12. **ATM'22 licence**: Zenodo says CC BY 4.0, site says redistribution prohibited. Get
    written clarification from the organisers before any use beyond internal evaluation.
13. **ATM'26 dataset terms**: not yet published ("coming soon"); re-check in early 2027.
14. **TotalSegmentator licence history**: PyPI metadata says Apache 2.0 for all versions,
    but the README now tiers tasks behind a licence. The exact version where tiering started
    is not documented in the README I read — pin and record `totalseg_info --list-tasks`
    per release rather than trusting "it's Apache-2.0".
15. **ITK-SNAP licence**: I could not retrieve an explicit licence statement from itksnap.org
    (the "License" wiki page does not exist). Widely believed GPL-2.0; verify from the
    SourceForge/GitLab tree before depending on it in a GPL-sensitive context.
16. **Seg3D and Slicer `AirwaySegmentation` licences**: neither repo contains a licence file.
    Do not redistribute their binaries; we only *use* them locally, so this is low risk.
17. **CGAL licence**: cgal.org returned 403 to my fetches; LGPL-3.0+/GPL dual is the
    documented position but unverified here.
18. **Bronchoscopy video datasets** (BronchoPose, BronchoLumen, BREATH-VL): papers exist,
    licences/dataset access not verified — ATM'26 Track 3 is the one to watch.
19. **"asklepieion / Open3DModel medical sets"**: could not verify either as a real licensed
    medical-mesh source. Treat as unconfirmed.
20. **Commercial use of CC BY assets**: CC BY 4.0 permits commercial use; CC BY-SA requires
    the *asset* (and adaptations) to stay SA. This is a scoping reading, not legal advice —
    get a lawyer's sign-off before any paid deployment.

---

## Appendix — verification log (2026-11-15)

Commands/requests actually executed, for reproducibility:

- `curl -sSIL https://dbarchive.biosciencedbc.jp/data/bodyparts3d/LATEST/partof_BP3D_4.0_obj_99.zip`
  → `HTTP/1.1 200 OK`, `Content-Length: 64888505`, `Last-Modified: Wed, 22 May 2013`.
- Downloaded + unzipped `partof_BP3D_4.0_obj_99.zip`; parsed `partof_element_parts.txt`;
  counted verts/tris per FMA concept; counted boundary/non-manifold edges per file;
  measured trachea cross-sections; rendered orthographic views (front/side/top) and
  visually confirmed carina + lobar/segmental branching.
- `curl https://zenodo.org/api/records/10069289` → AeroPath, `license cc-by-4.0`, 5.04 GB.
- `curl https://zenodo.org/api/records/6590745` → ATM'22 TrainBatch1, `license cc-by-4.0`,
  32.28 GB; plus records 7949582, 6590774, 7949571, 6590026, 6362170.
- `curl https://services.cancerimagingarchive.net/nbia-api/services/v1/getCollectionValues`
  → 156 collections, none airway/bronchoscopy; TCIA site search "tracheobronchial" and
  "bronchoscopy" → "Sorry, no results were found."
- `curl https://api.github.com/repos/...` for licences and last-push dates of Slicer,
  SlicerAirwaySegmentation, SlicerCIP, SlicerLungCTAnalyzer, SlicerVMTK, SlicerOpenAnatomy,
  TotalSegmentator, nnU-Net, MITK, Seg3D, VMTK, SimVascular, MeshLab, Z-Anatomy.
- `curl https://api.sketchfab.com/v3/models/<uid>` → bronchial models `isDownloadable:false`.
- `curl -sSI https://www.openanatomy.org/atlases/macbioidi/mauritania/thorax-2020-11-15.zip`
  → `HTTP/2 404`; viewer URL → 200.
- `curl https://slicer.readthedocs.io/en/latest/user_guide/data_loading_and_saving.html`
  → glTF writing only via SlicerOpenAnatomy extension.
