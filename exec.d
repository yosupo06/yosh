import std.stdio;
import base;

STree refArg(STree arg, int n) {
	assert(0 <= n);
	assert(arg.type == SType.P);
	if (n == 0) return arg.l;
	return refArg(arg.r, n-1);
}

STree execBL(STree s, STree arg, ref STree env) {
	assert(s.type == SType.BL);
	final switch (s.n) {
	case "define":
		auto a = refArg(arg, 0);
		auto b = execS(refArg(arg, 1), env);
		assert(a.type == SType.S);
		env = STree.makeE(a.s, b, env);
		return a;
	case "lambda":
		break;
	case "+":
		auto a = execS(refArg(arg, 0), env);
		auto b = execS(refArg(arg, 1), env);
		assert(a.type == SType.N);
		assert(b.type == SType.N);
		return STree.makeN(a.num + b.num);
	}
	assert(0);
}

STree firstenv() {
	STree env = null;
	env = STree.makeE("+", STree.makeBL("+"), env);
	env = STree.makeE("define", STree.makeBL("define"), env);
	return env;
}

STree execS(STree s, ref STree env) {
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
			assert(false);
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