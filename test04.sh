#!/bin/sh
#test commit -a after calling (legit)rm

legit.pl init
echo "a">a
legit.pl add a  #a is in the index
legit.pl rm --cached a   #should fail as no commits yet

legit.pl commit -m "commited a"
legit.pl rm --cached a   
rm a      #a is rm from cwd and index now
legit.pl commit -a -m "adding old a"  
legit.pl status  #No commits yet so status and show do not work
legit.pl show :a
legit.pl show 0:a

echo "b">b
legit.pl add b  
legit.pl commit -m "Adding b"
legit.pl rm --force b
legit.pl status
legit.pl add b
legit.pl commit -m "re adding b"  
legit.pl status
legit.pl show :b

