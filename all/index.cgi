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
my $file = "wizardfile1.xml"; 							 # Zu lesendes XML-File
my $debug_level = 1;								 # 0 = Keine Error oder Warnungen ausgeben / 1 = Direkt ausgeben
our $nl;                                                                         # Zeilenumbruch

do "part_config.pl" || die "Error $@";
do 'translate.pl'   || die "Error in ";                                          # include function translate


print $nl;
print '
<table width="100%" border="0" cellpadding="0" cellspacing="10" bgcolor="#ffffff">
  <tr>
    <td colspan=2>';                                                                                                             # mainmenu
      do "part_mainmenu.pl" || die "Error ";
      print '
    </td>
  </tr>
  <tr>
    <td width="250px" valign=top>';
      do "part_choosewfile.pl" || die "Error in ".$@;
    print '</td>
    <td valign="top">';
      print '<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'>
        <tr>
          <td>
            <table width="100%" border="0" cellpadding="2" cellspacing="0">
              <tr>
                <td '.$table_header.' id="wht">';
                  print translate("> Startseite",$lang);
                  print '</b></font>
                </td>
              </tr>
              <tr>
                <td '.$table_body.'>
                  <table border="0" width="100%" align="center" cellpadding="1" cellspacing="5">
                    <tr>
                      <td COLSPAN=2 id="nor"><span id="big">';
                        print translate("Herzlich Willkommen, ",$lang);
                        print "</span>".$nl.$nl;
                        print translate("im Wizard Configuration Framework (CWF).",$lang)." ";
											  print translate("Mit Hilfe des CWF k&ouml;nnen Sie beliebige Unix/Linux Programmpakete (f&uuml;r die eine ",$lang);
											  print translate("CWF-Datei exististiert) Schritt f&uuml;r Schritt konfigurieren und ",$lang);
											  print translate("erhalten auf Wunsch zu jedem einzelnen Schritt weitergehenden Informationen.",$lang);
                        print " ".translate("Um jetzt mit der Konfiguration eines Programmpaketes zu beginnen, ",$lang);
                        print translate("w&auml;hlen Sie bitte einen Wizard aus der Liste auf der linken Seite aus.",$lang);
                        print " ".translate("Im Hauptmen&uuml; unter dem Punkt &quot;Hilfe&quot; erhalten Sie mehr",$lang);
                        print " ".translate("Informationen zur Bedienung des CWF",$lang).".";
                        print $nl,$nl;
                        print '
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>';
    print '</td>
  </tr>
</table>';

do "part_footer.pl" || die "Error ";



























