import std.exception;
import std.stdio;

import base, reader, smacro, exec;

int main(string argv[]) {
	stderr.writeln(argv);
	enforce(argv.length == 2);

	auto re = new Reader(new ReaderBase(File(argv[1], "r")));
	SEnv ev = firstEnv();
	while (true) {
		auto r = readS(re);
		if (r is null) break;
		stderr.writeln("read: ", r);
		r = execM(r);
		stderr.writeln("macro: ", r);
		r = execS(r, ev);
		stderr.writeln("exec: ", r);
	}
	return 0;
}
