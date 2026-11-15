#!/usr/bin/env python3
"""Printability gate for the prop STLs.

Checks, per file: watertight (every edge shared by exactly two triangles),
a single connected body, positive volume, and prints dimensions plus an
estimated mass for PETG. Exits non-zero if any part fails.

Usage: python3 validate_stl.py [stl_dir]
"""
from __future__ import annotations

import struct
import sys
from collections import Counter, defaultdict
from pathlib import Path

DENSITY_G_CM3 = 1.27  # PETG


def read_ascii_stl(path: Path):
    tris, current = [], []
    for line in path.read_text(errors="replace").splitlines():
        parts = line.split()
        if parts and parts[0] == "vertex":
            current.append(tuple(float(x) for x in parts[1:4]))
            if len(current) == 3:
                tris.append(current)
                current = []
    return tris


def read_binary_stl(path: Path):
    data = path.read_bytes()
    if data[:5] == b"solid" and b"facet" in data[:400]:
        return read_ascii_stl(path)
    if len(data) < 84:
        raise ValueError("too short")
    count = struct.unpack_from("<I", data, 80)[0]
    if len(data) != 84 + count * 50:
        raise ValueError("not a binary STL (or truncated)")
    tris = []
    off = 84
    for _ in range(count):
        vals = struct.unpack_from("<12fH", data, off)
        off += 50
        v = [(vals[3], vals[4], vals[5]), (vals[6], vals[7], vals[8]), (vals[9], vals[10], vals[11])]
        tris.append(v)
    return tris


def analyse(tris):
    verts = {}
    points = []
    faces = []
    for t in tris:
        idx = []
        for v in t:
            key = (round(v[0], 4), round(v[1], 4), round(v[2], 4))
            if key not in verts:
                verts[key] = len(points)
                points.append(key)
            idx.append(verts[key])
        if len(set(idx)) == 3:      # drop degenerate triangles
            faces.append(tuple(idx))

    edge_use = Counter()
    edge_to_faces = defaultdict(list)
    for fi, (a, b, c) in enumerate(faces):
        for e in ((a, b), (b, c), (c, a)):
            key = tuple(sorted(e))
            edge_use[key] += 1
            edge_to_faces[key].append(fi)
    non_manifold = sum(1 for n in edge_use.values() if n != 2)

    # connected components across shared edges
    adj = defaultdict(set)
    for face_list in edge_to_faces.values():
        for i in range(len(face_list)):
            for j in range(i + 1, len(face_list)):
                adj[face_list[i]].add(face_list[j])
                adj[face_list[j]].add(face_list[i])
    def signed_volume(face_list):
        vol = 0.0
        for a, b, c in face_list:
            pa, pb, pc = points[a], points[b], points[c]
            vol += (pa[0] * (pb[1] * pc[2] - pb[2] * pc[1])
                    - pa[1] * (pb[0] * pc[2] - pb[2] * pc[0])
                    + pa[2] * (pb[0] * pc[1] - pb[1] * pc[0])) / 6.0
        return vol

    # Label each connected shell. Positive volume = solid, negative = an
    # internal void (a blind hole's inner surface). Only solids count as bodies.
    shells = []
    seen_shell = set()
    for start in range(len(faces)):
        if start in seen_shell:
            continue
        stack, comp = [start], []
        while stack:
            f = stack.pop()
            if f in seen_shell:
                continue
            seen_shell.add(f)
            comp.append(f)
            stack.extend(adj[f] - seen_shell)
        shells.append(comp)
    solid_shells = [c for c in shells if signed_volume([faces[i] for i in c]) > 0]
    void_shells = [c for c in shells if signed_volume([faces[i] for i in c]) < 0]
    volume = sum(signed_volume([faces[i] for i in c]) for c in solid_shells)

    xs = [p[0] for p in points]
    ys = [p[1] for p in points]
    zs = [p[2] for p in points]
    bbox = (max(xs) - min(xs), max(ys) - min(ys), max(zs) - min(zs))
    return {
        "triangles": len(faces),
        "vertices": len(points),
        "non_manifold_edges": non_manifold,
        "components": len(solid_shells),
        "voids": len(void_shells),
        "volume_mm3": abs(volume),
        "bbox_mm": bbox,
    }


stl_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "stl")
files = sorted(stl_dir.glob("*.stl"))
if not files:
    sys.exit(f"no STL files in {stl_dir}")

failures = []
print(f"{'part':34} {'tris':>7} {'mm³':>9} {'g':>6}  {'bbox (mm)':<22} status")
print("-" * 96)
for path in files:
    try:
        tris = read_binary_stl(path)
        info = analyse(tris)
    except Exception as exc:  # noqa: BLE001
        failures.append(f"{path.name}: {exc}")
        print(f"{path.name:34} FAILED: {exc}")
        continue

    problems = []
    if info["non_manifold_edges"]:
        problems.append(f"{info['non_manifold_edges']} non-manifold edges")
    if info["components"] != 1:
        problems.append(f"{info['components']} disconnected solid bodies")
    if info["volume_mm3"] <= 1.0:
        problems.append("zero volume")
    grams = info["volume_mm3"] / 1000.0 * DENSITY_G_CM3
    bbox = info["bbox_mm"]
    status = "ok" if not problems else "FAIL: " + "; ".join(problems)
    if problems:
        failures.append(f"{path.name}: {status}")
    voids = f" ({info['voids']} internal void{'s' if info['voids'] != 1 else ''})" if info["voids"] else ""
    print(f"{path.name:34} {info['triangles']:7d} {info['volume_mm3']:9.0f} {grams:6.1f}  "
          f"{bbox[0]:5.1f}x{bbox[1]:5.1f}x{bbox[2]:5.1f}      {status}{voids}")

print()
if failures:
    print("FAILED:")
    for f in failures:
        print("  -", f)
    sys.exit(1)
print("all parts watertight, single-body and printable")
