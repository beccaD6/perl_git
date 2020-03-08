#!/bin/sh
#testing rm effect on status and show commands
legit.pl init
legit.pl status #error, no commits yet
echo "lol">lol
legit.pl add lol
legit.pl commit -m "lol"
legit.pl status
legit.pl rm lol
legit.pl status
echo "e">efile
legit.pl add efile
legit.pl rm e  #error doesnt exist
legit.pl rm --cached e #legit.pl: error: 'e' is not in the legit repository
legit.pl rm --cached efile
legit.pl status  #efile should now be untracked
legit.pl add efile
legit.pl commit -m "added"
legit.pl status
legit.pl show 0:lol   #test show works correctly for a file that has been removed
legit.pl show :lol
legit.pl show 1:lol  
#test show on efile which has been removed from index then added again
legit.pl show :efile
legit.pl show 1:efile
legit.pl show 0:efile
