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

# get script directory
DIR_NAME="$(cd "$(dirname "$0")" > /dev/null 2>&1 || exit; pwd -P)"
cd $DIR_NAME

# OMP: Error #15: Initializing libiomp5.dylib, but found libomp.dylib already initialized.
# https://github.com/dmlc/xgboost/issues/1715#issuecomment-438924721
export KMP_DUPLICATE_LIB_OK=TRUE

# run cecelia
$CONDA_DIR/bin/conda run -n r-cecelia-gui-env --no-capture-output python cecelia-docker.py
