"""Verifie que chaque module VBA compile sous LibreOffice (outil de developpement).
Usage : python3 tests/check_compile.py [module ...]   (sans argument : tous)
Pour un module en echec, indique la premiere procedure fautive."""
import glob, os, re, subprocess, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, "build"))
import xlsxwriter  # noqa: E402
from vbaproject import build_vba_project, doc_module_source, std_module_source  # noqa: E402
from build import read_src  # noqa: E402

SKIP = {"modMdpMasque"}  # API Windows, non compilable sous LibreOffice
TMP = tempfile.mkdtemp(prefix="cc_", dir="/tmp/claude-0" if os.path.isdir("/tmp/claude-0") else None)


def compiles(name, code):
    mods = [("ThisWorkbook", "doc", doc_module_source("ThisWorkbook", "workbook", "Option Explicit\r\n")),
            ("shA", "doc", doc_module_source("shA", "sheet", "Option Explicit\r\n")),
            (name, "std", std_module_source(name, code)),
            ("modPing", "std", std_module_source("modPing", 'Public Sub Go()\r\n ThisWorkbook.Sheets(1).Range("A1").Value = "ok"\r\nEnd Sub\r\n'))]
    b = os.path.join(TMP, "p.bin"); x = os.path.join(TMP, "p.xlsm")
    open(b, "wb").write(build_vba_project(mods))
    wb = xlsxwriter.Workbook(x); wb.set_vba_name("ThisWorkbook")
    ws = wb.add_worksheet("ACCUEIL"); ws.set_vba_name("shA"); wb.add_vba_project(b); wb.close()
    out = subprocess.run([sys.executable, os.path.join(HERE, "lo_run.py"), x, "modPing.Go", "ACCUEIL!A1"],
                         capture_output=True, text=True).stdout
    return "'ok'" in out


def split(src):
    header, procs, cur = [], [], None
    for l in src.replace("\r\n", "\n").split("\n"):
        if re.match(r"^(Public |Private )?(Sub|Function) ", l):
            cur = [l]; procs.append(cur)
        elif cur is not None:
            cur.append(l)
            if re.match(r"^End (Sub|Function)", l):
                cur = None
        else:
            header.append(l)
    return header, procs


paths = sorted(glob.glob(os.path.join(ROOT, "src", "vba", "*.bas")))
wanted = set(sys.argv[1:])
for p in paths:
    name = os.path.basename(p)[:-4]
    if name in SKIP or (wanted and name not in wanted):
        continue
    src = read_src(p)
    if compiles(name, src):
        print("OK    ", name)
        continue
    print("ECHEC ", name)
    header, procs = split(src)
    for pr in procs:
        if not compiles(name, "\n".join(header + pr)):
            print("        procedure :", pr[0].strip())
            break
