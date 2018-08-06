# docker_starter
Scripts to setup and run the docker images published by dcamilleri13

# Setup Docker
Start with a fresh Ubuntu 16.04 or higher and make sure you have admin privileges

1. Install docker-ce
```
sudo apt-get update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
 
 sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
 
 sudo apt-get update
 
 sudo apt-get install docker-ce
```
Or see [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository) for latest instructions

2. Setup docker privileges
(Following instructions [here](https://askubuntu.com/questions/477551/how-can-i-use-docker-without-sudo))
```
sudo groupadd docker
"docker group already exists"

sudo gpasswd -a $USER docker
```

3. REBOOT (Skip at your own peril)

4. Check Docker works
``docker run hello-world``
If this returns something along the lines of permission denied, you did not do step 2 well or (unwisely) chose to not reboot

5. Make a folder called `docker_home` in your home directory. This will store all your source files and provides a bridge between the filesystem of your ubuntu installation and the filesystem of the docker container once initialised

6. Git clone this repository in `docker_home`
```
cd /home/$USER/docker_home

git clone https://github.com/dcam0050/docker_starter.git

``` 
7. Setup Useful Aliases

As the title says, these aliases are useful and help out a lot. To do this, copy all the text inside of the aptly named useful_aliases text file in the docker_starter directory and append it to the end of your .bashrc.
This provides three commands:
- **docker_stop_all** : stop all containers
- **docker_rm_all** : remove(delete) all containers but keeps the images intact
- **launch** : This is particularly useful as it sets up the parameters required for X11 forwarding to the docker container. Read: Allows GUIs and other visual stuff. This is important if you want to have a multi-terminal setup when editing your container

8. Spinning up a container in general

```
cd /home/$USER/docker_home/docker_starter

./start_image.sh <image_name> <my_container_name>
``` 
Look at the following sections for specific setups such as SAM and BlocklySim

# Setup SAM
1. Download the iCub-Hri docker image
`docker pull dcamilleri13/sam:dev`

2. Launch container using `start_image_icub.sh`
```
cd /home/$USER/docker_home/docker_starter

./start_image_icub.sh dcamilleri13/sam:dev <my_container_name>
```

3. Download SAM Code
```
cd /home/$USER/docker_home

git clone https://github.com/dcam0050/SAM
```

4. Download SAM Data from [here](https://drive.google.com/open?id=0B6fkkRLTYjNLbjFFSEZtUmtHNk0) into `cd /home/$USER/docker_home`

5. Start SAM container after setting up useful aliases
```
launch <my_container_name>
```

6. You should see the user has now changed to `icub` and you can find all the downloaded files at `/home/icub/user_files`

7. Start a multi-terminal window by running `terminator`

7. Copy required context files so they can be found by Yarp
```
cp -r /home/icub/user_files/SAM_Data_Models/SupervisorContext /home/icub/.local/share/yarp/contexts
```

8. Open 3 tabs in the terminal. 
- tab 1: `yarpserver--write`
- tab 2: `samSupervisor.py`
- tab 3: `yarp rpc /sam/rpc`

Then in tab 3, send `help` to get a list of possible actions

# Setup BlocklySim
1. Download BlocklySim Server Image
Make sure you have a good internet connection or this will frustrate you to no end.
If working directly on the server:
``docker pull dcamilleri13/all_connected:dev_mode``
If working via a remote tool:
``docker pull dcamilleri13/all_connected:dev_mode &``
(You do NOT want a 20GB download to fail 19GB in because your ssh connection got dropped)
Leave this working in the background and continue the steps

2. Git clone this repository in `docker_home` and copy all the files within the `mirosim_servers` to `docker_home`
```
cd /home/$USER/docker_home

git clone https://github.com/dcam0050/docker_starter.git

cp docker_starter/mirosim_servers/* .
```

3. Git clone the BlocklySim source files in docker_home
```
cd /home/$USER/docker_home

git clone https://github.com/MIRO-Robot/robot_blockly.git
```

4. At this point either wait for the download to finish to test the image or setup the optional bits

5. After the download has finished, you should see it listed when you run `docker images`

6. Use the `mirosim_image.sh` script to spin-up a container as follows:
```
./mirosim_image.sh dcamilleri13/all_connected:dev_mode <my_container_name> 9036 1036 8080 9000 live
```
Explanation: 
* 9036 -> Nginx Port (This is currently disabled by default)
* 1036 -> Blockly Frontend Port - This is the port over which the blockly frontend is served
* 8080 -> Gazebo Web Frontend Port - This is the port over which gzweb is served
* 9000 -> Blockly Backend Port - This is the port over which blockly frontend communicates with the backend in order to carry out the blockly code

These ports need to be specified because there can be multiple containers operating on the same host operating system but they must each have a unique set of ports. Trying to have multiple containers on the same port will end in sorrow.

The command as shown will create a container with your preferred name and also start it up. The container, upon starting up calls `mirosism.sh` which defines all the actions the container must do in order to properly start all the modules required for BlocklySim to run. 

To check correct operation, go to localhost:1036 and localhost:8080 in separate tabs within your browser.

**Side note**: You can also substitute the parameter `live` with `dev` which will create a container that does not start blockly and gazebo but instead starts into a terminal in order to allow for modification of the filesystem or installation of shiny new pieces.

You can attach to this terminal by running `docker attach <Container_name>`. 

This will attach your current terminal to the docker container but you can only have a single terminal attached to any one container. See **running multiple terminals** below if you are thirsty for more young padawan.

# Optional Bits

## Multiple Terminals
In order to have multiple terminals, follow the useful_aliases instructions above. 
Then close the container you want to open using `docker stop <container name>` and when closed run `launch <container_name>` This will allow you to run a multi-terminal GUI environment like `terminator` as well as using `subl` or `gedit` to edit any file in the system. Admin password: icub

Enjoy!
