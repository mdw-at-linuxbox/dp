*
* simulate mts-like environment using mvs primitives.
* works with z390 java simulator (ez390)
*
 entry ioinit,scards,sprint,spunch,iofini
 entry pgnttrp,sercom
mvsio csect
 balr 15,0
 lpsw 0
*
* initialize io units
*
ioinit equ *
 stm 14,12,12(13)
 lr 12,15
 using ioinit,12
 getmain r,lv=worklen
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using work,13
*
 open mf=(e,openlist)
*
 lr 1,13
 l 13,iosave+4
 drop 13
 freemain r,a=(1),lv=worklen
 lm 14,12,12(13)
 drop 12
 sr 15,15
 br 14
*
* read input
* parm1 = buffer
* parm2 = length
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
scards equ *
 stm 14,12,12(13)
 lr 12,15
 lr 11,1
 using scards,12
 getmain r,lv=worklen
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using work,13
*
 la 1,indcb
 l 0,0(11)
 get (1),(0)
 sr 15,15
*
sc10 equ *
 lr 1,13
 l 13,iosave+4
 st 15,16(13)
 drop 13
 freemain r,a=(1),lv=worklen
 lm 14,12,12(13)
 drop 12
 br 14
*
ineof equ *
 using scards,12
 la 15,4
 b sc10
 drop 12
*
* write output
* parm1 = buffer
* parm2 = length (ignored)
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
sprint equ *
 stm 14,12,12(13)
 lr 12,15
 lr 11,1
 using sprint,12
 getmain r,lv=worklen
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using work,13
*
 la 1,outdcb
 l 0,0(11)
 put (1),(0)
*
 lr 1,13
 l 13,iosave+4
 drop 13
 freemain r,a=(1),lv=worklen
 lm 14,12,12(13)
 drop 12
 sr 15,15
 br 14
*
* write output
* parm1 = buffer
* parm2 = length (ignored)
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
spunch equ *
 stm 14,12,12(13)
 lr 12,15
 lr 11,1
 using spunch,12
 getmain r,lv=worklen
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using work,13
*
 l 0,0(11)
 la 1,pchdcb
 put (1),(0)
*
 lr 1,13
 l 13,iosave+4
 drop 13
 freemain r,a=(1),lv=worklen
 lm 14,12,12(13)
 drop 12
 sr 15,15
 br 14
*
* tell operator
* parm1 = buffer
* parm2 = length
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
sercom equ *
 stm 14,12,12(13)
 lr 12,15
 lr 11,1
 using sercom,12
 getmain r,lv=wtwklen
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using wtwork,13
*
 l 8,4(11)
 lh 8,2(8)
 l 9,0(11)
 xc wtorec+2(2),wtorec+2
 lr 7,8
 la 7,4(7)
 sth 7,wtorec
 ltr 8,8
 bz sr10
 bctr 8,0
 ex 8,sr90
sr10 equ *
 la 1,wtorec
 wto mf=(E,(1))
*
 lr 1,13
 l 13,wtsave+4
 drop 13
 freemain r,a=(1),lv=wtwklen
 lm 14,12,12(13)
 drop 12
 sr 15,15
 br 14
 using wtwork,13
sr90 mvc wtorec+4(0),0(9)
 drop 13
*
* finish with io
*
iofini equ *
 stm 14,12,12(13)
 lr 12,15
 using iofini,12
 getmain r,lv=worklen
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using work,13
*
 close mf=(e,clslist)
*
 lr 1,13
 l 13,iosave+4
 drop 13
 freemain r,a=(1),lv=worklen
 lm 14,12,12(13)
 drop 12
 sr 15,15
 br 14
*
* catch pgm traps
*
pgnttrp equ *
 br 14
indcb dcb dsorg=ps,macrf=(pm),ddname=sysin,recfm=fba,lrecl=80,eodad=ineof
outdcb dcb dsorg=ps,macrf=(pm),ddname=sysout,recfm=fba,lrecl=133
pchdcb dcb dsorg=ps,macrf=(pm),ddname=syspch,recfm=fba,lrecl=80
*openlist open mf=l,(indcb,input,outdcb,output)
*clslist close mf=l,(indcb,,outdcb,)
openlist open mf=l,(indcb,input,pchdcb,output)
clslist close mf=l,(indcb,,pchdcb,)
 ltorg
work dsect
iosave ds 18f
worklen equ *-work
wtwork dsect
wtsave ds 18f
wtorec ds 1f,80c
wtwklen equ *-work
 end
