#!/bin/sh

if [ ! $# = 3 ]; then
  printf "Usage: $0 SHELL JMCLISP NUM\n"
  printf "Now using default settings\n"
  SHL="dash"
  JMCLISP="./jmclisp.sh"
  COUNT=10
else
  SHL=$1
  JMCLISP=$2
  COUNT=$3
fi

CNUM=0
NUM=
while [ $CNUM -lt $COUNT ]
do
  NUM="$NUM 0"
  CNUM=$((CNUM+1))
done

COMMON="(def append
  '(lambda (a b)
     (cond ((eq a nil) b)
           (t (append (cdr a)
              (cons (car a) b))))))

(def zero '())

(def one '(0))

(def num '($NUM))

"

FIB1="(def fib
  '(lambda (n)
     (cond ((eq n '()) '())
           ((eq (cdr n) '()) '(0))
           (t (append (fib (cdr n))
                      (fib (cdr (cdr n))))))))

(cons '(fib num) (cons '= (cons (length (fib num)) nil)))

exit

"

FIB2="(def fib2
  '(lambda (n f1 f2)
     (cond ((eq n '()) f1)
           (t (fib2 (cdr n) f2 (append f1 f2))))))

(cons '(fib2 num zero one) (cons '= (cons (length (fib2 num zero one)))))

exit

"

printf "(fibonacci $COUNT) processing time test on $SHL $JMCLISP\n\n"
date
printf "%s%s" "$COMMON" "$FIB1" | $SHL $JMCLISP -s
date
printf "%s%s" "$COMMON" "$FIB2" | $SHL $JMCLISP -s
date

