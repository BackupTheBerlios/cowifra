
      print '
      <table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'>
        <tr>
          <td>
            <table width="100%" border="0" cellpadding="2" cellspacing="0">
              <tr>
                <td '.$table_header.' id="whtsmli">';
                  print '<a href="'.$SELFNAME.'.cgi?togglemain=1'.$URLADD.'"><img src="images/';
                  if ($SESSION{'SMAIN'} != 1) {
                  	print 'minimize.gif';
                  } else {
                  	print 'maximize.gif';
                  }
                  print '" width="5" align="absmiddle" border="0" alt="'.&translate('Hauptmen&uuml;anzeige an/aus',$lang).'"></a> CWF '.&translate("Hauptmen&uuml;",$lang);
                  print '
                </td>
              </tr>';
				my %languages;
				my $langparamname;
				my %wlanguages;				
				if ($SELFNAME eq "index") {
					$languages{'de'} = "de";
					$languages{'uk'} = "uk";
					$languages{'fr'} = 0;
					$languages{'es'} = 0;
					$languages{'it'} = 0;
					$langparamname = "ULANG";
				} else { # We are not on the index.cgi site, therefore we show only available wizard languages
					$languages{'de'} = 0;
					$languages{'uk'} = 0;
					$languages{'fr'} = 0;
					$languages{'es'} = 0;
					$languages{'it'} = 0;				
					my $languagecounter = $CWFO->count_tag_appearance ("HEADER","LANGDEF",1);
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
										#print $awlang." = awlang<br>";	
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
					$langparamname = "wlang";
				}
	      if ($SESSION{'SMAIN'} != 1) {
                print '<tr>
                  		 <td '.$table_body.'><table border="0" width="1%" cellpadding="1" cellspacing="0">';
               	my @langkeys = keys(%languages);
               	@langkeys = sort(@langkeys);
               	#print @langkeys."<br>";
               	foreach $onelang (@langkeys) {
                	if ($langparamname eq "wlang") {	# the wizard languages have to be displayed
                	  my $foundlang = 0;
                	  while (my ($key, $value) = each(%wlanguages)) {
                	    #print "Key: ".$key." Onelang: ".$onelang."<br>";
                	  	(uc($key) eq uc($onelang)) && ($languages{$onelang} = $key) && ($foundlang = 1); # && (print "FOUND ".$key."<br>");
                	  	
                	  }
                	  if ($foundlang == 1) {
                	  	undef($wlanguages{$onelang});
                	  }
                  }
                } 
                
                my $languagecount = 0;
                if (($userlevel == 1) || ($userlevel == 2)) {
                	print '<tr>
                         <td nowrap>&nbsp;&nbsp;&nbsp;</td>
                         <td id="nor" align="center"><a href="index.cgi?1=1'.$URLADD.'">';
                	($userlevel == 1) && print '<img src="images/cwf_home_50x50.gif" border="0" alt="'.&translate ("Zur&uuml;ck zum Hauptmen&uuml;", $lang).'">';
                	($userlevel == 2) && print '<img src="images/cwf_home_25x25.gif" border="0" alt="'.&translate ("Zur&uuml;ck zum Hauptmen&uuml;", $lang).'">';
                	print '</a></td>';
                	print '<td nowrap>&nbsp;&nbsp;&nbsp;</td>
                	    	 <td id="nor" align="center"><a href="help.cgi?site='.$SELFNAME.$URLADD.'" target="_blank">';
                	($userlevel == 1) && print '<img src="images/cwf_help_50x50.gif" border="0" alt="'.&translate ("Online Hilfe", $lang).'">';
                	($userlevel == 2) && print '<img src="images/cwf_help_25x25.gif" border="0" alt="'.&translate ("Online Hilfe", $lang).'">';
                	print '</a></td>';
                	print '<td nowrap>&nbsp;&nbsp;&nbsp;</td>
                	       <td id="nor" align="center"><a href="'.$SELFNAME.'.cgi?ULEVEL=1'.$URLADD.'" title="'.&translate ("Alle Icons gross", $lang).'">';
                	($userlevel == 1) && print '<img src="images/cwf_level_1_50x50.gif" border="0" alt="'.&translate ("Alle Icons gross", $lang).'">';
                	($userlevel == 2) && print '<img src="images/cwf_level_1_25x25.gif" border="0" alt="'.&translate ("Alle Icons gross", $lang).'">';
                	print '</a></td>';                      
                	print '<td nowrap>&nbsp;&nbsp;&nbsp;</td>
                	       <td id="nor" align="center"><a href="'.$SELFNAME.'.cgi?ULEVEL=2'.$URLADD.'" title="'.&translate ("Alle Icons klein", $lang).'">';
                	($userlevel == 1) && print '<img src="images/cwf_level_2_50x50.gif" border="0" alt="'.&translate ("Alle Icons klein", $lang).'">';
                	($userlevel == 2) && print '<img src="images/cwf_level_2_25x25.gif" border="0" alt="'.&translate ("Alle Icons klein", $lang).'">';
                	print '</a></td>';    
                	print '<td nowrap>&nbsp;&nbsp;&nbsp;</td>
                	       <td id="nor" align="center"><a href="'.$SELFNAME.'.cgi?ULEVEL=3'.$URLADD.'" title="'.&translate ("Keine Icons", $lang).'">';
                	($userlevel == 1) && print '<img src="images/cwf_level_3_50x50.gif" border="0" alt="'.&translate ("Keine Icons", $lang).'">';
                	($userlevel == 2) && print '<img src="images/cwf_level_3_25x25.gif" border="0" alt="'.&translate ("Keine Icons", $lang).'">';
                	print '</a></td>';
                }
               	my @langkeys = keys(%languages);
               	@langkeys = sort(@langkeys);
               	($userlevel != 3) && (print '<td>&nbsp;</td><td>&nbsp;</td>');
               	foreach $onelang (@langkeys) {
               		#print '<td nowrap>&nbsp;&nbsp;&nbsp;</td>';
              	  if ($languages{$onelang} ne "0") {
              	  	$languagecount = $languagecount+1;
              	  	if ($userlevel != 3) {
	              	    print '<td>&nbsp;</td>';
		             	  	($userlevel == 1) && print '<td id="nor" align="center"><a href="'.$SELFNAME.'.cgi?'.$langparamname.'='.$languages{$onelang}.$URLADD.'"><img src="images/flags/'.$onelang.'_50x50.gif" border="0" alt="'.&translate ("Sprache", $lang).' '.$onelang.'"></a></td>';
	              	  	($userlevel == 2) && print '<td id="nor" align="center"><a href="'.$SELFNAME.'.cgi?'.$langparamname.'='.$languages{$onelang}.$URLADD.'"><img src="images/flags/'.$onelang.'_25x25.gif" border="0" alt="'.&translate ("Sprache", $lang).' '.$onelang.'"></a></td>';
	              	  }
              	  	#print '</a>';
              	  } #else {
              	  	#($userlevel == 1) && print '<img src="images/flags/'.$onelang.'_50x50g.gif" border="0" alt="'.&translate ("Sprache", $lang).' '.$onelang.'">';
              	    #($userlevel == 2) && print '<img src="images/flags/'.$onelang.'_25x25g.gif" border="0" alt="'.&translate ("Sprache", $lang).' '.$onelang.'">';
              	  #}
								}     
								
								$coutput = "<td>&nbsp;</td>";
								#if ($userlevel == 3) {
								#	$coutput .= '<tr><td colspan="'.(12+$languagecount).'">&nbsp;</td>';
								#}
								if ($langparamname eq "wlang") { #Show all unmatched languages
                	my @langkeys2 = keys(%wlanguages);
                	@langkeys2 = sort(@langkeys2);
                	my $lcount = 0;
                	foreach $onelang (@langkeys2) {
                		if (defined ($wlanguages{$onelang})) { $lcount++; }
                	}
                	if ($lcount > 0) {
                		$coutput .= '<form action="'.$SELFNAME.'.cgi?1=1'.$URLADD.'" method="post" name="sprache">'."\n";
                		$coutput .= '<td nowrap id="sml">';
                		$coutput .= &translate("Sprache",$lang).': <select name="'.$langparamname.'" onChange="submit();">';
	               		foreach $onelang (@langkeys2) {
	               			if (defined ($wlanguages{$onelang})) {
	               				$coutput .= '<option value="'.$onelang.'"';
	               				($SESSION{'WLANG'} eq $onelang) && ($coutput .= " selected ");
	               				$coutput .= '>'.$onelang.'</option>';
			             			#print '<td nowrap>&nbsp;&nbsp;&nbsp;</td>
			             		  #       <td id="nor" align="center">';
		             		  	#print '<a href="'.$SELFNAME.'.cgi?'.$langparamname.'='.$wlanguages{$onelang}.$URLADD.'">';
		             		  	#($userlevel == 1) && print '<img src="images/flags/empty_50x50.gif" border="0" alt="'.&translate ("Sprache", $lang).' '.$onelang.'">';
		             		  	#($userlevel == 2) && print '<img src="images/flags/empty_25x25.gif" border="0" alt="'.&translate ("Sprache", $lang).' '.$onelang.'">';
		             		  	#print '</a>';
			             		  #print "</td>\n";
			             	  }
										}
										$coutput .= "</select><input type=submit name=senden value=\"".&translate ("Senden", $lang)."\">\n";
										$coutput .= "</td>\n";
										$coutput .= "</form>";
										if ($userlevel != 3) {
											print $coutput;
										}
									}
									
								}
                print '</tr>';
        				#}
        				if (($userlevel == 1) || ($userlevel == 3)) {
        					print '<tr>
											   <td>&nbsp;</td>
											   <td align="center"><a href="index.cgi?1=1'.$URLADD.'" class="nor8">'.&translate("Startseite",$lang).'</td></td>
											   <td>&nbsp;</td>
											   <td align="center"><a href="help.cgi?site='.$SELFNAME.$URLADD.'" target="_blank" class="nor8">'.&translate("Hilfe",$lang).'</td></td>
											   <td>&nbsp;</td>
											   <td align="center" nowrap><a href="'.$SELFNAME.'.cgi?ULEVEL=1'.$URLADD.'" class="nor8">'.&translate("Anf&auml;nger",$lang).'</a></td>
											   <td>&nbsp;</td>
											   <td align="center" nowrap><a href="'.$SELFNAME.'.cgi?ULEVEL=2'.$URLADD.'" class="nor8">'.&translate ("Fortgeschr.", $lang).'</a></td>
											   <td>&nbsp;</td>
											   <td align="center" nowrap><a href="'.$SELFNAME.'.cgi?ULEVEL=3'.$URLADD.'" class="nor8">'.&translate ("Profi", $lang).'</a></td>';
                	my @langkeys = keys(%languages);
                	@langkeys = sort(@langkeys);
                	print '<td>&nbsp;</td>';print '<td>&nbsp;</td>';
                	foreach $onelang (@langkeys) {	
										#print '<td>&nbsp;</td>';
										if ($languages{$onelang} ne "0") {
										  print '<td>&nbsp;</td>';
									  	print '<td align="center" nowrap><a href="'.$SELFNAME.'.cgi?'.$langparamname.'='.$languages{$onelang}.$URLADD.'" class="nor8">'.&translate("Sprache",$lang).' '.$onelang.'</a></td>';
									  } #else {
									  	#print '<td align="center" nowrap id="sml">'.&translate("Sprache",$lang).' '.$onelang.'</td>';
									  #}
									}
									if ($userlevel == 3) {
										print $coutput;
									}
									#if ($langparamname eq "wlang") { #Show all unmatched languages
                	#	my @langkeys2 = keys(%wlanguages);
                	#	@langkeys2 = sort(@langkeys2);
                	#	foreach $onelang (@langkeys2) {
                	#		if (defined ($wlanguages{$onelang})) {
                	#		  print '<td>&nbsp;</td>';
									#			print '<td align="center" nowrap><a href="'.$SELFNAME.'.cgi?'.$langparamname.'='.$onelang.$URLADD.'" class="nor8">'.&translate("Sprache",$lang).' '.$onelang.'</a></td>';                			
		              #	  }
									#	}     
									#	
									#}									
          				print '</tr>';
        				}
        				print '</table>
        		  	       </td>
               			   </tr>';
    		}
        print '</table>
          		 </td>
        			 </tr>
      				 </table>';

1;
