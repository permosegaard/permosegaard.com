#!/bin/bash

if [[ ! -x "$( which ffmpeg )" ]]; then echo "install ffmpeg to continue"; exit 1; fi

contents="---\n"
contents+="layout: music/mixes/index.html\n"
contents+="lunr: true\n"
contents+="mixes:\n"

contents+="$(
	find ../../../../assets/media/mixes/*.mp3 -printf "%f\n" | while read line
	do
		name="$( echo "$line" | sed 's/\.mp3$//' )"
		name_cleaned="$( echo "$name" | sed "s/'//g" )"
		name_nospaces="$( echo "$name_cleaned" | sed 's/ /-/g' )"
		destination=${name_nospaces}.md

		mix="name: $name\n"
		mix+="duration: $( ffmpeg -i "../../../../assets/media/mixes/$line" 2>&1 | grep Duration | egrep -o "..:..:..???" )\n"
		mix+="genres:\n"
		mix+="date:\n"

		if [ -f $destination ]
		then
			echo "not overwriting $destination"
			continue
		else
			echo -en "---\nlayout: music/mixes/mix.html\nlunr: false\n$mix---\n$( cat $name_cleaned 2>/dev/null )" > $destination
		fi

		echo "$( echo -en "$mix" | while read line
		do
			echo "    $line"
		done | sed ':a;$!{N;ba};s/^  / -/' )"
	done
)\n"

contents+="---\n"

if [ -f ./index.md ]
then
	echo "not overwriting index.md"
else
	echo -e "$contents" > ./index.md
fi
