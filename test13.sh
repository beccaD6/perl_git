#checkout error situation #1: error occurs 
#The following test cases test when branch occurs at different states of the repository
#if error messages are generated at checkout or not
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
