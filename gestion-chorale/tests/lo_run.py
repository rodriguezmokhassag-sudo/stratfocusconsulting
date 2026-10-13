"""Ouvre un .xlsm dans LibreOffice (headless), execute une macro VBA et
renvoie le contenu de cellules. Usage : python3 lo_run.py fichier Module.Macro [Feuille!A1 ...]"""
import subprocess, sys, time, os, uno
from com.sun.star.beans import PropertyValue

def prop(n, v):
    p = PropertyValue(); p.Name = n; p.Value = v; return p

def main():
    path, macro, cells = os.path.abspath(sys.argv[1]), sys.argv[2], sys.argv[3:]
    port = 2002 + os.getpid() % 500
    proc = subprocess.Popen(["soffice", "--headless", "--norestore", "--nologo",
        "-env:UserInstallation=file:///tmp/claude-0/lo_profile",
        "--accept=socket,host=localhost,port=%d;urp;" % port],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    ctx = None
    local = uno.getComponentContext()
    resolver = local.ServiceManager.createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", local)
    for _ in range(60):
        try:
            ctx = resolver.resolve("uno:socket,host=localhost,port=%d;urp;StarOffice.ComponentContext" % port); break
        except Exception:
            time.sleep(0.5)
    desktop = ctx.ServiceManager.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)
    doc = desktop.loadComponentFromURL(uno.systemPathToFileUrl(path), "_blank", 0,
        (prop("Hidden", os.environ.get("LO_HIDDEN") == "1"), prop("MacroExecutionMode", 4)))
    try:
        sp = doc.getScriptProvider()
        script = sp.getScript("vnd.sun.star.script:VBAProject.%s?language=Basic&location=document" % macro)
        res = script.invoke((), (), ())
        print("RESULT:", res[0])
        for c in cells:
            sh, addr = c.split("!")
            cell = doc.Sheets.getByName(sh).getCellRangeByName(addr)
            print(c, "=", repr(cell.getString()))
    finally:
        doc.close(True)
        try: desktop.terminate()
        except Exception: pass
        proc.wait(timeout=30)

main()
