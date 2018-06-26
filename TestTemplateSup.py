from CGMM.TrainingUtilities import *
from StandardParser import parse

#------VARIABLE TO SET-----
# Number of arc labels
A = 4 
# Number of node labels
M = 122         
# Data Path
DATA_PATH='./Example_Data/' 
#--------------------------

name = 'TestTemplate'

C = 40
layer = 2
concatenate_fingerprints = True

svmC = 100
gamma = 5
unibigram = True

threshold = 0.
max_epochs = 3
Lprec = np.array([1], dtype='int')

graphs_train = parse(DATA_PATH, 'sup')
X_train, Y_train, adjacency_lists_train, sizes_train = unravel(graphs_train, one_target_per_graph=True)

# OPEN A LOG FILE WHERE TO STORE RESULTS
logging.basicConfig(
    filename=name + '_' + datetime.now().strftime('%Y-%m-%d %H:%M:%S') + '.log', level=logging.DEBUG, filemode='a')

# PERFORM TRAINING over the entire training set
runs = 1
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


    with open("fingerprints/" + name + '_' + str(run) + '_' + str(C) + '_' + str(layer) + '_' + str(Lprec)
                      + '_' + str(concatenate_fingerprints), 'wb') as f:

        # DEBUG: use a validation set equal to train. Just to make it work!
        unigram_valid, allStates_valid, adjacency_lists_valid, sizes_valid, Y_valid = unigram_train, allStates_train, adjacency_lists_train, sizes_train, Y_train

        pickle.dump([unigram_train, unigram_valid, allStates_train, allStates_valid, adjacency_lists_train, adjacency_lists_valid, sizes_train, sizes_valid, Y_train, Y_valid], f)


    fingerprints_to_svm_accuracy(C, Lprec, layer, runs, svmC, gamma, concatenate_fingerprints, name)