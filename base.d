class STree {
}

class SNum : STree {
	int num;
	this(int num) {
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
		this.s = s;
	}
	override string toString() {
		return s;
	}
}

class SPair : STree {
	STree l, r;
	this(STree l, STree r) {
		this.l = l;
		this.r = r;
	}
	override string toString() {
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
//		return "(" ~ l.toString ~ ", " ~ r.toString ~ ")";
	}
}

class SLambda : STree {
	SEnv e; //env
	SPair p; //program(arg program)
	this (SEnv e, SPair p) {
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
		this.s = s;
	}
	override string toString() {
		return "BaseLambda";
	}
}
class SEnv : STree {
	import std.exception : enforce;
	STree[string] mp;
	SEnv next;
	this(SEnv next) {
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
}

class SNull : STree {
	override string toString() {
		return "'()";
	}
}

unittest {
	import std.stdio : writeln;
	STree s = new STree();
	SNum n = new SNum();
	STree ss = n;
	writeln(s, " ", n, " ", ss);
}
