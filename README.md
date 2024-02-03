# Development Container for ROS 2 with NVIDIA GPUs

## Release

- Version 0.01 Initial Release

## How to use

1. Clone this repository

```
git clone 
```

2. Build container and setup container environment


With Japanese Keyboard
```
./build_container JP
```

With English Keyboard
```
./build_container US

```

3. Start/Stop Container

No SSL
```
./start_container.sh all
./stop_container.sh
```

With SSL (Put the cert files on /home/user/ssl geberated by make_cert.sh)

```
SSL_ENABLE=true ./start_container.sh all
./stop_container.sh
```

Select GPU

```
./start_container.sh gpu0
```

```
./start_container.sh gpu1
```

Use all GPUs

```
./start_container.sh all
```

NO GPU

```
./start_container.sh none
```

4. How to attach container from terminal


```
./attach_container.sh
```

## How to access Desktop environment

From web browser (Chrome / Edge)

http://ip:1\<UserID\>

with SSL

https://ip:1\<UserID\>



## How to update container

```
./update_container.sh
```

## How to delete container

```
./delete_container.sh
```

