#!/bin/bash
SHELL_DIR=$(cd $(dirname $0) && pwd)

cd $SHELL_DIR/scripts

NAME_IMAGE='nvidia_egl_jammy_desktop_ws'

sudo apt update
sudo apt install -y ansible

if [ $# -ne 1 ]; then
	echo "Please select keyboard type. (JP or US)"
	exit
fi
REGION=$1

if [ "$(docker image ls -q ${NAME_IMAGE})" ]; then
	echo "Docker image is already built!"
	exit
fi

echo "Build Container"

if [ "US" = $REGION ]; then
	./launch_container.sh build US
elif [ "JP" = $REGION ]; then
	./launch_container.sh build JP
else
	echo "Please select keyboard type. (JP or US)"
	exit
fi

nohup ./launch_container.sh novnc test > /tmp/nohup.out &

echo "Please wait 15 seconds..."
sleep 15

CONTAINER_ID=$(docker ps -a | grep nvidia_egl_jammy_desktop_docker | awk '{print $1}')
CONTAINER_IP=$(docker inspect $CONTAINER_ID | grep IPAddress | awk -F'[,,"]' 'NR==3{print $4}')

if [ ! -e ~/.ssh/id_rsa.pub  ]; then
	echo "Please make ssh key!"
	sleep 3
	ssh-keygen -t rsa
fi

ssh-keygen -R $CONTAINER_IP

echo ""
echo ""
echo "_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/"
echo "_/Please type 'test' as temporary password!!_/"
echo "_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/"
echo ""
echo ""
ssh-copy-id -i ~/.ssh/id_rsa.pub $CONTAINER_IP

ansible-playbook -i ../ansible/inventories/hosts.yml ../ansible/docker.yml

./launch_container.sh commit

echo "_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/"
echo "_/Building container is finished!!_/"
echo "_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/"
