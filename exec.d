import std.stdio, std.exception;
import base, reader, baselambda;


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
//	assert(s.p.r.r.type == SType.Null);
	STree fenv = STree.makeE(s.e);
	extArg(s.p.l, arg, fenv, env);
	STree[] l = listArgNE(s.p.r, 1, true);
	foreach (d; l[0..$-1]) {
		execS(d, fenv);
	}
	return execS(l[$-1], fenv);
}

STree firstenv() {
	STree env = STree.makeE(null);
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