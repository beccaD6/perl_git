legit.pl init
Initialized empty legit repository in .legit
 echo "hello" > a
 legit.pl add a
 legit.pl commit -m "Added a on master"

 legit.pl branch b2
 legit.pl branch b7
 legit.pl checkout b2
 echo "newline" >> file.txt
 legit.pl add file.txt
 legit.pl commit -m "Added file.txt on b2"
Committed as commit 1
 legit.pl checkout b7
Switched to branch 'b7'
 legit.pl log
0 Added a on master
 legit.pl status
a - same as repo
 legit.pl show 0:a
hello
legit.pl show 1:a
