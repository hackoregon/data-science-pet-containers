#! /bin/bash
source activate jupyter
ipcluster nbextension enable --user
jupyter notebook --no-browser --ip=0.0.0.0 --port=8888
