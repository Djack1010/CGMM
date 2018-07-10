from CGMM.TrainingUtilities import *
from StandardParser import parse
from datetime import datetime
import argparse
import sys
import os

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

#------VARIABLE TO SET-----
# Number of arc labels
A = args.arcLabels 
# Number of node labels
M = args.nodeLabels         
# Data Path
DATA_PATH=args.dataPath
#--------------------------

name = args.name

C = args.C
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

X_train, Y_train, adjacency_lists_train, sizes_train = unravel(graphs, one_target_per_graph=True)

# PERFORM TRAINING over the entire training and validation set
architecture = None
prevStats = None
lastStates = None
architecture, prevStats, lastStates = incremental_training(C, M, A, Lprec, adjacency_lists_train, X_train,
                                                            layers=layer,
                                                            threshold=threshold, max_epochs=max_epochs,
                                                            architecture=architecture,
                                                            prev_statistics=prevStats,
                                                            last_states=lastStates)

unigram_train, allStates_train = compute_input_matrix(architecture, C, X_train, adjacency_lists_train, sizes_train,
                                                        concatenate=concatenate_fingerprints, return_all_states=True)

with open('./fingerprints/temp.txt','w') as o:
    np.savetxt(o, unigram_train, fmt='%.6f',delimiter = ',')

ind=0
with open('./RESULTS/vector_'+str(C)+ '_' +str(layer)+ '_' +str(name)+'.txt','w') as o:
    with open('./fingerprints/temp.txt','r') as t:
        for line in t:
            o.write(line.rstrip('\n') + ',' + str(Y_train[ind]) + '\n')
            ind += 1

os.remove('./fingerprints/temp.txt')
        