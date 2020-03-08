#!/bin/sh
#test branch -d error umerged changes error
legit.pl init
touch a b c d
legit.pl add a
legit.pl branch b1
legit.pl commit -m a
legit.pl branch b2
legit.pl checkout b2
legit.pl add c
legit.pl checkout master
legit.pl branch -d b2
legit.pl checkout b1
echo aa>a
legit.pl checkout master
legit.pl branch -d b1
legit.pl branch b3
legit.pl checkout b3
echo d>d
legit.pl add d
legit.pl commit -m d
legit.pl checkout master   
legit.pl branch -d b3   #error beause b3 has a file committed that is no other branches' commits
legit.pl branch b4
legit.pl checkout b4
touch e
legit.pl checkout master
legit.pl branch -d b4
