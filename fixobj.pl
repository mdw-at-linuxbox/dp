#!/usr/bin/perl

#
# fixup mz390 weirdnesses.
#
# 1. combine TXT records, pack up to 56 bytes.
# 2. combine RLD records.
# 3. combine ESD records and fix esd item length, always 16.
#

use common::sense;
use Clone qw(clone);

my $lrecl = 72;
my $physrecl = 80;
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
#		if ($j eq "-par") {
#			$f = sub {
#				my ($f) = @_;
#				my @z = split(',', $f);
#$ncol = $z[0]-1 if $z[0] ne "";
#$ocol = $z[1]-1 if $z[1] ne "";
#$vcol = $z[2]-1 if $z[2] ne "";
#$ccol = $z[3]-1 if $z[3] ne "";
#$scol = $z[4]-1 if $z[4] ne "";
#			};
#			next;
#		}
		push @r, $j;
	}
	return @r;
}

use constant {
ESD   => 0x02C5E2C4,
TXT   => 0x02e3e7e3,
RLD   => 0x02d9d3c4,
END   => 0x02c5d5c4,
};
# SYM
# LDT
# REP
# DEF
# ENT
# NCA
# COM
# MDL
# LCS
# MSG
# OPT
# ALI
# LIB
# RIP
# DIR

sub digest_record
{
	my ($c) = @_;
	my ($w, $rest);
	my $r = {};

	if ($physrecl > $lrecl) {
		$r->{sequence} = substr($c, $lrecl, $physrecl - $lrecl);
		$c = substr($c, 0, $lrecl);
	}
	my ($x, $y, $z, $id) = unpack("NNNN", $c);
	$y &= 0xffffff;
	$z &= 0xffff;
	$id &= 0xffff;
	$r->{type} = $x;
	if ($x == ESD) {
		$r->{length} = $z;
		$r->{id} = $id;
		$r->{data} = substr($c, 16, $z);
	} elsif ($x == TXT) {
		$r->{address} = $y;
		$r->{length} = $z;
		$r->{id} = $id;
		$r->{data} = substr($c, 16, $z);
	} elsif ($x == RLD) {
		$r->{length} = $z;
		$r->{data} = substr($c, 16, $z);
	} elsif ($x == END) {
		$r->{address} = $y if $y ne 0x404040;
		$r->{id} = $id if $id ne 0x4040;
		my $epname = substr($c, 16, 8);
		my $s = unpack("N", substr($c, 28, 4));
		$r->{entryname} = $epname if $epname ne (chr(64) x 8);
		$r->{size} = $s if $s ne 0x40404040;
		my $comment = substr($c, 32, 40);
		$r->{comment} = $comment if $comment ne (chr(64) x 40);
	} else {
		printf STDERR "Record type %#lx not understood\n";
		$r->{literal} = $c;
	}
	return $r;
}

sub optimize_records
{
	my ($list) = @_;
}

sub format_record
{
	my ($r) = @_;
	if (defined($r->{literal})) {
		return $r->{literal};
	}
	my $c = pack("N", $r->{type});
	$c .= chr(64) x ($lrecl-4);
	if ($r->{sequence}) {
		$c .= $r->{sequence};
	}
	if (length($c) < $physrecl) {
		$c .= chr(64) x ($physrecl-length($c));
	}
	substr($c, 5,3) = substr(pack("N", $r->{address}),1,3)
		if defined($r->{address});
	substr($c, 10,2) = pack("n", length($r->{data}))
		if defined($r->{data});
	substr($c, 14,2) = pack("n", $r->{id})
		if defined($r->{id});
	substr($c, 16, length($r->{data})) = $r->{data}
		if defined($r->{data});
	if ($r->{type} == ESD) {
	} elsif ($r->{type} == TXT) {
	} elsif ($r->{type} == RLD) {
	} elsif ($r->{type} == END) {
		substr($c, 16, length($r->{entryname}))
			if defined($r->{entryname});
		substr($c,28,4) = pack("N", $r->{size})
			if defined($r->{size});
		substr($c,32,length($r->{comment})) = $r->{comment}
			if defined($r->{comment});
	} else {
		printf STDERR "Program error -- record type %#lx found!\n",
			$r->{type};
		die "Cannot continue\n";
	}
	if (length($c) != $physrecl) {
		printf STDERR "Program error -- made wrong size record %d for %lx\n",
			length($c), $r->{type};
		print STDERR unpack("H*", $c)."\n";
#	print $c;
		die "Cannot continue";
	}
	return $c;
}

sub process
{
	local $/ = \$physrecl;
	my @r;
	while (<>) {
		my $r = digest_record($_);
		push @r, $r;
	}
	optimize_records(\@r);
	for my $r ( @r ) {
		print format_record($r);
	}
}

@ARGV = process_opts(@ARGV);
process(@ARGV);
exit(0);
