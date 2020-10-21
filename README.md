[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/)

# jmclisp.sh

This software is a Pure LISP interpreter written in shell script conformed to POSIX shell,
inspired from [John McCarthy's 1960 paper](http://www-formal.stanford.edu/jmc/recursive/recursive.html)
and ported from [Paul Graham's Common Lisp implementation](http://paulgraham.com/lispcode.html).

## Purpose of this software

* To use in education and research of basic LISP language processing easily

* To use in ALL computer environments by running on a POSIX-conformant shell

## How to use

Run the script to use REPL, like the following on [busybox-w32](https://frippery.org/busybox/) in a Command Prompt of Windows 10.
**You must type a blank line after input of LISP codes to eval**.

```
C:\Users\TAKIZAWA Yozo\busybox>busybox.exe sh jmclisp.sh
S> (def mapcar
     '(lambda (f x)
        (cond ((null x) nil)
              (t (cons (f (car x))
                       (mapcar f (cdr x)))))))

mapcar
S> (mapcar 'car '((hoge . 10) (hage . 20) (hige . 30)))

(hoge hage hige)
S> (mapcar 'cdr '((hoge . 10) (hage . 20) (hige . 30)))

(10 20 30)
S> (def filter
     '(lambda (f x)
        (cond ((null x) nil)
              ((f (car x))
               (cons (car x) (filter f (cdr x))))
              (t (filter f (cdr x))))))

filter
S> (filter
     '(lambda (x) (eq (car x) 'o))
     '((o . 1) (i . 2) (o . 3) (a . 4) (z . 5) (o . 6)))

((o . 1) (o . 3) (o . 6))
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
$ cat sample.jmclisp
(def mapcar
  '(lambda (f x)
     (cond ((null x) nil)
           (t (cons (f (car x))
                    (mapcar f (cdr x)))))))

(mapcar 'car '((hoge . 10) (hage . 20) (hige . 30)))

(mapcar 'cdr '((hoge . 10) (hage . 20) (hige . 30)))

(def filter
  '(lambda (f x)
     (cond ((null x) nil)
           ((f (car x))
            (cons (car x) (filter f (cdr x))))
           (t (filter f (cdr x))))))

(filter
  '(lambda (x) (eq (car x) 'o))
  '((o . 1) (i . 2) (o . 3) (a . 4) (z . 5) (o . 6)))

(def reduce
  '(lambda (f L i)
     (cond ((null L) i)
           (t (f (car L) (reduce f (cdr L) i))))))

(reduce 'cons '(a b c) '(d e f g))

(def rappend '(lambda (x y) (reduce 'cons x y)))

(reduce 'rappend '((a b) (c d e) (f) (g h i)) '())

exit

$ sh jmclisp.sh -s < sample.jmclisp
mapcar
(hoge hage hige)
(10 20 30)
filter
((o . 1) (o . 3) (o . 6))
reduce
(a b c d e f g)
rappend
(a b c d e f g h i)
$ 
```

## LISP Specification

* Built-in functions: `cons`, `car`, `cdr`, `atom`, `eq`, `and`, `or` and utility functions to define the evaluator

* Special forms: `quote`, `cond`, `lambda`

* Special form `def` to bind variables in global environment with quoted values, including lambda expressions

* S-expression input and output functions

* Simple REPL

## Bugs and TODO

* Overwrited second arguments of two-argument functions in serial processing by the evaluator

This is a **fatal error for LISP processing**,
derived from using global variables in the shell script to conform to a POSIX shell, like the following:

```
S> (cons 'a (cons 'b (cons 'c nil)))

(a b c)
S> (cons (cons (cons nil 'a) 'b) 'c)

(((() . a) . a) . a)
```

* More suitable error checks

## License

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
