import std.stdio, std.exception;
import base, reader, exec;

string[] blList = [
	"+", "-", "=", "<",
	"if", "define", "lambda", "quote",
	"read", "newline", "display",
	"cons", "car", "cdr",
];

STree[] listArgNE(STree arg, int n, bool last) { // (1,2,..n . last) 全て未評価で返す
	if (n == 0) {
		if (!last) {
			enforce(arg.type == SType.Null, "引数が多すぎる");
			return [];
		}
		STree[] r;
		while (arg.type == SType.P) {
			r ~= arg.l;
			arg = arg.r;
		}
		enforce(arg.type == SType.Null, "引数の型がおかしい");
		return r;
	} else {
		enforce(arg.type == SType.P, "引数が少なすぎる");
		return arg.l ~ listArgNE(arg.r, n-1, last);
	}
}

STree[] listArgE(STree arg, int n, bool last, STree env) { // (1,2,..n . last) 全て評価で返す
	if (n == 0) {
		if (!last) {
			enforce(arg.type == SType.Null, "引数が多すぎる");
			return [];
		}
		STree[] r;
		while (arg.type == SType.P) {
			r ~= arg.l.execS(env);
			arg = arg.r;
		}
		enforce(arg.type == SType.Null, "引数の型がおかしい");
		return r;
	} else {
		enforce(arg.type == SType.P, "引数が少なすぎる");
		return arg.l.execS(env) ~ listArgE(arg.r, n-1, last, env);
	}
}

STree execBL(STree s, STree arg, STree env) {
	assert(s.type == SType.BL);
	final switch (s.n) {
	case "define":
		auto l = listArgNE(arg, 2, false);
		enforce(l[0].type == SType.S, "defineの第1引数はシンボル");
		env.add(l[0].s, execS(l[1], env));
		return l[0];
	case "lambda":
		return STree.makeL(env, arg);
	case "if":
		auto l = listArgNE(arg, 3, false);
		auto a = l[0].execS(env);
		if (a.type != SType.B || a.b != false) {
			// #t
			return l[1].execS(env);
		}
		// #f
		return l[2].execS(env);
	case "quote":
		auto l = listArgNE(arg, 1, false);
		return l[0];
	case "read":
		return readS(new Reader(stdin));
		assert(false);
	case "display":
		auto l = listArgE(arg, 1, false, env);
		write(l[0]);
		return l[0];
	case "newline":
		writeln();
		return STree.makeNull();
	case "cons":
		auto l = listArgE(arg, 2, false, env);
		return STree.makeP(l[0], l[1]);
	case "car":
		auto l = listArgE(arg, 1, false, env);
		enforce(l[0].type == SType.P, "carの引数はpair");
		return l[0].l;
	case "cdr":
		auto l = listArgE(arg, 1, false, env);
		enforce(l[0].type == SType.P, "cdrの引数はpair");
		return l[0].r;
	case "+":
		auto l = listArgE(arg, 0, true, env);
		int sm = 0;
		foreach (a; l) {
			enforce(a.type == SType.N, "+の引数は全て整数");
			sm += a.num;
		}
		return STree.makeN(sm);
	case "-":
		auto l = listArgE(arg, 1, true, env);
		enforce(l[0].type == SType.N, "-の引数は全て整数");
		int sm = l[0].num;
		foreach (a; l[1..$]) {
			enforce(a.type == SType.N, "-の引数は全て整数");
			sm -= a.num;
		}
		return STree.makeN(sm);		
	case "=":
		auto l = listArgE(arg, 2, false, env);
		enforce(l[0].type == SType.N, "=の引数は全て整数");
		enforce(l[1].type == SType.N, "=の引数は全て整数");
		return STree.makeB(l[0].num == l[1].num);
	case "<":
		auto l = listArgE(arg, 2, false, env);
		enforce(l[0].type == SType.N, "<の引数は全て整数");
		enforce(l[1].type == SType.N, "<の引数は全て整数");
		return STree.makeB(l[0].num < l[1].num);
	}
	assert(0);
}

