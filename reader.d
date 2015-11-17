import std.exception : enforce;
import base;

class ReaderBase {
	import std.stdio : File;
	File f;
	bool isR;
	char nowB;
	this(File f) {
		this.f = f;
		isR = false;
	}
	char read() {
		auto po = f.tell;
		f.readf("%c", &nowB);
		if (f.tell == po) {
			nowB = '\0';
		}
		return nowB;
	}
	char now() {
		if (isR) return nowB;
		char c = read();
		isR = true;
		return c;
	}
	char pop() {
		if (isR) {
			isR = false;
			return nowB;
		}
		return read();
	}
}

class Reader {
	ReaderBase f;
	bool isR;
	string nowB;
	this(ReaderBase f) {
		this.f = f;
		isR = false;
	}
	string read() {
		import std.ascii : isWhite;
		while (f.now != '\0' && isWhite(f.now)) {
			import std.stdio : writeln;
			f.pop;
		}
		nowB = "" ~ f.pop;
		if (nowB == "\0") {
			return nowB;
		}
		if (nowB == "(") {
			if (f.now == ')') {
				nowB ~= f.pop; // f.pop == ')'
			}
			return nowB;
		}
		if (nowB == ")" || nowB == "'") {
			return nowB;
		}
		while (true) {
			char n = f.now;
			if (n == '(' || n == ')' || n == '\0' || isWhite(n)) break;
			nowB ~= f.pop;
		}
		return nowB;
	}
	string nowW() {
		if (isR) return nowB;
		string s = read();
		isR = true;
		return s;
	}
	string popW() {
		if (isR) {
			isR = false;
			return nowB;
		}
		return read();
	}
}


bool isSymbol(string s) {
	import std.ascii : letters, digits;
	import std.string : indexOf;
	if (s.length == 0) return false;
	if (s == "+" || s == "-") return true;
	immutable string fi = letters ~ "!$%&*/:<=>?^_~";
	immutable string ba = fi ~ digits ~ "+-.@";
	if (fi.indexOf(s[0]) == -1) return false;
	foreach (char c; s[1..$]) {
		if (ba.indexOf(c) == -1) return false;
	}
	return true;
}

STree readS(Reader f) {
	import std.ascii : isDigit;
	import std.conv : to;
	string s = f.popW;
	if (s == "()") return new SNull();
	if (s == "'") {
		return new SPair(new SSymbol("quote"), new SPair(readS(f), new SNull));
	}
	if (isDigit(s[0])) {
		return new SNum(to!int(s));
	}
	if (s[0] == '#') {
		enforce(s.length == 2, s ~ " は不正な単語");
		enforce(s[1] == 't' || s[1] == 'f', s ~ " は不正な単語");
		if (s[1] == 't') {
			return new SBool(true);
		} else {
			return new SBool(false);
		}
	}
	if (s == "(") {
		SPair fp = new SPair(readS(f), new SNull());
		SPair p = fp;
		while (true) {
			if (f.nowW == ".") {
				f.popW;
				p.r = readS(f);
				enforce(f.nowW == ")", "とじカッコがない");
				f.popW;
				break;
			}
			if (f.nowW == ")") {
				f.popW;
				break;
			}
			SPair np = new SPair(readS(f), new SNull());
			p.r = np;
			p = np;
		}
		return fp;
	}
	if (isSymbol(s)) {
		return new SSymbol(s);
	}
	return null;
}
