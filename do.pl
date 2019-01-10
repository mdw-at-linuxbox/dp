#!/usr/bin/perl

#
# dump object
#

use common::sense;
use Clone qw(clone);
use Encode qw/encode decode/; 

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
		$r->{id} = $id;
		$r->{data} = substr($c, 16, $z);
	} elsif ($x == TXT) {
		$r->{address} = $y;
		$r->{id} = $id;
		$r->{data} = substr($c, 16, $z);
	} elsif ($x == RLD) {
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

my %sdnames = (
0 => "SD",
1 => "LD",
2 => "ER",
3 => "LR",
4 => "PC",
5 => "CM",
6 => "PR",
10 => "WX",
);
my %rlnames = (
0 => "A",
1 => "V",
2 => "PR",
3 => "CL",
);

sub print_record
{
	my ($r) = @_;
	if ($r->{type} == ESD) {
		my $d = $r->{data};
		my ($id) = $r->{id};
		my $q = "ESD";
		while ($d ne "") {
			my ($thisid);
			if (length($d < 16)) {
				$d .= chr(64) x (16-length($d));
			}
			my ($name, $aa, $n) = unpack("a8NN", $d);
			my ($type, $alignment);
			$type = ($aa >> 24);
			$aa &= 0xffffff;
			$alignment = ($n >> 24);
			$n &= 0xffffff;
			if ($name ne (chr(64)x8)) {
				$name = decode("posix-bc", $name);
				$name =~ s%  *$%%;
			} else {
				$name = "";
			}
			if ($type != 1) {
				$thisid = $id;
				++$id;
			} else {
				$thisid = "";
			}
			my ($typname) = $sdnames{$type};
			$typname = sprintf "id=%02d", $type if !defined($typname);
			my $idstr = sprintf "id=%04x", $thisid;
			if (!defined($thisid)) {
				$idstr = ' ' x length($idstr);
			}
			my $locstr = sprintf "%08x", $aa;
			$locstr = "" if ($aa eq 0x404040);
			my $lenstr = sprintf "%08x", $n;
			$lenstr = "" if ($aa eq 0x404040);
			printf "%3s %s LOC=%s LEN=%s TYPE=%s NAME=%s\n",
				$q,
				$idstr,
				$locstr,
				$lenstr,
				$typname,
				$name;
			$q = "";
		} continue {
			$d = substr($d, 16);
		}
	} elsif ($r->{type} == TXT) {
		my $o = 0;
		my $c;
		while ($o < length($r->{data})) {
			$c = length($r->{data})-$o;
			$c = 24 if $c > 24;
			if (!$o) {
				printf "TEXT %04x %06x ",
					$r->{id},
					$r->{address},
			} else {
				printf "          %06x ",
					$r->{address} + $o;
			}
			print unpack("H*", substr($r->{data}, $o, $c))."\n";
		} continue {
			$o += $c;
		}
	} elsif ($r->{type} == RLD) {
		my $d = $r->{data};
		my ($xr, $xp, $lf, $q);
		$q = "RLD";
		$lf = 0;
		while ($d ne "") {
			if (!($lf & 1)) {
				($xr, $xp) = unpack("nn", $d);
				$d = substr($d, 4);
			}
			my $aa = unpack("N", $d);
			$d = substr($d, 4);
			$lf = ($aa >> 24);
			$aa &= 0xffffff;
			my ($len, $type, $sign, $tyname);
			$len = 1+((($lf) & 12) >> 2);
			$sign = ($lf & 2) ? "-" : "+";
			$type = $lf >> 4;
			$tyname = $rlnames{$type};
			$tyname = sprintf "%x", $type if !defined($tyname);
			printf "%-03s R=%04x P=%04x LOC=%06x LEN=%d TYPE=%s SIGN=%s\n",
				$q, $xr, $xp, $aa, $len, $tyname, $sign;
			$q = "";
		}
	} elsif ($r->{type} == END) {
		printf "END %04x %06x\n",
			$r->{id},
			$r->{address};
	} else {
		printf STDERR "Program error -- record type %#lx found!\n",
			$r->{type};
		die "Cannot continue\n";
	}
}

sub process
{
	local $/ = \$physrecl;
	my @r;
	while (<>) {
		my $r = digest_record($_);
		push @r, $r;
	}
	for my $r ( @r ) {
		print_record($r);
	}
}

@ARGV = process_opts(@ARGV);
process(@ARGV);
exit(0);
