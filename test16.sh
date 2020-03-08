#checkout situation 4: NO error  
legit.pl init
touch b
legit.pl add b
legit.pl commit -m b
touch a
legit.pl add a
legit.pl commit -m a
echo a>a
legit.pl branch b
legit.pl add a
legit.pl checkout b
