#!/bin/bash

node_modules/.bin/gulp clean
if [ "$?" -ne "0" ]; then exit 1; fi

#echo; reset
#vagrant destroy && vagrant up
#if [ "$?" -ne "0" ]; then exit 1; fi

echo
node_modules/.bin/gulp

echo
#reset
echo "press enter to run 'node_modules/.bin/gulp watch' or ctrl+c to break out..."
read -n1

echo
#reset
node_modules/.bin/gulp watch
