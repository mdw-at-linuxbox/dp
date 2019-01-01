*
* read in data
* interpret operation
* print result, cc.
* do it again unmasked.
* if exception, say what.
*
 rmode 24
 entry skipspc,getword,catstr
str csect
 balr 15,0
 lpsw 0
*
* skip blanks.
*
skipspc equ *
 using *,15
 cli 0(1),C' '
 bnzr 14
 la 1,1(1)
 b skipspc
 drop 15
*
* copy space or null terminated word from (1) to (0)
* null-terminate word that is copied
* advance both 0 and 1.
*
getword equ *
 using *,15
 stm 2,3,28(13)
 lr 2,0
 lr 3,1
gw10 equ *
 cli 0(1),0
 bz gw80
 cli 0(1),C' '
 bz gw80
 la 1,1(1)
 b gw10
gw80 equ *
 sr 1,3
 bctr 1,0
 ex 1,gw90
 la 1,1(1)
 ar 2,1
 ar 1,3
 mvi 0(2),0
 la 0,1(2)
 lm 2,3,28(13)
 drop 15
 br 14
gw90 mvc 0(0,2),0(3)
*
* copy (1) to (0)
* null-terminate (0) - advance 0 to null
*
catstr equ *
 using *,15
 stm 2,3,28(13)
 lr 2,0
 xr 0,0
 la 3,1
cs10 equ *
 ic 0,0(1)
 stc 0,0(2)
 ar 2,3
 ar 1,3
 ltr 0,0
 bnz cs10
 lr 0,2
 sr 0,3
 lm 2,3,28(13)
 br 14
 ltorg
** work dsect
** iosave ds 18f
** worklen equ *-work
 end
** *
** * initialize io units
** *
** ioinit equ *
**  stm 14,12,12(13)
**  lr 12,15
**  using ioinit,12
**  getmain r,lv=worklen
**  st 13,4(1)
**  lr 13,1
**  using work,13
** *
**  open mf=(e,openlist)
** *
**  lr 1,13
**  l 13,iosave+4
**  drop 13
**  freemain r,a=(1),lv=worklen
**  lm 14,12,12(13)
**  drop 12
**  sr 15,15
**  br 14
