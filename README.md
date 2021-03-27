[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/)

# PureLISP.sh

* Hash tag on SNS: [`#PureLISP_sh`](https://twitter.com/hashtag/PureLISP_sh)
* Docker image: `docker run --rm -it ytaki0801/plsh`
* [PureLISP.js](https://ytaki0801.github.io/PureLISP.html), with same specification of PureLISP.sh

This software is a Pure LISP interpreter written in shell script conformed to POSIX shell,
inspired from
[John McCarthy's 1960 paper](http://www-formal.stanford.edu/jmc/recursive/recursive.html),
[Paul Graham's Common Lisp implementation](http://paulgraham.com/lispcode.html),
[Lispkit Lisp](https://github.com/hanshuebner/secd/tree/master/lispkit),
[MIT's Structure and Interpretation of Computer Programs](https://mitpress.mit.edu/sites/default/files/sicp/index.html),
[Peter Norvig's Lispy](https://norvig.com/lispy.html),
and [The Julia Programming Language's femtolisp/tiny](https://github.com/JeffBezanson/femtolisp/tree/master/tiny)

## Purpose of this software

* To use in education and research of basic LISP language processing easily
* To use in ALL computer environments by running on a POSIX-conformant shell

[![BusyBox_ash](https://img.shields.io/badge/BusyBox_ash-1.30.1-brightgreen)](https://www.busybox.net/)
[![NetBSD_sh](https://img.shields.io/badge/NetBSD_sh-20181212-brightgreen)](http://cvsweb.netbsd.org/bsdweb.cgi/src/bin/sh/)
[![dash](https://img.shields.io/badge/dash-0.5.9-brightgreen)](http://gondor.apana.org.au/~herbert/dash/)
[![NetBSD_ksh_(pdksh)](https://img.shields.io/badge/NetBSD_ksh_(pdksh)-v5.2.14_(not_supported)-red)](http://cvsweb.netbsd.org/bsdweb.cgi/src/bin/ksh/)
[![ksh93%2frksh93](https://img.shields.io/badge/ksh93%2frksh93-93u+-brightgreen)](http://kornshell.org/)
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

Or, you can send a text file of LISP codes to PureLISP.sh with "-snl" or "-sl" option,
prompt suppression mode, via redirection in a shell interpreter.

```
C:\Users\TAKIZAWA Yozo\busybox>busybox.exe sh
~/busybox $ cat examples/closure-stream.plsh
(def make-linear
  (lambda (x)
    (cons x (lambda () (make-linear (cons 'n x))))))

(def s (make-linear nil))

(car s)

(car ((cdr s)))

(car ((cdr ((cdr s)))))

(car ((cdr ((cdr ((cdr s)))))))

(car ((cdr ((cdr ((cdr ((cdr s)))))))))

(car ((cdr ((cdr ((cdr ((cdr ((cdr s)))))))))))

exit

~/busybox $ sh PureLISP.sh -snl < examples/closure-stream.plsh
make-linear
s
()
(n)
(n n)
(n n n)
(n n n n)
(n n n n n)
~/busybox $ exit

C:\Users\TAKIZAWA Yozo\busybox>
```

You can also try REPL by using Docker image created from Busybox base image.

```
$ docker run --rm -it ytaki0801/plsh
S> (def reverse-append
     (lambda (x y)
       (cond ((eq x nil) y)
             (t (reverse-append
                  (cdr x)
                  (cons (car x) y))))))

reverse-append
S> (reverse-append '(a b c) '(x y z))

(c b a x y z)
S> (def reverse-list                            
     (lambda (x)
       (reverse-append x nil)))

reverse-list
S> (reverse-list '(a b c d e))

(e d c b a)
S> (def append-list
     (lambda (x y)
       (reverse-append (reverse-list x) y)))

append-list
S> (append-list '(a b c) '(x y z))

(a b c x y z)
S> exit

$ 
```

## LISP Specification in this software

* Built-in functions in Pure LISP: `cons`, `car`, `cdr`, `atom`, `eq`
* Special forms in Pure LISP: `quote`, `cond` and lexically scoped `lambda`
* Special form not in PureLISP: `def` to bind variables in global environment
* Special form not in Pure LISP: `macro` to do meta-programming
* Built-in function not in Pure LISP: `length` to treat lists as numbers

* Simple REPL with `exit` command, comment notation `;` and the following exec options
	* default: prompt and pre-loading init file `init.plsh` in the current directory
	* `-snl` or `-s`: no prompt and no pre-loading init file
	* `-sl`: no prompt and pre-loading init file
	* `-nl`: prompt and no pre-loading init file

See `init.plsh` and codes in `examples` directory for details.

(FYI, firstly implemented referring to a John McCarthy's Original Lisp evaluator but now a SICP's one)

## Shell Programming in this software

* Conscells are firstly implemented to easy to program as a metacircular evaluator
* Pseudo-Array and Stack implementation by using global variables
* Using pattern-matching fully, to do S-expression lexical analysis especially

## Bugs and TODO

* Much more comments in the source code

## License

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
