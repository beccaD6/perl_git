#!/bin/sh
#test commit -a adds updates multiple files in the index with and without calling 'add' first 
legit.pl init   
echo "line1" >a
touch b
legit.pl commit -a -m 'attempt 1'    #should fail as no files added yet
legit.pl add a 
legit.pl add b
legit.pl commit -a -m 'works'  #should work 
echo "1 2 3" >> b
echo "1 2 3" >> a
legit.pl status
legit.pl commit -a -m "add two in one go?" 
legit.pl status
legit.pl show :b 
legit.pl show :a 
legit.pl show 2:b 
legit.pl show 2:a 
legit.pl show 1:b 
legit.pl show 1:a 
legit.pl show 0:b 
legit.pl show 0:b 
echo "3 4 5">>b
legit.pl status
legit.pl commit -a -m "change b"   #should update b without needing to call "add b"
legit.pl show :b
legit.pl show :a #a shouldnt have changed
legit.pl status
echo "3 4 5">>a
legit.pl commit -a -m "change a" 
legit.pl show :a 
legit.pl status
legit.pl log #test log is working correctly too

