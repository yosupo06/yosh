import std.stdio, std.exception;
import base, reader, exec;


void extArg(STree s, STree arg, SEnv fenv, SEnv env) { //s:仮引数 arg:実引数
	auto al = dListExt(s, 0, true);
	auto bl = dListExt(arg, 0, true);
	auto as = al.length;
	import std.range : zip;
	foreach (d; zip(al[0..as-1], bl[0..as-1])) {
		enforce(d[0].classinfo == SSymbol.classinfo, "argtypeはシンボル");
		fenv.add((cast(SSymbol)d[0]).s, execS(d[1], env));
	}
	if (al[as-1].classinfo != SNull.classinfo) {
		assert(false);
	} else {
		assert(bl.length == as);
	}
}

STree execL(SLambda s, STree arg, SEnv env) {
	SEnv fenv = new SEnv(s.e);
	extArg(s.p.l, arg, fenv, env);
	STree[] l = listArgNE(s.p.r, 1, false);
	return execS(l[0], fenv);
}



string[] blList = [
	"cons", "car", "cdr",
	"null?",
	"+", "-", "=", "<", "modulo",
	"read", "display",
];

STree[] listExt(STree arg, int mi = 0, bool inf = true) {
	STree[] r;
	while (arg.classinfo == SPair.classinfo) {
		enforce(arg.classinfo == SPair.classinfo, "リストではない");
		r ~= (cast(SPair)arg).l;
		arg = (cast(SPair)arg).r;
	}
	enforce(mi <= r.length, "引数が少なすぎる");
	enforce(inf || mi == r.length, "引数が多すぎる");
	enforce(arg.classinfo == SNull.classinfo, "非真性リスト");
	return r;
}

STree[] dListExt(STree arg, int mi = 0, bool inf = true) {
	STree[] r;
	while (arg.classinfo == SPair.classinfo) {
		enforce(arg.classinfo == SPair.classinfo, "リストではない");
		r ~= (cast(SPair)arg).l;
		arg = (cast(SPair)arg).r;
	}
	enforce(mi <= r.length, "引数が少なすぎる");
	enforce(inf || mi == r.length, "引数が多すぎる");
	r ~= arg;
	return r;
}

STree listPack(STree[] l) {
	if (l.length == 0) return new SNull();
	return new SPair(l[0], listPack(l[1..$]));
}

STree[] listArgNE(STree arg, int n, bool last) { // (1,2,..n . last) 全て未評価で返す
	auto l = listExt(arg);
	enforce(n <= l.length, "引数が少なすぎる");
	enforce(last || l.length == n, "引数が多すぎる");
	return l;
}

STree[] listArgE(STree arg, int n, bool last, SEnv env) { // (1,2,..n . last) 全て評価で返す
	auto l = listArgNE(arg, n, last);
	foreach (i; 0..l.length) {
		l[i] = execS(l[i], env);
	}
	return l;
}

STree execBL(SBLambda s, STree arg, SEnv env) {
	final switch (s.s) {
	case "cond":
		assert(false);
	case "cons":
		auto l = listArgE(arg, 2, false, env);
		return new SPair(l[0], l[1]);
	case "car":
		auto l = listArgE(arg, 1, false, env);
		enforce(typeid(l[0]) == typeid(SPair), "carの引数はpair");
		return (cast(SPair)l[0]).l;
	case "cdr":
		auto l = listArgE(arg, 1, false, env);
		enforce(typeid(l[0]) == typeid(SPair), "cdrの引数はpair");
		return (cast(SPair)l[0]).r;
	case "null?":
		auto l = listArgE(arg, 1, false, env);
		return new SBool(typeid(l[0]) == typeid(SNull));
	case "+":
		auto l = listArgE(arg, 0, true, env);
		int sm = 0;
		foreach (a; l) {
			enforce(typeid(a) == typeid(SNum), "+の引数は全て整数");
			sm += (cast(SNum)a).num;
		}
		return new SNum(sm);
	case "-":
		auto l = listArgE(arg, 1, true, env);
		enforce(typeid(l[0]) == typeid(SNum), "-の引数は全て整数");
		int sm = (cast(SNum)l[0]).num;
		foreach (a; l[1..$]) {
			enforce(typeid(a) == typeid(SNum), "-の引数は全て整数");
			sm -= (cast(SNum)a).num;
		}
		return new SNum(sm);
	case "=":
		auto l = listArgE(arg, 2, false, env);
		enforce(typeid(l[0]) == typeid(SNum), "=の引数は全て整数");
		enforce(typeid(l[1]) == typeid(SNum), "=の引数は全て整数");
		return new SBool((cast(SNum)l[0]).num == (cast(SNum)l[1]).num);
	case "<":
		auto l = listArgE(arg, 2, false, env);
		enforce(typeid(l[0]) == typeid(SNum), "<の引数は全て整数");
		enforce(typeid(l[1]) == typeid(SNum), "<の引数は全て整数");
		return new SBool((cast(SNum)l[0]).num < (cast(SNum)l[1]).num);
	case "modulo":
		auto l = listArgE(arg, 2, false, env);
		return new SNum((cast(SNum)l[0]).num % (cast(SNum)l[1]).num);
	case "read":
		return readS(new Reader(new FileReader(stdin)), false);
	case "display":
		auto l = listArgE(arg, 1, false, env);
		write(l[0]);
		return l[0];
	}
	assert(0);
}

