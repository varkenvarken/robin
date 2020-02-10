file Test/test_mul_f32.bin
run 200
// results from multiplication
test 0448 0x43 0x96 0x00 0x00 0x3f 0x80 0x00 0x00 
test 0450 0x40 0x00 0x00 0x00 0xbd 0xb8 0x51 0xec 
test 0458 0xc3 0x96 0x00 0x00 0xc3 0x96 0x00 0x00 
test 0460 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 
test 0468 0x3d 0xb8 0x51 0xec

file Test/test_leadingzeros.bin
run 200
// results from 8-bit test
test 0424 0 0 0 0 0 0 0 1 
test 042c 0 0 0 2 0 0 0 3 
test 0434 0 0 0 4 0 0 0 5 
test 043c 0 0 0 6 0 0 0 7 
test 0444 0 0 0 8

// results from 32 bit test
test 046c 0 0 0 0 0 0 0 4 
test 0474 0 0 0 8 0 0 0 9 
test 047c 0 0 0 16 0 0 0 18 
test 0484 0 0 0 24 0 0 0 28 
test 048c 0 0 0 32

file Test/test_add_f32.bin
run 200

// results from addition
test 448 0x40 0x00 0x00 0x00 0x40 0x40 0x00 0x00 
test 450 0x44 0x7a 0x13 0x33 0x00 0x00 0x00 0x00 
test 458 0x44 0x79 0xec 0xcd 0xc4 0x79 0xec 0xcd 
test 460 0x44 0x7a 0x00 0x00 0x44 0x7a 0x00 0x00 
test 468 0xbf 0x19 0x99 0x9a

// results from subtraction
test 046c 0x00 0x00 0x00 0x00 0x3f 0x80 0x00 0x00 
test 0474 0xc4 0x79 0xec 0x51 0xbf 0x19 0x99 0xed 
test 047c 0xc4 0x7a 0x13 0xca 0x44 0x7a 0x13 0xca 
test 0484 0xc4 0x7a 0x00 0xae 0x44 0x7a 0x00 0x00 
test 048c 0x00 0x00 0x00 0x00 

file Test/test_div_f32.bin
run 200
// results from inverse
test 041c 0x3f 0x7f 0xfe 0xd4 0x3e 0xff 0xfe 0xd4 
test 0424 0x3a 0x83 0x12 0x5c 0x40 0x55 0x55 0xa8 
test 042c 0xc0 0x55 0x55 0xa8 0xba 0x83 0x12 0x5c 
test 0434 0x7f 0x80 0x00 0x00 


