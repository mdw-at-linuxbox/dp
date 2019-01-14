*
* ESA/390 instructions that z/390 does not have.  
*
** ref,
** SA22-7832-03	ESA/390 Principles of Operation
* ... and a nabble posting "Basic Bootstrap loader program disassembled"
*
 MACRO
&L STSCH &P
&L DC X'B234',S(&P)
 MEND
 MACRO
&L SSCH &P
&L DC X'B233',S(&P)
 MEND
 MACRO
&L MSCH &P
&L DC X'B232',S(&P)
 MEND
