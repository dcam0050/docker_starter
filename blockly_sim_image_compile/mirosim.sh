#!/usr/bin/env bash

cd $SRC_FOLDER/blockly_ws/install_isolated/share/robot_blockly/frontend/blockly && sudo python build.py && cd

roscore &

sleep 5
roslaunch robot_blockly robot_blockly.launch &

sleep 5
gzserver worlds/miro.world &

sleep 5
cd $GZWEBPATH && npm start
