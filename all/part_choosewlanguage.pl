
      my $languagecounter = $CWFO->count_tag_appearance ("HEADER","LANGDEF",1);
      my %wlanguages;
      if ($languagecounter == 1) {								# at least one language is defined, therefore we do not need to scan the hole file for languages
	return 1;
      } elsif ($languagecounter == 0) {								# no language is defined in header, we need to scan the hole file for available languages
	my $stepscounter = $CWFO->count_section_appearence("STEP");
        my $i = 0;
        my $stepid = 0;
	my $countlang = 0;
        do {
 	  $i = $CWFO->get_next_step($stepid);
	  if ($i > 0) {
	    my $stepname = $CWFO->get_tag_content ('STEP','NAME',$i,0);
	    $stepid = $CWFO->get_tag_attribut_value ('STEP','STEP','id',$i,0);
            my $languagecounter = $CWFO->count_tag_appearance ("STEP","NAME",$i);
	    for ($j=0;$j<$languagecounter;$j++) {
	    	my $awlang = $CWFO->get_tag_attribut_value ('STEP','NAME','language',$i,$j);
		if (($awlang > -1) && (length($awlang) > 0)) {
			$wlanguages{$awlang} = $awlang;	
			$countlang++;
		} 
	    }
  	  }
        } until ($i == 0);	
	($countlang == 0) && (return 1);							# no language things are defined
      } else {											# more then one language is defined in HEADER
	for ($i=0; $i<$languagecounter;$i++) {
		$wlanguages{$CWFO->get_tag_attribut_value ("HEADER","LANGDEF","id",1,$i)} = $CWFO->get_tag_content_with_attribut("HEADER","LANGDEF","id",$CWFO->get_tag_attribut_value ("HEADER","LANGDEF","id",1,$i),1,$i);	# make a hash from available language definition (id => name)
	}
      }

      if (! $SESSION{'WLANG'}) {								# if no wizard language is selected, take the first found
        my $first;
        foreach $key (sort(keys(%wlanguages))) {
          (! defined($first)) && ($first = $key);
        }
        $SESSION{'WLANG'} = $first;
      }
      print '<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'>
        <tr>
          <td>
            <table width="100%" border="0" cellpadding="2" cellspacing="0">
              <tr>
                <td '.$table_header.' id="wht">';
                  print '<a href="'.$SELFNAME.'.cgi?togglewlang=1'.$URLADD.'"><img src="images/bullet_11x11.gif" align="absmiddle" border="0" alt="'.&translate("Verf&uuml;gbare Wizard Sprachen anzeigen",$lang).'"></a> '.&translate("Verf&uuml;gbare Wizard Sprachen",$lang);
                print '</td>
              </tr>';
	      if ($SESSION{'SWLANG'} != 1) { 
              print '<tr>
                <td '.$table_body.'>
                  <table border="0" width="100%" align="center" cellpadding="1" cellspacing="5">
                    <tr>
                      <td id="nor" nowrap>';
			my $counter = 0;
		  	foreach $key (sort(keys(%wlanguages))) {
			  if ((! $SESSION{'WLANG'}) || ($SESSION{'WLANG'} ne $key)) {
  			    print '<a HREF="'.$SELFNAME.'.cgi?wlang='.$key.$URLADD.'" class="nor10">';
	                    ($userlevel == 1) && print '<img src="images/cwf_lang_all_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Sprache",$lang).': '.ucfirst($wlanguages{$key}).'">';
     	                    ($userlevel == 2) && print '<img src="images/cwf_lang_all_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Sprache",$lang).': '.ucfirst($wlanguages{$key}).'">';
                            print ucfirst($wlanguages{$key}).'</a>'.$nl;
     	                  } else {
	                    ($userlevel == 1) && print '<img src="images/cwf_lang_all_sel_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Sprache",$lang).': '.ucfirst($wlanguages{$key}).'">';
     	                    ($userlevel == 2) && print '<img src="images/cwf_lang_all_sel_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.&translate("Sprache",$lang).': '.ucfirst($wlanguages{$key}).'">';
                            print ucfirst($wlanguages{$key}).$nl;
			  }
			  $counter++;
  		        }
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

