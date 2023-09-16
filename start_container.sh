#!/bin/bash

SHELL_DIR=$(cd $(dirname $0) && pwd)

cd $SHELL_DIR/scripts
VNC_PASSWORD="test"

function InputVNCPassword() {
	echo "Please input VNC Password."
	read input
	if [ -z $input ] ; then
		InputVNCPassword
	else
		VNC_PASSWORD=$input 
	fi
}

if [ "$(docker ps -al | grep nvidia_egl_jammy_desktop_docker)" ]; then
	echo "docker container restarting..."
	CONTAINER_ID=$(docker ps -a | grep nvidia_egl_jammy_desktop_ws: | awk '{print $1}')
	
	sudo rm -rf /tmp/.docker.xauth
	XAUTH=/tmp/.docker.xauth
	touch $XAUTH
	xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
	if [ ! -z "$xauth_list" ]; then
		echo $xauth_list | xauth -f $XAUTH nmerge -
	fi
	chmod a+r $XAUTH

	docker start $CONTAINER_ID
	exit
fi
sudo pwd # check sudo
InputVNCPassword
nohup ./launch_container.sh novnc ${VNC_PASSWORD} > /tmp/nohup.out &
