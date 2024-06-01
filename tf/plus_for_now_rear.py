import struct
import os

src_path = os.path.dirname(os.path.realpath(__file__))+"\\npy_hex\\"
file = "mini_dense1_kernel.txt"

dst_path = os.path.dirname(os.path.realpath(__file__))+"\\last\\"

cnt = 0

B = 7
W = 1
H = 64
D = 1
ONCE = 24	# W * D
temp = ''
modline = [0 for i in range (24*24)]

b_cnt = 0
w_cnt = 0
h_cnt = 0
d_cnt = 0

with open (src_path + file, "r") as src:
    with open (dst_path+file, "w") as dst:
        for line in src:
            currentline = line.split(' ')
                
            for item in currentline:
                temp = temp + item
                cnt += 1
                if (cnt >= ONCE):
                    dst.write(temp+ '\n')
                    temp = ''
                    cnt = 0