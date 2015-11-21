import std.stdio, std.exception;
import base, lambda, syntax;



SEnv firstEnv() {
	SEnv env = new SEnv(null);
	foreach (s; syList) {
		env.add(s, new SSyntax(s));
	}
	foreach (s; blList) {
		env.add(s, new SBLambda(s));
	}

	return env;
}

STree execS(STree s, SEnv env) {
	with (SType) final switch (s.type) {
	case BLambda:
	case Num:
	case Bool:
		return s;
	case Symbol:
		return env.at((cast(SSymbol)s).s);
	case Pair:
		auto l = execS((cast(SPair)s).l, env);
		if (l.type == Lambda) {
			return execL(cast(SLambda)l, (cast(SPair)s).r, env);
		}
		if (l.type == BLambda) {
			return execBL(cast(SBLambda)l, (cast(SPair)s).r, env);
		}
		if (l.type == Syntax) {
			return execSy(cast(SSyntax)l, (cast(SPair)s).r, env);
		}
		throw new Exception("Pairの左側はLambda / BLambda");
	case Null:
		throw new Exception("空リストは評価不可");
	case Syntax:
	case Lambda:
	case Env:
		throw new Exception("評価不可");
	}
}