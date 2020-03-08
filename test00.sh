#!/bin/sh
#test00 test error msgs for rm
legit.pl init
touch a b c d e f g
legit.pl add f
legit.pl commit -m "commiting f"
echo ff>f
legit.pl rm f  #should get error msg
legit.pl rm --cached f
legit.pl status
legit.pl add f
legit.pl rm f
legit.pl rm --cached --cached --force f  # f has changes staged in index
legit.pl commit -m "commit changes to f"
legit.pl status
legit.pl rm --cached f
legit.pl rm f # file no longer in index, still in cwd, error f is not in repo
legit.pl status
legit.pl rm a # has no commits, not in index
echo "b">b
legit.pl add b
legit.pl rm b #fails
legit.pl rm --cached b #works
legit.pl status
rm b
legit.pl show :b
legit.pl add e f
legit.pl commit -a -m "commit e f"
legit.pl rm e f __5invalidname    # check one invalid name means no files are rm
legit.pl status
touch __5invalidname
legit.pl rm e f __5invalidname 
legit.pl status
legit.pl rm --cached e f g #check fails removing e f from index if g isnt in index
legit.pl status
legit.pl rm --force e f g #check force also fails 
legit.pl status




