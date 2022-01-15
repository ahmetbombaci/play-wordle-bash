#!/bin/bash

# DEBUG_MODE=debug
DEBUG_MODE=$1

wordcount=$( wc dict5.txt | awk '{print $1}' )


[[ $DEBUG_MODE = "debug" ]] && echo "Debug mode is enabled"

[[ $DEBUG_MODE = "debug" ]] && echo "Word count: " $(( wordcount ))

while true; do
	randomnumber=$( date +%s%N | cut -b10-19 )
	randomline=$( expr "$randomnumber" % "$wordcount" )
	# randomword=$( ( sed '10q;d' dict5.txt ) )
	# sed "${randomline}q;d" dict5.txt
	myrandomword=$( sed "${randomline}q;d" dict5.txt )
	randomword_up=${myrandomword^^}

	[[ $DEBUG_MODE = "debug" ]] && echo "Random number: $randomnumber" 
	[[ $DEBUG_MODE = "debug" ]] && echo "Random line: $randomline"
	
	echo "Random word: $randomword_up"
	echo "Is this a word?(y/n)"
	read -r wordyesno

	[[ ${wordyesno^^} = "N" ]] || break
done

echo "Thanks! Random word selected: $randomword_up"
echo "${randomword_up}" > hint_current_random_word.secret

