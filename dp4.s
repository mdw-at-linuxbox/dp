*
* read in data
* interpret operation
* print result, cc.
* do it again unmasked.
* if exception, say what.
*
dp4 csect
 stm 14,12,12(13)
 lr 12,15
 using dp4,12
 getmain r,lv=worklen
 st 13,4(1)
 lr 13,1
 using work,13
 xc counts(countln),counts
*
 la 10,setup
again equ *
 xr 9,9
again2 equ *
 balr 11,10
 ltr 1,9
 bz again
 mvc scargs(16),inproto
 mvc spargs(16),outproto
 xc badflag,badflag
 xc sw,sw
 l 15,=V(skipspc)
 balr 14,15
 cli 0(1),0
 bz again
 la 0,temp
 st 0,word1
 l 15,=V(getword)
 balr 14,15
 l 15,=V(skipspc)
 balr 14,15
 st 0,word2
 l 15,=V(getword)
 balr 14,15
 l 15,=V(skipspc)
 balr 14,15
 st 0,word3
 l 15,=V(getword)
 balr 14,15
 l 15,=V(skipspc)
 balr 14,15
 st 0,word4
 l 15,=V(getword)
 balr 14,15
 l 15,=V(skipspc)
 balr 14,15
 tm 0(1),X'ff'
 bz ag90
 oi badflag,128
ag90 equ *
 xr 0,0
 xr 4,4
 l 1,word4
 b ag70
ag60 equ *
 la 1,1(1)
ag70 equ *
 cli 0(1),0
 bz ag95
 cli 0(1),C'-'
 bz ag60
 ic 2,0(1)
 n 2,=F'63'
 c 2,=F'32'
 bl ag74
 s 2,=F'8'
ag74 equ *
 c 2,=F'16'
 bnh ag76
 s 2,=F'7'
ag76 equ *
 la 3,1
 sll 3,0(2)
 or 4,3
 b ag60
ag95 equ *
 st 4,sw
*
 mvi outline,C' '
 mvc outline+1(79),outline
*
* validate operation and operands
*
 oi badflag,7
 l 6,=v(getpacked)
 tm sw,1		-x switch
 bz op10
 l 6,=v(gethex)
op10 equ *
 l 1,word1
 l 15,=v(strlen)
 balr 14,15
 c 0,=F'1'
 bnz op40
 ni badflag,-2
op40 equ *
 l 1,word2
 la 0,operand1
 lr 15,6
 balr 14,15
 ltr 15,15
 bnz op50
 ni badflag,-3
 st 0,len1
op50 equ *
 l 1,word3
 la 0,operand2
 lr 15,6
 balr 14,15
 ltr 15,15
 bnz op2
 ni badflag,-5
 st 0,len2
op2 equ *
 tm badflag,1
 bnz op3
 l 1,word1
 ic 0,0(1)
 la 1,optbl
 l 15,=v(index)
 balr 14,15
 sr 0,1
 st 0,opidx
 ltr 15,15
 bz op3
 oi badflag,1
op3 equ *
 tm badflag,X'FF'
 bz op80
*
* report the bad news: bad operation or operands
*
op71 equ *
 l 9,bdcount
 a 9,=f'1'
 st 9,bdcount
 la 7,badopers
 la 0,outline
 la 1,badinp
 l 15,=v(catstr)
 balr 14,15
 l 1,rcount
 l 15,=V(catint)
 balr 14,15
 la 1,badinp2
 l 15,=v(catstr)
 balr 14,15
 tm badflag,1
 bz op73
 la 1,badoper0
 l 15,=v(catstr)
 balr 14,15
 l 1,word1
 l 15,=v(catstr)
 balr 14,15
 lr 1,7
 l 15,=v(catstr)
 balr 14,15
op73 equ *
 tm badflag,2
 bz op74
 la 1,badoper1
 l 15,=v(catstr)
 balr 14,15
 l 1,word2
 l 15,=v(catstr)
 balr 14,15
 lr 1,7
 l 15,=v(catstr)
 balr 14,15
op74 equ *
 tm badflag,4
 bz op75
 la 1,badoper2
 l 15,=v(catstr)
 balr 14,15
 l 1,word3
 l 15,=v(catstr)
 balr 14,15
 lr 1,7
 l 15,=v(catstr)
 balr 14,15
op75 equ *
 tm badflag,128
 bz op76
 la 1,badxtra
 l 15,=v(catstr)
 balr 14,15
op76 equ *
 s 0,=F'2'
 lr 1,0
 mvc 0(2,1),=C'  '
 b op90
op80 equ *
*
* eventually do operation here.  for now, just print some stuff.
*
 la 0,outline
 la 1,lab1
 l 15,=V(catstr)
 balr 14,15
 la 1,operand1
 l 2,len1
 l 15,=V(cathex)
 balr 14,15
 la 1,lab2
 l 15,=V(catstr)
 balr 14,15
 la 1,operand2
 l 2,len2
 l 15,=V(cathex)
 balr 14,15
 la 1,lab3
 l 15,=V(catstr)
 balr 14,15
 l 1,word1
 l 15,=V(catstr)
 balr 14,15
 la 1,lab4
 l 15,=V(catstr)
 balr 14,15
 l 1,len2
 l 15,=V(catint)
 balr 14,15
 la 1,lab5
 l 15,=V(catstr)
 balr 14,15
 l 1,opidx
 l 15,=V(catint)
 balr 14,15
 la 1,lab6
 l 15,=V(catstr)
 balr 14,15
 l 1,sw
 l 15,=V(catint)
 balr 14,15
 la 1,lab7
 l 15,=V(catstr)
 balr 14,15
 la 1,sw
 la 2,4
 l 15,=V(cathex)
 balr 14,15
 la 1,lab8
 l 15,=V(catstr)
 balr 14,15
*
* report results and loop
*
op90 equ *
 lr 8,0
 mvi 0(8),C' '
 la 9,outline
 sr 8,9
 b again2
*
* co-routine
* 1. fetch data
* 2. return with program mask clear.
* 3. on re-entry, print results.
* 4. then set program mask, arrange to trap.
* 5. return.  if a trap occurs, log it.
* 6. on re-entry, capture and print results.
*
setup equ *
 using dp4,12
 using work,13
 l 15,=V(ioinit)
 balr 14,15
 lm 15,1,catchit
 balr 14,15
 b set40
set10 equ *
 l 9,rcount
 a 9,=f'1'
 st 9,rcount
 la 9,inline
 balr 10,11
 ltr 9,9
 bz set40
 bal 6,set70
set40 equ *
 la 1,scargs
 la 2,inline
 st 2,0(1)
 l 15,=V(scards)
 balr 14,15
 mvi inline+80,0
 ltr 15,15
 bz set10
 xr 9,9
 balr 10,11
 ltr 9,9
 bz done
 bal 6,set70
set70 equ *
 la 1,spargs
 st 9,0(1)
 st 8,outlen
 l 15,=v(sercom)
 balr 14,15
*
 la 1,spargs
 l 15,=V(spunch)
 balr 14,15
 br 6
*
* report summary
*
done equ *
 la 0,outline
 l 1,rcount
 l 15,=V(catint)
 balr 14,15
 la 1,sum1
 l 15,=V(catstr)
 balr 14,15
 la 6,1
 c 6,rcount
 bz dn10
 lr 1,0
 mvi 0(1),C's'
 ar 0,6
dn10 equ *
 la 1,sum1a
 l 15,=V(catstr)
 balr 14,15
 l 1,bdcount
 l 15,=V(catint)
 balr 14,15
 la 1,sum2
 l 15,=V(catstr)
 balr 14,15
 c 6,bdcount
 bz dn20
 lr 1,0
 mvi 0(1),C's'
 ar 0,6
dn20 equ *
 la 1,sum0
 l 15,=V(catstr)
 balr 14,15
 l 1,opcount
 l 15,=V(catint)
 balr 14,15
 la 1,sum3
 l 15,=V(catstr)
 balr 14,15
 c 6,opcount
 bz dn30
 lr 1,0
 mvi 0(1),C's'
 ar 0,6
dn30 equ *
 la 1,sum0
 l 15,=V(catstr)
 balr 14,15
 lr 8,0
 s 8,=F'2'
 la 9,outline
 sr 8,9
 la 1,spargs
 st 9,0(1)
 st 8,outlen
 l 15,=v(sercom)
 balr 14,15
*
* and finish up
*
 l 15,=V(iofini)
 balr 14,15
 lr 1,13
 l 13,dp1save+4
 drop 13
 freemain r,a=(1),lv=worklen
 lm 14,12,12(13)
 drop 12
 sr 15,15
 br 14
*
* table of operations.  will index with
*  offset from operator found in optbl.
*
extbl ap 0(0,1),0(2)
 sp 0(0,1),0(2)
 mp 0(0,1),0(2)
 dp 0(0,1),0(2)
 zap 0(0,1),0(2)
 cp 0(0,1),0(2)
ontrap equ *
* XXX do something here.
 lpsw 0
inlen dc f'80'
outlen dc f'80'
lineno dc f'0'
zero dc f'0'
inproto dc a(0,inlen,zero,lineno)
outproto dc a(0,outlen,zero,lineno)
catchit dc v(pgnttrp),a(ontrap,trapsave)
 ds 0d
lab1 dc C'Arg1 is <',X'0'
lab2 dc C'> arg2 <',X'0'
lab3 dc C'> op <',X'0'
lab4 dc C'> len=',X'0'
lab5 dc C' idx=',X'0'
lab6 dc C' sw=',X'0'
lab7 dc C'(',X'0'
lab8 dc C')',X'0'
badinp dc C'record ',X'0'
badinp2 dc C' is bad, ',X'0'
badoper0 dc C'operation is bad, <',X'0'
badoper1 dc C'operand1 is bad, <',X'0'
badopers dc C'>, ',X'0'
badoper2 dc C'operand2 is bad, <',X'0'
badxtra dc C'trailing garbage, ',X'0'
sum1 dc C' record',X'0'
sum1a dc C' read'
sum0 dc C', ',X'0'
sum2 dc C' bad record',X'0'
sum3 dc C' operation',X'0'
optbl dc c'+-*/=<',X'0'
 ltorg
work dsect
dp1save ds 18f
 ds 1f
inline ds 81c
 ds 1f
outline ds 81c
 ds 1f
word1 ds 1f
word2 ds 1f
word3 ds 1f
word4 ds 1f
sw ds 1f
badflag ds 1f
temp ds 81c
trapsave ds 18f
operand1 ds 16c
opidx ds 1f
len1 ds 1f
operand2 ds 16c
len2 ds 1f
operand3 ds 16c
len3 ds 1f
counts equ *
rcount ds 1f
bdcount ds 1f
opcount ds 1f
countln equ *-counts
scargs ds 4f
spargs ds 4f
worklen equ *-work
 end dp4
