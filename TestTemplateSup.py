from CGMM.TrainingUtilities import *
from StandardParser import parse
from datetime import datetime
import argparse
import sys
import os

parser = argparse.ArgumentParser()
parser.add_argument("--arcLabels", "-al", type=int, default=4, help="number of arc labels (default 4)")
parser.add_argument("--nodeLabels", "-nl", type=int, default=384, help="number of node labels (default 384)")
parser.add_argument("--trainDataPath", "-tdp", default="./Example_Data/", help="training data path (./Example_Data/)")
parser.add_argument("--validDataPath", "-vdp", default="./Example_Data/", help="validation data path (./Example_Data/)")
parser.add_argument("-C", "--C", type=int, default=40, help="default 40")
parser.add_argument("--fingerprintsFolder", "-ff", default="f1", help="default f1")
parser.add_argument("--layers", "-l", type=int, default=6, help="number of layers (default 6)")
parser.add_argument("--runs", "-r", type=int, default=1, help="number of runs (default 1)")
#parser.add_argument("-concatenate", "--concatenate", action='store_true', help="number of layers (default 6)")
parser.add_argument("--epochs", "-e", type=int, default=15, help="number of epochs (default 15)")
#parser.add_argument("-v", "--verbose", action="store_true", help="increase output verbosity")
args = parser.parse_args()

#------VARIABLE TO SET-----
# Number of arc labels
A = args.arcLabels 
# Number of node labels
M = args.nodeLabels         
# Data Path
DATA_PATH_TRAINING=args.trainDataPath
DATA_PATH_VALIDATION=args.validDataPath
fingFolder=args.fingerprintsFolder
#--------------------------

name = 'Test_' + args.fingerprintsFolder

C = args.C
layer = args.layers
concatenate_fingerprints = True

#svmC = 10
#gamma = 5

threshold = 0.
max_epochs = args.epochs
Lprec = np.array([1], dtype='int')
print('Dataset info -> Node labels:',M,'; Arc labels:',A)
print('Hyperparameters -> C:',C,'; layers:',layer,'; epochs:',max_epochs)

print('Parse Training Data')
graphs_train = parse(DATA_PATH_TRAINING, 'sup')

print('Parse Validation Data')
graphs_valid = parse(DATA_PATH_VALIDATION, 'sup')
print('Parsing DONE')

X_train, Y_train, adjacency_lists_train, sizes_train = unravel(graphs_train, one_target_per_graph=True)
X_valid, Y_valid, adjacency_lists_valid, sizes_valid = unravel(graphs_valid, one_target_per_graph=True)

# OPEN A LOG FILE WHERE TO STORE RESULTS
timenow=str(datetime.now())
logging.basicConfig(filename='Test_sup.log', level=logging.DEBUG, filemode='a')
logging.info('NEW EXPERIMENT ' + fingFolder +' -> start at '+ timenow) #C:',C,'; layers:',layer,'; epochs:',max_epochs
logging.info('INFO: ' + str(A) + ' ' + str(M) + ' ' + str(C) + ' ' + str(layer) + ' ' + str(concatenate_fingerprints) + ' ' + str(max_epochs) + ' ' + str(Lprec))

# PERFORM TRAINING over the entire training and validation set
runs = args.runs
for run in range(0, runs):

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

    unigram_valid, allStates_valid = compute_input_matrix(architecture, C, X_valid, adjacency_lists_valid, sizes_valid,
                                                        concatenate=concatenate_fingerprints, return_all_states=True)

    newpath = "./fingerprints/" + fingFolder + "/"
    if not os.path.exists(newpath):
        os.makedirs(newpath)

    with open(newpath + name + '_' + str(run) + '_' + str(C) + '_' + str(layer) + '_' + str(Lprec) + '_' + str(concatenate_fingerprints) + '.cgmmOutput', 'wb') as f:
        pickle.dump([unigram_train, unigram_valid, allStates_train, allStates_valid, adjacency_lists_train, adjacency_lists_valid, sizes_train, sizes_valid, Y_train, Y_valid], f)
        #pickle.dump(Info di architecture)

svmCs=[100, 50, 25, 10, 5, 2, 1 ]
gammas=[50, 25, 10, 5, 2, 1 ]
fingerprints_to_svm_accuracy_SEARCH_BEST_HYPERPAR(newpath, C, Lprec, layer, runs, svmCs, gammas, concatenate_fingerprints, name)