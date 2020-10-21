[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/)

# jmclisp.sh

This project is for creating a Pure LISP interpreter written in shell script conformed to POSIX shell,
inspired from [John McCarthy's 1960 paper](http://www-formal.stanford.edu/jmc/recursive/recursive.html)
and ported from [Paul Graham's Common Lisp implementation](http://paulgraham.com/lispcode.html).

## Purpose of this project

* To use in education and research of basic LISP language processing

* To use in ALL computer environments by using POSIX-conformant shell

## LISP Specification

* Built-in functions for conscell operation: cons, car, cdr, atom, eq and utility functions to define the evaluator
* Special forms: quote, cond, lambda, def (to set values including lambda expressions in global environment)
* S-expression input and output functions
* Simple REPL

## Bugs and TODO

* Overwrited first arguments of two-argument built-in functions in the evaluator

* More suitable error checks

## License

The codes in this repository are licensed under [CC0, Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
