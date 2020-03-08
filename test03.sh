#!/bin/sh
#test commit -a after calling (normal)rm

legit.pl init
echo "a">a
legit.pl add a  #a is in the index
rm a #from cwd
legit.pl commit -a -m "adding old a"  #should say nothing to commit
legit.pl status  #No commits yet so status and show do not work
legit.pl show :a
legit.pl rm --cached a
legit.pl commit -a -m "updating that a is untracked"
legit.pl status

echo "b">b
legit.pl add b  
legit.pl commit -m "Adding b"
rm b 
legit.pl commit -a -m "re adding b"  
legit.pl status
legit.pl show :b


