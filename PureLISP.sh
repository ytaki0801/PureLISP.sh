#!/bin/sh
#
# PureLISP.sh
#
# A Pure LISP interpreter by POSIX-conformant shell
# Evaluator with basic functions for conscell operations,
# S-expression input/output and simple REPL
#
# This code is licensed under CC0.
# https://creativecommons.org/publicdomain/zero/1.0/
#

IFS=''
LF="$(printf \\012)"


# Basic functions for conscell operations:
# cons, car, cdr, atom, eq

cons () {
  eval CAR$CNUM=$1
  eval CDR$CNUM=$2
  CONSR=${CNUM}.conscell
  CNUM=$((CNUM+1))
}

car () { eval CARR="\$CAR${1%%.*}"; }
cdr () { eval CDRR="\$CDR${1%%.*}"; }

atom () {
  case "$1" in (*.conscell)
    ATOMR=nil
  ;;(*)
    ATOMR=t
  ;;esac
}

eq () {
  atom $1
  case $ATOMR in (nil)
    EQR=nil
  ;;(*)
    atom $2
    case $ATOM in (nil)
      EQR=nil
    ;;(*)
      case "$1" in ("$2")
        EQR=t
      ;;(*)
        EQR=nil
      ;;esac
    ;;esac
  ;;esac
}


# S-expreesion output: s_display

s_strcons () {
  car $1 && s_display $CARR
  cdr $1
  eq $CDRR nil
  case $EQR in (t)
    printf ''
  ;;(*)
    atom $CDRR
    case $ATOMR in (t)
      printf ' . %s' "$CDRR"
    ;;(*)
      printf " " && s_strcons $CDRR
    ;;esac
  ;;esac
}

s_display () {
  s_null $1
  case $SNULLR in (t)
    printf "nil"
  ;;(*)
    atom $1
    case $ATOMR in (t)
      printf "$1"
    ;;(*)
      printf "("
      s_strcons $1
      printf ")"
    ;;esac
  ;;esac
}


# S-expression lexical analysis: s_lex

replace_all_posix() {
  set -- "$1" "$2" "$3" "$4" ""
  until [ _"$2" = _"${2#*"$3"}" ] && eval "$1=\$5\$2"; do
    set -- "$1" "${2#*"$3"}" "$3" "$4" "$5${2%%"$3"*}$4"
  done
}

s_lex0 () {
  replace_all_posix sl0INI " $1 " "$LF" ""
  replace_all_posix sl0LPS "$sl0INI" "(" " ( "
  replace_all_posix sl0RPS "$sl0LPS" ")" " ) "
  replace_all_posix sl0RET "$sl0RPS" "'" " ' "
}

s_lex1 () {
  sl1HEAD=${1%% *}
  sl1REST=${1#* }

  case "$sl1HEAD" in (''|' ') :
  ;;(*)
    eval "TOKEN$TNUM=\$sl1HEAD"
    TNUM=$((TNUM+1))
  ;;esac

  case "$sl1REST" in (''|' ') :
  ;;(*) s_lex1 $sl1REST
  ;;esac
}

s_lex () { s_lex0 $1 && s_lex1 $sl0RET; }


# S-expression syntax analysis: s_syn

s_quote () {
  case $SYNPOS in (-[0-9]*)
    SQUOTER=$1
  ;;(*)
    eval "squox=\$TOKEN$SYNPOS"
    case $squox in (\')
      SYNPOS=$((SYNPOS-1))
      cons $1 nil
      cons quote $CONSR
      SQUOTER=$CONSR
    ;;(*)
      SQUOTER=$1
    ;;esac
  ;;esac
}

s_syn0 () {
  eval "ss0t=\$TOKEN$SYNPOS"
  case $ss0t in ("(")
    SYNPOS=$((SYNPOS-1))
    SSYN0R=$1
  ;;(.)
    SYNPOS=$((SYNPOS-1))
    s_syn
    car $1
    cons $SSYNR $CARR
    s_syn0 $CONSR
  ;;(*)
    s_syn
    cons $SSYNR $1
    s_syn0 $CONSR
  ;;esac
}

s_syn () {
  eval "ssyt=\$TOKEN$SYNPOS"
  SYNPOS=$((SYNPOS-1))
  case $ssyt in (")")
    s_syn0 nil
    s_quote $SSYN0R
    SSYNR=$SQUOTER
  ;;(*)
    s_quote $ssyt
    SSYNR=$SQUOTER
  ;;esac
}

s_read () {
  TNUM=0
  s_lex $1
  SYNPOS=$((TNUM-1))
  s_syn
  SREADR=$SSYNR
}


# Stack implementation for recursive calls

stackpush () {
  eval STACK$STACKNUM=$1
  STACKNUM=$((STACKNUM+1))
}

stackpop ()
{
  STACKNUM=$((STACKNUM-1))
  eval STACKPOPR="\$STACK$STACKNUM"
}


# The evaluator: s_eval and utility functions

#caar () { car $1; car $CARR; CAARR=$CARR; }
#cadr () { cdr $1; car $CDRR; CADRR=$CARR; }
#cdar () { car $1; cdr $CARR; CDARR=$CDRR; }
#cadar () { car $1; cdr $CARR; car $CDRR; CADARR=$CARR; }
#caddr () { cdr $1; cdr $CDRR; car $CDRR; CADDRR=$CARR; }
#cadddr () { cdr $1; cdr $CDRR; cdr $CDRR; car $CDRR; CADDDRR=$CARR; }

caar ()
{
  eval CAAR_CARR="\$CAR${1%%.*}"
  eval CAARR="\$CAR${CAAR_CARR%%.*}"
}

cadr ()
{
  eval CADR_CDRR="\$CDR${1%%.*}"
  eval CADRR="\$CAR${CADR_CDRR%%.*}"
}

cdar ()
{
  eval CDAR_CARR="\$CAR${1%%.*}"
  eval CDARR="\$CDR${CDAR_CARR%%.*}"
}

cadar ()
{
  eval CADAR_CARR="\$CAR${1%%.*}"
  eval CADAR_CDARR="\$CDR${CADAR_CARR%%.*}"
  eval CADARR="\$CAR${CADAR_CDARR%%.*}"
}

caddr ()
{
  eval CADDR_CDRR="\$CDR${1%%.*}"
  eval CADDR_CDDRR="\$CDR${CADDR_CDRR%%.*}"
  eval CADDRR="\$CAR${CADDR_CDDRR%%.*}"
}

cadddr ()
{
  eval CADDDR_CDRR="\$CDR${1%%.*}"
  eval CADDDR_CDDRR="\$CDR${CADDDR_CDRR%%.*}"
  eval CADDDR_CDDDRR="\$CDR${CADDDR_CDDRR%%.*}"
  eval CADDDRR="\$CAR${CADDDR_CDDDRR%%.*}"
}

s_null () { eq $1 nil && SNULLR=$EQR; }

s_append () {
  s_null $1
  case $SNULLR in (t)
    SAPPENDR=$2
  ;;(*)
    cdr $1
    s_append $CDRR $2
    car $1
    cons $CARR $SAPPENDR
    SAPPENDR=$CONSR
  ;;esac
}

s_pair () {
  s_null $1
  stackpush $SNULLR
  s_null $2
  stackpop
  case "$STACKPOPR $SNULLR" in (t" "*|*" "t)
    SPAIRR=nil
  ;;(*)
    atom $1
    stackpush $ATOMR
    atom $2
    stackpop
    case "$STACKPOPR $ATOMR" in (nil" "nil)
      cdr $1
      stackpush $CDRR
      cdr $2
      stackpop
      s_pair $STACKPOPR $CDRR
      car $1
      stackpush $CARR
      car $2
      stackpop
      cons $STACKPOPR $CARR
      cons $CONSR $SPAIRR
      SPAIRR=$CONSR
    ;;(*)
      atom $1
      case $ATOMR in (t)
        cons $1 $2
        cons $CONSR nil
        SPAIRR=$CONSR
      ;;(*)
        SPAIRR=nil
      ;;esac
    ;;esac
  ;;esac
}

s_assq () {
  s_null $2
  case $SNULLR in (t)
    SASSQR=nil
  ;;(*)
    caar $2
    eq $CAARR $1
    case $EQR in (t)
      cdar $2
      SASSQR=$CDARR
    ;;(*)
      cdr $2
      s_assq $1 $CDRR
    ;;esac
  ;;esac
}

s_length () {
  s_null $1
  case $SNULLR in (nil)
    SLENGTHR=$((SLENGTHR+1))
    cdr $1
    s_length $CDRR
  ;;esac
}

s_cond () {
  s_null $1
  case $SNULLR in (t)
    SCONDR=nil
  ;;(*)
    caar $1
    s_eval $CAARR $2
    case $SEVALR in (t)
      cadar $1
      SCONDR=$CADARR
    ;;(*)
      cdr $1
      s_cond $CDRR $2
    ;;esac
  ;;esac
}

s_builtins () {
  case $1 in (t|nil)
    SBUILTINSR=$1
  ;;(cons|car|cdr|eq|atom)
    SBUILTINSR=$1
  ;;(length)
    SBUILTINSR=$1
  ;;(*)
    SBUILTINSR=notbuiltins
  ;;esac
}

s_lookup () {
  s_builtins $1
  case $SBUILTINSR in ($1)
    SLOOKUPR=$1
    return
  ;;esac
  s_assq $1 $2
  s_null $SASSQR
  case $SNULLR in (t)
    s_assq $1 $GENV
    s_null $SASSQR
    case $SNULLR in (t)
      SLOOKUPR=nil
      return
    ;;esac
  ;;esac
  SLOOKUPR=$SASSQR
}

s_evals () {
  s_null $1
  case $SNULLR in (t)
    SEVALSR=nil
  ;;(*)
    car $1 && s_eval $CARR $2
    stackpush $SEVALR
    cdr $1 && s_evals $CDRR $2
    stackpop && SEVALR=$STACKPOPR
    cons $SEVALR $SEVALSR
    SEVALSR=$CONSR
  ;;esac
}

s_eval () {
  SEVALARG1=$1
  SEVALARG2=$2

  while true
  do
    atom $SEVALARG1
    case $ATOMR in (t)
      s_lookup $SEVALARG1 $SEVALARG2
      SEVALR=$SLOOKUPR
      break
    ;;esac
    car $SEVALARG1
    case $CARR in (quote)
      cadr $SEVALARG1
      SEVALR=$CADRR
      break
    ;;(cond)
      cdr $SEVALARG1
      stackpush $SEVALARG2
      s_cond $CDRR $SEVALARG2
      stackpop && SEVALARG2=$STACKPOPR
      SEVALARG1=$SCONDR
    ;;(lambda|macro)
      stackpush $CARR
      cons $SEVALARG2 nil
      caddr $SEVALARG1
      cons $CADDRR $CONSR
      cadr $SEVALARG1
      cons $CADRR $CONSR
      stackpop && CARR=$STACKPOPR
      cons $CARR $CONSR
      SEVALR=$CONSR
      break
    ;;(def)
      caddr $SEVALARG1
      stackpush $SEVALARG1
      stackpush $SEVALARG2
      s_eval $CADDRR $SEVALARG2
      stackpop && SEVALARG2=$STACKPOPR
      stackpop && SEVALARG1=$STACKPOPR
      cadr $SEVALARG1
      cons $CADRR $SEVALR
      cons $CONSR $GENV
      GENV=$CONSR
      SEVALR=$CADRR
      break
    ;;(*)
      car $SEVALARG1
      stackpush $SEVALARG1
      stackpush $SEVALARG2
      s_eval $CARR $SEVALARG2
      stackpop && SEVALARG2=$STACKPOPR
      stackpop && SEVALARG1=$STACKPOPR
      SEVALEFUNC=$SEVALR

      stackpush $SEVALARG1
      stackpush $SEVALARG2
      stackpush $SEVALEFUNC
      cdr $SEVALARG1
      atom $SEVALEFUNC
      case $ATOMR in (t)
        s_evals $CDRR $SEVALARG2
        SEVALFVALS=$SEVALSR
      ;;(*)
        car $SEVALEFUNC
        case $CARR in (macro)
          SEVALFVALS=$CDRR
          SEVALFENVS=$SEVALARG2
        ;;(*)
          s_evals $CDRR $SEVALARG2
          SEVALFVALS=$SEVALSR
        ;;esac
      ;;esac
      stackpop && SEVALEFUNC=$STACKPOPR
      stackpop && SEVALARG2=$STACKPOPR
      stackpop && SEVALARG1=$STACKPOPR

      atom $SEVALEFUNC
      case $ATOMR in (t)
        s_apply $SEVALEFUNC $SEVALFVALS
        SEVALR=$SAPPLYR
        break
      ;;(*)
        cadr   $SEVALEFUNC && SEVALLVARS=$CADRR
        caddr  $SEVALEFUNC && SEVALLBODY=$CADDRR
        cadddr $SEVALEFUNC && SEVALLENVS=$CADDDRR
        SEVALARG1=$SEVALLBODY

        s_null $SEVALLVARS
        case $SNULLR in (t)
          SEVALARG2=$SEVALLENVS
        ;;(*)
          atom $SEVALLVARS
          case $ATOMR in (t)
            cons $SEVALLVARS $SEVALFVALS
            cons $CONSR nil
            s_append $CONSR $SEVALLENVS
            SEVALARG2=$SAPPENDR
          ;;(*)
            s_pair $SEVALLVARS $SEVALFVALS
            s_append $SPAIRR $SEVALLENVS
            SEVALARG2=$SAPPENDR
          ;;esac
        ;;esac

        car $SEVALEFUNC
        case $CARR in (macro)
          s_eval $SEVALARG1 $SEVALARG2
          s_eval $SEVALR $SEVALFENVS
        ;;esac
      ;;esac
    ;;esac

  done
}

s_apply () {
  case $1 in (cons)
    cadr $2
    car $2
    cons $CARR $CADRR
    SAPPLYR=$CONSR
  ;;(car)
    car $2
    car $CARR
    SAPPLYR=$CARR
  ;;(cdr)
    car $2
    cdr $CARR
    SAPPLYR=$CDRR
  ;;(eq)
    cadr $2
    car $2
    eq $CARR $CADRR
    SAPPLYR=$EQR
  ;;(atom)
    car $2
    atom $CARR
    SAPPLYR=$ATOMR
  ;;(length)
    SLENGTHR=0
    car $2
    s_length $CARR
    SAPPLYR=$SLENGTHR
    SLENGTHR=0
  ;;esac
}


# Simple REPL

s_replread () {
  SREPLREADR=""
  while read srplrd; do
    case $srplrd in ('')
      break
    esac
    SREPLREADR=$SREPLREADR$srplrd
  done
}

s_repl () {
  case "$PROMPT" in (t)
    printf "S> "
  ;;esac
  s_replread
  case $SREPLREADR in ('')
    PROMPT=t
    s_repl < /dev/tty
  ;;(*)
    case "$SREPLREADR" in ("exit")
      exit 0
    ;;(\;*)
      s_repl
    ;;(*)
      s_read $SREPLREADR
      s_eval $SREADR nil
      s_display $SEVALR && printf "\n"
      SEVALR=nil
      s_repl
    ;;esac
  ;;esac
}


# exec REPL with initialization

CNUM=0
STACKNUM=0
GENV=nil
PROMPT=nil
INITFILE=init.plsh

case "$1" in ("-s"|"-snl")
  PROMPTOPTION=nil
  LOADINITFILE=nil
;;("-sl")
  PROMPTOPTION=nil
  LOADINITFILE=t
;;("-nl")
  PROMPTOPTION=t
  LOADINITFILE=nil
;;(*)
  PROMPTOPTION=t
  LOADINITFILE=t
;;esac

if [ -e $INITFILE ]; then
  case $LOADINITFILE in (t)
    s_repl < $INITFILE
  ;;esac
fi

PROMPT=$PROMPTOPTION

s_repl

