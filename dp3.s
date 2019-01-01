*
* read in data
* interpret operation
* print result, cc.
* do it again unmasked.
* if exception, say what.
*
 rmode 24
dp3 csect
 stm 14,12,12(13)
 lr 12,15
 using dp3,12
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
 mvi outline,C' '
 mvc outline+1(79),outline
 la 0,outline
 la 1,lab1
 l 15,=V(catstr)
 balr 14,15
 l 1,word1
 l 15,=V(catstr)
 balr 14,15
 la 1,lab2
 l 15,=V(catstr)
 balr 14,15
 l 1,word2
 l 15,=V(catstr)
 balr 14,15
 la 1,lab3
 l 15,=V(catstr)
 balr 14,15
 l 1,word3
 l 15,=V(catstr)
 balr 14,15
 la 1,lab4
 l 15,=V(catstr)
 balr 14,15
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
 using dp3,12
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
lab1 dc C'First word is <',X'0'
lab2 dc C'> and second word is <',X'0'
lab3 dc C'> and the 3rd word is <',X'0'
lab4 dc C'>',X'0'
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
wtorec dc 1f,80c
worklen equ *-work
 end dp3
