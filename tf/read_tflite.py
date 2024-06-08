#%%
import os
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'
import tensorflow as tf
from tensorflow import keras
from sklearn.utils import shuffle
from sklearn.model_selection import train_test_split
import logging
logging.getLogger("tensorflow").setLevel(logging.DEBUG)
import numpy as np
print("TensorFlow version: ", tf.__version__)
import cv2
interpreter = tf.lite.Interpreter(model_path='qmodel.tflite')
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
Y = keras.utils.to_categorical(labels, num_classes)

#Shuffle the dataset
x,y = shuffle(img_data,Y, random_state=2)
# Split the dataset
X_train, X_test, y_train, y_test = train_test_split(x, y, test_size=0.2, random_state=2)
x_test=X_test
x_test.shape
y_test.shape

#%%
interpreter = tf.lite.Interpreter(model_path="qmodel.tflite", experimental_preserve_all_tensors=True)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()[0]
output_details = interpreter.get_output_details()[0]
#%%

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
np.set_printoptions(threshold=np.inf)
# test_image = [[[[np.uint8(255)] for i in range(24)] for j in range(24)]]
# test_input = [[[[np.int8(-5) for i in range (12)] for j in range(3)] for k in range(3)]]
interpreter.set_tensor(input_details['index'], test_image)
# interpreter.set_tensor(4, [np.int32(1),np.int32(1)])
# interpreter.set_tensor(7, [[[[np.int8(1)] for i in range(3)] for j in range(3)] for k in range(2)])
# interpreter.set_tensor(18, [np.repeat([np.int8(100)], 72)])
interpreter.invoke()

# print("image")
# print(interpreter.get_tensor(input_details['index'])[0].flatten())
# print("--------------------------")
# print("quantized input")
# print(interpreter.get_tensor(11).flatten())
# print("--------------------------")
# print("*1st Conv Filter")
# print(interpreter.get_tensor(11))
# print("--------------------------")
# print("*1st Conv Bias")
# print(interpreter.get_tensor(10))
# print("--------------------------")
print("1st Conv")
print(interpreter.get_tensor(13))
print("--------------------------")
# print("1st Maxpool")
# print(interpreter.get_tensor(14))
# print("--------------------------")
# print("2nd Conv")
# print(interpreter.get_tensor(15))
# print("--------------------------")
# print("2nd Maxpool")
# print(interpreter.get_tensor(16))
# print("--------------------------")
# print("3rd Conv")
# print(interpreter.get_tensor(17))
# print("--------------------------")
# print("3rd Maxpool")
# print(interpreter.get_tensor(18))
# print("--------------------------")
# print("Flatten")
# print(interpreter.get_tensor(19))
# print("--------------------------")
# print("*1st Dense MATMUL")
# print(interpreter.get_tensor(8))
# print("--------------------------")
# print("*1st Dense BIAS")
# print(interpreter.get_tensor(10))
# print("--------------------------")
# print("1st Dense")
# print(interpreter.get_tensor(19))
# print("--------------------------")
# print("*2nd Dense MATMUL")
# print(interpreter.get_tensor(20))
# print("--------------------------")
# print("*2nd Dense BIAS")
# print(interpreter.get_tensor(9))
# print("--------------------------")
# print("2nd Dense")
# print(interpreter.get_tensor(21))
# print("--------------------------")
# print("Softmax")
# print(interpreter.get_tensor(22))
# print("--------------------------")
# print("Result")
# print(interpreter.get_tensor(output_details['index']))
# %%
for item in interpreter.get_tensor_details():
	print(item['name'], "\nindex: " , item['index'],"\nshape: ",item['shape'],"\n")

# %%
print(test_image)
# %%
interpreter.get_tensor_details()
# %%
a = interpreter.get_tensor(19).astype(dtype=np.int32)

b = interpreter.get_tensor(20).astype(dtype=np.int32)

c = interpreter.get_tensor(9)

answer = interpreter.get_tensor(21)

a_scale = interpreter.get_tensor_details()[19]['quantization_parameters']['scales']
a_zero_points = interpreter.get_tensor_details()[19]['quantization_parameters']['zero_points']

b_scale = interpreter.get_tensor_details()[20]['quantization_parameters']['scales'].reshape(-1,1)

c_scale = interpreter.get_tensor_details()[9]['quantization_parameters']['scales'].reshape(1,-1)

o_scale = interpreter.get_tensor_details()[21]['quantization_parameters']['scales']
o_zero_points = interpreter.get_tensor_details()[21]['quantization_parameters']['zero_points']

print(a_scale)
print(a_zero_points)
print(b_scale)
print(c_scale)
print(o_scale)
print(o_zero_points)
#%%
a = (a - a_zero_points) * a_scale
print(a)
#%%
b = b * b_scale
c = c * c_scale
print("-------")
print(b)
print("-------")
print(c)
print("-------")

#%%
ans = a * b
print(a)
print("-------------")
print(b)
print("-------------")
print(c)
print("-------------")
for i in range(7):
	print((ans[i].sum() + c[0][i]))
	print("-------------")
#%%
for i in range(7):
	print(i+1,"번째")
	print("계산값: ", (ans[i].sum()+c[0][i]))
	print("정답: ",answer[0][i])

#%% 합치기
all = {}

all['conv0_kernel'] = ((interpreter.get_tensor(7).T * interpreter.get_tensor_details()[7]['quantization_parameters']['scales']).T \
						* interpreter.get_tensor_details()[11]['quantization_parameters']['scales'] \
							/ interpreter.get_tensor_details()[12]['quantization_parameters']['scales']).flatten()
all['conv0_bias'] = (interpreter.get_tensor(4) * interpreter.get_tensor_details()[4]['quantization_parameters']['scales'] \
						/ interpreter.get_tensor_details()[12]['quantization_parameters']['scales']).flatten()

all['conv1_kernel'] = ((interpreter.get_tensor(6).T * interpreter.get_tensor_details()[6]['quantization_parameters']['scales']).T \
						* interpreter.get_tensor_details()[13]['quantization_parameters']['scales'] \
							/ interpreter.get_tensor_details()[14]['quantization_parameters']['scales']).flatten()		
all['conv1_bias'] = (interpreter.get_tensor(3) * interpreter.get_tensor_details()[3]['quantization_parameters']['scales'] \
							/ interpreter.get_tensor_details()[14]['quantization_parameters']['scales']).flatten()

all['conv2_kernel'] = ((interpreter.get_tensor(5).T * interpreter.get_tensor_details()[5]['quantization_parameters']['scales']).T \
						* interpreter.get_tensor_details()[15]['quantization_parameters']['scales'] \
							/ interpreter.get_tensor_details()[16]['quantization_parameters']['scales']).flatten()	
all['conv2_bias'] = (interpreter.get_tensor(2) * interpreter.get_tensor_details()[2]['quantization_parameters']['scales'] \
							/ interpreter.get_tensor_details()[16]['quantization_parameters']['scales']).flatten()

all['dense0_kernel'] = ((interpreter.get_tensor(8).T * interpreter.get_tensor_details()[8]['quantization_parameters']['scales']).T \
						* interpreter.get_tensor_details()[18]['quantization_parameters']['scales'] \
							/ interpreter.get_tensor_details()[19]['quantization_parameters']['scales']).flatten()	
all['dense0_bias'] = (interpreter.get_tensor(10) * interpreter.get_tensor_details()[10]['quantization_parameters']['scales'] \
							/ interpreter.get_tensor_details()[19]['quantization_parameters']['scales']).flatten()

all['dense1_kernel'] = (interpreter.get_tensor(20) * interpreter.get_tensor_details()[20]['quantization_parameters']['scales'] \
						* interpreter.get_tensor_details()[19]['quantization_parameters']['scales'] \
							/ interpreter.get_tensor_details()[21]['quantization_parameters']['scales']).flatten()	
all['dense1_bias'] = (interpreter.get_tensor(9) * interpreter.get_tensor_details()[9]['quantization_parameters']['scales'] \
							/ interpreter.get_tensor_details()[21]['quantization_parameters']['scales']).flatten()	

for item in all:
	print(all[item])

# %%
dst_path = os.path.dirname(os.path.realpath(__file__))+"\\last_numbers\\"

for item in all:
	with open(dst_path+"mini_"+item+".txt", 'w') as file:
		for element in all[item]:
			file.write(str(element) + ' ')

# %% kernel은 shift 0
def decimal_to_hex(num, shift, width):
	result = ''
	flag = 0
	temp = ''
	num = num * 2 ** shift
	if(num<0):
		sign = '1'
		num = -num
	else:
		sign = '0'
	
	for i in range(100):
		if(num > 2 ** (31-i)):
			temp = temp + '1'
			num = num - 2 ** (31-i)
			flag = 1
		elif(flag == 1):
			temp = temp + '0'
		if(shift):
			if(len(temp) == shift):
				break
		else:
			if(len(temp) == width-1):
				break
	if(shift):
		for i in range (width-shift):
			result = result + sign
		result = result + temp
	else:
		result = sign + temp
	result = hex(int(result,2))[2:].zfill(int(width/4))
	return result

def find_shift(num):
	result = ''
	cnt_shift = 0
	flag = 0
	if(num<0):
		result = result + '1'
		num = -num
	else:
		result = result + '0'
	for i in range(100):
		if(num > 2 ** -(i+1)):
			break
		cnt_shift = cnt_shift + 1
	return cnt_shift + 7

to_hex_v = np.vectorize(decimal_to_hex)
# %%
to_hex_v(all['conv0_bias'], 0)
# %%
decimal_to_hex(0.0352352351, 0)
# %%
all['conv0_kernel'] = decimal_to_hex(all['conv0_kernel'])
# %%
find_shift(0.0016566326)
# %%
decimal_to_hex(1.0016566326, 11, 32)

#%%
for item in all:
	ll = all[item]
	print(item)
	ma = [newlist for newlist in ll if newlist < 0]
	mi = [newlist for newlist in ll if newlist > 0]
	if(len(ma) == 0):
		print(find_shift(min(ll)))
	else:
		print(find_shift(max(ma)))
	if(len(mi) == 0):
		print(find_shift(max(ll)))
	else:
		print(find_shift(min(mi)))
# %%
mod = {}
mod['conv0_bias'] = to_hex_v(all['conv0_bias'], 13, 32)
mod['conv0_kernel'] = to_hex_v(all['conv0_kernel'], 0, 8)
mod['conv1_bias'] = to_hex_v(all['conv1_bias'], 13, 32)
mod['conv1_kernel'] = to_hex_v(all['conv1_kernel'], 0, 8)
mod['conv2_bias'] = to_hex_v(all['conv2_bias'], 15, 32)
mod['conv2_kernel'] = to_hex_v(all['conv2_kernel'], 0, 8)
mod['dense0_bias'] = to_hex_v(all['dense0_bias'], 16, 32)
mod['dense0_kernel'] = to_hex_v(all['dense0_kernel'], 0, 8)
mod['dense1_bias'] = to_hex_v(all['dense1_bias'], 14, 32)
mod['dense1_kernel'] = to_hex_v(all['dense1_kernel'], 0, 8)
# %%
dst_path = os.path.dirname(os.path.realpath(__file__))+"\\last_hex\\"

for item in mod:
	with open(dst_path+"mini_"+item+".txt", 'w') as file:
		for element in mod[item]:
			file.write(str(element) + ' ')
# %%
