#!/bin/bash

contents="---\n"
contents+="layout: ramblings/index.html\n"
contents+="lunr: true\n"
contents+="posts:\n"

contents+="$( find *.md | grep -v "index.md" | while read line
do
	header="$( cat $line | sed -n '/---/,/---/p' )"

	if [ "$title" = "$( echo "$header" | egrep "^title: " )" ]; then continue; fi
	
	echo -e "$( for i in title description icon
	do
		buffer="$( echo "$header" | egrep "^${i}: " )"

		if [ "$buffer" != "" ]
		then
			echo -e "    $( echo "$header" | egrep "^${i}: " )"
		else
			continue
		fi
	done | sed ':a;$!{N;ba};s/^  / -/' )"
done )\n"

contents+="---\n"

if [ -f ./index.md ]
then
        echo "not overwriting index.md"
else
        echo -e "$contents" > ./index.md
fi
