#!/bin/bash
# https://nickjanetakis.com/blog/docker-tip-56-volume-mounting-ssh-keys-into-a-docker-container
#set -e

# for SSH keyfiles
cp -R /tmp/.ssh /home/jovyan/.ssh
chown -R jovyan:jovyan /home/jovyan/.ssh
chmod 700 /home/jovyan/.ssh
chmod 600 -R /home/jovyan/.ssh/*

# expose python libraries
# TODO how else would you do that .. ?
# https://stackoverflow.com/a/38946665
rm /home/jovyan/local/py/*.py
rm /home/jovyan/local/py/*/*.py
rm -fr /home/jovyan/local/py/__pycache__
R -e 'file.copy(system.file("py",package="cecelia"),"/home/jovyan/local/",recursive=TRUE)'
R -e 'file.copy(system.file("config.yml",package="cecelia"),"/home/jovyan/local/")'

# HPC server keygen here
# su - shiny -c "ssh-keyscan spartan.hpc.unimelb.edu.au > ~/.ssh/known_hosts"

# update cecelia
# for docker version: https://stackoverflow.com/a/65762156
#R -e 'lib <- Sys.getenv("R_LIBS_USER")[[1]];remotes::install_github("schienstockd/cecelia",lib=lib,Ncpus=4,repos="https://cloud.r-project.org",upgrade="never")'

# copy in local cecelia files
echo ">> Update app"
R -e 'Sys.setenv(RETICULATE_MINICONDA_PATH="/home/jovyan/miniconda3");renv::load("/home/jovyan/cecelia");cecelia::cciaUse("/home/jovyan/local/cecelia",initConda=FALSE,sourceConda=FALSE);cecelia::cciaCreateApp()'

# copy models
cp -R /home/jovyan/cecelia/models /home/jovyan/local/cecelia/

# copy config files
cp /home/jovyan/local/custom.yml /home/jovyan/local/cecelia/
cp /home/jovyan/local/docker.yml /home/jovyan/local/cecelia/

# move jupyter files
mv /home/jovyan/local/connectionFile.* /home/jovyan/local/cecelia/app/viewer/

# start shiny
R_CALL="Sys.setenv(RETICULATE_MINICONDA_PATH='/home/jovyan/miniconda3');renv::load('/home/jovyan/cecelia');library(cecelia);cciaUse('/home/jovyan/local/cecelia',initJupyter=TRUE,jupyterConnectionFile='/home/jovyan/local/cecelia/app/viewer/connectionFile.json',jupyterLibDir='$1');cciaRunApp(port=6860,host='0.0.0.0')"
R -e $R_CALL

#exec "$@"
