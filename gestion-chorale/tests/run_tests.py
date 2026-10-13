"""Execute des macros VBA d'un .xlsm sous LibreOffice et affiche les lignes
TEST du JOURNAL. Usage : python3 run_tests.py fichier.xlsm Module.Macro [...]"""
import os, subprocess, sys, time, uno
from com.sun.star.beans import PropertyValue

def prop(n, v):
    p = PropertyValue(); p.Name = n; p.Value = v; return p

path = os.path.abspath(sys.argv[1]); macros = sys.argv[2:]
port = 2100 + os.getpid() % 500
proc = subprocess.Popen(["soffice", "--headless", "--norestore", "--nologo",
    "-env:UserInstallation=file:///tmp/claude-0/lo_profile",
    "--accept=socket,host=localhost,port=%d;urp;" % port], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
local = uno.getComponentContext()
res = local.ServiceManager.createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", local)
for _ in range(80):
    try:
        ctx = res.resolve("uno:socket,host=localhost,port=%d;urp;StarOffice.ComponentContext" % port); break
    except Exception:
        time.sleep(0.5)
desktop = ctx.ServiceManager.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)
doc = desktop.loadComponentFromURL(uno.systemPathToFileUrl(path), "_blank", 0,
                                   (prop("Hidden", os.environ.get("LO_HIDDEN") == "1"), prop("MacroExecutionMode", 4)))
try:
    sp = doc.getScriptProvider()
    for m in macros:
        t0 = time.time()
        try:
            sp.getScript("vnd.sun.star.script:VBAProject.%s?language=Basic&location=document" % m).invoke((), (), ())
            print("RUN", m, "%.1fs" % (time.time() - t0))
        except Exception as e:
            print("ERR", m, str(e)[:600])
    j = doc.Sheets.getByName("JOURNAL")
    r = 4
    while True:
        a = j.getCellByPosition(4, r).getString()
        if not a and not j.getCellByPosition(0, r).getString():
            break
        if a in ("TEST", "Erreur") or os.environ.get("ALLJ"):
            print("  ", a, "|", j.getCellByPosition(5, r).getString())
        r += 1
    if os.environ.get("SAVE_AS"):
        doc.storeToURL(uno.systemPathToFileUrl(os.environ["SAVE_AS"]), (prop("FilterName", "Calc MS Excel 2007 VBA XML"),))
finally:
    doc.close(True)
    try: desktop.terminate()
    except Exception: pass
    proc.wait(timeout=30)
