#%%
import os


src_path = os.path.dirname(os.path.realpath(__file__))+"\\npy_hex\\"
dst_path = os.path.dirname(os.path.realpath(__file__))+"\\last\\"

files = ["mini_conv0_kernel.txt", "mini_conv1_kernel.txt", "mini_conv2_kernel.txt", "mini_dense0_kernel.txt", "mini_dense1_kernel.txt"]
params = [[3, 3, 2, 1], [3, 3, 4, 2], [3, 3, 8, 4], [3, 3, 64, 8], [1, 1, 7, 64]]



for num, file in enumerate(files):
	W = params[num][0]
	H = params[num][1]
	F = params[num][2]
	D = params[num][3]
 
	d_cnt = 0
	w_cnt = 0
	h_cnt = 0
	f_cnt = 0
	if(num<3):
		once = W*H*F
	elif (num == 3):
		once = W*D
	else:
		once = F
	result = [0 for k in range (W*H*F*D)]
	with open (src_path + file, "r") as src:
		with open (dst_path + file, "w") as dst:
			for line in src:
				items = line.split(' ')
				
				for item in items[:-1]:
					if (num<3):
						result[d_cnt * W * H * F + f_cnt * W * H + h_cnt * W + w_cnt] = item
					elif (num==3):	#dense
						result[h_cnt * W * F * D + f_cnt * W * D + d_cnt * W + w_cnt] = item
					else:
						result[d_cnt * W * H * F + f_cnt * W * H + h_cnt * W + w_cnt] = item
					d_cnt += 1
					if(d_cnt == D):
						d_cnt = 0
						w_cnt += 1
						if(w_cnt == W):
							w_cnt = 0
							h_cnt += 1
							if(h_cnt == H):
								h_cnt = 0
								f_cnt += 1
								if(f_cnt == F):
									f_cnt = 0
			temp = ''
			if (num<3):    
				for i, item in enumerate(result):
					dst.write(item)
					if((i+1) % once == 0):
						dst.write('\n')
			else:
				for i, item in enumerate(result):
					temp = str(item) + temp
					if ((i + 1) % once == 0):
						dst.write(temp+'\n')
						temp = ''
# %%
