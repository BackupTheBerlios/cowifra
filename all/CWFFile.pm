package CWFFile;

use strict;

####################################################################################
# FUNCTION INDEX:					
# new
# load_file
# find_key
# get_key_values
# get_key_values_within_section
# get_alt_key_values
# set_key_values
# get_section
# count_sections
# save_file
# is_error
# get_error_msg
# is_warning
# get_warning
# addslashes (not member of this class)





sub new {
	############################################################################
	# Parameter:
	#	1=Conf. file
	############################################################################
        my $pkg = shift;
	my $cfile = shift;								# First parameter filepath + name of xml file
	my $self = {};									# Start object

	if (! $cfile) {
		$self->{error}	= "- Parameter 1 Conf-filename is needed by object (pm:CWFFile[".__LINE__."], $0)";
		$self->{cfile} = "";
	} elsif (! -f $cfile) {								# check if conf file exists
		$self->{error}	= "- File does not exist $cfile (pm:CWFFile[".__LINE__."], $0)";
		$self->{cfile} = "";
	} else {									# xmlfile is defined and exists
		$self->{error};
		$self->{cfile} = $cfile;
	}

	bless $self, $pkg;								# object meets world
	return $self;
}

sub load_file {
	my $self = shift;
	my @conffile;
	(length($self->{cfile}) == 0) && ($self->{error} .= "- No file given Method: load_conf_into_file() (pm:CWFFile[".__LINE__."], $0)") && (return -1);
	if (! $self->{error}) {
		if (open(CONFFILE, $self->{cfile})) {
			while(my $input = <CONFFILE>)  {
				push @conffile, $input;
			}
			close CONFFILE;
		} else {
			$self->{error} .= "- Can\'t open file for reading (pm:CWFFile[".__LINE__."], $0)";
			return -1;
		}
	}
	$self->{fcontent} = \@conffile;
}

sub find_key {
	my $self = shift;
	my $key = shift;
	my $assignchars = shift;
	my $notinstart = shift;
	my $notinstop = shift;
	my $innot = 0;

	if (! $key) {
		$self->{error} .= "- Need first argument key Method: find_key() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	if ((! $self->{cfile}) || (! $self->{fcontent})) {
		$self->{error} .= "- File not loaded use load_file first Method: find_key() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	my $fcontent = $self->{fcontent};
	my @fcontenta = @$fcontent;
	my $oneline;
	my $searchstring = '^\s*'.&addslashes($key).'\s*'.&addslashes($assignchars).'\s*';	
	my $found = 0;
	foreach $oneline (@fcontenta) {
	  ($notinstart) && ($oneline =~ m/$notinstart/i) && ($innot++);
          ($notinstop) && ($oneline =~ m/$notinstop/i) && ($innot--);
	  ($innot < 0) && ($innot = 0);

	  ($innot == 0) && ($oneline =~ m/$searchstring/i) && ($found++);
	}
	return $found;
}

sub get_key_values {
	my $self = shift;
	my $key = shift;
	my $assignchars = shift;
	my $notinstart = shift;
	my $notinstop = shift;
	my $innot = 0;
	
	if (! $key) {
		$self->{error} .= "- Need first argument key Method: get_key_value() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	if (! $assignchars) {
		$self->{error} .= "- Need second argument assign chars Method: get_key_value() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	
	if ((! $self->{cfile}) || (! $self->{fcontent})) {
		$self->{error} .= "- File not loaded use load_file first Method: get_key_value() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	my $fcontent = $self->{fcontent};
	my @fcontenta = @$fcontent;
	my $oneline;
	my $searchstring = '^\s*'.&addslashes($key).'\s*?'.&addslashes($assignchars).'\s*';
	#print $searchstring."<br>";
	my @valuesfound;
	foreach $oneline (@fcontenta) {
	  ($notinstart) && ($oneline =~ m/$notinstart/i) && ($innot++);
    ($notinstart) && ($oneline =~ m/$notinstop/i) && ($innot--);
	  ($innot < 0) && ($innot = 0);
    ($innot > 0) && next;  # if we are in the not section skip line	  

		$oneline =~ s/\t/ /g; # remove tabs
	  if (($oneline =~ m/$searchstring/i)) {
	  	#print $oneline."<br>";
	  	my $subsearch = '^\s*'.&addslashes($key).'\s*'.&addslashes($assignchars).'\s*(.*)';
	      	#print $subsearch."<br>";
	      	if (($oneline =~ m/$subsearch/i)) {
	        	(($1) || ($1 eq "0")) && (push(@valuesfound, $1));
	      	}
	  } 
        } #for 
	return @valuesfound;
}

sub get_key_values_within_section {
	my $self = shift;
	my $key = shift;
	my $assignchars = shift;
	my $instart = shift;
	my $instop = shift;
	my $secnr = shift; 
	my $actsec = 0;
	my $isin = 0;
	
	if (! $key) {
		$self->{error} .= "- Need first argument key Method: get_key_value_within_section() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	if (! $assignchars) {
		$self->{error} .= "- Need second argument assign chars Method: get_key_value_within_section() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	if (! $instart) {
		$self->{error} .= "- Need third argument - start section definition Method: get_key_value_within_section() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	if (! $instop) {
		$self->{error} .= "- Need second argument - stop section definition Method: get_key_value_within_section() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}	
	if ((! $self->{cfile}) || (! $self->{fcontent})) {
		$self->{error} .= "- File not loaded use load_file first Method: get_key_value_within_section() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	my $fcontent = $self->{fcontent};
	my @fcontenta = @$fcontent;
	my $oneline;
	my $searchstring = '^\s*'.&addslashes($key).'\s*?'.&addslashes($assignchars).'\s*';
	my @valuesfound;
	foreach $oneline (@fcontenta) {
		if (($instart) && ($oneline =~ m/$instart/i)) {
			$isin++;
			$actsec++;
		}
    	($instart) && ($oneline =~ m/$instop/i) && ($isin--);
	  	($isin < 0) && ($isin = 0);
    	#print $actsec."--";
    	(($actsec != $secnr) || ($isin == 0)) && next;  # if we are in the section skip line	
		$oneline =~ s/\t/ /g; # remove tabs
		if (($oneline =~ m/$searchstring/i)) {
	  		my $subsearch = '^\s*'.&addslashes($key).'\s*'.&addslashes($assignchars).'\s*(.*)';
	      	if (($oneline =~ m/$subsearch/i)) {
	        	(($1) || ($1 eq "0")) && (push(@valuesfound, $1));
	      	}
	  	} 
   	} #for 
	return @valuesfound;
}


sub get_alt_key_values {
	my $self = shift;
	my $key = shift;
	my $assignchars = shift;
  my $commentchar = shift;
	my $notinstart = shift;
	my $notinstop = shift;      
	my $innot = 0;
	
	if (! $key) {
		$self->{error} .= "- Need first argument key Method: get_alt_key_values() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}

	if (! $assignchars) {
		$self->{error} .= "- Need second argument assign char Method: get_alt_key_values() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	
	if (! $commentchar) {
		$self->{error} .= "- Need third argument comment char Method: get_alt_key_values() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}

	if ((! $self->{cfile}) || (! $self->{fcontent})) {
		$self->{error} .= "- File not loaded use load_file first Method: get_alt_key_values() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	my $fcontent = $self->{fcontent};
	my @fcontenta = @$fcontent;
	my $oneline;
	my $searchstring = '^\s*'.&addslashes($commentchar).'+\s*'.&addslashes($key);   # before key should only by commentchars and spaces	
	#print $searchstring."<br>";	
	#my $found = 0;
	my @prealtvalues;
	foreach $oneline (@fcontenta) {
		$oneline =~ s/\t/ /g; # remove tabs
		($notinstart) && ($oneline =~ m/$notinstart/i) && ($innot++);
    ($notinstop) && ($oneline =~ m/$notinstop/i) && ($innot--);
    ($innot < 0) && ($innot = 0);
    ($innot > 0) && next;  # if we are in the not section skip line
		if (($oneline =~ m/$searchstring/i)) {
			#$found++;
			#print $oneline."<br>";
			my $subsearch = '^\s*'.&addslashes($commentchar).'+\s*?'.&addslashes($key).'\s*?'.&addslashes($assignchars).'\s*(.*)';
			#print $subsearch;
			($oneline =~ m/$subsearch/i) && (push (@prealtvalues, $1));      
		} 
	}
	return @prealtvalues;
}

sub get_alt_key_values_within_section {
	my $self = shift;
	my $key = shift;
	my $assignchars = shift;
  	my $commentchar = shift;
	my $instart = shift;
	my $instop = shift;    
	my $sectionnr = shift;
	my $isin = 0;
	
	if (! $key) {
		$self->{error} .= "- Need first argument key Method: get_alt_key_values_within_section() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}

	if (! $assignchars) {
		$self->{error} .= "- Need second argument assign char Method: get_alt_key_values_within_section() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	
	if (! $commentchar) {
		$self->{error} .= "- Need third argument comment char Method: get_alt_key_values_within_section() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}

	if (! $instart) {
		$self->{error} .= "- Need fourth argument instart Method: get_alt_key_values_within_section() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}

	if (! $instop) {
		$self->{error} .= "- Need fifth argument instop Method: get_alt_key_values_within_section() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}

	if (! $sectionnr) {
		$self->{warning} .= "- Sixth argument not given using 1 as value  Method: get_alt_key_values_within_section() (pm:CWFFile[".__LINE__."], $0)";
		$sectionnr = 1;
	}

	if ((! $self->{cfile}) || (! $self->{fcontent})) {
		$self->{error} .= "- File not loaded use load_file first Method: get_alt_key_values_within_section() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}
	my $fcontent = $self->{fcontent};
	my @fcontenta = @$fcontent;
	my $oneline;
	my $searchstring = '^\s*'.&addslashes($commentchar).'+\s*'.&addslashes($key);   # before key should only by commentchars and spaces	
	#print $searchstring."<br>";	
	#my $found = 0;
	my $seccount = 0;
	my @prealtvalues;
	foreach $oneline (@fcontenta) {
		$oneline =~ s/\t/ /g; # remove tabs
		if (($instart) && ($oneline =~ m/$instart/i)) {
			$isin++;
			$seccount++;
		}
    	($instop) && ($oneline =~ m/$instop/i) && ($isin--);
    	($isin < 0) && ($isin = 0);
    	($seccount != $sectionnr) && next;  # if we are in the not section skip line
		if (($oneline =~ m/$searchstring/i)) {
			#$found++;
			#print $oneline."<br>";
			my $subsearch = '^\s*'.&addslashes($commentchar).'+\s*?'.&addslashes($key).'\s*?'.&addslashes($assignchars).'\s*(.*)';
			#print $subsearch;
			($oneline =~ m/$subsearch/i) && (push (@prealtvalues, $1));      
		} 
	}
	return @prealtvalues;
}


sub set_key_values {
	my $self = shift;
	my $key = shift;
	my $assignchars = shift;
  my $commentchar = shift;
	my $valuesref = shift;					# contains reference to array
	my @newvalues = @$valuesref;				# values coutains now all values (dereference)
	my $notinstart = shift;
	my $notinstop = shift;      
	my $innot = 0;	
	if (! $key) {
		$self->{error} .= "- Need first argument key Method: set_key_values() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}

	if (! $assignchars) {
		$self->{error} .= "- Need second argument assign chars Method: set_key_values() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}

	if (! $commentchar) {
		$self->{error} .= "- Need third argument assign chars Method: set_key_values() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}

	($commentchar eq "NOCOMMENT") && (undef($commentchar));

	if (@newvalues == 0) {
		$self->{warning} .= "- Fourth argument not given using empty value  Method: set_key_values() (pm:CWFFile[".__LINE__."], $0)";
	}
	
	if ((! $self->{cfile}) || (! $self->{fcontent})) {
		$self->{error} .= "- File not loaded use load_file first Method: get_key_value() (pm:CWFFile[".__LINE__."], $0)";
		return -1;
	}

	($self->{error}) && (return 0);

	my $fcontent = $self->{fcontent};     # Get data from object
	my @fcontenta = @$fcontent;
	my $oneline;
	my $searchstring;	
	my @searchstrings;
	#my $found = 0;
  my @ncontent;
	my $linenumber = 0; # Remember the linenumber of the last line changed

	#1. get the current values
	my @currentvalues = $self->get_key_values ($key, $assignchars, $notinstart, $notinstop);

	#2. delete all comment out keys with active or old values
	if ($commentchar) {
    for (my $i=0;$i<@newvalues;$i++) {
    	push (@searchstrings,'^\s*'.&addslashes($commentchar).'+\s*'.&addslashes($key).'\s*?'.&addslashes($assignchars).'\s*?'.&addslashes($newvalues[$i]).'\s*?');
	  }          
	  for (my $i=0;$i<@currentvalues;$i++) {
	    push (@searchstrings,'^\s*'.&addslashes($commentchar).'+\s*'.&addslashes($key).'\s*?'.&addslashes($assignchars).'\s*?'.&addslashes($currentvalues[$i]).'\s*?');
	  }
	  #print "NOTSTART: ".$notinstart."<br>";
	  for (my $i=0;$i<@fcontenta;$i++) {
	    $oneline = $fcontenta[$i];
	  	$oneline =~ s/\t/ /g; # remove tabs
	    ($notinstart) && ($oneline =~ m/$notinstart/i) && ($innot++);
	    ($notinstop) && ($oneline =~ m/$notinstop/i) && ($innot--);
	    ($innot < 0) && ($innot = 0);
      ($innot > 0) && (push (@ncontent, $oneline)) && next;  # if we are in the not section skip line
      my $foundline = 0;
	    for (my $j=0; $j < @searchstrings; $j++) {
				if ($oneline =~ m/$searchstrings[$j]/i) {
		  		$foundline = 1;
		  		$linenumber = $i;
	      }
      }
	    if ($foundline == 1) {
	      next;  
	    } else { 
	      push (@ncontent, $oneline);
	    }
	  }
	  @fcontenta = @ncontent;
	  undef (@ncontent);
  } 

	#3. delete all active keys, but remember the line number of the first
	my $firstkeyfound = 0;
	my @searchstrings; # reset searchstrings
  push (@searchstrings,'^\s*'.&addslashes($key).'\s*?'.&addslashes($assignchars).'\s*?.*?\s*?'); # each key with any value
	for (my $i=0;$i<@fcontenta;$i++) {
	  $oneline = $fcontenta[$i];
	  ($notinstart) && ($oneline =~ m/$notinstart/i) && ($innot++);
	  ($notinstop) && ($oneline =~ m/$notinstop/i) && ($innot--);
	  ($innot < 0) && ($innot = 0);
	  ($innot > 0) && (push (@ncontent, $oneline)) && next;  # if we are in the not section skip line

    my $foundline = 0;
            
	  if ($oneline =~ m/$searchstrings[0]/i) {
	    $foundline = 1;
	    ($firstkeyfound == 0) && ($firstkeyfound = $i);
	  }
	  if ($foundline == 1) {
	    next;  
	  } else { 
	    push (@ncontent, $oneline);
	  }
  } # end for
	@fcontenta = @ncontent;
	undef (@ncontent);
	
	#4. change value of active key
	#$searchstring = '^\s*'.&addslashes($key);
	#$found = 0;
	#for ($i=0;$i<$acount;$i++) {
	#  $oneline = $fcontenta[$i];
	#  ($notinstart) && ($oneline =~ m/$notinstart/i) && ($innot++);
	#  ($notinstop) && ($oneline =~ m/$notinstop/i) && ($innot--);
	#  ($innot < 0) && ($innot = 0);
	#  ($innot > 0) && next;  # if we are in the not section skip line
	#
	#  if (($oneline =~ m/$searchstring/i)) {
	#    my $subsearch = '^\s*'.&addslashes($key).'\s*'.&addslashes($assignchars).'\s*?.*';
	#    if (($oneline =~ m/$subsearch/i)) {
	#      $found++;	
	#      $oneline = $key.$assignchars.$value."\n";
	#      $linenumber = $i;
	#    }
	#  } 
        #  push (@ncontent, $oneline);
	#}
	#@fcontenta = @ncontent;
	#undef (@ncontent);
	
	#5. if value changed and if line number of last change is defined, add comment out old key -> value
	if ($commentchar) {
	  my ($sec, $min, $stunde, $mtag, $mon, $jahr, $tag, $nr_tag, $isdst) = localtime(time);
		if ($mon < 10) { $mon = "0$mon"; }
		if ($tag < 10) { $tag = "0$tag"; }	  
		my $useline = 0;
		if ($firstkeyfound > 0) {
			$useline = $firstkeyfound;
		} elsif ($linenumber > 0) {
			$useline = $linenumber;
		}
	
		for (my $i=0; $i < @currentvalues; $i++) {
		 	my $doinsert = 1;
		  for (my $j=0; $j < @newvalues; $j++) {
		  	if ($newvalues[$j] eq $currentvalues[$i]) {			# if old value is still a new value do not insert as comment
		  		$doinsert = 0;
		  	}
		  }
		  if (($doinsert == 1) && ($useline > 0)) {		# insert new to existing line, if no line exists, skip insert as comment
		    splice @fcontenta, ($useline), 0, $commentchar." ".$key.$assignchars.$currentvalues[$i]."%CWF%".$mtag."-".$mon."-".($jahr+1900)."\n";  
		  }
		}
  } # if commentchar


  if (($firstkeyfound == 0) && ($linenumber == 0)) {
  	# if no active key found and no inactive key with old value, search for other line with key to find a linenumber for insert new key
		my $searchstring = '^\s*'.&addslashes($commentchar).'+\s*?'.&addslashes($key).'\s*?'.&addslashes($assignchars).'\s*(.*)';
		for (my $i=0;$i<@fcontenta;$i++) {
		  $oneline = $fcontenta[$i];
			$oneline =~ s/\t/ /g; # remove tabs
			($notinstart) && ($oneline =~ m/$notinstart/i) && ($innot++);
  	  ($notinstop) && ($oneline =~ m/$notinstop/i) && ($innot--);
  	  ($innot < 0) && ($innot = 0);
  	  ($innot > 0) && next;  # if we are in the not section skip line
			($oneline =~ m/$searchstring/i) && ($linenumber = $i);
		}
  }


	#6. insert all new key-> values at first key found, line changed or at the end
	
	my $useline = 0;
	if ($firstkeyfound > 0) {
	  $useline = $firstkeyfound;
	} elsif ($linenumber > 0) {
		$useline = $linenumber;
	}
	
	if ($useline > 0) {
	  for (my $j=0; $j < @newvalues; $j++) {
	  	if ($newvalues[$j] ne "##  ##")	{		# Value should be not set	
				my @parts = split(/%CWF%/, $newvalues[$j]);
				if (@parts == 2) {
					$newvalues[$j] = $parts[0];
				}	  
				splice @fcontenta, ($useline), 0, $key.$assignchars.$newvalues[$j]."\n";
			}
		} 
	} else {
	  for (my $j=0; $j < @newvalues; $j++) {
	    if ($newvalues[$j] ne "##  ##")	{		# Value should be not set	
				my @parts = split(/%CWF%/, $newvalues[$j]);
				if (@parts == 2) {
					$newvalues[$j] = $parts[0];
				}	  
				push (@fcontenta, "\n".$key.$assignchars.$newvalues[$j]);
			}
		}
  }

	$self->{fcontent} = \@fcontenta;        # Write data back to object
	#exit;
	return 1;
}

sub count_sections {
		my $self = shift;
		my $startcode = shift;
		my $stopcode = shift;
		if (! $startcode) {
			$self->{error} .= "- Need first argument - startcode: get_section() (pm:CWFFile[".__LINE__."], $0)";
			return -1;
		}		
		if (! $stopcode) {
			$self->{error} .= "- Need second argument - stopcode: get_section() (pm:CWFFile[".__LINE__."], $0)";
			return -1;
		}				
		
		my $insection = 0;
		my $sectionsfound = 0;
		my $fcontent = $self->{fcontent};     # Get data from object
		my @fcontenta = @$fcontent;				
		
		for (my $i=0;$i<@fcontenta;$i++) {
			my $oneline = $fcontenta[$i];
			if (($oneline =~ m/$startcode/i) && ($insection == 0)) {
				$insection = 1;
				$sectionsfound++;
				next;
			}
			if (($oneline =~ m/$stopcode/i) && ($insection == 1)) {
				$insection = 0;
				next;
			}		
		}
		
		return $sectionsfound;
}

sub get_section {
		my $self = shift;
		my $startcode = shift;
		##print $startcode;
		my $stopcode = shift;
		my $sectionnumber = shift;
		my $sectioncount = shift; # start counting by 1
		
		(! $sectionnumber) && ($sectionnumber ne "0") && ($sectionnumber = 1);
		(! $sectioncount) && ($sectioncount = 1);
		
		if (! $startcode) {
			$self->{error} .= "- Need first argument - startcode: get_section() (pm:CWFFile[".__LINE__."], $0)";
			return -1;
		}		
		if (! $stopcode) {
			$self->{error} .= "- Need second argument - stopcode: get_section() (pm:CWFFile[".__LINE__."], $0)";
			return -1;
		}		

    		my $filesections = $self->count_sections ($startcode, $stopcode);
		if (($sectionnumber > 0) && ($filesections > $sectionnumber)) {
			$self->{error} .= "- Section found to many times, should be $sectionnumber: get_section() (pm:CWFFile[".__LINE__."], $0)";
			return -1;
		}
		
		#print "FOUND: ".$filesections;

		#$startcode = addslashes($startcode);
		
		my $insection = 0;
		my $sectionsfound = 0;
		my $fcontent = $self->{fcontent};     # Get data from object
		my @fcontenta = @$fcontent;		
		my $insectioncount = 0;
		my @section;
		#print $startcode."\n";

		for (my $i=0;$i<@fcontenta;$i++) {
			my $oneline = $fcontenta[$i];
			if (($oneline =~ m/$startcode/i) && ($insection == 0)) {
				$insection = 1;
				$insectioncount = 1;
				$sectionsfound++;
				($sectionsfound == $sectioncount) && (push (@section, $oneline));
				next;
			} elsif (($oneline =~ m/$startcode/i) && ($insection == 1)) {
				$insectioncount++;
			}
			#if (($oneline =~ m/$stopcode/i) && ($insection == 0)) {
			#	$self->{error} .= "- Section end found before section start: get_section() (pm:CWFFile[".__LINE__."], $0)";
			#	return -1;
			if (($oneline =~ m/$stopcode/i) && ($insection == 1) && ($insectioncount == 1)) {
				$insection = 0;
				$insectioncount = 0;
				($sectionsfound == $sectioncount) && (push (@section, $oneline));
				next;
			} elsif (($oneline =~ m/$stopcode/i) && ($insection == 1)) {
				$insectioncount--;
			}
			
			($insection == 1) && ($sectionsfound == $sectioncount) && (push (@section, $oneline));
		}
		
		return @section;
}		


sub set_section {
		my $self = shift;
		my $startcode = shift;
		my $stopcode = shift;
		my $sectionnumber = shift; # -1 means insert new section
		my @newcontent = @_; # changed content

		my $fcontent = $self->{fcontent};     # Get data from object
		my @fcontenta = @$fcontent;	
		my $lineoldsection = 0;
		my @ncontent;
		
		(! $sectionnumber) && ($sectionnumber ne "0") && ($sectionnumber = 1);
		
		if (! $startcode) {
			$self->{error} .= "- Need first argument - startcode: set_section() (pm:CWFFile[".__LINE__."], $0)";
			return -1;
		}		
		if (! $stopcode) {
			$self->{error} .= "- Need second argument - stopcode: set_section() (pm:CWFFile[".__LINE__."], $0)";
			return -1;
		}		
		print $sectionnumber;
		if ($sectionnumber > 0) {
			my $filesections = $self->count_sections ($startcode, $stopcode);
			if (($sectionnumber > 0) && ($sectionnumber > $filesections)) {
				$self->{error} .= "- Section $sectionnumber don't exists: set_section() (pm:CWFFile[".__LINE__."], $0)";
				return -1;
			}
			
			my $insection = 0;
			my $sectionsfound = 0;
			my $insectioncount = 0;
			my $changed=0;
		
			# first remove the old section and remember the line number of that section
			for (my $i=0;$i<@fcontenta;$i++) {
				my $oneline = $fcontenta[$i];
				#print $oneline."<br>";
				if (($oneline =~ m/$startcode/i) && ($insection == 0)) {
					#print $oneline."dddd<br>";	
					$insection = 1; # 1= we are in a section / 0= we don't
					$insectioncount = 1; # count each section start tag, to match the correct section end tag
					$sectionsfound++; # total number of all found sections
					if ($sectionsfound == $sectionnumber) {
						# we are in the section wich should be substituted and we don't substitute before, we save the line number
						$lineoldsection = $i;	# remember position of the changed section
					}
				} elsif (($oneline =~ m/$startcode/i) && ($insection == 1)) {
					$insectioncount++; # count each section start tag, to match the correct section end tag
				}	

				if (($oneline =~ m/$stopcode/i) && ($insection == 1) && ($insectioncount == 1)) {
					$insection = 0;
					$insectioncount = 0;
					if ($sectionsfound != $sectionnumber) {
						push (@ncontent, $oneline)
					}
					next;
				} elsif (($oneline =~ m/$stopcode/i) && ($insection == 1)) {
					$insectioncount--;
				}
				
				(($insection == 0) || ($sectionsfound != $sectionnumber)) && (push (@ncontent, $oneline)); # if we're not in the searched section, save the line
			}
			if ($lineoldsection == 0) {
				$self->{error} .= "- Old section not found: set_section() (pm:CWFFile[".__LINE__."], $0)";
				return -1;
			}
		} else {
			# add new section
			@ncontent = @fcontenta;
			$lineoldsection = (@ncontent);
			
		}
		# 2. insert the new section (position is in $lineoldsection)
		
 		for (my $i=0;$i<@newcontent;$i++) {
			my $oneline = $newcontent[$i];
			splice @ncontent, ($lineoldsection+$i), 0, $oneline."\n";  
		}
		
		$self->{fcontent} = \@ncontent;        # Write data back to object
		return 1;
}		

sub save_file {
    my $self = shift;

    if ((! $self->{cfile}) || (! $self->{fcontent})) {
	$self->{error} .= "- File not loaded use load_file first Method: save_file() (pm:CWFFile[".__LINE__."], $0)";
	return -1;
    }

    (open(CONFFILE, ">".$self->{cfile})) || (($self->{error} .= "- Can\'t open file for writing") && (return -1));
    flock(CONFFILE, 2); # Lock File exclusive
   
    my $fcontent = $self->{fcontent};
    my @fcontenta = @$fcontent;
    my $oneline;

    foreach $oneline (@fcontenta) {
	#print $oneline;
	print CONFFILE $oneline;
    }
    close(CONFFILE);
}


##############################################################################################
sub is_error {
	my $self = shift;
	($self->{error}) && return 1;
	return 0;
}

##############################################################################################
sub get_error_msg {
	my $self = shift;
	my $msg = $self->{error};
	undef ($self->{error});
	return ($msg);
}

##############################################################################################
sub is_warning {
	my $self = shift;
	($self->{warning}) && return 1;
	return 0;
}

##############################################################################################
sub get_warning {
	my $self = shift;
	if ($self->{warning}) { 
		return $self->{warning};
	} else {
		return 0;
	}
}



##############################################################################################



sub addslashes {
  my $text = shift;
  $text =~ s/\\/\\\\/g;
  $text =~ s/\"/\\"/g;
  $text =~ s/\'/\\'\;/g;
  $text =~ s/\(/\\(/g;
  $text =~ s/\)/\\(/g;
  $text =~ s/\./\\./g;
  $text =~ s/\+/\\+/g;
  $text =~ s/\*/\\*/g;
  $text =~ s/\[/\\[/g;
  $text =~ s/\]/\\]/g;
  $text =~ s/\{/\\{/g;
  $text =~ s/\}/\\}/g;
  $text =~ s/\?/\\?/g;
  $text =~ s/\$/\\\$/g;
  $text =~ s/\^/\\\^/g;
  $text =~ s/\#/\\\#/g;
  return $text;
}

1;







