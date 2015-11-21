import std.exception;
import std.stdio;

import base, reader, smacro, exec;

int main(string argv[]) {
	stderr.writeln(argv);
	enforce(argv.length == 2);

	auto st = new Reader(new StringReader(import("first.scm")));
	auto re = new Reader(new FileReader(File(argv[1], "r")));
	SEnv ev = firstEnv();
	SEnv mc = firstMacro();
	while (true) {
		auto r = readS(st, true);
		if (r is null) break;
		stderr.writeln("read: ", r);
		r = execM(r, mc, ev);
		stderr.writeln("macro: ", r, ev.mp);
		r = execS(r, ev);
		stderr.writeln("exec: ", r);
	}
	while (true) {
		auto r = readS(re, false);
		if (r is null) break;
		stderr.writeln("read: ", r);
		r = execM(r, mc, ev);
		stderr.writeln("macro: ", r);
		r = execS(r, ev);
		stderr.writeln("exec: ", r);
	}
	return 0;
}
