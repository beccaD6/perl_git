#!/bin/sh
#quick test of rm arg parsing where options and filenames are provided in many orders
legit.pl init
touch a b
legit.pl add a
legit.pl commit -m a
legit.pl rm --cached --cached a
legit.pl rm --force a
legit.pl add b
legit.pl commit -m b
legit.pl status
echo b>b
legit.pl rm --cached b --force
legit.pl rm --cached --pineapple b --force
legit.pl status
touch c
legit.pl add c
legit.pl commit -m c
legit.pl rm --cached c
legit.pl status
