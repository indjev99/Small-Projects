@ fixup.s

@ "set reg, #val" is a synonym for a PC-relative load instruction.  The same
@ goes for the conditional versions seths and seteq, which are used in the
@ Lab 4 compiler to translate runtime checks.

.macro set, reg, val
       ldr \reg, =\val
.endm

.macro seths, reg, val
       ldrhs \reg, =\val
.endm

.macro seteq, reg, val
       ldreq \reg, =\val
.endm       
