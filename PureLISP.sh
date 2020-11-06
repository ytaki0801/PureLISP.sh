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

caar () { car $1; car $CARR; CAARR=$CARR; }
cadr () { cdr $1; car $CDRR; CADRR=$CARR; }
cdar () { car $1; cdr $CARR; CDARR=$CDRR; }
cadar () { car $1; cdr $CARR; car $CDRR; CADARR=$CARR; }
caddr () { cdr $1; cdr $CDRR; car $CDRR; CADDRR=$CARR; }
cadddr () { cdr $1; cdr $CDRR; cdr $CDRR; car $CDRR; CADDDRR=$CARR; }

s_null () { eq $1 nil && SNULLR=$EQR; }

s_append () {
  s_null $1
  if [ $SNULLR = t ]; then
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
    if [ $STACKPOPR = nil -a $ATOMR = nil ]; then
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
      atom $1
      if [ $ATOMR = t ]; then
        cons $1 $2
        cons $CONSR nil
        SPAIRR=$CONSR
      else
        SPAIRR=nil
      fi
    fi
  fi
}

s_assq () {
  s_null $2
  if [ $SNULLR = t ]; then
    SASSQR=nil
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

s_cond () {
  caar $1
  s_eval $CAARR $2
  if [ $SEVALR = t ]; then
    cadar $1
    stackpush $CADARR
    s_eval $CADARR $2
    stackpop && CADARR=$STACKPOPR
    SCONDR=$SEVALR
  else
    cdr $1
    s_cond $CDRR $2
  fi
}

s_builtins () {
  case $1 in
    t|nil)
      SBUILTINSR=$1
      ;;
    cons|car|cdr|eq|atom)
      SBUILTINSR=$1
      ;;
    length)
      SBUILTINSR=$1
      ;;
    *)
      SBUILTINSR=notbuiltins
      ;;
  esac
}

s_lookup () {
  s_builtins $1
  if [ $SBUILTINSR = $1 ]; then
    SLOOKUPR=$1
    return
  fi
  s_assq $1 $2
  s_null $SASSQR
  if [ $SNULLR = t ]; then
    s_assq $1 $GENV
    s_null $SASSQR
    if [ $SNULLR = t ]; then
      SLOOKUPR=nil
      return
    fi
  fi
  SLOOKUPR=$SASSQR
}

s_eargs () {
  s_null $1
  if [ $SNULLR = t ]; then
    SEARGSR=nil
  else
    car $1 && s_eval $CARR $2
    stackpush $SEVALR
    cdr $1 && s_eargs $CDRR $2
    stackpop && SEVALR=$STACKPOPR
    cons $SEVALR $SEARGSR
    SEARGSR=$CONSR
  fi
}

s_eval () {
  atom $1
  if [ $ATOMR = t ]; then
    s_lookup $1 $2
    SEVALR=$SLOOKUPR
    return
  fi
  car $1
  case $CARR in
    quote)
      cadr $1
      SEVALR=$CADRR
      ;;
    cond)
      cdr $1
      s_cond $CDRR $2
      SEVALR=$SCONDR
      ;;
    lambda|macro)
      stackpush $CARR
      cons $2 nil
      caddr $1
      cons $CADDRR $CONSR
      cadr $1
      cons $CADRR $CONSR
      stackpop && CARR=$STACKPOPR
      cons $CARR $CONSR
      SEVALR=$CONSR
      ;;
    def)
      caddr $1
      s_eval $CADDRR $2
      cadr $1
      cons $CADRR $SEVALR
      cons $CONSR $GENV
      GENV=$CONSR
      SEVALR=$CADRR
      ;;
    *)
      s_eval $CARR $2

      atom $SEVALR
      if [ $ATOMR = nil ]; then
        car $SEVALR
        if [ $CARR = macro ]; then
          cdr $1
          s_apply $SEVALR $CDRR
          s_eval $SAPPLYR $2
          return
        fi
      fi

      stackpush $SEVALR
      cdr $1
      s_eargs $CDRR $2
      stackpop && SEVALR=$STACKPOPR
      s_apply $SEVALR $SEARGSR
      SEVALR=$SAPPLYR
      ;;
  esac
}

s_apply () {
  atom $1
  if [ $ATOMR = t ]; then
    # builtin-funcs exec
    case $1 in
      cons)
        cadr $2
        car $2
        cons $CARR $CADRR
        SAPPLYR=$CONSR
        ;;
      car)
        car $2
        car $CARR
        SAPPLYR=$CARR
        ;;
      cdr)
        car $2
        cdr $CARR
        SAPPLYR=$CDRR
        ;;
      eq)
        cadr $2
        car $2
        eq $CARR $CADRR
        SAPPLYR=$EQR
        ;;
      atom)
        car $2
        atom $CARR
        SAPPLYR=$ATOMR
        ;;
      length)
        SLENGTHR=0
        car $2
        s_length $CARR
        SAPPLYR=$SLENGTHR
        SLENGTHR=0
        ;;
    esac
  else
    # lambda-expression exec
    cadr $1   # lvars
    caddr $1  # lbody
    cadddr $1 # lenvs

    atom $CADRR
    if [ $ATOMR = t ]; then
      s_null $CADRR
      if [ $SNULLR = t ]; then
        # when the arg is ()
        s_append $CADDDRR nil
      else
        # when the arg is atom except nil
        cons $CADRR $2
        cons $CONSR nil
        s_append $CONSR $CADDDRR
      fi
    else # the arg is normal type (...)
      s_pair $CADRR $2
      s_append $SPAIRR $CADDDRR
    fi

    s_eval $CADDRR $SAPPENDR
    SAPPLYR=$SEVALR
  fi
}


# Simple REPL

s_replread () {
  SREPLREADR=""
  while read srplrd; do
    if [ -z $srplrd ]; then
      break
    fi
    SREPLREADR=$SREPLREADR$srplrd
  done
}

s_repl () {
  if [ "$PROMPT" = "t" ]; then
    printf "S> "
  fi
  s_replread
  if [ -z $SREPLREADR ]; then
    PROMPT=t
    s_repl < /dev/tty
  else
    case "$SREPLREADR" in
      "exit")
        exit 0
        ;;
      \;*)
        s_repl
        ;;
      *)
        s_read $SREPLREADR
        s_eval $SREADR nil
        s_display $SEVALR && printf $LF
        SEVALR=nil
        s_repl
        ;;
    esac
  fi
}


# exec REPL with initialization

CNUM=0
STACKNUM=0
GENV=nil
PROMPT=nil
INITFILE=init.plsh

case "$1" in
  "-s"|"-snl")
    PROMPTOPTION=nil
    LOADINITFILE=nil
    ;;
  "-sl")
    PROMPTOPTION=nil
    LOADINITFILE=t
    ;;
  "-nl")
    PROMPTOPTION=t
    LOADINITFILE=nil
    ;;
  *)
    PROMPTOPTION=t
    LOADINITFILE=t
    ;;
esac

if [ -e $INITFILE -a $LOADINITFILE = t ]; then
  s_repl < $INITFILE
fi

PROMPT=$PROMPTOPTION

s_repl

