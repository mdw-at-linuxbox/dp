*
* memory allocation
*
 entry intfree,intalloc
*
* memory free list elements
*
align equ 7
blob dsect
 ds 1f	next
 ds 1f	len
bloblen equ *-blob
*
* memory pool
*
pool dsect
freelist ds 1f
firstp ds 1f
lastp ds 1f
poolsize ds 1f
freesize ds 1f
grow ds 1f
poollen equ *-pool
*
alloc csect
 balr 15,0
 lpsw 1
 cnop 0,4
*
* intfree
* entry:
*  2=pool
*  3=(a)
*  4=len
* ret:
*  2=pp or 0
*
 using alloc,12
 using pool,2
intfree equ *
 stm 10,11,44(13)
 la 1,align
 ar 3,1	a += ALIGN
 ar 4,1	len += ALIGN
 lcr 1,1
 bctr 1,0
 nr 3,1	a &= ~ALIGN
 nr 4,1	len &= ~ALIGN
 lr 10,2	pp = &q->freelist
 l 5,freelist	np = q->freelist
 la 1,0	prevp = 0
fr10 equ *	L3
 ltr 5,3
 bne fr20
 ltr 1,1	if prevp
 bne fr25
fr15 equ *	L8
 st 5,0(3)	p=a; p->next = *pp
 st 4,4(3)	p->len = len
 st 3,0(10)	*pp = p
 lr 1,3
 b fr55
fr20 equ *	L7
 clr 3,5
 bnl fr35
 ltr 1,1
 be fr45
fr25 equ *	L5
 lr 0,1
 a 0,4(1)
 clr 3,0
 bnl fr40
fr30 equ *	L17
 la 10,0
 b fr90
fr35 equ *	L4
 lr 10,5	pp = &np->next
 lr 1,5	prevp = np
 l 5,0(5)	np = *np
 b fr10
fr40 equ *	L29
 ltr 5,5
 be fr50
fr45 equ *	L13
 lr 0,3
 ar 0,4
 clr 5,0
 bl fr30
 ltr 1,1
 be fr15
fr50 equ *	L14
 l 0,4(1)
 lr 11,1
 ar 11,0
 cr 3,11
 bne fr15
 ar 0,4		prevp = p; p->len += len
 st 0,4(1)
fr55 equ *	L11
 ltr 5,5	if (np
 be fr60
 l 3,4(1)	&& p+p->len == np) {
 lr 0,1
 ar 0,3
 cr 5,0
 bne fr60
 l 0,0(5)	p->len += np->len;
 a 3,4(5)
 st 0,0(1)
 st 3,4(1)	p->next = np->next; }
fr60 equ *	L12
 a 4,freesize	q->freesize += len;
 st 4,freesize
fr90 equ *	L1
 lr 2,10
 lm 10,11,44(13)
 br 14
 drop 2
*
* grow:
*  2=pool
*  3=len
* ret:
*  r1=0 or addr
*
intgrow equ *
 using pool,2
 stm 10,15,40(13)
 a 3,=A(4095+bloblen)
 n 3,=F'-4096'
 lr 10,2
 drop 2
 using pool,10
 l 2,lastp
 lr 11,3
gr10 equ *
 lr 1,10
 lr 0,2
 l 15,grow
 balr 15,14
 ltr 15,15
 be gr20
 la 1,0
 ltr 2,2	xxx
 la 0,0	logic suspect
 bne gr10
 b gr90
gr20 equ *
 lr 0,11
 a 0,poolsize
 st 0,poolsize
 l 0,firstp
 ltr 0,0
 bne gr90
 st 1,firstp
gr90 equ *
 lr 2,10		FIXUP return
 drop 10
 lm 10,15,40(13)
 br 14
*
* intalloc
* 2=pool
* 3=len
* exit:
* 2=result
*
 using pool,2
intalloc equ *
 stm 10,15,40(15)
 la 1,align
 ar 3,1	len += ALIGN
 lcr 1,1
 lr 10,2	pp = &q->freelist
 drop 2
 bctr 1,0
 nr 3,1	len &= ~ALIGN
 using pool,10
 l 12,freelist	for (p = q->freelist;
 b al10
al60 equ *	L42
 c 11,4(12)	if (p->len >= len) break
 bnh al20 
 lr 2,12	pp = &p->next
 l 12,0(12)	p = *pp
al10 equ *	L40
 ltr 12,12	p != 0
 bne al60
 lr 3,11	pp = grow(q,len)
 lr 2,10
 bal 14,intgrow	XXX fixup return
 ltr 2,2	if (!pp) return 0
 be al90
 l 12,0(2)	p = *pp
al20 equ *	L41
 l 1,4(12)	p->len - len
 la 3,bloblen-1
 sr 1,11
 l 4,0(12)	if ((p->len - len) >= sizeof *p)
 clr 1,3
 bnh al70
 lr 3,12	q = r + len
 ar 3,11
 st 4,0(3)	q->next = p->next
 st 1,4(3)	q->len = p->len - len
 st 3,0(2)	*pp = q
 b al30	} else {
al70 equ *	L44
 st 4,0(2)		*pp = p->next; }
al30 equ *	L45
 st 11,0(12)	*r = len
 using pool,10	q->freesize -= len
 l 1,freesize
 sr 1,11
 st 1,freesize
al90 equ *	L39
 lr 2,12	r = p
 lm 10,15,40(15)
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
