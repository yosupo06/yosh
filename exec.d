import std.stdio, std.exception;
import base, reader, lambda;



SEnv firstEnv() {
	SEnv env = new SEnv(null);
	foreach (s; blList) {
		env.add(s, new SBLambda(s));
	}
	return env;
}

STree execS(STree s, SEnv env) {
	if (typeid(s) == typeid(SNull)) {
		throw new Exception("空リストは評価不可");
	} else if (typeid(s) == typeid(SNum) || typeid(s) == typeid(SBool)) {
		return s;
	} else if (typeid(s) == typeid(SSymbol)) {
		return env.at((cast(SSymbol)s).s);
	} else if (typeid(s) == typeid(SPair)) {
		auto l = execS((cast(SPair)s).l, env);
		if (typeid(l) == typeid(SLambda)) {
			return execL(cast(SLambda)l, (cast(SPair)s).r, env);
		} else if (typeid(l) == typeid(SBLambda)) {
			return execBL(cast(SBLambda)l, (cast(SPair)s).r, env);
		}
		throw new Exception("Pairの左側はLambda / BLambda");
	} else {
		throw new Exception("評価不可");
	}
}