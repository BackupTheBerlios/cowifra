
  print '
<table width="100%" border="0" cellpadding="0" cellspacing="10">
  <tr>
    <td>
      <table width="100%" border="0" cellpadding="1" cellspacing="0" '.$table_header.'>
        <tr>
          <td>
            <table width="100%" border="0" cellpadding="2" cellspacing="0">
              <tr>
                <td '.$table_body.'>
                  <table border="0" width="100%" align="center" cellpadding="1" cellspacing="0">
                    <tr>
                      <td colspan="2" align="center" id="norbold">';
                        print '(C) 2003-2004 <a href="http://www.berlios.de" target="_blank" class="nor10">Berlios.de</a> / By C. Schmidt
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table><br><br>
    </td>
  </tr>
</table>';

open(SESSIONFILE, ">sessiondata/".$sessionid.".ses"); 
print SESSIONFILE "LANG=".$lang."\n";
print SESSIONFILE "ULEVEL=".$userlevel."\n";
($SESSION{'WFILE'}) && ($SELFNAME ne "index") && print SESSIONFILE "WFILE=".$SESSION{'WFILE'}."\n";
($SESSION{'WLANG'}) && ($SELFNAME ne "index") && print SESSIONFILE "WLANG=".$SESSION{'WLANG'}."\n";
($SESSION{'SMAIN'}) && print SESSIONFILE "SMAIN=".$SESSION{'SMAIN'}."\n";
($SESSION{'SWLANG'}) && ($SELFNAME ne "index") && print SESSIONFILE "SWLANG=".$SESSION{'SWLANG'}."\n";
($SESSION{'SWSTEPS'}) && ($SELFNAME ne "index") && print SESSIONFILE "SWSTEPS=".$SESSION{'SWSTEPS'}."\n";
($SESSION{'SWCLEANUP'}) && ($SELFNAME ne "index") && print SESSIONFILE "SWCLEANUP=".$SESSION{'SWCLEANUP'}."\n";
($SESSION{'WCONFFILE'}) && ($SELFNAME ne "index") && print SESSIONFILE "WCONFFILE=".$SESSION{'WCONFFILE'}."\n";
($SESSION{'WCONFPATH'}) && ($SELFNAME ne "index") && print SESSIONFILE "WCONFPATH=".$SESSION{'WCONFPATH'}."\n";
($SESSION{'WSTEPID'}) && ($SELFNAME ne "index") && ($SELFNAME ne "site_startwizard") && print SESSIONFILE "WSTEPID=".$SESSION{'WSTEPID'}."\n";
($SESSION{'WSKILLID'}) && ($SELFNAME ne "index") && ($SELFNAME ne "site_startwizard") && print SESSIONFILE "WSKILLID=".$SESSION{'WSKILLID'}."\n";
($SESSION{'WGROUPID'}) && ($SELFNAME ne "index") && ($SELFNAME ne "site_startwizard") && print SESSIONFILE "WGROUPID=".$SESSION{'WGROUPID'}."\n";
close (SESSIONFILE);

if (defined($CWFO)) {
  if ($CWFO->is_error()) {
	print $CWFO->get_error_msg();
  }
}

  print '</body>
</html>';

print '<!-- '.$sessionid.' //-->';

1;




