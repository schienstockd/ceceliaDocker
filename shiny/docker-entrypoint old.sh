#!/bin/bash
# https://nickjanetakis.com/blog/docker-tip-56-volume-mounting-ssh-keys-into-a-docker-container
#set -e

cp -R /tmp/.ssh /home/shiny/.ssh
chown -R shiny:shiny /home/shiny/.ssh
chmod 700 /home/shiny/.ssh
chmod 600 -R /home/shiny/.ssh/*

# HPC server keygen here
# su - shiny -c "ssh-keyscan spartan.hpc.unimelb.edu.au > ~/.ssh/known_hosts"

# start shiny
su - shiny -c "/usr/bin/shiny-server.sh"

#exec "$@"
