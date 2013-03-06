#!/usr/bin/perl

use Data::Dumper;


sub loadchips 
{
	my @iclist;
	open (qw(data), "datafile") or die "No data";
	while (!eof(data)) {
		my $input = <data>;
		my @fields = split( /[\ \t]+/, $input, 7);
		chomp $input;
		my $tags = $fields[5];
		my @splittags = split(/,/, lc( $tags));
		my $sanity=@splittags;
		my $hs = {
		    PART => $fields[0],
		    QUANTITY => $fields[1],
		    PINOUT => $fields[2],
		    LOCATION => $fields[3],
		    SERIES => $fields[4],
		    COMMENT => $fields[6]};
		unshift(@splittags, lc($fields[4]));
		
		@{$hs->{'TAGS'}} = @splittags; 

		push(@iclist, $hs);

	}

	return @iclist;
}


sub generate_one_drawer {
	my ($rows_r, $columns_r, $name) = @_;

	my @rows = @$rows_r;
	my @columns = @$columns_r;
	my @result = ();
	foreach $r (@rows) {
		foreach $c (@columns) {
			push(@result, "$name$c$r");
		}
	}
	return @result;
}


sub generate_spaces
{
	my @drawers=("Z", "Y", "X", "U", "W", "V", "Q");
	my @smallrows = ("A", "B", "C", "D");
	my @smallcolumns= ("1", "2", "3", "4");
	my @rows = ("A", "B", "C", "D", "E", "F");
	my @columns = ("1", "2", "3", "4", "5");
	my @hugecolumns= ("1", "2", "3", "4", "5", "6", "7", "8");
	my @hugerows= ("A", "B", "C", "D", "E", "F", "G", "H");
	my @giantrows=("A", "B", "C", "D", "E", "F", "G", "H", "I", "J");
	my @giantcolumns = ("1", "2", "3", "4", "5", "6");



	my @res = ();

	push(@res, generate_one_drawer(\@smallrows, \@smallcolumns, "X"));
	push(@res, generate_one_drawer(\@smallrows, \@smallcolumns, "Y"));
	push(@res, generate_one_drawer(\@giantrows, \@giantcolumns, "Z"));
	push(@res, generate_one_drawer(\@smallrows, \@smallcolumns, "W"));
	push(@res, generate_one_drawer(\@rows, \@columns, "U"));
	push(@res, generate_one_drawer(\@rows, \@columns, "V"));
	push(@res, generate_one_drawer(\@hugerows, \@hugecolumns, "Q"));
    	return @res;
	@res = ();
	print "XXX";

	foreach $a  (@drawers) {
		foreach $b (@rows) {
			foreach $c (@columns) {
				push(@res, "$a$c$b");
			}
		}
	}
	return @res;
}


sub filter_parts {
	my ($filter, @parts) = @_;

	my @res = ();

	foreach $chip (@parts) {
		my @tags;
		@tags = @{$chip->{'TAGS'}};
		my $good = 0;
		foreach $t (@tags) {
			if ($t eq $filter) {
				$good = 1;
				break;
			}
		}
		if ($good) {
			push(@res, $chip);
		}
	}
	return @res;
}




sub convert_to_table
{
	my (@icl)  = @_;
	@spaces = generate_spaces();

	my $ref = {};

	foreach $s (@spaces) {
		$ref->{$s} = [];
	}

	foreach $chip (@icl) {
		$loc = $chip->{'LOCATION'};
		@x = @{$ref->{$loc}};
		push(@x, $chip);
		@{$ref->{$loc}} = @x;
	}
	return $ref;
}

sub sort_by_location($$)
{
	my $ha = $_[0];
	my $hb = $_[1];

	my @alist = @{$ha->{'TAGS'}};
	my @blist = @{$hb->{'TAGS'}};

	my $count = scalar(@alist);
	for($i = 0; $i < $count; $i++) {
		my $at = $alist[$i];
		my $bt = $blist[$i];
		my $r = $at cmp $bt;
		if ($r) {
			return $r;

		}
	}
	return 0;
}


sub sort_for_row_display
{
	my (@icl) = @_;
	@sr = sort (sort_by_location @icl);
#	print @icl;
	return @sr;
}


sub get_color_mapping{

	my $hs = {
		DAC => "#008000",
		INTER => "#00ff00",
		LOGIC => "#f08000",
		POWER => "#ffff00",
		SENSOR => "#800000",
		LINEAR  => "#00F0F0",
		UC => "#ff0000",
		OSC => "#0000ff",
		ADC => "#800080",
		REG => "#008080",
		OPAMP => "#ff00ff",
		CONN=> "#a0a0a0",
		JFET => "#a0a0a0",
		DIODE => "#a0a0a0",
		NPN => "#a0a0a0",
		PNP => "#a0a0a0",
		MOSFET => "#a0a0a0",
		DESC =>  "#a0a0a0"
	};
# 80800; 00ffff; bba880; 
	return $hs;



}

sub get_color
{
	my ($type) = @_;
	my $hs = get_color_mapping();
	$c = $hs->{$type};

	return $c;
}



	
return 1;
