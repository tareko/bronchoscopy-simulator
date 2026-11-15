#!/usr/bin/env python3
"""Generate the default "generic adult" bronchial tree for the simulator.

The output is a graph of airway segments: each node carries a clinically
recognisable label (RUL, RB1, LB4, ...), a 3D centreline position, an inner
lumen radius and its insertion depth from the incisors.  The engine uses the
graph for three things:

  * procedural tube geometry (see src/anatomy/airway_mesh_builder.gd),
  * collision / lumen clamping for the flexible scope,
  * scoring (which bronchopulmonary segments were inspected).

Dimensions are typical adult values assembled from published bronchoscopic and
CT morphometry; they are illustrative, not patient data.  Every value is
overridable so that CT-derived trees can replace this one wholesale.

Axis convention (millimetres, matches the Godot scene):
  +X = subject's left, +Y = superior, +Z = anterior.
The scope enters at the incisors (origin) and travels down -Y.

Usage:
    python3 tools/gen_anatomy/generate_generic_tree.py \\
        --out assets/anatomy/generic_adult.json
"""

from __future__ import annotations

import argparse
import json
import math
import random
from dataclasses import dataclass, field
from pathlib import Path

Vec3 = tuple[float, float, float]

# --------------------------------------------------------------------------
# Vector helpers (kept dependency-free so the tool runs anywhere)
# --------------------------------------------------------------------------


def v_add(a: Vec3, b: Vec3) -> Vec3:
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def v_mul(a: Vec3, s: float) -> Vec3:
    return (a[0] * s, a[1] * s, a[2] * s)


def v_dot(a: Vec3, b: Vec3) -> float:
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def v_cross(a: Vec3, b: Vec3) -> Vec3:
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def v_len(a: Vec3) -> float:
    return math.sqrt(v_dot(a, a))


def v_norm(a: Vec3) -> Vec3:
    n = v_len(a)
    if n < 1e-9:
        return (0.0, -1.0, 0.0)
    return (a[0] / n, a[1] / n, a[2] / n)


def v_rotate(v: Vec3, axis: Vec3, degrees: float) -> Vec3:
    """Rodrigues rotation of v around a unit axis."""
    theta = math.radians(degrees)
    k = v_norm(axis)
    c, s = math.cos(theta), math.sin(theta)
    return v_add(
        v_add(v_mul(v, c), v_mul(v_cross(k, v), s)),
        v_mul(k, v_dot(k, v) * (1.0 - c)),
    )


def lateral_basis(direction: Vec3) -> tuple[Vec3, Vec3]:
    """Subject-left and anterior unit vectors orthogonal to `direction`.

    For the default downward direction this returns exactly (+X, +Z), which is
    what makes the human-readable `twist` angles below work.
    """
    d = v_norm(direction)
    helper = (0.0, 0.0, 1.0) if abs(d[2]) < 0.9 else (1.0, 0.0, 0.0)
    left = v_norm(v_cross(helper, d))
    anterior = v_norm(v_cross(d, left))
    return left, anterior


# --------------------------------------------------------------------------
# Airway topology
# --------------------------------------------------------------------------
# `twist`: 0 = bend toward subject's left, 90 = anterior, 180 = right,
#          270 = posterior.
# `bend` : deviation from the parent's direction, degrees.
# `length`, `diam`: centreline length and lumen diameter at the segment mouth, mm.
#
# Depths are anchored so that the carina lands near 25 cm from the incisors,
# which is the number clinicians actually use.

ENTRY_LENGTH = 130.0


@dataclass
class Branch:
    label: str
    name: str
    length: float
    diam: float
    bend: float = 0.0
    twist: float = 0.0
    level: str = "segmental"
    children: list["Branch"] = field(default_factory=list)
    subsegments: int = 0
    scored: bool = True


def lobar(label: str, name: str, **kw) -> Branch:
    kw.setdefault("level", "lobar")
    return Branch(label, name, **kw)


def segment(label: str, name: str, **kw) -> Branch:
    kw.setdefault("level", "segmental")
    kw.setdefault("subsegments", 3)
    return Branch(label, name, **kw)


TREE = Branch(
    label="ENTRY",
    name="Oral route (incisors to vocal cords)",
    length=ENTRY_LENGTH,
    diam=20.0,
    level="route",
    scored=False,
    children=[
        Branch(
            label="TRACH",
            name="Trachea",
            length=115.0,
            diam=17.0,
            level="conducting",
            scored=False,
            children=[
                # ---------------- Right lung ----------------
                Branch(
                    label="RMB",
                    name="Right main bronchus",
                    length=22.0,
                    diam=14.0,
                    bend=28.0,
                    twist=200.0,
                    level="lobar",
                    children=[
                        lobar(
                            "RUL",
                            "Right upper lobe bronchus",
                            length=11.0,
                            diam=10.5,
                            bend=62.0,
                            twist=165.0,
                            children=[
                                segment("RB1", "Apical segment, right upper lobe",
                                        length=22.0, diam=6.5, bend=38.0, twist=195.0),
                                segment("RB2", "Posterior segment, right upper lobe",
                                        length=24.0, diam=6.5, bend=40.0, twist=250.0),
                                segment("RB3", "Anterior segment, right upper lobe",
                                        length=22.0, diam=6.0, bend=34.0, twist=110.0),
                            ],
                        ),
                        Branch(
                            label="BI",
                            name="Bronchus intermedius",
                            length=18.0,
                            diam=12.0,
                            bend=8.0,
                            twist=185.0,
                            level="conducting",
                            scored=False,
                            children=[
                                lobar(
                                    "RML",
                                    "Right middle lobe bronchus",
                                    length=14.0,
                                    diam=9.0,
                                    bend=55.0,
                                    twist=140.0,
                                    children=[
                                        segment("RB4", "Lateral segment, right middle lobe",
                                                length=16.0, diam=6.0, bend=30.0, twist=160.0),
                                        segment("RB5", "Medial segment, right middle lobe",
                                                length=16.0, diam=6.0, bend=42.0, twist=100.0),
                                    ],
                                ),
                                Branch(
                                    label="RLL",
                                    name="Right lower lobe bronchus",
                                    length=8.0,
                                    diam=10.5,
                                    bend=30.0,
                                    twist=215.0,
                                    level="lobar",
                                    children=[
                                        segment("RB6", "Superior (apical) segment, right lower lobe",
                                                length=16.0, diam=6.5, bend=44.0, twist=255.0),
                                        Branch(
                                            label="RB_TRUNK",
                                            name="Right basal trunk",
                                            length=14.0,
                                            diam=9.0,
                                            bend=12.0,
                                            twist=210.0,
                                            level="conducting",
                                            scored=False,
                                            children=[
                                                segment("RB7", "Medial basal segment",
                                                        length=15.0, diam=5.5, bend=30.0, twist=140.0),
                                                segment("RB8", "Anterior basal segment",
                                                        length=16.0, diam=6.0, bend=26.0, twist=150.0),
                                                segment("RB9", "Lateral basal segment",
                                                        length=16.0, diam=6.0, bend=34.0, twist=210.0),
                                                segment("RB10", "Posterior basal segment",
                                                        length=16.0, diam=6.5, bend=30.0, twist=280.0),
                                            ],
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ],
                ),
                # ---------------- Left lung ----------------
                Branch(
                    label="LMB",
                    name="Left main bronchus",
                    length=42.0,
                    diam=12.0,
                    bend=30.0,
                    twist=15.0,
                    level="lobar",
                    children=[
                        lobar(
                            "LUL",
                            "Left upper lobe bronchus",
                            length=13.0,
                            diam=10.0,
                            bend=58.0,
                            twist=30.0,
                            children=[
                                segment("LB1+2", "Apicoposterior segment, left upper lobe",
                                        length=22.0, diam=7.0, bend=40.0, twist=60.0),
                                segment("LB3", "Anterior segment, left upper lobe",
                                        length=21.0, diam=6.0, bend=35.0, twist=85.0),
                            ],
                        ),
                        lobar(
                            "LING",
                            "Lingular bronchus",
                            length=10.0,
                            diam=8.0,
                            bend=45.0,
                            twist=70.0,
                            children=[
                                segment("LB4", "Superior lingular segment",
                                        length=16.0, diam=5.5, bend=34.0, twist=85.0),
                                segment("LB5", "Inferior lingular segment",
                                        length=16.0, diam=5.5, bend=42.0, twist=55.0),
                            ],
                        ),
                        Branch(
                            label="LLL",
                            name="Left lower lobe bronchus",
                            length=10.0,
                            diam=10.0,
                            bend=34.0,
                            twist=330.0,
                            level="lobar",
                            children=[
                                segment("LB6", "Superior (apical) segment, left lower lobe",
                                        length=17.0, diam=6.5, bend=46.0, twist=300.0),
                                Branch(
                                    label="LB_TRUNK",
                                    name="Left basal trunk",
                                    length=14.0,
                                    diam=8.5,
                                    bend=14.0,
                                    twist=330.0,
                                    level="conducting",
                                    scored=False,
                                    children=[
                                        # B7 does not normally exist on the left;
                                        # B8 is the anteromedial basal segment.
                                        segment("LB8", "Anteromedial basal segment",
                                                length=16.0, diam=6.0, bend=26.0, twist=60.0),
                                        segment("LB9", "Lateral basal segment",
                                                length=16.0, diam=6.0, bend=36.0, twist=340.0),
                                        segment("LB10", "Posterior basal segment",
                                                length=16.0, diam=6.5, bend=32.0, twist=290.0),
                                    ],
                                ),
                            ],
                        ),
                    ],
                ),
            ],
        ),
    ],
)

# A few named landmarks used by briefings and debriefs.
LANDMARKS = {
    "ENTRY": "incisors",
    "TRACH": "vocal_cords",
    "RMB": "main_carina",
}


def bend_axis(parent_dir: Vec3, twist_deg: float) -> Vec3:
    """Rotation axis that turns `parent_dir` toward the requested compass point.

    With left = +X and anterior = +Z, rotating the downward direction around
    +Z moves it toward +X (left), and rotating around -X moves it toward +Z
    (anterior).  Hence the axis is anterior*cos(twist) - left*sin(twist).
    """
    left, anterior = lateral_basis(parent_dir)
    t = math.radians(twist_deg)
    return v_norm(v_add(v_mul(anterior, math.cos(t)), v_mul(left, -math.sin(t))))


def walk(branch: Branch, parent_pos: Vec3, parent_dir: Vec3, depth: float,
         parent_label: str | None, rng: random.Random, out: list[dict],
         path: list[str]) -> None:
    direction = parent_dir
    if branch.bend > 0.0:
        direction = v_norm(v_rotate(parent_dir, bend_axis(parent_dir, branch.twist), branch.bend))

    end = v_add(parent_pos, v_mul(direction, branch.length))
    here = depth + branch.length
    out.append(
        {
            "id": branch.label,
            "label": branch.label,
            "name": branch.name,
            "level": branch.level,
            "parent": parent_label,
            "start_mm": [round(c, 2) for c in parent_pos],
            "position_mm": [round(c, 2) for c in end],
            "direction": [round(c, 4) for c in direction],
            "length_mm": round(branch.length, 2),
            "radius_mm": round(branch.diam / 2.0, 2),
            "depth_mm": round(here, 1),
            "scored": branch.scored,
            "landmark": LANDMARKS.get(branch.label),
            "path": path + [branch.label],
        }
    )

    for child in branch.children:
        walk(child, end, direction, here, branch.label, rng, out, path + [branch.label])

    # Procedurally fan out subsegmental branches so the periphery looks
    # plausible and peripheral lesions have somewhere to live.  These are
    # never scored and can be dropped for low-end builds.
    if branch.subsegments:
        left, anterior = lateral_basis(direction)
        base_r = branch.diam / 2.0
        for i in range(branch.subsegments):
            ang = (360.0 / branch.subsegments) * i + rng.uniform(-18.0, 18.0)
            axis = v_norm(v_add(v_mul(left, math.cos(math.radians(ang))),
                                v_mul(anterior, math.sin(math.radians(ang)))))
            sub_dir = v_norm(v_rotate(direction, axis, rng.uniform(18.0, 32.0)))
            sub_len = branch.length * rng.uniform(0.55, 0.8)
            sub_end = v_add(end, v_mul(sub_dir, sub_len))
            sub_label = f"{branch.label}{chr(ord('a') + i)}"
            out.append(
                {
                    "id": sub_label,
                    "label": sub_label,
                    "name": f"Subsegment {sub_label}",
                    "level": "subsegmental",
                    "parent": branch.label,
                    "start_mm": [round(c, 2) for c in end],
                    "position_mm": [round(c, 2) for c in sub_end],
                    "direction": [round(c, 4) for c in sub_dir],
                    "length_mm": round(sub_len, 2),
                    "radius_mm": round(base_r * rng.uniform(0.55, 0.7), 2),
                    "depth_mm": round(here + sub_len, 1),
                    "scored": False,
                    "landmark": None,
                    "path": path + [branch.label, sub_label],
                }
            )


def build(seed: int = 20260) -> dict:
    rng = random.Random(seed)
    nodes: list[dict] = []
    walk(TREE, (0.0, 0.0, 0.0), (0.0, -1.0, 0.0), 0.0, None, rng, nodes, [])

    by_id = {n["id"]: n for n in nodes}
    for n in nodes:
        n["path_names"] = [by_id[p]["name"] if p in by_id else p for p in n["path"]]

    return {
        "schema": "bronchsim.airway_tree/1",
        "name": "generic_adult",
        "display_name": "Generic adult airway",
        "units": "mm",
        "axis_convention": "+X subject left, +Y superior, +Z anterior; scope enters at incisors (origin)",
        "generator": "tools/gen_anatomy/generate_generic_tree.py",
        "seed": seed,
        "provenance": {
            "kind": "synthetic",
            "note": (
                "Illustrative adult dimensions assembled from published bronchoscopy and CT "
                "morphometry. Not patient data; no consent required; safe to redistribute."
            ),
        },
        "tree": nodes,
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="assets/anatomy/generic_adult.json")
    ap.add_argument("--seed", type=int, default=20260)
    args = ap.parse_args()

    data = build(args.seed)
    tree = data["tree"]

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(data, indent=1) + "\n", encoding="utf-8")

    scored = [n for n in tree if n["scored"]]
    segmental = [n for n in tree if n["level"] == "segmental"]
    print(f"wrote {out}  nodes={len(tree)}  segmental={len(segmental)}  scored={len(scored)}")
    print("\nInsertion depths (mm from incisors):")
    for label in ("TRACH", "RMB", "RUL", "RML", "RLL", "RB6", "RB10",
                  "LMB", "LUL", "LING", "LLL", "LB6", "LB10"):
        n = next((x for x in tree if x["label"] == label), None)
        if n:
            print(f"  {label:<7} {n['depth_mm']:7.1f}  r={n['radius_mm']:.1f}  {n['name']}")

    assert all(n["depth_mm"] > 0 for n in tree if n["parent"]), "depth must be positive"
    assert max(n["depth_mm"] for n in tree) < 520.0, "tree deeper than a 60 cm scope can reach"
    # Sanity: right-sided branches must sit at +X after the main carina and
    # left-sided ones at -X, otherwise the twist convention is broken.
    for label, want_left in (("RB10", False), ("LB10", True), ("RB6", False), ("LB6", True)):
        n = next(x for x in tree if x["label"] == label)
        x = n["position_mm"][0]
        assert (x > 0) == want_left, f"{label} on wrong side: x={x}"
    print("\nsanity checks passed (laterality, depth, scope reach)")


if __name__ == "__main__":
    main()
