import std.exception : enforce;
import base;

interface ReaderBase {
	char read();
}

class StringReader : ReaderBase {
	string s;
	int c = 0;
	this(string s) {
		this.s = s;
	}
	char read() {
		if (c == s.length) {
			return '\0';
		}
		return s[c++];
	}
}

class FileReader : ReaderBase {
	import std.stdio : File;
	File f;
	this(File f) {
		this.f = f;
	}
	char read() {
		char now;
		auto po = f.tell;
		f.readf("%c", &now);
		if (f.tell == po) {
			now = '\0';
		}
		return now;
	}
}


class Reader {
	ReaderBase f;
	this(ReaderBase f) {
		this.f = f;
		isCR = false;
		isR = false;
	}

	bool isCR;
	char nowCB;
	char readC() {
		char c = f.read();
		if (c == ';') {
			while (c != '\n') c = f.read();
		}
		return c;
	}
	char now() {
		if (isCR) return nowCB;
		nowCB = readC();
		isCR = true;
		return nowCB;
	}
	char pop() {
		if (isCR) {
			isCR = false;
			return nowCB;
		}
		return (nowCB = readC());
	}

	bool isR;
	string nowB;
	string read() {
		import std.ascii : isWhite;
		while (now != '\0' && isWhite(now)) {
			pop;
		}
		nowB = "" ~ pop;
		if (nowB == "\0") {
			return nowB;
		}
		if (nowB == "(") {
			if (now == ')') {
				nowB ~= pop;
			}
			return nowB;
		}
		if (nowB == ")" || nowB == "'") {
			return nowB;
		}
		while (true) {
			char n = now;
			if (n == '(' || n == ')' || n == '\0' || isWhite(n)) break;
			nowB ~= pop;
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
	if (s == ".") return false;
	immutable string fi = letters ~ "!$%&*+-./:<=>?@^_~";
	immutable string ba = fi ~ digits;
	if (fi.indexOf(s[0]) == -1) return false;
	foreach (char c; s[1..$]) {
		if (ba.indexOf(c) == -1) return false;
	}
	return true;
}

STree readS(Reader f, bool first) {
	import std.ascii : isDigit;
	import std.conv : to;
	string s = f.popW;
	if (s == "()") return new SNull();
	if (s == "(") {
		SPair fp = new SPair(readS(f, first), new SNull());
		SPair p = fp;
		while (true) {
			if (f.nowW == ".") {
				f.popW;
				p.r = readS(f, first);
				enforce(f.nowW == ")", "とじカッコがない");
				f.popW;
				break;
			}
			if (f.nowW == ")") {
				f.popW;
				break;
			}
			SPair np = new SPair(readS(f, first), new SNull());
			p.r = np;
			p = np;
		}
		return fp;
	}
	if (s == "'") {
		return new SPair(new SSymbol("quote"), new SPair(readS(f, first), new SNull));
	}
	if (isDigit(s[0])) {
		return new SNum(to!int(s));
	}
	if (s == "#t") {
		return new SBool(true);
	}
	if (s == "#f") {
		return new SBool(false);
	}
	if (s == "#\\newline") {
		return new SSymbol("\n");
	}
	if (s.length >= 2 && s[0..2] == "##") {
		enforce(first, "不正シンボル");
		return new SBLambda(s[2..$]);
	}
	if (isSymbol(s)) {
		return new SSymbol(s);
	}
	return null;
}
