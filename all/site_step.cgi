#!/usr/bin/perl

## TODO: set_section 2. section nicht changable (CWFFile.pm)
## Theorie: Untersuchen, ob andere Tools die Konfigfile immer vollständig generieren oder auch modifizieren

use CWF;
use CWFFile;
use File::Copy cp;
use strict;
use CGI;

our %cookies;
our $usemode;
our $lang;									 # CWF language
our $CGIO = new CGI;                                                             # initial cgi object
our $userlevel;									 # screen user level
our $URLADD = "";								 # used if no cookies available
our $SELFNAME;
our $sessionid;		
our %SESSION;
our $table_header;								  
our $table_body;	 							 
our $table_body2;	 							 
our $table_body3;	 			

my $debug_level = 1;								 # 0 = Keine Error oder Warnungen ausgeben / 1 = Direkt ausgeben
our $nl;                                                                         # Zeilenumbruch
our $CWFO;
our $stepnr = 0;
our $stepid;

do "part_config.pl" || die "Error $@";
do 'translate.pl'   || die "Error in ";                                          # include function translate

our $sectionid = 0;
my $goindex = 0;
my $S_validation;
my $S_quote;
my $S_number;

#print $^O;

if (length($SESSION{'WFILE'}) < 2) {
	print '<meta http-equiv="refresh" content="0; URL=index.cgi?1=1'.$URLADD.'">';
	exit;
}
if (length($SESSION{'WCONFFILE'}) < 2) {
	print '<meta http-equiv="refresh" content="0; URL=site_startwizard.cgi?1=1'.$URLADD.'">';
	exit;
}

if (! ($SESSION{'WSTEPID'})) {							 # No step id given, try to find the first step, with give group and skill id
	my $skillid = 0;
	my $groupid = 0;
	($SESSION{'WGROUPID'} > 0) && ( $groupid = $SESSION{'WGROUPID'});
 	($SESSION{'WSKILLID'} > 0) && ( $skillid = $SESSION{'WSKILLID'});
 	#print "-----------------------".$SESSION{'WGROUPID'};
	$sectionid = $CWFO->get_next_step (0,$skillid,$groupid);
	($sectionid > 0) && ($SESSION{'WSTEPID'} = $CWFO->get_tag_attribut_value ("STEP","STEP","id",$sectionid));

} else {	
	# Step Id wich should be shown is given   		
	$sectionid = $CWFO->get_sectionnr_by_stepid ($SESSION{'WSTEPID'});
	($sectionid > 0) && ($SESSION{'WSTEPID'} = $CWFO->get_tag_attribut_value ("STEP","STEP","id",$sectionid));
}


if (! $SESSION{'WSTEPID'}) {
	# no step id given and no step id found with given skill and group trying to find at least the first step over all
	$sectionid = $CWFO->get_next_step (0);
	($sectionid > 0) && ($SESSION{'WSTEPID'} = $CWFO->get_tag_attribut_value ("STEP","STEP","id",$sectionid));
}

#Get CONF Type
my $S_conftype = $CWFO->get_tag_attribut_value ('STEP','TYPE','kind',$sectionid,0);

## Looking for standard assignment chars
my $W_assignchar = $CWFO->get_tag_content('HEADER','VALASSIGN',0);
($W_assignchar < 0) && ($W_assignchar = "=");

my $W_commentchar = $CWFO->get_tag_content('HEADER','COMMENTCHAR',0);


our $saveerror; # Error messages -> abort
our $msg;       # Other messages

my @finputtmp = $CGIO->param('finputtmp');
my @finput    = $CGIO->param('finput');

$S_validation = $CWFO->get_tag_attribut_value ('STEP','TYPE','validation',$sectionid,0);

my $S_canempty = $CWFO->get_tag_attribut_value ('STEP','TYPE','canempty',$sectionid,0);
($S_canempty < 0) && ($S_canempty = "0");

$S_quote =  $CWFO->get_tag_attribut_value ('STEP','TYPE','quote',$sectionid,0);


if ($CGIO->param('doexec') == 1) {
	####################################################
	# EXEC CONFIGURATION TOOL ##############
	####################################################

	my $runstring = $CWFO->get_tag_content('STEP','EXEC',$sectionid);

  for (my $i=0; $i<@finput; $i++) {
 		my $value = $finput[$i];  # real value, if quote is used, then find value without quotes

    $value =~ s/^\s+//; # Remove leading spaces
    $value =~ s/\s+$//; # Remove spaces from the end

    ## Handle empty value
    if (($S_canempty != 1) && ($value eq ""))  {
	    # Value must be defined but is not
			$saveerror .= "- ".&translate("Bitte geben Sie einen Wert an",$lang)." (".($i+1).".)".$nl;
    }
	
    ## Looking for quotations
    if (($S_quote) && ($S_quote != -1)) {
	  	## the input should be quoted
	    if ($value ne "") {
	    	my $searchstring = '^\s*\\'.$S_quote.'\s*(.*)'.$S_quote.'\s*';
	      if (! ($value =~ m/$searchstring/i)) {
		    	# input is not correct quoted
	        $saveerror .= "- ".&translate("Der Wert muss innerhalb bestimmter Zeichen stehen. Beispiel",$lang).": ".$S_quote.&translate("Wert",$lang).$S_quote.$nl;
		    } else {
		     	$value = $1;
		    }
		  }	
	  }
	
		## Look for input validation rulez
		if (($S_validation) && ($S_validation != -1)) {
			if (uc($S_validation) eq "EXISTPATH") { 
				# Input must be an existing path
				(substr($value,0,1) ne "/") && ($saveerror .= "- ".&translate("Der Pfad muss absolut angegeben werden (beginnend mit /)",$lang).$nl);
				(! -d $value)  && ($saveerror .= "- ".&translate("Das angegeben Verzeichnis existiert nicht",$lang).$nl);
			} #elsif (uc($S_validation) eq "PATH") {
			# Input must be in path form
			#(substr($value,0,1) ne "/") && ($saveerror .= "- ".&translate("Der Pfad muss absolut angegeben werden (beginnend mit /)",$lang).$nl);
	
			elsif (uc($S_validation) eq "EXISTFILE") {
				# Input must be an existing file
				(substr($value,0,1) ne "/") && ($saveerror .= "- ".&translate("Die Datei muss im absoluten Format angegeben werden (beginnend mit /)",$lang).$nl);
				(! -f $value)  && ($saveerror .= "- ".&translate("Die angegebene Datei existiert nicht",$lang)."...".$nl);
			} 
	
			#elsif (uc($S_validation) eq "FILE") {
			# Input must be in absolute file name form
			#(substr($value,0,1) ne "/") && ($saveerror .= "- ".&translate("Die Datei muss im absoluten Format angegeben werden (beginnend mit /)",$lang).$nl);
	
			elsif (uc($S_validation) eq "LETTERS") {
				# Input must be only letters
				my $searchstring = '^[a-zA-ZäöüÄÖÜß]+$';
				(! ($value =~ m/$searchstring/i)) && ($saveerror .= "- ".&translate("Die Eingabe darf nur aus Buchstaben bestehen",$lang).$nl);
			} 
	
			elsif (uc($S_validation) eq "NUMBERS") {
				# Input must be only numbers
				my $searchstring = '^\d+$';
				(! ($value =~ m/$searchstring/i)) && ($saveerror .= "- ".&translate("Die Eingabe darf nur aus Ziffern bestehen",$lang).$nl);
			} 
			elsif (uc($S_validation) eq "NUMLETTERS") {
				# Input must be numbers and/or letters
				my $searchstring = '^\w+$';
				(! ($value =~ m/$searchstring/i)) && ($saveerror .= "- ".&translate("Die Eingabe darf nur aus Ziffern, Buchstaben oder Unterstrichen bestehen",$lang).$nl);
			}           
	
			elsif (uc($S_validation) eq "IP") {
				# Input must be in ip format
				my $searchstring = '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$';
				(! ($value =~ m/$searchstring/i)) && ($saveerror .= "- ".&translate("Die Eingabe muss eine IP sein (Format: 123.123.123.123)",$lang).$nl);
			}

			elsif (uc($S_validation) eq "EMAIL") {
				# Input must be in email format
				my $searchstring = '^[-a-z0-9_.]+@([-a-z0-9]+\.)+[a-z]{2,6}$';
				(! ($value =~ m/$searchstring/i)) && ($saveerror .= "- ".&translate("Die Eingabe muss eine E-Mail Adresse sein",$lang).$nl);
			}
		} 
		my $searchstring = "#param".($i+1)."#";
		$runstring =~ s/$searchstring/$value/;
	} # end (for) check entered values (for)	
	if (! $saveerror) {
		# Exec
		# my $rstring;
		
		$msg = `$SESSION{'WCONFFILE'} $runstring `;
		(! $msg) && ($msg = '-'); 
		$msg = '<span id="norbold">'.&translate("Ergebnis",$lang).'</span>: '.$nl.'<span id="norgreenbold">'.$msg.'</span>'.$nl;
		#print $nl.$SESSION{'WCONFFILE'}." $runstring status";
		
		
		#print "----------".$msg; 
		#open (EXCOMMAND, $SESSION{'WCONFFILE'}." ".$runstring." |") || ($saveerror .= "- ".&translate("Es trat ein Fehler bei der Ausf&uuml;hrung auf, es wurden keine &Auml;nderungen durchgef&uuml;hrt",$lang).$nl);
		#open (EXCOMMAND, "/bin/ls") || ($saveerror .= "- ".&translate("Es trat ein Fehler bei der Ausf&uuml;hrung auf, es wurden keine &Auml;nderungen durchgef&uuml;hrt",$lang).$nl);

		#while (<EXCOMMAND>) {
			#print $_.$nl;
		#	$rstring .= $_;
		#}
		#close (EXCOMMAND);
		#print $rstring;
	}
	$msg = '<span id="norbold">'.&translate("Ausgef&uuml;hrt",$lang)."</span>: ".$nl.'<span id="norgreenbold">'.$SESSION{'WCONFFILE'}." ".$runstring.'</span>'.$nl.$msg;
} elsif ($CGIO->param('dosave') > 0) {
	####################################################
	# SAVE STANDARD VALUE ASSIGMENT START ##############
	####################################################
	if ((($CGIO->param('dosave') == 1) && ($finput[0])) || (($CGIO->param('dosave') == 1) && (! $finput[0]) && ($finputtmp[0] ne "#LEAVEUNSET#"))) {   ## Save option to configuration file
	  #print "&gt;".$CGIO->param('finput')."&lt;";
	  #print "&gt;".$CGIO->param('finput')
	  if ((@finput) || (@finputtmp) || ($finput[0] eq "0") || ($finputtmp[0] eq "0") ) {
	    if ((uc($S_conftype) == "STANDARD") || ($S_conftype < 0)) {
	      ## Looking for key in conf file
	      my $S_key = $CWFO->get_tag_attribut_value ('STEP','TYPE','key',$sectionid,0);
	      if ($S_key < 0) {
	        ## No conf key but standard conf 
	        undef($S_key);
	        $saveerror .= &translate("- Fehler im Wizard-File",$lang).$nl;	
	        ($debug_level == 1) && (print "Could not find key in wizard file for this step");
	      }
	       
	      ## Get number of times key can be defined
	      my $S_keynumber = $CWFO->get_tag_attribut_value ('STEP','TYPE','number',$sectionid,0);
	      ($S_keynumber < 0) && ($S_keynumber = "1");
	      
	      #print $S_keynumber.":";      
	      if (($S_keynumber > 1) || ($S_keynumber == 0)) { # multiply keys allowed, use select and input fields
					#print "GANNZ".$S_keynumber;exit;
	        if (! $finput[0]) { # Set value to selected one 
		  			$CGIO->param(-name=>'finput',-value=>@finputtmp);
		  			@finput = @finputtmp;
					} else {
		  			foreach my $onein (@finputtmp) {
	  	  	  	($finput[0] ne $onein) && (push (@finput,$onein));
	       		}
		  			$CGIO->param(-name=>'finput',-value=>@finput);
	       		#print $S_keynumber.":"@finput;
					}	
	    	} else { # only one value for key allowed
	  			if (! $finput[0]) { # Set value to selected one 
		  			$CGIO->param(-name=>'finput',-value=>@finputtmp);
		  			@finput = @finputtmp;
	 				}
					#if (($finput[0] eq "##  ##") || ($finput[0] eq "#LEAVEUNSET#")) { # Set value empty 
					#  $CGIO->param(-name=>'finput',-value=>'');
					#  $finput[0] = '';
					#}
				} 

	      my $S_notinstart = $CWFO->get_tag_attribut_value ('STEP','TYPE','notinstart',$sectionid,0);
	      ($S_notinstart < 0) && (undef $S_notinstart);

	      my $S_notinstop = $CWFO->get_tag_attribut_value ('STEP','TYPE','notinstop',$sectionid,0);
	      ($S_notinstop < 0) && (undef $S_notinstop);      
	
	      if (($S_keynumber > 0) && ($S_keynumber < @finput)) {
	          $saveerror .= "- ".&translate("Es wurden zuviele Werte f&uuml;r diese Option angegeben",$lang).$nl;
	          ($debug_level == 1) && (print "Found ".@finput." values, allowed are ".$S_keynumber);
	      }
	
	      #print $finput[0]."--------------";
	      for (my $i=0; $i<@finput; $i++) {
	        my $value = $finput[$i];  # real value, if quote is used, then find value without quotes
	        
	        $value =~ s/^\s+//; # Remove leading spaces
	        $value =~ s/\s+$//; # Remove spaces from the end
	
	        ## Handle empty value
	        if (($S_canempty != 1) && ($value eq ""))  {
	          # Value must be defined but is not
		  			$saveerror .= "- ".&translate("Bitte geben Sie einen Wert f&uuml;r diesen Schritt an",$lang);
	        }
	
	        ## Looking for quotations
	        if (($S_quote) && ($S_quote != -1)) {
	          ## the input should be quoted
	          if ($value ne "") {
	            my $searchstring = '^\s*\\'.$S_quote.'\s*(.*)'.$S_quote.'\s*';
	            if (! ($value =~ m/$searchstring/i)) {
		      			# input is not correct quoted
	              $saveerror .= "- ".&translate("Der Wert muss innerhalb bestimmter Zeichen stehen. Beispiel",$lang).": ".$S_quote.&translate("Wert",$lang).$S_quote.$nl;
		    			} else {
		     				$value = $1;
		    			}
		  			}	
	        }
	
	        ## Look for input validation rulez
	        if (($S_validation) && ($S_validation != -1) && ($value ne "##  ##")) {
		  			if (uc($S_validation) eq "EXISTPATH") { 
	            # Input must be an existing path
	            (substr($value,0,1) ne "/") && ($saveerror .= "- ".&translate("Der Pfad muss absolut angegeben werden (beginnend mit /)",$lang).$nl);
	            (! -d $value)  && ($saveerror .= "- ".&translate("Das angegeben Verzeichnis existiert nicht",$lang).$nl);
	          } #elsif (uc($S_validation) eq "PATH") {
	          # Input must be in path form
	          #(substr($value,0,1) ne "/") && ($saveerror .= "- ".&translate("Der Pfad muss absolut angegeben werden (beginnend mit /)",$lang).$nl);
	          
	          elsif (uc($S_validation) eq "EXISTFILE") {
	            # Input must be an existing file
	            (substr($value,0,1) ne "/") && ($saveerror .= "- ".&translate("Die Datei muss im absoluten Format angegeben werden (beginnend mit /)",$lang).$nl);
		    			(! -f $value)  && ($saveerror .= "- ".&translate("Die angegebene Datei existiert nicht",$lang).$nl);
	          } 
	          
	          #elsif (uc($S_validation) eq "FILE") {
	          # Input must be in absolute file name form
	          #(substr($value,0,1) ne "/") && ($saveerror .= "- ".&translate("Die Datei muss im absoluten Format angegeben werden (beginnend mit /)",$lang).$nl);
	
	          elsif (uc($S_validation) eq "LETTERS") {
	            # Input must be only letters
	            my $searchstring = '^[a-zA-ZäöüÄÖÜß]+$';
		    			(! ($value =~ m/$searchstring/i)) && ($saveerror .= "- ".&translate("Die Eingabe darf nur aus Buchstaben bestehen",$lang).$nl);
	          } 
	          
	          elsif (uc($S_validation) eq "NUMBERS") {
	            # Input must be only numbers
	            my $searchstring = '^\d+$';
	            (! ($value =~ m/$searchstring/i)) && ($saveerror .= "- ".&translate("Die Eingabe darf nur aus Ziffern bestehen",$lang).$nl);
	          } 
	          elsif (uc($S_validation) eq "NUMLETTERS") {
	            # Input must be numbers and/or letters
	            my $searchstring = '^\w+$';
	            (! ($value =~ m/$searchstring/i)) && ($saveerror .= "- ".&translate("Die Eingabe darf nur aus Ziffern, Buchstaben oder Unterstrichen bestehen",$lang).$nl);
	          }           
	          
	          elsif (uc($S_validation) eq "IP") {
	            # Input must be in ip format
	            my $searchstring = '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$';
	            (! ($value =~ m/$searchstring/i)) && ($saveerror .= "- ".&translate("Die Eingabe muss eine IP sein (Format: 123.123.123.123)",$lang).$nl);
	          }
	
	          elsif (uc($S_validation) eq "EMAIL") {
	            # Input must be in email format
	            my $searchstring = '^[-a-z0-9_.]+@([-a-z0-9]+\.)+[a-z]{2,6}$';
	            (! ($value =~ m/$searchstring/i)) && ($saveerror .= "- ".&translate("Die Eingabe muss eine E-Mail Adresse sein",$lang).$nl);
	          }
	          
	          
	        } 
	      } # end check entered values (for)
	
	      my $CFO;
	      # Check for configuration file and create object
	      if (! $saveerror) {
	        $CFO = new CWFFile ($SESSION{'WCONFFILE'});
	        if ($CFO->is_error()) {
	          $saveerror .= "- ".&translate("Kann Konfigurationsdatei nicht finden",$lang).' ('.$SESSION{'WCONFFILE'}.')'.$nl;
	          ($debug_level == 1) && (print $CFO->get_error_msg());
	        }
	      } 
	
	      # Load configuration from file
	      if (! $saveerror) {
	        $CFO->load_file();
	        if ($CFO->is_error()) {
	          $saveerror .= "- ".&translate("Kann Konfigurationsdatei nicht lesen",$lang).$nl;
	          ($debug_level == 1) && (print $CFO->get_error_msg());
	        }  
	      }
	
	      # Set new value for key
	      if (! $saveerror) {
					(! $W_commentchar) && ($W_commentchar = "NOCOMMENT");
					my $lineschanged;
					#if (($S_number == 1) || ($S_number eq "0")) {
		  		$lineschanged = $CFO->set_key_values ($S_key,$W_assignchar,$W_commentchar,\@finput, &myhtml2txt($S_notinstart),&myhtml2txt($S_notinstop));
					#} else {
					#  print "MULTI";
					#}
					if ($CFO->is_error()) {
	    		  $saveerror .= "- ".&translate("Einstellung konnte nicht ge&auml;ndert werden",$lang).$nl;
		 				($debug_level == 1) && (print $CFO->get_error_msg());
	  			} 
	  			if (($S_keynumber > 0) && ($S_keynumber < $lineschanged)) {
	  				$saveerror .= "- ".&translate("Fehler im Konfigurationsfile, Einstellung zu oft vorhanden",$lang).$nl;
	    			($debug_level == 1) && (print "Option found: ".$lineschanged." times, should be max ".$S_keynumber);
		  		}
	  		}
	
	
				# Save configuration to file
				if (! $saveerror) {
					$CFO->save_file();
					if ($CFO->is_error()) {
					  $saveerror .= "- ".&translate("Einstellung konnte nicht gespeichert werden",$lang).$nl;
				    ($debug_level == 1) && (print $CFO->get_error_msg());
				  } 
				}
		
				# Load next step
				if ((! $saveerror) && ($CGIO->param('fnextstepid')) && ($CGIO->param('fnextstepid') <= $SESSION{'WSTEPID'})) {
					# The next step ID is smaller then the current step ID, we must be at the end
					# if no cleanup, goto index
					# if cleanup, do cleanup
					$goindex = 1;
					print '<meta http-equiv="refresh" content="0; URL=site_startwizard.cgi?1=1'.$URLADD.'">';
					return 1;	
				} elsif ((! $saveerror) && ($CGIO->param('fnextstepid')) && ($CGIO->param('fnextstepid') != $SESSION{'WSTEPID'})) {
					$sectionid = $CWFO->get_sectionnr_by_stepid ($CGIO->param('fnextstepid'));
					($sectionid > 0) && ($SESSION{'WSTEPID'} = $CWFO->get_tag_attribut_value ("STEP","STEP","id",$sectionid));
				} else {
					#print $saveerror;
				}
		
				# Success message
				if (! $saveerror) {
					$msg = &translate("Einstellung gespeichert",$lang).$nl;
				}
	
			} # End configuration is type STANDARD
		} else {
			print "No value defined?!";
		}
	} # end dosave = 1 (save standard assignment value)
	elsif (($CGIO->param('dosave') == 1) && ($finputtmp[0] eq "#LEAVEUNSET#")) {
	  if ((! $saveerror) && ($CGIO->param('fnextstepid')) && ($CGIO->param('fnextstepid') < $SESSION{'WSTEPID'})) {
	    # The next step ID is smaller then the current step ID, we must be at the end
	    # if no cleanup, goto index
	    # if cleanup, do cleanup
	    $goindex = 1;
	    print '<meta http-equiv="refresh" content="0; URL=site_startwizard.cgi?1=1'.$URLADD.'">';
	    return 1;	
	  } elsif ((! $saveerror) && ($CGIO->param('fnextstepid')) && ($CGIO->param('fnextstepid') != $SESSION{'WSTEPID'})) {
	    $sectionid = $CWFO->get_sectionnr_by_stepid ($CGIO->param('fnextstepid'));
	    ($sectionid > 0) && ($SESSION{'WSTEPID'} = $CWFO->get_tag_attribut_value ("STEP","STEP","id",$sectionid));
	  } 
	
	}
	
	############################################
	## MULTILINE SAVING
	############################################
	if ($CGIO->param('dosave') == 2) {   ## Save option to configuration file
		my $sectext   = $CGIO->param('sectioncontent');
		my $secnr   = $CGIO->param('secnr');


		my $CFO;
	
		# Check for configuration file and create object
		if (! $saveerror) {
			$CFO = new CWFFile ($SESSION{'WCONFFILE'});
			if ($CFO->is_error()) {
				$saveerror .= "- ".&translate("Kann Konfigurationsdatei nicht finden",$lang).' ('.$SESSION{'WCONFFILE'}.')'.$nl;
				($debug_level == 1) && (print $CFO->get_error_msg());
			}
		} 	

		# Load configuration from file
		if (! $saveerror) {
			$CFO->load_file();
			if ($CFO->is_error()) {
				$saveerror .= "- ".&translate("Kann Konfigurationsdatei nicht lesen",$lang).$nl;
				($debug_level == 1) && (print $CFO->get_error_msg());
			}  
		}

		my $S_StartCode = $CWFO->get_tag_content ("STEP","START",$sectionid);
		my $S_StopCode = $CWFO->get_tag_content ("STEP","STOP",$sectionid);

	  if (($CGIO->param('SecSave')) && ($CGIO->param('secnr') > 0)) {
	  	# Abschnitt bereits vorhanden, geänderte Version jetzt speichern
	  	#print ($CGIO->param('sectioncontent'));
	  	my @lines = split ("\n",$CGIO->param('sectioncontent'));
	  	$CFO->set_section (&myhtml2txt($S_StartCode),&myhtml2txt($S_StopCode),$secnr,@lines);
		if ($CFO->is_error()) {
			print $CFO->get_error_msg();exit;
		} else {
			$CFO->save_file();
		}
		if ((length($CGIO->param('sectioncontent')) == 0) && ($CGIO->param('secnr') > 0)) {
			$CGIO->param(-name=>'secnr',-value=>'1');
		}
	  } elsif ($CGIO->param('SecSaveNew')) {
		# Insert new section at eof
	  	my @lines = split ("\n",$CGIO->param('sectioncontent'));
	  	$CFO->set_section (&myhtml2txt($S_StartCode),&myhtml2txt($S_StopCode),-1,@lines);
		if ($CFO->is_error()) {
			print $CFO->get_error_msg();exit;
		} else {
			$CFO->save_file();
		}		
		
	  }

		## Get number of times key can be defined
		my $S_keynumber = $CWFO->get_tag_attribut_value ('STEP','TYPE','number',$sectionid,0);
		($S_keynumber < 0) && ($S_keynumber = "1");
		
		# Load next step
		if ((($CGIO->param('NextStep')) || ($S_keynumber==1)) && (! $saveerror) && ($CGIO->param('fnextstepid')) && ($CGIO->param('fnextstepid') < $SESSION{'WSTEPID'})) {
			# The next step ID is smaller then the current step ID, we must be at the end
			# if no cleanup, goto index
			# if cleanup, do cleanup
			$goindex = 1;
			print '<meta http-equiv="refresh" content="0; URL=site_startwizard.cgi?1=1'.$URLADD.'">';
			return 1;	
		} elsif ((($CGIO->param('NextStep')) || ($S_keynumber==1)) && (! $saveerror) && ($CGIO->param('fnextstepid')) && ($CGIO->param('fnextstepid') != $SESSION{'WSTEPID'})) {
			$sectionid = $CWFO->get_sectionnr_by_stepid ($CGIO->param('fnextstepid'));
			($sectionid > 0) && ($SESSION{'WSTEPID'} = $CWFO->get_tag_attribut_value ("STEP","STEP","id",$sectionid));
		} else {
			print $saveerror;
		}
	
		# Success message
		if (! $saveerror) {
			$msg = &translate("Einstellung gespeichert",$lang).$nl;
		}	
	}
} # end dosave > 0


##################################################################
###                START OUTPUT                                ###
##################################################################

print '<table width="100%" border="0" cellpadding="0" cellspacing="10" bgcolor="#ffffff">';
print '<tr><td colspan=2>';                                                                                                             # mainmenu
do "part_mainmenu.pl" || die "Error $@";
print '</td></tr>';
print '<tr><td width="250px" valign=top>';
#do "part_choosewlanguage.pl" || die "Error in ".$@;
(($saveerror || $msg) && (do "part_showmessage.pl" || die "Error in ".$@));
do "part_choosewstep.pl" || die "Error in ".$@;
print '</	td><td valign="top">
       <table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'>
		   <tr><td>
			 <table width="100%" border="0" cellpadding="2" cellspacing="0">
       <tr><td '.$table_header.' id="wht">';
my $appversion = $CWFO->get_tag_content("HEADER","APPVERSION");
if (($appversion != -1) && ($appversion != 0)) {
	$appversion = " v".$appversion;
} else {
	undef ($appversion);
}
print ' &nbsp;'.&translate("Wizard",$lang)." ".&translate("f&uuml;r",$lang)." ".ucfirst($CWFO->get_tag_content("HEADER","APPLICATION")).$appversion;
print ' / '.&translate("Schritt",$lang).' ';
my $stepname;
($SESSION{'WLANG'}) && ($stepname = $CWFO->get_tag_content_with_attribut('STEP','NAME','language',$SESSION{'WLANG'},$sectionid));
## Name not found in current language, try to find any language
(($stepname eq "0") || (! $SESSION{'WLANG'})) && ($stepname = $CWFO->get_tag_content('STEP','NAME',$sectionid));
($stepname < 0) && ($stepname = &translate ("Kein Name",$lang));
print '&quot;'.$stepname.'&quot; ';
($stepnr > 0) && print '('.$stepnr.')';
print '</b></font></td></tr>

       <!-- ################### STEP NAVIGATION (NEXT/PREVIOUS STEP ################# //-->';
do "part_step_head_navigation.pl" || die "Error $@";
              
              
our $dependcount = $CWFO->count_tag_appearance ('STEP','DEPENDS',$sectionid);
if ($dependcount > 0) {
	print '<!-- ################### STEP DEPENDICIES ################# //-->';
 	do "part_step_head_dependencies.pl" || die "Error $@";
}

print '<!-- ################### STEP CONTENT ################# //-->
       <tr><td '.$table_body.'>
		   <table width="100%" border="0" cellpadding="0" cellspacing="10">
  	   <tr><td id="nor" widht="80%"><span id="big"><u>'.$stepname.'</u></span><br>';
my $help;
($SESSION{'WLANG'}) && ($help = $CWFO->get_tag_content_with_attribut('STEP','HELP','language',$SESSION{'WLANG'},$sectionid));
## Step help not found in current language take any help
(($help eq "0") || (! $SESSION{'WLANG'})) && ($help = $CWFO->get_tag_content('STEP','HELP',$sectionid));
($help < 0) && ($help = &translate ("Keine Hilfe f&uuml;r diesen Schritt verf&uuml;gbar",$lang));
$help = &transform_help ($help);
print '</td>';

my $sysinfo = "";
my $CFO;
my $conftypef = $CWFO->get_tag_content("HEADER","CONFTYPE");
if (($conftypef == -1) || ($conftypef eq "configfile")) {
	############################ Init Configuration File
	$sysinfo = '<table width="98%" border="0" cellpadding="1" cellspacing="0" align="center" '.$table_header.'><tr><td><table border="0" width="100%" align="center" cellpadding="1" cellspacing="1" '.$table_body2.' ><tr><td id="sml" colspan="2" nowrap><b>System Informationen:</b></td></tr><tr><td valign="top" width="1%"><li></li></td><td id="sml" valign="top">';
	##### Create Conf file object
  $CFO = new CWFFile ($SESSION{'WCONFFILE'});
	if ($CFO->is_error()) {
		$sysinfo .= $CFO->get_error_msg();
	} else {
		$sysinfo .= 'Configuration file found'.$SESSION{'SWCONFFILE'};
		$CFO->load_file();
	}
	$sysinfo .= '</td></tr><tr><td valign="top"><li></li></td><td id="sml" valign="top">';


	# Handle backup files if configuration file is used

	##### Try to access backup of orginal configuration file
	my $CFOB = new CWFFile ($SESSION{'WCONFFILE'}.'.cwfsave');
	if ($CFOB->is_error()) {
		$sysinfo .= 'Backup copy of orginal configuration file does not exists, creating...';
		if (cp($SESSION{'WCONFFILE'},$SESSION{'WCONFFILE'}.'.cwfsave') == 1) {
			$sysinfo .= " backup file successfully created ";
		} else {
			$sysinfo .= " can't make backup file";
		}
	} else {
		$sysinfo .= 'Backup of orginal configuration file is available';
	}

	$sysinfo .= '</td></tr><tr><td valign="top"><li></li></td><td id="sml" valign="top">';
	##### Try to access session backup of configuration file
	my $CFOB = new CWFFile ($SESSION{'WCONFFILE'}.'.'.$sessionid.'.cwfsave');
	if ($CFOB->is_error()) {
		$sysinfo .= 'Session backup copy of configuration file does not exists, creating...';
		if (cp($SESSION{'WCONFFILE'},$SESSION{'WCONFFILE'}.'.'.$sessionid.'.cwfsave') == 1) {
			$sysinfo .= " session backup file successfully created ";
		} else {
			$sysinfo .= " can\t copy file";
		}
	} else {
		$sysinfo .= 'Session backup of orginal configuration file is available';
	}
	$sysinfo .= '</td></tr>';
}	
print '</tr>
			 <tr><td>&nbsp;</td></tr>'."\n";

# Set error false, if true, the wizard step can't be used
my $error = 0; 

print '<form action="'.$SELFNAME.'.cgi" name="step" method="post">'."\n";
print '<input type="hidden" name="fstepid" value="'.$SESSION{'WSTEPID'}.'">'."\n";
print '<input type="hidden" name="fnextstepid" value="'.$stepid.'">'."\n";
my $S_conftype = $CWFO->get_tag_attribut_value ('STEP','TYPE','kind',$sectionid,0);
my $inputtype;

# keynumber can be used in each configuration type
my $S_keynumber = $CWFO->get_tag_attribut_value ('STEP','TYPE','number',$sectionid,0);
($S_keynumber < 0) && ($S_keynumber = "1");

## Looking for def value
my $defvalue = $CWFO->get_tag_attribut_value ('STEP','TYPE','default',$sectionid,0);
($defvalue < 0) && (undef ($defvalue));
		
$S_validation = $CWFO->get_tag_attribut_value ('STEP','TYPE','validation',$sectionid,0);
($S_validation < 0) && ($S_validation = "0");

$S_quote =  $CWFO->get_tag_attribut_value ('STEP','TYPE','quote',$sectionid,0);
($S_quote < 0) && (undef ($S_quote));

if (($conftypef == -1) || ($conftypef eq "configfile")) {
	# if configtype is configuration file
	if ((uc($S_conftype) eq "STANDARD") || ($S_conftype < 0)) {
		print '<input type="hidden" name="dosave" value="1">'."\n";
		# this step uses a standard value assignment
		$inputtype = $CWFO->get_tag_attribut_value ('STEP','TYPE','input',$sectionid,0);
	
		my $S_key = $CWFO->get_tag_attribut_value ('STEP','TYPE','key',$sectionid,0);
		($S_key < 0) && ($S_key = "");
	
		my $S_canempty = $CWFO->get_tag_attribut_value ('STEP','TYPE','canempty',$sectionid,0);
		($S_canempty < 0) && ($S_canempty = "0");

		my $S_notinstart = $CWFO->get_tag_attribut_value ('STEP','TYPE','notinstart',$sectionid,0);
		($S_notinstart < 0) && (undef $S_notinstart);
	
		my $S_notinstop = $CWFO->get_tag_attribut_value ('STEP','TYPE','notinstop',$sectionid,0);
		($S_notinstop < 0) && (undef $S_notinstop);

		## Count key appaerance in conf file
		$sysinfo .= '<tr><td valign="top"><li></li></td><td id="sml" valign="top">';
		my $keycounter;
		if (length($S_key) > 0) { 
			$keycounter = $CFO->find_key ($S_key, $W_assignchar, $S_notinstart, &myhtml2txt($S_notinstop));
			if (($S_keynumber > 0) && ($keycounter > $S_keynumber)) {
				$sysinfo .= "ERROR: Key found to many times ($keycounter) in file";
				$error = 1;
			} else {
				$sysinfo .= "Found key ". $keycounter." time(s)";
			}
			$sysinfo .= '</td></tr>';
			# Get the active value for this option
			$sysinfo .= '<tr><td valign="top"><li></li></td><td id="sml" valign="top">';
			my @prevalues;
			my $prefound=0;
			if ($error == 0) {
				@prevalues = $CFO->get_key_values ($S_key,$W_assignchar,&myhtml2txt($S_notinstart), &myhtml2txt($S_notinstop));
				$prefound = @prevalues;
				if ($prefound > 0) {
					$sysinfo .= $prefound." values for key found, 1st: ".$prevalues[0];
				} else {
					undef (@prevalues);
					$sysinfo .= "No value for key found ";
				}
			}
			$sysinfo .= '</td></tr>';


			# Find all comment out values for this option
			$sysinfo .= '<tr><td valign="top"><li></li></td><td id="sml" valign="top">';
			my @altprevalues;
			my $altprevalcount = 0;
			if ($error == 0) {
				@altprevalues = $CFO->get_alt_key_values ($S_key,$W_assignchar,$W_commentchar,&myhtml2txt($S_notinstart), &myhtml2txt($S_notinstop));
				$altprevalcount = @altprevalues;
				if ($altprevalcount > 0) {
					$sysinfo .= "Alt. value found for key: ".$altprevalcount;
				} else {
					undef (@altprevalues);
					$sysinfo .= "No more alternatives values found ";
				}
			}
			$sysinfo .= '</td></tr>';
	
	
			if (uc($inputtype) eq "TEXTLINE") {
				# input through a textfield (standard)	  
				print '<tr><td id="nor" valign="top">';
				print &translate ("Wert angeben",$lang).': <input type="text" name="finput" value="';
				if ($saveerror) {
					print &mytxt2html($CGIO->param("finput"));
				} else {
					print &mytxt2html ($prevalues[0]);
				} #elsif ($defvalue) { 
				print '" size="30"> ';   
				($S_keynumber != 1) && (print &translate ('und',$lang)." / ");
				print &translate ('oder',$lang);
				print ' <select name="finputtmp" onChange="document.step.finput.value=\'\';" ';
				($S_keynumber != 1) && (print ' multiple size="5" ');
				print '>';
				if ($prefound > 0) {
					#if ($prevalue || ($prevalue eq "0")) {
					for (my $i=0;$i<$prefound;$i++) {
						print '<option value="'.&mytxt2html($prevalues[$i]).'" selected >'.&mytxt2html($prevalues[$i]).' ('.&translate('Zur Zeit aktiv',$lang).') </option>'; 
					}
				} else {
					print '<option value="#LEAVEUNSET#" selected >'.&translate('Wert undefiniert lassen (Keine &Auml;nderung vornehmen)',$lang).'</option>'; 
				}
				if ($defvalue || $defvalue eq "0") {
					print '<option value="'.&mytxt2html($defvalue).'">'.&mytxt2html($defvalue).' ('.&translate('Standard Wert',$lang).') </option>'; 
				} 
				$sysinfo .= '<tr><td valign="top"><li></li></td><td id="sml" valign="top">';
				#$sysinfo .= $CWFO->get_tag_attribut_value ('STEP','TYPE','notinstop',$sectionid,0);
				$sysinfo .= $CWFO->get_tag_attribut_value("STEP","TYPE","ignorealtvalues",$sectionid);
				$sysinfo .= '</td></tr>';
				if ($CWFO->get_tag_attribut_value ("STEP","TYPE","ignorealtvalues",$sectionid) != 1) {
					if ($altprevalcount > 0) {
						# print comment out values
						foreach (@altprevalues) {
							(uc($S_validation) eq "IP") && (! ($_ =~ m/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)) && next; 	# Validation type is number, filter all values that don't match
							(uc($S_validation) eq "LETTERS") && (! ($_ =~ m/^[a-zA-ZäöüÄÖÜß]+$/)) && next; 	# Validation type is letters, filter all values that don't match
							(uc($S_validation) eq "NUMBERS") && (! ($_ =~ m/^\d+$/)) && next; 	# Validation type is number, filter all values that don't match
							(uc($S_validation) eq "NUMLETTERS") && (! ($_ =~ m/^\w+$/)) && next; 	# Validation type is numbers, letters or underline, filter all values that don't match
							(uc($S_validation) eq "EMAIL") && (! ($_ =~ m/^[-a-z0-9_.]+@([-a-z0-9]+\.)+[a-z]{2,6}$/)) && next; 	# Validation type is email filter all values that don't match
				
							print '<option value="'.&mytxt2html($_).'">';
							my @parts = split(/%CWF%/, $_);
							#print (@parts);
							if (@parts == 2) {
							
								print &mytxt2html(@parts[0])." (".@parts[1].")";
							} else {
								print &mytxt2html($_).' ';
							}
							#('.&translate('Auskommentierter Wert',$lang).') 
							print '</option>';
						}	
					}
				}	
				if ($S_canempty == 1) {
					# The value for this step can be undefined (empty)
					print '<option value="##  ##" ';
					($keycounter > 0) && ($prefound == 0) && (print "selected"); 
					print '>'.&translate('Wert nicht definieren',$lang);
					($keycounter > 0) && ($prefound == 0) && (print ' ('.&translate('Zur Zeit aktiv',$lang).') '); 
					print '</option>';
				} 
				print '</select>';
				print '</td></tr>';
			}
		
			if (uc($inputtype) eq "SELECTABLE") {
				print '<tr><td id="nor" align="center" valign="top">';
				my $optionscount = $CWFO->count_tag_appearance ('STEP','SELECT',$sectionid);
				print &translate ("Bitte ausw&auml;hlen",$lang).' <select name="finput">';
				my %send;
				for (my $counter=0;$counter<$optionscount;$counter++) {
					# look for each selection if it is available in current language and if it is already send to browser
					my $selval = $CWFO->get_tag_attribut_value ('STEP','SELECT','value',$sectionid,$counter);
					my $seldesc;
					($SESSION{'WLANG'}) && ($seldesc = $CWFO->get_tag_content_with_two_attributs('STEP','SELECT','language',$SESSION{'WLANG'},'value',$selval,$sectionid));
					if (($seldesc < 0) || ($seldesc eq "0") || (! $SESSION{'WLANG'})) {
						$seldesc = $CWFO->get_tag_content_with_attribut('STEP','SELECT','value',$selval,$sectionid)
					}
		
					if ($send{$selval} != 1) {
						# if option is not send to browser before, send it now
						$send{$selval} = 1;
						print '<option value="'.&mytxt2html($selval).'" '; 
						if ((($prefound == 0) && (uc($selval) eq uc($defvalue))) || (uc($prevalues[0]) eq uc($selval))) {
							print " selected ";
						}
						print '>'.&mytxt2html($seldesc);
						($selval eq $defvalue) && ($selval ne $prevalues[0]) && print ' ('.&translate('Standard Wert',$lang).')';
						($selval eq $prevalues[0]) && ($selval ne $defvalue) && print ' ('.&translate('Zur Zeit aktiv',$lang).')';
						($selval eq $prevalues[0]) && ($selval eq $defvalue) && print ' ('.&translate('Standard Wert',$lang).' / '.&translate('Zur Zeit aktiv',$lang).')';
						print '</option>';
					} 
				} # end for
				print '</select></td></tr>';
			} # end if selectable
		} # end if key	

		if ($S_validation || $S_quote) { #SHOW HINT
			print '<tr><td id="nor"><br><span id="norbold">'.&translate('Hinweis',$lang).':</span><br>';
			if ($S_validation) {
				(uc($S_validation) eq "EXISTPATH")  && print &translate("Der Wert muss ein existierendes Verzeichnis sein",$lang).".".$nl;
				(uc($S_validation) eq "EXISTFILE")  && print &translate("Der Wert muss eine existierende Datei sein",$lang).".".$nl;
				(uc($S_validation) eq "FILE")  			&& print &translate("Der Wert muss eine Datei sein",$lang).".".$nl;				
				(uc($S_validation) eq "NUMBERS")    && print &translate("Der Wert darf nur Ziffern enthalten",$lang).".".$nl;
				(uc($S_validation) eq "LETTERS")    && print &translate("Der Wert darf nur Buchstaben enthalten",$lang).".".$nl;
				(uc($S_validation) eq "NUMLETTERS") && print &translate("Der Wert darf nur Buchstaben, Zahlen oder Unterstriche enthalten",$lang).".".$nl;
				(uc($S_validation) eq "IP")   		  && print &translate("Der Wert muss eine IP-Adresse sein. Beispiel:",$lang)." 127.0.0.1".$nl;
				(uc($S_validation) eq "EMAIL")      && print &translate("Der Wert muss eine E-Mail Adresse sein",$lang).".".$nl;
			}
			if ($S_quote) {
				print &translate ("Der Wert muss innerhalb bestimmter Zeichen stehen. Beispiel",$lang).": ".$S_quote.&translate("Wert",$lang).$S_quote.$nl;
			}
			print '</td></tr>';
		} # END HINT
		if ($error == 0) {
			print '<tr><td align="center"><br><input type="submit" name="Send" value="'.&translate('Einstellung speichern',$lang).'"><br><br></td></tr>';
		} else {
			print '<tr><td id="norredbold">'.&translate('Es trat ein Fehler auf, dieser Konfigurationsschritt kann nicht ausgeführt werden',$lang).'</td></tr>';
		}	
	} # Ende configuration type = standard


	if ((uc($S_conftype) eq "USER") || ($S_conftype < 0)) {
		print '<input type="hidden" name="dosave" value="2">'."\n";
		my $S_StartCode = $CWFO->get_tag_content ("STEP","START",$sectionid);
		#print $S_StartCode."\n";
		my $S_StopCode = $CWFO->get_tag_content ("STEP","STOP",$sectionid);
		if (($S_StartCode < 0) || ($S_StopCode < 0)) {
			$error = 1;
		} else {
			my $secnr = 1;
		  if ($CGIO->param('secnr') > 0) {
		  	$secnr = $CGIO->param('secnr');
		  }
		  print '<input type="hidden" name="secnr" value="'.$secnr.'">'."\n";
			my $sectionsfound = $CFO->count_sections (&myhtml2txt($S_StartCode),&myhtml2txt($S_StopCode));
			my @sectionlines = $CFO->get_section (&myhtml2txt($S_StartCode),&myhtml2txt($S_StopCode),$S_keynumber,$secnr);
			if ($CFO->is_error()) {
			  print $CFO->get_error_msg();
			}
			print '<tr><td align="center">
			<a name="secedit"></a>';
			if ($sectionsfound > 1) {
				print '<span id="norbold">'.&translate("F&uuml;r diesen Schritt existieren bereits mehrere Abschnitte.",$lang)." ".&translate("Sie k&ouml;nnen zwischen den einzelnen Abschnitten, mit Hilfe der Links neben dem Textfeld, w&auml;hlen",$lang).'</span><br><br>';
			}
			print '<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_body2.'><tr><td width="1%">
			<textarea name="sectioncontent" rows="10" cols="60">';
			for (my $i=0;$i<@sectionlines;$i++) {
				print $sectionlines[$i];
			}
			print '</textarea></td>';
			print '<td align="left" nowrap valign="top">';
			if ($sectionsfound > 1) {
				for (my $i=1; $i<=$sectionsfound; $i++) {
					if ($i == $secnr) {
					  print '&nbsp; <span id="norbold">'.&translate("Abschnitt",$lang).' '.$i.'</span><br>';
					} else {
						print '&nbsp; <a href="site_step.cgi?stepid='.$SESSION{'WSTEPID'}.$URLADD.'&secnr='.$i.'#secedit" class="nor10">'.&translate("Abschnitt",$lang).' '.$i.'</a><br>';
					}	
				}
			}
	 		print '</td>';
			print '</tr></table>';
			if (@sectionlines == 0) {
				print $nl.'<span id="norbold">'.&translate("Abschnitt in Ihrer aktuellen Konfiguration noch nicht vorhanden",$lang)."!</span>";
			}
			print '</td></tr>';
			if ($error == 0) {
				print '<tr><td align="center"><br><br>';
				if (@sectionlines > 0) {
					print '<input type="submit" name="SecSave" value="'.&translate('Abschnitt speichern',$lang).'">';
				}
				if (($S_keynumber eq "0") || ($sectionsfound < $S_keynumber)) {
					print ' <input type="submit" name="SecSaveNew" value="'.&translate('Als neuen Abschnitt speichern',$lang).'">';
	 			}	
	 			print ' <input type="submit" name="NextStep" value="'.&translate('Zum n&auml;chsten Schritt',$lang).'">';
				print '<br><br></td></tr>';
			} else {
				print '<tr><td id="norredbold">'.&translate('Es trat ein Fehler auf, diese Konfigurationsschritt kann nicht ausgeführt werden',$lang).'</td></tr>';
			}				
		}
	}
} # END if configuration type is config file
elsif ($conftypef eq "configprogram") {
	print '<tr><td id="nor" valign="top">';
	print '<input type="hidden" name="doexec" value="1">'."\n";
	
	## Get number of values can be defined
	my $S_number = $CWFO->get_tag_attribut_value ('STEP','TYPE','number',$sectionid,0);
	($S_number < 0) && ($S_number = "1");
	for (my $i=0;$i<$S_number;$i++) {
		print &translate ("Wert",$lang).' '.($i+1).': <input type="text" name="finput" value="';
		if ($saveerror) {
			print &mytxt2html($finput[$i]);
		} else {
			($i == 0) && print &mytxt2html($defvalue);
		}
		print '" size="30"> '.$nl;
	}   
	print '</td></tr>';
	if ($S_validation || $S_quote) { #SHOW HINT
		print '<tr><td id="nor"><br><span id="norbold">'.&translate('Hinweis',$lang).':</span><br>';
		if ($S_validation) {
			(uc($S_validation) eq "EXISTPATH")  && print &translate("Der Wert muss ein existierendes Verzeichnis sein",$lang).".".$nl;
			(uc($S_validation) eq "EXISTFILE")  && print &translate("Der Wert muss eine Datei sein",$lang).".".$nl;
			(uc($S_validation) eq "FILE")  			&& print &translate("Der Wert muss eine Datei sein",$lang).".".$nl;
			(uc($S_validation) eq "NUMBERS")    && print &translate("Der Wert darf nur Ziffern enthalten",$lang).".".$nl;
			(uc($S_validation) eq "LETTERS")    && print &translate("Der Wert darf nur Buchstaben enthalten",$lang).".".$nl;
			(uc($S_validation) eq "NUMLETTERS") && print &translate("Der Wert darf nur Buchstaben, Zahlen oder Unterstriche enthalten",$lang).".".$nl;
			(uc($S_validation) eq "IP")   		  && print &translate("Der Wert muss eine IP-Adresse sein. Beispiel:",$lang)." 127.0.0.1".$nl;
			(uc($S_validation) eq "EMAIL")      && print &translate("Der Wert muss eine E-Mail Adresse sein",$lang).".".$nl;
		}
		if ($S_quote) {
			print &translate ("Der Wert muss innerhalb bestimmter Zeichen stehen. Beispiel",$lang).": ".$S_quote.&translate("Wert",$lang).$S_quote.$nl;
		}
		print 
		print '</td></tr>';
	} # END HINT	
	if ($error == 0) {
		print '<tr><td align="center"><input type="submit" name="Send" value="'.&translate('Ausf&uuml;hren',$lang).'"><br><br></td></tr>';
	} else {
		print '<tr><td id="norredbold">'.&translate('Es trat ein Fehler auf, diese Konfigurationsschritt kann nicht ausgeführt werden',$lang).'</td></tr>';
	}	
}
print '</form>';
print '</table><table width="100%" border="0" cellpadding="0" cellspacing="10"><tr><td id="nor">';
print $help;
print '</td></tr>';

print '</table><br><br></td></tr>';
print '<!-- ################### STEP NAVIGATION (NEXT/PREVIOUS STEP ################# //-->';
do "part_step_head_navigation.pl" || die "Error $@";
print '</table>
</td>
</tr>';


print '</table>';
print '</td>'; # Main CONTENT 
print '</tr>';       
print '</table>';

$sysinfo .= '</table></td></tr></table>';
#print $sysinfo;

do "part_footer.pl" || die "Error ";

