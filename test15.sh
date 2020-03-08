#checkout error situation 3: No error, last commits are the same between branches

legit.pl init
touch b
legit.pl add b
legit.pl commit -m b
touch a
legit.pl add a
legit.pl commit -m a
legit.pl branch b
echo a>a
legit.pl add a
echo a>>a
legit.pl checkout b
