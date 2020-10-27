[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/)

# PureLISP.sh

Hash tag on SNS: [`#PureLISP_sh`](https://twitter.com/hashtag/PureLISP_sh)

This software is a Pure LISP interpreter written in shell script conformed to POSIX shell,
inspired from
[John McCarthy's 1960 paper](http://www-formal.stanford.edu/jmc/recursive/recursive.html),
[Paul Graham's Common Lisp implementation](http://paulgraham.com/lispcode.html),
[Lispkit Lisp](https://github.com/hanshuebner/secd/tree/master/lispkit),
[MIT's Structure and Interpretation of Computer Programs](https://mitpress.mit.edu/sites/default/files/sicp/index.html)
and [Peter Norvig's Lispy](https://norvig.com/lispy.html)

## Purpose of this software

* To use in education and research of basic LISP language processing easily
* To use in ALL computer environments by running on a POSIX-conformant shell

[![BusyBox_ash](https://img.shields.io/badge/BusyBox_ash-1.33.0-brightgreen)](https://www.busybox.net/)
[![NetBSD_sh](https://img.shields.io/badge/NetBSD_sh-20181212-brightgreen)](http://cvsweb.netbsd.org/bsdweb.cgi/src/bin/sh/)
[![dash](https://img.shields.io/badge/dash-0.5.10.2-brightgreen)](http://gondor.apana.org.au/~herbert/dash/)
[![NetBSD_ksh_(pdksh)](https://img.shields.io/badge/NetBSD_ksh_(pdksh)-v5.2.14_(not_supported)-red)](http://cvsweb.netbsd.org/bsdweb.cgi/src/bin/ksh/)
[![ksh93](https://img.shields.io/badge/ksh93-93u+-brightgreen)](http://kornshell.org/)
[![mksh](https://img.shields.io/badge/mksh-R59b-brightgreen)](http://www.mirbsd.org/mksh.htm)
[![oksh](https://img.shields.io/badge/oksh-6.7-brightgreen)](https://github.com/ibara/oksh)
[![Bash](https://img.shields.io/badge/Bash-5.0.3-brightgreen)](https://www.gnu.org/software/bash/)
[![yash](https://img.shields.io/badge/yash-2.48-brightgreen)](https://yash.osdn.jp/index.html.en)
[![bosh%2fpbosh](https://img.shields.io/badge/bosh%2fpbosh-2020%2f04%2f27-brightgreen)](http://schilytools.sourceforge.net/bosh.html)

## How to use

Run the script to use REPL, like the following on [busybox-w32](https://frippery.org/busybox/) in a Command Prompt of Windows 10.
**You must type a blank line after input of LISP codes to eval**.

```
C:\Users\TAKIZAWA Yozo\busybox>busybox.exe sh PureLISP.sh
S> (def reduce
     (lambda (f L i)
       (cond ((eq L nil) i)
             (t (f (car L) (reduce f (cdr L) i))))))

reduce
S> (reduce cons '(a b c) '(d e f g))

(a b c d e f g)
S> (def rappend (lambda (x y) (reduce cons x y)))

rappend
S> (reduce rappend '((a b) (c d e) (f) (g h i)) ())

(a b c d e f g h i)
S> exit


C:\Users\TAKIZAWA Yozo\busybox>
```

Or, you can send a text file of LISP codes to PureLISP.sh with "-s" option,
prompt suppression mode, via redirection in a shell interpreter.

```
C:\Users\TAKIZAWA Yozo\busybox>busybox.exe sh
~/busybox $ cat examples/fibonacci.plsh
(def append
  (lambda (a b)
     (cond ((eq a nil) b)
           (t (append (cdr a)
              (cons (car a) b))))))

(def fib
  (lambda (n)
     (cond ((eq n '()) '())
           ((eq (cdr n) '()) '(0))
           (t (append (fib (cdr n))
                      (fib (cdr (cdr n))))))))

(def ten '(0 0 0 0 0 0 0 0 0 0))

(cons '(fib ten) (cons '=
(cons (length (fib ten)) nil)))

(def fib2
  (lambda (n f1 f2)
     (cond ((eq n nil) f1)
           (t (fib2 (cdr n) f2 (append f1 f2))))))

(def zero '())

(def one '(0))

(cons '(fib2 ten zero one) (cons '=
(cons (length (fib2 ten zero one)) nil)))

exit

~/busybox $ sh PureLISP.sh -s < examples/fibonacci.plsh
append
fib
ten
((fib ten) = 55)
fib2
zero
one
((fib2 ten zero one) = 55)
~/busybox $ exit

C:\Users\TAKIZAWA Yozo\busybox>
```

## LISP Specification in this software

* Built-in functions in Pure LISP: `cons`, `car`, `cdr`, `atom`, `eq`
* Built-in functions not in Pure LISP: `length` to treat lists as numbers
* Special forms: `quote`, `cond` and lexically scoped `lambda`
* Special form `def` to bind variables in global environment
* Simple S-expression input and output functions
* Simple REPL with `exit` command and `-s` prompt suppression mode

## Shell Programming in this software

* Conscells are firstly implemented to program as a metacircular evaluator
* Pseudo-Array and Stack implementation by using gloval variables
* Using pattern-matching, to do S-expression lexical analysis especially
* Firstly implemented as a John McCarthy's Original Lisp evaluator but now a SICP's one

## Bugs and TODO

* Introducing tail call optimization
* More suitable error checks
* Much more comments in the source code

## License

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
