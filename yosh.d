import std.exception;
import std.stdio;

import base, reader, exec;

int main(string argv[]) {
	writeln(argv);
	enforce(argv.length == 2);

	auto re = new Reader(File(argv[1], "r"));
	STree env = firstenv;

	while (true) {
		auto r = readS(re);
		if (r is null) break;
		writeln("exec: ", r);
		writeln(execS(r, env));

	}
	return 0;
}