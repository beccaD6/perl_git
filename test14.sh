#checkout error situation 2: error occurs because b's last commit differs to master's 
legit.pl init
touch b
legit.pl add b
legit.pl commit -m b
touch a
legit.pl add a
legit.pl branch b
legit.pl commit -m a
echo a>a
legit.pl checkout b
