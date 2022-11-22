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

echo ">> START IPYTHON"

DIR_NAME="$(cd "$(dirname "$0")" > /dev/null 2>&1 || exit; pwd -P)"
cd $DIR_NAME

CONDA_ENV=r-cecelia-gui-env
CONN_FILE=$DIR_NAME/app/viewer/connectionFile.json
DEBUG_CONN_FILE=$DIR_NAME/app/viewer/connectionFile.debug.json

# remove connection file for IPython kernel
rm $CONN_FILE

# init conda
source $CONDA_DIR/bin/activate
conda activate $CONDA_ENV

# start IPython kernel
#ipython kernel -f=$CONN_FILE 2>&1 &
#jupyter kernel --KernelManager.connection_file=$CONN_FILE &
ipython kernel -f=$CONN_FILE &

# DOCKER specific
# wait for file to be created
watch -g -t -n 0.1 "ls $CONN_FILE"

# replace IP to access host from docker
cp $CONN_FILE $DEBUG_CONN_FILE
LC_ALL=C sed -i '' -e 's/127.0.0.1/host.docker.internal/g' $CONN_FILE

# return back job id
PID=$!

echo ">> START SHINY"

# remove previous processes that might have failed
# TODO a bit drastic and would kill everything listening
# on port 6860
lsof -t -iTCP:6860 -sTCP:LISTEN | xargs kill -9

# start docker
docker compose up

# kill python
killall $PID
