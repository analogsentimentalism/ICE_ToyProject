import time
import os

src_path = os.path.dirname(os.path.realpath(__file__))+"\\npy_hex\\"
file = "mini_dense0_kernel.txt"

dst_path = os.path.dirname(os.path.realpath(__file__))+"\\last\\"

cnt = 0

B = 64
W = 2
H = 2
D = 12
ONCE = 24	# W * D
temp = ''
modline = [0 for i in range (B*W*H*D)]

b_cnt = 0
w_cnt = 0
h_cnt = 0
d_cnt = 0

with open (src_path + file, "r") as src:
	with open (dst_path+file, "w") as dst:
		for line in src:
			current_line = line.split(' ')
			for i, x in enumerate(current_line):
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
			temp = str(item) + temp
			cnt += 1
			if (cnt >= ONCE):
				dst.write(temp+ '\n')
				temp = ''
				cnt = 0
			  