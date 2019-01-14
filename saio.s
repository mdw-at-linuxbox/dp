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
 stm 2,5,28(13)
 mvc exnpsw(16),intproto
 mvc svnpsw+8(24),svnpsw
 mvc pgnpsw(8),pgtpsw
 mvc newpsw(4),intproto+8
 st 14,newpsw+4
 aif ('&sysparm' eq 'I390').n390
 xr 2,0		* 360: max out timer
 bctr 2,0
 st 2,timer
 ago .nend
.n390 anop
 mvi newpsw+4,0	must clear high byte for EC mode psw
 l 3,workptr
 using work,3
 xc myorb(32),myorb
 la 1,x'1ff'	form x'ff80'
 sll 1,7
 sth 1,myorb+6	orb lpm, use any path
 l 1,=f'65535'
nt10 equ *
 la 1,1(1)
 stsch myschib
 bo nt40
 la 4,otsubch
 clc myschib+6(2),otunit
 bz nt20
 la 4,insubch
 clc myschib+6(2),inunit
 bz nt20
 la 4,cnsubch
 clc myschib+6(2),cons
 bnz nt10
nt20 equ *
 st 1,0(4)
 oi myschib+5,128
 msch myschib
 b nt10
nt40 equ *
 drop 3
 ago .nend
.nend anop
 lm 2,5,28(13)
 lpsw newpsw
 drop 15
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
 lh 3,inunit
 l 5,workptr
 using work,5
sc20 equ *
 aif ('&sysparm' eq 'I390').s390
 la 2,inccw
 st 2,thecaw
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
 ago .scend
.s390 anop
 la 2,inccw
 st 2,myorb+8
 l 1,insubch
 ssch myorb
 bc 2,sc20
 bc 4,incsw
 bc 1,help
sc30 equ *
 tsch myirb
 bc 3,sc30
 tm thecsw+4,2
 bc 1,help
 tm thecsw+4,x'f3'
 bc 5,incsw	hercules reports eof here
 ago .scend
.scend anop
 l 1,24(13)
 l 2,in2
 la 2,1(0,2)
 st 2,in2
 l 3,12(0,1)
 st 2,0(0,3)
 la 2,80
 l 3,4(0,1)
 sth 2,0(0,3)
 xr 2,2
sc70 equ *
 lr 15,2
 lm 0,12,20(13)
 br 14
ineof equ *
 la 2,4
 b sc70
incsw tm thecsw+4,1
 bc 1,ineof
 tm thecsw+4,16
 bcr 1,4
 b help
 drop 5
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
 l 5,workptr
 using work,5
 stm 0,12,20(13)
 l 2,0(0,1)
 st 2,outccw
 mvi outccw,1
 l 2,4(0,1)
 lh 2,0(0,2)
 sth 2,outccw+6
 balr 4,0
 lh 3,otunit
sp05 equ *
 xr 8,8
 la 2,outccw
 bal 7,sp10
 l 1,24(13)
 lm 0,12,20(13)
 xr 15,15
 br 14
sp10 equ *
 aif ('&sysparm' eq 'I390').u390
 st 2,thecaw
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
 ago .puend
.u390 anop
 st 2,myorb+8
 l 1,otsubch
 ssch myorb
 bc 2,sp10
 bc 4,outcsw
 bc 1,help
sp20 equ *
 tsch myirb
 bc 3,sp20
 tm thecsw+4,2
 bc 1,outsns
 tm thecsw+4,1	left-over from printer
 bc 1,skip	probably not valid here.
 ago .puend
.puend anop
 br 7
outcsw tm thecsw+4,2
 bc 1,outsns
 tm thecsw+4,1
 bc 1,skip
 tm thecsw+4,16
 bcr 1,4
 b help
outsns la 2,snsccw
 ltr 8,8
 bnzr 4
 lr 9,2
 lr 8,7
 bal 7,sp10
 lr 2,9
 br 8
skip la 2,skpccw	wrong; this is not
 ltr 8,8
 bnzr 4
 lr 9,2
 lr 8,7		a printer.  hope it can't
 bal 7,sp10	happen
 lr 2,9
 br 8
 drop 5
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
 drop 15
*
* uses,
*  4 = address to branch back to
*  3 = unit # that needs help
* trashes:
*  1
*  6
*  7
*  8
*  9
* preserves:
*  13
*  15
*
help equ *
 balr 6,0
 using *,6
 l 8,workptr
 using work,8
 mvc hlpccw+1(3),=al3(hlpmsg)
 la 5,hlpmsgl
 sth 5,hlpccw+6
 la 5,hlpccw
 mvc svstat(8),thecsw
 sth 3,help1  
 mvc help1+2(2),svstat+4
 unpk help2(9),help1(5)
 tr help2(8),help3-240
 mvc hlpmsg+5(3),help2+1
 mvc hlpmsg+9(4),help2+4
 bal 6,type
 using *,6
 lpsw helpsw
*
helpgo equ *
 aif ('&sysparm' eq 'I390').e390
 tm exopsw+3,64	bit 25 = external interrupt
 bcr 1,4
 ago .extoend
.e390 anop
 mvc trappsw(1),exicod
 oc trappsw(1),exicod+1
 cli trappsw,x'40'
 bzr 4
 ago .extoend
.extoend anop
 lpsw helpsw
*
 drop 8
hell equ *
 balr 15,0
 using *,15
 la 5,hllccw
 bal 6,type
 drop 15
 using *,6
 lpsw hllpsw
 drop 6
type equ *
 balr 9,0
 using *,9
 aif ('&sysparm' eq 'I390').h390
 st 5,thecaw
 lh 7,cons
 sio 0(7)
 bcr 7,9
sr20 equ *
 tio 0(7)
 bc 7,sr20
 ago .hlend
.h390 anop
 l 8,workptr
 using work,8
 st 5,myorb+8
 l 1,cnsubch
 ssch myorb
 bcr 7,9
sr20 equ *
 tsch myirb
 bc 7,sr20
 drop 8
 ago .hlend
.hlend anop
 br 6
 drop 9
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
*
 balr 4,0
 using *,4
 mvc trappsw(4),intproto+8
 st 0,trappsw+4
 lm 0,15,8(1)
 drop 4
 lpsw trappsw
*
* handle program interrupt.
*
** extension for esa/390 / ez390:
***	in EC mode: return ilc|intcode in R2, dxc in R3.
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
 aif ('&sysparm' eq 'I390').g390
 ago .gend
.g390 anop
 lm 2,3,pgicod-2	pick up ilc,intcode,dxc
.gend anop
 l 15,pgntsv
 l 1,pgntsv+4
 xc pgntsv(8),pgntsv
 ltr 15,15
 bz pgnt10
 ltr 1,1
 bz pgnt10
 mvc 0(72,1),pgstate
 lm 12,13,pgstate+8+4*12
 drop 12
 drop 13
 balr 14,15
pgnt10 equ *
 balr 15,0
 using *,15
 lpsw pgnfail
 drop 15
 aif ('&sysparm' eq 'I390').i390
**
* 360 bc mode
**
diswait ds 0d,x'0002',h'0',a(0)
hllpsw dc 0d,x'000200000000dead'
helpsw dc 0d,x'010200000000feed'
pgnfail dc 0d,x'0002',h'0',a(999)
* 1st will be exnpsw, next will be default for rest.
intproto dc x'0',a(helpgo)
 dc x'0',a(hell)
* pgnpsw is special.
pgtpsw dc x'0',a(prgint)
 ago .vecend
**
* esa/390
**
.i390 anop
diswait ds 0d,x'000a',h'0',a(0)
hllpsw dc 0d,x'000a00000000dead'
helpsw dc 0d,x'010a00000000feed'
pgnfail dc 0d,x'000a',h'0',a(999)
* 1st will be exnpsw, next will be default for rest.
intproto dc x'00080000',a(helpgo)
 dc x'00080000',a(hell)
* pgnpsw is special.
pgtpsw dc x'00080000',a(prgint)
 ago .vecend
.vecend anop
*
hllccw ccw 9,hllmsg,x'20',l'hllmsg
hlpccw ccw 9,0,x'20',10
cons dc xl2'009'
help3 dc c'0123456789abcdef'
help1 ds 1f
help2 ds 9c
hllmsg dc c'bad thing happened'
hlpmsg dc c'help xxx yyyy'
hlpmsgl equ *-hlpmsg
svstat ds d
*
sysarch dc C'&sysparm'
*
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
 aif ('&sysparm' eq 'I390').w390
 ago .workend
.w390 anop
myschib ds 12f
myorb ds 8f
thecsw equ myirb+4
myirb ds 24f
otsubch ds f
insubch ds f
cnsubch ds f
 ago .workend
.workend anop
pgstate ds 18f
pgntsv ds 2f
worklen equ *-work
*
ptargs dsect
ptpsw ds 2f
ptgprs ds 16f
pgargsln equ *-ptargs
 end saio
