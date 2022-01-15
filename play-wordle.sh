#!/bin/bash

# DEBUG_MODE=debug
DEBUG_MODE=$1

CLUE_CORRECT=+
CLUE_NOTEXIST=-
CLUE_WRONGPOS=x

validate_input() {
	# input must be 5 chars only
	user_input=$1
	[[ $user_input =~ ^[A-Za-z]{5}$ ]] && return 0
	echo "Invalid input! Please enter only 5 chars" && return 1
}

check_input() {
	# print $user_input
	# use $CLUE_CORRECT , $CLUE_NOTEXIST, $CLUE_WRONGPOS to display matches
	# $CLUE_CORRECT --> correct char in correct place
	# $CLUE_NOTEXIST --> char does not exist in secret word
	# $CLUE_WRONGPOS --> char exist in secret word but in a different position
	user_input=$1
	secret_word=$2
	match_result=""

	for (( i=0; i<${#user_input}; i++ )); do
		[[ $DEBUG_MODE = "debug" ]] && echo "${user_input:$i:1}"
		[[ $DEBUG_MODE = "debug" ]] && echo "${secret_word:$i:1}"
		if [ "${user_input:$i:1}" = "${secret_word:$i:1}" ]; then
			[[ $DEBUG_MODE = "debug" ]] && echo "$CLUE_CORRECT"
			match_result=${match_result}"$CLUE_CORRECT"
		elif [[ $secret_word =~ ${user_input:$i:1} ]]; then
			[[ $DEBUG_MODE = "debug" ]] && echo "$CLUE_WRONGPOS"
			match_result=${match_result}"$CLUE_WRONGPOS"
		else
			[[ $DEBUG_MODE = "debug" ]] && echo "$CLUE_NOTEXIST"
			match_result=${match_result}"$CLUE_NOTEXIST"
		fi
	done

	echo "$user_input"
	echo "$match_result"

	[[ $match_result = "+++++" ]] && echo "Wow, you found it!" && return 0
	echo "You need to make another guess" && return 1

}

welcome() {
	echo "Welcome to word game!"
	echo "Find the secret word"
	echo "You will get a clue after each guess"
	echo "If a character is correct and in the correct place, you will see ${CLUE_CORRECT}"
	echo "If a character is correct but in the wrong place, you will see ${CLUE_WRONGPOS}"
	echo "If a character is not found in the secret word, you will see ${CLUE_NOTEXIST}"
	echo "Let's assume that secret word is 'CLAIM' and your first guess is 'CABLE'"
	echo "You will see:"
	echo "-------------"
	echo "CABLE"
	echo "${CLUE_CORRECT}${CLUE_WRONGPOS}${CLUE_NOTEXIST}${CLUE_NOTEXIST}${CLUE_NOTEXIST}"
	echo "-------------"
	echo ""
	echo "Game on!"
	echo "--------"
}


welcome

wordcount=$( wc dict5.txt | awk '{print $1}' )
randomnumber=$( date +%s%N | cut -b10-19 )
randomline=$( expr "$randomnumber" % "$wordcount" )
# randomword=$( ( sed '10q;d' dict5.txt ) )
# sed "${randomline}q;d" dict5.txt
myrandomword=$( sed "${randomline}q;d" dict5.txt )
randomword_up=${myrandomword^^}
echo "${randomword_up}" > hint_current_random_word.secret


[[ $DEBUG_MODE = "debug" ]] && echo "Debug mode is enabled"

[[ $DEBUG_MODE = "debug" ]] && echo "Word count: " $(( wordcount ))
[[ $DEBUG_MODE = "debug" ]] && echo "Random number: " $(( randomnumber ))
[[ $DEBUG_MODE = "debug" ]] && echo "Random line: " $(( randomline ))
[[ $DEBUG_MODE = "debug" ]] && echo "Random word: $randomword_up"

guesscnt=0

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


