#! /bin/bash

# make sure Cookiecutter is there
source activate jupyter
pip install --upgrade cookiecutter

echo "Creating a new Cookiecutter project in $HOME/Projects"
cd $HOME/Projects
cookiecutter https://github.com/drivendata/cookiecutter-data-science
