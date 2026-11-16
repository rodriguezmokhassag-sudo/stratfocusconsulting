"""Captures d'ecran des feuilles (PNG) pour le guide, via LibreOffice.
Usage : python3 tests/captures.py classeur.xlsm dossier FEUILLE[:lignes[:colonnes]] ...
Sans nombre de lignes, la zone d'impression du classeur est conservee (graphiques compris)."""
import os, subprocess, sys, tempfile, time, uno
from com.sun.star.beans import PropertyValue


def prop(n, v):
    p = PropertyValue(); p.Name = n; p.Value = v; return p


def rogner(path, marge=14):
    """Retire le blanc autour du contenu."""
    from PIL import Image, ImageChops
    im = Image.open(path).convert("RGB")
    fond = Image.new("RGB", im.size, (255, 255, 255))
    box = ImageChops.difference(im, fond).getbbox()
    if box:
        l, t, r, b = box
        im.crop((max(l - marge, 0), max(t - marge, 0), min(r + marge, im.width), min(b + marge, im.height))).save(path, optimize=True)


src, outdir, specs = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2]), sys.argv[3:]
os.makedirs(outdir, exist_ok=True)
port = 2700 + os.getpid() % 200
proc = subprocess.Popen(["soffice", "--headless", "--norestore", "-env:UserInstallation=file:///tmp/claude-0/lo_profile3",
                         "--accept=socket,host=localhost,port=%d;urp;" % port], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
local = uno.getComponentContext()
res = local.ServiceManager.createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", local)
for _ in range(80):
    try:
        ctx = res.resolve("uno:socket,host=localhost,port=%d;urp;StarOffice.ComponentContext" % port); break
    except Exception:
        time.sleep(0.5)
desk = ctx.ServiceManager.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)
tmp = tempfile.mkdtemp(dir="/tmp/claude-0")
try:
    for spec in specs:
        parts = spec.split(":")
        name = parts[0]
        doc = desk.loadComponentFromURL(uno.systemPathToFileUrl(src), "_blank", 0, (prop("Hidden", True), prop("MacroExecutionMode", 0)))
        sheets = doc.Sheets
        for n in list(sheets.ElementNames):
            if n != name:
                sheets.removeByName(n)
        sh = sheets.getByName(name)
        sh.IsVisible = True
        ps = doc.StyleFamilies.getByName("PageStyles").getByName(sh.PageStyle)
        ps.ScaleToPagesX, ps.ScaleToPagesY = 1, 1
        if len(parts) > 1:
            cur = sh.createCursor(); cur.gotoEndOfUsedArea(False)
            endc = int(parts[2]) - 1 if len(parts) > 2 else cur.RangeAddress.EndColumn
            sh.setPrintAreas((sh.getCellRangeByPosition(0, 0, endc, int(parts[1]) - 1).RangeAddress,))
        pdf = os.path.join(tmp, name + ".pdf")
        doc.storeToURL(uno.systemPathToFileUrl(pdf), (prop("FilterName", "calc_pdf_Export"),))
        doc.close(True)
        png = os.path.join(outdir, name.lower())
        subprocess.run(["pdftoppm", "-r", "110", "-png", "-singlefile", pdf, png], check=True)
        rogner(png + ".png")
        print("OK", name)
finally:
    desk.terminate(); proc.wait(timeout=30)
