*
* S/370 instructions that z/390 does not have.  
** ref,
** A22-6821-0_360PrincOps.pdf
** GA27-2719-2_360-67_funcChar.pdf

*
 MACRO
&L SIO &P
&L DC X'9C00',S(&P)
 MEND
 MACRO
&L TIO &P
&L DC X'9D00',S(&P)
 MEND
 MACRO
&L HIO &P
&L DC X'9E00',S(&P)
 MEND
 MACRO
&L TCH &P
&L DC X'9F00',S(&P)
 MEND
 MACRO
&L WRD &P,&I
&L DC X'84',AL1(&I),S(&P)
 MEND
 MACRO
&L SSK &A,&B
&L DC X'08',AL1(&A),AL1(&B)
 MEND
 MACRO
&L ISK &A,&B
&L DC X'09',AL1(&A),AL1(&B)
 MEND
 MACRO
&L LMC &A,&C,&B
&L DC X'B8',AL1(&A),AL1(&C),S(&B)
 MEND
 MACRO
&L STMC &A,&C,&B
&L DC X'B0',AL1(&A),AL1(&C),S(&B)
 MEND
