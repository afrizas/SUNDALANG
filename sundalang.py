#!/usr/bin/env python3
import os
import sys
import argparse
import keyword
import builtins

VERSI = "1.1"


class KasalahanSunda(Exception):
    def __init__(self, pesen, baris=None):
        super().__init__(pesen)
        self.pesen = pesen
        self.baris = baris


KECAP_KONCI = {
    "jieun", "citak", "lamun", "atawa_lamun", "lamun_henteu",
    "salila", "pikeun", "ti", "nepi", "lengkah",
    "pagawean", "balik", "eureun", "terus",
    "leres", "lepat", "kosong", "jeung", "atawa", "lain",
}
OP_DUA = ("==", "!=", "<=", ">=", "**", "+=", "-=", "*=", "/=")
OP_SATU = "+-*/%<>=(){}[],"


def lex(src):
    tokens = []
    i, n, baris, kurung = 0, len(src), 1, 0
    while i < n:
        c = src[i]
        if c == "\n":
            if kurung == 0:
                tokens.append(("NL", "\n", baris))
            baris += 1
            i += 1
            continue
        if c in " \t\r":
            i += 1
            continue
        if c == ";":
            tokens.append(("NL", "\n", baris))
            i += 1
            continue
        if c == "#":
            while i < n and src[i] != "\n":
                i += 1
            continue
        if c.isdigit():
            j = i
            while j < n and src[j].isdigit():
                j += 1
            if j + 1 < n and src[j] == "." and src[j + 1].isdigit():
                j += 1
                while j < n and src[j].isdigit():
                    j += 1
                tokens.append(("ANGKA", float(src[i:j]), baris))
            else:
                tokens.append(("ANGKA", int(src[i:j]), baris))
            i = j
            continue
        if c in "\"'":
            q, j, buf = c, i + 1, []
            while j < n and src[j] != q:
                if src[j] == "\n":
                    raise KasalahanSunda("teks acan ditutup (kurang tanda kutip)", baris)
                if src[j] == "\\" and j + 1 < n:
                    j += 1
                    buf.append({"n": "\n", "t": "\t"}.get(src[j], src[j]))
                else:
                    buf.append(src[j])
                j += 1
            if j >= n:
                raise KasalahanSunda("teks acan ditutup (kurang tanda kutip)", baris)
            tokens.append(("TEKS", "".join(buf), baris))
            i = j + 1
            continue
        if c.isalpha() or c == "_":
            j = i
            while j < n and (src[j].isalnum() or src[j] == "_"):
                j += 1
            kecap = src[i:j]
            tokens.append(("KONCI" if kecap in KECAP_KONCI else "NAMA", kecap, baris))
            i = j
            continue
        if src[i:i + 2] in OP_DUA:
            tokens.append(("OP", src[i:i + 2], baris))
            i += 2
            continue
        if c in OP_SATU:
            if c in "([":
                kurung += 1
            elif c in ")]":
                kurung = max(0, kurung - 1)
            tokens.append(("OP", c, baris))
            i += 1
            continue
        raise KasalahanSunda(f"karakter '{c}' teu dikenal", baris)
    tokens.append(("NL", "\n", baris))
    tokens.append(("EOF", None, baris))
    return tokens


def N(t, baris, **kw):
    d = {"t": t, "baris": baris}
    d.update(kw)
    return d


class Parser:
    def __init__(self, tokens):
        self.tk = tokens
        self.p = 0

    def kini(self):
        return self.tk[self.p]

    def baris(self):
        return self.tk[self.p][2]

    def maju(self):
        t = self.tk[self.p]
        self.p += 1
        return t

    def cek(self, jenis, nilai=None):
        t = self.tk[self.p]
        return t[0] == jenis and (nilai is None or t[1] == nilai)

    def cek_op(self, v):
        return self.cek("OP", v)

    def cek_k(self, v):
        return self.cek("KONCI", v)

    def gambar(self):
        t = self.kini()
        if t[0] == "EOF":
            return "tungtung berkas"
        if t[0] == "NL":
            return "baris anyar"
        return "'" + str(t[1]) + "'"

    def harep(self, jenis, nilai=None, pesen=None):
        if not self.cek(jenis, nilai):
            raise KasalahanSunda(
                pesen or f"kedahna aya '{nilai or jenis}', tapi kapendak {self.gambar()}",
                self.baris())
        return self.maju()

    def lewati_nl(self):
        while self.cek("NL"):
            self.maju()

    def tungtung(self):
        if self.cek("NL"):
            self.maju()
        elif self.cek_op("}") or self.cek("EOF"):
            pass
        else:
            raise KasalahanSunda(
                f"saatos paréntah kedah baris anyar, tapi kapendak {self.gambar()}",
                self.baris())

    def ahir_stmt(self):
        return self.cek("NL") or self.cek_op("}") or self.cek("EOF")

    def program(self):
        stmts = []
        self.lewati_nl()
        while not self.cek("EOF"):
            stmts.append(self.stmt())
            self.lewati_nl()
        return stmts

    def blok(self):
        self.lewati_nl()
        self.harep("OP", "{", "kedahna aya '{' pikeun muka blok")
        stmts = []
        self.lewati_nl()
        while not self.cek_op("}"):
            if self.cek("EOF"):
                raise KasalahanSunda("blok acan ditutup, kedahna aya '}'", self.baris())
            stmts.append(self.stmt())
            self.lewati_nl()
        self.maju()
        return stmts

    def stmt(self):
        t = self.kini()
        b = t[2]
        if t[0] == "KONCI":
            v = t[1]
            if v == "jieun":
                self.maju()
                nama = self.harep("NAMA", pesen="saatos 'jieun' kedah aya ngaran variabel")[1]
                nilai = None
                if self.cek_op("="):
                    self.maju()
                    nilai = self.expr()
                self.tungtung()
                return N("jieun", b, nama=nama, nilai=nilai)
            if v == "citak":
                self.maju()
                args = []
                if not self.ahir_stmt():
                    args.append(self.expr())
                    while self.cek_op(","):
                        self.maju()
                        args.append(self.expr())
                self.tungtung()
                return N("citak", b, args=args)
            if v == "lamun":
                self.maju()
                cab = []
                c = self.expr()
                cab.append((c, self.blok()))
                sanes, baris_sanes = None, b
                while True:
                    pos = self.p
                    self.lewati_nl()
                    if self.cek_k("atawa_lamun"):
                        self.maju()
                        c = self.expr()
                        cab.append((c, self.blok()))
                    elif self.cek_k("lamun_henteu"):
                        baris_sanes = self.maju()[2]
                        sanes = self.blok()
                        break
                    else:
                        self.p = pos
                        break
                return N("lamun", b, cab=cab, sanes=sanes, baris_sanes=baris_sanes)
            if v == "salila":
                self.maju()
                c = self.expr()
                return N("salila", b, cond=c, blok=self.blok())
            if v == "pikeun":
                self.maju()
                var = self.harep("NAMA", pesen="saatos 'pikeun' kedah aya ngaran variabel")[1]
                self.harep("KONCI", "ti", "kedahna aya 'ti' (pikeun i ti 1 nepi 10)")
                a = self.expr()
                self.harep("KONCI", "nepi", "kedahna aya 'nepi' (pikeun i ti 1 nepi 10)")
                z = self.expr()
                lg = None
                if self.cek_k("lengkah"):
                    self.maju()
                    lg = self.expr()
                return N("pikeun", b, var=var, dari=a, nepi=z, lengkah=lg, blok=self.blok())
            if v == "pagawean":
                self.maju()
                nama = self.harep("NAMA", pesen="saatos 'pagawean' kedah aya ngaran")[1]
                self.harep("OP", "(", "kedahna aya '(' saatos ngaran pagawean")
                param = []
                if not self.cek_op(")"):
                    param.append(self.harep("NAMA", pesen="kedahna aya ngaran parameter")[1])
                    while self.cek_op(","):
                        self.maju()
                        param.append(self.harep("NAMA", pesen="kedahna aya ngaran parameter")[1])
                self.harep("OP", ")", "kedahna aya ')' pikeun nutup parameter")
                return N("pagawean", b, nama=nama, param=param, blok=self.blok())
            if v == "balik":
                self.maju()
                nilai = None if self.ahir_stmt() else self.expr()
                self.tungtung()
                return N("balik", b, nilai=nilai)
            if v in ("eureun", "terus"):
                self.maju()
                self.tungtung()
                return N(v, b)
            if v in ("ti", "nepi", "lengkah", "jeung", "atawa",
                     "atawa_lamun", "lamun_henteu"):
                raise KasalahanSunda(f"'{v}' teu tiasa dipaké di mimiti paréntah", b)

        e = self.expr()
        if self.cek_op("="):
            self.target_sah(e, b)
            self.maju()
            nilai = self.expr()
            self.tungtung()
            return N("assign", b, target=e, nilai=nilai)
        if self.cek("OP") and self.kini()[1] in ("+=", "-=", "*=", "/="):
            self.target_sah(e, b)
            op = self.maju()[1][0]
            nilai = N("bin", b, op=op, a=e, b=self.expr())
            self.tungtung()
            return N("assign", b, target=e, nilai=nilai)
        self.tungtung()
        return N("ekspresi", b, nilai=e)

    def target_sah(self, e, b):
        if e["t"] not in ("nama", "indeks"):
            raise KasalahanSunda("sisi kénca '=' kedah variabel atanapi unsur daptar", b)

    def expr(self):
        return self.atawa()

    def atawa(self):
        a = self.jeung()
        while self.cek_k("atawa"):
            b = self.maju()[2]
            a = N("bin", b, op="atawa", a=a, b=self.jeung())
        return a

    def jeung(self):
        a = self.lain()
        while self.cek_k("jeung"):
            b = self.maju()[2]
            a = N("bin", b, op="jeung", a=a, b=self.lain())
        return a

    def lain(self):
        if self.cek_k("lain"):
            b = self.maju()[2]
            return N("unari", b, op="lain", x=self.lain())
        return self.banding()

    def banding(self):
        a = self.tambah()
        while self.cek("OP") and self.kini()[1] in ("==", "!=", "<", ">", "<=", ">="):
            t = self.maju()
            a = N("bin", t[2], op=t[1], a=a, b=self.tambah())
        return a

    def tambah(self):
        a = self.kali()
        while self.cek("OP") and self.kini()[1] in ("+", "-"):
            t = self.maju()
            a = N("bin", t[2], op=t[1], a=a, b=self.kali())
        return a

    def kali(self):
        a = self.unari()
        while self.cek("OP") and self.kini()[1] in ("*", "/", "%"):
            t = self.maju()
            a = N("bin", t[2], op=t[1], a=a, b=self.unari())
        return a

    def unari(self):
        if self.cek_op("-"):
            b = self.maju()[2]
            return N("unari", b, op="-", x=self.unari())
        return self.pangkat()

    def pangkat(self):
        a = self.postfix()
        if self.cek_op("**"):
            b = self.maju()[2]
            return N("bin", b, op="**", a=a, b=self.unari())
        return a

    def postfix(self):
        e = self.primary()
        while True:
            if self.cek_op("("):
                b = self.maju()[2]
                args = []
                if not self.cek_op(")"):
                    args.append(self.expr())
                    while self.cek_op(","):
                        self.maju()
                        args.append(self.expr())
                self.harep("OP", ")", "kedahna aya ')' pikeun nutup pamanggil pagawean")
                e = N("panggil", b, fungsi=e, args=args)
            elif self.cek_op("["):
                b = self.maju()[2]
                idx = self.expr()
                self.harep("OP", "]", "kedahna aya ']' pikeun nutup indeks")
                e = N("indeks", b, dasar=e, idx=idx)
            else:
                return e

    def primary(self):
        t = self.kini()
        b = t[2]
        if t[0] == "ANGKA":
            self.maju()
            return N("angka", b, nilai=t[1])
        if t[0] == "TEKS":
            self.maju()
            return N("teks", b, nilai=t[1])
        if t[0] == "NAMA":
            self.maju()
            return N("nama", b, nama=t[1])
        if t[0] == "KONCI" and t[1] in ("leres", "lepat"):
            self.maju()
            return N("bool", b, nilai=(t[1] == "leres"))
        if t[0] == "KONCI" and t[1] == "kosong":
            self.maju()
            return N("kosong", b)
        if self.cek_op("("):
            self.maju()
            e = self.expr()
            self.harep("OP", ")", "kedahna aya ')' pikeun nutup kurung")
            return e
        if self.cek_op("["):
            self.maju()
            items = []
            if not self.cek_op("]"):
                items.append(self.expr())
                while self.cek_op(","):
                    self.maju()
                    if self.cek_op("]"):
                        break
                    items.append(self.expr())
            self.harep("OP", "]", "kedahna aya ']' pikeun nutup daptar")
            return N("daptar", b, items=items)
        raise KasalahanSunda(f"ekspresi teu valid, kapendak {self.gambar()}", b)


BAWAAN = {
    "panjang": "len", "angka": "_angka", "teks": "_teks", "tanya": "_tanya",
    "acak": "_acak", "akar": "_akar", "pangbadagna": "max", "pangleutikna": "min",
    "tambihkeun": "_tambihkeun", "bunderkeun": "_bunderkeun", "mutlak": "abs",
    "urutkeun": "sorted", "hurup_gede": "_gede", "hurup_leutik": "_leutik",
}
_RESERVED = set(keyword.kwlist) | set(dir(builtins)) | {"math", "random", "sys"}


def pyname(n):
    return n + "_s" if (n in _RESERVED or n.startswith("_")) else n


class Generator:
    def __init__(self):
        self.out, self.peta = [], []
        self.ind = 0
        self.scopes = [set()]
        self.fungsi = []
        self.tangguh = []
        self.loop = 0
        self.b = 0

    def emit(self, s):
        self.out.append("    " * self.ind + s)
        self.peta.append(self.b)

    def hasilkeun(self, prog):
        self.hoist(prog)
        for s in prog:
            self.stmt(s)
        self.periksa_tangguh()
        return "\n".join(self.out) + "\n"

    def tambahan(self, prog):
        self.out, self.peta = [], []
        scope_awal = set(self.scopes[0])
        try:
            self.hoist(prog)
            for s in prog:
                self.stmt(s)
        except KasalahanSunda:
            self.scopes = [scope_awal]
            self.fungsi, self.tangguh = [], []
            self.loop = self.ind = 0
            raise
        self.tangguh = []
        return "\n".join(self.out) + "\n"

    def periksa_tangguh(self):
        for nama, baris, sc in self.tangguh:
            if nama not in BAWAAN and not any(nama in s for s in sc):
                raise KasalahanSunda(f"'{nama}' teu kapendak (acan dijieun)", baris)

    def hoist(self, stmts):
        for s in stmts:
            if s["t"] == "pagawean":
                self.scopes[-1].add(s["nama"])

    def resolve(self, nama, baris):
        for s in reversed(self.scopes):
            if nama in s:
                return pyname(nama)
        if nama in BAWAAN:
            return BAWAAN[nama]
        if len(self.scopes) > 1:
            self.tangguh.append((nama, baris, list(self.scopes)))
            return pyname(nama)
        raise KasalahanSunda(f"'{nama}' teu kapendak (acan dijieun)", baris)

    def tandaan_assign(self, nama, baris):
        for k in range(len(self.scopes) - 1, -1, -1):
            if nama in self.scopes[k]:
                if k != len(self.scopes) - 1:
                    f = self.fungsi[-1]
                    (f["global"] if k == 0 else f["nonlocal"]).add(pyname(nama))
                return
        raise KasalahanSunda(
            f"variabel '{nama}' acan dijieun; paké 'jieun {nama} = ...' heula", baris)

    def blok(self, stmts):
        self.ind += 1
        n0 = len(self.out)
        for s in stmts:
            self.stmt(s)
        if len(self.out) == n0:
            self.emit("pass")
        self.ind -= 1

    def stmt(self, s):
        self.b = s["baris"]
        t = s["t"]
        if t == "jieun":
            v = self.ex(s["nilai"]) if s["nilai"] else "None"
            self.scopes[-1].add(s["nama"])
            self.emit(f"{pyname(s['nama'])} = {v}")
        elif t == "citak":
            self.emit("_citak(" + ", ".join(self.ex(a) for a in s["args"]) + ")")
        elif t == "assign":
            tg = s["target"]
            v = self.ex(s["nilai"])
            if tg["t"] == "nama":
                self.tandaan_assign(tg["nama"], tg["baris"])
                self.emit(f"{pyname(tg['nama'])} = {v}")
            else:
                self.emit(f"{self.ex(tg)} = {v}")
        elif t == "lamun":
            for i, (cond, blk) in enumerate(s["cab"]):
                self.b = cond["baris"]
                self.emit(("if " if i == 0 else "elif ") + self.ex(cond) + ":")
                self.blok(blk)
            if s["sanes"] is not None:
                self.b = s["baris_sanes"]
                self.emit("else:")
                self.blok(s["sanes"])
        elif t == "salila":
            self.emit("while " + self.ex(s["cond"]) + ":")
            self.loop += 1
            self.blok(s["blok"])
            self.loop -= 1
        elif t == "pikeun":
            a = self.ex(s["dari"])
            z = self.ex(s["nepi"])
            lg = self.ex(s["lengkah"]) if s["lengkah"] else "1"
            self.scopes[-1].add(s["var"])
            self.emit(f"for {pyname(s['var'])} in _rentang({a}, {z}, {lg}):")
            self.loop += 1
            self.blok(s["blok"])
            self.loop -= 1
        elif t == "pagawean":
            self.scopes[-1].add(s["nama"])
            ps = ", ".join(pyname(p) for p in s["param"])
            self.emit(f"def {pyname(s['nama'])}({ps}):")
            pos = len(self.out)
            self.scopes.append(set(s["param"]))
            self.fungsi.append({"global": set(), "nonlocal": set()})
            loop_lama, self.loop = self.loop, 0
            self.hoist(s["blok"])
            self.blok(s["blok"])
            f = self.fungsi.pop()
            self.scopes.pop()
            self.loop = loop_lama
            ekstra = []
            pad = "    " * (self.ind + 1)
            if f["global"]:
                ekstra.append(pad + "global " + ", ".join(sorted(f["global"])))
            if f["nonlocal"]:
                ekstra.append(pad + "nonlocal " + ", ".join(sorted(f["nonlocal"])))
            self.out[pos:pos] = ekstra
            self.peta[pos:pos] = [s["baris"]] * len(ekstra)
        elif t == "balik":
            if len(self.scopes) == 1:
                raise KasalahanSunda("'balik' ngan tiasa dipaké di jero 'pagawean'", s["baris"])
            self.emit("return " + (self.ex(s["nilai"]) if s["nilai"] else "None"))
        elif t in ("eureun", "terus"):
            if self.loop == 0:
                raise KasalahanSunda(
                    f"'{t}' ngan tiasa dipaké di jero 'salila' atanapi 'pikeun'", s["baris"])
            self.emit("break" if t == "eureun" else "continue")
        elif t == "tampil":
            self.emit("_tampil(" + self.ex(s["nilai"]) + ")")
        elif t == "ekspresi":
            self.emit(self.ex(s["nilai"]))

    def ex(self, e):
        t = e["t"]
        if t in ("angka", "teks"):
            return repr(e["nilai"])
        if t == "bool":
            return "True" if e["nilai"] else "False"
        if t == "kosong":
            return "None"
        if t == "nama":
            return self.resolve(e["nama"], e["baris"])
        if t == "daptar":
            return "[" + ", ".join(self.ex(x) for x in e["items"]) + "]"
        if t == "indeks":
            return f"{self.ex(e['dasar'])}[{self.ex(e['idx'])}]"
        if t == "unari":
            x = self.ex(e["x"])
            return f"(-{x})" if e["op"] == "-" else f"(not {x})"
        if t == "bin":
            op, a, b = e["op"], self.ex(e["a"]), self.ex(e["b"])
            if op == "+":
                return f"_tmb({a}, {b})"
            if op == "/":
                return f"_bgi({a}, {b})"
            if op == "jeung":
                return f"({a} and {b})"
            if op == "atawa":
                return f"({a} or {b})"
            return f"({a} {op} {b})"
        if t == "panggil":
            f = e["fungsi"]
            fn = self.resolve(f["nama"], f["baris"]) if f["t"] == "nama" else self.ex(f)
            return f"{fn}(" + ", ".join(self.ex(a) for a in e["args"]) + ")"
        raise KasalahanSunda("ekspresi teu dikenal", e.get("baris"))


PREAMBLE = r'''import math as _math, random as _random, sys as _sys

_sys.setrecursionlimit(3000)


def _fmt(x, dalam=False):
    if x is True: return "leres"
    if x is False: return "lepat"
    if x is None: return "kosong"
    if isinstance(x, float):
        if x.is_integer() and abs(x) < 1e15: return str(int(x))
        return str(round(x, 10))
    if isinstance(x, list):
        return "[" + ", ".join(_fmt(i, True) for i in x) + "]"
    if isinstance(x, str):
        return chr(34) + x + chr(34) if dalam else x
    return str(x)


def _citak(*a): print(" ".join(_fmt(i) for i in a))
def _tampil(x):
    if x is not None: print(_fmt(x, True))
def _teks(x): return _fmt(x)


def _tmb(a, b):
    if isinstance(a, str) or isinstance(b, str): return _fmt(a) + _fmt(b)
    return a + b


def _bgi(a, b):
    if b == 0: raise ZeroDivisionError("bagi nol")
    if isinstance(a, int) and isinstance(b, int) and a % b == 0: return a // b
    return a / b


def _angka(x):
    if isinstance(x, str):
        s = x.strip()
        try: return int(s)
        except ValueError: pass
        try: return float(s)
        except ValueError: raise ValueError("'" + x + "' lain angka")
    if isinstance(x, bool): return int(x)
    if isinstance(x, (int, float)): return x
    raise ValueError("teu tiasa dirobah jadi angka")


def _tanya(p=""):
    try: return input(_fmt(p))
    except EOFError: return ""


def _acak(a, b): return _random.randint(int(a), int(b))


def _akar(x):
    if x < 0: raise ValueError("akar tina angka négatif teu tiasa")
    return _math.sqrt(x)


def _tambihkeun(d, x): d.append(x)


def _bunderkeun(x, n=0):
    n = int(n)
    m = 10 ** n
    r = _math.floor(x * m + 0.5) / m
    return int(r) if n == 0 else r


def _gede(s): return str(s).upper()
def _leutik(s): return str(s).lower()


def _rentang(a, b, s=1):
    a, b, s = int(a), int(b), int(s)
    if s == 0: raise ValueError("lengkah teu tiasa nol")
    return range(a, b + 1, s) if s > 0 else range(a, b - 1, s)


def _pesen_galat(e):
    if isinstance(e, ZeroDivisionError): return "teu tiasa dibagi ku nol"
    if isinstance(e, IndexError): return "indeks daptar kaluar tina wates"
    if isinstance(e, RecursionError): return "pagawean nelepon dirina teuing jero (rekursi teu aya tungtungna)"
    if isinstance(e, (TypeError, AttributeError)): return "jinis data teu cocog pikeun operasi ieu"
    if isinstance(e, NameError):
        n = getattr(e, "name", None)
        return ("'" + n + "' acan dijieun") if n else "aya ngaran anu acan dijieun"
    if isinstance(e, ValueError): return str(e)
    if isinstance(e, KeyboardInterrupt): return "dieureunkeun ku pamaké"
    return type(e).__name__ + ": " + str(e)


def _lapor_galat(e):
    if isinstance(e, BrokenPipeError):
        return
    baris, tb = None, e.__traceback__
    while tb:
        if tb.tb_frame.f_globals is globals() and tb.tb_lineno > _AWAL:
            i = tb.tb_lineno - _AWAL - 1
            if 0 <= i < len(_PETA):
                baris = _PETA[i]
        tb = tb.tb_next
    lokasi = " (baris " + str(baris) + ")" if baris else ""
    _sys.stderr.write("Kasalahan nalika ngajalankeun" + lokasi + ": " + _pesen_galat(e) + chr(10))


def _hook(t, e, tb):
    _lapor_galat(e)


_sys.excepthook = _hook
'''

CONTO = '''#!/usr/bin/env sunda
jieun ngaran = tanya("Saha ngaran anjeun? ")
citak "Wilujeng sumping,", ngaran

pikeun i ti 1 nepi 3 {
    citak "Itungan ka-" + teks(i)
}
'''


def kompilasi(sumber):
    ast = Parser(lex(sumber)).program()
    g = Generator()
    kode = g.hasilkeun(ast)
    return kode, g.peta


def rakit(kode, peta, shebang=False):
    kepala = ("#!/usr/bin/env python3\n" if shebang else "") + PREAMBLE
    kepala += "_PETA = " + repr(peta) + "\n"
    awal = kepala.count("\n") + 1
    return kepala + f"_AWAL = {awal}\n" + kode


def jalankeun(kode, peta):
    ns = {"__name__": "__sunda__"}
    try:
        exec(compile(rakit(kode, peta), "<sunda>", "exec"), ns)
    except SystemExit:
        raise
    except BaseException as e:
        ns["_lapor_galat"](e)
        return 1
    return 0


def lapor(sumber, e):
    if e.baris:
        sys.stderr.write(f"Kasalahan kompilasi di baris {e.baris}: {e.pesen}\n")
        baris = sumber.split("\n")
        if 0 < e.baris <= len(baris):
            sys.stderr.write(f"  {e.baris} | {baris[e.baris - 1].strip()}\n")
    else:
        sys.stderr.write(f"Kasalahan kompilasi: {e.pesen}\n")


def jadikeun_eksekusi(jalur):
    try:
        os.chmod(jalur, os.stat(jalur).st_mode | 0o755)
    except OSError:
        pass


def cari_berkas(nama):
    for kandidat in (nama, nama + ".sd"):
        if os.path.isfile(kandidat):
            return kandidat
    return None


def buat_baru(nama):
    if not nama.endswith(".sd"):
        nama += ".sd"
    if os.path.exists(nama):
        sys.stderr.write(f"Berkas '{nama}' atos aya\n")
        return 1
    with open(nama, "w", encoding="utf-8") as f:
        f.write(CONTO)
    jadikeun_eksekusi(nama)
    print(f"Berkas dijieun: {nama}")
    print(f"Jalankeun nganggo: sunda {nama}")
    return 0


def repl():
    try:
        import readline
    except ImportError:
        pass
    print(f"Sundalang {VERSI} - ketik 'kaluar' pikeun kaluar")
    ns = {"__name__": "__sunda__"}
    exec(compile(PREAMBLE, "<runtime>", "exec"), ns)
    g = Generator()
    buf = ""
    while True:
        try:
            baris = input("sunda> " if not buf else "  ...> ")
        except EOFError:
            print()
            return 0
        except KeyboardInterrupt:
            print()
            buf = ""
            continue
        if not buf and baris.strip() in ("kaluar", "exit", "quit"):
            return 0
        buf += baris + "\n"
        try:
            tk = lex(buf)
        except KasalahanSunda as e:
            sys.stderr.write(f"Kasalahan: {e.pesen}\n")
            buf = ""
            continue
        muka = sum(1 for t in tk if t[0] == "OP" and t[1] in ("{", "(", "["))
        nutup = sum(1 for t in tk if t[0] == "OP" and t[1] in ("}", ")", "]"))
        if muka > nutup:
            continue
        buf = ""
        try:
            prog = Parser(tk).program()
            if len(prog) == 1 and prog[0]["t"] == "ekspresi":
                prog[0]["t"] = "tampil"
            kode = g.tambahan(prog)
        except KasalahanSunda as e:
            sys.stderr.write(f"Kasalahan: {e.pesen}\n")
            continue
        try:
            exec(compile(kode, "<sunda>", "exec"), ns)
        except SystemExit:
            raise
        except BaseException as e:
            sys.stderr.write("Kasalahan: " + ns["_pesen_galat"](e) + "\n")


def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser(
        prog="sunda",
        add_help=False,
        usage="sunda [berkas.sd] [pilihan]",
        description="Sundalang - basa program nganggo kecap konci basa Sunda")
    ap.add_argument("berkas", nargs="?",
                    help="berkas sumber (.sd); upami kosong, muka mode interaktif")
    ap.add_argument("-h", "--bantuan", action="help", help="témbongkeun bantuan ieu")
    ap.add_argument("--py", action="store_true", help="témbongkeun kode Python hasil kompilasi")
    ap.add_argument("-o", "--kaluaran", metavar="BERKAS",
                    help="jieun program mandiri anu bisa langsung dijalankeun")
    ap.add_argument("--baru", action="store_true", help="jieun berkas .sd anyar tina conto")
    ap.add_argument("--versi", action="store_true", help="témbongkeun versi")
    a = ap.parse_args()

    if a.versi:
        print(f"Sundalang {VERSI}")
        return 0
    if a.baru:
        if not a.berkas:
            sys.stderr.write("Sebutkeun ngaran berkas, contona: sunda --baru halo.sd\n")
            return 1
        return buat_baru(a.berkas)
    if not a.berkas:
        return repl()

    jalur = cari_berkas(a.berkas)
    if jalur is None:
        sys.stderr.write(f"Berkas '{a.berkas}' teu kapendak\n")
        return 1
    with open(jalur, encoding="utf-8-sig") as f:
        sumber = f.read()

    try:
        kode, peta = kompilasi(sumber)
    except KasalahanSunda as e:
        lapor(sumber, e)
        return 1

    if a.kaluaran:
        with open(a.kaluaran, "w", encoding="utf-8") as f:
            f.write(rakit(kode, peta, shebang=True))
        jadikeun_eksekusi(a.kaluaran)
        print(f"Program mandiri disimpen di {a.kaluaran}")
        return 0
    if a.py:
        print(kode)
        return 0
    return jalankeun(kode, peta)


if __name__ == "__main__":
    sys.exit(main())
