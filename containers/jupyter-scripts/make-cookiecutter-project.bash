#! /bin/bash

echo "Creating a new Cookiecutter project in $HOME/Projects"
source activate jupyter
conda install --yes --quiet -c conda-forge cookiecutter
cd $HOME/Projects
cookiecutter https://github.com/drivendata/cookiecutter-data-science
