import std.exception;
import base, lambda;

/*
 define-syntax, syntax-rules のみ実装
 syntax-rulesは
 (syntax-rules ()
 	((e1 e2 e3 .. en) (p1 p2 p3 .. pn))
 )
 の形式のみ
 (define-syntax ()
  (syntax-rules ()
   [(e1 ..) (p1 ...)]
  )
 )
 不衛生
*/

SEnv firstMacro() {
	return new SEnv(null);
}


bool isMatch(STree d, STree syn, SEnv ev, SEnv sl) {
	if (syn.classinfo == SSymbol.classinfo) {
		auto ss = cast(SSymbol)syn;
		if (ss.s == "_") return true;
		if (sl.have(ss.s)) {
			if (d.classinfo != SSymbol.classinfo) return false;
			if ((cast(SSymbol)d).s != ss.s) return false;
			return true;
		} else {
			ev.add(ss.s, d);
			return true;
		}
	}
	if (syn.classinfo == SPair.classinfo) {
		if (d.classinfo != SPair.classinfo) return false;
		auto l1 = listExt(d);
		auto l2 = listExt(syn);
		int po = -1;
		foreach (i; 0..l2.length) {
			if (l2[i].classinfo != SSymbol.classinfo) continue;
			if ((cast(SSymbol)l2[i]).s != "...") continue;
			po = cast(int)i;
			break;
		}
		assert(po == -1 || po+1 == l2.length); // ...は最後のみの仕様
		if (po == -1 && l1.length != l2.length) return false;

		foreach (i; 0..l2.length) {
			if (i+1 == po) {
				ev.add((cast(SSymbol)l2[i]).s, listPack(l1[i..$]));
				return true;
			}
			if (l1.length <= i) return false;
			if (!isMatch(l1[i], l2[i], ev, sl)) {
				return false;
			}
		}
		return true;
	}
	throw new Exception("syn形式が不正");
}

STree repl(STree tmp, SEnv ev) {
	if (tmp.classinfo == SSymbol.classinfo) {
		auto tm = cast(SSymbol)tmp;
		if (ev.have(tm.s)) {
			return ev.at(tm.s);
		}
	}
	if (tmp.classinfo == SPair.classinfo) {
		auto l = listExt(tmp);
		STree[] r;
		int po = -1;
		foreach (i; 0..l.length) {
			if (l[i].classinfo == SSymbol.classinfo && (cast(SSymbol)l[i]).s == "...") {
				po = cast(int)i;
				break;
			}
		}
		assert(po == -1 || po+1 == l.length);
		foreach (i; 0..l.length) {
			if (l[i].classinfo == SSymbol.classinfo &&
				(cast(SSymbol)l[i]).s == "...") continue;
			if (i+1 == po) {
				//ell
				r ~= listExt(ev.at((cast(SSymbol)l[i]).s));
				continue;
			} else {
				r ~= repl(l[i], ev);
			}
		}
		return listPack(r);
	}
	return tmp;
}

STree conv(STree t, STree m, out bool res) {
	import std.stdio;
	assert(m.classinfo == SPair.classinfo);
	auto mm = cast(SPair)m;
//	assert(
//	mm.l.type == SType.Symbol &&
//	(cast(SSyntax)mm.l).s == "syntax-rules"); //syntax-rulesのみ対応

	auto l = listArgNE(mm.r, 1, true);
	SEnv sl = new SEnv(null);
	foreach (d; listExt(l[0])) {
		assert(d.classinfo == SSymbol.classinfo);
		sl.add((cast(SSymbol)d).s, new SNull());
	}
	foreach (d; l[1..$]) {
		auto x = listArgNE(d, 2, false);
		auto ev = new SEnv(null);
		if (isMatch(t, x[0], ev, sl)) {
			res = true;
			return repl(x[1], ev);
		}
	}
	res = false;
	return t;
}

STree execM(STree t, SEnv m, SEnv ev) {
	import std.stdio;
	while (true) {
		if (t.type != SType.Pair) break;
		auto tt = cast(SPair)t;
		if (tt.l.type != SType.Symbol) break;
		auto s = (cast(SSymbol)tt.l).s;
		if (!m.have(s)) break;
		bool res;
		t = conv(t, m.at(s), res);
		if (res) continue;
		writeln(t);
		break;
	}
	if (t.classinfo != SPair.classinfo) return t;
	auto tt = cast(SPair)t;
	if (tt.l.type == SType.Symbol) {
		auto s = (cast(SSymbol)tt.l).s;
		if (ev.have(s)) {
			auto e = ev.at(s);
			if (e.type == SType.Syntax) {
				switch ((cast(SSyntax)e).s) {
				case "define-syntax":
					auto l = listArgNE(tt.r, 2, false);
					writeln("addmacro ", execM(l[1], m, ev));
					m.add((cast(SSymbol)l[0]).s, execM(l[1], m, ev));
					return t;
				case "syntax-rules":
					return t;
				default:
					auto r = execM(tt.r, m, ev);
					return new SPair(tt.l, r);
				}			
			}
		}
	}
	auto l = execM(tt.l, m, ev);
	auto r = execM(tt.r, m, ev);
	return new SPair(l, r);
}
