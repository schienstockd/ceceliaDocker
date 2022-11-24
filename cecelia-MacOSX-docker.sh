#!/bin/bash
# get conda directory
if [ -d ~/opt/anaconda3 ]; then
  CONDA_DIR=~/opt/anaconda3
elif [ -d ~/anaconda3 ]; then
  CONDA_DIR=~/anaconda3
elif [ -d ~/opt/miniconda3 ]; then
	CONDA_DIR=~/opt/miniconda3
elif [ -d ~/miniconda3 ]; then
	CONDA_DIR=~/miniconda3
fi

echo ">> START Cecelia"

# run cecelia
$CONDA_DIR/bin/conda run -n r-cecelia-gui-env --no-capture-output python cecelia-docker.py
