# Read the following instructions carefully
#
# You will provide your solution to this part of the project by
# editing the collection of functions in this source file.
#
# Some rules from the C bitwise puzzles are still in effect for your assembly
# code here:
#  1. No global variables are allowed
#  2. You may not define or call any additional functions in this file
#  3. You may not use any floating-point assembly instructions
#
# You may assume that your machine:
#  1. Uses two's complement, 32-bit representations of integers.
#  2. Has unpredictable behavior when shifting if the shift amount
#     is less than 0 or greater than 31.

# TO AVOID GRADING SURPRISES:
#   Pay attention to the results of the call_cc script, which is run
#   as part of the provided tests.
#
#   This makes sure you have adhered to the x86-64 calling convention
#   in your assembly code. If it reports any errors, make sure to fix
#   them before you submit your code.
#
# YOU WILL RECEIVE NO CREDIT IF YOUR CODE DOES NOT PASS THIS CHECK

# bitXor - Compute x^y
#   Example: bitXor(4, 5) = 1
#   Rating: 1
.global bitXor
bitXor:
    # args: x in %edi, y in %esi
    pushq   %rbx
    movl    %edi, %eax
    notl    %esi              # invert y
    andl    %esi, %eax        # eax = x & ~y
    movl    %edi, %ebx
    notl    %ebx
    movl    %esi, %ecx
    notl    %ecx              # un-invert y ecx = y
    andl    %ecx, %ebx
    orl     %ebx, %eax        # eax = (x & ~y) | (~x & y)
    popq    %rbx
    ret

# bitAnd - Compute x&y
#   Example: bitAnd(6, 5) = 4
#   Rating: 1
.global bitAnd
bitAnd:
    pushq   %rbx
    movl    %edi, %eax
    notl    %eax              # eax = ~x
    movl    %esi, %ebx
    notl    %ebx              # ebx = ~y
    orl     %ebx, %eax        # eax = ~x | ~y
    notl    %eax              # eax = ~(~x | ~y) = x & y Demorgans law
    popq    %rbx
    ret

# allOddBits - Return 1 if all odd-numbered bits in word set to 1
#   where bits are numbered from 0 (least significant) to 31 (most significant)
#   Examples allOddBits(0xFFFFFFFD) = 0, allOddBits(0xAAAAAAAA) = 1
#   Rating: 2
.global allOddBits
allOddBits:
    pushq   %rbx
    movl    $0xAA, %eax
    movl    %eax, %ebx
    shll    $8, %ebx
    orl     %ebx, %eax        # eax = 0xAAAA
    movl    %eax, %ebx
    shll    $16, %ebx
    orl     %ebx, %eax        # eax = 0xAAAAAAAA
    movl    %edi, %ebx
    andl    %eax, %ebx        # ebx = x & mask
    xorl    %eax, %ebx        # ebx = (x & mask) ^ mask
    testl   %ebx, %ebx        # check if ebx = 0
    sete    %al               # 0 if ebx = 0, 1 if ebx anything else
    movzbl  %al, %eax
    popq    %rbx
    ret

# floatIsEqual - Compute f == g for floating point arguments f and g.
#   Both the arguments are passed as unsigned int's, but
#   they are to be interpreted as the bit-level representations of
#   single-precision floating point values.
#   If either argument is NaN, return 0.
#   +0 and -0 are considered equal.
#   Rating: 2
.global floatIsEqual
floatIsEqual:
    pushq   %rbx
    # uF in %edi, uG in %esi
    movl    %edi, %eax
    shrl    $23, %eax
    andl    $0xFF, %eax      # expF in eax
    movl    %esi, %ebx
    shrl    $23, %ebx
    andl    $0xFF, %ebx      # expG in ebx
    movl    %edi, %ecx
    andl    $0x7FFFFF, %ecx # extract fraction F
    movl    %esi, %edx
    andl    $0x7FFFFF, %edx # extract fraction G

    # check NaN
    cmpl    $0xFF, %eax
    jne     .check_next
    testl   %ecx, %ecx
    jne     .return_zero
.check_next:
    # (exp==0xFF && frac != 0)
    cmpl    $0xFF, %ebx
    jne     .check_zero_case
    testl   %edx, %edx
    jne     .return_zero

.check_zero_case:
    # if ((uf << 1) == 0) && ((ug << 1) == 0) return 1;
    movl    %edi, %eax
    sall    $1, %eax
    testl   %eax, %eax
    jne     .check_equal_direct
    movl    %esi, %eax
    sall    $1, %eax
    testl   %eax, %eax
    jne     .check_equal_direct
    movl    $1, %eax
    popq    %rbx
    ret

.check_equal_direct:
    # return uf == ug
    cmpl    %esi, %edi
    sete    %al
    movzbl  %al, %eax
    popq    %rbx
    ret

.return_zero:
    xorl    %eax, %eax
    popq    %rbx
    ret

# anyEvenBit - Return 1 if any even-numbered bit in word set to 1
#   where bits are numbered from 0 (least significant) to 31 (most significant)
#   Examples anyEvenBit(0xA) = 0, anyEvenBit(0xE) = 1
#   Rating: 2
.global anyEvenBit
anyEvenBit:
    pushq    %rbx
    # build mask 0x55555555
    movl    $0x55, %eax
    movl    %eax, %ebx
    shll    $8, %ebx
    orl     %ebx, %eax        # eax = 0x5555
    movl    %eax, %ebx
    shll    $16, %ebx
    orl     %ebx, %eax        # eax = 0x55555555
    movl    %edi, %ebx
    andl    %eax, %ebx        # ebx = x & mask
    testl   %ebx, %ebx
    setne   %al
    movzbl  %al, %eax
    popq    %rbx
    ret

# isPositive - return 1 if x > 0, return 0 otherwise
#   Example: isPositive(-1) = 0.
#   Rating: 2
.global isPositive
isPositive:
    cmpl    $0, %edi
    setg    %al         # set al = 1 if x > 0, else 0
    movzbl  %al, %eax
    ret

# replaceByte(x,n,c) - Replace byte n in x with c
#   Bytes numbered from 0 (least significant) to 3 (most significant)
#   Examples: replaceByte(0x12345678, 1, 0xab) = 0x1234ab78
#   You can assume 0 <= n <= 3 and 0 <= c <= 255
#   Rating: 3
.global replaceByte
replaceByte:
    pushq    %rbx
    # args: x in %edi, n in %esi, c in %edx
    # compute shift = n << 3 in %ecx
    movl    %esi, %ecx
    shll    $3, %ecx
    # mask = ~(0xFF << shift)
    movl    $0xFF, %eax
    # shift eax left by cl
    movl    %ecx, %ecx
    shll    %cl, %eax
    notl    %eax
    movl    %edi, %ebx
    andl    %eax, %ebx
    # c_shifted = c << shift
    movl    %edx, %eax
    shll    %cl, %eax
    orl     %ebx, %eax        # result = x_cleared | c_shifted
    popq    %rbx
    ret

# isLess - if x < y  then return 1, else return 0
#   Example: isLess(4,5) = 1.
#   Rating: 3
.global isLess
isLess:
    # args: x in %edi, y in %esi
    cmpl    %esi, %edi        # sets flags for edi - esi
    setl    %al               # set if signed less
    movzbl  %al, %eax
    ret


# rotateLeft - Rotate x to the left by n
#   Can assume that 0 <= n <= 31
#   Examples: rotateLeft(0x87654321,4) = 0x76543218
#   Rating: 3
.global rotateLeft
rotateLeft:
    # args: x in %edi, n in %esi
    movl    %esi, %ecx
    movl    %edi, %eax
    roll    %cl, %eax         # rotate left eax by cl bits
    ret

# bitMask - Generate a mask consisting of all 1's
#   between lowbit and highbit positions
#   Examples: bitMask(5,3) = 0x38
#   Assume 0 <= lowbit <= 31, and 0 <= highbit <= 31
#   If lowbit > highbit, then mask should be all 0's
#   Rating: 3
.global bitMask
bitMask:
    pushq %rbx
    # args: highbit in %edi, lowbit in %esi
    # onesHigh = (2 << highbit) + ~0  -> (1 << (highbit+1)) - 1
    movl    %edi, %ecx
    movl    $2, %ebx
    shll    %cl, %ebx          # ebx = 2 << highbit
    addl    $-1, %ebx          # ebx = onesHigh

    # onesLow = (1 << lowbit) + ~0  -> (1 << lowbit) - 1
    movl    %esi, %ecx
    movl    $1, %edx
    shll    %cl, %edx          # edx = 1 << lowbit
    addl    $-1, %edx          # edx = onesLow

    # mask = onesHigh & ~onesLow
    notl    %edx               # ~onesLow
    andl    %edx, %ebx         # ebx = mask

    # valid = ((highbit + (~lowbit + 1)) >> 31)  (arithmetic right)
    # compute highbit - lowbit
    movl    %edi, %ecx
    subl    %esi, %ecx         # ecx = highbit - lowbit
    sarl    $31, %ecx          # ecx = 0 if high>=low else -1
    notl    %ecx               # ~valid
    andl    %ecx, %ebx         # mask & ~valid

    movl    %ebx, %eax
    popq %rbx
    ret


# floatScale2 - Return bit-level equivalent of expression 2*f for
#   floating point argument f.
#   Both the argument and result are passed as unsigned int's, but
#   they are to be interpreted as the bit-level representation of
#   single-precision floating point values.
#   When argument is NaN, return argument
#   Rating: 4
.global floatScale2
floatScale2:
    pushq   %rbx
    # arg in %edi, make copy to for shifts
    movl    %edi, %eax
    movl    %eax, %ecx

    # Extract sign, exp, frac
    movl    %eax, %edx
    andl    $0x7F800000, %edx     # isolate exponent bits (bits 30-23)
    shrl    $23, %edx             # edx = exp
    movl    %eax, %ebx
    andl    $0x007FFFFF, %ebx     # ebx = frac
    andl    $0x80000000, %eax     # eax = sign (keep in eax)

    # if (exp == 0xFF) return uf
    cmpl    $0xFF, %edx
    je      .ret_uf

    # if (exp == 0)
    testl   %edx, %edx
    jne     .normalized

    # denormalized: frac <<= 1; return sign | frac
    shll    $1, %ebx
    orl     %ebx, %eax
    popq    %rbx
    ret

.normalized:
    incl    %edx                   # exp += 1
    cmpl    $0xFF, %edx
    je      .make_inf              # if exp == 0xFF → inf

    # return sign | (exp << 23) | frac
    shll    $23, %edx
    orl     %edx, %eax
    orl     %ebx, %eax
    popq %rbx
    ret

.make_inf:
    orl     $0x7F800000, %eax      # sign | (0xFF << 23)
    popq %rbx
    ret

.ret_uf:
    movl    %edi, %eax             # return uf
    popq %rbx
    ret

# isPower2 - returns 1 if x is a power of 2, and 0 otherwise
#   Examples: isPower2(5) = 0, isPower2(8) = 1, isPower2(0) = 0
#   Note that no negative number is a power of 2.
#   Rating: 4
.global isPower2
isPower2:
    # return (x > 0) && ((x & (x-1)) == 0)
    cmpl    $0, %edi
    jle     .ret_zero
    movl    %edi, %eax
    movl    %edi, %ecx
    subl    $1, %ecx           # ecx = x-1
    andl    %ecx, %eax         # eax = x & (x-1)
    testl   %eax, %eax
    sete    %al
    movzbl  %al, %eax
    ret

.ret_zero:
    xorl    %eax, %eax
    ret
