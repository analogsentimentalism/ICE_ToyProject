#%%
import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)
import os,cv2
import numpy as np

from sklearn.utils import shuffle
from sklearn.model_selection import train_test_split
# import tensorflow as tf
# Input data files are available in the "../input/" directory.
# For example, running this (by clicking run or pressing Shift+Enter) will list the files in the input directory

# print(os.listdir("../input/ckplus/CK+48"))

# from keras.utils import np_utils
# from tensorflow import keras
# from keras.utils import to_categorical
# from keras.models import Sequential
# from keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout
# from keras.layers import ReLU, Softmax
# from keras.callbacks import ModelCheckpoint, EarlyStopping


# Any results you write to the current directory are saved as output

from sklearn.model_selection import cross_val_score, cross_val_predict
from sklearn.datasets import make_classification

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
img_data = img_data/255.0
temp_img = img_data
img_data = img_data.reshape(img_data.shape + (1,))
img_data.shape

print(img_data)

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

print(X_train.shape)
print(y_train.shape)

#%%
def create_model():
    input_shape=(24,24,1)

    model = Sequential()
    model.add(Conv2D(2, (3, 3), input_shape=input_shape, padding='same'))
    model.add(ReLU())
    model.add(MaxPooling2D(pool_size=(2, 2)))

    model.add(Conv2D(4, (3, 3), padding='same'))
    model.add(ReLU())
    model.add(MaxPooling2D(pool_size=(2, 2)))

    model.add(Conv2D(8, (3, 3), padding='same'))
    model.add(ReLU())
    model.add(MaxPooling2D(pool_size=(2, 2)))

    model.add(Flatten())
    model.add(Dense(64))
    model.add(ReLU())
    model.add(Dropout(0.5))
    model.add(Dense(7))
    model.add(Softmax())

    model.compile(loss='categorical_crossentropy', metrics=['accuracy'],optimizer='RMSprop')
    
    return model

#%%
model_custom = create_model()
model_custom.summary()

#%%
from keras.utils import plot_model
plot_model(model_custom, to_file='test_toytoy_model.png', show_shapes=True, show_layer_names=True)

#%%
from sklearn.model_selection import KFold

#%%
kf = KFold(n_splits=5, shuffle=False) 

#%%
from tensorflow.keras.preprocessing.image import ImageDataGenerator


#%%
aug = ImageDataGenerator(
    rotation_range=25, width_shift_range=0.1,
    height_shift_range=0.1, shear_range=0.2, 
    zoom_range=0.2,horizontal_flip=True, 
    fill_mode="nearest")

#%%
# BS = 8
EPOCHS = 200

#%%
result = []
scores_loss = []
scores_acc = []
k_no = 0
for train_index, test_index in kf.split(x):
    X_Train_ = x[train_index]
    Y_Train = y[train_index]
    X_Test_ = x[test_index]
    Y_Test = y[test_index]

    file_path = "cnn_model"+str(k_no)+".keras"
    checkpoint = ModelCheckpoint(file_path, monitor='loss', verbose=0, save_best_only=True, mode='min')
    early = EarlyStopping(monitor="loss", mode="min", patience=8)

    callbacks_list = [checkpoint, early]

    model = create_model()
    hist = model.fit(aug.flow(X_Train_, Y_Train), epochs=EPOCHS,validation_data=(X_Test_, Y_Test), callbacks=callbacks_list, verbose=0)
    # model.fit(X_Train, Y_Train, batch_size=batch_size, epochs=epochs, validation_data=(X_Test, Y_Test), verbose=1)
    model.load_weights(file_path)
    result.append(model.predict(X_Test_))
    score = model.evaluate(X_Test_,Y_Test, verbose=0)
    scores_loss.append(score[0])
    scores_acc.append(score[1])
    k_no+=1
    
#%%
print(scores_acc,scores_loss)

#%%
value_min = min(scores_loss)
value_index = scores_loss.index(value_min)
print(value_index)

#%%
model.load_weights("cnn_model"+str(value_index)+".keras")
best_model = model

for layer in model.layers: print(layer.get_config(), layer.get_weights())

#%%
score = best_model.evaluate(X_test, y_test, verbose=0)
print('Test Loss:', score[0])
print('Test accuracy:', score[1])

test_image = X_test[0:1]
print (test_image.shape)

print(best_model.predict(test_image))
print(best_model.predict(test_image).argmax(axis=-1))
print(y_test[0:1])

#Model Save
best_model.save_weights('cnn_model_best.weights.h5')
best_model.save('cnn_model_best.keras')

# %%
import tensorflow_model_optimization as tfmot
from tensorflow import keras

model = keras.models.load_model('cnn_model_best.keras')

quantize_model = tfmot.quantization.keras.quantize_model
q_aware_model = quantize_model(model)
q_aware_model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'])

q_aware_model.summary()
# %%
Y = keras.utils.to_categorical(labels, num_classes)
print(Y)
#%%
#Shuffle the dataset
x,y = shuffle(int_img,Y, random_state=2)
# Split the dataset
X_train, X_test, y_train, y_test = train_test_split(x, y, test_size=0.2, random_state=2)
# X_train = X_train.reshape(784,24,24)

#%%
q_aware_model.fit(X_train[0:100], y_train[0:100],
					epochs=80, validation_split=0.1)
# %%
baseline_model_accuracy = model.evaluate(
    X_test, y_test, verbose=0)

q_aware_model_accuracy = q_aware_model.evaluate(
   X_test, y_test, verbose=0)

print('Baseline test accuracy:', baseline_model_accuracy)
print('Quant test accuracy:', q_aware_model_accuracy)
# %%
import tensorflow as tf
converter = tf.lite.TFLiteConverter.from_keras_model(q_aware_model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.inference_input_type = tf.uint8
converter.inference_output_type = tf.uint8

quantized_tflite_model = converter.convert()
# %%
def evaluate_model(interpreter):
  input_index = interpreter.get_input_details()[0]["index"]
  output_index = interpreter.get_output_details()[0]["index"]

  # Run predictions on every image in the "test" dataset.
  prediction_digits = []
  for i, test_image in enumerate(X_test):
    if i % 1000 == 0:
      print('Evaluated on {n} results so far.'.format(n=i))
    # Pre-processing: add batch dimension and convert to float32 to match with
    # the model's input data format.
    test_image = np.expand_dims(test_image, axis=0).astype(np.uint8)
    interpreter.set_tensor(input_index, test_image[..., np.newaxis])

    # Run inference.
    interpreter.invoke()

    # Post-processing: remove batch dimension and find the digit with highest
    # probability.
    output = interpreter.tensor(output_index)
    digit = np.argmax(output()[0])
    prediction_digits.append(digit)

  print('\n')
  # Compare prediction results with ground truth labels to calculate accuracy.
  prediction_digits = np.array(prediction_digits)
  accuracy = (prediction_digits == y_test).mean()
  return accuracy
# %%
interpreter = tf.lite.Interpreter(model_content=quantized_tflite_model)
interpreter.allocate_tensors()

test_accuracy = evaluate_model(interpreter)

print('Quant TFLite test_accuracy:', test_accuracy)
print('Quant TF test accuracy:', q_aware_model_accuracy)
# %%
with open('qmodel.tflite', 'wb') as f:
    f.write(quantized_tflite_model)
# %%
