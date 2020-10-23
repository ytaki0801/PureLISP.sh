[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/)

# jmclisp.sh

Hash tag on SNS: [`#jmclisp_sh`](https://twitter.com/hashtag/jmclisp_sh)

This software is a Pure LISP interpreter written in shell script conformed to POSIX shell,
inspired from [John McCarthy's 1960 paper](http://www-formal.stanford.edu/jmc/recursive/recursive.html)
and ported from [Paul Graham's Common Lisp implementation](http://paulgraham.com/lispcode.html).

[![BusyBox](https://img.shields.io/badge/BusyBox-1.33.0-brightgreen)](https://www.busybox.net/)

## Purpose of this software

* To use in education and research of basic LISP language processing easily

* To use in ALL computer environments by running on a POSIX-conformant shell

## How to use

Run the script to use REPL, like the following on [busybox-w32](https://frippery.org/busybox/) in a Command Prompt of Windows 10.
**You must type a blank line after input of LISP codes to eval**.

```
C:\Users\TAKIZAWA Yozo\busybox>busybox.exe sh jmclisp.sh
S> (def reduce
     '(lambda (f L i)
        (cond ((null L) i)
              (t (f (car L) (reduce f (cdr L) i))))))

reduce
S> (reduce 'cons '(a b c) '(d e f g))

(a b c d e f g)
S> (def rappend '(lambda (x y) (reduce 'cons x y)))

rappend
S> (reduce 'rappend '((a b) (c d e) (f) (g h i)) '())

(a b c d e f g h i)
S> exit


C:\Users\TAKIZAWA Yozo\busybox>
```

Or, you can send a text file of LISP codes to jmclisp.sh with "-s" option, prompt suppression mode, via redirection in a shell interpreter.

```
C:\Users\TAKIZAWA Yozo\busybox>busybox sh
~/busybox $ cat assoc.jmclisp
(def mkassoc
  '(lambda (a b)
     (cond ((or (null a) (null b)) nil)
           (t (cons (cons (car a) (car b))
                    (mkassoc (cdr a) (cdr b)))))))

(def vs (mkassoc '(hoge hage hige) '(10 20 30)))

(def assoc
  '(lambda (k vs)
     (cond ((eq vs '()) nil)
           ((eq (car (car vs)) k)
            (car vs))
           (t (assoc k (cdr vs))))))

(assoc 'hage vs)

(car (assoc 'hage vs))

(cdr (assoc 'hage vs))

exit

~/busybox $ ./jmclisp.sh -s < assoc.jmclisp
mkassoc
vs
assoc
(hage . 20)
hage
20
~/busybox $
```

## LISP Specification

* Built-in functions: `cons`, `car`, `cdr`, `atom`, `eq`, `and`, `or` and utility functions to define the evaluator

* Special forms: `quote`, `cond`, `lambda` (the arguments are dynamically scoped)

* Special form `def` to bind variables in global environment with quoted values, including lambda expressions

* Simple S-expression input and output functions

* Simple REPL with `exit` command and `-s` prompt suppression mode

## Bugs and TODO

* More suitable error checks

* More suitable S-expression input for REPL and lisp script execution

## License

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
