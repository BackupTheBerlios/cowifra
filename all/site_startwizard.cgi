#!/usr/bin/perl

use CWF;
use strict;
use CGI;
use POSIX; # for strftime (format time for backup files)

our %cookies;
our $usemode;
our $lang;									 # CWF language
our $CGIO = new CGI;                                                             # initial cgi object
our $userlevel;									 # screen user level
our $URLADD = "";								 # used if no cookies available
our $SELFNAME;
our $sessionid;		
our %SESSION;
our $table_header;								 # 
our $table_body;	 							 # 
our $table_body2;	 							 # 
my $debug_level = 1;								 # 0 = Keine Error oder Warnungen ausgeben / 1 = Direkt ausgeben
our $nl;                                                                         # Zeilenumbruch
our $CWFO;

do "part_config.pl" || die "Error $@";
do 'translate.pl'   || die "Error in ";                                          # include function translate

($SESSION{'WSTEPID'}) && ($SESSION{'WSTEPID'} = '');
($SESSION{'WSKILLID'}) && ($SESSION{'WSKILLID'} = '');
($SESSION{'WGROUPID'}) && ($SESSION{'WGROUPID'} = '');


our $saveerror; # Error messages -> abort
our $msg;       # Other messages

if ($CGIO->param('cleanupid') > 0) {
  my $cleanname = $CWFO->get_tag_content_with_attribut ('CLEANUP','EXECUTE','id',$CGIO->param('cleanupid'),1);
  if ($cleanname < 0) {
    $saveerror = &translate("Aktion nicht vorhanden",$lang);
  } else {
  
    my $cleanupcounter = $CWFO->count_tag_appearance ("CLEANUP","EXECUTE",1);
    if ($cleanupcounter > 0) {
    	# There are executables
    	for (my $i=0; $i<$cleanupcounter; $i++) {
    		my $cleanid = $CWFO->get_tag_attribut_value ("CLEANUP","EXECUTE","id",1,$i);
    		if ($cleanid == $CGIO->param('cleanupid')) {
    			my $execcode = $CWFO->get_tag_attribut_value ("CLEANUP","EXECUTE","pathfile",1,$i);
    			my $execparam = $CWFO->get_tag_attribut_value ("CLEANUP","EXECUTE","parameter",1,$i);
    			if (-f $execcode) {
    				my $execresult = system("$execcode $execparam");
    				if ($execresult != 0) {
    					$saveerror = &translate("Beim ausf&uuml;hren der Aktion trat ein Fehler auf",$lang)." ($execresult)"; 
    				} else {
    					$msg = &translate("Aktion erfolgreich ausgef&uuml;hrt",$lang);
    				}
    				last;
    			} 
    		}
    	} # end for
    }
  }
} elsif ($CGIO->param('cleanupid') eq "all") {
  my $cleanup = 0;
  $cleanup = $CWFO->count_section_appearence("CLEANUP");

  if ($cleanup > 0) {
	 my $i = 0;
	 my $cleanid = 0;
	 my $foundact = 0;
	 my $allcounter = 0;
	 do {
		$i = $CWFO->get_next_exec($i);
		#print $i.": i<br>";
		if ($i > 0) {
			$allcounter++;
			my $cleanname = $CWFO->get_tag_content_with_attribut ('CLEANUP','EXECUTE','id',$i,1);
			if ($cleanname < 0) {
				$saveerror .= &translate("Aktion nicht vorhanden",$lang);
			} else {
				my $cleanupcounter = $CWFO->count_tag_appearance ("CLEANUP","EXECUTE",1);
			    	if ($cleanupcounter > 0) {
					# There are executables
					for (my $j=0; $j<$cleanupcounter; $j++) {
						my $cleanid = $CWFO->get_tag_attribut_value ("CLEANUP","EXECUTE","id",1,$j);
						if ($cleanid == $i) {
							my $execcode = $CWFO->get_tag_attribut_value ("CLEANUP","EXECUTE","pathfile",1,$j);
							my $execparam = $CWFO->get_tag_attribut_value ("CLEANUP","EXECUTE","parameter",1,$j);
							if (-f $execcode) {
								my $execresult = system("$execcode $execparam");
								if ($execresult != 0) {
									$saveerror .= &translate("Beim ausf&uuml;hren der Aktion trat ein Fehler auf",$lang)." ($execresult)"."<br>"; 
								} else {
									$msg .= &translate("Aktion erfolgreich ausgef&uuml;hrt",$lang)."<br>";
								}
								last;
							} 
						}
					} # end for
			    	}
			}
			
				
		}
		#($i > 0) && ($stepid = $CWFO->get_tag_attribut_value ('STEP','STEP','id',$i,0)) && (print $stepid.$nl);
	 } until ($i == 0);
  }
}  



print '<table width="100%" border="0" cellpadding="0" cellspacing="10" bgcolor="#ffffff"><tr><td colspan=2>';                                                                                                             # mainmenu
do "part_mainmenu.pl" || die "Error $@";
print '</td></tr><tr><td width="250px" valign=top>';
#do "part_choosewlanguage.pl" || die "Error in ".$@;
do "part_choosewstep.pl" || die "Error in ".$@;
do "part_cleanup.pl" || die "Error in ".$@;
(($saveerror || $msg) && (do "part_showmessage.pl" || die "Error in ".$@));
print '</td><td valign="top">';
print '<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'><tr>
  <td><table width="100%" border="0" cellpadding="2" cellspacing="0"><tr><td '.$table_header.' id="wht">';
my $appversion = $CWFO->get_tag_content("HEADER","APPVERSION");
if (($appversion != -1) && ($appversion != 0)) {
	$appversion = " v".$appversion;
} else {
	undef ($appversion);
}
print ' &nbsp;'.&translate("Wizard",$lang)." ".&translate("f&uuml;r",$lang)." ".ucfirst($CWFO->get_tag_content("HEADER","APPLICATION")).$appversion;
print '</b></font>';
print '</td></tr><tr><td '.$table_body.'>';
print '<table border="0" width="100%" align="center" cellpadding="1" cellspacing="5"><tr>'."\n";
print '<td colspan="2" id="nor"><span id="big">';
my $conftype;
my $conftypef = $CWFO->get_tag_content("HEADER","CONFTYPE");
if ($conftypef eq "configprogram") {
	$conftype = &translate ("Konfigurationsprogramm",$lang);
} elsif (($conftypef == -1) || ($conftypef eq "configfile")) {
	$conftype = &translate ("Konfigurationsdatei",$lang);
} else {
	$conftype = &translate ("Unbekannter Konfigurationstyp",$lang)."(!)";
}

print uc(&translate("Wizard",$lang)).' '.uc(&translate("Informationen",$lang)).":</span>".$nl."<hr>";
(length($appversion) < 2) && ($appversion = "-");
my $foundfile = 0;
my $file = $CWFO->get_tag_content ('HEADER','FILE');
print '<table border="0" width="100%" align="center" cellpadding="4" cellspacing="0"><tr>';
print '<td id="nor" nowrap width="1%" valign="top" align="right" '.$table_body2.'>'.&translate("Programm Packet",$lang).': </td><td width="1%" '.$table_body2.'>&nbsp;</td><td id="nor" '.$table_body2.'>'.$CWFO->get_tag_content("HEADER","APPLICATION").'</td>'."\n";
print '<td width="1%" '.$table_body2.'>&nbsp;</td>'."\n";
print '<td id="nor" nowrap width="1%" valign="top" align="right" '.$table_body2.'>'.&translate("Programm Version",$lang).': </td><td width="1%" '.$table_body2.'>&nbsp;</td><td id="nor" '.$table_body2.'>'.$appversion.'</td></tr><tr>';
print '<td id="nor" nowrap width="1%" valign="top" valign="top" align="right">'.&translate("Konfigurationstyp",$lang).': </td><td width="1%">&nbsp;</td><td id="nor" valign="top">'.$conftype.'</td>';
print '<td width="1%">&nbsp;</td>'."\n";
print '<td id="nor" nowrap width="1%" valign="top" valign="top" align="right">'.&translate("Dateipfade",$lang).': </td><td width="1%">&nbsp;</td><td id="nor">';
my $i = $CWFO->count_tag_appearance ('HEADER','PATH');
for (my $j=0; $j<$i; $j++) {
	my $path = $CWFO->get_tag_content ('HEADER','PATH',1,$j);
	my $distri = $CWFO->get_tag_attribut_value ('HEADER','PATH','distribution',1,$j);
	if (-d $path) {
		# not defined, what to do, if more then one conf file is found, until now the last found file is used
		print '<img src="images/available.gif" alt="'.&translate ("Pfad existiert in diesem System",$lang).'">';
		if (($conftypef == -1) || ($conftypef eq "configfile")) {
			(-e $path.$file) && ($foundfile == 0) && ($foundfile = 1) && ($SESSION{'WCONFFILE'} = $path.$file) && ($SESSION{'WCONFPATH'} = $path);
		} elsif ($conftypef eq "configprogram") { 
			if ((-x $path.$file) && ($foundfile == 0)) {
				$foundfile = 1;
				$SESSION{'WCONFFILE'} = $path.$file;
				$SESSION{'WCONFPATH'} = $path;
			}
		}
	} else {
		print '<img src="images/notavailable.gif" alt="'.&translate ("Pfad existiert nicht in diesem System",$lang).'">';
	}
	print $path;
	(length($distri)>2) && print ' ('.$distri.')';
	print $nl;
}
print '</td></tr>';
my $author = $CWFO->get_tag_content("HEADER","AUTHOR");
if (length($author)<3) {
	$author = "-";
} 
my $email = $CWFO->get_tag_content("HEADER","EMAIL");
if (length($email)<3) {
	$email = "";
} else {
	$email = $nl.'<a href="mailto:'.$email.'" class="nor10">'.$email.'</a>';
}

print '<tr><td id="nor" nowrap width="1%" valign="top" valign="top" align="right" '.$table_body2.'>'.&translate("Autor",$lang).': </td>'."\n";
print '<td width="1%" '.$table_body2.'>&nbsp;</td>'."\n";
print '<td id="nor" valign="top" '.$table_body2.'>'.$author.$email.'</td>';
print '<td width="1%" '.$table_body2.'>&nbsp;</td>'."\n";
print '<td id="nor" nowrap width="1%" valign="top" valign="top" align="right" '.$table_body2.'>'.&translate("Datei",$lang).': </td>'."\n";
print '<td width="1%" '.$table_body2.'>&nbsp;</td><td id="nor" valign="top" '.$table_body2.'>';

($foundfile == 1) && print '<img src="images/available.gif" alt="'.&translate ("Datei gefunden",$lang).'">';
($foundfile == 0) && print '<img src="images/notavailable.gif" alt="'.&translate ("Datei nicht gefunden",$lang).'">';
print $file;
print '</td></tr>';

my $url = $CWFO->get_tag_content("HEADER","URL");
if (length($url)<3) {
	$url = "-";
} else {
	$url = '<a href="'.$url.'" target="_blank" class="nor10">'.$url.'</a>';
}
my $date = $CWFO->get_tag_content("HEADER","DATE");
if (length($date)<3) {
	$date = "-";
} 
print '<tr><td id="nor" nowrap width="1%" valign="top" valign="top" align="right">'.&translate("Dowload URL",$lang).': </td>'."\n";
print '<td width="1%">&nbsp;</td><td id="nor" valign="top">'.$url.'</td>'."\n";
print '<td width="1%">&nbsp;</td>';
print '<td id="nor" nowrap width="1%" valign="top" valign="top" align="right">'.&translate("Wizard Datum",$lang).': </td>';
print '<td width="1%">&nbsp;</td><td id="nor">'.$date.'</td></tr>';

my $waddon = $CWFO->get_tag_content("HEADER","WIZARDFILEADDON");
if (! ($waddon < 0)) {


  my @filedata = split /(\.)/,$waddon;
  my $fname = $filedata[0];
	#use CWF;
	
	#$TCWFO = new CWF ($SESSION{'WFILE'}.".cwf",$usemode);						# new object 
	print '<tr><td id="nor" nowrap width="1%" valign="top" valign="top" align="right" '.$table_body2.'>';
	print &translate("Weiterer Wizard",$lang).': </td>'."\n";
	print '<td width="1%" '.$table_body2.'>&nbsp;</td>'."\n";
	print '<td id="nor" valign="top" '.$table_body2.' colspan="6">';
  print '<a HREF="site_startwizard.cgi?wfile='.&myuri_escape('wizards/'.$fname).$URLADD.'" class="nor10">';	
	print $fname.'</td>';
	print '</tr>';
}	

print '</table></td></tr>'."\n";

print '<tr><td>&nbsp;</td></tr>'."\n";
print '<tr><td colspan="2" id="norbold12">'."\n";
print &translate("Wizard",$lang).' '.&translate("starten",$lang).$nl;
print '<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'><tr><td>'."\n";
print '<table width="100%" border="0" cellpadding="2" cellspacing="0"><tr>';
print '<td '.$table_body.' align="center"><br><br>';

if (($foundfile == 1) || ($SESSION{'WCONFFILE'})) {
	#print '<a HREF="site_step.cgi?1=1'.$URLADD.'">';
	#($userlevel == 1) && print '<img src="images/cwf_start_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Wizard starten",$lang).'">';
	#($userlevel == 2) && print '<img src="images/cwf_start_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Wizard starten",$lang).'">';
	#print '</a>'.$nl
	print '<a HREF="site_step.cgi?1=1'.$URLADD.'" class="nor14">'.&translate("Wizard mit allen Schritten starten",$lang).' ('.$CWFO->count_steps().') </a>'.$nl;

  #### Wizard start by group
	my $groupscounter = $CWFO->count_tag_appearance ("HEADER","GROUPDEF");				# Count groups
	my %groups;
	for ($i=0;$i<$groupscounter;$i++) {									# find unique groups
		my $groupname;
		if (exists($SESSION{'WLANG'})) {
		  # if languages available
		  $groupname = $CWFO->get_tag_content_with_two_attributs("HEADER","GROUPDEF","id",$CWFO->get_tag_attribut_value('HEADER','GROUPDEF','id',1,$i),"language",$SESSION{'WLANG'}); 
		} 
	
		if ((! $groupname) || ($groupname < 0)) {
			# without languages
		  $groupname = $CWFO->get_tag_content_with_attribut ('HEADER','GROUPDEF',"id",$CWFO->get_tag_attribut_value('HEADER','GROUPDEF','id',1,$i));
		}
	
		#print $groupname;
		#my $groupname = $CWFO->get_tag_content_with_two_attributs("HEADER","GROUPDEF","id",$CWFO->get_tag_attribut_value('HEADER','GROUPDEF','id',1,$i),"language",$SESSION{
		$groups{$CWFO->get_tag_attribut_value('HEADER','GROUPDEF','id',1,$i)} = $groupname;
			
	}
		  
	$groupscounter = 0;
	my $groupscontent = '<table border="0" width="100%" align="center" cellpadding="5" cellspacing="1" '.$table_body2.'>';
	foreach my $onegroup (keys %groups) {
		$groupscounter++;
	  $groupscontent .= '<tr><td width="1%">';
	  ($userlevel == 1) && ($groupscontent .= '<a href="site_step.cgi?groupid='.$onegroup.$URLADD.'"><img src="images/cwf_wizard_group_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Wizard starten",$lang).'"></a>');
	  ($userlevel == 2) && ($groupscontent .= '<a href="site_step.cgi?groupid='.$onegroup.$URLADD.'"><img src="images/cwf_wizard_group_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Wizard starten",$lang).'"></a>');
	  $groupscontent .= '</td><td><a href="site_step.cgi?groupid='.$onegroup.$URLADD.'" class="nor10">'.$groups{$onegroup}.' ('.$CWFO->get_nr_steps_with_group($onegroup).')</a></td></tr>';
	}
	$groupscontent .= '</table>';
	
  #Wizard start by skill
	my $skillscounter = $CWFO->count_tag_appearance ("HEADER","SKILLDEF");				# Count skills 
	my %skills;
	
	for ($i=0;$i<$skillscounter;$i++) {									# find unique groups
			my $skillname;
		if (exists($SESSION{'WLANG'})) {
			$skillname = $CWFO->get_tag_content_with_two_attributs("HEADER","SKILLDEF","id",$CWFO->get_tag_attribut_value('HEADER','SKILLDEF','id',1,$i),"language",$SESSION{'WLANG'}); 
		} 
		if ((! $skillname) || ($skillname < 0)) {
			# without languages
			$skillname = $CWFO->get_tag_content_with_attribut ('HEADER','SKILLDEF',"id",$CWFO->get_tag_attribut_value('HEADER','SKILLDEF','id',1,$i));
		}
		$skills{$CWFO->get_tag_attribut_value('HEADER','SKILLDEF','id',1,$i)} = $skillname;
				
	}
		  
	$skillscounter = 0;
	my $skillscontent = '<table border="0" width="100%" align="center" cellpadding="5" cellspacing="1"'.$table_body2.' >';
	foreach my $oneskill (keys %skills) {
		$skillscounter++;
	  $skillscontent .= '<tr><td width="1%">';
	  ($userlevel == 1) && ($skillscontent .= '<a href="site_step.cgi?skillid='.$oneskill.$URLADD.'"><img src="images/cwf_wizard_skill_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Wizard starten",$lang).'"></a>');
	  ($userlevel == 2) && ($skillscontent .= '<a href="site_step.cgi?skillid='.$oneskill.$URLADD.'"><img src="images/cwf_wizard_skill_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Wizard starten",$lang).'"></a>');
	  $skillscontent .= '</td><td><a href="site_step.cgi?skillid='.$oneskill.$URLADD.'" class="nor10">'.$skills{$oneskill}.' ('.$CWFO->get_nr_steps_with_skill($oneskill).')</a></td></tr>';
	}
	
	$skillscontent .= '</table>';

	print '<table border="0" width="100%" align="center" cellpadding="1" cellspacing="15"><tr>';
	($skillscounter > 0) && (print '<td valign="top" id="norbold12">'.&translate("Wizard nach Benutzerlevel",$lang).'<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'><tr><td>'.$skillscontent.'</td></tr></table></td>');
	($groupscounter > 0) && (print '<td valign="top" width="50%" id="norbold12">'.&translate("Wizard nach Gruppe",$lang).'<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'><tr><td>'.$groupscontent.'</td></tr></table></td>');
	print '</tr>';
	
  #print $SESSION{'WCONFFILE'};
  # Write found file into session
} else {
  print &translate("Die Datei",$lang)." ".$file." ".&translate("wurde nicht in den angegebenen Verzeichnissen gefunden",$lang).".";
  print &translate("Ohne diese Datei kann der Wizard nicht gestartet werden.",$lang)." "; #$nl."<b>".&translate("Soll jetzt nach der Datei gesucht werden?",$lang)."</b>";	                   
}
print '<br><br></td></tr></table></td></tr></table></td></tr>'."\n\n";
#print '<tr><td colspan="2" id="nor" align="center">';
#print '</td></tr><tr><td>&nbsp;</td></tr>';
print '</table>';



#####################################################
# Handle Backup actions #############################
#####################################################

my $backupmsg = "";
if ($CGIO->param('bfile')) {
  my $mfile = $file;
	$mfile =~ s/\./\\\./g;
	if ($CGIO->param('bfile') =~ m/$mfile/) {
		if ($CGIO->param('action') eq "rem") {
			if (unlink ($CGIO->param('bfile')) != 1) {
				$backupmsg .= &translate("Backup Datei konnte nicht gel&ouml;scht werden",$lang);
			} else {
				$backupmsg .= &translate("Backup Datei wurde gel&ouml;scht",$lang);
			}
		} elsif ($CGIO->param('action') eq "use") {
			if ((-f $CGIO->param('bfile')) && (-f $SESSION{'WCONFFILE'})) {
				if (! rename ($SESSION{'WCONFFILE'},$SESSION{'WCONFFILE'}.".".time.".cwfsave")) {
					$backupmsg .= &translate("Konnte original Datei nicht umbenennen",$lang);
				}
				if (! rename ($CGIO->param('bfile'),$SESSION{'WCONFFILE'})) {
					$backupmsg .= &translate("Konnte Backup Datei nicht umbenennen",$lang);
				}
			  	$backupmsg .= &translate("Backup erfolgreich wieder hergestellt.",$lang);			
			} else {
				$backupmsg .= &translate("Eine der beiden Dateien ist nicht vorhanden. Backup kann nicht wieder hergestellt werden.",$lang);
			}
		}
  }
}

my @cwffiles=grep(/cwfsave/, glob($SESSION{'WCONFPATH'}."*.*"));
if (@cwffiles > 0) { 
 # There are backup files!

	print '<tr><td colspan="2" id="norbold12">'."\n";
	print &translate("Sicherheitskopien der Konfigurationsdatei",$lang).$nl;
	print '<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'><tr><td>'."\n";
	print '<table width="100%" border="0" cellpadding="2" cellspacing="0">';
	print '<tr><td '.$table_body.' id="norbold" align="center">'.&translate("Letzte &Auml;nderung",$lang).'</td>'."\n";
	print '<td '.$table_body.' id="norbold" align="right">'.&translate("Dateigr&ouml;sse",$lang).'</td>'."\n";
	print '<td '.$table_body.' id="nor" colspan="4">&nbsp;&nbsp;</td>'."\n";
	print '</tr>';
	
	foreach my $onefile (@cwffiles) {
		my @cwffileinfo = stat($onefile);
		my @date = localtime($cwffileinfo[9]);
		#my ($sec, $min, $stunde, $mtag, $mon, $jahr, $tag, $nr_tag, $isdst) = scalar localtime($cwffileinfo[9]);
		#my $datum = date('Y-m-d H:i', $cwffileinfo[9]);
		print '<form action="'.$SELFNAME.'.cgi" name="backup" method="post">'."\n";
		print '<input type="hidden" name="bfile" value="'.$onefile.'">'."\n";
		print '<tr><td '.$table_body.' id="norbold" align="center">'.strftime("%d.%m.%Y - %H:%M:%S",@date).'</td>'."\n";
		print '<td '.$table_body.' id="nor" align="right">'.$cwffileinfo[7].' Byte</td>'."\n";
		print '<td '.$table_body.' id="nor">&nbsp;&nbsp;</td>'."\n";
		print '<td '.$table_body.' id="nor"><input type="radio" name="action" value="rem"> '.&translate("l&ouml;schen",$lang).'</td>'."\n";
		print '<td '.$table_body.' id="nor"><input type="radio" name="action" value="use"> '.&translate("wiederherstellen",$lang).'</td>'."\n";
		print '<td '.$table_body.'><input type="submit" name="Doit" value="'.&translate("Ausf&uuml;hren",$lang).'"></td>'."\n";	
		print '</tr>';
		
		print '</form>';
	}

	if ($backupmsg) {
	  print '<tr><td colspan="6" '.$table_body.'>&nbsp;</td></tr>';
		print '<tr><td colspan="6" '.$table_body.' align="center" id="norredbold">'.$backupmsg.'</td></tr>';
		print '<tr><td colspan="6" '.$table_body.'>&nbsp;</td></tr>';
	}
	print '</table></td></tr></table></td></tr>'."\n\n";
}	
print '</table></td></tr></table></td></tr></table>';
print '</td></tr></table>';
do "part_footer.pl" || die "Error ";
