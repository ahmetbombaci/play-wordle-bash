#!/bin/bash

GREEN_P='[0;32m'
RED_P='[0;31m'
BLUE_P='[0;34m'
RESET_P='[0m'

# GREEN='\033[0;32m'
# RED='\033[0;31m'
# BLUE='\033[0;34m'
# RESET='\033[0m'

function gr() {
		echo "$GREEN_P$1$RESET_P"
}

function rd() {
		echo "$RED_P$1$RESET_P"
}

function bl() {
		echo "$BLUE_P$1$RESET_P"
}

function fail() {
		echo "Test failed: [$1]"
}

# chr() {
# 		[ "$1" -lt 256 ] || return 1
# 		printf "\\$(printf '%03o' "$1")"
# }
# 
# ord() {
# 		LC_CTYPE=C printf '%d' "'$1"
# }

source ./play-wordle.sh unit-test

expected=$(gr C)$(gr L)$(gr A)$(gr I)$(gr M)
# set -x # turn on tracing
check_input CLAIM CLAIM | grep -qF "$expected" || fail "exact match | CLAIM CLAIM"
# set +x # turn off tracing

expected=$(rd C)$(rd L)$(rd A)$(rd I)$(rd M)
check_input CLAIM NOTER | grep -qF "$expected" || fail "no match | CLAIM NOTER"


expected=$(rd C)$(rd L)$(rd A)$(rd I)$(bl M)
check_input CLAIM MONEY | grep -qF "$expected" || fail "single char M | blue | CLAIM MONEY"

expected=$(bl P)$(bl A)$(gr P)$(bl E)$(rd R)
check_input PAPER APPLE | grep -qF "$expected" || fail "repeating char P | blue & green | PAPER APPLE" 

# secret word has only single A
# guess word has double A, both in wrong places
# result: both As will be in blue
expected=$(rd N)$(bl A)$(rd S)$(bl A)$(bl L)
# echo $expected > debug.out
# echo "--------" >> debug.out
# check_input NASAL APPLE >> debug.out
check_input NASAL APPLE | grep -qF "$expected" || fail "single char A | blue & blue | NASAL APPLE"

# secret word has only single A
# guess word has double A, one in correct place
# result: First A will be in green. Second A will in red since secret word 
#         has only one A
expected=$(gr A)$(rd R)$(rd R)$(rd A)$(rd Y)
check_input ARRAY APPLE | grep -qF "$expected" || fail "single char A | green & red"

expected=$(gr N)$(rd L)$(rd A)$(rd I)$(rd M)
check_input '?LAIM' NOTER | grep -qF "$expected" || fail "hint requested N | green"


