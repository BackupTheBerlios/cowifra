
      my $stepscounter = $CWFO->count_section_appearence("STEP");

      print '<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'>
        <tr>
          <td>
            <table width="100%" border="0" cellpadding="2" cellspacing="0">
              <tr>
                <td '.$table_header.' id="wht">';
                  print '<a href="'.$SELFNAME.'.cgi?togglewsteps=1'.$URLADD.'"><img src="images/';
		  if ($SESSION{'SWSTEPS'} != 1) {
			print 'minimize.gif';
		  } else {
			print 'maximize.gif';
		  }
                  print '" align="absmiddle" border="0" alt='.&translate("Verf&uuml;gbare Wizard Schritte anzeigen an/aus",$lang).'"></a> '.&translate("Alle Konfigurationsschritte",$lang);
                  print '
                </td>
              </tr>';
              if ($SESSION{'SWSTEPS'} != 1) { 
              print '<tr>
                <td '.$table_body.'>
                  <table border="0" width="100%" align="center" cellpadding="1" cellspacing="5">
                    <tr>
                      <td id="nor">';
			 #print $CWFO->get_tag_attributs('STEP','STEP',0,0);
			 my $i = 0;
			 my $stepid = 0;
			 my $foundact = 0;
			 my $allcounter = 0;
			 do {
				$i = $CWFO->get_next_step($stepid);
				if ($i > 0) {
					$allcounter++;
					my $stepname;
					(exists($SESSION{'WLANG'})) && ($stepname = $CWFO->get_tag_content_with_attribut ('STEP','NAME','language',$SESSION{'WLANG'},$i));
					(($stepname < 0) || (! defined($stepname))) && ($stepname = $CWFO->get_tag_content ('STEP','NAME',$i,0));
					($stepname < 0) && ($stepname = &translate('Schritt',$lang).' '.$allcounter);
					$stepid = $CWFO->get_tag_attribut_value ('STEP','STEP','id',$i,0);
					print '<table width="100%" border="0" cellpadding="0" cellspacing="0"><tr><td width="1%">';
					if ($SESSION{'WSTEPID'} != $stepid) {
						print '<a HREF="site_step.cgi?stepid='.$stepid.$URLADD.'" class="nor10">';
	     		                        ($userlevel == 1) && print '<img src="images/cwf_step_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.ucfirst($stepname).'">';
	          		                ($userlevel == 2) && print '<img src="images/cwf_step_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.ucfirst($stepname).'">';
						($SESSION{'WSTEPID'} != $stepid) && (print '</a>');
						($foundact == 0) && ($stepnr++);
					} else {
	     		                        ($userlevel == 1) && print '<img src="images/cwf_step_current_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.ucfirst($stepname).'">';
	          		                ($userlevel == 2) && print '<img src="images/cwf_step_current_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.ucfirst($stepname).'">';
						$foundact = 1;
						$stepnr++;
					}
					print '</td><td id="nor">';
					($SESSION{'WSTEPID'} != $stepid) && (print '<a HREF="site_step.cgi?stepid='.$stepid.$URLADD.'" class="nor10">');
            		                print ucfirst($stepname);
					($SESSION{'WSTEPID'} != $stepid) && (print '</a>');
					print '</td></tr></table>';
				}
				#($i > 0) && ($stepid = $CWFO->get_tag_attribut_value ('STEP','STEP','id',$i,0)) && (print $stepid.$nl);
			 } until ($i == 0);
                         print '
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>';
              }
            print '</table>
          </td>
        </tr>
      </table><br>';

1;




