#!/usr/bin/env bash
source ~/.sourceScripts
cd $SRC_FOLDER/blockly_ws/src/robot_blockly/frontend/blockly/ && python build.py

cd $SRC_FOLDER/blockly_ws
catkin_make_isolated -j4 --pkg robot_blockly --install

roscore &

echo $BLOCKLY_PORT
echo "TEST ECHO"
sleep 3
source $SRC_FOLDER/blockly_ws/install_isolated/setup.bash
roslaunch robot_blockly robot_blockly.launch &

sleep 3
gzserver worlds/miro_simple.world &

sleep 3
cd $GZWEBPATH && npm start

