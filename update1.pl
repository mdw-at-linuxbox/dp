#!/usr/bin/perl

use common::sense;

my $ncol = 0;
my $ocol = 9;
my $vcol = 15;
my $ccol = 34;
my $scol = 72;
my $iseqflag;
my $ucflag;

sub process_opts
{
	my @r;
	my $f;
	for my $j ( @_ ) {
		if (defined($f)) {
			&$f($j);
			undef $f;
			next;
		}
#		if ($j eq "-v") {
#			++$kflag;
#			next;
#		}
		if ($j eq "-uc") {
			$ucflag = 1;
			next;
		}
		if ($j eq "-iseq") {
			$iseqflag = 1;
			next;
		}
		if ($j eq "-par") {
			$f = sub {
				my ($f) = @_;
				my @z = split(',', $f);
$ncol = $z[0]-1 if $z[0] ne "";
$ocol = $z[1]-1 if $z[1] ne "";
$vcol = $z[2]-1 if $z[2] ne "";
$ccol = $z[3]-1 if $z[3] ne "";
$scol = $z[4]-1 if $z[4] ne "";
			};
			next;
		}
		push @r, $j;
	}
	return @r;
}

sub eat_operands
{
	my ($l) = @_;
	my ($o, $rest);
	my $pcount = 0;
	my $qflag = 0;
	my $comflag = 0;
	my $c;
#print "SPLITTING $l\n";
	for my $c ( split(//, $l)) {
#print "operand byte: $c\n", $c;
		if ($comflag) {
			$comflag = 2 if $c ne " ";
			$rest .= $c if $comflag == 2;
			next;
		}
		if (!$qflag && $c eq ' ') {
			$comflag = 1;
			next;
		}
		if ($c eq "'") {
			$qflag = !$qflag;
		}
		$c = maybe_uc($c) if !$qflag;
		$o .= $c;
	}
	return ($o, $rest);
}

sub digest_line
{
	my ($l) = @_;
	chomp ($l);
	my ($w, $rest);
	my $r = {};

	$l =~ s/\t/ /g;
	$r->{where} = $.;
	if ($iseqflag) {
		if (length($l) >= $scol) {
			$r->{sequence} = substr($l, $scol);
			$l = substr($l, 0, $scol);
			$l =~ s%  *$%%;
		}
	}
	if ($l =~ /^\*/) {
		$r->{initial_comment} = $l;
		return $r;
	}
	if ($l =~ /^([^ ]*) /) {
		$w = substr($l, $-[1], $+[1]-$-[1]);
		if ($w ne "") {
			$r->{label} = $w;
		}
		$l = substr($l, $+[1]+1);
	} else {
print STDERR "warning: $.: label only?\n";
		$r->{label} = $l;
		return $r;
	}
	$l =~ s%^  *%%;
	if ($l =~ /^([^ ]*) /) {
		$w = substr($l, $-[1], $+[1]-$-[1]);
		$rest = substr($l, $+[1]+1);
	} else {
		$w = $l;
		$rest = undef;
	}
	if ($w ne "") {
		$r->{operation} = $w;
	}
	$rest =~ s%^  *%%;
	($w, $rest) = eat_operands($rest);
	if ($w ne "") {
		$r->{operands} = $w;
	}
	if ($rest ne "") {
		$r->{comment} = $rest;
	}
	return $r;
}

sub maybe_uc
{
	my ($x) = @_;
	if ($ucflag) {
		$x = uc($x);
	}
	return $x;
}

sub translate_operation {
	my ($x) = @_;
	$x = 'CCW0' if $x eq 'CCW';
	return $x;
}

sub format_line
{
	my ($r) = @_;
	my $result = "";
	my $o;
	$o = "";
	if (defined($r->{initial_comment})) {
		$o = $r->{initial_comment};
	} else {
	if (defined($r->{label})) {
		$o .= " " x ($ncol-length($o))
			if length($o) < $ncol;
		$o .= maybe_uc($r->{label});
	}
	if (defined($r->{operation})) {
		my $x = $r->{operation};
		$o .= " " x ($ocol-length($o)-1)
			if length($o) < $ocol-1;
		$x = translate_operation($x);
		$o .= ' '.maybe_uc($x);
	}
	if (defined($r->{operands})) {
		$o .= " " x ($vcol-length($o)-1)
			if length($o) < $vcol-1;
		$o .= ' '.$r->{operands};
	}
	if (defined($r->{comment})) {
		$o .= " " x ($ccol-length($o)-1)
			if length($o) < $ccol-1;
		$o .= ' '.maybe_uc($r->{comment});
	}
	}
	{
		my $seq = $r->{sequence};
		my $rest;
		while (length($o) >= $scol) {
			$rest = substr($o, $scol-1);
			$o = substr($o, 0, $scol-1);
			$result .= $o . 'X' . $seq."\n";
			undef $seq;
			$o = (' ' x 15) . $rest;
		}
		if (defined($seq)) {
			$o .= " " x ($scol-length($o)-1)
				if length($o) < $scol-1;
			$o .= ' '.$seq;
		}
	}
	$o .= "\n";
	$result .= $o;
	return $result;
}

sub process
{
	while (<>) {
		my $r = digest_line($_);
		print format_line($r);
	}
}

@ARGV = process_opts(@ARGV);
process(@ARGV);
exit(0);
