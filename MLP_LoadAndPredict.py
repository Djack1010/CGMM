import numpy as np
import sys
from keras.models import Sequential, model_from_json
from keras.layers import Dense, Dropout

# Generate dummy data
#x_train = np.random.random((10, 20))
#y_train = np.random.randint(2, size=(10, 1))
#x_test = np.random.random((1, 20))
#y_test = np.random.randint(2, size=(1, 1))

#---VARIABLE TO SET---
batch_size=128 #256 #128
#---------------------

print("Loading data...",end="",flush=True)
#"RESULTS/vector_40_8_SeTNull4lightAll.txt"
data = np.loadtxt("RESULTS/vector_40_8_SeTNull4lightAll.txt", delimiter=',', dtype = float)
print("DONE! Vector size: ",data.shape)

x_test = data[:,:-1]
y_test = data[:, [data.shape[1]-1]]

# load json and create model
json_file = open('checkpoints/modelMLP_SeTNull4lightAll/model.json', 'r')
loaded_model_json = json_file.read()
json_file.close()
loaded_model = model_from_json(loaded_model_json)


# load weights into new model
loaded_model.load_weights("checkpoints/modelMLP_SeTNull4lightAll/model.h5")
print("Loaded model from disk")
 
# evaluate loaded model on test data -> THERE IS NO TARGET FOR TEST DATA!!!
#loaded_model.compile(loss='binary_crossentropy', optimizer='rmsprop', metrics=['accuracy'])
#score = loaded_model.evaluate(x_test, y_test, batch_size=batch_size, verbose=1)
#print("%s: %.2f%%" % (loaded_model.metrics_names[1], score[1]*100))

#NB: newData has to contain at least 2 samples, if only one it fails
#newData=np.loadtxt("RESULTS/vector_40_8_SeTNull4lightAll.txt", delimiter=',', dtype = float)
#if data.shape[1]-1 < newData.shape[1]:
#    newData=newData[:,:-1]
#
pred=loaded_model.predict(x_test)
with open("RESULTS/pred.txt", "w") as pred_file:
    np.savetxt(pred_file,pred,fmt='%1.4f')
    #pred_file.write(pred)

print("Saved prediction on RESULTS/pred.txt")