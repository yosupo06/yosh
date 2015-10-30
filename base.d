import std.format;
import std.conv;


enum SType {
	Null, // null
	N, // number 
	B, // bool
	S, // symbol
	P, // pair
	L, // lambda
	BL, // base lambda
	E, // enviroment
}

class STree {
	SType type;
	union {
		int num; // number
		bool b; // boolean
		string s; // symbol
		struct { // pair
			STree l, r;
		}
		struct { // lambda
			STree e; // enviroment
			STree p; // program
		}
		string n; // base lambda
		struct { // enviroment
			string name; // name
			STree d; // data
			STree next; // next
		}
	}

	static STree makeNull() {
		auto s = new STree();
		s.type = SType.Null;
		return s;
	}
	static STree makeN(int n) {
		auto s = new STree();
		s.type = SType.N;
		s.num = n;
		return s;
	}
	static STree makeS(string st) {
		auto s = new STree();
		s.type = SType.S;
		s.s = st;
		return s;
	}
	static STree makeB(bool b) {
		auto s = new STree();
		s.type = SType.B;
		s.b = b;
		return s;
	}
	static STree makeP(STree l, STree r) {
		auto s = new STree();
		s.type = SType.P;
		s.l = l; s.r = r;
		return s;
	}
	static STree makeBL(string st) {
		auto s = new STree();
		s.type = SType.BL;
		s.n = st;
		return s;
	}
	static STree makeE(string st, STree d, STree n) {
		auto s = new STree();
		s.type = SType.E;
		s.name = st;
		s.d = d;
		s.next = n;
		return s;
	}
	STree check(string s) {
		assert(type == SType.E);
		if (s == name) return d;
		assert(next);
		return next.check(s);
	}
	void toString(scope void delegate(const(char)[]) sink, FormatSpec!char fmt) const {
		final switch(type) {
		case SType.Null:
			sink("()");
			break;
		case SType.N:
			sink(to!string(num));
			break;
		case SType.B:
			sink("Bool");
			break;
		case SType.S:
			sink(s);
			break;
		case SType.P:
			sink("(");
			sink(to!string(l));
			sink(" . ");
			sink(to!string(r));
			sink(")");
			break;
		case SType.L:
			sink("Lambda");
			break;
		case SType.BL:
			sink("BaseLambda");
			break;
		case SType.E:
			sink("Enviroment");
    	}
    }
}
