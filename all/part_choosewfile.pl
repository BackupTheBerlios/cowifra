      print '<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'>
        <tr>
          <td>
            <table width="100%" border="0" cellpadding="2" cellspacing="0">
              <tr>
                <td '.$table_header.' id="wht">';
                  print '&nbsp;&nbsp; '.&translate("Verf&uuml;gbare Wizards",$lang);
                  print '
                </td>
              </tr>
              <tr>
                <td '.$table_body.'>
                  <table border="0" width="100%" align="center" cellpadding="1" cellspacing="5">
                    <tr>
                      <td id="nor" nowrap>';
                        my $counter = 0;
                        foreach my $filename (glob("wizards/*.cwf")) {
                          my @filedata = split /(\.)/,$filename;
                          my $fname = substr($filedata[0], 8);
                          print '<a HREF="site_startwizard.cgi?wfile='.&myuri_escape($filedata[0]).$URLADD.'" class="nor10">';
                          ($userlevel == 1) && print '<img src="images/cwf_icon_50x50.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.ucfirst($filedata[0]).'">';
                          ($userlevel == 2) && print '<img src="images/cwf_icon_25x25.gif" align="absmiddle" border="0" hspace="5" vspace="5" alt="'.ucfirst($filedata[0]).'">';
                          print ucfirst($fname).'</a>'.$nl;
                          $counter++;
                        }
                         ($counter == 0) && (print &translate("Kein Wizard verf&uuml;gbar (s. Hilfe f&uuml;r mehr Information)",$lang));
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

1;
