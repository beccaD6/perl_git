#checkout situation 6: error 
legit.pl init
touch b
legit.pl add b
legit.pl commit -m b
legit.pl branch b
touch a
legit.pl add a
legit.pl commit -m a
echo eee>>a
legit.pl checkout b
