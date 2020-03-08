#!/bin/sh
#test05 test error msgs for add and commit and rm

legit.pl init
legit.pl add g      #non existant
legit.pl add __34d  #invalid name
touch a
legit.pl add a
legit.pl commit -m -m  
legit.pl commit -m -a  #wrong order
legit.pl commit -a -a msg
legit.pl commit -a -B
legit.pl commit -m "hello\n" #fake new line error
touch b
touch __12
legit.pl add a b __12  #check one invalid name means no files get added to index
legit.pl status  

#test show on a file that is not in the last commit but is in previous commits
touch c
echo c>c
legit.pl add c
legit.pl commit -m "commit c"
legit.pl rm c
touch d
legit.pl add d
legit.pl commit -m "commit d"
legit.pl show 2:c
legit.pl show 1:c
legit.pl show 0:c

# test errors for rm...

#file never been comitted but want to remove from index
touch x
legit.pl add x
legit.pl rm --cached x

#file is not in cwd but in index-- call rm 
touch z y
legit.pl add z
rm z
legit.pl rm z  #fail because needs to delete from BOTH cwd and index
legit.pl rm  --cached z # should work
legit.pl rm z

#file is not in index but in cwd --call rm --cached should fail
legit.pl rm --cached y
legit.pl add y
legit.pl rm --cached y #should work
legit.pl rm --cached y #should fail
legit.pl rm y
