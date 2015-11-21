import std.exception;
import base, lambda, exec;

string[] syList = [
	"define", "set!", "lambda", "quote", "if",
	"define-syntax", "syntax-rules"
];



STree execSy(SSyntax s, STree arg, SEnv env) {
	final switch(s.s) {
	case "define":
		auto l = listExt(arg, 2, false);
		enforce(l[0].classinfo == SSymbol.classinfo, "defineの第1引数はシンボル");
		env.add((cast(SSymbol)l[0]).s, execS(l[1], env));
		return l[0];
	case "set!":
		auto l = listExt(arg, 2, false);
		enforce(l[0].classinfo == SSymbol.classinfo, "set!の第1引数はシンボル");
		env.set((cast(SSymbol)l[0]).s, execS(l[1], env));
	case "lambda":
		return new SLambda(env, (cast(SPair)arg));
	case "quote":
		auto l = listExt(arg, 1, false);
		return l[0];
	case "if":
		auto l = listExt(arg, 3, false);
		auto a = execS(l[0], env);
		if (a.classinfo != SBool.classinfo || (cast(SBool)a).b != false) {
			// #t
			return execS(l[1], env);
		}
		return execS(l[2], env);
	case "define-syntax":
		auto l = listExt(arg, 2, false);
		return l[0];
	}
	assert(false);
}
