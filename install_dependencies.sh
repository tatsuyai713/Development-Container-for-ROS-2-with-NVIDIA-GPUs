#!/bin/bash


sudo apt install -y ansible

# Docker
curl https://get.docker.com | sh

sudo gpasswd -a ${USER} docker

sudo service docker restart