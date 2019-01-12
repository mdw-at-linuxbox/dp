*
* simulate mts-like environment
* for standalone s/370
*
 copy alequ
 copy psa
*
 entry scards,spunch
 entry pgnttrp,sercom,getspace,freespace
saio csect
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
freemem dc v(endish)
startup equ *
 lr 12,15
 drop 15
 using st10,12
 la 13,mywork
 using work,13
 la 1,=a(mypool,mygrow)
 l 15,=v(initaloc)
 balr 14,15
 l 0,freemem
 a 0,=F'4095'
 n 0,=F'-4096'
 st 0,mypool+(lastp-pool)
 st 13,workptr
 xc pgntsv(8),pgntsv
 la 1,worklen
 la 0,3
 l 15,=v(getspace)
 balr 14,15
 st 13,4(1)
 lr 13,1
 using work,13
*
 l 15,=A(ioinit)
 balr 14,15
 l 15,=V(main)
 balr 14,15
 st 0,20(13)
 l 15,=A(iofini)
 balr 14,15
*
 lpsw diswait
diswait ds 0d,x'0002',h'0',a(0)
 drop 12
 drop 13
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
 using *,15
 stm 2,3,28(13)
 mvc exnpsw(16),intproto
 mvc svnpsw+8(24),svnpsw
 mvc pgnpsw(8),pgtpsw
 mvc newpsw(4),intproto
 st 14,newpsw+4
 xr 2,0
 bctr 2,0
 st 2,timer
 lm 2,4,28(13)
 lpsw newpsw
 drop 15
 ds 0d
* 1st will be exnpsw, next will be default for rest.
intproto dc x'00040000',a(helpgo)
 dc x'0',a(hell)
* pgnpsw is special.
pgtpsw dc x'00000000',a(prgint)
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
sc10 equ *
 la 2,inccw
 st 2,thecaw
 lh 3,inunit
sc20 equ *
 sio 0(3)
 bc 2,sc20
 bc 4,incsw
 bc 1,help
sc30 equ *
 tio 0(3)
 bc 3,sc30
 tm thecsw+4,2
 bc 1,help
 tm thecsw+4,x'f3'
 bc 5,incsw	hercules reports eof here
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
inunit dc h'12'
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
 mvi outccw,1
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
 tm thecsw+4,1	left-over from printer
 bc 1,skip	probably not valid here.
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
skip la 2,skpccw	wrong; this is not
 st 2,thecaw	a printer.  hope it can't
 sio 0(3)	happen
 bc 3,skip
 tm thecsw+4,16
 bc 1,skip
 br 4
outccw ccw 1,0,x'20',0
skpccw ccw x'8b',0,0,1
snsccw ccw 4,sense,x'20',1
otunit dc h'13'
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
 balr 6,0
 using *,6
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
*
helpgo equ *
 tm exopsw+3,64	bit 25 = external interrupt
 bcr 1,4
 lpsw helpsw
*
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
helpsw dc 0d,x'010200000000feed'
hllpsw dc 0d,x'000000000000dead'
hllccw ccw 9,hllmsg,x'20',l'hllmsg
hlpccw ccw 9,0,x'20',10
cons dc xl2'009'
help3 dc c'0123456789abcdef'
help1 ds 1h
help2 ds 5c
hllmsg dc c'bad thing happened'
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
* modelled after mts d1.0
* 0 = handler
* 1 = save area
* if handler is 0 that means reset trap
* if first byte of save area is FF that
* means load context & resume.
*
pgnttrp ds 0d
 l 15,workptr
 using work,15
 stm 0,1,pgntsv
 xr 15,15
 drop 15
 ltr 1,1
 ber 14
*
 tm 0(1),x'ff'
 bnor 14
 l 0,4(1)
 la 1,8(1)
*
 mvc trappsw(4),pgopsw
 st 0,trappsw+4
 lm 0,15,0(8)
 lpsw trappsw
** svctra
** prgint
** seterr = might be setxit
*
prgint equ *
 stm 12,13,trapgrs
 l 13,workptr
 balr 12,0
 using *,12
 using work,13
 mvc pgstate(8),pgopsw
 stm 0,11,pgstate+8
 mvc pgstate+8+4*12(8),trapgrs
 stm 14,15,pgstate+8+4*14
 l 15,pgntsv
 ltr 15,15
 bz pgnt10
 l 1,pgntsv+4
 mvc 0(72,1),pgstate
 lm 12,13,pgstate+8+4*12
 drop 12
 drop 13
 balr 14,15
pgnt10 equ *
 balr 15,0
 using *,15
 lpsw pgnfail
pgnfail dc 0d,x'0002',h'0',a(999)
 ltorg
*
mypool ds 0f
 org mypool+poollen
mywork ds 0f
 org mywork+worklen
newpsw ds 0d,2f
 dc f'0'
*
work dsect
iosave ds 18f
pgstate ds 18f
pgntsv ds 2f
worklen equ *-work
*
ptargs dsect
ptpsw ds 2f
ptgprs ds 16f
pgargsln equ *-ptargs
 end saio
