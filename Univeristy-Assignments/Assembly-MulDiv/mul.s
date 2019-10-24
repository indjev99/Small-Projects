        .syntax unified
        .global foo

        .text
        .thumb_func
foo:
@ ----------------
@ Multiplication by repeated division by 2
@ Variables x = r0, y = r1, z = r2
@ Invariant a * b = x * y + z

        movs r2, #0             @ z = 0;
        cmp r0, #0
        beq done                @ if (x==0) goto done;
        b loop                  @ goto loop;
loopOdd:
        adds r2, r2, r1         @   z += y;
loopEven:
        lsls r1, r1, #1         @   y *= 2;
loop:
        lsrs r0, r0, #1         @   x /= 2;
        bhi loopOdd             @   if (x(old)%2 && x!=0) goto loopOdd;
        bcc loopEven            @   if (!x(old)%2) goto loopEven; // x!=0
last:
        add r2, r2, r1	        @ z += y;
done:
        movs r0, r2             @ return z;
@ ----------------
        bx lr
