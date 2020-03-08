#!/bin/sh
#test log entries, indexes, commit numbering across different branches
#tests show command works across branches
touch a b c d
legit.pl init
legit.pl add a b c 
legit.pl commit -m "abc"

legit.pl log        
legit.pl branch new1 
legit.pl checkout new1
legit.pl show 0:a
legit.pl show 0:b
legit.pl show 0:c 
legit.pl show :a 
legit.pl add d 
legit.pl commit -m "d"
Committed as commit 1 
legit.pl log
legit.pl checkout master
legit.pl show 1:d
legit.pl show 0:d
legit.pl show :d
legit.pl log
legit.pl add d
legit.pl show :d  #cant be found in index
legit.pl checkout new1
legit.pl show :d   
#check file is in both indexes
echo g>g    
legit.pl add g 
legit.pl show :g
legit.pl checkout new1
legit.pl show :g

#once we commit the file in master, it disappears from index of the other branch
legit.pl checkout master
legit.pl  commit -m g
legit.pl show :g
legit.pl  checkout new1   
legit.pl  show :g
legit.pl show 2:g
#legit.pl: error: 'g' not found in index

#test commit numbering
touch z
legit.pl add z
legit.pl commit -m 'z'  #should be commit number 3 even though no commit 2 made on this branch
legit.pl log


