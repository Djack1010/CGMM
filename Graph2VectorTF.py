from __future__ import absolute_import, division, print_function
from CGMMTF.TrainingUtilities import *
from StandardParser import parse
import argparse
import sys
import os

import pickle

parser = argparse.ArgumentParser()
parser.add_argument("--arcLabels", "-al", type=int, default=4, help="number of arc labels (default 4)")
parser.add_argument("--nodeLabels", "-nl", type=int, default=379, help="number of node labels (default xxx)")
parser.add_argument("--dataPath", "-dp", default="./data/data_COMPLETE/", help="data path (./data/data_COMPLETE/)")
parser.add_argument("-C", "--C", type=int, default=40, help="default 40")
parser.add_argument("--layers", "-l", type=int, default=8, help="number of layers (default 8)")
#parser.add_argument("-concatenate", "--concatenate", action='store_true', help="number of layers (default 6)")
parser.add_argument("--epochs", "-e", type=int, default=20, help="number of epochs (default 20)")
parser.add_argument("--name", "-n", default="NoNameSet", help="name of the output file (default NoNameSet)")
#parser.add_argument("-v", "--verbose", action="store_true", help="increase output verbosity")
args = parser.parse_args()

# Number of arc labels
A = args.arcLabels 
# Number of node labels
M = args.nodeLabels         
# Data Path
DATA_PATH=args.dataPath

name = args.name

C = args.C
C2 = args.C
layer = args.layers
concatenate_fingerprints = True

threshold = 0.
max_epochs = args.epochs
Lprec = np.array([1], dtype='int')
print('Dataset info -> Node labels:',M,'; Arc labels:',A)
print('Hyperparameters -> C:',C,'; layers:',layer,'; epochs:',max_epochs)

print('Parse Data')
graphs = parse(DATA_PATH, 'sup')
print('Parsing DONE')

X, Y, adjacency_lists, sizes = unravel(graphs, one_target_per_graph=True)

target_dataset = tf.data.Dataset.from_tensor_slices(np.reshape(X, (X.shape[0], 1)))

# use_statistics = [1, 3]  # e.g use the layer-1 and layer-3 statistics
use_statistics = [1]
batch_size = 2000

'''
# WARNING: if you reuse the statistics, make sure the order of the vertexes is the same
# do NOT re-shuffle the dstatisticheataset if you want to keep using them
'''

save_name = 'first_experiment'
statistics_name = save_name + '_statistiche'
unigram_inference_name_train = save_name + '_unigrams_train'

statistics_inference_name = save_name + '_statistiche_inferenza'

# Training and inference phase
incremental_training(C, M, A, use_statistics, adjacency_lists, target_dataset.batch(batch_size), layer, statistics_name,
                         threshold=0, max_epochs=max_epochs, batch_size=2000, save_name=save_name)


# Now recreate the dataset and the computation graph, because incremental_training resets the graph at the end
# (after saving the model)
target_dataset = tf.data.Dataset.from_tensor_slices(np.reshape(X, (X.shape[0], 1)))

incremental_inference(save_name, M, A, C, layer, use_statistics, target_dataset.batch(batch_size), adjacency_lists, sizes,
                          unigram_inference_name_train, statistics_inference_name, batch_size=batch_size)

list_layers=[]
for i in range(layer):
    list_layers.append(i)

unigrams_train = recover_unigrams(unigram_inference_name_train, layers=list_layers,
                            C=C, concatenate=True, return_numpy=True)

with open('./fingerprints/temp.txt','w') as o:
    np.savetxt(o, unigrams_train, fmt='%.6f',delimiter = ',')

ind=0
with open('./RESULTS/vector_'+str(C)+ '_' +str(layer)+ '_' +str(name)+'.txt','w') as o:
    with open('./fingerprints/temp.txt','r') as t:
        for line in t:
            o.write(line.rstrip('\n') + ',' + str(Y[ind]) + '\n')
            ind += 1

os.remove('./fingerprints/temp.txt')