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

#%%
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
img_data = img_data.astype('float32')
img_data = img_data/1.0
img_data = img_data.reshape(img_data.shape + (1,))
img_data.shape

print(img_data)

#%%



def representative_data_gen():
  for input_value in tf.data.Dataset.from_tensor_slices(img_data).batch(1).take(100):
    yield [input_value]

src_path = os.path.dirname(os.path.realpath(__file__))+"\\cnn_model_best.keras"
src_path2 = os.path.dirname(os.path.realpath(__file__))
print(src_path)
print("_______________________________________")

model = tf.keras.models.load_model(src_path)

# Convert the Keras model to a TFLite model

converter = tf.lite.TFLiteConverter.from_keras_model(model)

converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.uint8
converter.inference_output_type = tf.int8
converter.representative_dataset = representative_data_gen
#%%
tflite_model = converter.convert()

#%%

# Save the TFLite model to a file
with open(src_path2+"\\"+'model.tflite', 'wb') as f:
    f.write(tflite_model)
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
interpreter = tf.lite.Interpreter(model_path=src_path2+"\\model.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()[0]
output_details = interpreter.get_output_details()[0]

for i, test_image in enumerate(X_test):
	test_image = [test_image]
	interpreter.set_tensor(input_details['index'], test_image)
	interpreter.invoke()
	output = interpreter.get_tensor(output_details['index'])
	print(output, "|", y_test[i])


# %%
print(test_image)
print(interpreter.get_tensor(11))
# %%
