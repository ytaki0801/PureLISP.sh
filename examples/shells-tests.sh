#!/bin/sh

LISP=PureLISP.sh

TESTCODE="(def list (lambda x x))

(def defun
  (macro (name args body)
    (list 'def name (list 'lambda args body))))

(defun append2 (a b)
    (cond ((eq a nil) b)
          (t (cons (car a) (append2 (cdr a) b)))))

(append2 '(1 2 3) '(x y z))

exit

"

for SHL in sh ksh bash yash $1
do
  if type $SHL > /dev/null 2>&1; then
    printf "$LISP test on $SHL:\n"
    printf "$TESTCODE" | $SHL $LISP -snl
    printf "\n"
  fi
done


