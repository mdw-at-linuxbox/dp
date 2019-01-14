psa dsect
strtpsw ds d
initccw1 ds d
initccw2 ds d
exopsw ds d
svopsw ds d
pgopsw ds d
mcopssw ds d
ioopsw ds d
 org psa+64
thecsw ds d
thecaw ds f
 ds f
timer ds f
 ds f
exnpsw ds d
svnpsw ds d
pgnpsw ds d
mcnpssw ds d
ionpsw ds d
scanout ds xl256
 aif ('&sysparm' eq 'I390').p390
 aif ('&sysparm' eq 'I2067').p2067
 ago .psaend
.p2067 anop
**
* 360/67 interruption codes, EC mode
**
 org psa+20
exicod ds h
svicod ds h
pgicod ds h
mcicod ds h
ioicod ds h
 ago .psaend
**
* esa/390 interruption codes
**
.p390 anop
 org psa+134
exicod ds h
 org psa+138
svicod ds h
 org psa+142
pgicod ds h
 org psa+144
dxc ds f
 org psa+232
mcicod ds 4h
 ago .psaend
.psaend anop
**
* (common) working storage, low core
**
 org psa+512
trappsw ds 1d	construct psw here to return to application
trapgrs ds 2f	trap temp save
workptr ds 1f	pointer to sup work area
