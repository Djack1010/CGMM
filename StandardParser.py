import numpy as np
import random

import os

def parse(data_path='./Example_Data/', mode='unsup', shuffle=True):

    graphs = []

    files = os.listdir(data_path)

    for basefile in files:

        if basefile.endswith('.adjlist'):

            filename=data_path+basefile

            print('Working with', filename)

            prefix = filename[:-8]  # remove .adjlist

            #labels_filename = 'labels_C5-' + prefix + '.txt'

            print('Parsing', prefix)

            lines = open(filename).readlines()[1:]  # skip the first line
            #labels_lines = open(labels_filename).readlines()[1:]  # skip the first line

            adjacency_lists = []
            X = []
            Y = []


            for line in lines:

                line = line.split()

                node_id  = int(line[0])
                label_id = int(line[1])
                adj_list = line[2:]

                print('NodeID:',node_id,',label:',label_id,',Number of incoming edges:', len(adj_list)//2)
                print('adj_list:', adj_list)

                incoming_list = []

                X.append(label_id)
                if mode == 'unsup':
                    Y.append(label_id)
                

                for i in range(0, len(adj_list)//2):

                    incoming_id = int(adj_list[i*2][1:])  # removes the (
                    arc_label   = int(adj_list[i*2 + 1][:-1])  # removes the )
                    incoming_list.append((incoming_id, arc_label))

                adjacency_lists.append(incoming_list)

            # A graph is a tuple (X,Y,adj_lists,dim), where Y==X in unsup. tasks
            if mode == 'sup':
                if prefix[-1] == 0 :
                    Y.append(0)
                else:
                    Y.append(1)
            graphs.append((np.array(X, dtype='int'), np.array(Y, dtype='int'), adjacency_lists, len(adjacency_lists)))

    if shuffle:
        random.shuffle(graphs)

    print("Parsed ", len(graphs), " graphs")

    return graphs


graphs = parse()
