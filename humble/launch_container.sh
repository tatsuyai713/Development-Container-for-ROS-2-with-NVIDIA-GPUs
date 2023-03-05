#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)

RESOLUTION_W="1920"
RESOLUTION_H="1080"

function InputVNCPassword() {
	echo "Please input VNC Password."
	read input
	if [ -z $input ] ; then
		InputVNCPassword
	else
		VNC_PASSWORD=$input 
	fi
}

sudo service docker start

sleep 3

NAME_IMAGE='nvidia_egl_desktop_ws'

# Make Container
if [ ! "$(docker image ls -q ${NAME_IMAGE})" ]; then
	if [ ! $# -ne 1 ]; then
		if [ "build" = $1 ]; then
			if [ "$http_proxy" ]; then
				echo "Image ${NAME_IMAGE} does not exist."
				echo 'Now building image with proxy...'
				docker build --file=./proxy.dockerfile -t $NAME_IMAGE . --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg UNAME=$USER --build-arg HTTP_PROXY=$http_proxy --build-arg HTTPS_PROXY=$https_proxy
			else
				echo "Image ${NAME_IMAGE} does not exist."
				echo 'Now building image without proxy...'
				docker build --file=./noproxy.dockerfile -t $NAME_IMAGE . --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg UNAME=$USER
			fi
			exit
		fi
	else
		echo "Docker image not found. Please setup first!"
		exit
  	fi
else
	if [ ! $# -ne 1 ]; then
		if [ "build" = $1 ]; then
			echo "Docker image is already built!"
			exit
		fi
	fi
fi


# Commit
if [ ! $# -ne 1 ]; then
	if [ "commit" = $1 ]; then
		echo 'Now commiting docker container...'
		docker commit nvidia_egl_desktop_docker nvidia_egl_desktop_ws:latest
		CONTAINER_ID=$(docker ps -a | grep nvidia_egl_desktop_docker | awk '{print $1}')
		docker stop $CONTAINER_ID
		docker rm $CONTAINER_ID -f
		exit
	fi
fi

# Stop
if [ ! $# -ne 1 ]; then
	if [ "stop" = $1 ]; then
		echo 'Now stopping docker container...'
		CONTAINER_ID=$(docker ps -a | grep nvidia_egl_desktop_docker | awk '{print $1}')
		docker stop $CONTAINER_ID
		docker rm $CONTAINER_ID -f
		exit
	fi
fi

XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
if [ ! -z "$xauth_list" ];  then
  echo $xauth_list | xauth -f $XAUTH nmerge -
fi
chmod a+r $XAUTH

DOCKER_OPT=""
DOCKER_NAME="nvidia_egl_desktop_docker"
DOCKER_WORK_DIR="/home/${USER}"
KERNEL=$(uname -r)

## For XWindow
DOCKER_OPT="${DOCKER_OPT} \
        --env=QT_X11_NO_MITSHM=1 \
        --volume=/home/${USER}:/home/${USER}/host_home:rw \
        --volume=/lib/modules/$(uname -r):/lib/modules/$(uname -r):rw \
        --volume=/usr/src/linux-headers-$(uname -r):/usr/src/linux-headers-$(uname -r):rw \
        --volume=/usr/src/linux-hwe-${KERNEL:0:4}-headers-${KERNEL:0:9}:/usr/src/linux-hwe-${KERNEL:0:4}-headers-${KERNEL:0:9}:rw \
        --env=XAUTHORITY=${XAUTH} \
		--env=TERM=xterm-256color \
		--env=QT_X11_NO_MITSHM=1 \
        --volume=${XAUTH}:${XAUTH} \
        --env=DISPLAY=${DISPLAY} \
        -w ${DOCKER_WORK_DIR} \
        -u ${USER} \
		--shm-size=4096m -e SIZEW=${RESOLUTION_W} -e SIZEH=${RESOLUTION_H}  -e NOVNC_ENABLE=true -p $(id -u):8080 \
        --hostname `hostname`-Docker \
        --add-host `hostname`-Docker:127.0.1.1"
		
## For nvidia-docker
DOCKER_OPT="${DOCKER_OPT} --gpus all --runtime=nvidia "
DOCKER_OPT="${DOCKER_OPT} --privileged -it "

# Device
if [ ! $# -ne 1 ]; then
	if [ "device" = $1 ]; then
		echo 'Enable host devices'
		DOCKER_OPT="${DOCKER_OPT} --volume=/dev:/dev:rw "
	fi
fi

## Allow X11 Connection
xhost +local:`hostname`-Docker
CONTAINER_ID=$(docker ps -a | grep nvidia_egl_desktop_ws: | awk '{print $1}')

# Run Container
if [ ! "$CONTAINER_ID" ]; then
	if [ ! $# -ne 1 ]; then
		if [ "setup" = $1 ]; then
			InputVNCPassword
			docker run ${DOCKER_OPT} \
				--name=${DOCKER_NAME} \
				-e PASSWD=${VNC_PASSWORD}  -e BASIC_AUTH_PASSWORD=${VNC_PASSWORD} \
				--entrypoint "/usr/bin/supervisord" \
				nvidia_egl_desktop_ws:latest
			CONTAINER_ID=$(docker ps -a | grep nvidia_egl_desktop_ws | awk '{print $1}')
			docker commit nvidia_egl_desktop_docker nvidia_egl_desktop_ws:latest
			docker stop $CONTAINER_ID
			docker rm $CONTAINER_ID -f
		else
			docker run ${DOCKER_OPT} \
				--name=${DOCKER_NAME} \
				--entrypoint "bash" \
				nvidia_egl_desktop_ws:latest
		fi
	else
		docker run ${DOCKER_OPT} \
			--name=${DOCKER_NAME} \
			--entrypoint "bash" \
			nvidia_egl_desktop_ws:latest
	fi
else
	docker start $CONTAINER_ID
	docker exec -it $CONTAINER_ID /bin/bash
fi

xhost -local:`hostname`-Docker

