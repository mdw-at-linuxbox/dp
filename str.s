*
* read in data
* interpret operation
* print result, cc.
* do it again unmasked.
* if exception, say what.
*
 rmode 24
 entry skipspc,getword,catstr,strlen,catint
str csect
 balr 15,0
 lpsw 0
 cnop 0,4
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
 cnop 0,4
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
 br 14
gw90 mvc 0(0,2),0(3)
 drop 15
 cnop 0,4
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
 drop 15
 cnop 0,4
*
* skip blanks.
*
strlen equ *
 using *,15
 lr 0,1
 b st20
st10 equ *
 al 1,=f'1'
st20 equ *
 cli 0(1),0
 bnz st10
 sr 0,1
 ar 1,0
 lcr 0,0
 br 14
 drop 15
 cnop 0,4
*
* put int
* 1 = num
* (0) = put printable number here
*
catint equ *
 using *,12
 stm 14,12,12(13)
 lr 12,15
 getmain r,lv=ciwlen
 st 13,4(1)
 lr 13,1
 using ciwork,13
*
 l 4,4(13)
 l 2,20(4)
 l 1,24(4)
 cvd 1,p4
 mvc p5(p8len),p8
 ed p5(p8len-1),p4
 la 1,p5
 la 3,1
 b ci20
ci10 equ *
 la 1,1(1)
ci20 equ *
 cli 0(1),C' '
 bz ci10
 tm p4+7,1
 bz ci30
 sr 1,3
 mvi 0(1),C'-'
ci30 equ *
 ic 0,0(1)
 stc 0,0(2)
 ar 2,3
 ar 1,3
 ltr 0,0
 bnz ci30
 st 2,20(4)
*
 lr 1,13
 l 13,cisave+4
 drop 13
 freemain r,a=(1),lv=ciwlen
 lm 14,12,12(13)
 drop 12
 sr 15,15
 br 14
p8 dc X'40',3X'20',X'6B',3X'20',X'6B',3X'20',X'6B',3X'20',X'6B',2X'20',X'21',X'0'
p8len equ *-p8
 cnop 0,4
*
 ltorg
ciwork dsect
cisave ds 18f
p4 ds 1d
p5 ds 3d
ciwlen equ *-ciwork
 end
