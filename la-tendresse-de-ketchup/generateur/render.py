"""Conversion HTML -> PDF avec Chromium (headless)."""
import os
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build"


def chromium():
    for cand in (os.environ.get("CHROMIUM"), "/opt/pw-browsers/chromium",
                 shutil.which("chromium"), shutil.which("chromium-browser"),
                 shutil.which("google-chrome")):
        if cand and Path(cand).exists():
            return cand
    raise SystemExit("Chromium introuvable : définir la variable CHROMIUM.")


def to_pdf(html, out_pdf):
    out_pdf = Path(out_pdf)
    out_pdf.parent.mkdir(parents=True, exist_ok=True)
    src = BUILD / "html" / out_pdf.relative_to(ROOT).with_suffix(".html")
    src.parent.mkdir(parents=True, exist_ok=True)
    src.write_text(html, encoding="utf-8")
    subprocess.run([chromium(), "--headless=new", "--no-sandbox", "--disable-gpu",
                    "--no-pdf-header-footer", "--virtual-time-budget=4000",
                    f"--print-to-pdf={out_pdf}", src.as_uri()],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return out_pdf
