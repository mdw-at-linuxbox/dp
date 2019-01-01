 rmode 24
dp1 csect
 stm 14,12,12(13)
 lr 12,15
 using dp1,12
 getmain r,lv=worklen
 st 13,4(1)
 lr 13,1
 using work,13
*
 open mf=(e,openlist)
 la 1,outdcb
 put (1),hello
 close mf=(e,clslist)
*
 lr 1,13
 l 13,dp1save+4
 drop 13
 freemain r,a=(1),lv=worklen
 lm 14,12,12(13)
 drop 12
 sr 15,15
 br 14
outdcb dcb dsorg=ps,macrf=(pm),ddname=sysout,recfm=fba,lrecl=133
openlist open mf=l,(outdcb,output)
clslist close mf=l,(outdcb)
hello dc cl128'HELLO WORLD'
 ltorg
work dsect
dp1save ds 18f
worklen equ *-work
 end dp1
