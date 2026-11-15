# Contributing

Thanks for helping. This is a training tool for a real clinical skill; accuracy
and honesty matter more than features.

## Quick start

```bash
git clone https://github.com/tareko/bronchoscopy-simulator
cd bronchoscopy-simulator
./scripts/run.sh --editor        # Godot 4.7+
godot --headless --path . --script tests/run_tests.gd
```

The test suite needs no addons. If your change touches the scope model, anatomy
or metrics, the suite must stay green — CI runs exactly that command.

## What is most useful

1. **Clinical review.** Read `docs/03-case-catalog.md` and
   `docs/04-scope-model.md` as a bronchoscopist and tell us what is wrong.
   Segment dimensions, depths, nomenclature and case scripts all need expert eyes.
2. **Airway dimensions with citations.** Edit
   `tools/gen_anatomy/generate_generic_tree.py` and cite the source in a comment
   and in the pull request. Do not "improve" numbers from memory.
3. **Case scripts** (JSON + a small runner) for the eight cases.
4. **VR hardware testing** on any OpenXR headset — including "this feels wrong"
   reports, which are the most valuable bug reports we get.
5. **CT pipeline work** (docs/06).

## Ground rules

- **No patient data.** Ever. Not de-identified, not "just a demo". See
  `docs/06-anatomy-pipeline.md`.
- **No unlicensed assets.** Meshes, textures and models must have a licence
  compatible with MIT, or live in a separately-licensed asset pack with clear
  provenance. Check `docs/06`.
- **No invented evidence.** Do not add a citation you have not read, and do not
  describe a metric as "validated" unless it is.
- **Metric changes need a rationale.** DC, SP, PT, AIT and wall contacts are
  defined by published work; changing them silently breaks comparability.
- **Keep it runnable without a headset.** Desktop mode and headless tests are the
  development backbone.

## Code style

- GDScript, static typing where practical (`var x: Vector3 = …`).
- One class per file, `class_name` for engine classes, plain `RefCounted` for
  logic that should be testable without a scene tree.
- Units: millimetres and degrees in the model, metres in the scene
  (`MM_TO_M`), seconds for time.
- Every new engine behaviour gets a test in `tests/run_tests.gd`.

## Pull requests

- One logical change per PR; explain the *clinical* reason, not just the code.
- Say what you tested (desktop only? headset? which model?).
- If you change a metric or a threshold, include before/after numbers from a
  scripted run.

## Reporting problems

Include: commit hash, Godot version, headset/runtime, whether desktop mode also
fails, and the exact command. For scoring complaints, attach a session JSON —
that is the whole point of the export format.

## Code of conduct

Be decent. Clinical disagreements are welcome and expected; personal attacks are
not.
