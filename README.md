# nvidia-egl-desktop-with-ros
## Introduction

This is a Dockerfile to use ROS 2 on KDE Plasma Desktop container with NVIDIA GPU.  
This Dockerfile is based on [selkies-project/docker-nvidia-egl-desktop](https://github.com/selkies-project/docker-nvidia-egl-desktop).

![](nvidia-egl-desktop-ros2-screenshot.png)

## Requirements

- NVIDIA graphics driver 450.80.02+ [^1]
- Docker
- nvidia-docker2

## Build Japanese docker image

```
cd jammy
./launch_container.sh build JP # Support Japanese
```
## Build US docker image

```
cd jammy
./launch_container.sh build US
```

## Launch docker container with novnc (Web Browser)

Execute the command described below.  
```
./launch_container.sh novnc
```

### Access KDE Plasma Desktop via web browser

Browse <http://127.0.0.1:uid/>.  
In this docker container, default account is `your login user name`.  

[^1]: <https://github.com/selkies-project/docker-nvidia-egl-desktop/blob/main/README.md>


## Launch docker container with bash

Execute the command described below.  
```
./launch_container.sh
```