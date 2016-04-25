#!/bin/bash

streams=(
	"Bassdrive|Drum and Bass station that's been running more than a decade|http://amsterdam2.shouthost.com.streams.bassdrive.com:8000"
)

if [[ ! -x "$( which ffmpeg )" ]]; then echo "install ffmpeg to continue"; exit 1; fi

contents="---\n"
contents+="layout: music/streaming/index.html\n"
contents+="lunr: true\n"
contents+="streams:\n"

contents+="$(
	for item in "${streams[@]}"
	do
		name="$( echo "$item" | cut -d"|" -f1 )"
		name_lower="$( echo "$name" | tr "[:upper:]" "[:lower:]" )"
		name_nospaces="$( echo "$name_lower" | sed 's/ /-/g' )"
		destination=${name_nospaces}.md

		description="$( echo "$item" | cut -d"|" -f2 )"
		url="$( echo "$item" | cut -d"|" -f3 )"

		stream="name: $name\n"
		stream+="description: $description\n"
		stream+="url: $name_nospaces\n"
		stream+="stream: $url"

		if [ -f $destination ]
		then
			echo "not overwriting $destination"
			continue
		else
			echo -en "---\nlayout: music/streaming/stream.html\nlunr: false\n$stream\n---\n$( cat $name_nospaces 2>/dev/null )" > $destination
		fi

		echo "$( echo -en "$stream" | while read line
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
