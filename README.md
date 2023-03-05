# nvidia-egl-desktop-ros2-humble

## Introduction

This is a Dockerfile to use ROS2 on KDE Plasma Desktop container with NVIDIA GPU.  
This Dockerfile is based on [selkies-project/docker-nvidia-egl-desktop](https://github.com/selkies-project/docker-nvidia-egl-desktop).

![](nvidia-egl-desktop-ros2-screenshot.png)

If you are interested in ROS1 version, please check [atinfinity/nvidia-egl-desktop-ros](https://github.com/atinfinity/nvidia-egl-desktop-ros).

## Requirements

- NVIDIA graphics driver 450.80.02+ [^1]
- Docker
- nvidia-docker2

## Build docker image

```
cd humble
./launch_container.sh build
```


## Launch docker container

Execute the command described below.  
If you customize setting, please read <https://github.com/selkies-project/docker-nvidia-egl-desktop/blob/main/README.md>.

```
./launch_container.sh setup
```

### Access KDE Plasma Desktop via web browser

Browse <http://127.0.0.1:<uid>/>.  
In this docker container, default account is `your login user`.  

[^1]: <https://github.com/selkies-project/docker-nvidia-egl-desktop/blob/main/README.md>
