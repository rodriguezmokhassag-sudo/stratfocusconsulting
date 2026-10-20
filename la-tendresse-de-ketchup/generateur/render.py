"""Conversion HTML -> PDF avec Chromium (headless)."""
import base64
import os
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build"
SORTIE = ROOT / "sortie"
HTML_OUT = SORTIE / "6_HTML"
FONTS_URI = (ROOT / "assets" / "fonts").as_uri()


def portable(html):
    """Intègre les polices en base64 pour que le HTML s'ouvre partout, sans dossier annexe."""
    def data_uri(m):
        data = (ROOT / "assets" / "fonts" / m.group(1)).read_bytes()
        return "url('data:font/ttf;base64," + base64.b64encode(data).decode() + "')"
    return re.sub(r"url\('" + re.escape(FONTS_URI) + r"/([\w.-]+\.ttf)'\)", data_uri, html)


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
    try:
        rel = out_pdf.relative_to(SORTIE)
    except ValueError:
        rel = None
    if rel is not None and not rel.parts[0].startswith(("3_", "6_")):
        dst = HTML_OUT / rel.with_suffix(".html")
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(portable(html), encoding="utf-8")
    subprocess.run([chromium(), "--headless=new", "--no-sandbox", "--disable-gpu",
                    "--no-pdf-header-footer", "--virtual-time-budget=4000",
                    f"--print-to-pdf={out_pdf}", src.as_uri()],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return out_pdf
