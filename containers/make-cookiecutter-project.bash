#! /bin/bash

# make sure Cookiecutter is there
source activate jupyter
pip install --upgrade cookiecutter

echo "Creating a new Cookiecutter project in $HOME/Projects"
cd $HOME/Projects
cookiecutter https://github.com/drivendata/cookiecutter-data-science

echo "Next steps:"
echo "1. 'cd' into your new project."
echo "2. make create_environment"
echo "3. source activate <new-environment>"
echo "4. make requirements"
