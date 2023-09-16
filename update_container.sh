#!/bin/bash

SHELL_DIR=$(cd $(dirname $0) && pwd)

cd $SHELL_DIR/scripts

NAME_IMAGE='nvidia_egl_jammy_desktop_ws'

sudo apt update
sudo apt install -y ansible

if [ ! "$(docker image ls -q ${NAME_IMAGE})" ]; then
	echo "Docker image not found."
	exit
fi

echo "START UPDATE..."

nohup ./launch_container.sh novnc test > /tmp/nohup.out &

echo "Please wait 15 seconds..."
sleep 15

CONTAINER_ID=$(docker ps -a | grep nvidia_egl_jammy_desktop_docker | awk '{print $1}')
CONTAINER_IP=$(docker inspect $CONTAINER_ID | grep IPAddress | awk -F'[,,"]' 'NR==3{print $4}')

ansible-playbook -i ../ansible/inventories/hosts.yml ../ansible/docker.yml

./launch_container.sh commit

echo "_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/"
echo "_/Updating container is finished!!_/"
echo "_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/"
