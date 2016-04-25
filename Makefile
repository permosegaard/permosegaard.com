GULP = node_modules/.bin/gulp

.PHONY: clean full quick watch

default: quick run test

clean:
	-@ $(GULP) clean

full: clean
	-@ $(GULP) bower; $(GULP)

quick:
	-@ $(GULP) metalsmith; $(GULP) sync

#watch:
#	-@ $(GULP) watch

run:

test:
