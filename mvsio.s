*
* simulate mts-like environment using mvs primitives.
* works with z390 java simulator (ez390)
*
 ihaepie
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
* mts primitive to trap program interrupts
* on entry,
* 0 = handler
* 1 = save area
* if handler is 0 that means reset trap
* if first byte of save area is FF that
* means load context & resume.
*
pgnttrp equ *
 using *,3
*
 stm 14,3,12(13)
 lr 3,15
 lr 15,1
 tm 0(15),x'ff'
 bno pt10
 la 1,finpi
 espie set,(1),(6),param=(15)
 bcr 0,1
 bcr 0,1
 bcr 0,1
 dr 15,15	should do spec exception
 dc y(0)	survived? die die die
pt10 equ *
 ltr 0,0
 bnz pt20
 espie reset,,
 b pt70
pt20 equ *
 st 0,4(15)	stuff handler somewhere
 la 1,onpgmint
 espie set,(1),((6,11)),param=(15)
*
pt70 equ *
 lm 14,3,12(13)
 drop 3
 sr 15,15
 br 14
 ds 0f
*
* here when trap fires
*  mts rewrites psw in bc form.  that won't work here.
*  so, if we return an ec format pc, our caller will
*  need to know to look in R2-R3 for the intcode.
*
onpgmint equ *
 using *,15
 using epie,1
 l 2,epieparm	2 user parm
 using ptargs,2
 xr 3,3
 l 6,ptpsw+4
 la 4,ptgprs	save user state
 la 5,16
 mvc ptpsw(8),epiepsw	psw,
pi10 equ *
 l 0,epieg64+4(3)	registers
 st 0,0(4)
 la 3,8(3)
 la 4,4(4)
 bct 5,pi10
 st 6,epienxt1	vector here
 st 6,epieg6415+4	with r15=epa
 la 0,diehere	die if it returns
 st 0,epieg6414+4
 st 2,epieg6401+4	give it r1=user arg
 lm 2,3,epieint	fetch ilc inc1 and dxd.
 st 2,epieg6402+4	mts says don't care
 st 3,epieg6403+4	so it's fair game
 espie reset,,
 drop 15
 xr 15,15
 br 14
 drop 1
 drop 2
diehere equ *
 dc y(0)	return here to die
 bcr 0,0
 bcr 0,0
 bcr 0,0
 bcr 0,0
 bcr 0,0
*
* here to resume after 2nd trap
*
finpi equ *
 using *,15
 bcr 0,15
 bcr 0,15
 bcr 0,15
 using epie,1
 l 2,epieparm	2 user parm
 using ptargs,2
 xr 3,3
 la 4,ptgprs	restore user state
 la 5,16
fn10 equ *
 l 0,0(4)	registers
 st 0,epieg64+4(3)
 la 3,8(3)
 la 4,4(4)
 bct 5,fn10
 mvc epiepsw(8),ptpsw
 mvi epiepsw,7	fixup first byte
 espie reset,,
 drop 15
 xr 15,15
 br 14
 drop 1
 drop 2
*
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
ptargs dsect
ptpsw ds 2f
ptgprs ds 16f
pgargsln equ *-ptargs
 end
