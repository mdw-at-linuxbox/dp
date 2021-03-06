*
* decimal arithmetic test driver
*
* input data form:
*  operation operand1 operand2 switches
* operation is a single character, one of +-*/=<%
*  = is zap, < is cp, % is edmk
* switches: -x means operands on this line are in hex
*  (instead of being packed decimal numbers).
*
* read in data
* execute operation
* print results, cc.
* also trap and report exception if any.
* when no more data, print summary.
*
 entry main
dp4 csect
main equ *
 stm 14,12,12(13)
 lr 12,15
 using dp4,12
 la 1,worklen
 la 0,3
 l 15,=v(getspace)
 balr 14,15
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using work,13
 xc counts(countln),counts
 xc zero(8),zero	zero lineno too
 mvc scargs(ioprotln),inproto	setup arg lists
 la 4,scargs	do runtime	for scards,spunch
 la 3,spargs+12	relocation
 la 2,4
ag10 equ *
 l 5,0(4)
 ar 5,13
 st 5,0(4)
 bxle 4,2,ag10
 mvi fatal,0
 la 1,operand3	compute possible bases
 st 1,r1a31	for when edmk sets r1
 st 1,r1a24
 mvi r1a24,r1cc
*
* get an input record, split it up
*
 la 10,setup
again equ *
 xr 9,9	(nothing to print)
again2 equ *
 balr 11,10
 ltr 1,9
 bz again
 xc badflag,badflag
 xc sw,sw
 l 15,=V(skipspc)
 balr 14,15
 cli 0(1),0
 bz again
 cli 0(1),C'#'
 bz again
 la 0,temp
 st 0,word1	first word (operation)
 l 15,=V(getword)
 balr 14,15
 l 15,=V(skipspc)
 balr 14,15
 st 0,word2	second word (operand1)
 l 15,=V(getword)
 balr 14,15
 l 15,=V(skipspc)
 balr 14,15
 st 0,word3	third word (operand2)
 l 15,=V(getword)
 balr 14,15
 l 15,=V(skipspc)
 balr 14,15
 st 0,word4	4th word (switches)
 l 15,=V(getword)
 balr 14,15
 l 15,=V(skipspc)
 balr 14,15
 tm 0(1),X'ff'	and trailing garbage check
 bz ag90
 oi badflag,128
ag90 equ *
 xr 0,0
 xr 4,4
 l 1,word4
 b ag70
ag60 equ *
 la 1,1(1)
ag70 equ *	parse flags
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
 mvi guard1,x'a5'
 mvc guard1+1(guardlen-1),guard1
*
* validate operation and operands
* also parse operands and make them ready for use
*
 la 7,op3len
 l 6,=v(getpacked)
 tm sw,1		-x switch
 bz op10	means select alternate
 l 6,=v(gethexst)	operand conversion
 sll 7,1
op10 equ *
 l 1,word1	operation should be 1 char
 l 15,=v(strlen)
 balr 14,15
 c 0,=F'1'
 bz op40
 oi badflag,1
 b op60
op40 equ *
 l 1,word1	compute operation index
 ic 0,0(1)
 la 1,optbl
 l 15,=v(index)
 balr 14,15
 sr 0,1
 st 0,opidx
 ltr 15,15
 bz op60
 oi badflag,1
op60 equ *
 l 1,word2	check for operands way too big
 l 15,=v(strlen)
 balr 14,15
 cr 0,7
 bnh op42
 oi badflag,64+2
op42 equ *
 l 1,word3
 l 15,=v(strlen)
 balr 14,15
 cr 0,7
 bnh op44
 oi badflag,64+4
op44 equ *
 tm badflag,64
 bnz op55
 oi badflag,6
 la 7,16	decimal numbers: 16 bytes at most
 cli opidx+3,6	extbl==edmk?
 bne op48	then allow more space
 la 7,op3len
op48 equ *
 l 1,word2	convert word2 -> operand1
 la 0,operand1
 lr 15,6
 balr 14,15
 ltr 15,15
 bnz op50
 cr 0,7
 bh op50
 ni badflag,-3
 st 0,len1
op50 equ *
 l 1,word3	convert word3 -> operand2
 la 0,operand2
 lr 15,6
 balr 14,15
 ltr 15,15
 bnz op55
 cr 0,7
 bh op55
 ni badflag,-5
 st 0,len2
op55 equ *
 tm badflag,X'FF'
 bz op80
*
* here when bad input line.
* report the bad news: bad operation or operands
*
 l 9,bdcount
 a 9,=f'1'
 st 9,bdcount
 la 7,badopers
 la 1,outline
 la 0,badinp	report input lineno
 l 15,=v(catstr)
 balr 14,15
 l 0,rcount
 l 15,=V(catint)
 balr 14,15
 la 0,badinp2
 l 15,=v(catstr)
 balr 14,15
 tm badflag,1	bad operation?
 bz op71
 la 0,badoper0
 l 15,=v(catstr)
 balr 14,15
 l 0,word1
 l 15,=v(catstr)
 balr 14,15
 lr 0,7
 l 15,=v(catstr)
 balr 14,15
op71 equ *
 tm badflag,64	operands way too big?
 bz op72
 la 0,badway2
 l 15,=v(catstr)
 balr 14,15
op72 equ *
 tm badflag,2	operand1 bad?
 bz op74
 la 0,badoper1
 l 15,=v(catstr)
 balr 14,15
 l 0,word2
 l 15,=v(catstr)
 balr 14,15
 lr 0,7
 l 15,=v(catstr)
 balr 14,15
op74 equ *
 tm badflag,4	operand2 bad?
 bz op75
 la 0,badoper2
 l 15,=v(catstr)
 balr 14,15
 l 0,word3
 l 15,=v(catstr)
 balr 14,15
 lr 0,7
 l 15,=v(catstr)
 balr 14,15
op75 equ *
 tm badflag,128	trailing garbage?
 bz op76
 la 0,badxtra
 l 15,=v(catstr)
 balr 14,15
op76 equ *
 s 1,=F'2'	erase redundant trailing comma and nul
 mvc 0(3,1),=C'   '
 b op90
*
* do operation here.
*
op80 equ *
 l 9,opcount
 a 9,=f'1'
 st 9,opcount
 xr 4,4	ignore what we can
 bctr 4,0
 spm 4
 l 4,opidx	operation index
 sll 4,1	times 6
 lr 6,4
 sll 4,1
 ar 6,4
 l 4,len1	or len-1's together
 st 4,len3
 bctr 4,0
 cli opidx+3,6	extbl==edmk?
 be op95	then don't add len2 in
 sll 4,4
 l 5,len2
 bctr 5,0
 ar 4,5
op95 equ *
 mvc operand3(op3len),operand1
 mvi trapflag+3,255
 lm 15,0,catproto	prepare to trap exceptions
 la 1,trapsave
 balr 14,15
 l 1,r1proto
 la 3,operand3
 la 2,operand2
 ex 4,extbl(6)	do it!
do10 equ *
 st 1,saver1
 la 3,c'0'	format/save cc
 bc 10,do50	branch if cc=0 or c=2
 la 3,1(3)	otherwise 1,3 make r3 odd
do50 equ *
 bc 12,do55	branch if cc=0 or cc=1
 la 3,2(3)	otherwise 2,3: bump r3
do55 equ *
 stc 3,cc
 l 15,catproto	=v(pgnttrp) cancel trap
 xr 0,0
 xr 1,1
 spm 0	clear program mask along the way
 balr 14,15
 tm trapflag+3,255	count exceptions
 bo do60
 l 9,excount
 a 9,=f'1'
 st 9,excount
do60 equ *
 la 1,guard2	make sure guard bytes not clobbered
 la 2,4
 bal 3,chkover
 oi badflag+1,1	skipped if no problem
 la 1,guard3
 l 2,len2
 sr 1,2
 la 2,4(2)
 bal 3,chkover
 oi badflag+1,2	maybe skipped
 la 1,guard4
 l 2,len3
 sr 1,2
 la 2,4(2)
 bal 3,chkover
 oi badflag+1,4	maybe skipped
*
* format results to print
*
 la 1,outline
 la 0,lab3	operation
 l 15,=V(catstr)
 balr 14,15
 l 0,word1
 l 15,=V(catstr)
 balr 14,15
 la 0,lab1	operand1
 l 15,=V(catstr)
 balr 14,15
 la 2,operand1
 l 0,len1
 l 15,=V(cathexst)
 balr 14,15
 la 0,lab2	operand2
 l 15,=V(catstr)
 balr 14,15
 la 2,operand2
 l 0,len2
 l 15,=V(cathexst)
 balr 14,15
 la 0,lab6	operand3
 l 15,=V(catstr)
 balr 14,15
 la 2,operand3
 l 0,len3
 l 15,=V(cathexst)
 balr 14,15
 la 0,lab7	cc
 l 15,=V(catstr)
 balr 14,15
 mvc 0(1,1),cc
 mvi 1(1),0
 la 1,1(1)
 l 2,saver1	r1
 c 2,r1proto
 bz pr24
 la 0,lab10		if it was altered
 l 15,=V(catstr)
 balr 14,15
 l 0,r1a24
 cli saver1,r1cc	a24 does not touch
 bz pr21		top byte of r1
 l 0,r1a31
 s 1,=f'4'
pr21 equ *
 mvi 0(1),C'-'
 sr 0,2
 bp pr22
 mvi 0(1),C'+'
 lcr 0,0
pr22 equ *
 la 1,1(1)
 l 15,=V(catint)
 balr 14,15
pr24 equ *
 tm badflag+1,x'ff'	overflow
 bz pr40
 la 0,lab4
 l 15,=V(catstr)
 balr 14,15
 lh 0,badflag
 l 15,=V(catint)
 balr 14,15
pr40 equ *
 tm trapflag+3,255	if an exception
 bo pr50
 mvc 0(lab9len,1),lab9
 bal 3,getilc
 c 0,=f'2'	if it's not 4 bytes
 be pr25
 la 1,lab9len(1)
 l 15,=V(catint)
 balr 14,15
 b pr30
pr25 equ *
 mvi 0(1),0
pr30 equ *
 la 0,lab5		report intcode
 l 15,=V(catstr)
 balr 14,15
 bal 3,getxcode
 l 15,=V(catint)
 balr 14,15
 lr 4,1
 la 0,lab8		and iar
 l 15,=V(catstr)
 balr 14,15
 bal 3,getiar
 l 2,=a(extbl)
 sr 0,2
 bnl pr45
 s 1,=f'3'
 lr 2,1
 mvi 0(2),C'+'
 a 0,=a(extbl-do10)
 be pr48		if it's not do10
 bl pr45
 la 1,1(2)
pr45 equ *
 l 15,=V(catint)
 balr 14,15
 b pr50
pr48 equ *
 mvi 0(4),0	backup and nul terminate
 lr 1,4	if not reporting iar
pr50 equ *
*
* report results and loop
*
op90 equ *
 la 9,outline	have something to print
 lr 8,1
 sr 8,9	get its length
 b again2
*
* check guard bytes
* (1)=guard bytes (should all be x'a5')
* 2=len
* 3=return addr.
* skips 4 bytes on return if all ok
*
chkover equ *
 cli 0(1),x'a5'
 bnzr 3
 la 1,1(1)
 bct 2,chkover
 b 4(3)
*
* fetch int code from trapsave,trapflag
* pass: 3=ret addr
* return: code in 0
*
getxcode equ *
 tm trapsave+1,8	EC bit set?
 bz gx10
 lh 0,trapflag+6	int code came back in r2
 br 3
gx10 equ *
 lh 0,trapsave+2	int code in BC mode psw
 br 3
*
* fetch next instruction address from psw in trapsave
* pass: 3=ret addr
* return: code in 0
*
getiar equ *
 l 0,trapsave+4
 n 0,=X'7fffffff'
 tm trapsave+1,8	EC bit set?
 bnzr 3
 n 0,=X'00ffffff'
 br 3
*
* fetch ilc from trapsave,trapflag
* pass 3=ret addr
* return: ilc in 0 (should be: 0,2,4,6)
*
getilc equ *
 xr 0,0
 tm trapsave+1,8	EC bit set?
 bz gl10
 ic 0,trapflag+5	ilc came back in r2 too
 srl 0,1
 br 3
gl10 equ *
 ic 0,trapsave+4	BC mode ilc
 srl 0,6
 n 0,=f'3'
 br 3
*
* co-routine does I/O
*
* 1. fetch data
* 2. on re-entry, print results.
*
* on co-exit: r9=ptr to input (if any) else 0
* on re-entry: r9=record to print or 0. r8=length of it.
* on EOF proceeds to true-done.
*
setup equ set40
set10 equ *
 l 9,rcount	got a record
 a 9,=f'1'
 st 9,rcount
 la 9,inline
 balr 10,11	switch up with caller
 bal 6,set70	show some results
set40 equ *
 la 1,scargs	fetch input
 la 2,l'inline-1
 sth 2,inlen
 la 2,inline
 st 2,0(1)
 l 15,=V(scards)
 balr 14,15
 mvi inline+80,0
 ltr 15,15
 bz set10
* error (EOF?) on input, so finalize
 xr 9,9		indicate no input
 balr 10,11	switch up with caller
 bal 6,set70	show any final results
 b done
*
* logic to punch results.
* here,
*  6=return back to co-routine
*  9=buffer to print (consumed)
*  8=length of it (consumed)
*  11=co-routine entry
* *12=dp4
* *13=work
* used internally
*  0 (calling spunch)
*  1 temp
*  2=outcard or outcard+4
*  3=outcard
*  10=count (per line)
*  1 (calling spunch)
*  15 (calling spunch)
*
set70 equ *
 ltr 9,9
 bzr 6
 la 1,spargs
 la 3,outcard
 lr 2,3
 st 2,0(1)
set72 equ *
 mvi outcard,C' '
 mvc outcard+1(79),outcard
 la 10,outcard+72
 sr 10,2
 cr 10,8
 bnh set75
 lr 10,8
set75 equ *
 lr 1,10
 bctr 1,0
 ex 1,set94
 la 1,0(2,10)
 sr 1,3
 sth 1,outlen
*
* l 15,=v(sercom)
* balr 14,15
*
 la 1,spargs
 l 15,=V(spunch)
 balr 14,15
 ltr 15,15
 bnz set95
 la 2,outcard+4
 ar 9,10
 sr 8,10
 bnz set72
 br 6
set94 mvc 0(0,2),0(9)
set95 equ *
 oi fatal,1
*
* report summary
*
done equ *
 la 1,outline
 tm fatal,1
 bz dn05
 la 0,ft10
 l 15,=V(catstr)
 balr 14,15
 b dn70
dn05 equ *
 l 0,rcount	number records read
 l 15,=V(catint)
 balr 14,15
 la 0,sum1
 l 15,=V(catstr)
 balr 14,15
 la 6,1
 c 6,rcount
 bz dn10
 mvi 0(1),C's'
 ar 1,6
dn10 equ *
 la 0,sum1a
 l 15,=V(catstr)
 balr 14,15
 l 0,bdcount	bad records
 l 15,=V(catint)
 balr 14,15
 la 0,sum2
 l 15,=V(catstr)
 balr 14,15
 c 6,bdcount
 bz dn20
 mvi 0(1),C's'
 ar 1,6
dn20 equ *
 la 0,sum0
 l 15,=V(catstr)
 balr 14,15
 l 0,opcount	operation count
 l 15,=V(catint)
 balr 14,15
 la 0,sum3
 l 15,=V(catstr)
 balr 14,15
 c 6,opcount
 bz dn30
 mvi 0(1),C's'
 ar 1,6
dn30 equ *
 la 0,sum0
 l 15,=V(catstr)
 balr 14,15
 l 0,excount	exception count
 l 15,=V(catint)
 balr 14,15
 la 0,sum4
 l 15,=V(catstr)
 balr 14,15
 c 6,excount
 bz dn40
 mvi 0(1),C's'
 ar 1,6
dn40 equ *
 la 0,sum0
 l 15,=V(catstr)
 balr 14,15
 lr 8,1
 s 8,=F'2'	ignore trailing ", "
dn70 equ *
 la 9,outline
 sr 8,9
 la 1,spargs	send to console
 st 9,0(1)
 sth 8,outlen
 l 15,=v(sercom)
 balr 14,15
*
* and finish up
*
 lr 1,13
 l 13,dp1save+4
 drop 13
 la 0,worklen
 l 15,=v(freespace)
 balr 14,15
 lm 14,12,12(13)
 drop 12
 xr 15,15
 br 14
*
* trap program interrupts from decimal instruction here
* 15 = here.
* 14 = exit to default action (failure).
* 1=trapsave
* (if saved psw is EC, 2 contains ilc,intcode, 3 could have dxd)
* for z390: careful!  returns EC mode psw, and returns WRONG iar.
*
ontrap equ *
 using *,15
 l 12,=a(dp4)	recover our base address
 drop 15
 using dp4,12
 lr 13,1	and work
 s 13,=a(trapsave-work)
 using work,13
 tm trapflag+3,255	already got exception?
 bno ot90
 stm 1,3,trapflag
 lr 2,1	copy trap'd registers
 la 1,traprest
 mvc 0(72,1),0(2)
 l 15,catproto	prepare to return
 tm 1(1),8	EC bit set?
 bz ot30
 mvc 4(4,1),=a(do10)	force ret addr
 xr 0,0	and don't re-enable trap
ot30 equ *
 mvi 0(1),x'ff'	flag to resume exec
 balr 14,15
ot90 equ *
 dc y(0)	should never reach
*
** must be continuous (and match scargs/spargs)
inproto dc a(0,inlen-work,zero-work,lineno-work)
outproto dc a(0,outlen-work,zero-work,lineno-work)
ioprotln equ *-inproto
** end must be contiguous
catproto dc v(pgnttrp),a(ontrap)
*
* table of operations.  will index with
*  offset from operator found in optbl.
*
extbl ap 0(1,3),0(1,2)
 sp 0(1,3),0(1,2)
 mp 0(1,3),0(1,2)
 dp 0(1,3),0(1,2)
 zap 0(1,3),0(1,2)
 cp 0(1,3),0(1,2)
 edmk 0(1,3),0(2)
* operations.  order must match extbl
optbl dc c'+-*/=<%',X'0'
*
lab1 dc C' i1=',X'0'
lab2 dc C' i2=',X'0'
lab3 dc C'op=',X'0'
lab4 dc C' overrun=',X'0'
lab5 dc C' ex=',X'0'
lab6 dc C' -> o=',X'0'
lab7 dc C' cc=',X'0'
lab8 dc C' iar=ex+',X'0'
lab9 dc C' ilc='
lab9len equ *-lab9
lab10 dc C' r1=(24)',X'0'
badinp dc C'record ',X'0'
badinp2 dc C' is bad, ',X'0'
badway2 dc C'operand too big, ',X'0'
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
sum4 dc C' exception',X'0'
ft10 dc C'fatal error, can''t write to punch',X'0'
r1cc equ x'aa'	r1 canary for edmk
r1proto dc 0f,al1(r1cc),xl3'555aa5'
 ltorg
*
* working storage (impure)
*
work dsect
dp1save ds 18f
 ds 1f
inline ds cl181
 ds 1f
outline ds cl255
 ds 1f
outcard ds cl80
 ds 1f
fatal ds 1f
word1 ds 1f
word2 ds 1f
word3 ds 1f
word4 ds 1f
sw ds 1f
badflag ds 1f
temp ds cl181
trapflag ds 3f
trapsave ds 18f
traprest ds 18f
r1a24 ds 1f
r1a31 ds 1f
opidx ds 1f
len1 ds 1f
len2 ds 1f
len3 ds 1f
guard1 ds 1f
operand1 ds cl40
guard2 ds 1f
operand2 ds cl40
guard3 ds 1f
operand3 ds cl40
guard4 ds 1f
guardlen equ *-guard1
op3len equ *-operand3
counts equ *
rcount ds 1f
bdcount ds 1f
opcount ds 1f
excount ds 1f
countln equ *-counts
zero ds 1f
lineno ds 1f	must be immediately after zero
inlen dc 1h
outlen dc 1h
** order must match inproto/outproto
scargs ds 4f	must be contiguous
spargs ds 4f	for runtime relocation
** end order must match
saver1 ds 1f
cc ds 1c
worklen equ *-work
 end
