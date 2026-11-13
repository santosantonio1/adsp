"""Test-split metrics and confusion matrices of runs/<task>/weights/best.pt.

Usage (from tf/):
    .venv/bin/python eval/report.py <name>
Writes results/<name>/<task>_metrics.csv and results/<name>/<task>_confusion_matrix.png.
"""
import csv
import shutil
import sys
from pathlib import Path

from ultralytics import YOLO

TF = Path(__file__).resolve().parent.parent
COLS = ["Class", "Images", "Instances", "Box-P", "Box-R", "mAP50", "mAP50-95"]


def main():
    out = TF / "results" / sys.argv[1]
    out.mkdir(parents=True, exist_ok=True)
    for task in ("display", "chars"):
        model = YOLO(TF / "runs" / task / "weights" / "best.pt")
        data = str(TF / "data" / task / "data.yaml")

        # metrics: val's default conf (0.001), as mAP requires
        m = model.val(data=data, split="test", device="cpu", project=str(out), name="_tmp", exist_ok=True)
        shutil.rmtree(m.save_dir)
        with open(out / f"{task}_metrics.csv", "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(COLS)
            n_images = len(list((TF / "data" / task / "test" / "images").iterdir()))
            w.writerow(["all", n_images, int(m.nt_per_class.sum()), *[round(v, 3) for v in m.box.mean_results()]])
            for row in m.summary(decimals=3):
                w.writerow([row[k] for k in COLS])

        # confusion matrix: conf 0.25, otherwise it is flooded with low-confidence boxes
        m = model.val(data=data, split="test", device="cpu", conf=0.25, project=str(out), name="_tmp", exist_ok=True)
        shutil.copy(Path(m.save_dir) / "confusion_matrix.png", out / f"{task}_confusion_matrix.png")
        shutil.rmtree(m.save_dir)


if __name__ == "__main__":
    main()
