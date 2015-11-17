import base;

/*
 define-syntax, syntax-rules のみ実装
 syntax-rulesは
 (syntax-rules ()
 	((e1 e2 e3 .. en) (p1 p2 p3 .. pn))
 )
 の形式のみ
 不衛生
*/
STree execM(STree t) {
	if (typeid(t) == typeid(SPair)) {
		return t;
	} else {
		return t;
	}
}
