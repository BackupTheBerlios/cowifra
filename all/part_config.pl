

sub myuri_escape {
   my $string = shift;
   $string =~ s/ /%20/g;
   $string =~ s/\//%2F/g;
   return $string;
}

sub mytxt2html {
   my $text = shift;
   $text =~ s/\"/\&quot\;/g;
   $text =~ s/\'/\&acute\;/g;
   $text =~ s/\</\&lt;/g;
	 $text =~ s/\</\&gt;/g;   
   return $text;
}


sub myhtml2txt {
   my $text = shift;
   $text =~ s/\&quot\;/\"/g;
   $text =~ s/\&acute\;/\'/g;
   $text =~ s/\&gt\;/\>/g;
   $text =~ s/\&lt\;/\</g;
   return $text;
}


sub mygmtime {                                                                  	# Create expired date for cookies 
	my ($etime) = @_;
	my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
	my @days = ("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
	my ($sec,$min,$hr,$mday,$mon,$yr,$wday,$yday,$isdst) = gmtime($etime);
        # format must be Wed, DD-Mon-YYYY HH:MM:SS GMT
	my $timestr = sprintf("%3s, %02d-%3s-%4d %02d:%02d:%02d GMT",
	$days[$wday],$mday,$months[$mon],$yr+1900,$hr,$min,$sec);
	return $timestr;
}

sub transform_help {
	my $helptext = shift;
	$helptext =~ s/\[\[/</g;
	$helptext =~ s/\]\]/>/g;
	return $helptext;
}


if (length($ENV{'HTTP_COOKIE'}) > 2) {
  my @cookies = split(/[;,]\s*/,$ENV{'HTTP_COOKIE'});                             # Seperate cookies
  foreach my $cook (@cookies) {
    my @actcookie = split /(\=)/,$cook;
    $cookies{$actcookie[0]} = $actcookie[2];
  }
}

########### Get usermode
if (($ENV{'SERVER_SOFTWARE'} =~ /^MiniServ/ ) && ($ENV{'SERVER_PORT'} == 10000)) { 
    $usemode = 3;                                                               # Seems like webmin is running above us
} elsif (! defined($ENV{'SERVER_SOFTWARE'})) {
    $usemode = 1;                                                               # Hm, no server, we must be in shell, debuggin?
} else {
    $usemode = 2;                                                               # Unknown server runs above us, must be a regular webserver
} 
 

#if (! %cookies) {
#  ($userlevel > 0) && ($URLADD .= "&ULEVEL=".$userlevel);
#  ($lang > 0) && ($URLADD .= "&CLANG=".$lang);
#}

if ($cookies{'CSESSIONID'} > 0) {
  	$sessionid = $cookies{'CSESSIONID'};
} elsif ($CGIO->param('SESSIONID') > 0) {
	$sessionid = $CGIO->param('SESSIONID');
	$URLADD .= "&SESSIONID=".$sessionid;
} else {
	$sessionid = time();
	$URLADD .= "&SESSIONID=".$sessionid;
}

($sessionid > 0) && print "Set-Cookie: CSESSIONID=$sessionid; expires=".&mygmtime(time+(86400*365))."\n";

###### session data 
if (-e "sessiondata/".$sessionid.".ses") {					# Session file exists
        open(SESSIONFILE,"sessiondata/".$sessionid.".ses");			
	while(<SESSIONFILE>){
		chomp ($_); 							# cut line feed
		my @sesparam = split /(\=)/,$_;                                # seperate data
		$SESSION{$sesparam[0]} = $sesparam[2];			
	}
	close (SESSIONFILE);
}
	

############ Get user language; 1=english, 2=german
if (length($CGIO->param('ULANG')) > 0) {                                               # new language set by user?
  $lang = $CGIO->param('ULANG');
} elsif (length($SESSION{'LANG'}) > 0) {
  $lang = $SESSION{'LANG'};
} elsif (length($cookies{'CLANG'}) > 0) {
  $lang = $cookies{'CLANG'};
} else {
  $lang = "de";
  if ($ENV{'HTTP_ACCEPT_LANGUAGE'} =~ /de/ ) {
    $lang = "de";
  } elsif (($ENV{'HTTP_ACCEPT_LANGUAGE'} =~ /us/ ) || ($ENV{'HTTP_ACCEPT_LANGUAGE'} =~ /en/ )) {
    $lang = "uk";
  }
}
($lang > 0) && print "Set-Cookie: CLANG=$lang; expires=".&mygmtime(time+(86400*365))."\n";	# safe language in a long time cookie

########## Get user screen level; 1= Beginner, 2 = Advanced, 3=Expert
if ($CGIO->param('ULEVEL') > 0) {                                             ##### new level set by user?
  $userlevel = $CGIO->param('ULEVEL');
} elsif ($SESSION{'ULEVEL'} > 0) {
  $userlevel = $SESSION{'ULEVEL'};
} elsif ($cookies{'CLEVEL'} > 0) {
  $userlevel = $cookies{'CLEVEL'};
} else {
  $userlevel = 1;
}

($userlevel > 0) && print "Set-Cookie: CLEVEL=$userlevel; expires=".&mygmtime(time+(86400*365))."\n";

########## wizard file

if ($CGIO->param('wfile')) {
	$SESSION{'WFILE'} = $CGIO->param('wfile');
}

if ($CGIO->param('wlang')) {
	$SESSION{'WLANG'} = $CGIO->param('wlang');
  (uc($CGIO->param('wlang')) eq uc("en")) 			&& ($lang = "uk");
  (uc($CGIO->param('wlang')) eq uc("uk")) 			&& ($lang = "uk");
  (uc($CGIO->param('wlang')) eq uc("ENGLISH")) 	&& ($lang = "uk");
  (uc($CGIO->param('wlang')) eq uc("ENGLISCH")) && ($lang = "uk");
  (uc($CGIO->param('wlang')) eq uc("DE")) 			&& ($lang = "de");
  (uc($CGIO->param('wlang')) eq uc("GERMAN")) 	&& ($lang = "de");
  (uc($CGIO->param('wlang')) eq uc("DEUTSCH")) 	&& ($lang = "de");	
	($lang > 0) && print "Set-Cookie: CLANG=$lang; expires=".&mygmtime(time+(86400*365))."\n";	# safe language in a long time cookie
  #print $CGIO->param('wlang')."---------".$nl;	
  #exit;
}

if ($CGIO->param('togglemain') == 1) {
	if ($SESSION{'SMAIN'} == 1) {
		$SESSION{'SMAIN'} = 0;
	} else {
		$SESSION{'SMAIN'} = 1;
	}
}

if ($CGIO->param('togglewlang') == 1) {
	if ($SESSION{'SWLANG'} == 1) {
		$SESSION{'SWLANG'} = 0;
	} else {
		$SESSION{'SWLANG'} = 1;
	}
}

if ($CGIO->param('togglewsteps') == 1) {
	if ($SESSION{'SWSTEPS'} == 1) {
		$SESSION{'SWSTEPS'} = 0;
	} else {
		$SESSION{'SWSTEPS'} = 1;
	}
}

if ($CGIO->param('togglecleanup') == 1) {
	if ($SESSION{'SWCLEANUP'} == 1) {
		$SESSION{'SWCLEANUP'} = 0;
	} else {
		$SESSION{'SWCLEANUP'} = 1;
	}
}

if ($CGIO->param('stepid')) {
	$SESSION{'WSTEPID'} = $CGIO->param('stepid');
}

if ($CGIO->param('skillid')) {
	$SESSION{'WSKILLID'} = $CGIO->param('skillid');
}

if ($CGIO->param('groupid')) {
	$SESSION{'WGROUPID'} = $CGIO->param('groupid');
}


my @actfile = split /(\/)/,$0;                                                  # get name of actual script
my @actname = split /(\.)/,$actfile[(@actfile-1)];                              # name of actual script 
$SELFNAME = $actname[(@actname-3)];                                             # name of actual script without .cgi


####################################### Header output

if (($usemode == 3) && ($SELFNAME ne "help")) {
    do '../web-lib.pl' || die "Failed do";
    &init_config();
    &header ("Configuration Wizard Framework","icon.gif",'','','','','','<link rel=\'stylesheet\' type=\'text/css\' href=\'style.css\'>');
    $table_header = "bgcolor=#000099";
    $table_body   = "bgcolor=#EEEEFF";
    $table_body2  = "bgcolor=#DDDEFF";
    $table_body3  = "bgcolor=#F1D6D3";
    
    $nl = "<br>";
} elsif (($usemode == 2) || ($SELFNAME eq "help")) {
    # use my header
    $table_header = "bgcolor=#000099";
    $table_body   = "bgcolor=#EEEEFF";
    $table_body2  = "bgcolor=#FFFFFF";
    $table_body3  = "bgcolor=#F1D6D3";
    
    print "Content-type: text/html\n\n";
    print "<html><header><title>Configuration Wizard Framework</title><link rel='stylesheet' type='text/css' href='style.css'></header><body>";
    $nl = "<br>";
} else {
    $nl = "\n";
}
##################################### End Header 


if ($SESSION{'WFILE'}) {
	use CWF;
	$CWFO = new CWF ($SESSION{'WFILE'}.".cwf",$usemode);						# new object 
	$CWFO->is_error() &&  die "Error: ".$nl.$CWFO->get_error_msg.$nl;  		# end at every error
	#print "Object is on...".$nl;

	#$CWFO->validate_xml_file();                                                    # checks if xml-file matches dtd
	#$CWFO->is_error() && die "Error: ".$nl.$CWFO->get_error_msg.$nl;
	#print "Skip validation...".$nl;

	$CWFO->new_xml_parser();                                                        # suceed every time
	#print "Parser is on...".$nl;

	(! $CWFO->start_xml_parser()) && die "Error: ".$nl.$CWFO->get_error_msg.$nl;    # parse the xml-file 
	#print "Parsing is done...".$nl;

	#################################### end checking & parsing


	#######################
	#print $nl;
	$debug_level && $CWFO->is_warning() && print "Warnings: ".$nl.$CWFO->get_warning().$nl;
}


1;



