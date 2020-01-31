file test_mul_f32.bin
run 200
test 400 0xc0 0x8a 0x43 0x95

file test_leadingzeros.bin
run 200
test 0424 0 0 0 0 0 0 0 1 
test 042c 0 0 0 2 0 0 0 3 
test 0434 0 0 0 4 0 0 0 5 
test 043c 0 0 0 6 0 0 0 7 
test 0444 0 0 0 8 
