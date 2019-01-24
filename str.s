*
* basic string operations
* to parse input and generate output
*
 entry skipspc,getword,catstr,strlen,catint,cathexst,index
 entry gethexst,cathex,getint
str csect
 balr 15,0
 lpsw 1
 cnop 0,4
*
* skip blanks.
* (1) = string
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
* advances both 0 and 1.
*
getword equ *
 using *,15
 stm 2,4,28(13)
 lr 2,0
 lr 3,1
 la 4,1
gw10 equ *
 cli 0(1),0
 bz gw80
 cli 0(1),C' '
 bz gw80
 la 1,1(1)
 b gw10
gw80 equ *
 sr 1,3
 bnh gw85
 sr 1,4
 ex 1,gw90
 ar 1,4
gw85 equ *
 ar 2,1
 ar 1,3
 mvi 0(2),0
 la 0,1(2)
 lm 2,4,28(13)
 xr 15,15
 br 14
gw90 mvc 0(0,2),0(3)
 drop 15
 cnop 0,4
*
* get hex string
* entry:
*  0=output (sufficient size)
*  1=input - string of hex digits, null terminated
* exit:
*   15=4 if bad number
*  or
*   15=0
*   0=len (bytes) of converted string
* reg usage,
*  2 point to output string
*  1 point to input string
*  3 digit count
*  4 byte count(-1)
*  5 unpack len
*
gethexst equ *
 using *,15
 stm 1,5,24(13)
*
 lr 2,0
 xr 0,0
 lr 3,1
 la 4,1
 b gh20
gh10 equ *
 ar 3,4
gh20 tm 0(3),240
 bnz gh10
 s 3,24(13)
 ar 4,3
 srl 4,1
 st 4,20(13)
 stc 3,19(13)
 tm 19(13),1
 bz gh30
 mvi 0(2),0
 bctr 1,0
 b gh40
gh30 ic 5,0(1)
 tm 0(1),240
 bo gh35
 a 5,=F'9'
gh35 sll 5,4
 stc 5,0(2)
gh40 ic 5,1(1)
 tm 1(1),240
 bo gh45
 a 5,=F'9'
gh45 n 5,=F'15'
 ex 5,gh95
 la 1,2(1)
 la 2,1(2)
 bct 4,gh30
*
 lm 0,5,20(13)
 drop 15
 xr 15,15
 br 14
gh95 oi 0(2),0
 cnop 0,4
*
* get integer
* leading spaces, optional -, optional 0 or 0x, digits 0-9a-fA-F
* enter: 1=str
* exit:
* 0=integer, 1=str (updated)
* 15=0 | 4
*
getint equ *
 using *,15
 stm 2,4,28(13)
 lr 2,0
 la 3,1
 la 2,10
gi10 equ *
 mvi 71(13),64	plus, no digits seen yet
 cli 0(1),c' '
 bne gi15
 la 1,1(1)
 b gi10
gi15 equ *
 cli 0(1),c'-'
 bne gi20
 oi 71(13),128	negative
gi20 equ *
 cli 0(1),c'0'
 bne gi35
 cli 1(1),c'x'
 be gi23
 cli 1(1),c'X'
 bne gi25
gi23 equ *
 la 2,16
 la 1,2(1)
 b gi35
gi25 equ *
 ni 71(13),255-64	saw a digit
 la 2,8
 la 1,1(1)
gi35 equ *
 xr 0,0
 st 2,72(13)
gi40 equ *
 tm 0(1),x'ff'
 be gi70
 xr 3,3
 ic 3,0(1)
 cli 0(1),c'0'
 bl gi50
 cli 0(1),c'9'
 bh gi50
 s 3,=A(C'0')
 b gi60
gi50 equ *
 cli 0(1),c'a'
 bl gi55
 cli 0(1),c'f'
 bh gi55
 s 3,=A(C'a'-10)
 b gi60
gi55 equ *
 cli 0(1),c'A'
 bl gi75
 cli 0(1),c'F'
 bh gi75
 s 3,=A(C'A'-10)
gi60 equ *
 clr 3,2
 bnl gi72
gi71 equ *
 ni 71(13),255-64	saw a digit
 mh 0,74(13)
 ar 0,3
 la 1,1(1)
 b gi40
gi72 equ *
* bcr 0,0
* bcr 0,1
* b gi71
gi75 equ *
gi70 equ *
 tm 71(13),128	negative?
 bz gi80
 lcr 0,0
gi80 equ *
 xr 2,2
 tm 71(13),64	saw no digits?
 bz gi90
 la 2,4
gi90 equ *
 lr 15,2
 lm 2,4,28(13)
 br 14
 drop 15
 cnop 0,4
*
* copy (0) to (1)
* null-terminate (1) - advance 1 to null
*
catstr equ *
 using *,15
 stm 2,3,28(13)
 lr 2,0
 xr 0,0
 la 3,1
cs10 equ *
 ic 0,0(2)
 stc 0,0(1)
 ar 1,3
 ar 2,3
 ltr 0,0
 bnz cs10
 sr 1,3
 lm 2,3,28(13)
 xr 15,15
 br 14
 drop 15
 cnop 0,4
*
* string length
* pass:
*  (1) = string (null terminated)
* return:
*  0 = string length
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
 xr 15,15
 br 14
 drop 15
 cnop 0,4
*
* find character in string
*pass:
* 0=char
* (1) = string
*return:
* if found,
*  0=pointer to char in string
*  15=0
* if not found,
*  0=0
*  15=4
*
index equ *
 using *,15
 stm 1,2,24(13)
 lr 2,0
 b in20
in10 equ *
 a 1,=f'1'
in20 equ *
in30 cli 0(1),0
 bz in90
 ex 2,in30
 bnz in10
 lr 0,1
 xr 1,1
in80 lr 15,1
 lm 1,2,24(13)
 br 14
in90 xr 0,0
 la 1,4
 b in80
 drop 15
 cnop 0,4
*
* put int
* 0 = num
* (1) = put printable number here
*
catint equ *
 using *,12
 stm 14,12,12(13)
 lr 12,15
 la 1,ciwlen
 la 0,3
 l 15,=v(getspace)
 balr 14,15
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using ciwork,13
*
 l 4,4(13)
 l 1,24(4)
 l 2,20(4)
 cvd 2,p4
 mvc p5(p8len),p8
 ed p5(p8len-1),p4
 la 2,p5
 la 3,1
 b ci20
ci10 equ *
 la 2,1(2)
ci20 equ *
 cli 0(2),C' '
 bz ci10
 tm p4+7,1
 bz ci30
 sr 2,3
 mvi 0(2),C'-'
ci30 equ *
 ic 0,0(2)
 stc 0,0(1)
 ar 1,3
 ar 2,3
 ltr 0,0
 bnz ci30
 sr 1,3
 st 1,24(4)
*
 lr 1,13
 l 13,cisave+4
 drop 13
 la 0,ciwlen
 l 15,=v(freespace)
 balr 14,15
 lm 14,12,12(13)
 drop 12
 xr 15,15
 br 14
p8 dc X'40',3X'20',X'6B',3X'20',X'6B',3X'20',X'6B',3X'20',X'6B',X'202120',X'0'
p8len equ *-p8
 cnop 0,4
*
* put hex number
* 0= hex number
* (1) = put printable number here, update, null terminate
*
cathex equ *
 using *,15
 stm 2,3,28(13)
*
 la 3,20(1)
 mvi 0(3),0
cx10 equ *
 la 2,15
 nr 2,0
 ar 2,15
 bctr 3,0
 mvc 0(1,3),hexdig-cathex(2)
 srl 0,4
 n 0,=X'0fffffff'
 bne cx10
 la 2,20(1)
 sr 2,3
 ex 2,cx20
 ar 1,2
*
 lm 2,3,28(13)
 drop 15
 xr 15,15
 br 14
cx20 mvc 0(0,1),0(3)
 cnop 0,4
*
* put hex string
* 2 = hex string
* 0 = length hex string
* (1) = put printable number here - updated
*
cathexst equ *
 using *,15
 stm 2,3,24(13)
*
ch10 equ *
 ic 3,0(2)
 stc 3,1(1)
 srl 3,4
 stc 3,0(1)
 nc 0(2,1),hexmask
 tr 0(2,1),hexdig
 la 1,2(1)
 la 2,1(2)
ch50 equ *
 bct 0,ch10
*
 mvi 0(1),0
 lr 0,1
 lm 2,3,24(13)
 drop 15
 xr 15,15
 br 14
hexdig dc C'0123456789abcdef'
hexmask dc X'0F0F'
 cnop 0,4
*
 ltorg
ciwork dsect
cisave ds 18f
p4 ds 1d
p5 ds 3d
ciwlen equ *-ciwork
 end
