#test log only shows commits made in each branch (or before branch occured)
legit.pl init
touch a b c d
legit.pl add a b
legit.pl commit -m "  ab in master, lots of spaces    "
legit.pl branch b1
legit.pl checkout b1
legit.pl log
legit.pl add c
legit.pl commit -m "c in b1"
legit.pl checkout master
legit.pl log
legit.pl add d
legit.pl commit -m "d in master"
legit.pl log
legit.pl checkout b1
legit.pl log
touch e
legit.pl add e
legit.pl commit -m e
legit.pl log
legit.pl branch b2
legit.pl checkout b2
legit.pl log

