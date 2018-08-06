FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

ARG cores=6
# ARG VIDEO_GID
ENV SRC_FOLDER=/usr/local/src/robot

# If host is running squid-deb-proxy on port 8000, populate /etc/apt/apt.conf.d/30proxy
# By default, squid-deb-proxy 403s unknown sources, so apt shouldn't proxy ppa.launchpad.net
RUN route -n | awk '/^0.0.0.0/ {print $2}' > /tmp/host_ip.txt
RUN echo "HEAD /" | nc `cat /tmp/host_ip.txt` 8000 | grep squid-deb-proxy \
  && (echo "Acquire::http::Proxy \"http://$(cat /tmp/host_ip.txt):8000\";" > /etc/apt/apt.conf.d/30proxy) \
  && (echo "Acquire::http::Proxy::ppa.launchpad.net DIRECT;" >> /etc/apt/apt.conf.d/30proxy) \
  || echo "No squid-deb-proxy detected on docker host"

#create icub user
RUN apt-get update && \
    apt-get -y install sudo git wget && \
    useradd -m icub && echo "icub:icub" | chpasswd && adduser icub sudo && usermod -aG video icub && usermod -s /bin/bash icub

COPY keyboard /etc/default/keyboard
COPY bashrc /home/icub/.bashrc

RUN wget https://download.sublimetext.com/sublime-text_build-3126_amd64.deb && \
	dpkg -i sublime-text_build-3126_amd64.deb && rm sublime-text_build-3126_amd64.deb && \
	sh -c 'echo "deb http://www.icub.org/ubuntu xenial contrib/science" > /etc/apt/sources.list.d/icub.list' && \
	mkdir $SRC_FOLDER

RUN apt-get update && apt-get install -y --allow-unauthenticated	\
	build-essential 						\
	cmake-curses-gui 						\
	mesa-utils 								\
	pkg-config 								\
	checkinstall 							\
	bash-completion 						\
	apt-utils  								\
	vim										\
	software-properties-common 				\
	xterm 									\
	gedit									\
	net-tools								\
	iputils-ping 							\
	openssh-server							\
	expect 									\
	icub-common								\
	doxygen									\
	pciutils								\
	libasound2 								\
	libpango1.0-0 							\
	pulseaudio-utils 						\
	alsa-base 								\
	alsa-utils								\
	tmux                                    \
    terminator             					\
    && apt-get clean 						\
   	&& rm -rf /var/lib/apt/lists/*                   

WORKDIR $SRC_FOLDER

#Python
RUN cd $SRC_FOLDER && wget https://repo.continuum.io/archive/Anaconda2-4.2.0-Linux-x86_64.sh && \
	cd $SRC_FOLDER && bash Anaconda2-4.2.0-Linux-x86_64.sh -b -p ./anaconda2 	&& 	\
	rm $SRC_FOLDER/anaconda2/lib/libgomp.so* 									&& 	\
	rm $SRC_FOLDER/anaconda2/lib/libstdc++.so* 									&& 	\
	rm $SRC_FOLDER/anaconda2/lib/libgfortran.so* 								&& 	\
	rm $SRC_FOLDER/anaconda2/lib/libQt5*										&& 	\
	rm -r $SRC_FOLDER/anaconda2/lib/cmake/Qt5* 									&& 	\
	rm $SRC_FOLDER/Anaconda2-4.2.0-Linux-x86_64.sh

ENV PYTHONPATH=$SRC_FOLDER/anaconda2/bin 
ENV PATH=$PYTHONPATH:$PATH

#OpenCV 3
RUN apt-get update && apt-get install -y \
	libgtk2.0-dev 		\
	libavcodec-dev 		\
	libavformat-dev 	\
	libswscale-dev 		\
	libtbb2 			\
	libtbb-dev 			\
	libjpeg-dev 		\
	libpng-dev 			\
	libtiff-dev 		\
	libjasper-dev 		\
	libdc1394-22-dev 	\
	libopenblas-dev 	\
	liblapack-dev 		\
	liblapacke-dev 		\
	libboost-all-dev 	\
	libeigen3-dev 		\
	libatlas-dev		

ARG opencv3Hash=70bbf17b133496bd7d54d034b0f94bd869e0e810
RUN git clone https://github.com/opencv/opencv.git ./opencv3 && cd opencv3 && git checkout -b localBranch $opencv3Hash

ARG opencv3ContribHash=86342522b0eb2b16fa851c020cc4e0fef4e010b7
RUN git clone https://github.com/opencv/opencv_contrib.git && cd opencv_contrib && git checkout -b localBranch $opencv3ContribHash

RUN mkdir opencv3/build 	&& cd opencv3/build 	&& mkdir ./install 							&& \
	cmake .. 	-DCMAKE_BUILD_TYPE=Release 									\
				-DBUILD_PERF_TESTS=OFF 										\
				-DCMAKE_INSTALL_PREFIX=./install 							\
				-DBUILD_TESTS=OFF 											\
				-DBUILD_opencv_cnn_3dobj=OFF 								\
				-DCUDA_ARCH_BIN="6.0 6.1" 									\
				-DCUDA_FAST_MATH=ON 										\
				-DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules 	\
				-DWITH_CUBLAS=ON 											\
				-DWITH_QT=ON 												\
				-DWITH_TIFF=OFF 											\
				-DWITH_TBB=ON 												\
				-DBUILD_opencv_tracking=ON 									\
				-DBUILD_opencv_dnn=ON										\
				-DINSTALL_PYTHON_EXAMPLES=ON 								\
				-DINSTALL_TESTS=ON 											\
				-DBUILD_opencv_hdf=OFF 										\
				-DPYTHON2_NUMPY_INCLUDE_DIRS=$SRC_FOLDER/anaconda2/lib/python2.7/site-packages/numpy/core/include 	\
				-DPYTHON2_LIBRARY=$SRC_FOLDER/anaconda2/lib/libpython2.7.so 										\
				-DPYTHON2_PACKAGES_PATH=$SRC_FOLDER/anaconda2/lib/python2.7/site-packages 						&& 	\
	make -j$cores && make -j$cores install

ENV OPENCV_DIR=$SRC_FOLDER/opencv3 OPENCV_ROOT=$SRC_FOLDER/opencv3/build/install 
ENV OPENCV_LIB=$OPENCV_ROOT/lib OPENCV_BIN=$OPENCV_ROOT/bin \
	OPENCV_INCLUDE=$OPENCV_ROOT/include OPENCV_PYTHONLIB=$OPENCV_DIR/build/lib
ENV PATH=$OPENCV_BIN:$OPENCV_INCLUDE:$PATH \
	LD_LIBRARY_PATH=$OPENCV_LIB:$OPENCV_PYTHONLIB:$LD_LIBRARY_PATH


# YARP
RUN apt-get update && apt-get install -y \
	swig3.0				\
	liblua5.2-dev		\
	python-tk 			\
	portaudio19-dev		\
	libavdevice-dev 		\
    && apt-get clean    \
   	&& rm -rf /var/lib/apt/lists/* 
# Works with icub
ARG yarpHash=cca890b8ae3ec14fc7cadab0821bcd1a09181da1
#Does not work with icub
#ARG yarpHash=e51a52d94076ccea63a695425d9ce02a1491e9dc
RUN	git clone https://github.com/robotology/yarp.git && cd yarp && git checkout -b localBranch $yarpHash && rm bindings/yarp.i

ADD yarp_cca890b.i yarp/bindings/yarp.i
#ADD yarp_e51a52d.i yarp/bindings/yarp.i

RUN mkdir yarp/build && cd yarp/build 									&& 	\
	cmake .. 	-DCMAKE_BUILD_TYPE=Release 									\
				-DCREATE_DEVICE_LIBRARY_MODULES=ON 							\
				-DCMAKE_INSTALL_PREFIX=./install 							\
				-DCREATE_GUIS=ON 											\
				-DCREATE_LIB_MATH=ON 										\
				-DCREATE_OPTIONAL_CARRIERS=ON								\
				-DYARP_COMPILE_BINDINGS=ON									\
				-DCREATE_CSHARP=ON 											\
				-DCREATE_LUA=ON 											\
				-DCREATE_PYTHON=ON 											\
				-DENABLE_yarpcar_bayer=ON 									\
				-DENABLE_yarpcar_mjpeg=ON 									\
				-DENABLE_yarpmod_microphone=ON 								\
				-DENABLE_yarpmod_ffmpeg_grabber=ON 							\
				-DENABLE_yarpmod_portaudio=ON 								\
				-DENABLE_yarpmod_opencv_grabber=ON 							\
				-DENABLE_yarpmod_serial=ON 									\
				-DENABLE_yarpmod_serialport=ON 								\
				-DENABLE_yarpmod_SerialServoBoard=ON 						\
				-DYARP_USE_PYTHON_VERSION=2								 &&	\
	cmake .. 	-DCMAKE_BUILD_TYPE=Release 									\
				-DCREATE_DEVICE_LIBRARY_MODULES=ON 							\
				-DCMAKE_INSTALL_PREFIX=./install 							\
				-DCREATE_GUIS=ON 											\
				-DCREATE_LIB_MATH=ON 										\
				-DCREATE_OPTIONAL_CARRIERS=ON								\
				-DYARP_COMPILE_BINDINGS=ON									\
				-DCREATE_CSHARP=ON 											\
				-DCREATE_LUA=ON 											\
				-DCREATE_PYTHON=ON 											\
				-DENABLE_yarpmod_microphone=ON 								\
				-DENABLE_yarpmod_ffmpeg_grabber=ON 							\
				-DENABLE_yarpmod_portaudio=ON 								\
				-DENABLE_yarpcar_bayer=ON 									\
				-DENABLE_yarpcar_mjpeg=ON 									\
				-DENABLE_yarpmod_opencv_grabber=ON 							\
				-DENABLE_yarpmod_serial=ON 									\
				-DENABLE_yarpmod_serialport=ON 								\
				-DENABLE_yarpmod_SerialServoBoard=ON 						\
				-DYARP_USE_PYTHON_VERSION=2								&& 	\
	make -j$cores && make install 

ENV LUA_CPATH=$SRC_FOLDER/yarp/build/lib/lua/?.so  YARP_ROOT=$SRC_FOLDER/yarp
ENV YARP_DIR=$YARP_ROOT/build/install
ENV YARP_LIB=$YARP_DIR/lib \
	YARP_BIN=$YARP_DIR/bin \
	YARP_ROBOT_NAME=iCubSheffield01
ENV PATH=$YARP_BIN:$LUA_CPATH:$PATH \
	LD_LIBRARY_PATH=$YARP_LIB:$LD_LIBRARY_PATH
ENV YARP_PYTHON=$YARP_DIR/lib/python2.7/site-packages
ENV PYTHONPATH=$PYTHONPATH:$YARP_PYTHON
ENV YARP_DATA_DIRS=$YARP_DIR/share/yarp

USER icub
RUN yarp conf 10.0.0.100 10000

USER root
RUN echo "source $SRC_FOLDER/yarp/scripts/yarp_completion" >> /home/icub/.sourceScripts

# ROBOTS CONFIGURATION
ARG robotConfigHash=a8e47be03b88a0dd2bc7609ab5ce6bfdf29a3c5c
RUN git clone https://github.com/robotology/robots-configuration.git && \
	cd robots-configuration &&	git checkout -b localBranch $robotConfigHash

# ICUB MAIN
ARG icubMainHash=a5e94059e899c4fd6994d007dc7bdab9595a9111
# ARG icubMainHash=2fe40bcad13734ce6800839a0492c5bae99f3cb6
RUN git clone https://github.com/robotology/icub-main.git && cd icub-main  && git checkout -b localBranch $icubMainHash && \
	mkdir build && 	cd build 								&& 	\
	cmake .. -DCMAKE_BUILD_TYPE=Release							\
			 -DICUB_USE_GTK2=OFF 								\
			 -DCMAKE_INSTALL_PREFIX=./install 					\
			 -DENABLE_icubmod_gazecontrollerclient=ON 			\
			 -DENABLE_icubmod_cartesiancontrollerclient=ON 		\
			 -DENABLE_icubmod_cartesiancontrollerserver=ON 	&&	\
	make -j$cores && make -j$cores install

ENV ICUB_ROOT=$SRC_FOLDER/icub-main 
ENV ICUB_DIR=$ICUB_ROOT/build/install
ENV ICUB_LIB=$ICUB_DIR/lib 	\
	ICUB_BIN=$ICUB_DIR/bin 	\
	ICUB_ROBOTNAME=$YARP_ROBOT_NAME

ENV PATH=$ICUB_BIN:$PATH 	\
	LD_LIBRARY_PATH=$ICUB_LIB:$LD_LIBRARY_PATH

# ICUB CONTRIB
RUN git clone https://github.com/robotology/icub-contrib-common.git && \
	mkdir icub-contrib-common/build && cd icub-contrib-common/build							&& 	\
	cmake .. -DCMAKE_INSTALL_PREFIX=$SRC_FOLDER/icub-contrib-common/build/install 				\
			 -DCMAKE_BUILD_TYPE=Release														&&	\
	make && make install

ENV ICUBCONTRIB_ROOT=$SRC_FOLDER/icub-contrib-common 
ENV ICUBCONTRIB_DIR=$ICUBCONTRIB_ROOT/build/install
ENV ICUBCONTRIB_BIN=$ICUBCONTRIB_DIR/bin \
	CMAKE_PREFIX_PATH=$ICUBCONTRIB_DIR
ENV PATH=$ICUBCONTRIB_DIR:$ICUBCONTRIB_BIN:$PATH
ENV YARP_DATA_DIRS=$YARP_DATA_DIRS:$ICUB_DIR/share/iCub:$ICUBCONTRIB_DIR/share/ICUBcontrib:$ICUB_ROOT/app/simConfig/conf

#OpenCV 2
RUN apt-get update && apt-get install -y \
	libgtk2.0-dev 		\
	libavcodec-dev 		\
	libavformat-dev 	\
	libswscale-dev 		\
	libtbb2 			\
	libtbb-dev 			\
	libjpeg-dev 		\
	libpng-dev 			\
	libtiff-dev 		\
	libjasper-dev 		\
	libdc1394-22-dev 	\
	libopenblas-dev 	\
	liblapack-dev 		\
	liblapacke-dev 		\
	libboost-all-dev 	\
	libeigen3-dev 		\
	libatlas-dev		\
	libprotobuf-dev 	\
	protobuf-compiler	\
	libgoogle-glog-dev	\
	libgflags-dev		\
	libleveldb-dev		\
	libhdf5-serial-dev	\
	liblmdb-dev			\
	libsnappy-dev		\
	hdf5-tools 			\
	libatlas-base-dev 	\
	libatlas3-base		

ARG opencv2Hash=d68e3502278d6fc5a1de0ce8f7951d9961b20913
RUN git clone https://github.com/opencv/opencv.git ./opencv2 && cd opencv2 && git checkout -b localBranch $opencv2Hash && \
	mkdir build && cd build && mkdir ./install 							&& 	\
	cmake .. 	-DCMAKE_BUILD_TYPE=Release 									\
				-DBUILD_PERF_TESTS=OFF 										\
				-DCMAKE_INSTALL_PREFIX=./install 							\
				-DBUILD_TESTS=OFF 											\
				-DCUDA_ARCH_BIN="6.0 6.1" 									\
				-DCUDA_FAST_MATH=ON 										\
				-DWITH_CUBLAS=ON 											\
				-DWITH_QT=ON 												\
				-DWITH_TIFF=OFF 											\
				-DWITH_TBB=ON 											&& 	\
	make -j$cores && make -j$cores install

#Caffe
ARG caffeHash=68215ccc004ebd05a2209270688c26b6e4304d4a
RUN git clone https://github.com/BVLC/caffe.git && \
	cd caffe && git checkout -b localBranch $caffeHash && mkdir build 	&& cd build	&& 	\
	cmake .. 	-DCMAKE_BUILD_TYPE=Release									\
				-DCMAKE_INSTALL_PREFIX=./install 							\
				-DOpenCV_DIR=$SRC_FOLDER/opencv2/build/install/share/OpenCV \
				-DCUDA_USE_STATIC_CUDA_RUNTIME=OFF 						&& 	\
	make -j$cores && make -j$cores install 								&& 	\
	cd .. && scripts/download_model_binary.py models/bvlc_reference_caffenet && \
	./data/ilsvrc12/get_ilsvrc_aux.sh

ENV CAFFE_ROOT=$SRC_FOLDER/caffe/build 
ENV CAFFE_DIR=$CAFFE_ROOT/install
ENV CAFFE_LIB=$CAFFE_DIR/lib 	\
	CAFFE_BIN=$CAFFE_DIR/bin
ENV PATH=$CAFFE_BIN:$PATH 		\
	LD_LIBRARY_PATH=$CAFFE_LIB:$LD_LIBRARY_PATH

RUN apt-get update && apt-get install -y \
	libglew-dev 		\
	libdevil-dev		

#rFSM
ARG rFSMHash=26d0477053597690ab1d941f26041492ddfced9b
RUN git clone https://github.com/kmarkus/rFSM.git && cd rFSM && git checkout -b localBranch $rFSMHash

# Segmentation
ARG segmentationHash=0a6666ce44304a9cf52c49e4871a1fb835896200
RUN git clone https://github.com/robotology/segmentation.git && \
	cd segmentation && git checkout -b localBranch $segmentationHash && mkdir build && \
	cd build && cmake .. -DCMAKE_INSTALL_PREFIX=$CMAKE_PREFIX_PATH && make -j$cores && make -j$cores install

#SiftGPU
ARG siftGPUHash=b46bd5b8cc5cfdc1dc163444b72c705569800b6d
RUN git clone https://github.com/pitzer/SiftGPU.git && \
	cd SiftGPU && git checkout -b localBranch $siftGPUHash && make clean && make

ENV SIFTGPU_ROOT=$SRC_FOLDER/SiftGPU
ENV SIFTGPU_BIN=$SIFTGPU_ROOT/bin \
	SIFTGPU_LIB=$SIFTGPU_ROOT/lib \
	SIFTGPU_INCLUDE_DIRS=$SIFTGPU_ROOT/src/SiftGPU/
ENV LUA_PATH=$SRC_FOLDER/rFSM/?.lua:$ICUBCONTRIB_DIR/share/ICUBcontrib/contexts/iol/lua/?.lua?
ENV PATH=$SIFTGPU_BIN:$SIFTGPU_INCLUDE_DIRS:$PATH \
	LD_LIBRARY_PATH=$SIFTGPU_LIB:$LIBSVMLIN_DIR:$LUA_PATH:$LD_LIBRARY_PATH

#LIBLINEAR
RUN git clone https://github.com/robotology/himrep.git && \
	cd himrep && wget https://www.csie.ntu.edu.tw/~cjlin/liblinear/oldfiles/liblinear-1.91.tar.gz 
RUN cd himrep && tar xvzf liblinear-1.91.tar.gz && rm liblinear-1.91.tar.gz
RUN cd himrep/liblinear-1.91 && mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=RELEASE && make && cp libLiblinear.a ../
ENV LIBSVMLIN_DIR=$SRC_FOLDER/himrep/liblinear-1.91

# Himrep
ARG himrepHash=c1e4b0509da512ee4e9234d77148bf18fe228ad8
RUN cd himrep && git checkout -b localBranch $himrepHash && mkdir build && cd build && 	\
	cmake .. 	-DCMAKE_BUILD_TYPE=RELEASE 									\
				-DOpenCV_DIR=$SRC_FOLDER/opencv2/build/install/share/OpenCV \
				-DSIFTGPU_DIR=$SIFTGPU_ROOT 								\
				-DSIFTGPU_LIBRARIES=$SIFTGPU_BIN/libsiftgpu.so 				\
				-DSIFTGPU_INCLUDE_DIRS=$SIFTGPU_INCLUDE_DIRS				\
				-DCMAKE_INSTALL_PREFIX=$CMAKE_PREFIX_PATH					\
				-DCUDA_USE_STATIC_CUDA_RUNTIME=OFF 						&& 	\
	make -j$cores && make -j$cores install

#Stereo Vision
ARG stereoHash=a5b8e2599916ac1a83e7f89ac94d15d087ef3a59
RUN git clone https://github.com/robotology/stereo-vision.git && \
	cd stereo-vision && git checkout -b localBranch $stereoHash && mkdir build && cd build 	&& 	\
	cmake .. 	-DCMAKE_BUILD_TYPE=RELEASE 														\
				-DUSE_SIFT_GPU=OFF 																\
				-DOpenCV_DIR=$SRC_FOLDER/opencv3/build/install/share/OpenCV 					\
				-DCUDA_USE_STATIC_CUDA_RUNTIME=OFF												\
				-DCMAKE_INSTALL_PREFIX=$CMAKE_PREFIX_PATH 									&& 	\
	make -j$cores && make -j$cores install

#Boost
ARG boostHash=fbe3e245a0b1aecfda960c1d7a254a1deeb58022
RUN git clone https://github.com/robotology/boost-mil.git && \
	cd boost-mil && git checkout -b localBranch $boostHash && mkdir build && cd build 	&& 	\
	cmake .. 	-DCMAKE_BUILD_TYPE=RELEASE 													\
				-DCMAKE_INSTALL_PREFIX=$CMAKE_PREFIX_PATH 								&& 	\
	make -j$cores && make -j$cores install

#IOL
ARG iolHash=60b608ecced5c32933449d4b67c367f16221a815
RUN git clone https://github.com/robotology/iol.git && \
	cd iol && git checkout -b localBranch $iolHash && mkdir build && cd build 	&& 	\
	cmake .. 	-DCMAKE_BUILD_TYPE=RELEASE 											\
				-DCMAKE_INSTALL_PREFIX=$CMAKE_PREFIX_PATH 							\
				-DOpenCV_DIR=$SRC_FOLDER/opencv3/build/install/share/OpenCV 	&& 	\
	make -j$cores && make -j$cores install

RUN apt-get update && apt-get install -y	\
	usbutils 								\
	libopenni-dev

#NITE
ARG NITED=NITE-Bin-Dev-Linux-x64-v1.5.2.21
ARG NITEZ=nite-bin-linux-x64-v1.5.2.21.tar.bz2
RUN wget http://ilab.usc.edu/packages/forall/ubuntu-12.04lts/old/nite-bin-linux-x64-v1.5.2.21.tar.bz2 && \
	tar xvfj $NITEZ && cd $NITED && ./install.sh && rm $SRC_FOLDER/$NITEZ

#SensorKinect
ARG sensorKinectHash=15f1975d5e50d84ca06ff784f83f8b7836749a7b
RUN git clone https://github.com/avin2/SensorKinect.git && \
	cd SensorKinect && git checkout -b localBranch $sensorKinectHash && \
	cd Platform/Linux/CreateRedist && ./RedistMaker && cd ../Redist/Sensor-Bin-Linux-x64-v5.1.2.1/ && ./install.sh

#kinectWrapper
ARG kinectHash=20113eae69e3e16e69048d7debd2d02dee591425
RUN git clone https://github.com/robotology/kinect-wrapper.git && \
	cd kinect-wrapper && git checkout -b localBranch $kinectHash && mkdir build && cd build && 	\
	cmake .. 	-DCMAKE_BUILD_TYPE=RELEASE 														\
				-DCMAKE_INSTALL_PREFIX=$CMAKE_PREFIX_PATH 										\
				-DOpenCV_DIR=$SRC_FOLDER/opencv3/build/install/share/OpenCV 				&& 	\
	make -j$cores && make -j$cores install

# Speech
ARG speechHash=0ad96ea84f490df9596544f4ca579e259783e650
RUN git clone https://github.com/robotology/speech.git && \
	cd speech && git checkout -b localBranch $speechHash && mkdir build && cd build && 	\
	cmake .. 	-DCMAKE_BUILD_TYPE=RELEASE 												\
				-DCMAKE_INSTALL_PREFIX=$CMAKE_PREFIX_PATH 							&& 	\
	make -j$cores && make -j$cores install

ENV YARP_DATA_DIRS=$YARP_DATA_DIRS:$ICUBCONTRIB_DIR/share/speech \
	YARP_PYTHONLIB=$YARP_LIB/python2.7/site-packages

RUN cd speech/svox-speech && mkdir build &&	cd build && 		\
	cmake .. 	-DCMAKE_BUILD_TYPE=RELEASE 						\
				-DCMAKE_INSTALL_PREFIX=$CMAKE_PREFIX_PATH 		\
				-DENABLE_speech=ON 							&& 	\
	make -j$cores && make -j$cores install

ARG karmaWYSIWYDHash=e14488ffc7fcca750db54122174fe8c06fa397a0
RUN git clone https://github.com/towardthesea/karmaWYSIWYD.git && \
	cd karmaWYSIWYD && git checkout -b localBranch $karmaWYSIWYDHash && mkdir build && cd build && 	\
	cmake .. 	-DCMAKE_BUILD_TYPE=RELEASE 															\
				-DCMAKE_INSTALL_PREFIX=$CMAKE_PREFIX_PATH 											\
				-DOpenCV_DIR=$SRC_FOLDER/opencv3/build/install/share/OpenCV 					&&  \
	make -j$cores && make -j$cores install

#Install dlib
RUN apt-get update && apt-get install libsqlite3-dev

RUN wget http://dlib.net/files/dlib-19.2.tar.bz2 && tar xvfj dlib-19.2.tar.bz2 && \
	cd dlib-19.2/examples && mkdir build && cd build && \
	cmake .. -DOpenCV_DIR=$SRC_FOLDER/opencv3/build/install/share/OpenCV && make -j$cores && rm $SRC_FOLDER/dlib-19.2.tar.bz2

#Human Sensing SAM
RUN git clone https://github.com/dcam0050/human-sensing-SAM.git 				&& 	\
 	cd human-sensing-SAM && mkdir build && cd build 							&& 	\
	cmake .. -DCMAKE_BUILD_TYPE=Release												\
			-DOpenCV_DIR=/usr/local/src/robot/opencv/build/install/share/OpenCV && 	\
	make -j6 && make install

COPY CLMYarp.ini $SRC_FOLDER/human-sensing-SAM/app/CLM_Yarp/conf
ENV CLM_MODEL_DIR=$SRC_FOLDER/human-sensing-SAM/app/CLM_Yarp/conf
ENV PATH=$CLM_MODEL_DIR:$PATH
RUN echo "alias CLMYarp='CLMYarp --from $CLM_MODEL_DIR'" >> /home/icub/.sourceScripts

#ICUB CLIENT
# ARG icubClientHash=f720428148690306abc0d1b1dc1503467cc5ad02
RUN git clone https://github.com/robotology/icub-client.git
RUN cd icub-client && git checkout -b localBranch $icubClientHash && mkdir build && cd build && \
 	cmake ..	-DCMAKE_INSTALL_PREFIX=./install 													\
 				-DCMAKE_BUILD_TYPE=Release															\
 				-DOpenCV_DIR=$SRC_FOLDER/opencv3/build/install/share/OpenCV 						\
 				-DICUBCLIENT_COMPILE_TESTS=ON 													&& 	\
	make -j$cores && make -j$cores install

ENV ICUBCLIENT_ROOT=$SRC_FOLDER/icub-client/build 
ENV ICUBCLIENT_DIR=$ICUBCLIENT_ROOT/install 									\
	ICUBCLIENT_BIN=$ICUBCLIENT_ROOT/install/bin 								\
	ICUBCLIENT_LIB=$ICUBCLIENT_ROOT/install/lib 								
ENV LD_LIBRARY_PATH=$ICUBCLIENT_LIB:$LD_LIBRARY_PATH 							\
	PATH=$ICUBCLIENT_BIN:$PATH

RUN cd icub-client/bindings && mkdir build && cd build && \
	cmake .. 	-DCMAKE_INSTALL_PREFIX=./install 			\
 				-DCMAKE_BUILD_TYPE=Release					\
				-DCREATE_PYTHON=ON 						\
 				-DICUBCLIENT_USE_PYTHON_VERSION=2		&& 	\
 	make -j$cores && make -j$cores install												

ENV SAM_ROOT=$SRC_FOLDER/icub-client/src/modules \
	ICUBCLIENT_BINDINGS=$SRC_FOLDER/icub-client/bindings/build/install/lib/python2.7/site-packages
ENV PYTHONPATH=$PYTHONPATH:$SAM_ROOT:$ICUBCLIENT_BINDINGS

RUN pip install --upgrade pip && pip install paramz==0.7.4 && conda install ipyparallel -y && conda install 'pyqt<5' -y

#Git clone GPY and WYSIWYD
ARG GPYHash=845168af3bb5e61dafed4dd860644546e9c4666a
RUN git clone https://github.com/SheffieldML/GPy.git && \
	cd GPy && git checkout -b localBranch $GPYHash && python setup.py build_ext --inplace 
ENV GPY_ROOT=$SRC_FOLDER/GPy \
	GPY_DIR=$SRC_FOLDER/GPy/build

ENV PYTHONPATH=$PYTHONPATH:$YARP_PYTHONLIB:$OPENCV_PYTHONLIB:$GPY_DIR:$GPY_ROOT:

ARG GPYOPTHash=dd1438023e9d133af0c861a9a3c3fd24a5fa07bd
RUN git clone https://github.com/SheffieldML/GPyOpt.git && \
	cd GPyOpt && git checkout -b localBranch $GPYOPTHash && python setup.py develop
ENV GPY_ROOT=$SRC_FOLDER/GPyOpt \
	GPY_DIR=$SRC_FOLDER/GPyOpt/build

ENV PYTHONPATH=$PYTHONPATH:$GPYOPT_DIR:$GPYOPT_ROOT

# ROS KINETIC
# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116 && \
    echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    dirmngr \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
ENV ROS_DISTRO kinetic
RUN apt-get update && apt-get install -y \
    ros-kinetic-desktop python-wstool \
    ros-kinetic-catkin ros-kinetic-usb-cam ros-kinetic-image-view \
    && rm -rf /var/lib/apt/lists/*

RUN pip install defusedxml rospkg catkin_pkg empy

EXPOSE 11345

RUN echo "source /opt/ros/kinetic/setup.sh" >> /home/icub/.sourceScripts                &&  \
    echo 'source $SRC_FOLDER/catkin_ws/devel/setup.bash' >> /home/icub/.sourceScripts   &&  \
    chmod +x /opt/ros/kinetic/setup.sh                                                  &&  \
    mkdir -p $SRC_FOLDER/catkin_ws/src                                                  &&  \
    cd $SRC_FOLDER/catkin_ws                                                            &&  \
    /bin/bash -c 'source /opt/ros/kinetic/setup.sh; catkin_make'

COPY ./ros_entrypoint.sh /home/icub/
RUN echo 'ROS_IP=127.0.0.1' >> /home/icub/.sourceScripts && \
    echo 'ROS_MASTER_URI=http://$ROS_IP:11311' >> /home/icub/.sourceScripts && \
    chmod +x /home/icub/ros_entrypoint.sh

# echo $ROS_MASTER_URI

# GAZEBO 7
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2486D2DD83DB69272AFE98867170598AF249743

RUN . /etc/os-release \
    && . /etc/lsb-release \
    && echo "deb http://packages.osrfoundation.org/gazebo/$ID-stable $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/gazebo-latest.list

RUN apt-get update && apt-get install -q -y \
    gazebo7 \
    libgazebo7-dev \
    && rm -rf /var/lib/apt/lists/*
RUN echo 'source /usr/share/gazebo/setup.sh' >> /home/icub/.sourceScripts 

# GazeboWeb
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN apt-get update && \
  apt-get install -y libjansson-dev nodejs libboost-dev imagemagick libtinyxml-dev mercurial cmake build-essential

ENV GZWEBPATH=$SRC_FOLDER/gzweb
RUN hg clone https://bitbucket.org/osrf/gzweb && \
	cd gzweb && hg up gzweb_1.4.0 && \
	/bin/bash -c 'source /usr/share/gazebo/setup.sh && \
          export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH && \
          npm run deploy --- -m'

RUN echo 'source /usr/share/gazebo/setup.sh' >> /home/icub/.sourceScripts

# Blockly
RUN apt-get update && \
	apt-get install -y ros-kinetic-mavros ros-kinetic-mavros-extras python3-pip && \
	pip install --upgrade pip && \
	pip3 install autobahn rospkg catkin_pkg empy numpy && \
	mkdir -p ./blockly_ws/src

RUN cd $SRC_FOLDER/blockly_ws/src && \
	git clone --recurse-submodules https://github.com/MIRO-Robot/robot_blockly.git && \
	cd $SRC_FOLDER/blockly_ws && \
	/bin/bash -c 'source /opt/ros/kinetic/setup.sh; catkin_make_isolated -j2 --pkg robot_blockly --install' && \
	echo 'source $SRC_FOLDER/blockly_ws/install_isolated/setup.bash' >> /home/icub/.sourceScripts 

# Nginx to serve website
RUN \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# EXPOSE 80 443 8080 1036 9000

# static html content
COPY miro_sim_html /var/www/html

# Miro MDK
COPY mdk $SRC_FOLDER/mdk
ENV MIRO_PATH_MDK=$SRC_FOLDER/mdk
RUN echo 'export GAZEBO_MODEL_PATH=$MIRO_PATH_MDK/sim/gazebo/models:$GAZEBO_MODEL_PATH' >> /home/icub/.sourceScripts && \
    echo 'export GAZEBO_RESOURCE_PATH=$MIRO_PATH_MDK/sim/gazebo:$GAZEBO_RESOURCE_PATH' >> /home/icub/.sourceScripts && \
    echo 'export GAZEBO_PLUGIN_PATH=$MIRO_PATH_MDK/bin/deb64:$GAZEBO_PLUGIN_PATH' >> /home/icub/.sourceScripts && \
    echo 'export ROS_PACKAGE_PATH=$MIRO_PATH_MDK/share:$ROS_PACKAGE_PATH' >> /home/icub/.sourceScripts && \
    echo 'export PYTHONPATH=$MIRO_PATH_MDK/share:$PYTHONPATH' >> /home/icub/.sourceScripts && \
    apt-get update && apt-get install -y ros-kinetic-image-transport-plugins

RUN cd $GZWEBPATH && /bin/bash -c 'source /usr/share/gazebo/setup.sh && \
          export GAZEBO_MODEL_PATH=$MIRO_PATH_MDK/sim/gazebo/models:$GAZEBO_MODEL_PATH && \
          npm run deploy --- -m local'

#Gazebo Yarp Plugins
# ARG gazeboPluginsHash=af8b684546c256f3a1f781b90d38d1054f6bb6ca
ARG gazeboPluginsHash=cf437cfb36f28d02263769f6a22486ecf2ac0082
#ARG gazeboPluginsHash=e45a7c561a4246344e4b6cd2f64fd149791911c8
RUN git clone https://github.com/robotology/gazebo-yarp-plugins.git 			&& 	\
	cd gazebo-yarp-plugins  && git checkout -b localBranch $gazeboPluginsHash 	&& 	\
	mkdir build && cd build 													&& 	\
	cmake ../ -DCMAKE_INSTALL_PREFIX=./install && make -j$cores install

#Gazebo iCub
ARG gazeboIcubHash=ab22fdc34c0a9faa6f72428c2abdb6afc3145872
RUN GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:$SRC_FOLDER/gazebo-yarp-plugins/build/install/lib && \
	git clone https://github.com/robotology/icub-gazebo.git && \
	cd icub-gazebo && git checkout -b localBranch $gazeboIcubHash

RUN echo 'export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:$SRC_FOLDER/gazebo-yarp-plugins/build/install/lib' >> /home/icub/.sourceScripts && \
    echo 'export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$SRC_FOLDER/icub-gazebo' >> /home/icub/.sourceScripts

RUN cd $GZWEBPATH && /bin/bash -c 'source /usr/share/gazebo/setup.sh && \
          export GAZEBO_MODEL_PATH=$SRC_FOLDER/icub-gazebo:$GAZEBO_MODEL_PATH && \
          npm run deploy --- -m local'

RUN apt-get update && apt-get install -y \
	ros-kinetic-qt-build 			\
	ros-kinetic-gazebo-ros-control 	\
	ros-kinetic-gazebo-ros-pkgs 	\
	ros-kinetic-ros-control 		\
	ros-kinetic-control-toolbox 	\
	ros-kinetic-realtime-tools 		\
	ros-kinetic-ros-controllers 	\
	ros-kinetic-xacro 				\
	ros-kinetic-tf-conversions 		\
	ros-kinetic-kdl-parser

RUN pip install netifaces	


RUN cd $SRC_FOLDER/catkin_ws/src 	&& \
	wstool init .				 	&& \
	wstool merge https://raw.githubusercontent.com/RethinkRobotics/baxter_simulator/kinetic-devel/baxter_simulator.rosinstall && \
	wstool update																	

RUN cd $SRC_FOLDER/catkin_ws && /bin/bash -c 'source /opt/ros/kinetic/setup.sh; catkin_make'
RUN cp $SRC_FOLDER/catkin_ws/src/baxter/baxter.sh $SRC_FOLDER/catkin_ws

RUN apt-get update && apt-get install -y      	\
    ros-kinetic-gazebo-plugins                  \
    ros-kinetic-gazebo-ros-pkgs                 \
    ros-kinetic-gazebo-ros                      \
    ros-kinetic-gazebo-ros-control              \       
    ros-kinetic-moveit

ARG version=2.5.5.5-linux64
ARG naoqic=naoqi-sdk-$version
ARG naoqipy=pynaoqi-python2.7-$version

COPY $naoqic.tar.gz ./$naoqic.tar.gz
COPY $naoqipy.tar.gz ./$naoqipy.tar.gz

RUN tar xzf $naoqic.tar.gz && tar xzf $naoqipy.tar.gz   && \
    rm $naoqic.tar.gz && rm $naoqipy.tar.gz 			&& \
    mv $naoqic naoqi-sdk && mv $naoqipy pynaoqi 		&& \
    pip install netifaces

ENV PYTHONPATH=$PYTHONPATH:$SRC_FOLDER/pynaoqi/lib/python2.7/site-packages
ENV CATKIN_ROOT $SRC_FOLDER/catkin_ws
ENV CATKIN_SOURCE $CATKIN_ROOT/devel/setup.bash

WORKDIR $SRC_FOLDER/catkin_ws/src

ARG roboticsgroup_gazebo_pluginsHash=2f2f7f19669f9470692925bb3cc79c99e68cc011
ARG pal_msgsHash=8a3ee9811c9dc8133d163225b39199217636abfe
ARG pal_gazebo_pluginsHash=c13d52145d6331a74d16179d7b5abe8d7f381385

# RUN git clone https://github.com/roboticsgroup/roboticsgroup_gazebo_plugins.git && cd roboticsgroup_gazebo_plugins && git checkout -b localBranch $roboticsgroup_gazebo_pluginsHash
# RUN git clone https://github.com/pal-robotics/pal_msgs.git && cd pal_msgs && git checkout -b localBranch $pal_msgsHash

RUN git clone https://github.com/roboticsgroup/roboticsgroup_gazebo_plugins.git && cd roboticsgroup_gazebo_plugins
RUN git clone https://github.com/pal-robotics/pal_msgs.git && cd pal_msgs && git checkout -b localBranch $pal_msgsHash
#RUN git clone https://github.com/pal-robotics/pal_gazebo_plugins.git && cd pal_gazebo_plugins && git checkout -b localBranch $pal_gazebo_pluginsHash


RUN apt-get update && apt-get install -y        \
    ros-kinetic-pepper-meshes                   \
    ros-kinetic-moveit-visual-tools             \
    ros-kinetic-pepper-moveit-config            \
    ros-kinetic-humanoid-nav-msgs               \
    ros-kinetic-naoqi-dcm-driver                \
    ros-kinetic-naoqi-libqi                     \
    ros-kinetic-naoqi-libqicore                 \
    ros-kinetic-naoqi-pose                      \
    ros-kinetic-find-object-2d                  \
    ros-kinetic-humanoid-msgs                   \
    ros-kinetic-move-base-msgs                  \
    ros-kinetic-octomap-msgs

RUN git clone https://github.com/dcam0050/pepper_virtual.git
RUN git clone https://github.com/dcam0050/pepper_robot.git
RUN git clone https://github.com/ros-naoqi/pepper_dcm_robot

RUN cd $SRC_FOLDER/catkin_ws && \
    /bin/bash -c 'source /opt/ros/kinetic/setup.sh; source /usr/local/src/robot/catkin_ws/devel/setup.bash; catkin_make'

WORKDIR $SRC_FOLDER


# if (CMAKE_VERSION VERSION_LESS "3.1")
#     if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
#       set (CMAKE_CXX_FLAGS "-std=gnu++11 ${CMAKE_CXX_FLAGS}")
#     endif ()
#   else ()
#     set (CMAKE_CXX_STANDARD 11)
#   endif ()


RUN pip install --upgrade pip               &&  \
    apt-get update                          &&  \
    apt-get install -y portaudio19-dev sox  &&  \
    apt-get install -y pavucontrol parallel &&  \
    apt-get install -y ros-kinetic-srdfdom ros-kinetic-urdf && \
    apt-get clean                           &&  \
    rm -rf /var/lib/apt/lists/*                       

RUN pip install --upgrade                       \
      pandas                                    \
      progressbar2                              \
      numpy                                     \
      scipy==0.19.1                             \
      paramiko>=2.1                             \
      sox                                       \
      pysftp                                    \                             
      python_speech_features                    \
      pyxdg                                     \
      bs4                                       \
      pyaudio                                   \
      simplejson                                \
      python-utils                              \
      ikpy                                      \
      && conda install setuptools    

RUN apt-get update                          &&  \
    apt-get install -y libgirepository1.0-dev &&  \
    conda update pycairo &&  \
    pip install pygobject && \
    conda install fontconfig=2.11 && \
    rm /usr/local/src/robot/anaconda2/bin/gst-* && \
    apt-get install -y gstreamer1.0         &&  \
    apt-get remove -y gstreamer1.0-vaapi gstreamer1.0-clutter

ENV GST_PLUGIN_PATH=/usr/lib/x86_64-linux-gnu/gstreamer-1.0/:/usr/local/lib/gstreamer-1.0

WORKDIR /home/icub/

COPY Xylo.wav  .
COPY startup.sh .
COPY init.sh .
COPY detect_attY.sh .
COPY mirosim.sh .
COPY myprompt /usr/bin/
COPY setpermissions.sh .
RUN chmod +x setpermissions.sh && mkdir .local && chown -R icub /home/icub/.local && chown icub /home/icub/.* && chown icub /home/icub/
RUN mkdir user_files 

RUN apt-get update && apt-get install -y parallel

RUN mkdir -p .config/terminator
COPY config .config/terminator/

USER icub
RUN ssh-keygen -t rsa -f /home/icub/.ssh/id_rsa -q -N "" && touch .ssh/authorized_keys && \
	cat .ssh/id_rsa.pub >> .ssh/authorized_keys

USER root

COPY bashrc_iCub /home/icub/.bashrc_iCub
COPY asoundrc /home/icub/.asoundrc

USER icub
ENTRYPOINT bash

