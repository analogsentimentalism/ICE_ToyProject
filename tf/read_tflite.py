#%%
import os
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'
import tensorflow as tf
from keras.utils import to_categorical
from sklearn.utils import shuffle
from sklearn.model_selection import train_test_split
import logging
logging.getLogger("tensorflow").setLevel(logging.DEBUG)
import numpy as np
print("TensorFlow version: ", tf.__version__)
import cv2
interpreter = tf.lite.Interpreter(model_path='model.tflite')
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("== Input details ==")
print("name:", input_details[0]['name'])
print("shape:", input_details[0]['shape'])
print("type:", input_details[0]['dtype'])
print("\n== Output details ==")
print("name:", output_details[0]['name'])
print("shape:", output_details[0]['shape'])
print("type:", output_details[0]['dtype'])

print("\n---------------------------------------\n")

#%%

input_details = interpreter.get_tensor_details()
for item in input_details:
	print(item)
	print(item['name'])
	print(item['dtype'])
	print(item['index'])
 
#%%
interpreter.tensor(input_details[8]['index'])()

# %%
data_path = '../images/ckplus'
train_dir = "../images/ckplus"
data_dir_list = os.listdir(data_path)

num_epoch=10

img_data_list=[]

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
img_data = img_data.reshape(img_data.shape + (1,))
img_data.shape

#%%
num_classes = 7

num_of_samples = img_data.shape[0]
labels = np.ones((num_of_samples,),dtype='int64')

labels[0:134]=0 #135
labels[135:188]=1 #54
labels[189:365]=2 #177
labels[366:440]=3 #75
labels[441:647]=4 #207
labels[648:731]=5 #84
labels[732:980]=6 #249

names = ['anger','contempt','disgust','fear','happy','sadness','surprise']

def getLabel(id):
    return ['anger','contempt','disgust','fear','happy','sadness','surprise'][id]

#%%
Y = to_categorical(labels, num_classes)

#Shuffle the dataset
x,y = shuffle(img_data,Y, random_state=2)
# Split the dataset
X_train, X_test, y_train, y_test = train_test_split(x, y, test_size=0.2, random_state=2)
x_test=X_test
x_test.shape
y_test.shape

#%%
interpreter = tf.lite.Interpreter(model_path="model.tflite", experimental_preserve_all_tensors=True)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()[0]
output_details = interpreter.get_output_details()[0]

sum_correct = 0

for i, test_image in enumerate(X_test):
	test_image = [test_image]
	interpreter.set_tensor(input_details['index'], test_image)
	interpreter.invoke()
	output = interpreter.get_tensor(output_details['index'])
	if np.argmax(output) == np.argmax(y_test[i]):
		sum_correct += 1

print(sum_correct/float(i+1))


# %%
test_image = [[[[np.uint8(0)] for i in range(24)] for j in range(24)]]
# test_input = [[[[np.int8(-5) for i in range (12)] for j in range(3)] for k in range(3)]]
interpreter.set_tensor(input_details['index'], test_image)
# interpreter.set_tensor(10, [np.int32(1),np.int32(1),np.int32(1),np.int32(1)])
# interpreter.set_tensor(11, [[[[np.int8(0)] for i in range(3)] for j in range(3)] for k in range(4)])
interpreter.invoke()

# print("image")
# print(interpreter.get_tensor(input_details['index']))
# print("--------------------------")
# print("quantized input")
# print(interpreter.get_tensor(12))
print("--------------------------")
print("*1st Conv Filter")
print(interpreter.get_tensor(11))
print("--------------------------")
print("*1st Conv Bias")
print(interpreter.get_tensor(10))
print("--------------------------")
print("1st Conv")
print(interpreter.get_tensor(13))
print("--------------------------")
print("1st Maxpool")
print(interpreter.get_tensor(14))
print("--------------------------")
print("2nd Conv")
print(interpreter.get_tensor(15))
print("--------------------------")
print("2nd Maxpool")
print(interpreter.get_tensor(16))
print("--------------------------")
print("3rd Conv")
print(interpreter.get_tensor(17))
print("--------------------------")
print("3rd Maxpool")
print(interpreter.get_tensor(18))
print("--------------------------")
print("Flatten")
print(interpreter.get_tensor(19))
print("--------------------------")
print("*1st Dense MATMUL")
print(interpreter.get_tensor(5))
print("--------------------------")
print("*1st Dense BIAS")
print(interpreter.get_tensor(4))
print("--------------------------")
print("1st Dense")
print(interpreter.get_tensor(20))
print("--------------------------")
print("*2nd Dense MATMUL")
print(interpreter.get_tensor(3))
print("--------------------------")
print("*2nd Dense BIAS")
print(interpreter.get_tensor(2))
print("--------------------------")
print("2nd Dense")
print(interpreter.get_tensor(21))
print("--------------------------")
print("Result")
print(interpreter.get_tensor(output_details['index']))
# %%
for item in interpreter.get_tensor_details():
    print(item['name'], "\nindex: " , item['index'],"\nshape: ",item['shape'],"\n")

# %%
print(test_image)
# %%
interpreter.get_tensor_details()
# %%
