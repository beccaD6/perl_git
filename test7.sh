touch a b c
legit.pl init
legit.pl add a b c 
legit.pl commit -m "abc"
legit.pl status
legit.pl branch b1
legit.pl checkout b1
legit.pl status
#create new file in working directory then switch
touch d
legit.pl checkout master
legit.pl status
#add then switch
legit.pl add d
legit.pl checkout b1
#finally commit, 
legit.pl commit -m "commit d "
legit.pl status
legit.pl checkout master
#check file d is reverted
legit.pl status
touch e
legit.pl add e
echo e>>e
legit.pl checkout b1
legit.pl show :e
legit.pl status
legit.pl commit -m e
echo ee>>e
#test error msg : e is different to index and last commit
legit.pl checkout master
legit.pl status






