*
* test memory allocator
*
 copy alequ
*
*
 entry main
 entry getspace,freespace
*
tma csect
*
* entry point
* initialize io, call main, exit.
*
main equ *
 using *,12
 stm 14,12,12(13)
 lr 12,15
 getmain r,lv=worklen
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using work,13
*
 la 1,=a(mypool,mygrow)
 l 15,=v(initaloc)
 balr 14,15
 xr 0,0
 st 0,mypool+(firstp-pool)
*
again equ *
 mvc spargs(16),outproto
 wtor 'tma> ',com,L'com,wtorecb
 wait ecb=wtorecb
 mvi com+64,0
 la 1,com
 l 15,=v(skipspc)
 balr 14,15
 xr 2,2
 tm 0(1),x'ff'
 be again
 cli 0(1),c'a'
 be doalloc
 cli 0(1),c'A'
 be doalloc
 cli 0(1),c'f'
 be dofree
 cli 0(1),c'F'
 be dofree
 cli 0(1),c'p'
 be doprint
 cli 0(1),c'P'
 be doprint
 cli 0(1),c'q'
 be doquit
 cli 0(1),c'Q'
 be doquit
 cli 0(1),c'!'
 be oops
 wto '?'
 b again
oops equ *
 dc y(0)
 cnop 0,4
doprint ds 0h
 using pool,6
 la 6,mypool
 la 0,outline
 la 1,lab1
 l 15,=v(catstr)
 balr 14,15
 l 1,firstp
 l 15,=v(cathex)
 balr 14,15
 la 1,lab2
 l 15,=v(catstr)
 balr 14,15
 l 1,lastp
 l 15,=v(cathex)
 balr 14,15
 la 1,lab3
 l 15,=v(catstr)
 balr 14,15
 l 1,poolsize
 s 1,freesize
 l 15,=v(catint)
 balr 14,15
 la 1,lab4
 l 15,=v(catstr)
 balr 14,15
 l 1,poolsize
 l 15,=v(catint)
 balr 14,15
 lr 1,0
 mvi 0(1),c'-'
 la 0,1(1)
 l 1,freesize
 l 15,=v(catint)
 balr 14,15
 la 1,lab5
 l 15,=v(catstr)
 balr 14,15
*
 la 1,outline
 st 1,spargs
 la 1,outlen
 st 1,spargs+4
 sr 0,1
 st 0,outlen
 la 1,spargs
 l 15,=a(sercom)
 balr 14,15
 la 7,freelist
 b dp30
*
dp20 equ *
 la 0,outline
 lr 1,0
 mvc 0(2,1),=C'0x'
 la 0,2(1)
 lr 1,8
 l 15,=v(cathex)
 balr 14,15
 lr 1,0
 mvi 0(1),c'/'
 la 0,1(1)
 l 1,4(8)
 l 15,=v(catint)
 balr 14,15
*
 la 1,outline
 st 1,spargs
 la 1,outlen
 st 1,spargs+4
 sr 0,1
 st 0,outlen
 la 1,spargs
 l 15,=a(sercom)
 balr 14,15
 lr 7,8
dp30 equ *
 l 8,0(7)
 ltr 8,8
 be dp40
 b dp20 
 drop 6
dp40 equ *
 b again
dp10 equ *
 b again
lab1 dc c'firstp = 0x',x'0'
lab2 dc c', lastp = 0x',x'0'
lab3 dc c', inuse = ',x'0'
lab4 dc c' (',x'0'
lab5 dc c')',x'0'
 cnop 0,4
doalloc ds 0h
 la 1,1(1)
 l 15,=v(getint)
 balr 14,15
 lr 6,0
 la 1,alb3
 ltr 15,15
 bnz al70
 la 0,0
 lr 1,6
 l 15,=a(getmem)
 lr 8,1
 la 0,outline
 la 1,alb1
 ltr 15,15
 bne al40
 la 1,alb2
 l 15,=v(catstr)
 balr 14,15
 lr 1,8
 l 15,=v(cathex)
 balr 14,15
 lr 1,0
 mvi 0(1),c'/'
 la 0,1(1)
 l 1,0(8)
 l 15,=v(catint)
 balr 14,15
 b al90
al40 equ *
 l 15,=v(catstr)
 balr 14,15
 lr 1,6
 l 15,=v(catint)
 balr 14,15
 b al90
al70 equ *
 la 0,outline
 l 15,=v(catstr)
 balr 14,15
 lr 1,6
 l 15,=v(catint)
 balr 14,15
 lr 1,0
 mvi 0(1),c'='
 la 0,1(1)
 lr 1,6
 l 15,=v(cathex)
 balr 14,15
*
al90 equ *
 la 1,outline
 st 1,spargs
 la 1,outlen
 st 1,spargs+4
 sr 0,1
 st 0,outlen
 la 1,spargs
 l 15,=a(sercom)
 balr 14,15
 b again
alb1 dc c'can''t allocate, ',x'0'
alb2 dc c'alloc: 0x',x'0'
alb3 dc c'alloc fails, 0x',x'0'
 cnop 0,4
dofree ds 0h
 la 1,1(1)
 l 15,=v(getint)
 balr 14,15
 lr 6,0
 la 1,fab1
 ltr 15,15
 bnz al40
 l 15,=v(getint)
 balr 14,15
 lr 7,0
 la 1,fab2
 ltr 15,15
 bnz al70
*
 lr 1,6
*
 la 15,4
* l 15,=a(freemem)
* balr 15,14
*
 lr 0,7
 la 0,outline
 la 1,fab3
 ltr 15,15
 be fr40
 la 1,fab4
fr40 equ *
 l 15,=v(catstr)
 balr 14,15
 lr 1,6
 l 15,=v(cathex)
 balr 14,15
 lr 1,0
 mvi 0(1),c'/'
 la 0,1(1)
 lr 1,7
 l 15,=v(catint)
 balr 14,15
 b al90
fab1 dc c'free: not a number',x'0'
fab2 dc c'free: not a number too',x'0'
fab3 dc c'free 0x',x'0'
fab4 dc c'cannot free 0x',x'0'
*
doquit equ *
 lr 1,13
 l 13,iosave+4
 drop 13
 freemain r,a=(1),lv=worklen
 lm 14,12,12(13)
 drop 12
 br 14
*
* getspace
*pass:
* 0=switches
* 1=length
*return:
* on success,
*  r15=0
*  r1=addr (r1)=len
* on failure,
*  r15=4
*
getmem ds 0d
 using *,15
 l 15,=a(mypool)
 using pool,15
 b alalloc
 drop 15
 cnop 0,4
*
* freespace
* pass:
*  0=len
*  1=loc
* returns:
*  r15=0 | 4
*
freemem ds 0d
 using *,15
 l 15,=a(mypool)
 using pool,15
 b alfree
 drop 15
 cnop 0,4
*
* mygrow
* enter:
*  1=suggested start
*  0=len
* exit:
*  1=start
*  15=0
*
mygrow ds 0f
 using *,12
 stm 14,12,12(13)
 lr 12,15
 lr 1,0
 getmain r,lv=(1)
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using work,13
*
* getspace
*pass:
* 0=switches
* 1=length
*return:
* on success,
*  r15=0
*  r1=addr (r1)=len
* on failure,
*  r15=4
*
getspace ds 0d
 using *,15
 getmain r,lv=(1)
 ltr 15,15
 bner 14
 st 0,0(1)
 br 14
 drop 15
 cnop 0,4
*
* freespace
* pass:
*  0=len
*  1=loc
* returns:
*  r15=0 | 4
*
freespace ds 0d
 using *,15
* xr 0,1
* xr 1,0
* xr 0,1
 freemain r,a=(1),lv=(0)
 br 14
 drop 15
*
* tell operator
* parm1 = buffer
* parm2 = length
* parm3 = modifiers (shoudd be zero, ignored)
* parm4 = lineno (ignored)
*
sercom ds 0d
 stm 14,12,12(13)
 lr 12,15
 lr 11,1
 using sercom,12
 getmain r,lv=wtwklen
 st 13,4(1)
 st 1,8(13)
 lr 13,1
 using wtwork,13
*
 l 8,4(11)
 lh 8,2(8)
 l 9,0(11)
 xc wtorec+2(2),wtorec+2
 lr 7,8
 la 7,4(7)
 sth 7,wtorec
 ltr 8,8
 bz sr10
 bctr 8,0
 ex 8,sr90
sr10 equ *
 la 1,wtorec
 wto mf=(E,(1))
*
 lr 1,13
 l 13,wtsave+4
 drop 13
 freemain r,a=(1),lv=wtwklen
 lm 14,12,12(13)
 drop 12
 xr 15,15
 br 14
 using wtwork,13
sr90 mvc wtorec+4(0),0(9)
 drop 13
 cnop 0,4
 cnop 0,4
 ds 0d
lineno dc f'0'
zero dc f'0'
outproto dc a(0,0,zero,lineno)
 ltorg
*
mypool ds 0f
 org mypool+poollen
 ds f'00'
*
work dsect
iosave ds 18f
wtorecb ds f'0'
com ds cl64
 ds 0f	hold nul after com
outlen ds 1f
spargs ds 4f
outline ds cl250
worklen equ *-work
wtwork dsect
wtsave ds 18f
wtorec ds 1f,80c
wtwklen equ *-work
 end
