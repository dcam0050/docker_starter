#!/usr/bin/env bash
echo "$7"
if [ "$7" == 'dev' ]
then
      docker run -dit \
				--env="DISPLAY="$DISPLAY  \
				--env="QT_X11_NO_MITSHM=1"  \
				--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"  \
				-p $3:80 \
				-p $4:1036 \
				-p $5:8080 \
				-p $6:$6 \
				--volume="/home/"$USER"/docker_home:/home/icub/user_files:rw" \
				-e BLOCKLY_PORT=$6 \
				--name=$2  \
				--hostname=$HOSTNAME \
                                $1
else
      docker run -dit \
                --env="QT_X11_NO_MITSHM=1"  \
                --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"  \
                -p $3:80 \
                -p $4:1036 \
                -p $5:8080 \
                -p $6:$6 \
                --volume="/home/"$USER"/docker_home:/home/icub/user_files:rw" \
                -e BLOCKLY_PORT=$6 \
                --name=$2  \
                --hostname=$HOSTNAME \
                --entrypoint="/home/icub/mirosim.sh" \
                --privileged $1
fi
#docker attach $2
