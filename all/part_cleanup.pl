
      my $cleanup = 0;
      $cleanup = $CWFO->count_section_appearence("CLEANUP");
      
      ($cleanup == 0) && (return 1);

      print '<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'>
        <tr>
          <td>
            <table width="100%" border="0" cellpadding="2" cellspacing="0">
              <tr>
                <td '.$table_header.' id="wht">';
                  print '<a href="'.$SELFNAME.'.cgi?togglecleanup=1'.$URLADD.'"><img src="images/';
		  if ($SESSION{'SWCLEANUP'} != 1) {
			print 'minimize.gif';
		  } else {
			print 'maximize.gif';
		  }
                  print '" align="absmiddle" border="0" alt='.&translate("Aktionen am Ende der Konfiguration an/aus",$lang).'"></a> '.&translate("Aktionen nach der Konfiguration",$lang);
                  print '
                </td>
              </tr>';
              if ($SESSION{'SWCLEANUP'} != 1) { 
              print '<tr>
                <td '.$table_body.'>
                  <table border="0" width="100%" align="center" cellpadding="1" cellspacing="5">
                    <tr>
                      <td id="nor">';
			 #print $CWFO->get_tag_attributs('STEP','STEP',0,0);
			 my $i = 0;
			 my $cleanid = 0;
			 my $foundact = 0;
			 my $allcounter = 0;

			 print '<table width="100%" border="0" cellpadding="0" cellspacing="0"><tr><td width="1%" valign="top">';
			 print '<a HREF="site_startwizard.cgi?cleanupid=all'.$URLADD.'" class="nor10">';
			 ($userlevel == 1) && print '<img src="images/cwf_cleanup_all_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate('Alle Aktionen ausführen',$lang).'">';
			 ($userlevel == 2) && print '<img src="images/cwf_cleanup_all_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate('Alle Aktionen ausführen',$lang).'">';
			 print '</a>';
			 print '</td><td id="nor">';
			 print '<a HREF="site_startwizard.cgi?cleanupid='.$cleanupid.$URLADD.'" class="nor12">';
			 print &translate('Alle Aktionen ausführen',$lang);
			 print '</a><br><hr>';
			 print '</td></tr></table>';
			 
			 do {
				$i = $CWFO->get_next_exec($i);
				#print $i.": i<br>";
				if ($i > 0) {
					$allcounter++;
					my $cleanname;
					#(exists($SESSION{'WLANG'})) && ($cleanname = $CWFO->get_tag_content_with_two_attributs ('CLEANUP','EXECUTE','language',$SESSION{'WLANG'},'id',$i,1));
					#($cleanname < 0) && (
					$cleanname = $CWFO->get_tag_content_with_attribut ('CLEANUP','EXECUTE','id',$i,1);
					#print $cleanname."--------------------<br>";
					($cleanname < 0) && ($cleanname = &translate('Aktion',$lang).' '.$allcounter);
					$cleanupid = $i;
					print '<table width="100%" border="0" cellpadding="0" cellspacing="0"><tr><td width="1%">';
					print '<a HREF="site_startwizard.cgi?cleanupid='.$cleanupid.$URLADD.'" class="nor10">';
     		                        ($userlevel == 1) && print '<img src="images/cwf_cleanup_one_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.ucfirst($cleanname).'">';
          		                ($userlevel == 2) && print '<img src="images/cwf_cleanup_one_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.ucfirst($cleanname).'">';
					print '</a>';
					print '</td><td id="nor">';
					print '<a HREF="site_startwizard.cgi?cleanupid='.$cleanupid.$URLADD.'" class="nor10">';
            		                print ucfirst($cleanname);
					print '</a>';
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




