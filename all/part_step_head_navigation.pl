#!/usr/bin/perl

use strict;

our $table_body2;
our $CWFO;
our %SESSION;
our $userlevel;
our $URLADD;
our $lang;
our $stepid;



print '              <tr>
                <td '.$table_body2.'>
		  						<table width="100%" border="0" cellpadding="0" cellspacing="0">
  							    <tr>';
  							      my $laststep = $CWFO->get_previous_step($SESSION{'WSTEPID'}, $SESSION{'WSKILLID'}, $SESSION{'WGROUPID'});
  							      #print $laststep;
  							      $stepid = $CWFO->get_tag_attribut_value ('STEP','STEP','id',$laststep,0);
  							      if ($laststep > 0) {
		  						      print '<td width="1%">';
												  ($userlevel == 1) && (print '<a href="site_step.cgi?stepid='.$stepid.$URLADD.'"><img src="images/cwf_arrow_left_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Zum vorherigen Schritt",$lang).'"></a>');
	    			              ($userlevel == 2) && (print '<a href="site_step.cgi?stepid='.$stepid.$URLADD.'"><img src="images/cwf_arrow_left_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Zum vorherigen Schritt",$lang).'"></a>');
	    			            print '</td>
	    			            <td align="left">';
												  print '<a href="site_step.cgi?stepid='.$stepid.$URLADD.'" class="nor10">'.&translate("Zum vorherigen Schritt",$lang).'</a>';
	    			            print '</td>';
	    			          }
		  						    print '<td width="1%">';
												($userlevel == 1) && (print '<a href="site_startwizard.cgi?1=1'.$URLADD.'"><img src="images/cwf_step_index_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Zur Wizard &Uuml;bersichtsseite",$lang).'"></a>');
                        ($userlevel == 2) && (print '<a href="site_startwizard.cgi?1=1'.$URLADD.'"><img src="images/cwf_step_index_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Zur Wizard &Uuml;bersichtsseite",$lang).'"></a>');
                      print '</td>
                      <td align="left">';
												print '<a href="site_startwizard.cgi?1=1'.$URLADD.'" class="nor10">'.&translate("Zur Wizard &Uuml;bersichtsseite",$lang).'</a>';
      	              print '</td>';
  							      my $nextstep = $CWFO->get_next_step($SESSION{'WSTEPID'},$SESSION{'WSKILLID'}, $SESSION{'WGROUPID'});
  							      $stepid = $CWFO->get_tag_attribut_value ('STEP','STEP','id',$nextstep,0);
  							      if ($nextstep > 0) {
		  						      print '<td width="1%">';
												  ($userlevel == 1) && (print '<a href="site_step.cgi?stepid='.$stepid.$URLADD.'"><img src="images/cwf_arrow_right_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Zun n&auml;chsten Schritt",$lang).'"></a>');
	    			              ($userlevel == 2) && (print '<a href="site_step.cgi?stepid='.$stepid.$URLADD.'"><img src="images/cwf_arrow_right_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Zun n&auml;chsten Schritt",$lang).'"></a>');
	    			            print '</td>
	    			            <td align="left">';
												  print '<a href="site_step.cgi?stepid='.$stepid.$URLADD.'" class="nor10">'.&translate("Zun n&auml;chsten Schritt",$lang).'</a>';
	    			            print '</td>';
	    			          }                      
                    print '</tr>
                  </table>
                </td>
              </tr>';
              
 return 1;