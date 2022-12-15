#!/bin/bash
# https://nickjanetakis.com/blog/docker-tip-56-volume-mounting-ssh-keys-into-a-docker-container
#set -e

# for SSH keyfiles
cp -R /tmp/.ssh /home/shiny/.ssh
chown -R shiny:shiny /home/shiny/.ssh
chmod 700 /home/shiny/.ssh
chmod 600 -R /home/shiny/.ssh/*

# expose python libraries
# TODO how else would you do that .. ?
# https://stackoverflow.com/a/38946665
rm /home/shiny/local/py/*.py
rm /home/shiny/local/py/*/*.py
rm -fr /home/shiny/local/py/__pycache__
R -e 'file.copy(system.file("py",package="cecelia"),"/home/shiny/local/",recursive=TRUE)'
R -e 'file.copy(system.file("config.yml",package="cecelia"),"/home/shiny/local/")'

# HPC server keygen here
# su - shiny -c "ssh-keyscan spartan.hpc.unimelb.edu.au > ~/.ssh/known_hosts"

# update cecelia
# for docker version: https://stackoverflow.com/a/65762156
#R -e 'lib <- Sys.getenv("R_LIBS_USER")[[1]];remotes::install_github("schienstockd/cecelia",lib=lib,Ncpus=4,repos="https://cloud.r-project.org",upgrade="never")'

# copy in local cecelia files
echo ">> Update app"
R -e 'cecelia::cciaUse("/home/shiny/local/cecelia",initConda=FALSE,sourceConda=FALSE);cecelia::cciaCreateApp()'

# copy config files
cp /home/shiny/local/custom.yml /home/shiny/local/cecelia/
cp /home/shiny/local/docker.yml /home/shiny/local/cecelia/

# move jupyter files
mv /home/shiny/local/connectionFile.* /home/shiny/local/cecelia/app/viewer/

# start shiny
R_CALL="library(cecelia);cciaUse('/home/shiny/local/cecelia',initJupyter=TRUE,jupyterConnectionFile='/home/shiny/local/cecelia/app/viewer/connectionFile.json',jupyterLibDir='$1');cciaRunApp(port=6860,host='0.0.0.0')"
R -e $R_CALL

#exec "$@"
