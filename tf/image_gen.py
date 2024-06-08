#%%
import os,cv2
import numpy as np

def to_hex(num, length):
    num = num - 128
    return hex((num + (1 << length)) % (1 << length))[2:].zfill(2)

to_hex_v = np.vectorize(to_hex)

data_path = '../images/ckplus'
train_dir = "../images/ckplus"
data_dir_list = os.listdir(data_path)

img_data_list = []
np.set_printoptions(threshold=np.inf)

for dataset in data_dir_list:
    img_list=os.listdir(data_path+'/'+ dataset)
    print ('Loaded the images of dataset-'+'{}\n'.format(dataset))
    for img in img_list:
        input_img=cv2.imread(data_path + '/'+ dataset + '/'+ img,0)
        #input_img=cv2.cvtColor(input_img, cv2.COLOR_BGR2GRAY)
        input_img_resize=cv2.resize(input_img,(24,24))
        img_data_list.append(input_img_resize)

img_data = np.array(img_data_list)
img_data = img_data.astype('uint8')

#%%
data = to_hex_v(img_data, 8).flatten()
#%%
dst_path = os.path.dirname(os.path.realpath(__file__)) + "\\..\\all_in_one\\"
file = "images.txt"

with open (dst_path + file, "w") as dst:
	temp = ''
	for i, item in enumerate(data):
		temp = str(item) + temp
		if((i+1) % 24 == 0):
			dst.write(temp+'\n')
			temp = ''
			if((i+1) % 576 == 0):
				dst.write('\n')
				if((i+1)%2304==0):
					print("DONE")
					break
	
# %%
