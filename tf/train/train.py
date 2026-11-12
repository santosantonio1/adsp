"""Fine-tune a pretrained YOLO detector on data/display or data/chars.

Usage (from tf/):
    .venv/bin/python train/train.py display
    .venv/bin/python train/train.py chars --model yolo26n.pt --epochs 150
Results go to runs/<task>/ (weights in runs/<task>/weights/best.pt).
"""
import argparse
from pathlib import Path

from ultralytics import YOLO

TF = Path(__file__).resolve().parent.parent


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("task", choices=["display", "chars"])
    ap.add_argument("--model", default="yolo26n.pt")
    ap.add_argument("--epochs", type=int, default=100)
    ap.add_argument("--imgsz", type=int, default=640)
    ap.add_argument("--batch", type=float, default=16, help="16 fits yolo26n in the ~2 GB free on the T1000; -1 = AutoBatch")
    ap.add_argument("--device", default=None, help="e.g. 0 or cpu; default: GPU if available")
    args = ap.parse_args()

    batch = int(args.batch) if args.batch >= 1 else args.batch
    model = YOLO(args.model)
    model.train(
        data=str(TF / "data" / args.task / "data.yaml"),
        epochs=args.epochs,
        imgsz=args.imgsz,
        batch=batch,
        patience=25,
        fliplr=0.0,   # a mirrored digit is a different (or invalid) digit
        project=str(TF / "runs"),
        name=args.task,
        exist_ok=True,
        seed=0,
        device=args.device,
    )
    # final numbers on the held-out test split
    best = YOLO(TF / "runs" / args.task / "weights" / "best.pt")
    best.val(data=str(TF / "data" / args.task / "data.yaml"), split="test",
             project=str(TF / "runs"), name=f"{args.task}_test", exist_ok=True,
             device=args.device)


if __name__ == "__main__":
    main()
