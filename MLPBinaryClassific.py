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
folds=10
runs=1
epochs=25
batch_size=128 #256 #128
#---------------------

print("Hyperparameters: folds",folds,"runs",runs,"epochs",epochs,"batch size",batch_size)
print("Loading data...",end="",flush=True)
data = np.loadtxt("RESULTS/DATASET_40_8_SeTNull4LightAllTF.txt", delimiter=',', dtype = float)
print("DONE! Vector size: ",data.shape)
kfold =  np.array_split(data, folds)


#x_train = np.concatenate((kfold[0], kfold[1]))

model = Sequential()
model.add(Dense(64, input_dim=data.shape[1]-1, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(64, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(1, activation='sigmoid'))

final_loss=0
final_acc=0
for run in range(runs):

    model.compile(loss='binary_crossentropy',
              optimizer='rmsprop',
              metrics=['accuracy'])

    test_result=[]
    for tr in range(folds):
        data_test = kfold[tr]
        if tr == 0:
            a = 1
        else:
            a = 0
        data_train = kfold[a]
        for te in [x for x in range(folds) if x != tr and x != a ]:
            data_train =np.concatenate((data_train, kfold[te]))
        toPrint="RUN "+str(run+1)+" out of "+str(runs)+" --- KFOLD "+str(tr+1)+" out of "+str(folds)
        printOverwrite(toPrint)
        x_train = data_train[:,:-1]
        y_train = data_train[:, [data_train.shape[1]-1]]
        x_test = data_test[:,:-1]
        y_test = data_test[:, [data_train.shape[1]-1]]
        history=model.fit(x_train, y_train, verbose=0,
                epochs=epochs,
                batch_size=batch_size)
        score = model.evaluate(x_test, y_test, batch_size=batch_size, verbose=0)
        test_result.append(score)

    loss=0
    acc=0
    for l in range(len(test_result)):
        loss=loss+test_result[l][0]
        acc=acc+test_result[l][1]

    loss=loss/len(test_result)
    acc=acc/len(test_result)
    final_loss=final_loss+loss
    final_acc=final_acc+acc


final_loss=final_loss/runs
final_acc=final_acc/runs
print()
print("LOSS:",final_loss)
print("ACC:",final_acc)

#NB: newData has to contain at least 2 samples, if only one it fails
newData=np.loadtxt("RESULTS/vector_40_8_SeTNull4lightAll.txt", delimiter=',', dtype = float)
if data.shape[1]-1 < newData.shape[1]:
    newData=newData[:,:-1]

pred=model.predict(newData)
print(pred)