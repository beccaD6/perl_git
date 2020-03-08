touch a b c
legit.pl init
legit.pl add a b c 
legit.pl commit -m "abc"
legit.pl status
legit.pl branch b1
legit.pl checkout b1
legit.pl status
legit.pl log
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
legit.pl log
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
legit.pl status
#test error msg
legit.pl log
legit.pl checkout master
legit.pl log
legit.pl add e
#test error msg
legit.pl checkout master
legit.pl log
echo eeee>>e   # test error msg
legit.pl checkout b1
legit.pl log
legit.pl status
legit.pl add e
legit.pl commit -m e2
echo e>>e
legit.pl checkout master  #test error msg 
