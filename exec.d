import std.stdio;
import base;

STree refArg(STree arg, int n) {
	assert(0 <= n);
	assert(arg.type == SType.P);
	if (n == 0) return arg.l;
	return refArg(arg.r, n-1);
}

STree execBL(STree s, STree arg, STree env) {
	assert(s.type == SType.BL);
	final switch (s.n) {
	case "define":
		auto a = refArg(arg, 0);
		auto b = execS(refArg(arg, 1), env);
		assert(a.type == SType.S);
		env.add(a.s, b);
//		env = STree.makeE(a.s, b, env);
		return a;
	case "lambda":
		return STree.makeL(env, arg);
	case "if":
		auto a = execS(refArg(arg, 0), env);
		if (a.type == SType.B && a.b == false) {
			//false
			return execS(refArg(arg, 2), env);
		}
		//true
		return execS(refArg(arg, 1), env);
	case "+":
		auto a = execS(refArg(arg, 0), env);
		auto b = execS(refArg(arg, 1), env);
		assert(a.type == SType.N);
		assert(b.type == SType.N);
		return STree.makeN(a.num + b.num);
	case "-":
		auto a = execS(refArg(arg, 0), env);
		auto b = execS(refArg(arg, 1), env);
		assert(a.type == SType.N);
		assert(b.type == SType.N);
		return STree.makeN(a.num - b.num);
	case "=":
		auto a = execS(refArg(arg, 0), env);
		auto b = execS(refArg(arg, 1), env);
		assert(a.type == SType.N);
		assert(b.type == SType.N);
		return STree.makeB(a.num == b.num);
	case "<":
		auto a = execS(refArg(arg, 0), env);
		auto b = execS(refArg(arg, 1), env);
		assert(a.type == SType.N);
		assert(b.type == SType.N);
		return STree.makeB(a.num < b.num);
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
	string[] blList = ["+", "-", "=", "<", "if", "define", "lambda"];
	foreach (s; blList) {
		env.add(s, STree.makeBL(s));
	}
	return env;
}

STree execS(STree s, STree env) {
	final switch (s.type) {
	case SType.Null:
		assert(false); // !空リストは評価不可
		break;
	case SType.N:
		return s;
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
		break;
	case SType.L:
		assert(false);
		break;
	case SType.BL:
		assert(false);
		break;
	case SType.E:
		assert(false);
		break;
	}
	assert(false);
}