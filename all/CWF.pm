package CWF;

use XML::Parser;
#use XML::Checker::Parser;
use strict;
use Data::Dumper;

####################################################################################
# FUNCTION INDEX:					
# new
# validate_xml_file
# new_xml_parser
# start_xml_parser
# is_defined_tag
# count_tag_appearance
# get_tag_content
# get_tag_content_with_attribut
# get_tag_content_with_two_attributs
# get_tag_attributs
# get_tag_attribut_value
# get_tag_attribut_value_with_attribut_value
# get_next_step
# get_next_subset_step
# get_previous_step
# count_steps
# get_sectionnr_by_stepid
# get_nr_steps
# get_nr_steps_with_skill
# get_nr_steps_with_group
# get_next_exec
#
# is_error
# get_error_msg
# is_warning
# get_warning

sub new {
	############################################################################
	# Parameter:
	#	1=XML-File
	#	2=Mode (1=Shell / 2=CGI / 3=Webmin (def))
	############################################################################
        my $pkg = shift;
	my $xmlfile = shift;								# First parameter filepath + name of xml file
	my $usemode = shift;								# 0=Shell / 1=CGI / 2=Webmin
	my $self = {};									# Start object

	if (! $xmlfile) {
		$self->{error}	= "- Parameter 1 XML-filename is needed by object (pm:CWF[".__LINE__."], $0)";
		$self->{xmlfile} = "";
	} elsif (! -f $xmlfile) {							# check if xml file exists
		$self->{error}	= "- XML-file ($xmlfile) do not exist (pm:CWF[".__LINE__."], $0)";
		$self->{xmlfile} = "";
	} else {									# xmlfile is defined and exists
		$self->{error};
		$self->{xmlfile} = $xmlfile;
	}
	
	$self->{warning} = "";	

	if (($usemode > 0) && ($usemode < 4)) { $self->{usemode} = $usemode; }		# check and set usemode
	else { 
		$self->{usemode} = 3; 							# usemode is default
		$self->{warning} = "- Usemode not set in constructor using default 3 (webmin) (pm:CWF[".__LINE__."], $0)";
	}						

	if ($self->{usemode} == 1) { 
		$self->{nl} = "\n";
	} else {	
		$self->{nl} = "<br>";
	}
	bless $self, $pkg;								# object meets world
	return $self;
}

##############################################################################################
sub validate_xml_file {
	my $self = shift;

	sub my_fail {
    		my $code = shift;
		my $error;
    		print XML::Checker::error_string ($code, @_) if $code < 200;
    		XML::Checker::print_error ($code, @_);
	}

	sub handle_final {
	    return 1;
	}


	my $xp = new XML::Checker::Parser ( ErrorContext => 5 );
	$xp->setHandlers (Final => \&handle_final);
	eval {
  		local $XML::Checker::FAIL = \&my_fail;
  		if ($xp->parsefile($self->{xmlfile}) != 1) { 
		    $self->{error} .= "- XML-file (".$self->{xmlfile}.") is not a valid xml-file (pm:CWF[".__LINE__."], $0)".$self->{nl}; 
		    return 0;
		}
	};

	if ($@) {
		my $mess = $@;
		$self->{error} .= "- XML-file (".$self->{xmlfile}.") is not a valid xml-file (pm:CWF[".__LINE__."], $0)".$self->{nl}."  XML-Error Message: $mess ";
  		return 0;
	}
	return 1;
}

##############################################################################################
sub new_xml_parser {
	my $self = shift;
	my $p1 = new XML::Parser (ErrorContext => 5);
	$p1->setHandlers (Start => \&handle_start, 
			  End => \&handle_stop, 
			  Default => \&handle_default,
			  Comment => \&handle_comment);
	$self->{xmlparser} = $p1;
	return 1;
}

##############################################################################################
sub start_xml_parser {
    my $self = shift;
	my %sectionnr = ("STEP",0,"HEADER",0,"CLEANUP",0);
	my $actualsection;                                                              # which section we're in
	my $lasttag = "";                                                               # is needed to define the content of a tag
	my $lasttagnr = 0;                                                              # is needed to define the content of a tag

	#####################
	sub handle_start () {								# handler for tag start event from xml-parser
	    my $p = shift; 								# Pointer
	    my $tagname = shift; 							# Tag Name
	    use vars qw($self %sectionnr $actualsection $lasttag $lasttagnr);
	    my $val;
	    my $section;
	    my $i;
	    $lasttag = $tagname;

	    ###### Datenstruktur Anmerkung:
	    # $self -> ist das CWF Objekt mit Hilfe von use vars in diesem Handler verfügbar
	    # {tags} -> Ist ein Hash, der als Keys ein Array von Tagnamen hat.
            # {$tagname} erzeugt also einen Hash Eintrag mit dem Namen des aktuellen Tags
            # da Tags mehrmals vorkommen können, ist dies ein Array. 

	    if (($tagname eq "STEP") || ($tagname eq "HEADER") || ($tagname eq "CLEANUP")) {
			$actualsection = $tagname;
			$sectionnr{$tagname}++;
	    }
	    if ($actualsection) {
			$i = 0;
			while (defined($self->{$actualsection}[$sectionnr{$actualsection}]{$tagname}[$i])) {
			   $i++;
			}

			# Key und Werte des XML-Tags einlesen
			while (my $key = shift) {
			    $val = shift;
			    $self->{$actualsection}[$sectionnr{$actualsection}]{$tagname}[$i]{$key} = $val;
			}
	    }
	    $lasttagnr = $i;
	    return 1;
	}

    #######################
    sub handle_default () {
	    my $p = shift;
	    my $somethin = shift;
	    use vars qw($self $lasttag $actualsection %sectionnr $lasttagnr);
	    if ($somethin eq "\n") { return 1;  }
	    if ($lasttag && $actualsection && ($sectionnr{$actualsection} >0)) {
			$self->{$actualsection}[$sectionnr{$actualsection}]{$lasttag}[$lasttagnr]{"tagcontent"} .= $somethin;
			#print $actualsection ." -> ".$lasttag." -> ".$lasttagnr." -> ".$somethin."\n";
	    } else {
			#$self->{error} .= "- XML-file (".$self->{xmlfile}.") found content that should not be there [\"$somethin\"] (pm:CWF[".__LINE__."], $0)".$self->{nl}; 
	    }
	    return 1;
	}

    #######################
	sub handle_comment () {
	    # This handler only to skips comments
	    # my $p = shift;
	    # my $comment = shift;
	    return 1;
	}

    #######################
	sub handle_stop () {								# handler for tag end event from xml-parser
	    my $p = shift; 								# Pointer
	    my $tagname = shift; 							# Tag Name
	    use vars qw ($lasttag $actualsection);
	    if (($tagname eq "HEADER") || ($tagname eq "STEP") || ($tagname eq "CLEANUP")) {
			$actualsection = "";
	    }
	    $lasttag = "";
	    return 1;
	}


	$self->{xmlparser}->parsefile ($self->{xmlfile});
	return 1;
}


##############################################################################################
sub is_defined_tag {
	my $self = shift;
	my $section = shift;                                                           # Should be HEADER, STEP or CLEANUP
        my $tagname = shift;                                                           # Tagname to find
        my $nr = shift;                                                                # nr of step, should be always 1 for HEADER and CLEANUP

        (! $section) && ($self->{error} .= "- Need first argument \$section. Method: is_defined_tag() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $tagname) && ($self->{error} .= "- Need second argument \$tagname. Method: is_defined_tag() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $nr) && ($self->{warning} .= "- Missing number, using step number 1 (pm:CWF[".__LINE__."], $0)".$self->{nl}) && ($nr = 1);
	if (($section eq "STEP") || ($section eq "HEADER") || ($section eq "CLEANUP")) {
	    if (! $self->{$section}[$nr]{$tagname}) {
			return 0;
	    } else {
			return 1;
	    }
    }
	return 0;
}


###############################################################################################
sub count_tag_appearance {
        # Liefert die Anzahl, wie oft das tag in der angegebenen section vorkommt.
	my $self = shift;
	my $section = shift;                                                           # Should be HEADER, STEP or CLEANUP
        my $tagname = shift;                                                           # Tagname to find
        my $nr = shift;                                                                # nr of step, should be always 1 for HEADER and CLEANUP

        (! $section) && ($self->{error} .= "- Need first argument \$section. Method: count_tag_appearance() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $tagname) && ($self->{error} .= "- Need second argument \$tagname. Method: count_tag_appearance() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $nr) && ($self->{warning} .= "- Missing number, using number 1 (pm:CWF[".__LINE__."], $0)".$self->{nl}) && ($nr = 1);
    	if ($self->is_defined_tag($section,$tagname,$nr)) {
		my $i = 0;
		while (defined($self->{$section}[$nr]{$tagname}[$i])) {
		    $i++;
		}
		return $i;
        }
	return 0;
}


###############################################################################################
sub count_section_appearence {
        # Returns number of apperance of given section in current XML-file
	my $self = shift;
	my $section = shift;                                                           # Should be HEADER, STEP or CLEANUP

        (! $section) && ($self->{error} .= "- Need first argument \$section. Method: is_defined_tag() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);

	
	my $i=1;
	if (! defined($self->{$section}[$i])) {
		return 0;				                               # Section is not defined
	}
	while (defined($self->{$section}[$i])) {
		$i++;
	}
	return --$i;
}


##############################################################################################
sub get_tag_content {
	# Returns content of a tag (0 if tag does'nt exists, -1 if tag empty)
	my $self = shift;
   	my $section = shift;
	my $tagname = shift;
        my $sectionnr = shift;
	my $tagnr = shift;

        (! $section) && ($self->{error} .= "- Need first argument \$section. Method: get_tag_content() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $tagname) && ($self->{error} .= "- Need second argument \$tagname. Method: (get_tag_content) (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $sectionnr) && ($self->{warning} .= "- Missing section number, using number 1 (pm:CWF[".__LINE__."], $0)".$self->{nl}) && ($sectionnr = 1);
        (! $tagnr) && ($self->{warning} .= "- Missing tag number, using number 0 (pm:CWF[".__LINE__."], $0)".$self->{nl}) && ($tagnr = 0);	

	if ($self->is_defined_tag ($section, $tagname, $sectionnr)) {
		my $tagcontent = $self->{$section}[$sectionnr]{$tagname}[$tagnr]{'tagcontent'};
		#print "$section -> $sectionnr -> $tagname -> $tagnr ";
		#print $self->{$section}[$sectionnr]{$tagname}[$tagnr]{"tagcontent"};
		(defined ($tagcontent)) && return $tagcontent;
		return -1;
	} else {
		return -2;
	}
}

##############################################################################################
sub get_tag_content_with_attribut {
	# Returns content of a tag with have a valid pair of attribut and attribut value (-1 if tag does'nt exists, -2 if no tag was found with the given attribut and value)
	my $self = shift;
  my $section = shift;
	my $tagname = shift;
	my $attribut = shift;
	my $attributvalue = shift;
  my $sectionnr = shift;
	#print $attribut."->".$attributvalue;

  (! $section) && ($self->{error} 	.= "- Need first argument \$section. Method: is_defined_tag() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
  (! $tagname) && ($self->{error} 	.= "- Need second argument \$tagname. Method: is_defined_tag() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
  (! $attribut) && ($self->{error} 	.= "- Need third argument \$attribut. Method: get_tag_content_with_attribut() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
  (! $attributvalue) && ($self->{error} 	.= "- Need fourth argument \$attributvalue. Method: get_tag_content_with_attribut() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
  (! $sectionnr) && ($self->{warning} 	.= "- Missing section number, using number 1 (pm:CWF[".__LINE__."], $0)".$self->{nl}) && ($sectionnr = 1);

	if ($self->is_defined_tag ($section, $tagname, $sectionnr)) {
		my $i;
		my $tagcontent;
		for ($i=0;$i<$self->count_tag_appearance($section,$tagname,$sectionnr);$i++) {
			#print $self->get_tag_attribut_value($section,$tagname,$attribut,$sectionnr,$i).$self->{nl};
			if ($self->get_tag_attribut_value($section,$tagname,$attribut,$sectionnr,$i) eq $attributvalue) {
				if (exists($self->{$section}[$sectionnr]{$tagname}[$i]{"tagcontent"})) {
					$tagcontent = $self->{$section}[$sectionnr]{$tagname}[$i]{"tagcontent"};
				} else {
					return -2;
				}
			}
		}
		(defined ($tagcontent)) && return $tagcontent;
		return -2;
	} else {
		return -1;
	}
}


##############################################################################################
sub get_tag_content_with_two_attributs {
	# Returns content of a tag with have a valid pair of attribut and attribut value (0 if tag does'nt exists, -1 if no tag was find with the given attribut and value)
	my $self = shift;
   	my $section = shift;
	my $tagname = shift;
	my $attribut = shift;
	my $attributvalue = shift;
	my $attribut2 = shift;
	my $attributvalue2 = shift;
        my $sectionnr = shift;

        (! $section) && ($self->{error} 	.= "- Need first argument \$section. Method: get_tag_content_with_two_attributs() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $tagname) && ($self->{error} 	.= "- Need second argument \$tagname. Method: get_tag_content_with_two_attributs() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $attribut) && ($self->{error} 	.= "- Need third argument \$attribut. Method: get_tag_content_with_two_attributs() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $attributvalue) && ($self->{error} 	.= "- Need fourth argument \$attributvalue. Method: get_tag_content_with_two_attributs() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $sectionnr) && ($self->{warning} 	.= "- Missing section number, using number 1 (pm:CWF[".__LINE__."], $0)".$self->{nl}) && ($sectionnr = 1);

	if ($self->is_defined_tag ($section, $tagname, $sectionnr)) {
		my $i;
		my $tagcontent;
		for ($i=0;$i<$self->count_tag_appearance($section,$tagname,$sectionnr);$i++) {
			#print $self->get_tag_attribut_value($section,$tagname,$attribut2,$sectionnr,$i)."=".$attributvalue2;
			if (($self->get_tag_attribut_value($section,$tagname,$attribut,$sectionnr,$i) eq $attributvalue) && ($self->get_tag_attribut_value($section,$tagname,$attribut2,$sectionnr,$i) eq $attributvalue2)) {
				$tagcontent = $self->{$section}[$sectionnr]{$tagname}[$i]{"tagcontent"};
			}
		}
		(defined ($tagcontent)) && return $tagcontent;
		return -1;
	} else {
		return -2;
	}
}



##############################################################################################
sub get_tag_attributs {
	# Returns array of attributs of this tag
	my $self = shift;
   	my $section = shift;
	my $tagname = shift;
        my $sectionnr = shift;
	my $tagnr = shift;

        (! $section) && ($self->{error} .= "- Need first argument \$section. Method: is_defined_tag() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $tagname) && ($self->{error} .= "- Need second argument \$tagname. Method: is_defined_tag() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $sectionnr) && ($self->{warning} .= "- Missing section number, using number 1 (pm:CWF[".__LINE__."], $0)".$self->{nl}) && ($sectionnr = 1);
        (! $tagnr) && ($self->{warning} .= "- Missing tag number, using number 0 (pm:CWF[".__LINE__."], $0)".$self->{nl}) && ($tagnr = 0);	
	print Dumper($self);
	if ($self->is_defined_tag ($section, $tagname, $sectionnr)) {
		print "\$self->{$section}[$sectionnr]{$tagname}[$tagnr]{kind}\n";
		if (defined($self->{$section}[$sectionnr]{$tagname}[$tagnr])) {
			my $mhash = $self->{$section}[$sectionnr]{$tagname}[$tagnr];				# Anonymer HASH!
			my %rhash = %$mhash;									# give him a name
			foreach my $key (keys(%rhash)) {							# print keys
				print $key."\n";
			}
			#print Dumper(%rhash);
			#print $mhash{kind}."::";
		}
	} else {
		return 0;
	}
}        

##############################################################################################
sub get_tag_attribut_value {
	# Returns value of the given attribut, indentified by section, tag, attribut names... or -1 if tag is not found 
	my $self = shift;
   	my $section = shift;
	my $tagname = shift;
	my $attribut = shift;
        my $sectionnr = shift;											# should always be 1 for HEADER or CLEANUP
	my $tagnr = shift;

        (! $section) && ($self->{error} .= "- Need first argument \$section. Method: get_tag_attribut_value() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $tagname) && ($self->{error} .= "- Need second argument \$tagname. Method: get_tag_attribut_value() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $attribut) && ($self->{error} .= "- Need third argument \$attribut. Method: get_tag_attribut_value() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
        (! $sectionnr) && ($self->{warning} .= "- Missing section number, using number 1 (pm:CWF[".__LINE__."], $0)".$self->{nl}) && ($sectionnr = 1);
        (! $tagnr) && ($self->{warning} .= "- Missing tag number, using number 0 (pm:CWF[".__LINE__."], $0)".$self->{nl}) && ($tagnr = 0);	
	if ($self->is_defined_tag ($section, $tagname, $sectionnr)) {
	  if (defined($self->{$section}[$sectionnr]{$tagname}[$tagnr])) {
	    if (defined($self->{$section}[$sectionnr]{$tagname}[$tagnr]{$attribut})) {
	      return $self->{$section}[$sectionnr]{$tagname}[$tagnr]{$attribut};
	    } 
	  } 
	} #else { print "TAG NOT DEF"; }
	return -1;
}        

##############################################################################################
sub get_tag_attribut_values_with_attribut_value {
	# Returns value of the given attribut, indentified by section, tag, attribut names... or -1 if tag is not found 
	my $self = shift;
   	my $section = shift;
	my $tagname = shift;
	my $attribut = shift;
	my $wattribut = shift;
	my $wattributv = shift;
	my $sectionnr = shift;		
	# should always be 1 for HEADER or CLEANUP

	(! $sectionnr) && ($sectionnr = 1);

	(! $section) && ($self->{error} 	.= "- Need first argument \$section. Method: get_tag_attribut_value_with_attribut_value() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
	(! $tagname) && ($self->{error} 	.= "- Need second argument \$tagname. Method: get_tag_attribut_value_with_attribut_value() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
	(! $attribut) && ($self->{error} 	.= "- Need third argument \$attribut. Method: get_tag_attribut_value_with_attribut_value() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);
	(! $wattribut) && ($self->{error} 	.= "- Need fourth argument \$wattribut. Method: get_tag_attribut_value_with_attribut_value() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);        
	(! $wattributv) && ($self->{error} 	.= "- Need fifth argument \$wattributv. Method: get_tag_attribut_value_with_attribut_value() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);        
        (! $sectionnr) && ($self->{warning} 	.= "- Missing section number, using number 1 (pm:CWF[".__LINE__."], $0)".$self->{nl}) && ($sectionnr = 1);
        
        my @resultarray;
	if ($self->is_defined_tag ($section, $tagname, $sectionnr)) {
		my $i;
		my $tagcontent;
		for ($i=0;$i<$self->count_tag_appearance($section,$tagname,$sectionnr);$i++) {
			#print $self->get_tag_attribut_value($section,$tagname,$attribut,$sectionnr,$i).$self->{nl};
			if ($self->get_tag_attribut_value($section,$tagname,$wattribut,$sectionnr,$i) eq $wattributv) {
				if (defined($self->{$section}[$sectionnr]{$tagname}[$i]{$attribut})) {
					push (@resultarray,$self->{$section}[$sectionnr]{$tagname}[$i]{$attribut});
				} 
				#else {
				#	return -2;
				#}
			}
		}
	} 
	
	if (@resultarray > 0) {
		print @resultarray;
		print "--------------";
		return @resultarray;
	} else {
		return -1;
	}
}        


###############################################################################################
sub get_next_step {
        # Returns id of next step
	my $self = shift;
	my $nr = shift;                                                           				# find next step after this
	my $skill = shift;											# which skill should the next step have? 0 or blank if any
  	my $group = shift;											# which group should the next step have? 0 or blank if any

	(! $nr) && ($nr = 0);
	(! $skill) && ($skill = 0);
	(! $group) && ($group = 0);

	#print "GROUP: ".$group."<br>";
	#print "SKILL: ".$skill."<br>";


	my $next = 0;
	my $nextid = 0;
	my $i=1;
	if (! defined($self->{'STEP'}[$i])) {
		return 0;				                               				# Section is not defined
	}
	while (defined($self->{'STEP'}[$i]{'STEP'}[0])) {							# as long as there is another step
		my $sid = $self->{'STEP'}[$i]{'STEP'}[0]{'id'};
		my $sskill = $self->{'STEP'}[$i]{'STEP'}[0]{'skill'};
		my $sgroup = $self->{'STEP'}[$i]{'STEP'}[0]{'group'};

		(! $sid) && ($sid = 0);
		(! $sskill) && ($sskill = 0);
		(! $sgroup) && ($sgroup = 0);

		#print $i."--";
                if (($sid > $nr) && ($sid < $next) && ($next > 0)) {						# is a step given and the next greater?
			if (  ((($skill > 0) && ($skill == $sskill)) || ($skill==0)) && 
 			      ((($group > 0) && ($group == $sgroup)) || ($group==0))     ) {	# is a skill and a group given and do they match?
				$next = $sid;
				$nextid = $i;
				#print "x";
			} 	
		}
		elsif (($sid > $nr) && ($next == 0)) {
			if (  ((($skill > 0) && ($skill == $sskill)) || ($skill==0)) && 
 			      ((($group > 0) && ($group == $sgroup)) || ($group==0))     ) {	# is a skill and a group given and do they match?
				#print "-->".$sid."<---";
				$next = $sid;
				$nextid = $i;
				#print "y";
			} 	
		}
		$i++;
	}
	return $nextid;												# returns array id not the real step id!
}

###############################################################################################
sub get_next_subset_step {
    # Returns id of next step which is part of the give subset 
	my $self = shift;
	my $nr = shift;                                             # find next step after this
	my $subsetid = shift;										# from which subset?

	(! $nr) && ($nr = 0);

	(! ($subsetid > 0)) && ($self->{error} 	.= "- Need second argument \$subsetid. Method: get_next_subset_step() (pm:CWF[".__LINE__."], $0)".$self->{nl}) && (return 0);

	my $next = 0;
	my $nextid = 0;
	my $i=1;
	if (! defined($self->{'STEP'}[$i])) {
		return 0;				                               	# Section is not defined
	}
	while (defined($self->{'STEP'}[$i]{'STEP'}[0])) {			# as long as there is another step
		my $sid = $self->{'STEP'}[$i]{'STEP'}[0]{'id'};
		my $ssubsetid = $self->{'STEP'}[$i]{'STEP'}[0]{'subsetid'};

		(! $sid) && ($sid = 0);
		(! $ssubsetid) && ($ssubsetid = 0);
        if (($sid > $nr) && ($sid < $next) && ($next > 0)) {	# is a step given and the next greater?
			if ($subsetid == $ssubsetid) {						# is a skill and a group given and do they match?
				$next = $sid;
				$nextid = $i;
			} 	
		}
		elsif (($sid > $nr) && ($next == 0)) {
			if ($subsetid == $ssubsetid) {	# is a skill and a group given and do they match?
				$next = $sid;
				$nextid = $i;
			} 	
		}
		$i++;
	}
	return $nextid;												# returns array id not the real step id!
}


###############################################################################################
sub get_previous_step {
        # Returns id of previous step
	my $self = shift;
	my $nr = shift;                                                           				# find next step after this
	my $skill = shift;											# which skill should the next step have? 0 or blank if any
        my $group = shift;											# which group should the next step have? 0 or blank if any

	(! $nr) && ($nr = 0);
	(! $skill) && ($skill = 0);
	(! $group) && ($group = 0);

	#print "GROUP: ".$group."<br>";
	#print "SKILL: ".$skill."<br>";
	#print "Nr: ".$nr."<br>";	


	my $last = 0;
	my $lastid = 0;
	my $i=1;
	if (! defined($self->{'STEP'}[$i])) {
		return -1;				                               				# Section is not defined
	}
	while (defined($self->{'STEP'}[$i]{'STEP'}[0])) {							# as long as there is another step
		my $sid = $self->{'STEP'}[$i]{'STEP'}[0]{'id'};
		my $sskill = $self->{'STEP'}[$i]{'STEP'}[0]{'skill'};
		my $sgroup = $self->{'STEP'}[$i]{'STEP'}[0]{'group'};

		(! $sid) && ($sid = 0);
		(! $sskill) && ($sskill = 0);
		(! $sgroup) && ($sgroup = 0);

		#print "Sid: ".$sid." Nr: $nr Last: $last SSkill = $sskill<br>";
                if (($sid < $nr) && ($sid > $last) && ($sid > 0)) {						# is a step given and the next greater?
			if (  ((($skill > 0) && ($skill == $sskill)) || ($skill==0)) && 
 			      ((($group > 0) && ($group == $sgroup)) || ($group==0))     ) {	# is a skill and a group given and do they match?
				$last = $sid;
				$lastid = $i;
				#print "x";
			} 	
			#print "x";
		}
		elsif ($nr == 0) {
			return -1;
		}
		$i++;
	}
	return $lastid;												# returns array id not the real step id!
}


###############################################################################################
sub get_sectionnr_by_stepid {
        # Returns array id of next step
	my $self = shift;
	my $stepid = shift;                                                           				# find section nr from step with given id

	my $i=1;
	if (! defined($self->{'STEP'}[$i])) {
		return -1;				                               				# Section is not defined
	}
	while (defined($self->{'STEP'}[$i]{'STEP'}[0])) {							# as long as there is another step
		my $sid = $self->{'STEP'}[$i]{'STEP'}[0]{'id'};
		#print $sid."-";
		($sid == $stepid) && (return $i);
		$i++;
	}
	return -2;												# returns array id not the real step id!
}

###############################################################################################
sub count_steps {
       # Returns number of steps 
	my $self = shift;
	my $i = 1;
	while (defined($self->{'STEP'}[$i]{'STEP'}[0])) {							# as long as there is another step
		$i++;
	}
	return ($i-1);
}

###############################################################################################
sub get_nr_steps_with_skill {
       # Returns number of steps with given Skill ID
	my $self = shift;
	my $skillid = shift;                                                           				# count steps with these skill id
	my $counter = 0;
	my $i = 1;
	while (defined($self->{'STEP'}[$i]{'STEP'}[0])) {							# as long as there is another step
		($self->{'STEP'}[$i]{'STEP'}[0]{'skill'} == $skillid) && ($counter++);
		$i++;
	}
	return $counter;
}

###############################################################################################
sub get_nr_steps_with_group {
       # Returns number of steps with given group ID
	my $self = shift;
	my $groupid = shift;                                                           				# count steps with these group id
	my $counter = 0;
	my $i = 1;
	while (defined($self->{'STEP'}[$i]{'STEP'}[0])) {							# as long as there is another step
		($self->{'STEP'}[$i]{'STEP'}[0]{'group'} == $groupid) && ($counter++);
		$i++;
	}
	return $counter;
}


###############################################################################################
sub get_next_exec {
        # Returns id of next step
	my $self = shift;
	my $nr = shift;                                                           				# find next step after this

	(! $nr) && ($nr = 0);

	my $next = 0;
	my $i=0;
	if (! defined($self->{'CLEANUP'}[1]{'EXECUTE'}[$i])) {
		return 0;				                               				# Section is not defined
	}
	while (defined($self->{'CLEANUP'}[1]{'EXECUTE'}[$i])) {							# as long as there is another step
		my $sid = $self->{'CLEANUP'}[1]{'EXECUTE'}[$i]{'id'};
		(! $sid) && ($sid = 0);

                if ((($sid > $nr) && ($sid < $next) && ($next > 0)) || (($sid > $nr) && ($next == 0))){						# is a step given and the next greater?
			$next = $sid;
			#print "x";
		}
		$i++;
	}
	return $next;												# returns array id not the real step id!
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
	return ($self->{error});
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


1;






