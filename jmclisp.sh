#!/bin/sh
#
# A Pure LISP interpreter by POSIX-conformant shell
# Evaluator defined in McCarthy's 1960 paper
# with basic functions for conscell operations,
# S-expression input/output and simple REPL
#
# This code is licensed under CC0.
# https://creativecommons.org/publicdomain/zero/1.0/
#

IFS=''
LF="
"


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
  if [ "${1##*.}" = conscell ]; then
    ATOMR=nil
  else
    ATOMR=t
  fi
}

eq () {
  atom $1
  if [ $ATOMR = nil ]; then
    EQR=nil
  else
    atom $2
    if [ $ATOMR = nil ]; then
      EQR=nil
    elif [ "$1" = "$2" ]; then
      EQR=t
    else
      EQR=nil
    fi
  fi
}


# S-expreesion output: s_display

s_strcons () {
  car $1 && s_display $CARR
  cdr $1
  eq $CDRR nil
  if [ $EQR = t ]; then
    printf ''
  else
    atom $CDRR
    if [ $ATOMR = t ]; then
      printf ' . %s' "$CDRR"
    else
      printf " " && s_strcons $CDRR
    fi
  fi
}

s_display () {
  eq $1 nil
  if [ $EQR = t ]; then
    printf "()"
  else
    atom $1
    if [ $ATOMR = t ]; then
      printf "$1"
    else
      printf "("
      s_strcons $1
      printf ")"
    fi
  fi
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

  if [ ! ${sl1HEAD} = " " ]; then
    eval "TOKEN$TNUM=\$sl1HEAD"
    TNUM=$((TNUM+1))
  fi

  if [ ! ${sl1REST} = " " ]; then
    s_lex1 $sl1REST
  fi
}

s_lex () { s_lex0 $1 && s_lex1 $sl0RET; }


# S-expression syntax analysis: s_syn

s_quote () {
  if [ $SYNPOS -ge 0 ]; then
    eval "squox=\$TOKEN$SYNPOS"
    if [ $squox = "'" ]; then
      SYNPOS=$((SYNPOS-1))
      cons $1 nil
      cons quote $CONSR
      SQUOTER=$CONSR
    else
      SQUOTER=$1
    fi
  else
    SQUOTER=$1
  fi
}

s_syn0 () {
  eval "ss0t=\$TOKEN$SYNPOS"
  if [ $ss0t = "(" ]; then
    SYNPOS=$((SYNPOS-1))
    SSYN0R=$1
  elif [ $ss0t = "." ]; then
    SYNPOS=$((SYNPOS-1))
    s_syn
    car $1
    cons $SSYNR $CARR
    s_syn0 $CONSR
  else
    s_syn
    cons $SSYNR $1
    s_syn0 $CONSR
  fi
}

s_syn () {
  eval "ssyt=\$TOKEN$SYNPOS"
  SYNPOS=$((SYNPOS-1))
  if [ $ssyt = ")" ]; then
    s_syn0 nil
    s_quote $SSYN0R
    SSYNR=$SQUOTER
  else
    s_quote $ssyt
    SSYNR=$SQUOTER
  fi
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

caar () {
  car $1
  car $CARR
  CAARR=$CARR
}
cadr () {
  cdr $1
  car $CDRR
  CADRR=$CARR
}
cdar () {
  car $1
  cdr $CARR
  CDARR=$CDRR
}
cddr () {
  cdr $1
  cdr $CDRR
  CDDRR=$CDRR
}
cadar () {
  car $1
  cdr $CARR
  car $CDRR
  CADARR=$CARR
}
cddar () {
  car $1
  cdr $CARR
  cdr $CDRR
  CDDARR=$CDRR
}
caddr () {
  cdr $1
  cdr $CDRR
  car $CDRR
  CADDRR=$CARR
}
cdddr () {
  cdr $1
  cdr $CDRR
  cdr $CDRR
  CDDDRR=$CDRR
}
caddar () {
  car $1
  cdr $CARR
  cdr $CDRR
  car $CDRR
  CADDARR=$CARR
}
cadddr () {
  cdr $1
  cdr $CDRR
  cdr $CDRR
  car $CDRR
  CADDDRR=$CARR
}
caaddr () {
  cdr $1
  cdr $CDRR
  car $CDRR
  car $CARR
  CAADDRR=$CARR
}
cdddar () {
  car $1
  cdr $CARR
  cdr $CDRR
  cdr $CDRR
  CDDDARR=$CDRR
}

s_null () { eq $1 nil && SNULLR=$EQR; }

s_append () {
  s_null $1
  if [ $SNULLR = "t" ]; then
    SAPPENDR=$2
  else
    cdr $1
    s_append $CDRR $2
    car $1
    cons $CARR $SAPPENDR
    SAPPENDR=$CONSR
  fi
}

s_pair () {
  s_null $1
  stackpush $SNULLR
  s_null $2
  stackpop
  if [ $STACKPOPR = t -o $SNULLR = t ]; then
    SPAIRR=nil
  else
    atom $1
    stackpush $ATOMR
    atom $2
    stackpop
    if [ $STACKPOPR = nil -o $ATOMR = nil ]; then
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
    else
      SPAIRR=nil
    fi
  fi
}

s_assq () {
  s_null $2
  if [ $SNULLR = t ]; then
    SASSQ=nil
  else
    caar $2
    eq $CAARR $1
    if [ $EQR = t ]; then
      cdar $2
      SASSQR=$CDARR
    else
      cdr $2
      s_assq $1 $CDRR
    fi
  fi
}

s_length () {
  s_null $1
  if [ $SNULLR = nil ]; then
    SLENGTHR=$((SLENGTHR+1))
    cdr $1
    s_length $CDRR
  fi
}

s_eval () {
  eq $1 t
  if [ $EQR = t ]; then
    SEVALR=t
  else
  eq $1 nil
  if [ $EQR = t ]; then
    SEVALR=nil
  else
  atom $1
  if [ $ATOMR = t ]; then
    s_assq $1 $2
    SEVALR=$SASSQR
  else
  car $1 && atom $CARR
  if [ $ATOMR = t ]; then
    car $1
    case $CARR in
      quote)
        cadr $1 && SEVALR=$CADRR
        ;;
      atom)
        cadr $1 && s_eval $CADRR $2
        atom $SEVALR && SEVALR=$ATOMR
        ;;
      eq)
        caddr $1 && s_eval $CADDRR $2
        stackpush $SEVALR
        cadr  $1 && s_eval $CADRR  $2
        stackpop && SEVALR_EQ2=$STACKPOPR
        eq $SEVALR $SEVALR_EQ2
        SEVALR=$EQR
        ;;
      car)
        cadr $1 && s_eval $CADRR $2
        car $SEVALR && SEVALR=$CARR
        ;;
      cdr)
        cadr $1 && s_eval $CADRR $2
        cdr $SEVALR && SEVALR=$CDRR
        ;;
      cons)
        caddr $1 && s_eval $CADDRR $2
        stackpush $SEVALR
        cadr  $1 && s_eval $CADRR  $2
        stackpop && SEVALR_CONS2=$STACKPOPR
        cons $SEVALR $SEVALR_CONS2
        SEVALR=$CONSR
        ;;
      cond)
        cdr $1
        evcon $CDRR $2
        SEVALR=$EVCONR
        ;;
      lambda)
        cons $2 nil
        caddr $1
        cons $CADDRR $CONSR
        cadr $1
        cons $CADRR $CONSR
        cons lambda $CONSR
        SEVALR=$CONSR
        ;;
      def)
        caddr $1
        s_eval $CADDRR $2 && cons $SEVALR nil
        stackpush $CONSR
        cadr $1 && cons $CADRR nil
        stackpop
        stackpush $CADRR
        s_pair $CONSR $STACKPOPR
        s_append $SPAIRR $ENV
        ENV=$SAPPENDR
        stackpop
        SEVALR=$STACKPOPR
        ;;
      length)
        cadr $1
        s_eval $CADRR $2
        SLENGTHR=0
        s_length $SEVALR
        SEVALR=$SLENGTHR
        ;;
      *)
        car $1
        s_assq $CARR $2
        cdr $1
        cons $SASSQR $CDRR
        s_eval $CONSR $2
        ;;
    esac
  else
    car $1
    s_eval $CARR $2 # f

    stackpush $SEVALR
    cdr $1
    evlis $CDRR $2 # args
    stackpop && SEVALR=$STACKPOPR

    cadr   $SEVALR # lvars
    caddr  $SEVALR # lbody
    cadddr $SEVALR # lenvs

    stackpush $CADDRR
    s_pair $CADRR $EVLISR
    s_append $SPAIRR $CADDDRR
    stackpop && CADDRR=$STACKPOPR

    s_eval $CADDRR $SAPPENDR
  fi
  fi
  fi
  fi
}

evcon () {
  caar $1
  s_eval $CAARR $2
  if [ $SEVALR = t ]; then
    cadar $1
    stackpush $CADARR
    s_eval $CADARR $2
    stackpop
    CADARR=$STACKPOPR
    EVCONR=$SEVALR
  else
    cdr $1
    evcon $CDRR $2
  fi
}

evlis () {
  s_null $1
  if [ $SNULLR = "t" ]; then
    EVLISR=nil
  else
    car $1 && s_eval $CARR $2
    stackpush $SEVALR
    cdr $1 && evlis  $CDRR $2
    stackpop
    cons $STACKPOPR $EVLISR
    EVLISR=$CONSR
  fi
}


# Simple REPL

s_replread () {
  SREPLREADR=""
  read srplrd
  while [ ! $srplrd = $LF ]; do
    SREPLREADR=$SREPLREADR$srplrd
    read srplrd
  done
}

s_repl () {
  if [ ! $PROMPT = nil ]; then
    printf "S> "
  fi
  s_replread
  if [ ! $SREPLREADR = exit ]; then
    s_lex $SREPLREADR
    SYNPOS=$((TNUM-1))
    s_syn
    s_eval $SSYNR $ENV
    s_display $SEVALR && printf $LF
    s_repl
  fi
}


# exec REPL with initialization

CNUM=0
TNUM=0
STACKNUM=0
ENV=nil
if [ "$1" != "-s" ]; then
  PROMPT=t
else
  PROMPT=nil
fi
s_repl
