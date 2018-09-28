from keras.models import Sequential, model_from_json
import numpy as np
import matplotlib.pyplot as plt
import keras.backend as K

from keras.layers import Dense, Dropout

class KerasDropoutPrediction(object):
    def __init__(self,model):
        self.f = K.function(
                [model.layers[0].input, 
                 K.learning_phase()],
                [model.layers[-1].output])
    def predict(self,x, n_iter=10):
        result = []
        for _ in range(n_iter):
            result.append(self.f([x , 1]))
        result = np.array(result).reshape(n_iter,len(x)).T
        return result

#### TO LOAD THE MODEL ######
##load json and create model
#json_file = open('checkpoints/modelMLP_SeTNull4lightAll/model.json', 'r')
#loaded_model_json = json_file.read()
#json_file.close()
#loaded_model = model_from_json(loaded_model_json)
##load weights into new model
#loaded_model.load_weights("checkpoints/modelMLP_SeTNull4lightAll/model.h5")
#print("Loaded model from disk")
###############################

##### TO TRAIN THE MODEL ######
batch_size=128 #256 #128
epochs=50
print("Loading data...",end="",flush=True)
data = np.loadtxt("RESULTS/DATASET_40_8_SeTNull4LightAllTF.txt", delimiter=',', dtype = float)
print("DONE! Vector size: ",data.shape)
model = Sequential()
model.add(Dense(512, input_dim=data.shape[1]-1, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(512, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(1, activation='sigmoid'))
model.compile(loss='binary_crossentropy',
            optimizer='rmsprop',
            metrics=['accuracy'])
x_train = data[:,:-1]
y_train = data[:, [data.shape[1]-1]]
history=model.fit(x_train, y_train, verbose=1,
        epochs=epochs,
        batch_size=batch_size)
loaded_model = model
################################

print("Loading test data...",end="",flush=True)
data_test = np.loadtxt("RESULTS/vector_40_8_SeTNull4lightAll.txt", delimiter=',', dtype = float)
print("DONE! Vector size: ",data_test.shape)

x_test = data_test[:,:-1]
y_test = data_test[:, [data_test.shape[1]-1]]

print("Dropout predictions...",end="",flush=True)
kdp = KerasDropoutPrediction(loaded_model)
y_pred_do = kdp.predict(x_test,n_iter=30)
y_pred_do_mean = y_pred_do.mean(axis=1)
print("DONE!")

print("Predictions without dropout...",end="",flush=True)
y_pred = loaded_model.predict(x_test)
print("DONE!")

#plt.figure(figsize=(5,5))
#plt.scatter(y_pred_do_mean , y_pred, alpha=0.1)
#plt.xlabel("The average of dropout predictions")
#plt.ylabel("The prediction without dropout from Keras")
#plt.show()
#with open("RESULTS/prova.txt", "w") as pred_file:
#    for row in y_pred_do:
#        pred_file.write("{:.4f}".format(np.mean(row))+"+"+"{:.4f}".format(np.std(row))+"\n")

#plt.hist(y_pred, bins='auto')  # arguments are passed to np.histogram
#plt.title("Histogram with 'auto' bins")
#plt.show()
#
#plt.hist(y_pred_do_mean, bins='auto')  # arguments are passed to np.histogram
#plt.title("Histogram with 'auto' bins")
#plt.show()
#
with open("RESULTS/predStandard.txt", "w") as pred_file:
    np.savetxt(pred_file,y_pred,fmt='%1.4f')

with open("RESULTS/predDropMean.txt", "w") as pred_file:
    np.savetxt(pred_file,y_pred_do_mean,fmt='%1.4f')

with open("RESULTS/predDropStd.txt", "w") as pred_file:
    for row in y_pred_do:
        pred_file.write("{:.4f}".format(np.mean(row))+"+"+"{:.4f}".format(np.std(row))+"\n")
