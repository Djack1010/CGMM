## Dependency
Python 3 or 2.6

scikit-learn - Machine Learning in Python (http://scikit-learn.org/stable/index.html).
```
sudo apt install python3-sklearn
```

### File Format

#### Input
The supported input format is an adjacent list stored in a '.adjlist' file. 
The 'StandardParser.py' file use the following format (line example):
```
node_id_int node_label_int (sourceNodeIncoming1_id_int edgeIncoming1_label_int) ... (sourceNodeIncomingN_id_int edgeIncomingN_label_int) 
```	
NB. The adjacent list stores INCOMING edges!

#### Authors
* **Federico Errica** - [diningphil](https://github.com/diningphil)
* **Giacomo Iadarola** - [Djack1010](https://github.com/Djack1010)
