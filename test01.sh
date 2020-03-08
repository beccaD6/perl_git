#!/bin/sh
#tests error responses of branch/checkout command inclduing when deleting a branch with uncommitted changes


legit.pl branch #should print error msg
legit.pl init
legit.pl branch # should print no commits in repo error msg
echo a>a                
legit.pl add a
legit.pl commit -m "a committed on master"
legit.pl branch
master
echo l>l                
legit.pl branch branch1
legit.pl branch master #branchname already exists error msg
legit.pl branch       
legit.pl add l
echo l>>l
legit.pl checkout branch1
legit.pl checkout master
legit.pl show :l
echo "lol">>l
legit.pl branch -d master  #error msg legit.pl: error: can not delete branch 'master'
legit.pl checkout branch1
Switched to branch 'branch1'
legit.pl branch -d master  #error msg legit.pl: error: can not delete branch 'master'
legit.pl branch -d branch1  #error cannot delete the branch you are currently checked out on.
legit.pl checkout branch1  #Already on 'branch1'
echo "ka">ka
legit.pl checkout master
Switched to branch 'master'
legit.pl branch -d branch1  #delete should work now
legit.pl branch branch1   #recreate the old branch name
echo "lol">lol
legit.pl add lol
legit.pl branch -d branch1
Deleted branch 'branch1'
legit.pl checkout branch1 #error cant checkout the deleted branch now

#test invalid branch names error msg
legit.pl branch __011
legit.pl branch 123






