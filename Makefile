all: DP4.390
## DP1.390 DP2.390 DP3.390
#
#  d p 1
#
DP1.390: DP1.OBJ
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K lz390 DP1
DP1.PRN DP1.OBJ: DP1.MLC
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 DP1 'SYSMAC(/home/mdw/src/z390/mac)'
DP1.MLC: dp1.s update1.pl
	perl update1.pl -par ,,,36 -uc dp1.s > DP1.MLC
#
#  d p 2
#
DP2.390: DP2.OBJ MVSIO.OBJ DP2.LKD
	MYLIB=. java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K lz390 DP2
DP2.PRN DP2.OBJ: DP2.MLC
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 DP2 'SYSMAC(/home/mdw/src/z390/mac)'
DP2.MLC: dp2.s update1.pl
	perl update1.pl -par ,,,36 -uc dp2.s > DP2.MLC
#
#  d p 3
#
DP3.390: DP3.OBJ MVSIO.OBJ STR.OBJ DP3.LKD
	MYLIB=. java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K lz390 DP3
DP3.PRN DP3.OBJ: DP3.MLC
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 DP3 'SYSMAC(/home/mdw/src/z390/mac)'
DP3.MLC: dp3.s update1.pl
	perl update1.pl -par ,,,36 -uc dp3.s > DP3.MLC
#
#  d p 4
#
DP4.390: DP4.OBJ MVSIO.OBJ STR.OBJ PDC.OBJ DP4.LKD
	MYLIB=. java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K lz390 DP4
DP4.PRN DP4.OBJ: DP4.MLC
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 DP4 'SYSMAC(/home/mdw/src/z390/mac)'
DP4.MLC: dp4.s update1.pl
	perl update1.pl -par ,,,36 -uc dp4.s > DP4.MLC
#
# support library
#
MVSIO.PRN MVSIO.OBJ: MVSIO.MLC
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 MVSIO 'SYSMAC(/home/mdw/src/z390/mac)'
MVSIO.MLC: mvsio.s update1.pl
	perl update1.pl -par ,,,36 -uc mvsio.s > MVSIO.MLC
STR.PRN STR.OBJ: STR.MLC
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 STR 'SYSMAC(/home/mdw/src/z390/mac)'
STR.MLC: str.s update1.pl
	perl update1.pl -par ,,,36 -uc str.s > STR.MLC
PDC.PRN PDC.OBJ: PDC.MLC
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 PDC 'SYSMAC(/home/mdw/src/z390/mac)'
PDC.MLC: pdc.s update1.pl
	perl update1.pl -par ,,,36 -uc pdc.s > PDC.MLC
