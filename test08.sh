#!/bin/sh
#test status msgs
legit.pl init
touch a b c d e

legit.pl status
legit.pl add a b c 
legit.pl commit -a -m "commit a b c"
legit.pl status
rm e
legit.pl status #e should still be untracked
legit.pl add d
legit.pl status  # d changed
echo a>a
echo b>b
legit.pl add b
legit.pl status
echo bb>>b
legit.pl status # b status changed
legit.pl rm --force b
legit.pl status   # b still shows up
echo e>e
legit.pl add e
legit.pl commit -m "e"   
legit.pl status   # b no longer shows up
legit.pl rm --cached e
legit.pl status  # e status changes
rm e
legit.pl status # e should be file deleted

