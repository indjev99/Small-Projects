        .syntax unified
        .global foo

        .text
        .thumb_func
foo:
@ ----------------
@ Division by long division algorithm
@ Variables x = r0, y = r1, z = r2, k = r3
@ Invariant a = z*b+x && (k > 0 => k = 2^t && y = b*2^t && t >= 0 && x < b*2^(t+1))
@                     && (k == 0 => x < b) && x >= 0

        movs r2, #0             @ z = 0;
        movs r3, #1             @ k = 1;
        cmp r1, 0               @ while (y < 1<<31) {
        bmi loop2
loop1:
        lsls r3, r3, #1         @   k = k*2;
        lsls r1, r1, #1         @   y = y*2;
        bpl loop1               @ }
                                @ while (k != 0) {
loop2:
        cmp r0, r1              @   if (y <= x) {
        blo greater
        subs r0, r0, r1         @     x = x-y;
        adds r2, r2, r3         @     z = z+k;
                                @   }
greater:
        lsrs r1, r1, #1         @   y = y/2;
        lsrs r3, r3, #1         @   k = k/2;
        bne loop2               @ }
done:
        movs r0, r2             @ return z;
@ ----------------
        bx lr
