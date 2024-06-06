#%%
import numpy as np
import os

#%%
def to_hex(num, length):
    return hex((num + (1 << length)) % (1 << length))[2:].zfill(2)

to_hex_v = np.vectorize(to_hex)

#%%
src_path = os.path.dirname(os.path.realpath(__file__))+"\\npy\\"
dst_path = os.path.dirname(os.path.realpath(__file__))+"\\npy_hex\\"

file_list = os.listdir(src_path)
print(file_list)
for file in file_list:
	data = np.load(src_path+file).flatten()
	print("BEFORE")
	print(data)
	data = to_hex_v(data,32) if ('bias' in file) else to_hex_v(data,8)
	print("AFTER")
	print(data)
	print("\n-------------------------------------------------\n")
 
 
	np.savetxt(dst_path+file[:-4]+'.txt', data.flatten(), fmt='%s', newline=' ')
     
# %%
