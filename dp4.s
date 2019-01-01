*
* read in data
* interpret operation
* print result, cc.
* do it again unmasked.
* if exception, say what.
*
 rmode 24
dp4 csect
 stm 14,12,12(13)
 lr 12,15
 using dp4,12
 getmain r,lv=worklen
 st 13,4(1)
 lr 13,1
 using work,13
*
 la 10,setup
 xr 9,9
again equ *
 balr 11,10
 ltr 1,9
 bz again
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
 lr 1,9
*
 mvi outline,C' '
 mvc outline+1(79),outline
*
* validate operation and operands
*
 oi len1,X'FF'
 oi len2,X'FF'
 oi opidx,X'FF'
 l 1,word1
 l 15,=v(strlen)
 balr 14,15
 c 0,=F'1'
 bnz op0
 st 0,opidx
op0 equ *
 l 1,word2
 la 0,operand1
 l 15,=v(getpacked)
 balr 14,15
 ltr 15,15
 bnz op1
 st 0,len1
op1 equ *
 l 1,word3
 la 0,operand2
 l 15,=v(getpacked)
 balr 14,15
 ltr 15,15
 bnz op2
 st 0,len2
op2 equ *
 tm opidx,X'ff'
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
 oi opidx,X'FF'
op3 equ * 
 tm opidx,X'ff'
 bnz op71
 tm len1,X'ff'
 bnz op71
 tm len2,X'ff'
 bz op80
*
* report the bad news: bad operation or operands
*
op71 equ *
 la 7,badopers
 la 0,outline
 tm opidx,X'ff'
 bz op71a
 la 1,badoper0
 l 15,=v(catstr)
 balr 14,15
 l 1,word1
 l 15,=v(catstr)
 balr 14,15
 lr 1,7
 l 15,=v(catstr)
 balr 14,15
op71a equ *
 tm len1,X'ff'
 bz op72
 la 1,badoper1
 l 15,=v(catstr)
 balr 14,15
 l 1,word2
 l 15,=v(catstr)
 balr 14,15
 lr 1,7
 l 15,=v(catstr)
 balr 14,15
op72 equ *
 tm len2,X'ff'
 bz op73
 la 1,badoper2
 l 15,=v(catstr)
 balr 14,15
 l 1,word3
 l 15,=v(catstr)
 balr 14,15
 lr 1,7
 l 15,=v(catstr)
 balr 14,15
op73 equ *
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
*
* report results and loop
*
op90 equ *
 lr 1,0
 mvi 0(1),C' '
 la 9,outline
 b again
*
done equ *
 lr 1,13
 l 13,dp1save+4
 drop 13
 freemain r,a=(1),lv=worklen
 lm 14,12,12(13)
 drop 12
 sr 15,15
 br 14
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
 bz set60
 bal 6,set70
set60 equ *
 l 15,=V(iofini)
 balr 14,15
 b done
set70 equ *
 la 1,spargs
 st 9,0(1)
 mvc wtorec+4(80),0(9)
 mvc wtorec(4),wt2
 la 1,wtorec
 wto mf=(E,(1))
 la 1,spargs
 l 15,=V(spunch)
 balr 14,15
 br 6
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
scargs call scards,(0,inlen,zero,lineno),mf=l
spargs call spunch,(0,outlen,zero,lineno),mf=l
catchit dc v(pgnttrp),a(ontrap,trapsave)
 ds 0d
lab1 dc C'Arg1 is <',X'0'
lab2 dc C'> arg2 <',X'0'
lab3 dc C'> op <',X'0'
lab4 dc C'> len=',X'0'
lab5 dc C' idx=',X'0'
badoper0 dc C'operation is bad, <',X'0'
badoper1 dc C'operand1 is bad, <',X'0'
badopers dc C'>, ',X'0'
badoper2 dc C'operand2 is bad, <',X'0'
optbl dc c'+-*/=<',X'0'
wt2 dc y(80,0)
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
temp ds 81c
trapsave ds 18f
wtorec ds 1f,80c
operand1 ds 16c
opidx ds 1f
len1 ds 1f
operand2 ds 16c
len2 ds 1f
operand3 ds 16c
len3 ds 1f
worklen equ *-work
 end dp4
