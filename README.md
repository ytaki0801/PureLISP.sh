[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/)

# jmclisp.sh

Hash tag on SNS: [`#jmclisp_sh`](https://twitter.com/hashtag/jmclisp_sh)

This software is a Pure LISP interpreter written in shell script conformed to POSIX shell,
inspired from [John McCarthy's 1960 paper](http://www-formal.stanford.edu/jmc/recursive/recursive.html)
and [Paul Graham's Common Lisp implementation](http://paulgraham.com/lispcode.html).

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
~/busybox $ cat examples/assoc.jmclisp
(def or '(lambda (a b) (cond (a t) (t b))))

(def mkassoc
  '(lambda (a b)
     (cond ((or (eq a nil) (eq b nil)) nil)
           (t (cons (cons (car a) (car b))
                    (mkassoc (cdr a) (cdr b))))))) 

(def k '(Apple Orange Lemmon))

(cons '= (cons k nil))

(def v '(120 210 180))

(cons '= (cons v nil))

(def vs (mkassoc k v))

(cons '= (cons '(mkassoc k v) (cons '= (cons vs 'nil))))

(def assoc
  '(lambda (k vs)
     (cond ((eq vs '()) nil)
           ((eq (car (car vs)) k)
            (car vs))
           (t (assoc k (cdr vs))))))

(cons '(assoc 'Orange vs)
(cons '= (cons (assoc 'Orange vs) nil)))

(cons '(car (assoc 'Orange vs))
(cons '= (cons (car (assoc 'Orange vs)) nil)))

(cons '(cdr (assoc 'Orange vs))
(cons '= (cons (cdr (assoc 'Orange vs)) nil)))

exit

~/busybox $ ./jmclisp.sh -s < examples/assoc.jmclisp
or
mkassoc
k
(= (Apple Orange Lemmon))
v
(= (120 210 180))
vs
(= (mkassoc k v) = ((Apple . 120) (Orange . 210) (Lemmon . 180)))
assoc
((assoc (quote Orange) vs) = (Orange . 210))
((car (assoc (quote Orange) vs)) = Orange)
((cdr (assoc (quote Orange) vs)) = 210)
~/busybox $ 
```

## LISP Specification in this software

* Built-in functions: `cons`, `car`, `cdr`, `atom`, `eq`

* Special forms: `quote`, `cond`, `lambda` (the arguments are dynamically scoped)

* Special form `def` to bind variables in global environment with quoted values, including lambda expressions

* Simple S-expression input and output functions

* Simple REPL with `exit` command and `-s` prompt suppression mode

## Bugs and TODO

* More suitable error checks

* Introducing lexically scoped variables in lambda expressions

## License

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
