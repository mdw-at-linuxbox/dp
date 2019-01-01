*
* read in data
* interpret operation
* print result, cc.
* do it again unmasked.
* if exception, say what.
*
 rmode 24
dp2 csect
 stm 14,12,12(13)
 lr 12,15
 using dp2,12
 getmain r,lv=worklen
 st 13,4(1)
 lr 13,1
 using work,13
*
 bal 11,setup
 mvi outline,C' '
 mvc outline+1(132),outline
 mvc outline+5(50),inline
 balr 11,10
 balr 11,10
*
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
 using dp2,12
 using work,13
 call ioinit
nextcard equ *
 la 1,scargs
 la 2,inline
 st 2,0(1)
 call scards
 balr 10,11
 la 2,outline
 la 1,spargs
 st 2,0(1)
 call sprint
 balr 10,11
 call iofini
 br 11
outdcb dcb dsorg=ps,macrf=(pm),ddname=sysout,recfm=fba,lrecl=133
openlist open mf=l,(outdcb,output)
clslist close mf=l,(outdcb)
inlen dc f'80'
outlen dc f'133'
lineno dc f'0'
zero dc f'0'
scargs call scards,(0,inlen,zero,lineno),mf=l
spargs call sprint,(0,outlen,zero,lineno),mf=l
 ltorg
work dsect
dp1save ds 18f
inline ds 80c
outline ds 133c
worklen equ *-work
 end dp2
