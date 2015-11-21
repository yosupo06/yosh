enum SType {
	Null,
	Symbol,
	Pair,
	Syntax,
	Lambda,
	BLambda,
	Env,
	Bool,
	Num,
}


class STree {
	const SType type;
	this(SType t) {
		type = t;
	}
}

class SNum : STree {
	int num;
	this(int num) {
		super(SType.Num);
		this.num = num;
	}
	override string toString() {
		import std.conv : to;
		return to!string(num);
	}
}

class SBool : STree {
	bool b;
	this(bool b) {
		super(SType.Bool);
		this.b = b;
	}
	override string toString() {
		if (b == false) {
			return "#f";
		} else {
			return "#t";
		}
	}
}

class SSymbol : STree {
	string s;
	this(string s) {
		super(SType.Symbol);
		this.s = s;
	}
	override string toString() {
		return s;
	}
}

class SPair : STree {
	STree l, r;
	this(STree l, STree r) {
		super(SType.Pair);
		this.l = l;
		this.r = r;
	}
	override string toString() {
		import std.stdio;
		string re = "(" ~ l.toString;
		SPair p = this;
		while (typeid(p.r) == typeid(SPair)) {
			p = cast(SPair)p.r;
			re ~= " " ~ p.l.toString;
		}
		if (typeid(p.r) != typeid(SNull)) {
			re ~= " . " ~ p.r.toString;
		}
		re ~= ")";
		return re;
	}
}

class SSyntax : STree {
	string s;
	this(string s) {
		super(SType.Syntax);
		this.s = s;
	}
	override string toString() {
		return "Syntax(" ~ s ~ ")";
	}
}

class SLambda : STree {
	SEnv e; //env
	SPair p; //program(arg program)
	this (SEnv e, SPair p) {
		super(SType.Lambda);
		this.e = e;
		this.p = p;
	}
	override string toString() {
		return "Lambda";
	}
}

class SBLambda : STree {
	string s;
	this(string s) {
		super(SType.BLambda);
		this.s = s;
	}
	override string toString() {
		return "##"~this.s;
		return "BaseLambda";
	}
}

class SEnv : STree {
	import std.exception : enforce;
	STree[string] mp;
	SEnv next;
	this(SEnv next) {
		super(SType.Env);
		this.next = next;
	}

	void add(string s, STree d) {
		mp[s] = d;
	}
	void set(string s, STree d) {
		if (get(mp, s, null)) {
			mp[s] = d;
			return;
		}
		enforce(next, s ~ " は未定義");
		next.set(s, d);
	}
	STree at(string s) {
		if (get(mp, s, null)) {
			return mp[s];
		}
		enforce(next, s ~ " は未定義");
		return next.at(s);
	}
	bool have(string s) {
		if (get(mp, s, null)) {
			return true;
		}
		if (next is null) return false;
		return next.have(s);
	}
}

class SNull : STree {
	this() {
		super(SType.Null);
	}
	override string toString() {
		return "()";
	}
}

