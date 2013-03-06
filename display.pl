#!/usr/bin/perl

use CGI;
use Data::Dumper;

require "base.pl";
sub display_colorness{
	$hs = get_color_mapping();


	start_table();
    	while ( my ($key, $value) = each(%$hs) ) {
		start_column($value);
		print "$key";
		stop_column();
	}
	end_table();
}

sub render_location_link {
	($loc) =  @_;
	print "<a href = 'display.pl?mode=grid&blink=$loc'> $loc</a>";
}

sub render_part_link {
	($part) = @_;
	print "<b><a href='http://www.google.com/search?hl=en&source=hp&biw=&bih=&q=$part&btnI=I%27m+Feeling+Lucky'> $part</a> &nbsp&nbsp</b>";
}
sub display_rows{
	my (@input) = @_;
	@iclist = sort_for_row_display(@input);
	print "<table frame='border' border='5' rules='all' bgcolor='#bbbee0'>";
	my $alltags = {};
	foreach $i (@iclist){
		$part = $i->{'PART'};
		$location = $i->{'LOCATION'};
		$comments = $i->{'COMMENT'};
		@tags = @{$i->{'TAGS'}};
		foreach $t (@tags){
			$alltags->{$t}++;;
		}
		$color = get_color($i->{'SERIES'});
		
		print "<tr bgcolor='$color'><td>";
		render_part_link($part);
		print "</td><td>";
		render_location_link($location);

		print "</td><td>@tags</td><td>$comments</td></tr>";
	}	
	print "</table>";
	print "<hr>";
	@tl = keys(%$alltags);
	display_filters(\@filters,$alltags);

	print "<br><hr>";

}

sub display_filters {
	my ($param_filters, $part_filters) = @_;

	@param_fa = @$param_filters;
	@part_fa = keys(%$part_filters);
	if (@param_fs) {
		$filter_base = join(",", @param_fa) . ",";
	} else {
		$filter_base = "";
	}

	@part_fa = sort { $part_filters->{$b} - $part_filters->{$a}}  @part_fa;
	foreach $p (@part_fa) {
		$filter_arg = $filter_base ."$p";
		$count = $part_filters->{$p};
		$fs = log($count)/log(2) * 1.5;
		print "<font style='arial' size='$fs'> <a href='display.pl?filters=$filter_arg'> $p($count) </a> &nbsp&nbsp&nbsp</font>";
	}
}


sub display_table{
	my ($blinkme, $t_data, @t_places) = @_;
	start_table();
	foreach $p (@t_places)
	{
		$drawer = substr($p, 0, 1);
		$column = substr($p, 1, 1);
		$row = substr($p, 2, 1);
		@stuffhere = @{$t_data->{$p}};

		if ($drawer ne $lastdrawer) {
			print "</td> </tr> </table><hr>";
			start_table();
		} elsif ($row ne $lastrow) {
			new_row();
		} elsif ($column ne $lastcolumn){
		}
		if ($p eq $blinkme) {
			start_column("#ffffff");
		}elsif (@stuffhere) {
			$firstpart = $stuffhere[0];
			$color = get_color($firstpart->{'SERIES'});
			start_column($color);
		} else {
			start_column("#555555");
		}
		print "<div style='text-align:center'><font size='-1' color='#000000'>$p</font></div>";

		foreach $s (@stuffhere)
		{
			$chip = $s->{'PART'};
			render_part_link($chip);
#			print "<b>$chip</b> ";

			@tags = @{$s->{'TAGS'}};
			print "<font size='-1'>";
			foreach $t (@tags) {
				print "$t ";
			}
			print "</font><br>";
		}
		print "\n";
		stop_column();
		$lastrow = $row;
		$lastdrawer = $drawer;
		$lastcolumn = $column;
	}
	end_table();
}

sub start_table
{
print "<table frame='border' border='5' rules='all' bgcolor='#bbbee0'>";
print "<TR>";
}

sub end_table {
	print "</tr><table>";
}
sub new_row {
	print "</td></tr><tr>";
}
sub stop_column{
	print "</td>";
}
sub start_column{
	my ($color) = @_;
	print "<td  style='vertical-align:top' width=250 height=100 bgcolor='$color'>";
}
#print "</td></tr></table>";

print "Content-Type: Text/html\r\n\r\n";

print "<html><body style='font-family:arial' alink='#0000000' vlink='#000000' link='000000'>";


$cgi = new CGI;
$rawfilters = $cgi->param("filters");

$blinkthisrow = $cgi->param("blink");

@filters=split(/,/,$rawfilters);


print "You are searching with these filters: @filters<br>\n";
print "<a href='display.pl?mode=grid'> grid mode</a><br>\n";
print "<a href='display.pl?mode=list'> list mode</a><br>\n";



@p = loadchips();

for $f (@filters) {
	@p = filter_parts($f, @p);
}


@g = generate_spaces();
$c = convert_to_table(@p);


display_colorness();

if ($cgi->param("mode") eq "grid") {
	display_table($blinkthisrow, $c, @g);
} else {
	display_rows(@p);
}



print "</body></html>";
