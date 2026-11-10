"""Merge the raw Roboflow datasets into two YOLO datasets with unified classes.

    data/chars/    classes 0-9 . -    (YOLO 2: characters)
    data/display/  class display      (YOLO 1: numeric reading region)

Usage:
    .venv/bin/python data/unify.py
Rules:
  - each source class maps to a unified class or to None (box dropped)
  - polygon labels are converted to their bounding box
  - images left with no boxes are skipped (they show digits that weren't annotated)
  - exact duplicate images (same 32x32 grayscale thumbnail) are kept only once
  - original train/valid/test splits are kept
"""
import hashlib
import os
import shutil
from collections import Counter, defaultdict
from pathlib import Path

import yaml
from PIL import Image

DATA = Path(__file__).resolve().parent
RAW = DATA / "raw"
SPLITS = ("train", "valid", "test")
DIGITS = [str(d) for d in range(10)]

TASKS = {
    "chars": {
        "classes": DIGITS + [".", "-"],
        "sources": {
            # units (A, AC, DC, V, mA, mV, uA) are out of scope
            "multimeter_digits": {**{d: d for d in DIGITS}, ".": ".", "-": "-"},
            # '+' is not used by multimeters
            "mba_7seg": {**{d: d for d in DIGITS}, ".": ".", "-": "-"},
            "reynier_7seg": {**{d: d for d in DIGITS}, "dot": "."},
        },
    },
    "display": {
        "classes": ["display"],
        "sources": {
            # every class is a whole reading ("212.9", "-0.8", ...)
            "digits_multimeter": "display",
            # RoI = one line of digits; the digit boxes are dropped
            "sevenseg_roi": {"RoI": "display"},
        },
    },
}


def image_key(path):
    thumb = Image.open(path).convert("L").resize((32, 32))
    return hashlib.md5(thumb.tobytes()).hexdigest()


def to_bbox(values):
    """YOLO box or polygon (normalized) -> (cx, cy, w, h)."""
    if len(values) == 4:
        return values
    xs, ys = values[0::2], values[1::2]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    return (x0 + x1) / 2, (y0 + y1) / 2, x1 - x0, y1 - y0


def convert(label_path, src_names, mapping, dst_index):
    lines = []
    for line in label_path.read_text().splitlines():
        v = line.split()
        if not v:
            continue
        name = src_names[int(v[0])]
        target = mapping if isinstance(mapping, str) else mapping.get(name)
        if target is None:
            continue
        cx, cy, w, h = to_bbox([float(x) for x in v[1:]])
        lines.append(f"{dst_index[target]} {cx:.6f} {cy:.6f} {w:.6f} {h:.6f}")
    return lines


def build(task, spec):
    out = DATA / task
    if out.exists():
        shutil.rmtree(out)
    classes = spec["classes"]
    dst_index = {c: i for i, c in enumerate(classes)}
    seen = {}
    images = defaultdict(Counter)       # split -> source -> n images
    boxes = defaultdict(Counter)        # source -> class -> n boxes
    skipped = Counter()                 # reason -> n

    for src, mapping in spec["sources"].items():
        src_names = yaml.safe_load(open(RAW / src / "data.yaml"))["names"]
        for split in SPLITS:
            img_dir = RAW / src / split / "images"
            if not img_dir.exists():
                continue
            (out / split / "images").mkdir(parents=True, exist_ok=True)
            (out / split / "labels").mkdir(parents=True, exist_ok=True)
            for img in sorted(img_dir.iterdir()):
                lab = RAW / src / split / "labels" / (img.stem + ".txt")
                lines = convert(lab, src_names, mapping, dst_index) if lab.exists() else []
                if not lines:
                    skipped["no boxes"] += 1
                    continue
                key = image_key(img)
                if key in seen:
                    skipped["duplicate"] += 1
                    continue
                seen[key] = f"{src}/{split}/{img.name}"
                stem = f"{src}__{img.stem}"
                dst = out / split / "images" / (stem + img.suffix)
                os.link(img, dst)
                (out / split / "labels" / (stem + ".txt")).write_text("\n".join(lines) + "\n")
                images[split][src] += 1
                for ln in lines:
                    boxes[src][classes[int(ln.split()[0])]] += 1

    yaml.safe_dump({"path": str(out), "train": "train/images", "val": "valid/images",
                    "test": "test/images", "names": dict(enumerate(classes))},
                   open(out / "data.yaml", "w"), sort_keys=False, allow_unicode=True)

    print(f"\n=== {task}: {len(seen)} images -> {out}")
    for split in SPLITS:
        print(f"  {split:5s} {sum(images[split].values()):5d}  {dict(images[split])}")
    print(f"  skipped: {dict(skipped)}")
    print("  boxes per class:")
    srcs = list(spec["sources"])
    print("    " + "class".ljust(8) + "".join(s[:18].rjust(20) for s in srcs) + "total".rjust(8))
    for c in classes:
        row = [boxes[s][c] for s in srcs]
        print("    " + c.ljust(8) + "".join(str(n).rjust(20) for n in row) + str(sum(row)).rjust(8))


def main():
    for task, spec in TASKS.items():
        build(task, spec)


if __name__ == "__main__":
    main()
