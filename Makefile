# Makefile Tip 1: Escape $ with $$ 
# https://stackoverflow.com/questions/2382764/escaping-in-makefile

setup:
	cat /usr/share/dict/american-english | grep -E '^[A-Za-z]{5}$$' | awk '{print toupper($$0)}' > dict5.txt

play:
	./play-wordle.sh

play-preselected:
	./play-wordle.sh normal preselected

play-legacy:
	./play-wordle.sh normal legacy

pick-a-word:
	./pick-a-word.sh

unit-test:
	./test-play-wordle.sh

debug:
	./play-wordle.sh debug

debug-preselected:
	./play-wordle.sh debug preselected

debug-legacy:
	./play-wordle.sh debug legacy

debug-pick-a-word:
	./pick-a-word.sh debug

shellcheck:
	shellcheck play-wordle.sh

shellcheck-pick-a-word:
	shellcheck pick-a-word.sh

shellcheck-test-play-wordle:
	shellcheck -x test-play-wordle.sh

reveal-1st:
	cat hint_current_random_word.secret | cut -c 1-1

reveal-2nd:
	cat hint_current_random_word.secret | cut -c 2-2

reveal-3rd:
	cat hint_current_random_word.secret | cut -c 3-3

reveal-4th:
	cat hint_current_random_word.secret | cut -c 4-4

reveal-5th:
	cat hint_current_random_word.secret | cut -c 5-5

count-word:
	wc dict5.txt | awk '{print $$1}'

random-number:
	date +%s%N | cut -b10-19

hint-bash-mod:
	expr 21 % 5

hint-read-10th-line:
	sed '10q;d' dict5.txt

hint-word:
	grep '^.a.o.$$' solutions-mod.txt
