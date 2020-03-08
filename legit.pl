#!/usr/bin/perl -w
#By Rebecca Diaz (z5162531) for COMP2041 Assignment 1
#spec: https://cgi.cse.unsw.edu.au/~cs2041/18s2/assignments/ass1/index.html

use File::Copy;
use File::Compare;

#global variables:

#the currently checked out branch
my $current_branch='master';
#this is the highest commit number across ALL branches
my $global_max_commit=-1;

#update global_max_commit
foreach $branch(glob ".legit/branch.*"){
	$branch=~s|.legit/branch.||;
	foreach $d(glob ".legit/branch.$branch/commit.*"){
		$d=~s|.legit/branch.$branch/commit.||; # get directory number
			if($d > $global_max_commit){
				$global_max_commit=$d;
			}
	}
}

#figure out which branch is checked out
#if the repository exists, ( init has been called before) then the current branch is stored in the branch_log.txt file
if(-e '.legit/branch_log.txt'){
	open BRANCH_LOG,'<' ,'.legit/branch_log.txt';
	my @branch=<BRANCH_LOG>;
	$current_branch=$branch[0];
	close BRANCH_LOG;
}else{
	$current_branch='master';
}

#returns 0 if the two files are the same, returns 1 if the files are different, or one of the files does not exist
sub compare_files{
	my $file1=$_[0];
	my $file2=$_[1];

	if( -e "$file1" and -e "$file2"){
		my $res=compare("$file1", "$file2");
		return $res;
	}

	return 1;
}


#returns the local (across current branch) most recent commit number        
sub find_max_commit{
	my $max=-1;

	foreach $d(glob ".legit/branch.$current_branch/commit.*"){
		$d=~s|.legit/branch.$current_branch/commit.||; # get directory number
			if($d > $max){
				$max=$d;
			}
	}

	return $max;
}

#Verfies if the repository has commits, else exits program
#called by all commands except init, add and commit.
sub check_for_commits{

	my @commits=glob ".legit/branch.$current_branch/commit.*";
	if(@commits==0){
		print STDERR "legit.pl: error: your repository does not have any commits yet\n";
		exit 1;
	}
}

#The init command creates an empty Legit repository.
sub init{

	if (-e ".legit" and -d ".legit"){
		print STDERR "legit.pl: error: .legit already exists\n";
		exit 1;
	}else{
        #create legit directory
		mkdir ".legit" or die "failed to create init .legit dirrectory";
		#create a branch log file which contains only the name of the currently checked out branch
		open BRANCH_LOG,'>','.legit/branch_log.txt';
		print {BRANCH_LOG} "$current_branch";
		close BRANCH_LOG;
		#make a folder for the current branch (master) and store in it the index, log subdirectories
		mkdir ".legit/branch.$current_branch/" or die "Failed to create $current_branch directory";
		mkdir ".legit/branch.$current_branch/index/" or die "Faield to create index in .init func"; 
		mkdir ".legit/branch.$current_branch/log/" or die "failed to create log folder, in .init func";  
		print "Initialized empty legit repository in .legit\n";
		exit 0;
	}
}


#Check if the filename is valid, returns 1 if invalid, 0 if valid
sub valid_name{
	my $f=$_[0] or return 1; #occurs if empty string passed in (i.e. '')
	
    #valid names will always start with an alphanumeric character ([a-zA-Z0-9]) and will only contain alpha-numeric characters plus '.', '-' and '_' characters.
	if($f=~m|/| or $f eq '-' or $f eq '' or $f=~m/^[^a-zA-Z0-9]/ or $f=~m/[^a-zA-Z0-9.-_ ]+/){
		return 1; 
	}
	return 0; 
}


#The add command adds the contents of one or more files to the "index".
sub add{
	my @files=@_;

    #check for any invalid files (directories, non existant, invalid names..)
	foreach $f(@files){

        #filename is invalid
		if(valid_name($f)==1){
			print STDERR"legit.pl: error: invalid filename '$f'\n";
			exit 1;
		}
        #file does not exist or has been deleted from both cwd and index
        #(if a file is not in the cwd but is in the index it can still it can be added-see test 1_13)
		if(not(-e $f) and not(-e ".legit/branch.$current_branch/index/$f")){
			print  STDERR"legit.pl: error: can not open '$f'\n";
			exit 1;
		}
		
        #not an ordinary filetype
		if(not(-f $f) and not(-e ".legit/branch.$current_branch/index/$f")){ 
			print STDERR "legit.pl: error: '$f' is not a regular file\n";
			exit 1;
		}
				
		
	}

    #if we reach this point, all files are able to be added to the index
	foreach $f(@files){
        #overwrite the previously added to the index version of the file
		if(-e ".legit/branch.$current_branch/index/$f"){
			unlink ".legit/branch.$current_branch/index/$f";
		}
		copy($f,".legit/branch.$current_branch/index");# or or die "error adding file $f to index: $!\n";
	}
	return 0;
}
sub compare_cwd_last_commit{
	my $file=$_[0];

	
	my $max=find_max_commit;

	if($max==-1){
	    #no commits have been made yet, so of course the files are different
		return 1; 
	}
	my $i=$max;

    
	if( -e ".legit/branch.$current_branch/commit.$i/$file" and -e ".legit/branch.$current_branch/index/$file"){
       
		my $res=compare_files(".legit/branch.$current_branch/commit.$i/$file", "$file");
		return $res;

	}else{
		return 1; # the file has no previous commits or one of the files does not exist
	}

}


#Compare a given filename in the index and last commit of the current branch.
#returns 0 if files are the same or 1 if the  files are different/the file has been deleted from index/file has not been committed yet
sub compare_index_last_commit{
	my $file=$_[0];

	$file=~s|.legit/branch.$current_branch/index/||;
	my $max=find_max_commit;

	if($max==-1){
	    #no commits have been made yet, so of course the files are different
		return 1; 
	}
	my $i=$max;

    
	if( -e ".legit/branch.$current_branch/commit.$i/$file" and -e ".legit/branch.$current_branch/index/$file"){
       
		my $res=compare_files(".legit/branch.$current_branch/commit.$i/$file", ".legit/branch.$current_branch/index/$file");
		return $res;

	}else{
		return 1; # the file has no previous commits or one of the files does not exist
	}

}

#returns 1 if a file in the last commit is no longer in the index (because rm --cached has been called)
sub check_deleted_files_in_index{
	my $max=find_max_commit;
	if($max==-1){
		return 0;
	}
	foreach $f(glob ".legit/branch.$current_branch/commit.$max/*"){
		$f=~s|.legit/branch.$current_branch/commit.$max/||;
		if(not (-e ".legit/branch.$current_branch/index/$f")){
			return 1;
		}
	}
	return 0;
}

#The commit command saves a copy of all files in the index to the repository.
sub commit{
    #msg is commit message, option is -a or -m
	my ($msg, $option)=@_; 
	my $max=$global_max_commit;

    # legit.pl commit can have a -a option which causes all files already in the index to have their contents from the current directory added to the index before the commit. 
	if($option eq "-a"){

        #go through the files in the index, and replace them with their cwd versions
		foreach $file(glob ".legit/branch.$current_branch/index/*"){ 
			$file=~s|.legit/branch.$current_branch/index/||;
			$cwd_file=$file;

            # if(-e $cwd_file){
            #delete old version in the index
	        unlink ".legit/branch.$current_branch/index/$cwd_file"; 
            # }
            
            #push cwd version of file to the index
		    copy($cwd_file,".legit/branch.$current_branch/index");# or die "error adding file $cwd_file to index: $!\n";
		}

	}


    #our new commit no will be one more than the current global maximum commit number
	$max++; 
	my $dirname=".legit/branch.$current_branch/commit.$max/";

    # check we have something to commit 
	$identical=0; #false
	$num_files_in_index=0;

	foreach $file(glob ".legit/branch.$current_branch/index/*"){ 
		if (-f $file ){ 
 
            #compare file to the last commit version (if there is one)
            #call a fn compare_index_last_commit which returns 0 if files are the same or 1 if the  files are different/no last commit of this file...

		    if(compare_index_last_commit($file)==0) {
			    $identical++;
		    } 
		}
		$num_files_in_index++;
	}

    #if a file has been deleted from the index, this change needs to be committed
	$files_missing=check_deleted_files_in_index; #returns 0 if none missing

    #if all the files are identical and no new files have been added or deleted from the index
    #there is nothing to commit
    if($identical == $num_files_in_index and $files_missing==0){
        print "nothing to commit\n";
        exit 0;
    }

   
	mkdir $dirname or die "died making $dirname because $!";
	
	foreach $file(glob ".legit/branch.$current_branch/index/*"){ 
		if (-f $file ){    
			copy($file,$dirname) or die "error copying $file to $dirname in commit fn\n";
		}

	}
	print "Committed as commit $max\n";

    #append an entry to the log file
	open FILE ,'>>' ,".legit/branch.$current_branch/log/log.txt";  
	#remove trailing spaces from $Msg
	$msg=~s|\s+$||;
	print {FILE} "$max $msg\n";
	close FILE;
	return 0;
}


#legit.pl log prints one line for every commit that has been made to the repository.
sub logger{   
	check_for_commits;
	open FILE ,'<' ,".legit/branch.$current_branch/log/log.txt";  
	@lines=<FILE>;
	
	@lines=reverse @lines;

	print @lines;
	close FILE;
	return 0;
}



#print the contents of the specified file as of the specified commit
#(across all branches, not the current branch).
sub show{

	my @arr=@_;
	my $commit_no=$arr[0];
	my $filename=$arr[1];

    #even if something is in the index and you want to print it, if no commits made yet
    #cannot show it 
	check_for_commits;
	
    #exit if forget to supply a filename or give an invalid one
	if($filename eq ''or $filename eq '-' or $filename=~m/^[^a-zA-Z0-9]/ or $filename=~m/[^a-zA-Z0-9.-_ ]+/){
		print STDERR "legit.pl: error: invalid filename '$filename'\n";
		exit 1;
	}

    
    #print the state of the file in the index
	if($commit_no eq ''){
		if(-e ".legit/branch.$current_branch/index/$filename"){
			open F , '<' , ".legit/branch.$current_branch/index/$filename"; 
			my @text=<F>;
			print @text;
			close F;
			exit 0;
		}   

		print STDERR "legit.pl: error: '$filename' not found in index\n";
		exit 1;

	}else{
	
	    $branch_where_commit_is='';
        #find the branch where the commit number was made
        foreach $b(glob ".legit/branch.*"){
            $b=~s|.legit/branch.||;
	        if(-e ".legit/branch.$b/commit.$commit_no/"){
                $branch_where_commit_is=$b;
                last; #break from loop

	        }
	    }
	     #exit if specified commit no doesnt exist IN ANY branch
	    if($branch_where_commit_is eq ''){
            print STDERR "legit.pl: error: unknown commit '$commit_no'\n";
            exit 1;	    
	    }


	    #print the version of the file in the given commit_no
		if( -e ".legit/branch.$branch_where_commit_is/commit.$commit_no/$filename") {            
			open FILE, "<",  ".legit/branch.$branch_where_commit_is/commit.$commit_no/$filename";
			my @lines=<FILE>;
			print @lines;
			close FILE;
			exit 0;
		}    

		print STDERR "legit.pl: error: '$filename' not found in commit $commit_no\n";
		exit 1;

	}
	return 0;
}



sub rm{
	my ($force_flag, $cached_flag ,@files)=@_;

	check_for_commits;
	
    #check ALL files are valid, if any one of them is not, error and exit 
	foreach $f(@files){
	
		if(valid_name($f)==1){
			print STDERR "legit.pl: error: invalid filename '$f'\n";
			exit 1;
		}
		
		#if the file is not tracked in the index both rm and rm --cached will not work
		if(not(-e ".legit/branch.$current_branch/index/$f")){
			print STDERR "legit.pl: error: '$f' is not in the legit repository\n";
			exit 1;
		}
		
        #check if file is not regular 
		if(not(-f $f) and -e $f){
			print STDERR "legit.pl: error: '$f' is not a regular file\n";
			exit 1;
		}


		if(valid_name($f)==1){
			print STDERR"legit.pl: error: invalid filename '$f'\n";
			exit 1;
		}

	}



	if($force_flag==0){  #in error mode

        #with cached option only remove files from the index
		if($cached_flag==1){
			foreach $f(@files){

				if(not(-e ".legit/branch.$current_branch/index/$f")){
					print STDERR "legit.pl: error: '$f' is not in the legit repository\n";
					exit 1;

				}
				
				my $cwd_compare_index=compare_files($f,".legit/branch.$current_branch/index/$f");
				my $index_compare_last_commit=compare_index_last_commit(".legit/branch.$current_branch/index/$f");
				#make sure difference between cwd and index files is not because the file 
				#does not exist in the cwd anymore - cached option still removes from the index when the file has been rm from the cwd							
				if( ($cwd_compare_index==1 and -e $f) and $index_compare_last_commit==1){
					print STDERR "legit.pl: error: '$f' in index is different to both working file and repository\n";
					exit 1;  
				}
			}


            #all files are valid/in the index,so we can simply delete them from the index 
			foreach $f(@files){
				unlink ".legit/branch.$current_branch/index/$f" or die;
			}



		}else{  
	    #If not in --cached mode we also need to delete the files from the cwd, and do additional checks

			foreach $f(@files){

                #check the file is tracked
				if(not(-e ".legit/branch.$current_branch/index/$f")){                       
					print STDERR "legit.pl: error: '$f' is not in the legit repository\n";
					exit 1;                       
				}

				my $cwd_compare_index=compare_files($f,".legit/branch.$current_branch/index/$f");
				my $index_compare_last_commit=compare_index_last_commit(".legit/branch.$current_branch/index/$f");
				#check file is both in cwd and index, and the file has status "Same as repo"
				if($cwd_compare_index==1 and $index_compare_last_commit==1){
					print STDERR "legit.pl: error: '$f' in index is different to both working file and repository\n";
					exit 1; 
				}


                #make sure the file is the same in index and last commit
				if($index_compare_last_commit==1){
					print STDERR "legit.pl: error: '$f' has changes staged in the index\n"; 
						exit 1;
				}

                # compare index version to cwd
				if($cwd_compare_index==1){
					print STDERR "legit.pl: error: '$f' in repository is different to working file\n";
					exit 1;
				}

			}






            #if not exited, all files are valid to be removed from cwd AND index.

			foreach $f(@files){

				unlink $f;
				unlink ".legit/branch.$current_branch/index/$f";

			}


		}



	}else{

        #The --force option overrides all checks. 
        #we simpy delete the files


	
        #delete from index and delete from cwd
		foreach $f(@files){

			unlink ".legit/branch.$current_branch/index/$f";
			if($cached_flag==0){
			    #if not in cached mode, also delete from cwd
			    unlink $f ;#or die "error $!";
            }
		}

	}
	return 0;
}



#returns 1(true) if file is in the index, 0 if not (false)
sub in_index{
	my $file=$_[0] or die;
	if(-e ".legit/branch.$current_branch/index/$file"){
		return 1;
	}

	return 0;
}

#returns 1 if file in is in the cwd, 0 if not
sub in_cwd{
	my $file=$_[0] or die;
	if(-e "$file"){
		return 1;
	}
	return 0;
}

#check if provided file is in the VERY last commit made or not. returns 1 if it is.
sub in_last_commit{
	my $file=$_[0] or die;
	my $last=find_max_commit;
	my $last_commit_no=find_max_commit;
	if(-e ".legit/branch.$current_branch/commit.$last/$file"){
		return 1; #true
	}
	return 0; #false
}

#print the status of the provided file in the current branch
sub print_file_status{
	my $file=$_[0] or die;
	my $status="$file -";

	my $in_index=in_index($file);
	my $in_cwd=in_cwd($file);
	my $in_last_commit=in_last_commit($file);
	
    #CASE1: "deleted"
    #file is NOT IN index and NOT IN cwd and IS IN THE very LAST commit   
	if(!$in_index and !$in_cwd and $in_last_commit){

		print "$status deleted\n";
		return 0;

	}
    #CASE 2: untracked
    #occurs when the file is NOT in the index.	
	if(!$in_index){
		print "$status untracked\n";
		return 0;

	}


    #CASE3: file deleted
    #file is IN the index, file is NOT IN the cwd (occurs after a normal rm call)
	if($in_index and !$in_cwd){

		print "$status file deleted\n";
		return 0;
	}

    #CASE4: added to index
    #file NOT in last commit and IS IN index 
    #if the file is the same or different in cwd is irrelevant.
	if($in_index and !$in_last_commit){

		print "$status added to index\n";
		return 0;
	}

    #CASE 5: same as repo
    #file in last commit == file in index == file in cwd
	if($in_index and $in_cwd and $in_last_commit and (compare_index_last_commit(".legit/branch.$current_branch/index/$file")==0) and (compare_files(".legit/branch.$current_branch/index/$file","$file")==0) ){

		print "$status same as repo\n";
		return 0;
	}


    #CASE 6:file changed, changes staged for commit	
    #file in last commit != file in the index == file in cwd
	if($in_index and $in_cwd and $in_last_commit and (compare_index_last_commit(".legit/branch.$current_branch/index/$file")==1) and (compare_files(".legit/branch.$current_branch/index/$file","$file")==0) ){
		print "$status file changed, changes staged for commit\n";
		return 0;
	}


    #CASE 7: file changed, different changes staged for commit
    #file in last commit != file in index != file in cwd
	if($in_index and $in_cwd and $in_last_commit and (compare_index_last_commit(".legit/branch.$current_branch/index/$file")==1) and (compare_files(".legit/branch.$current_branch/index/$file","$file")==1) ){
		print "$status file changed, different changes staged for commit\n";
		return 0;
	}

    #CASE 8: file changed, changes not staged for commit
    #file in the index == last commit != file in cwd 

	if($in_index and $in_cwd and $in_last_commit and (compare_index_last_commit(".legit/branch.$current_branch/index/$file")==0) and compare_files("$file",".legit/branch.$current_branch/index/$file")==1 ){
		print "$status file changed, changes not staged for commit\n";
		return 0;
	}

	
	return 1;
}

#print status messages for files, alphabetically sorted.
sub status{

	check_for_commits;
	
    #use a dictionary as a set for storing every file in the index, last commit and cwd ONCE only.
	my %seen_files=();
	my $i=find_max_commit;
	
    #Add files from last commit
	foreach $f(glob ".legit/branch.$current_branch/commit.$i/*"){
		$f=~s|.legit/branch.$current_branch/commit.$i/||;
		$seen_files{$f}=1;
	}

    #add files in the index
	foreach $f(glob ".legit/branch.$current_branch/index/*"){
		$f=~s|.legit/branch.$current_branch/index/||;
		$seen_files{$f}=1;
	}

    #add files in cwd
	foreach $f(glob "*"){  
        #do not track folders, only files with VALID filenames
		if(-f $f and valid_name($f)==0){         
			$seen_files{$f}=1;     
		}           
	}



    #go through keys in seen_files hashes
	foreach $file_key (sort keys %seen_files){
        #figure out the files status and print it.
		print_file_status($file_key);

	}
	return 0;
}


#helper function for branch subroutine
#returns 1 if provided file is in provided branch's last commit
sub check_file_in_last_commit{
    my ($file, $branch)=@_;


    #find last commit number for $branch
    my $max=-1;
	foreach $d(glob ".legit/branch.$branch/commit.*"){
		$d=~s|.legit/branch.$branch/commit.||; # get directory number
			if($d > $max){
				$max=$d;
			}
	}

    if($max ==-1){  #no commits made for this branch
        return 0;
    }
    #check if $file is in last commit folder, if yes return 1
    foreach $f(glob ".legit/branch.$branch/commit.$max/*"){
        $f=~s|.legit/branch.$branch/commit.$max/||;
        if($f eq $file){
            return 1;
        }
    
    }
   
   return 0;

}

sub branch{
	check_for_commits;

	my ($list_mode, $delete_mode, $create_mode, $branch_name)=@_;  

	if($list_mode){
        #print the list of branches alphabetically sorted
		my @branches=glob(".legit/branch.*");
		@branches=sort @branches;
		foreach $b(@branches){
			$b=~s|.legit/branch.||;
			print "$b\n";
		}



	}elsif($create_mode){

    #check branch name does not already exist
		if(-e ".legit/branch.$branch_name/"){
			print STDERR "legit.pl: error: branch '$branch_name' already exists\n";
			exit 1;
		}

        #check branch name is valid and not all numbers
		if(valid_name($branch_name)==1 or $branch_name=~/^[0-9]+$/){
			print STDERR "legit.pl: error: invalid branch name '$branch_name'\n";
			exit 1;

		}

		mkdir ".legit/branch.$branch_name/" or die "error creating new branch $branch_name";
		
        #make sub directories and copies of commits, log, index for current branch
		mkdir ".legit/branch.$branch_name/index/" or die;
		mkdir ".legit/branch.$branch_name/log/" or die;
		mkdir ".legit/branch.$branch_name/copy_cwd/" or die;

        #make copy of the real cwd in copy_cwd folder so the cwd state can be restored during checkout
		foreach $f(glob "*"){
           #if(-f $f and valid_name($f)==0){ 
	            copy($f,".legit/branch.$branch_name/copy_cwd/");

          #  }
		}


        #make a copy of the log file
		copy(".legit/branch.$current_branch/log/log.txt",".legit/branch.$branch_name/log/");


        #copy across each commit subdirectory
		foreach $commit(glob ".legit/branch.$current_branch/commit.*" ){
			$commit=~s|.legit/branch.$current_branch/commit.||;
			my $num=$commit;

			mkdir ".legit/branch.$branch_name/commit.$num/";
            #copy across files in the commit
			foreach $file(glob ".legit/branch.$current_branch/commit.$num/*"){
				copy ($file,".legit/branch.$branch_name/commit.$num");#or die;
			}

		}

        #copy across index
		mkdir ".legit/branch.$branch_name/index/";
		foreach $file(glob ".legit/branch.$current_branch/index/*"){
			copy($file, ".legit/branch.$branch_name/index");
		}




	}else{  #delete mode

        #  check branch name is not $current_branch
		if($branch_name eq $current_branch or $branch_name eq "master"){
			print STDERR "legit.pl: error: can not delete branch '$branch_name'\n";
			exit 1;

		}
        #check branch name exists
		if(not(-e ".legit/branch.$branch_name")){
			print STDERR "legit.pl: error: branch '$branch_name' does not exist\n";
			exit 1;
		}
        #check that the branch about to be deleted does not have any committed files that do not exist in any other branches commits 
    
        my $not_in_any_other_commits=0; #initally false
        
        #find last commit of the branch to be deleted
        my $max=-1;
        foreach $d(glob ".legit/branch.$branch_name/commit.*"){
            $d=~s|.legit/branch.$branch_name/commit.||; # get directory number
            if($d > $max){
	            $max=$d;
            }
        }

        
        foreach $file(glob ".legit/branch.$branch_name/commit.$max/*"){
            $file=~s|.legit/branch.$branch_name/commit.$max/||;
            $in_any_other_commits=0;
            #see if the file in the last commit exists in another branch
            foreach $b(glob ".legit/branch.*"){
               
                $b=~s|.legit/branch.||;
                 if($b ne $branch_name){
                    # print "consdering if $file in in $b\n";
                     my $res=check_file_in_last_commit($file,$b);
                     if($res==1){ #file is in another commit
                       $in_any_other_commits=1;
                       last;
                     }
               }
            }
            if($in_any_other_commits==0){
                print STDERR "legit.pl: error: branch '$branch_name' has unmerged changes\n";
                exit 1;
            }
        }
       
       

        #delete log subdir
		unlink ".legit/branch.$branch_name/log/log.txt";
		rmdir ".legit/branch.$branch_name/log/";



        #rm copy of cwd at the state when branched
		foreach $f(glob ".legit/branch.$branch_name/copy_cwd/*"){
			unlink $f;       
		}
		rmdir ".legit/branch.$branch_name/copy_cwd/";# or die;

        #delete each commit subdirectory
		foreach $commit(glob ".legit/branch.$branch_name/commit.*" ){
			$commit=~s|.legit/branch.$branch_name/commit.||;
			my $num=$commit;
            #delete files
			foreach $file(glob ".legit/branch.$branch_name/commit.$num/*"){
				unlink $file or die "$!";
			}
			rmdir ".legit/branch.$branch_name/commit.$num/"or die "$!";

		}

        #delete index subdir
		foreach $file(glob ".legit/branch.$branch_name/index/*"){
			unlink $file or die "$!";
		}
		rmdir ".legit/branch.$branch_name/index/";

        #finally delete branch itself
		rmdir ".legit/branch.$branch_name/";
		print "Deleted branch '$branch_name'\n";
		exit 0;

	}

	return 0;
}

#helper function for the checkout subroutine.
#compare the state of the last commits for two branches
#return the files in the old_branch whose changes need to be saved before checkout
#to the new branch.
sub compare_last_commits{
    my @error_files=();
    
    #old branch is the branch currently checkout, new branch is the branch about to be checkout out
    my ($old_branch, $new_branch)=@_;
    
    #find the last/max commit for the old and new branches
    my $old_max=-1;
    my $new_max=-1;
    foreach $co(glob ".legit/branch.$old_branch/commit.*"){
        $co=~s|.legit/branch.$old_branch/commit.||;
        if($co > $old_max){
            $old_max=$co;      
        }      
    }  
     
    
    foreach $co(glob ".legit/branch.$new_branch/commit.*"){
        $co=~s|.legit/branch.$new_branch/commit.||;
        if($co > $new_max){
            $new_max=$co;        
        }      
    }
    
    #if both branches have no commits , return
    if($old_max==-1 and $new_max==-1){
        return @error_files; 
    }
   
   
    #for each file in the current branch , check if it is in the new branch.  
    foreach $file(glob ".legit/branch.$old_branch/commit.$old_max/*"){
        $file=~s|.legit/branch.$old_branch/commit.$old_max/||;
        
        if( -e ".legit/branch.$new_branch/commit.$new_max/$file"){
            #compare the file across the two branches last commits
            $diff_flag=compare(".legit/branch.$old_branch/commit.$old_max/$file",
            ".legit/branch.$new_branch/commit.$new_max/$file");
            
            #if the files differ in the last commits AND the file has changed since the last commit in the current branch, this files changes will be lost on checkout
            if($diff_flag==1 and (compare_cwd_last_commit($file)==1 or compare_index_last_commit($file)==1)){
                push @error_files,$file;
            }
        
        }else{
            #if the file has never been committed on the new branch AND
            #the file has changed since the last commit on the current branch, the files changes will be lost on checkout 
            if(compare_cwd_last_commit($file)==1 and in_last_commit($file) or compare_index_last_commit($file)==1){
                push @error_files,$file;
            }
        }
        
    }
    
    #return the files in old_branch whose changes will be overwritten by checkout
    return @error_files;
}

sub checkout{

	check_for_commits;
	my $branch_name=$_[0];

    #non existant branch error
	if(not(-e ".legit/branch.$branch_name")){
		print STDERR "legit.pl: error: unknown branch '$branch_name'\n";
		exit 1;
	}
    #already on the branch error
	if($current_branch eq $branch_name){
		print "Already on '$branch_name'\n"; 
		exit 0; 
	}

   #get the files whose changes would be overwritten upon checkout to the new branch
   my @error_files=compare_last_commits($current_branch, $branch_name);
   if(@error_files!=0){
        print STDERR "legit.pl: error: Your changes to the following files would be overwritten by checkout:\n";
       foreach $f(@error_files){      
            print STDERR "$f\n";
       } 
       exit 1;     
   }
  
    #save a copy of the current working directory to a folder called copy_cwd
    #so that when this branch is checked out again the cwd state can be restored
    if(-e ".legit/branch.$current_branch/copy_cwd/"){ 
        #if already exists, update folder contents
	    foreach $f(glob "*"){
		    if(-e ".legit/branch_$current_branch/copy_cwd/$f"){
		         #replace old file version
			    unlink ".legit/branch_$current_branch/copy_cwd/$f";
		    }
       
	    copy($f,".legit/branch.$current_branch/copy_cwd/"); #or die
	    }
    }else{
        #If does not exist yet create new folder
	    mkdir ".legit/branch.$current_branch/copy_cwd/"; 
        #make copy of real cwd in copy_cwd folder
	    foreach $f(glob "*"){      
	        copy($f,".legit/branch.$current_branch/copy_cwd/");
	    }
    }
    
    #files that need to be updated or created in the branch we are about to 
    #checkout
    my @files_to_push_to_index=();
   
    #files that need to be reverted to their last committed version
    #in the index/cwd of the branch we are about to checkout
    my @files_to_revert_in_index=();
    
    for $f(glob ".legit/branch.$current_branch/index/*"){
	    $f=~s|.legit/branch.$current_branch/index/||;
        #add to the branch about to be checked out's index any files newly created or that have uncommitted changes
	    if(compare_index_last_commit($f)==1 or compare_files(".legit/branch.$current_branch/index/$f",".legit/branch.$current_branch/copy_cwd/$f")==1){
		    push @files_to_push_to_index,".legit/branch.$current_branch/index/$f";

	    }
       
    }
    
    #These are files that have changed or been created in the working directory
    #in the branch we are currently on , and these changed files have not yet been committed
    #These files need to be copied to the working directory of the branch we are
    #about to checkout
    my @files_in_cwd_and_shared_index=();
    
    for $f(glob "*"){   
	    if(-f $f and valid_name($f)==0){	 
            my $in_index=in_index($f);
            my $in_cwd=in_cwd($f);
            my $in_last_commit=in_last_commit($f);
                       
            #If file is "same as repo" the file has been committed 
            #and has not changed in the working directory or index since
            #so we need to revert the versions of the file in the index/workign directory of the new branch to the new branch's last committed version
            if($in_index and $in_cwd and $in_last_commit and (compare_index_last_commit(".legit/branch.$current_branch/index/$f")==0) and (compare_files(".legit/branch.$current_branch/index/$f","$f")==0) ){
               push @files_to_revert_in_index,"$f";
             
             
            }    
            
            
            #If file has changed since last commit, it will need to be added to the 
            #cwd and index of the new branch
            if($in_index==0 or $in_cwd==0 or $in_last_commit==0 or (compare_index_last_commit(".legit/branch.$current_branch/index/$f")==1) or (compare_files(".legit/branch.$current_branch/index/$f","$f")==1) ){
                push @files_in_cwd_and_shared_index, ".legit/branch.$current_branch/copy_cwd/$f";

            }

		    
	    }
    }


    #SWITCH BRANCHES:
    my $old_branch=$current_branch;
    $current_branch=$branch_name;
    #update current_branch in branch_log.txt
    open BRANCH_LOG,'>','.legit/branch_log.txt';
    print {BRANCH_LOG} "$current_branch";
    close BRANCH_LOG;
    print "Switched to branch '$current_branch'\n";
    
    #RESTORE copy_cwd of this branch to the real working directory
 
    #delete current working directory
    foreach $f(glob "*"){
	    unlink $f;
    }
    
    #restore saved version of working directory
    foreach $f(glob ".legit/branch.$current_branch/copy_cwd/*"){
        $f=~s|.legit/branch.$current_branch/copy_cwd/||;
  
	        copy(".legit/branch.$current_branch/copy_cwd/$f",'.'); 
     
    }
    
    #Update our cwd with files from the previous branch's cwd that have changed/been created and not committed   
    foreach $f(@files_in_cwd_and_shared_index){
	    copy($f,'.');
    }
    
    #Update our index with files from the previous branch's index 
    #that have uncommited changes or were newly added
    foreach $f(@files_to_push_to_index){
	    copy($f,".legit/branch.$current_branch/index/");
    }

    #restore files that were committed in the previous branch to their last committed state in this branch's index and cwd
    foreach $f(@files_to_revert_in_index){

       
        #find last committed version 
        #find the file in the cwd and index
        #revert files back to the last committed version 

        #last committed version
	    my $max=find_max_commit;
	    
        #delete cwd and index versions of the file 
	    if(-e ".legit/branch.$current_branch/index/$f"){
		    unlink ".legit/branch.$current_branch/index/$f";
	    }
	    if(-e "$f"){
		    unlink "$f";
	    }
        
         #revert index and cwd files to last commit version
        copy(".legit/branch.$current_branch/commit.$max/$f",".legit/branch.$current_branch/index/");
        copy(".legit/branch.$current_branch/commit.$max/$f",".");
        
        }  
    exit 0;
}


#ARGUMENT PROCESSING

#Check a command was supplied
if(@ARGV==0){
print"Usage: legit.pl <command> [<args>]

These are the legit commands:
   init       Create an empty legit repository
   add        Add file contents to the index
   commit     Record changes to the repository
   log        Show commit log
   show       Show file at particular state
   rm         Remove files from the current directory and from the index
   status     Show the status of files in the current directory, index, and repository
   branch     list, create or delete a branch
   checkout   Switch branches or restore current directory files
   merge      Join two development histories together

"; 
	exit 1;
}
$command=shift @ARGV;
if($command eq "init"){
	init;
	return 0;
}

#for all other commands except init, we need to check the .legit directory
#exists before we can execute the command
if(not(-e ".legit/")){  
	print STDERR"legit.pl: error: no .legit directory containing legit repository exists\n";
	exit 1;
}


if($command eq "add"){

	@filenames=@ARGV;
	#Allowed to assume filenames will be supplied.
	add(@filenames);

}elsif($command eq "commit"){

    #check a -a or -m argument was provided
	if(@ARGV==0){
		print STDERR"usage: legit.pl commit [-a] -m commit-message\n";
		exit 1;
	}
	
	my $first_option=shift @ARGV;
	#make sure a valid option was provided
	if($first_option ne "-m" and $first_option ne "-a"){
		print STDERR"usage: legit.pl commit [-a] -m commit-message\n";
		exit 1;
	}

	if($first_option eq "-a"){
	    #check the rest of the required args were provided
		if(@ARGV==0){
			print STDERR "usage: legit.pl commit [-a] -m commit-message\n";
			exit 1;

		}
		my $second_option=shift @ARGV;
		#check -m and files were supplied
		if($second_option ne "-m" or @ARGV==0){ 
			print STDERR "usage: legit.pl commit [-a] -m commit-message\n";
			exit 1;

		}
		
        #second option is -m ...
		my $msg=shift @ARGV;
		commit($msg, $first_option);


    #first option is -m
	}else{
        # There should only be one more argument ( a commit message)
		if(@ARGV==0 or @ARGV==2){  
			print STDERR"usage: legit.pl commit [-a] -m commit-message\n";
			exit 1;
		}

		my $msg=shift @ARGV;
        #we cannot have a msg that is the same as one of the options
		if($msg eq '-m' or $msg eq '-a'){
			print STDERR"usage: legit.pl commit [-a] -m commit-message\n";
			exit 1;
		}

        #msgs cannot have a newline in them
		if($msg=~m|\n|){
			print STDERR "legit.pl: error: commit message can not contain a newline\n";
			exit 1;

		}
		commit($msg, $first_option); 
	} 

}elsif($command eq "log"){
	logger;

}elsif($command eq "show"){


    # check we are given an argument
	if(@ARGV==0){
		print STDERR"usage: legit.pl show <commit>:<filename>\n";
		exit 1;
	}
	$argument=$ARGV[0];
    
    #make sure argument is of the correct format
	if(not($argument=~m/^.*:.+$/)){
		print STDERR "legit.pl: error: invalid object '$argument'\n";
		exit 1;

	}

    #pass the commit number and filename as seperate arguments
	my @arr=split(":",$argument);
	show(@arr);


}elsif($command eq "rm"){

    #options can be anywhere after "rm" in the command
   #according to ref implementation , allowed to assume at least one filename (non option) will be provided
	
	my $force_flag=0;
	my $cached_flag=0;
	my @files_to_rm=();
	#go through @ARGV setting $force or $cached flags if these options are provided,
	#storing the filenames provided, and exiting if any invalid options are given
	foreach $arg(@ARGV){
	    
	    if($arg eq "--force"){
		    $force_flag=1;

	    }elsif($arg eq "--cached"){
		    $cached_flag=1;

	    }
	    # some unknown -option
	    elsif($arg=~/^-.*/){ 
		    print STDERR "usage: legit.pl rm [--force] [--cached] <filenames>\n";
		    exit 1;
	    }else{
	        push @files_to_rm,$arg;	        	    
	    }	
	
	}
	rm($force_flag,$cached_flag, @files_to_rm);

}elsif($command eq "status"){

	status;

}elsif($command eq "branch"){

 
    #legit.pl branch either creates a branch, deletes a branch or lists current branch names.
	my $list_mode=0;
	my $delete_mode=0;
	my $create_mode=0;
	if(@ARGV==0){
        #we only have to list the branches, no other options supplied
		$list_mode=1;
		branch($list_mode, $delete_mode,$create_mode,@ARGV);
		exit 0;

	} 
	$possible_first_option=shift @ARGV;
	if($possible_first_option eq "-d"){
	    #No branchname specified to delete
		if(@ARGV==0){ 
			print STDERR "legit.pl: error: branch name required\n";
			exit 1;
		}
        # too many branch names specified
		if(@ARGV!=1){
			print STDERR "usage: legit.pl branch [-d] <branch>\n";
			exit 1;
		}

		$delete_mode=1;
        #argv contains the branch name
		branch($list_mode, $delete_mode,$create_mode,@ARGV);
		
	}else{
		$create_mode=1;
        #can only supply one branch name
		if(@ARGV !=0){
			print STDERR "usage: legit.pl branch [-d] <branch>\n";
			exit 1;
		}
        #$possible_first_option was the branchname
		branch($list_mode, $delete_mode,$create_mode,$possible_first_option);
	}

}elsif ($command eq "checkout"){

    #too little or too many branchnames supplied
	if(@ARGV!=1){ 
		print STDERR "usage: legit.pl checkout <branch>\n";
		exit 1;
	}else{
		checkout(@ARGV);
	}
}

else{ #unknown command supplied
    print STDERR 
"legit.pl: error: unknown command $command
Usage: legit.pl <command> [<args>]

These are the legit commands:
   init       Create an empty legit repository
   add        Add file contents to the index
   commit     Record changes to the repository
   log        Show commit log
   show       Show file at particular state
   rm         Remove files from the current directory and from the index
   status     Show the status of files in the current directory, index, and repository
   branch     list, create or delete a branch
   checkout   Switch branches or restore current directory files
   merge      Join two development histories together

"; 
	exit 1;
}
exit 0;
