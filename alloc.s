*
* memory allocation
*
 copy alequ
 entry initaloc
*
* memory free list elements
*
align equ 7
blob dsect
 ds 1f	next
 ds 1f	len
bloblen equ *-blob
*
alloc csect
 balr 15,0
 lpsw 1
 cnop 0,4
*
* enter w/ 0(r1) = data, 4(1) = growfunc
* returns rc=0
* fills out "data" with a pool.
*
initaloc equ *
 using *,15
 stm 14,3,12(13)
 lm 2,3,0(1)
 using pool,2
 mvi 0(2),0
 mvc 1(poollen-1,2),0(2)
 st 3,grow
 mvc alnew(4),=a(alloc)
 st 2,alnew+4
 mvc alalloc(protosize),poolproto
 mvc 16(4,3),alsave	zero rc
 lm 14,3,12(13)
 br 14
 drop 2
poolproto equ *
plalloc equ *
 using pool,15
 using alloc,12
 stm 8,14,alreg2
 lm 12,13,alnew
 b intalloc
 using pool-12,15
plfree equ *
 stm 8,14,alreg1
 lm 12,13,alnew
 b intfree
 drop 15
 drop 12
protosize equ *-poolproto
*
* intfree
* entry:
*  13=pool
*  1=(a)
*  0=len
* ret:
*  1=pp or 0
*  15=rc
*
* alreg2 usage: (intgrow and intalloc)
pp equ 15	%r10
u equ 11	%r11
t equ 10	%r0
lena equ 9	%r11
p equ 1		%r12
q equ 8		%r3
* alreg1 usage: (intfree)
*pp equ 15	%r2
*u equ 11
*t equ 10	%r4
*p equ 1	%r3
lenf equ 0	%r4
np equ 9	%r5
prevp equ 8	%r1
*
 using alloc,12
 using pool,13
intfree equ *
 la t,align
 ar p,t	a += ALIGN
 ar lenf,t	lenf += ALIGN
 lcr t,t
 bctr t,0
 nr p,t	a &= ~ALIGN
 nr lenf,t	lenf &= ~ALIGN
 la pp,freelist	pp = &q->freelist
 l np,freelist	np = q->freelist
 xr prevp,prevp	prevp = 0
 b fr10		tail loop while
fr08 equ *	!L3 L4
 lr pp,np	pp = &np->next
 lr prevp,np	prevp = np
 l np,0(np)	np = *np
fr10 equ *	L3
 ltr np,np	while (np &&
 be fr12
 clr p,np	np < a )
 bnl fr08
fr12 equ *	!L7
 ltr prevp,prevp	if (prevpp
 be fr42
fr25 equ *	L5
 lr t,prevp		&& prevp->prevp->lenf > a)
 a t,4(prevp)
 clr p,t
 bl fr30	return 0
fr42 equ *	! L29
 ltr np,np	if (np &&
 be fr50
fr45 equ *	L13
 lr t,p		a + lenf > np)
 ar t,lenf
 clr np,t
 bnl fr48
fr30 equ *	L17
 la pp,0	return 0
 b fr90
fr48 equ *	! L17
 ltr prevp,prevp	if (prevp
 be fr15
fr50 equ *	L14
 l t,4(prevp)		&& prevp+prevp->lenf
 lr u,prevp
 ar u,t
 cr p,u			== a) {
 bne fr15
 ar t,lenf		prevp->lenf += lenf
 st t,4(prevp)
 lr p,prevp		p = prevp;
 b fr55	} else {
fr15 equ *	L8
 st np,0(p)	p=a; p->next = *pp
 st lenf,4(p)	p->lenf = lenf
 st p,0(pp)	*pp = p; }
fr55 equ *	L11
 ltr np,np	if (np
 be fr60
 l u,4(p)	&& p+p->lenf
 lr t,p
 ar t,u
 cr np,t	== np) {
 bne fr60
 l t,0(np)	p->lenf += np->lenf;
 a u,4(np)
 st t,0(p)	p->next = np->next;
 st u,4(p)	}
fr60 equ *	L12
 a lenf,freesize	q->freesize += lenf;
 st lenf,freesize
fr90 equ *	L1
 lr 1,pp	return pp;
 lm 8,14,alreg1
 br 14
*
* grow: out of line from intalloc
* "pass"
*  lena=length
*  13=pool
* "return"
*  pp=result
*
intgrow equ *
 lr t,lena	pp = q->grow(q,lena)
 a t,=A(4095+bloblen)
 n t,=F'-4096'
 l u,lastp
gr10 equ *
 lr 0,t	lena
 lr 1,u	hint
 l 15,grow
 balr 15,14
 ltr 15,15
 be gr20
 la 1,0
 ltr u,u
 la u,0
 bne gr10
 xr p,p	failed; return 0 ptr
 b al94	and rc=4
gr20 equ *
 lr u,1
 lr 0,t
 lr 15,13
 bal 14,alfree
 lr pp,1
 lr u,pp
 ar u,t
 st u,lastp
 lr u,t
 a u,poolsize
 st u,poolsize
 l u,firstp
 ltr u,u
 bne gr90
 st pp,firstp
gr90 equ *
 b al11
*
* intalloc
* pass:
* 1=len
* 0=flags
* 12=base reg
* 13=pool
* exit:
* 1=result
*
 using pool,13
intalloc equ *
 lr lena,1
 la u,align
 ar lena,u	lena += ALIGN
 lcr u,u
 la pp,freelist lr 10,2	pp = &q->freelist
 bctr u,0
 nr lena,u	lena &= ~ALIGN
 l p,freelist	for (p = q->freelist;
* L40
 ltr p,p	p != 0
 be intgrow
al60 equ *	L42
 c lena,4(p)	if (p->lena >= lena) break
 bnh al20 
 lr pp,p	pp = &p->next
al11 equ *	here from intgrow
 l p,0(p)	p = *pp
 lr lena,q
 ltr pp,1	if (!pp) return 0
 be al90
 l p,0(pp)	p = *pp
al20 equ *	L41
 l u,4(p)	p->lena - lena
 la q,bloblen-1
 sr u,lena
 l t,0(p)	if ((p->lena - lena) >= sizeof *p)
 clr u,q
 bnh al70
 lr q,p	q = r + lena
 ar q,lena
 st t,0(q)	q->next = p->next
 st u,4(q)	q->lena = p->lena - lena
 st q,0(pp)	*pp = q
 b al30	} else {
al70 equ *	L44
 st t,0(pp)		*pp = p->next; }
al30 equ *	L45
 st lena,0(p)	*r = lena
 l u,freesize	q->freesize -= lena
 sr u,lena
 st u,freesize
al90 equ *	L39
 xr 15,15
 ltr 1,p	return p
 bne al95
al94 la 15,4	rc=4 iff p==0
al95 equ *
 lm 8,14,alreg2
 br 14
***
*
***
 drop 12
*
 ltorg
gpwork dsect
gpsave ds 18f
gpwlen equ *-gpwork
 end
