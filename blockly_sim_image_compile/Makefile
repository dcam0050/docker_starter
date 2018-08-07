.PHONY: build first_run run clean docker configure build_image buildBashrc uploadImage upload

#scan parts directory
INPUTS := $(wildcard ${DOCKERPARTS}/*.part)
HOST=$(shell hostname)
VIDEO_GID := $(shell grep video /etc/group | cut -d':' -f3)

build: clean docker build_image buildBashrc build_image1

run:
	docker start $(containerName)
	docker attach $(containerName)

clean:
	@rm -f bashrc_iCub
	@rm -f Dockerfile
	-@docker rm -f $(containerName) >/dev/null || true
	touch bashrc_iCub

docker:
	${DOCKERPARTS}/compileDockerfile.py $(PWD)

configure:
	sudo apt-get install -y libopenni-dev squid-deb-proxy


first_run:
	@echo ${DISPLAY}
	docker run -dit --env="DISPLAY="${DISPLAY} --env="QT_X11_NO_MITSHM=1" 					\
					  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" 					\
					  --volume=/dev/snd:/dev/snd							\
					  --device=/dev/ttyACM0								\	
					  --device=/dev/ttyACM1								\
					  --volume="/home/$(USER)/.local/share/yarp:/home/icub/.local/share/yarp:rw" 	\
					  --volume="/home/$(USER)/docker_home:/home/icub/user_files:rw" 		\
					  --volume="/dev/bus/usb:/dev/bus/usb"						\
					  --name=${containerName} 							\
					  --hostname=$(HOST)								\
					  --network=host								\
					  --privileged 									\
					  $(tagName)
	docker stop $(containerName)
	#set up display
	@xhost +local:`docker inspect --format='{{ .Config.Hostname }}' $(containerName)`
	docker start $(containerName)
	docker attach $(containerName)

build_image build_image1:
	@echo $(VIDEO_GID)
	docker build -t $(tagName) . --build-arg VIDEO_GID=$(VIDEO_GID)

	-@docker stop $(containerName) >/dev/null || true
	-@docker rm $(containerName) >/dev/null || true


	docker run -dit --env="DISPLAY="${DISPLAY} --env="QT_X11_NO_MITSHM=1" 					\
					  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" 									\
					  --volume=/dev/snd:/dev/snd													\
					  --device=/dev/ttyACM0															\
					  --device=/dev/ttyACM1 														\
					  --volume="/home/$(USER)/.local/share/yarp:/home/icub/.local/share/yarp:rw" 	\
					  --volume="/home/$(USER)/docker_home:/home/icub/user_files:rw" 				\
					  --volume="/dev/bus/usb:/dev/bus/usb"											\
					  --name=${containerName} 														\
					  --hostname=$(HOST)															\
					  --network=host																\
					  --privileged 																	\
					  $(tagName)

	docker stop $(containerName)
	#set up display
	@xhost +local:`docker inspect --format='{{ .Config.Hostname }}' $(containerName)`

buildBashrc:
	#set up environment bashrc_iCub
	@echo "export $(shell docker inspect --format='{{.Config.Env}}' $(containerName) |cut -c 31- | rev | cut -c 2- | rev)" > bashrc_iCub
	@echo "source ~/.sourceScripts" >> bashrc_iCub
	@echo "environment written to bashrc_iCub"

all: build run

upload: build uploadImage

uploadImage: 
	docker push $(tagName)
