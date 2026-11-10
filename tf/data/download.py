"""Download the selected Roboflow Universe datasets in YOLO format.

Usage (key must be in ROBOFLOW_API_KEY):
    .venv/bin/python data/download.py
Datasets land in data/raw/<name>/.
"""
import os
from pathlib import Path

import roboflow

RAW = Path(__file__).resolve().parent / "raw"

# name: (workspace, project, version)
DATASETS = {
    # characters
    "multimeter_digits": ("taechin-dmqb3", "multimeter-digits-4ougn", 1),
    "mba_7seg": ("mba", "seven-segments-display-digits", 2),
    "reynier_7seg": ("reynier-rodriguez-socarras-wqs34", "seven-segment-digits-5hkzn", 1),
    # display / reading region
    "digits_multimeter": ("jeison-colmenares", "digits-multimeter", 7),
    "sevenseg_roi": ("sevensegment-digits", "seven-segment-digits", 6),
}


def main():
    rf = roboflow.Roboflow(api_key=os.environ["ROBOFLOW_API_KEY"])
    for name, (ws, proj, ver) in DATASETS.items():
        dest = RAW / name
        if (dest / "data.yaml").exists():
            print(f"skip {name}: already in {dest}")
            continue
        rf.workspace(ws).project(proj).version(ver).download("yolov8", location=str(dest))


if __name__ == "__main__":
    main()
