def zbits(v):
    n = 0;
    for d in (128,64,32,16,8,4,2,1):
        if v >= d :
            break
        n+=1
    return n

print(" ".join(["%02x"%zbits(i) for i in range(256)]))
   
