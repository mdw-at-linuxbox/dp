all: DP4.390 TMA.390 SAIO.OBJ ALLOC.OBJ DP4XA.BIN
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
#  d p 4 x a
#
DP4XA.BIN: DP4XA.390
	perl lm2o.pl -load 8192 DP4XA.390 > DP4XA.BIN
DP4XA.390: DP4.OBJ SAIO390.OBJ STR.OBJ PDC.OBJ ALLOC.OBJ DP4XA.LKD
	MYLIB=. java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K lz390 DP4XA
#
#  t m a
#
TMA.390: TMA.OBJ MVSIO.OBJ STR.OBJ ALLOC.OBJ TMA.LKD
	MYLIB=. java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K lz390 TMA
TMA.PRN TMA.OBJ: TMA.MLC ALEQU.CPY
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 TMA 'SYSMAC(/home/mdw/src/z390/mac)'
TMA.MLC: tma.s update1.pl
	perl update1.pl -par ,,,36 -uc tma.s > TMA.MLC
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
ENDISH.PRN ENDISH.OBJ: ENDISH.MLC
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 ENDISH 'SYSMAC(/home/mdw/src/z390/mac)'
ENDISH.MLC: endish.s update1.pl
	perl update1.pl -par ,,,36 -uc endish.s > ENDISH.MLC
#
# standalone support
#
SAIO390.PRN SAIO390.OBJ: SAIO390.MLC S360.MA ALEQU.CPY PSA.CPY SAIO.MLC
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 SAIO390 'PROFILE(S390.MA)' 'SYSPARM(I390)'
SAIO.PRN SAIO.OBJ: SAIO.MLC S360.MA ALEQU.CPY PSA.CPY
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 SAIO 'PROFILE(S360.MA)'
SAIO.MLC: saio.s update1.pl
	perl update1.pl -par ,,,36 -uc saio.s > SAIO.MLC
ALLOC.PRN ALLOC.OBJ: ALLOC.MLC S360.MA ALEQU.CPY
	java -cp ~/src/z390/z390.jar -Xrs -Xms150000K -Xmx150000K mz390 ALLOC 'PROFILE(S360.MA)'
ALLOC.MLC: alloc.s update1.pl
	perl update1.pl -par ,,,36 -uc alloc.s > ALLOC.MLC
ALEQU.CPY: alequ.s update1.pl
	perl update1.pl -par ,,,36 -uc alequ.s > ALEQU.CPY
PSA.CPY: psa.s update1.pl
	perl update1.pl -par ,,,36 -uc psa.s > PSA.CPY

#
SAIO390.MLC:
	ln -s SAIO.MLC SAIO390.MLC
