#%%
from keras.models import load_model
import os,cv2
import numpy as np

#%%
model = load_model("toytoy_model_keras.h5")
# test_image = image.load_img(, 0)
# test_image = image.img_to_array(test_image)
# test_image = test_image.reshape(test_image.shape + (1,))

path = "../images/ckplus/sadness/"

#%%
file_list = os.listdir(path)
for file in file_list: 
	input_img=cv2.imread(path+file,0)
	img_data_list = []
	img_data_list.append(input_img)
	img_data = np.array(img_data_list)
	img_data = img_data.reshape(img_data.shape + (1,))
	with open("val.txt", 'a') as file_d:
		pred = model.predict(img_data)
		file_d.write(np.array2string(pred)+"\n")
# img_data = np.expand_dims(img_data, axis=0)

#%%

# %%


        
        #input_img=cv2.cvtColor(input_img, cv2.COLOR_BGR2GRAY)
        
