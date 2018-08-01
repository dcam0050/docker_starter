#!/usr/bin/env bash
nvidia-docker run -dit \
				--env="DISPLAY="$DISPLAY  \
				--env="QT_X11_NO_MITSHM=1"  \
				--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"  \
				--volume=/dev/snd:/dev/snd	 \
				--volume="/home/"$USER"/docker_home:/home/icub/user_files:rw" \
				--volume="/dev/bus/usb:/dev/bus/usb" \
				--name=$2  \
				--hostname=$HOSTNAME \
				--network=host \
				--privileged $1
