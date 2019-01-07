*
* simulate mts-like environment
* for standalone s/370
*
 copy alequ
 copy psa
*
 entry scards,spunch
 entry pgnttrp,sercom,getspace,freespace
saio start h'400'
 using psa,0
*
* entry point
* initialize io, call main, exit.
*
 balr 15,0
st10 equ *
 using *,15
 b startup
 cnop 0,4
freemem dc f'12288'
startup equ *
 lr 12,15
 drop 15
 using st10,12
 la 13,mypool
 l 1,=a(mypool,mygrow)
 l 15,=v(initaloc)
 balr 15,14
 l 0,freemem
 st 0,mypool+(firstp-pool)
 la 13,mywork
 using work,13
 la 1,worklen
 la 0,3
 l 15,=v(getspace)
 balr 14,15
 st 13,4(1)
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
 lpsw diswait
diswait ds 0d
 dc x'0002',h'0',a(0)
 drop 12
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
 l 15,=a(mypool)
 using pool,15
 b alalloc
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
 l 15,=a(mypool)
 using pool,15
 b alfree
 drop 15
 cnop 0,4
*
* mygrow
* enter:
*  1=suggested start
*  0=len
* exit:
*  1=start
*  15=0
*
mygrow ds 0f
 xr 15,15
 br 14
*
* initialize io units
*
ioinit ds 0d
 br 14
*
* read input
* from mts d1.0 file #16 (bsload)
* parm1 = buffer
* parm2 = length
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
scards ds 0d
 using *,15
 stm 0,12,20(13)
 l 2,0(1)
 st 2,inccw
 mvi inccw,2
 balr 4,0
 la 2,inccw
 st 2,thecaw
 lh 3,inunit
sc10 equ *
 sio 0(3)
 bc 2,sc10
 bc 4,incsw
 bc 1,help
sc20 equ *
 tio 0(3)
 bc 3,sc20
 tm thecsw+4,2
 bc 1,help
 tm thecsw+4,x'f3'
 bc 5,hell
 l 2,in2
 la 2,1(0,2)
 st 2,in2
 l 3,12(0,1)
 st 2,0(0,3)
 la 2,80
 l 3,4(0,1)
 sth 2,0(0,3)
 xr 15,15
sc70 equ *
 lm 0,12,20(13)
 br 14
ineof equ *
 la 15,4
 b sc70
incsw tm thecsw+4,1
 bc 1,ineof
 tm thecsw+4,16
 bcr 1,4
 b help
*
in2 dc f'0'
inunit dc h'0'
inccw ccw x'2',0,x'20',80
*
* write output
* from mts d1.0 file #16 (bsload)
* parm1 = buffer
* parm2 = length (ignored)
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
spunch ds 0d
 using *,15
 stm 0,12,20(13)
 l 2,0(0,1)
 st 2,outccw
 mvi outccw,9
 l 2,4(0,1)
 lh 2,0(0,2)
 sth 2,outccw+6
 balr 4,0
 la 2,outccw
 st 2,thecaw
 lh 3,otunit
sp10 equ *
 sio 0(3)
 bc 2,sp10
 bc 4,outcsw
 bc 1,help
sp20 equ *
 tio 0(3)
 bc 3,sp20
 tm thecsw+4,2
 bc 1,outsns
 tm thecsw+4,1
 bc 1,skip
outlv lm 0,12,20(13)
 xr 15,15
 br 14
outcsw tm thecsw+4,2
 bc 1,outsns
 tm thecsw+4,1
 bc 1,skip
 tm thecsw+4,16
 bcr 1,4
 b help
outsns la 2,snsccw
 st 2,thecaw
 sio 0(3)
 bc 7,outsns
sp60 equ *
 tio 0(3)
 bc 7,sp60
 tm sense,254
 bcr 8,4
 b help
skip la 2,skpccw
 st 2,thecaw
 sio 0(3)
 bc 3,skip
 tm thecsw+4,16
 bc 1,skip
 br 4
outccw ccw 9,0,x'20',0
skpccw ccw x'8b',0,0,1
snsccw ccw 4,sense,x'20',1
otunit dc h'0'
sense dc c' '
 cnop 0,4
*
* tell operator
* not much like "help" in mts d1.0 file #16 (bsload)
* parm1 = buffer
* parm2 = length
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
sercom ds 0d
 using *,15
 stm 0,12,20(13)
 l 2,0(0,1)
 st 2,hlpccw
 mvi hlpccw,9
 l 2,4(0,1)
 lh 2,0(0,2)
 sth 2,hlpccw+6
 la 5,hlpccw
 bal 6,type
 lm 0,12,20(13)
 xr 15,15
 br 14
*
help equ *
 balr 15,0
 using *,15
 mvc hlpccw+1(3),=al3(hlpmsg)
 la 5,hlpccw
 mvc svstat(8),thecsw
 sth 3,help1  
 unpk help2(5),help1(3)
 mvc hlpmsg+5(3),help2+1
 nc hlpmsg+5(3),=X'0f0f0f'
 tr hlpmsg+5(3),help3
 bal 6,type
 drop 15
 using *,6
 lpsw helpsw
hell equ *
 balr 15,0
 using *,15
 la 5,hllccw
 bal 6,type
 drop 15
 using *,6
 lpsw hllpsw
type equ *
 st 5,thecaw
 balr 5,0
 using *,5
 lh 7,cons
 sio 0(7)
 bc 7,type
sr20 equ *
 tio 0(7)
 bc 7,sr20
 br 6
helpsw dc 0d,x'0002000000001111'
hllpsw dc 0d,x'0002000000001111'
hllccw ccw 9,hllmsg,x'20',l'hllmsg
hlpccw ccw 9,0,x'20',10
cons dc xl2'009'
help3 dc c'01234567689abcdef'
help1 ds 1h
help2 ds 5c
hllmsg dc c'I/O botch - failed!'
hlpmsg dc c'help xxx'
svstat ds d
*
*
* finish with io
*
iofini ds 0d
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
* to re-enter code we have to cause another exception.
*
pgnttrp ds 0d
 aif (1).nope
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
.nope anop
*
 ltorg
*
mypool ds 0f
 org mypool+poollen
mywork ds 0f
 org mywork+worklen
 ds f'00'
*
work dsect
iosave ds 18f
worklen equ *-work
ptargs dsect
ptpsw ds 2f
ptgprs ds 16f
pgargsln equ *-ptargs
 end
