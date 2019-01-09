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
 org psa+512
trappsw ds 1d
trapgrs ds 2f
workptr ds 1f
