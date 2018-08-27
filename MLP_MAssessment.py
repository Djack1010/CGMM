import numpy as np
import sys
from keras.models import Sequential
from keras.layers import Dense, Dropout

def printOverwrite(toPrint):
    sys.stdout.write('\r' + str(toPrint) + ' ' * 20)
    sys.stdout.flush()

# Generate dummy data
#x_train = np.random.random((10, 20))
#y_train = np.random.randint(2, size=(10, 1))
#x_test = np.random.random((1, 20))
#y_test = np.random.randint(2, size=(1, 1))

#---VARIABLE TO SET---
batch_size=128 #256 #128
epochs=40
#---------------------

print("Loading data...",end="",flush=True)
data = np.loadtxt("RESULTS/DATASET_40_8_SeTNull4LightAllTF.txt", delimiter=',', dtype = float)
print("DONE! Vector size: ",data.shape)


#x_train = np.concatenate((kfold[0], kfold[1]))

model = Sequential()
model.add(Dense(64, input_dim=data.shape[1]-1, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(64, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(1, activation='sigmoid'))

final_loss=0
final_acc=0
model.compile(loss='binary_crossentropy',
            optimizer='rmsprop',
            metrics=['accuracy'])

x_train = data[:,:-1]
y_train = data[:, [data.shape[1]-1]]

history=model.fit(x_train, y_train, verbose=1,
        epochs=epochs,
        batch_size=batch_size)

# serialize model to JSON
model_json = model.to_json()
with open("checkpoints/modelMLP_SeTNull4lightAll/model.json", "w") as json_file:
    json_file.write(model_json)
# serialize weights to HDF5
model.save_weights("checkpoints/modelMLP_SeTNull4lightAll/model.h5")
print("Saved model to disk")