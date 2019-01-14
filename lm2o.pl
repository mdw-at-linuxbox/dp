#!/usr/bin/perl

#
# convert .390 to obj
#
# lz390 can only write .390
# hercules can only load object files
#

use common::sense;
use Clone qw(clone);
use Encode qw/encode decode/; 

my $lrecl = 72;
my $physrecl = 80;
my $iseqflag;
my $ucflag;
my $loadaddr = 0;

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
		if ($j eq "-load") {
			$f = sub {
				my ($f) = @_;
				$loadaddr = $f;
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

sub read_390
{
	local $/;
	my $r;
	$r = {};
	$/ = \20;
	my $header = <>;
	my ($code_ver, $flags, $size, $entry, $nrlds) =
		unpack("a4NNNN", $header);
	$/ = \$size;
	my $text = <>;
	$/ = \(5 * $nrlds);
	my $rlds = <>;
	$r->{entry} = $entry;
	$r->{text} = $text;
	$r->{nrlds} = $nrlds;
	my $rsize = 5;
	my @z;
	while ($rlds ne "") {
		my ($loc, $len) = unpack("NC", $rlds);
		my $e = {};
		$e->{addr} = $loc;
		if ($len < 0) {
			$e->{len} = -$len;
			$e->{sign} = 1;
		} else {
			$e->{len} = $len;
			$e->{sign} = 0;
		}
		push @z, $e;
	} continue {
		$rlds = substr($rlds, $rsize);
	}
	$r->{rlds} = \@z;
	$r->{raw_flags} = $flags;
	return $r;
}

sub load_relocate
{
	my ($l, $la) = @_;
	$l->{offset} = $la;
	for my $e ( @{$l->{rlds}} ) {
		my $aa = $e->{addr};
		my $offs = substr($l->{text}, $aa, $e->{len});
		if ($e->{len} == 8) {
die "Sorry-- cannot relocate 64 bit data yet\n";
		}
		if ($e->{len} != 4) {
			$offs = (chr(0)x(4-$e->{len})).$offs;
		}
		my $off;
		$off = unpack("N", $offs);
		$off += $la;
		$offs = pack("N", $off);
		if ($e->{len} != 4) {
			$offs = substr($offs, 4-$e->{len});
		}
		substr($l->{text}, $aa, $e->{len}) = $offs;
		$e->{addr} += $la;
	}
	$l->{entry} += $la;
}

sub convert_390_to_deck
{
	my ($l, $rp) = @_;
	my @z;
	my $esdid = 1;

	my $aa = 0;
	# top byte of AA is type: 0=SD which is what we want.
	# rest is loc, 0 is what we want.
	my $n = $l->{offset} + length($l->{text});		# ?? alignment ??
	my $esd = pack("a8NN", encode("posix-bc", ".MAIN."), $aa, $n);
	my $re = {};
	$re->{type} = ESD;
	$re->{id} = $esdid;
	$re->{data} = $esd;
	push @z, $re;
	my $to = 0;
	my $c = 0;
	while ($to < length($l->{text})) {
		$c = length($l->{text}) - $to;
		$c = $lrecl - 16 if $c > $lrecl - 16;
		my $rt = {};
		$rt->{type} = TXT;
		$rt->{address} = $l->{offset} + $to;
		$rt->{id} = $esdid;
		$rt->{data} = substr($l->{text}, $to, $c);
		push @z, $rt;
	} continue {
		$to += $c;
	}
	my $lf = 0;
	my $rr;
	for my $e ( @{$l->{rlds}} ) {
		my $aa = $e->{addr};
		my $flags = 0;
		$flags |= 2 if ($e->{sign});
		# top 4bits of flags are type: 0=A() what we want.
		my $kl;
		$kl = $e->{len} - 1;
		$kl = 0 if $e->{len} == 8;
		$flags |= ($kl<<2);
		$aa |= ($flags<<24);
		if ($rr && length($rr->{data}) > $lrecl-20) {
			push @z, $rr;
			undef $rr;
		}
		if (!defined($rr)) {
			$rr->{type} = RLD;
			$rr->{data} = pack("nn", $esdid, $esdid);
		}
		if (length($rr->{data}) > 4) {
			my $outfoff = length($rr->{data})-4;
			substr($rr->{data},$outfoff,1) =
				chr(1 | ord(substr($rr->{data},$outfoff,1)));
		}
		$rr->{data} .= pack("N", $aa);
	}
	push @z, $rr if $rr;
	$re = {};
	$re->{type} = END;
	$re->{id} = $esdid;
	$re->{address} = $l->{entry};
	push @z, $re;
	@$rp = @z;
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
	my $l = read_390();
	my @r;
	load_relocate($l, $loadaddr) if $loadaddr;
	convert_390_to_deck($l, \@r);
	printf STDERR "%d rlds, %#x textsize, load at %#x, entry at %#x; %d cards out\n",
		$l->{nrlds}, length($l->{text}), $l->{offset}, $l->{entry}, $#r;
	for my $r ( @r ) {
		print format_record($r);
	}
}

@ARGV = process_opts(@ARGV);
process(@ARGV);
exit(0);
