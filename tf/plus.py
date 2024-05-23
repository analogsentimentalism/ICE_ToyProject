import struct
import os

src_path = os.path.dirname(os.path.realpath(__file__))+"\\..\\txt\\"
file = "mini_dense1_kernel.txt"

dst_path = os.path.dirname(os.path.realpath(__file__))+"\\..\\txt_mod\\"

cnt = 0

B = 7
W = 1
H = 1
D = 128
ONCE = 1	# W * D
temp = ''
modline = [0 for i in range (B*W*H*D)]

b_cnt = 0
w_cnt = 0
h_cnt = 0
d_cnt = 0

with open (src_path + file, "r") as src:
    with open (dst_path+file, "w") as dst:
        for line in src:
            currentline = line.split(' ')
            for i, x in enumerate(currentline[:-1]):
                modline[b_cnt * D * H * W + w_cnt + h_cnt * D * W + d_cnt * W] = x
                if (b_cnt < B - 1):
                    b_cnt += 1
                else:
                    b_cnt = 0
                    if (w_cnt < W - 1):
                        w_cnt += 1
                    else:
                        w_cnt = 0
                        if (h_cnt < H - 1):
                            h_cnt += 1
                        else:
                            h_cnt = 0
                            if (d_cnt < D - 1):
                                d_cnt += 1
                            else:
                                d_cnt = 0
            print(modline)
                
            for item in modline:
                temp = item + temp
                cnt += 1
                if (cnt >= ONCE):
                    dst.write(temp+ '\n')
                    temp = ''
                    cnt = 0
              