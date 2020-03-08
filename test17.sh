#checkout situation 5: error occurs 
legit.pl init
touch b
legit.pl add b
legit.pl commit -m b
touch a
legit.pl add a
legit.pl branch b
legit.pl commit -m a
echo a>a
legit.pl add a
echo ee>a
legit.pl checkout b
