#!/bin/sh
##REPEAT of test00.sh but testing rm --force option
## Also test rm when file is different in index, last commit and cwd
legit.pl init
touch a b c d e f g
legit.pl add f
legit.pl commit -m "commiting f"

#test arg parsing errors
legit.pl status
legit.pl show :f
legit.pl rm --cached --cached --cached f # should be treated as if the command was "rm --cached f"
legit.pl show :f
legit.pl status
legit.pl rm --cached --cached --cached --force f  
legit.pl status
legit.pl rm --force --force f
legit.pl status
legit.pl rm --force -a f
legit.pl status

echo ff>f
legit.pl rm --force f  
legit.pl status
legit.pl rm --cached --force f
legit.pl status
legit.pl rm --force --cached f
legit.pl status
legit.pl add f
legit.pl rm --force f
legit.pl rm --force --cached f  # f has changes staged in index
legit.pl commit -m "commit changes to f"
legit.pl status
legit.pl rm --force --cached f
legit.pl rm --force f # file no longer in index, still in cwd, error f is not in repo
legit.pl status
legit.pl rm --force a # has no commits, not in index
echo "b">b
legit.pl add b
legit.pl rm --force b #fails
legit.pl rm --force --cached b #works
legit.pl status
rm b
legit.pl show :b
legit.pl add e f
legit.pl commit -a -m "commit e f"
legit.pl rm --force e f __5invalidname    # check one invalid name means no files are rm
legit.pl status
touch __5invalidname
legit.pl rm --force e f __5invalidname 
legit.pl status
legit.pl rm --force --cached e f g #check fails removing e f from index if g isnt in index
legit.pl status
legit.pl rm --force e f g #check force also fails 
legit.pl status
touch h
legit.pl add h
legit.pl commit -m "added h"
legit.pl rm --cached --cached --cached -f -a h #error?


#Test rm when file is different in index, last commit and cwd
touch p
legit.pl add p
legit.pl commit -m p
echo p>p
legit.pl add p
echo pp>>p
rm p
legit.pl rm --force p
legit.pl status



