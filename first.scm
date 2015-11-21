; syntax
; (##define-syntax define-syntax
; 	(##syntax-rules ()
; 		(
; 			(define-syntax x ...)
; 			(##define-syntax x ...)
; 		)
; 	)
; )

; (define-syntax syntax-rules
; 	(##syntax-rules ()
; 		(
; 			(syntax-rules x ...)
; 			(##syntax-rules x ...)
; 		)
; 	)
; )


(define-syntax and
	(syntax-rules ()
		(
			(and e1 e2)
			(if e1 e2 #f)
		)
		(
			(and e1 e2 ...)
			(if e1
				(and e2 ...)
				#f
			)
		)
	)
)

(define-syntax or
	(syntax-rules ()
		(
			(or e1 e2)
			(if e1 #t e2)
		)
		(
			(or e1 e2 ...)
			(if e1
				#t
				(or e2 ...)
			)
		)
	)
)

(define-syntax begin
	(syntax-rules ()
		(
			(begin arg)
			arg
		)
		(
			(begin arg1 arg2 earg ...)
			(or (and arg1 #f) (begin arg2 earg ...))
		)
	)
)


(define-syntax lambda
	(syntax-rules ()
		(
			(lambda x y z arg ...)
			(lambda x (begin y z arg ...))
		)
	)
)

(define-syntax define
	(syntax-rules ()
		(
			(define (f arg ...) x)
			(define f (lambda (arg ...) x))
		)
	)
)


(define-syntax cond
	(syntax-rules (else)
		(
			(cond (else arg ...))
			(begin arg ...)
		)
		(
			(cond (now arg ...))
			(if now
				(begin arg ...)
				#f)
		)
		(
			(cond (now arg ...) other ...)
			(if now
				(begin arg ...)
				(cond other ...)
			)
		)
	)
)

(define (not a)
	(if a
		#f
		#t
	)
)

; list
(define (filter f l)
	(cond
		((null? l) '())
		((f (car l)) (cons (car l) (filter f (cdr l))))
		(else (filter f (cdr l)))
	)
)

; number


(define (> a b) (< b a))

(define (max a b)
	(if (> a b)
		a
		b)
)

(define (even? a) (= (modulo a 2) 0))
(define (odd? a) (not (even? a)))

(define (newline)
	(display '#\newline)
)
