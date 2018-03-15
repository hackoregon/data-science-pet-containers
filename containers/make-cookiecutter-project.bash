#! /bin/bash

echo "Creating a new Cookiecutter project in $HOME/Projects"
source activate jupyter
cd $HOME/Projects
cookiecutter https://github.com/drivendata/cookiecutter-data-science
