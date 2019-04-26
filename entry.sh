#!/bin/bash -eu

groupdel docker
groupadd -g "$(stat -c '%g' /var/run/docker.sock)" docker
usermod -aG docker sgibbs

sudo -u sgibbs tmux -S /home/sgibbs/workstation/tmux.socket new -t workstation -s workstation -d

sleep infinity
