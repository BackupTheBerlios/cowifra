      print '<table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'>
        <tr>
          <td>
            <table width="100%" border="0" cellpadding="2" cellspacing="0">
              <tr>
                <td '.$table_header.' id="wht"> &nbsp;&nbsp;&nbsp;';
                  #print '<img src="images/bullet_11x11.gif" align="absmiddle"> ';
                  $msg && print &translate("Information",$lang);
                  $saveerror && print &translate("Fehler",$lang);
                  print '
                </td>
              </tr>
              <tr>
                <td '.$table_body.'>
                  <table border="0" width="100%" align="center" cellpadding="1" cellspacing="5">
                    <tr>
                      <td id="nor">';
                         if ($msg) { print $msg; }
                         if ($saveerror) { print '<span id="norredbold">'.$saveerror.'</span>'; }
                         print '
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table><span id="sml"><br></span>';

1;
