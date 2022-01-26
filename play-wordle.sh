#!/bin/bash

# DEBUG_MODE=debug
DEBUG_MODE=$1

# GAME_MODE=random
# GAME_MODE=legacy
#  - Uses old dictionary
# GAME_MODE=preselected
#  - Avoid totally random word since dictionary has non-English words 
#  - Help of 3rd party is needed for this process
#  - left over from legacy code
GAME_MODE=$2

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
# WHITE='\033[0;37m'
RESET='\033[0m'

CLUE_CORRECT=${GREEN}+${RESET}
CLUE_NOTEXIST=${RED}-${RESET}
CLUE_WRONGPOS=${BLUE}x${RESET}

ord() {
  LC_CTYPE=C printf '%d' "'$1"
}

setup_alphabet() {
	for x in {A..Z}; do
		char_list+=("$x")
		char_greened+=(false)
	done
}

print_alphabet() {
	echo -e "${char_list[*]}"
}

update_alphabet() {
	# $1: letter (i.e A)
	# $2: color (i.e $GREEN)
	char_pos=$( ord "$1")
	char_pos=$((char_pos-65))
	if [ "$GREEN" = "$2" ]; then
		char_greened[$char_pos]=true
		char_list[$char_pos]="$2$1${RESET}"
	elif [ ${char_greened[$char_pos]} = false ]; then
		char_list[$char_pos]="$2$1${RESET}"
	fi

}

validate_length() {
	[[ $1 =~ ^[A-Za-z]{5}$ ]] && return 0
	echo "Invalid input! Please enter only 5 chars" && return 1
}

validate_dictionary() {
	if [ "$GAME_MODE" = "legacy" ]; then 
		grep -iq "$1" dict5.txt && return 0
	else
		( grep -iq "$1" solutions-mod.txt || grep -iq "$1" nonsolutions-mod.txt ) && return 0
	fi
	echo "Invalid input! Word does not exist in the dictionary!" && return 1
}

validate_input() {
	validate_length "$1" && validate_dictionary "$1" && return 0
	return 1
}

check_input() {
	# print $user_input
	# use $CLUE_CORRECT , $CLUE_NOTEXIST, $CLUE_WRONGPOS to display matches
	# $CLUE_CORRECT --> correct char in correct place
	# $CLUE_NOTEXIST --> char does not exist in secret word
	# $CLUE_WRONGPOS --> char exist in secret word but in a different position
	# user_input =CABLE
	# secret_word=CLAIM
	# Output:
	# CABLE
	# +x---

	user_input=$1
	secret_word=$2
	match_result=""
	colorized_input=""

	# During initial loop replace green chars with `_` for correct blue coloring for mismatches
	secret_mask_found=""
	for (( i=0; i<${#user_input}; i++ )); do
		current_char=${user_input:$i:1}
		if [ "${current_char}" = "${secret_word:$i:1}" ]; then
			secret_mask_found="$secret_mask_found"_
		else
			secret_mask_found="$secret_mask_found${secret_word:$i:1}" 
		fi
	done
	[[ $DEBUG_MODE = "debug" ]] && echo "Secret mask found: ${secret_mask_found}"

	for (( i=0; i<${#user_input}; i++ )); do
		[[ $DEBUG_MODE = "debug" ]] && echo -n "${user_input:$i:1}"
		[[ $DEBUG_MODE = "debug" ]] && echo -n "${secret_word:$i:1}"
		current_char=${user_input:$i:1}
		if [ "${current_char}" = "${secret_word:$i:1}" ]; then
			[[ $DEBUG_MODE = "debug" ]] && echo -en "$CLUE_CORRECT"
			match_result=${match_result}"$CLUE_CORRECT"
			colorized_input=${colorized_input}"$GREEN${current_char}$RESET"
			update_alphabet "$current_char" "$GREEN"
		elif [[ $secret_mask_found =~ ${current_char} ]]; then
			# Do coloring correctly for multi-char words
			# A character can be blue if it is misplaced and its correct position is not found during guess 

			# Secret: APPLE
			# Guess : PAPER --> First P in blue and second P in green
			# Guess : NASAL --> Both A can be blue although there is only one A
			# Guess : ARRAY --> First A in green and the second A in red since there is only one A

			[[ $DEBUG_MODE = "debug" ]] && echo -en "$CLUE_WRONGPOS"
			match_result=${match_result}"$CLUE_WRONGPOS"
			colorized_input=${colorized_input}"$BLUE${current_char}$RESET"
			update_alphabet "$current_char" "$BLUE"
		else
			[[ $DEBUG_MODE = "debug" ]] && echo -en "$CLUE_NOTEXIST"
			match_result=${match_result}"$CLUE_NOTEXIST"
			colorized_input=${colorized_input}"$RED${current_char}$RESET"
			update_alphabet "$current_char" "$RED"
		fi
		[[ $DEBUG_MODE = "debug" ]] && echo ""
	done

	# echo "$user_input"
	history_print_helper="$history_print_helper\n$colorized_input"
	echo -e "$history_print_helper"
	echo -e "$match_result"
	print_alphabet

	[[ $user_input = "$secret_word" ]] && echo "Wow, you found it!" && return 0
	echo "You need to make another guess" && return 1

}

welcome() {
	while IFS= read -r line; do printf '%s\n' "$line"; done < banner.txt
	echo "Welcome to word game!"
	echo "Find the secret word"
	echo "You will get a clue after each guess"
	echo -e "If a character is correct and in the correct place, you will see ${CLUE_CORRECT}"
	echo -e "If a character is correct but in the wrong place, you will see ${CLUE_WRONGPOS}"
	echo -e "If a character is not found in the secret word, you will see ${CLUE_NOTEXIST}"
	echo "Let's assume that secret word is 'CLAIM' and your first guess is 'CABLE'"
	echo "You will see:"
	echo "-------------"
	echo "CABLE"
	echo -e "${CLUE_CORRECT}${CLUE_WRONGPOS}${CLUE_NOTEXIST}${CLUE_NOTEXIST}${CLUE_NOTEXIST}"
	echo "-------------"
	echo ""
	echo "Game on!"
	echo "--------"
}

setup_alphabet
welcome

[[ $DEBUG_MODE = "debug" ]] && echo "Debug mode is enabled"

if [ "$GAME_MODE" = "preselected" ]; then 
	[[ $DEBUG_MODE = "debug" ]] && echo "Preselected mode is enabled"
	randomword_up=$( cat hint_current_random_word.secret ) 
elif [ "$GAME_MODE" = "legacy" ]; then 
	wordcount=$( wc dict5.txt | awk '{print $1}' )
	randomnumber=$( date +%s%N | cut -b10-19 )
	randomline=$( expr "$randomnumber" % "$wordcount" )
	# randomword=$( ( sed '10q;d' dict5.txt ) )
	# sed "${randomline}q;d" dict5.txt
	myrandomword=$( sed "${randomline}q;d" dict5.txt )
	randomword_up=${myrandomword^^}
	echo "${randomword_up}" > hint_current_random_word.secret
	[[ $DEBUG_MODE = "debug" ]] && echo "Word count: " $(( wordcount ))
	[[ $DEBUG_MODE = "debug" ]] && echo "Random number: " $(( randomnumber ))
	[[ $DEBUG_MODE = "debug" ]] && echo "Random line: " $(( randomline ))
else
	wordcount=$( wc solutions-mod.txt | awk '{print $1}' )
	randomnumber=$( date +%s%N | cut -b10-19 )
	randomline=$( expr "$randomnumber" % "$wordcount" )
	myrandomword=$( sed "${randomline}q;d" solutions-mod.txt )
	randomword_up=${myrandomword^^}
	echo "${randomword_up}" > hint_current_random_word.secret
	[[ $DEBUG_MODE = "debug" ]] && echo "Word count: " $(( wordcount ))
	[[ $DEBUG_MODE = "debug" ]] && echo "Random number: " $(( randomnumber ))
	[[ $DEBUG_MODE = "debug" ]] && echo "Random line: " $(( randomline ))
fi

[[ $DEBUG_MODE = "debug" ]] && echo "Random word: $randomword_up"

guesscnt=0
history_print_helper=""

while true; do
	((guesscnt++))

	echo "[ ${guesscnt} ] Make a guess: "
	read -r myguess1
	guess1_up=${myguess1^^}

	echo "Your guess is $guess1_up"
	validate_input "$guess1_up" 
	while [ $? -ne 0 ] 
	do
		echo "Make another guess: "
		read -r myguess1
		guess1_up=${myguess1^^}

		echo "Your new guess is $guess1_up"
		validate_input "$guess1_up"
	done

	check_input "$guess1_up" "$randomword_up"
	[[ $? -ne 0 ]] || break

done

echo "--------------"
echo "End of Program"


