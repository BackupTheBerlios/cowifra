#!/usr/bin/perl

use strict;

our $table_body3;	
our $lang;	
our $dependcount;
our $CWFO;
our %SESSION;
our $userlevel;
our $URLADD;
our $sectionid;

print '<tr><td '.$table_body3.'><table width="100%" border="0" cellpadding="3" cellspacing="0">
<tr><td colspan="4" id="nor"><center id="norbold12">'.&translate("Abh&auml;ngigkeiten",$lang).'</center>'.&translate("Folgende Schritte sollten ebenfalls durchgef&uuml;hrt werden, wenn Sie &Auml;nderungen in diesem Schritt vornehmen",$lang).':</td></tr>';
for (my $i=0;$i<sprintf("%.2f",$dependcount/2);$i++) {
	print "<tr>";
	my $dependstepid = $CWFO->get_tag_content ("STEP","DEPENDS",$sectionid,$i);
	my $dependsectionnr = $CWFO->get_sectionnr_by_stepid($dependstepid);
	my $dependstepname;
	($SESSION{'WLANG'}) && ($dependstepname = $CWFO->get_tag_content_with_attribut ("STEP","NAME","language",$SESSION{'WLANG'},$dependsectionnr));
	if (($dependstepname < 0) || ($dependstepname eq "0") || (! $SESSION{'WLANG'})) {
		$dependstepname = $CWFO->get_tag_content ('STEP','NAME',$dependsectionnr)
	}
	print '<td width="1%">';
	($userlevel == 1) && (print '<a href="site_step.cgi?stepid='.$dependstepid.$URLADD.'"><img src="images/cwf_step_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Abh&auml;ngiger Schritt",$lang).'"></a>');
	($userlevel == 2) && (print '<a href="site_step.cgi?stepid='.$dependstepid.$URLADD.'"><img src="images/cwf_step_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Abh&auml;ngiger Schritt",$lang).'"></a>');
	print '</td>		  							  	
	<td><a href="site_step.cgi?stepid='.$dependstepid.$URLADD.'" class="nor10">'.$dependstepname.'</a></td>';

	my $j = $i + sprintf("%.2f",$dependcount/2) + 1;
	($j > $dependcount) && next;
	my $dependstepid = $CWFO->get_tag_content ("STEP","DEPENDS",$sectionid,$j);
	my $dependsectionnr = $CWFO->get_sectionnr_by_stepid($dependstepid);
	my $dependstepname;
	($SESSION{'WLANG'}) && ($dependstepname = $CWFO->get_tag_content_with_attribut ("STEP","NAME","language",$SESSION{'WLANG'},$dependsectionnr));
	if (($dependstepname < 0) || ($dependstepname eq "0") || (! $SESSION{'WLANG'})) {
		$dependstepname = $CWFO->get_tag_content ('STEP','NAME',$dependsectionnr)
	}
	print '<td width="1%">';
	($userlevel == 1) && (print '<a href="site_step.cgi?stepid='.$dependstepid.$URLADD.'"><img src="images/cwf_step_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Abh&auml;ngiger Schritt",$lang).'"></a>');
	($userlevel == 2) && (print '<a href="site_step.cgi?stepid='.$dependstepid.$URLADD.'"><img src="images/cwf_step_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Abh&auml;ngiger Schritt",$lang).'"></a>');
	print '</td>		  							  	
	<td><a href="site_step.cgi?stepid='.$dependstepid.$URLADD.'" class="nor10">'.$dependstepname.'</a></td>';
	print '</tr>';
}
print '</table></td></tr>';

return 1;
