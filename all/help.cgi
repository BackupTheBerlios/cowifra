#!/usr/bin/perl

use strict;
use CGI;

our %cookies;
our $usemode;
our $lang;
our $CGIO = new CGI;                                                            # initial cgi object
our $userlevel;
our $sessionid;
our $URLADD = "";
our $SELFNAME;
our $table_header;								 # 
our $table_body;	 							 # Fuss der Seite (kommt bei Webmin von Webmin)
my $debug_level = 1;								 # 0 = Keine Error oder Warnungen ausgeben / 1 = Direkt ausgeben
our %SESSION;
our $nl;                                                                         # Zeilenumbruch

do "part_config.pl" || die "Error $@";
do 'translate.pl'   || die "Error in ";                                          # include function translate


my $pagetitle;
($CGIO->param('site') eq "cwf") && ($pagetitle = "&gt; ".translate("Willkommen",$lang));
($CGIO->param('site') eq "wizardfiles") && ($pagetitle = "&gt; ".translate("Wizard Dateien",$lang));
($CGIO->param('site') eq "index") && ($pagetitle = "&gt; ".translate("Startseite",$lang));
($CGIO->param('site') eq "site_startwizard") && ($pagetitle = "&gt; ".translate("Wizard Startseite",$lang));
($CGIO->param('site') eq "site_step") && ($pagetitle = "&gt; ".translate("Wizard Schritt",$lang));



print $nl;
print '
<table width="100%" border="0" cellpadding="0" cellspacing="10" bgcolor="#ffffff">
  <tr>
    <td valign="top">';
      print '<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'>
        <tr>
          <td>
            <table width="100%" border="0" cellpadding="2" cellspacing="0">
              <tr>
                <td '.$table_header.' id="wht">';
                  print "&gt; ".translate("Hilfe",$lang)." ".$pagetitle;
                  print '</b></font>
                </td>
              </tr>
              <tr>
                <td '.$table_body.'>';
		  ###### Load help file 
		  if (-e "helpfiles/".$CGIO->param('site')."_".$SESSION{'LANG'}.".html") {					# Help file exists
				open(HELPFILE,"helpfiles/".$CGIO->param('site')."_".$SESSION{'LANG'}.".html");			
				while(<HELPFILE>){
					print $_;
				}
				close (HELPFILE);
			} else {
				print "helpfiles/".$CGIO->param('site')."_".$SESSION{'LANG'}.".html not found";
			}
                print '</td>
              </tr>
            </table>
          </td>
        </tr>
      </table>';
    print '</td>
    <td valign="top">
      <table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'>
        <tr>
          <td>
            <table width="100%" border="0" cellpadding="2" cellspacing="0">
              <tr>
                <td '.$table_header.' id="wht">';
                  print "&gt; ".translate("Hilfe",$lang)." > ".translate("Inhalt",$lang);
                  print '</b></font>
                </td>
              </tr>
              <tr>
                <td '.$table_body.' width="200" valign="top">';
		  ###### Load help file 
		  if (-e "helpfiles/content_".$SESSION{'LANG'}.".html") {					# Help file exists
				open(HELPFILE,"helpfiles/content_".$SESSION{'LANG'}.".html");			
				while(<HELPFILE>){
					print $_;
				}
				close (HELPFILE);
			} else {
				print "helpfiles/content_".$SESSION{'LANG'}.".html not found";
			}
                print '</td> 
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </td>
    </tr>
</table>';

do "part_footer.pl" || die "Error ";



























