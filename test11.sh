#test creating a file + add + commit in one branch only then checkout
#where that file doesn't exist in other branches 
legit.pl init
touch a b c
legit.pl add a
legit.pl commit -m a
legit.pl branch b
legit.pl checkout b
touch f
legit.pl add f
legit.pl commit -m f
legit.pl checkout master
legit.pl status

