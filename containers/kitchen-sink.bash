#! /bin/bash

source activate jupyter
conda install --yes --quiet \
  geopandas \
  matplotlib \
  pandas \
  psycopg2 \
  pysal \
  requests \
  seaborn \
  statsmodels
conda install --yes --quiet -c conda-forge \
  cookiecutter \
  osmnx
pip install --upgrade pip
pip install --upgrade gwr
