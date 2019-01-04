*
* read in data
* interpret operation
* print result, cc.
* do it again unmasked.
* if exception, say what.
*
 entry getpacked
pdc csect
 balr 15,0
 lpsw 1
 cnop 0,4
*
* getpacked
* entry:
*  0=output to rec' packed string (should be 16 bytes)
*  1=input - possible +-, then string of digits.
* exit:
*   15=4 if bad number
*  or
*   15=0
*   0=len (bytes) of packed string.
* reg usage:
*  2 point to output string
*  1 point to input string
*  4 point to old save area
*  5 'c' or 'd' - sign nybble.
*  6 digit count
*  7 byte len(-1)
*  8 unpack len
*
getpacked equ *
 using *,12
 stm 14,12,12(13)
 lr 12,15
 la 1,gpwlen
 la 0,3
 l 15,=v(getspace)
 balr 14,15
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using gpwork,13
*
 xr 6,6
 la 5,X'FC'
 l 4,4(13)
 l 2,20(4)
 l 1,24(4)
 cli 0(1),C'+'
 bz gp10
 cli 0(1),C'-'
 bnz gp20
 la 5,X'FD'
gp10 equ *
 la 1,1(1)
gp20 equ *
 cli 0(1),C'0'
 bl gp30
 cli 0(1),C'9'
 bh gp90
 bctr 6,0
 b gp10
gp30 equ *
 cli 0(1),0
 bnz gp90
 lcr 6,6
 bz gp90
 la 7,1
 or 7,6
 srl 7,1
 la 7,1(7)
 c 7,=F'16'
 bnl gp90
 lr 8,7
 bctr 8,0
 sll 8,4
 or 8,6
 bctr 8,0
 sr 1,6
 ex 8,gp95
 ar 2,7
 bctr 2,0
 ex 5,gp96
 st 7,20(4)
 mvc 16(4,4),=F'0'
 b gp92
*
gp90 mvc 16(4,4),=F'4'
*
gp92 equ *
 lr 0,13
 l 13,gpsave+4
 drop 13
 la 1,gpwlen
 l 15,=v(freespace)
 balr 14,15
 lm 14,12,12(13)
 br 14
gp95 pack 0(0,2),0(0,1)
gp96 ni 0(2),0
 drop 12
*
 ltorg
gpwork dsect
gpsave ds 18f
gpwlen equ *-gpwork
 end
