ld r1, r0, 0
ld r2, r0, 12
div r3, r1, r2
sto r3, r0, 24
addi r0, r0, 4
cmp_lt r0, 12
bra -24
end
