import std.stdio, std.exception;
import base, reader, exec;


STree extLastArg(STree arg, STree env) {
	if (typeid(arg) == typeid(SNull)) {
		return new SNull;
	}
	// 未対応♨️
	assert(false);
}

void extArg(STree s, STree arg, SEnv fenv, SEnv env) { //s:仮引数 arg:実引数
	if (typeid(s) == typeid(SNull)) {
		enforce(typeid(arg) == typeid(SNull), "引数が多すぎる");
	} else if (typeid(s) == typeid(SSymbol)) { // 可変長引数, ラスト
		assert(false);
//		fenv.add(s.n, extLastArg(arg, env));
	} else if (typeid(s) == typeid(SPair)) {
		enforce(typeid((cast(SPair)s).l) == typeid(SSymbol), "arg typeはシンボル");
		fenv.add((cast(SSymbol)(cast(SPair)s).l).s, execS((cast(SPair)arg).l, env));
		extArg((cast(SPair)s).r, (cast(SPair)arg).r, fenv, env);
	} else {
		writeln(typeid(s));
		assert(false);
	}
}

STree execL(SLambda s, STree arg, SEnv env) {
	SEnv fenv = new SEnv(s.e);
//  listArgE(STree arg, int n, bool last, SEnv env)
	extArg(s.p.l, arg, fenv, env);
	STree[] l = listArgNE(s.p.r, 1, true);
	foreach (d; l[0..$-1]) {
		execS(d, fenv);
	}
	return execS(l[$-1], fenv);
}


string[] blList = [
	"+", "-", "=", "<",
	"if", "or", "define", "lambda", "quote", "set!",
	"read", "newline", "display",
	"list", "cons", "car", "cdr", "null?",
];

STree[] listArgNE(STree arg, int n, bool last) { // (1,2,..n . last) 全て未評価で返す
	if (n == 0) {
		if (!last) {
			enforce(typeid(arg) == typeid(SNull), "引数が多すぎる");
			return [];
		}
		STree[] r;
		while (typeid(arg) == typeid(SPair)) {
			r ~= (cast(SPair)arg).l;
			arg = (cast(SPair)arg).r;
		}
		enforce(typeid(arg) == typeid(SNull), "引数の型がおかしい");
		return r;
	} else {
		enforce(typeid(arg) == typeid(SPair), "引数が少なすぎる");
		return (cast(SPair)arg).l ~ listArgNE((cast(SPair)arg).r, n-1, last);
	}
}

STree[] listArgE(STree arg, int n, bool last, SEnv env) { // (1,2,..n . last) 全て評価で返す
	if (n == 0) {
		if (!last) {
			enforce(typeid(arg) == typeid(SNull), "引数が多すぎる");
			return [];
		}
		STree[] r;
		while (typeid(arg) == typeid(SPair)) {
			r ~= (cast(SPair)arg).l.execS(env);
			arg = (cast(SPair)arg).r;
		}
		enforce(typeid(arg) == typeid(SNull), "引数の型がおかしい");
		return r;
	} else {
		enforce(typeid(arg) == typeid(SPair), "引数が少なすぎる");
		return (cast(SPair)arg).l.execS(env) ~ listArgE((cast(SPair)arg).r, n-1, last, env);
	}
}

STree execBL(SBLambda s, STree arg, SEnv env) {
	final switch (s.s) {
	case "define":
		auto l = listArgNE(arg, 2, false);
		enforce(typeid(l[0]) == typeid(SSymbol), "defineの第1引数はシンボル");
		env.add((cast(SSymbol)l[0]).s, execS(l[1], env));
		return l[0];
	case "set!":
		auto l = listArgNE(arg, 2, false);
		enforce(typeid(l[0]) == typeid(SSymbol), "set!の第1引数はシンボル");
		env.set((cast(SSymbol)l[0]).s, execS(l[1], env));
	case "lambda":
		return new SLambda(env, (cast(SPair)arg));
	case "if":
		auto l = listArgNE(arg, 3, false);
		auto a = l[0].execS(env);
		if (typeid(a) != typeid(SBool) || (cast(SBool)a).b != false) {
			// #t
			return l[1].execS(env);
		}
		// #f
		return l[2].execS(env);
	case "or":
		auto l = listArgNE(arg, 2, false);
		auto a = l[0].execS(env);
		if (typeid(a) != typeid(SBool) || (cast(SBool)a).b != false) {
			// #t
			return new SBool(true);
		}
		// #f
		a = l[1].execS(env);
		if (typeid(a) != typeid(SBool) || (cast(SBool)a).b != false) {
			// #t
			return new SBool(true);
		}		
		return new SBool(false);
	case "quote":
		auto l = listArgNE(arg, 1, false);
		return l[0];
	case "read":
		return readS(new Reader(new ReaderBase(stdin)));
		assert(false);
	case "display":
		auto l = listArgE(arg, 1, false, env);
		write(l[0]);
		return l[0];
	case "newline":
		writeln();
		return new SNull();
	case "list":
		auto l = listArgE(arg, 0, true, env);
		SPair p = new SPair(new SNull(), new SNull());
		SPair q = p;
		foreach (a; l) {
			q.l = a;
			q.r = new SPair(new SNull(), new SNull());
			q = cast(SPair)((cast(SPair)q).r);
		}
		return p;
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
	}
	assert(0);
}

