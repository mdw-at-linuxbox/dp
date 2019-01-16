*
* simulate mts-like environment using mvs-like primitives.
* works with z390 java simulator (ez390)
*
 ihaepie
*
 entry ioinit,scards,sprint,spunch,iofini
 entry pgnttrp,sercom,getspace,freespace
mvsio csect
*
* entry point
* initialize io, call main, exit.
*
 using *,12
 stm 14,12,12(13)
 lr 12,15
 getmain r,lv=worklen
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using work,13
*
 l 15,=V(ioinit)
 balr 14,15
 l 15,=V(main)
 balr 14,15
 st 0,20(13)
 l 15,=V(iofini)
 balr 14,15
*
 lr 1,13
 l 13,iosave+4
 drop 13
 freemain r,a=(1),lv=worklen
 lm 14,12,12(13)
 drop 12
 br 14
 cnop 0,4
*
* getspace
*pass:
* 0=switches
* 1=length
*return:
* on success,
*  r15=0
*  r1=addr (r1)=len
* on failure,
*  r15=4
*
getspace ds 0d
 using *,15
 getmain r,lv=(1)
 ltr 15,15
 bner 14
 st 0,0(1)
 br 14
 drop 15
 cnop 0,4
*
* freespace
* pass:
*  0=len
*  1=loc
* returns:
*  r15=0 | 4
*
freespace ds 0d
 using *,15
* xr 0,1
* xr 1,0
* xr 0,1
 freemain r,a=(1),lv=(0)
 br 14
 drop 15
 cnop 0,4
*
* initialize io units
*
ioinit ds 0d
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
 xr 15,15
 br 14
 cnop 0,4
*
* read input
* parm1 = buffer
* parm2 = length
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
scards ds 0d
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
 xr 15,15
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
 cnop 0,4
*
* write output
* parm1 = buffer
* parm2 = length (ignored)
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
sprint ds 0d
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
 xr 15,15
 br 14
 cnop 0,4
*
* write output
* parm1 = buffer
* parm2 = length (ignored)
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
spunch ds 0d
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
 xr 15,15
 br 14
 cnop 0,4
*
* tell operator
* parm1 = buffer
* parm2 = length
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
sercom ds 0d
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
 lh 8,0(8)
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
 xr 15,15
 br 14
 using wtwork,13
sr90 mvc wtorec+4(0),0(9)
 drop 13
 cnop 0,4
*
* finish with io
*
iofini ds 0d
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
 xr 15,15
 br 14
 cnop 0,4
*
* mts primitive to trap program interrupts
* on entry,
* 0 = handler
* 1 = save area
* if handler is 0 that means reset trap
* if first byte of save area is FF that
* means load context & resume.
*
* to re-enter code we have to cause another exception.
*
pgnttrp ds 0d
 using *,3
*
 stm 14,3,12(13)
 lr 3,15
 lr 15,1
 tm 0(15),x'ff'
 bno pt10
 la 1,finpi	ok we want to re-enter the original code
 espie set,(1),(7),param=(15)	to do that we need to cause
 bcr 0,1	another exception.  So trapping data exception
 bcr 0,1
 bcr 0,1
*
* dr 15,15	should do spec exception
*  but actually breaks ez390 espie handler
*  showing fault at finpi-2
*
 cp bd1(1),bd1	ez390 espie handler worked with this.
*
 dc y(0)	survived? die die die
pt10 equ *
 ltr 0,0	disabling trap?
 bnz pt20
 espie reset,,
 b pt70
pt20 equ *	enabling trap.
 st 0,4(15)	stuff handler somewhere
 la 1,onpgmint
 espie set,(1),((6,11)),param=(15)
*
pt70 equ *
 lm 14,3,12(13)
 drop 3
 xr 15,15
 br 14
bd1 dc x'ffff'	this is not valid decimal packed
 cnop 0,4
*
* here when trap fires
*  mts rewrites psw in bc form.  that won't work here.
*  so, if we return an ec format pc, our caller will
*  need to know to look in R2-R3 for the intcode.
*
onpgmint ds 0d
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
 ni epieg6402+7,63	mvs c7 -> esa/390 7
 espie reset,,
 drop 15
 xr 15,15
 br 14
 drop 1
 drop 2
 cnop 0,4
diehere ds 0d
 dc y(0)	return here to die
 bcr 0,0
 bcr 0,0
 bcr 0,0
 cnop 0,4
*
* here to resume after 2nd trap
*
finpi ds 0d
 using *,15
 bcr 0,15	weird no-ops
 bcr 0,15	which did not help ez390
 bcr 0,15	espie with dr 15,15
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
