#!/bin/bash

contents="---\n"
contents+="title: My Blog\n"
contents+="layout: ramblings/index.html\n"
contents+="lunr: true\n"
contents+="posts:\n"

contents+="$( find *.md | grep -v "index.md" | while read line
do
	header="$( cat $line | sed -n '/---/,/---/p' )"
	draft="$( echo "$header" | egrep "^draft: " )"
	path="$( echo "$line" | sed 's/\.md$//' )"

	if [ "$( echo "$draft" | grep -q "true"; echo $? )" -eq "0" ]; then continue; fi

	if [ "$title" = "$( echo "$header" | egrep "^title: " )" ]; then continue; fi
	
	echo -e "$(
		for i in title description icon
		do
			buffer="$( echo "$header" | egrep "^${i}: " )"

			if [ "$buffer" != "" ]
			then
				echo -e "    $( echo "$header" | egrep "^${i}: " )"
			else
				continue
			fi
		done | sed ':a;$!{N;ba};s/^  / -/'
	)"
	echo "    path: $path"
done )\n"

contents+="---\n"

if [ -f ./index.md ]
then
        echo "not overwriting index.md"
else
        echo -e "$contents" > ./index.md
fi
