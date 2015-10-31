import std.exception;
import std.stdio;
import base;

class Reader {
	File f;
	char now;
	this(File ff) {
		f = ff;
		auto po = f.tell;
		f.readf("%c", &now);
		if (f.tell == po) {
			now = '\0';
		}
	}
	char pop() {
		char res = now;
		auto po = f.tell;
		f.readf("%c", &now);
		if (f.tell == po) {
			now = '\0';
		}
		return res;
	}
	char popW() { // pop white
		import std.ascii;
		char res;
		while (true) {
			res = now;
			if (res == '\0' || !isWhite(res)) break;
			pop();
		}
		return res;
	}
}

bool isStrFirst(char c) {
	import std.ascii;
	if (c == '\0') return false;
	if (isWhite(c)) return false;
	if (c == '#') return false;
	if (c == '.') return false;
	if (c == '(') return false;
	if (c == ')') return false;
	if (isDigit(c))	return false;
	return true;
}
bool isStrChar(char c) {
	import std.ascii;
	if (c == '\0') return false;
	if (isWhite(c)) return false;
	if (c == '#') return false;
	if (c == '.') return false;
	if (c == '(') return false;
	if (c == ')') return false;
	return true;
}

int readN(Reader f) {
	import std.ascii;
	int s = 0;
	while (isDigit(f.now)) {
		s *= 10;
		s += f.pop - '0';
	}
	return s;
}

string readA(Reader f) {
	import std.ascii;
	string s = "" ~ f.pop;
	while (isStrChar(f.now)) {
		s ~= f.pop;
	}
	return s;
}

STree readP(Reader f) {
	import std.ascii;
	auto l = readS(f);

	f.popW;
	char c = f.now;
	if (c == '.') {
		f.pop;
		STree r = readS(f);
		return STree.makeP(l, r);
	} else if (c == ')') {
		return STree.makeP(l, STree.makeNull);
	} else {
		return STree.makeP(l, readP(f));
	}
}

STree readS(Reader f) {
	import std.ascii;

	f.popW;
	char c = f.now;

	if (isDigit(c)) {
		return STree.makeN(readN(f));
	} else if (c == '#') {
		f.pop;
		c = f.pop;
		if (c == 't') {
			return STree.makeB(true);
		} else if (c == 'f') {
			return STree.makeB(false);
		} else {
			assert(false);
		}
	} else if (c == '(') {
		f.pop;
		f.popW;

		c = f.now;
		if (c == ')') {
			f.pop;
			return STree.makeNull;
		}
		STree l = readS(f);
		f.popW;
		c = f.now;
		if (c == '.') {
			f.pop;
			STree r = readS(f);
			return STree.makeP(l, r);
		} else if (c == ')') {
			f.pop;
			return STree.makeP(l, STree.makeNull);
		} else {
			STree r = readP(f);
			f.popW;
			assert(f.now == ')');
			f.pop;
			return STree.makeP(l, r);
		}
	} else if (isStrFirst(c)) {
		return STree.makeS(readA(f));
	}
	return null;
}
