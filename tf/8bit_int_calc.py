#%%
import numpy as np

#%%

def twos_complement(hexstr, bits):
    value = int(hexstr, 16)
    if value & (1 << (bits - 1)):
        value -= 1 << bits
    return value

def to_hex(num, length):
    return hex((num + (1 << length)) % (1 << length))[2:].zfill(2)
to_hex_v = np.vectorize(to_hex)

def to_np(s):
    temp = np.array([], dtype=np.int8)
    for i in range(int(len(s)/2)):
        temp = np.append(temp, twos_complement(s[i]+s[i+1], 8))
    return temp

#%%
a = '812b'
b = '3b4c'
c = '4c6b'
#%%
d = to_np(a)
e = to_np(b)
f = to_np(c)

print(d)
print(e)
print(f)
print(d * e + f)
print(to_hex_v(d * e + f, 8))
# %%
