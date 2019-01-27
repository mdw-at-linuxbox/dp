#!/usr/bin/perl

#
# fixup mz390 weirdnesses.
#
# 1. combine TXT records, pack up to 56 bytes.
# 2. combine RLD records.
# 3. combine ESD records and fix esd item length, always 16.
# also, for hercules | simh: need patches, so
# 4. if fixups, also insert them as REP records, before RLD|END each section.
#

use common::sense;
use Clone qw(clone);
use Encode qw/encode decode/;

my $lrecl = 72;
my $physrecl = 80;
my $iseqflag;
my $ucflag;

my @fixups;

sub process_opts
{
	my @r;
	my $f;
	for my $j ( @_ ) {
		if (defined($f)) {
			if (!&$f($j)) {
				undef $f;
			}
			next;
		}
#		if ($j eq "-v") {
#			++$kflag;
#			next;
#		}
		if ($j eq "-fix") {
			my ($x, $y) = undef;
			$f = sub {
				my ($a) = @_;
				if (!$x) {
					$x = $a;
					return 1;
				}
				if (defined($x)) {
					$y = create_fixup($x, $a);
					push @fixups, $y;
				}
#				my ($f) = @_;
#				my @z = split(',', $f);
#$ncol = $z[0]-1 if $z[0] ne "";
#$ocol = $z[1]-1 if $z[1] ne "";
#$vcol = $z[2]-1 if $z[2] ne "";
#$ccol = $z[3]-1 if $z[3] ne "";
#$scol = $z[4]-1 if $z[4] ne "";
				return undef;
			};
			next;
		}
		push @r, $j;
	}
	return @r;
}

use constant {
ESD   => 0x02C5E2C4,
TXT   => 0x02e3e7e3,
RLD   => 0x02d9d3c4,
END   => 0x02c5d5c4,
REP   => 0x02d9c5d7,
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

sub delete_junk
{
	my ($list) = @_;
	my ($skipping, $skipcount);
	my @z;

	my $ns;
	for my $r ( @$list ) {
		my $nextskip;
		if ($r->{type} == END)
		{
			$nextskip = 1;
		}
		if ($r->{type} == ESD) {
			$nextskip = 0;
			$skipping = 0;
		}
		push @z, $r if !$skipping;
		++$skipcount if $skipping;
		$skipping = $nextskip;
	}
	printf STDERR "Skipped %d records\n", $skipcount if $skipcount;
	@$list = @z;
}

sub scan_for_missed_fixups
{
	my $r;
	for my $f ( @fixups ) {
		++$r if !$f->{used};
	}
	return $r;
}

sub create_fixup
{
	my ($w, $c) = @_;
	my $r = {};
	my $a;
	if ($w =~ /(.*)([-+].*)/) {
		$a = substr($w, substr($w, $-[1], $+[1]-$-[1]));
		$r->{offset} = 0+substr($w, substr($w, $-[2], $+[2]-$-[2]));
	} else {
		$a = $w;
	}
	$r->{name} = $a;
	$r->{contents} = pack("H*",$c);
	return $r;
}

sub find_fixups
{
	my ($name) = @_;
	my $lname = lc($name);
	my @r;
	for my $f ( @fixups ) {
		if ($f->{name} ne $lname) {
			next;
		}
		push @r, $f;
	}
	return @r;
}

sub gen_rep_card
{
	my ($e, $q) = @_;
	my $r = {};
	$r->{type} = REP;
	$r->{address} = $e->{aa};
	$r->{address} += $q->{offset} if defined($q->{offset});
	$r->{id} = $e->{type} == 1 ? $e->{n} : $e->{id};
	$r->{data} = $q->{contents};
	++ $q->{used};
	return $r;
}

sub fixups_to_rep_cards
{
	my (@symbols) = @_;
	my @r;
	for my $e (@symbols) {
		# only SD and LD
		next unless $e->{type} == 1 || $e->{type} == 2;
		for my $q ( find_fixups($e->{name})) {
			push @r, gen_rep_card($e, $q);
		}
	}
	return @r;
}

sub populate_estbl
{
	my ($estbl, $d, $id) = @_;
	my @r;
	while (length($d) >= 16) {
		my ($name, $aa, $n) = unpack("a8NN", $d);
		my ($type, $alignment);
		$name = decode("posix-bc", $name);
		$name =~ s%  *%%;
		undef $name if ($name eq "");
		$d = substr($d, 16);
		$type = ($aa >> 24);
		$aa &= 0xffffff;
		if ($aa == 0x404040) {
			undef $aa;
		}
		$alignment = ($n >> 24);
		$n &= 0xffffff;
		if ($n eq 0x404040) {
			undef $n;
		}
		my $r = {};
		if ($type != 1) {
			$r->{id} = $id;
			++$id;
		}
		$r->{type} = $type;
		$r->{aa} = $aa if defined($aa);
		$r->{name} = $name if defined($name);
		$r->{alignment} = $alignment;
		$r->{n} = $n if defined($n);
		if (defined($r->{id})) {
			$estbl->{$r->{id}} = $r;
		}
		push @r, $r;
	}
	return @r;
}

sub optimize_records
{
	my ($list) = @_;
	my @z;
	my @symbols;
	my $c;
	my ($outr, $outp, $outfoff);
	my $estbl;
	my $did_fixups;
	delete_junk($list);
	for my $r ( @$list) {
		if ($r->{type} == ESD) {
			$did_fixups = 0;
			$estbl ||= {};
			my $d = $r->{data};
			my $l = length($d);
			if ($l < 16) {
				$d .= chr(64) x (16-$l);
				$l = 16;
			}
			push @symbols, populate_estbl($estbl, $d, $r->{id});
			if (defined($c) && ($c->{type} != ESD
					|| $c->{id} != $r->{id}
					|| length($c->{data})+$l > $lrecl-16
					)) {
				push @z, $c;
				$c = clone($r);
				$c->{data} = $d;
				next;
			}
			if (!defined($c)) {
				$c = clone($r);
				$c->{data} = $d;
			} else {
				$c->{data} .= $d;
			}
			next;
		} elsif ($r->{type} == TXT) {
			my $a = $r->{address};
			my $d = $r->{data};
			my $l = length($d);
			my $count;
			while ($l > 0) {
				if (defined($c) && ($c->{type} != TXT
						|| $c->{id} != $r->{id}
						|| $c->{address} + length($c->{data})
							!= $a
						|| length($c->{data}) >= $lrecl-16
						)) {
					push @z, $c;
					$c = clone($r);
					$c->{address} = $a;
					$c->{data} = "";
				}
				$count = ($lrecl-16) - length($c->{data});
				$count = $l if $count > $l;
				$c->{data} .= substr($d, 0, $count);
			} continue {
				$l -= $count;
				$a += $count;
				$d = substr($d, $count);
			}
			next;
		} elsif ($r->{type} == RLD) {
			my $d = $r->{data};
			my $l = length($d);
			my ($count, $oc);
			my ($inr, $inp, $flags, $aa, $rty, $q, $item);
			my $seq = $r->{sequence};
			$flags = 0;
			while ($l > 0) {
				if (!($flags & 1)) {
					($inr, $inp, $aa) = unpack("nnN", $d);
					$count = 8;
				} else {
					$inr = $outr;
					$inp = $outp;
					($aa) = unpack("N", $d);
					$count = 4;
				}
				$flags = ($aa>>24);
				$aa &= 0xffffff;
				if (!defined($outfoff) || $outr != $inr || $outp != $inp) {
					$oc = 8;
				} else {
					$oc = 4;
				}
				if (defined($c) && ($c->{type} != RLD
						|| length($c->{data})+$oc > $lrecl-16
						)) {
					push @z, $c;
					undef $c;
					push @z, fixups_to_rep_cards(@symbols) if !$did_fixups;
					$did_fixups = 1;
				}
				$flags &= 254;
				$rty = ($flags >> 4);
				if (!$rty) {
					my $q = $estbl->{$inr};
# ref to ER should be V?
					if (defined($q) && $q->{type} == 2) {
						$flags |= (1<<4);
					}
				}
				$q = ($flags << 24) | $aa;
				$item = "";
				$item .= pack("nn", $inr, $inp) if $oc == 8;
				$item .= pack("N", $q);
				if (!defined($c)) {
					$c = {};
					$c->{type} = RLD;
					$c->{sequence} = $seq
						if defined($seq);
					undef $seq;
					undef $outfoff;
					$oc = 8;
				}
				if ($oc == 4) {
					substr($c->{data},$outfoff,1) =
					chr(1 | ord(substr($c->{data},$outfoff,1)));
				}
				$c->{data} .= $item;
				$outfoff = length($c->{data})-4;
				$outr = $inr;
				$outp = $inp;
			} continue {
				$l -= $count;
				$d = substr($d, $count);
			}
			$c->{data} .= $d;
			next;
		} elsif ($r->{type} == END) {
			push @z, fixups_to_rep_cards(@symbols) if !$did_fixups;
			undef $estbl;
			undef @symbols;
		}
		if (defined($c)) {
			push @z, $c;
			undef $c;
		}
		push @z, $r;
	}
	push @z, $c if defined($c);
	@$list = @z;
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
	if ($r->{type} != REP) {
	substr($c, 5,3) = substr(pack("N", $r->{address}),1,3)
		if defined($r->{address});
	substr($c, 10,2) = pack("n", length($r->{data}))
		if defined($r->{data});
	substr($c, 14,2) = pack("n", $r->{id})
		if defined($r->{id});
	substr($c, 16, length($r->{data})) = $r->{data}
		if defined($r->{data});
	}
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
	} elsif ($r->{type} == REP) {
		my $s = ' ' x12;
		substr($s, 2, 6) = uc(sprintf("%06x", 0xffffff & $r->{address}));
		substr($s, 10, 2) = uc(sprintf"%02x", 0xff & $r->{id});
		$s .= uc(unpack("H*", $r->{data}));
		$s .= ' ' if (length($s) < $physrecl-20);
print STDERR "Oversize fixup!\n" if length($s) > $physrecl-16;
		my $s = encode("posix-bc", $s);
		substr($c, 4, length($s)) = $s;
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
	my $missed = scan_for_missed_fixups();
	printf STDERR "Skipped %d fixups\n", $missed if $missed;
}

@ARGV = process_opts(@ARGV);
process(@ARGV);
exit(0);
