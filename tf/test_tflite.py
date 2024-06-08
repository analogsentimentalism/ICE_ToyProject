#%%
import tensorflow as tf
import os
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'
from tensorflow import keras
# from keras.utils import to_categorical
# from keras.models import Sequential
# from keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout
# from keras.layers import ReLU, Softmax
# from keras.callbacks import ModelCheckpoint, EarlyStopping
import logging
import numpy as np
logging.getLogger("tensorflow").setLevel(logging.DEBUG)
#%%
def create_model():
    input_shape=(4,4,1)

    model = Sequential()
    model.add(keras.layers.Conv2D(1, (3, 4), input_shape=input_shape, padding='same'))

    model.compile(loss='categorical_crossentropy', metrics=['accuracy'],optimizer='RMSprop')
    
    return model

#%%
tensorflow_model = create_model()
# tensorflow_model.save('test_tensorflow_model.keras')

#%%

img_data = np.array([[[[np.float32(1)] for i in range (4)] for j in range (4)] for k in range (3)])

#%%
def representative_data_gen():
  for input_value in tf.data.Dataset.from_tensor_slices(img_data).batch(1).take(100):
    yield [input_value]


#%%
converter = tf.lite.TFLiteConverter.from_keras_model(tensorflow_model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.uint8
converter.inference_output_type = tf.int8
#%%
converter.representative_dataset = representative_data_gen
tflite_model = converter.convert()
with open('test_tflite.tflite', 'wb') as f:
    f.write(tflite_model)
# %%
interpreter = tf.lite.Interpreter(model_path='test_tflite.tflite',  experimental_preserve_all_tensors=True)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()
print(input_details)
print("== Input details ==")
print("name:", input_details[0]['name'])
print("shape:", input_details[0]['shape'])
print("type:", input_details[0]['dtype'])
print("\n== Output details ==")
print("name:", output_details[0]['name'])
print("shape:", output_details[0]['shape'])
print("type:", output_details[0]['dtype'])

print("\n---------------------------------------\n")
# %%
for item in interpreter.get_tensor_details():
    print(item['name'], "\nindex: " , item['index'],"\nshape: ",item['shape'],"\n")
# %%
test_image = tf.constant(np.uint8(128), shape=[1,4,4,1])
# test_input = [[[[np.int8(-5) for i in range (12)] for j in range(3)] for k in range(3)]]
interpreter.set_tensor(input_details[0]['index'], test_image)
# interpreter.set_tensor(5, [[[[np.int8(0)] for i in range(3)] for j in range(3)] for k in range(4)])
# interpreter.set_tensor(4, [np.int32(99507) for i in range(4)])
# interpreter.set_tensor(11, [[[[np.int8(0)] for i in range(3)] for j in range(3)] for k in range(4)])
interpreter.invoke()
print(interpreter.get_tensor(3))
print("--------------------------")
print("*1st Conv Filter")
print(interpreter.get_tensor(2))
print("--------------------------")
print("*1st Conv Bias")
print(interpreter.get_tensor(1))
print("--------------------------")
print("1st Conv")
print(interpreter.get_tensor(4))
print("--------------------------")
# %%
