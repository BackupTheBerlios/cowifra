

sub mygmtime {                                                                  # Create expired date for cookies 
	my ($etime) = @_;
	my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
	my @days = ("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
	my ($sec,$min,$hr,$mday,$mon,$yr,$wday,$yday,$isdst) = gmtime($etime);
        # format must be Wed, DD-Mon-YYYY HH:MM:SS GMT
	my $timestr = sprintf("%3s, %02d-%3s-%4d %02d:%02d:%02d GMT",
	$days[$wday],$mday,$months[$mon],$yr+1900,$hr,$min,$sec);
	return $timestr;
}

1;
