import std.stdio, std.exception;
import base, reader;

STree refArg(STree arg, int n) {
	assert(0 <= n);
	assert(arg.type == SType.P);
	if (n == 0) return arg.l;
	return refArg(arg.r, n-1);
}


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

STree extLastArg(STree arg, STree env) {
	if (arg.type == SType.Null) {
		return STree.makeNull();
	}
	assert(false);
}

void extArg(STree s, STree arg, STree fenv, STree env) { //s:仮引数 arg:実引数
	if (s.type == SType.Null) {
		assert(arg.type == SType.Null);
	} else if (s.type == SType.S) { // 可変長引数, ラスト	
		fenv.add(s.n, extLastArg(arg, env));
	} else {
		assert(s.type == SType.P);
		assert(s.l.type == SType.S);
		assert(arg.type == SType.P);
		fenv.add(s.l.n, execS(arg.l, env));
		extArg(s.r, arg.r, fenv, env);
	}
}

STree execL(STree s, STree arg, STree env) {
	assert(s.type == SType.L);
	assert(s.p.type == SType.P);
	assert(s.p.r.type == SType.P);
	assert(s.p.r.r.type == SType.Null);
	STree fenv = STree.makeE(s.e);
	extArg(s.p.l, arg, fenv, env);
	return execS(s.p.r.l, fenv);
}

STree firstenv() {
	STree env = STree.makeE(null);
	string[] blList = ["+", "-", "=", "<", "if", "define", "lambda", "quote", "read", "newline", "display"];
	foreach (s; blList) {
		env.add(s, STree.makeBL(s));
	}
	return env;
}

STree execS(STree s, STree env) {
	final switch (s.type) {
	case SType.Null:
		throw new Exception("空リストは評価不可");
	case SType.N:
	case SType.B:
		return s;
	case SType.S:
		return env.check(s.s);
	case SType.P:
		auto l = execS(s.l, env);
		assert(l.type == SType.L || l.type == SType.BL);
		if (l.type == SType.L) {
			return execL(l, s.r, env);
		} else if (l.type == SType.BL) {
			return execBL(l, s.r, env);
		}
		assert(false);
	case SType.L:
	case SType.BL:
	case SType.E:
		throw new Exception("評価不可");
	}
}