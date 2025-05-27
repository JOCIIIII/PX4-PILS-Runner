#!/bin/bash
mkdir -p ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src
git clone https://github.com/JOCIIIII/A4VAI-Algorithms-ROS2.git ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src 
git -C ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src submodule update --init --recursive 
mkdir -p ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src/pathplanning/pathplanning/model 
wget https://github.com/kestr31/PX4-SITL-Runner/releases/download/Resources/weight.onnx -O ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src/pathplanning/pathplanning/model/weight.onnx 

chmod -R o+wrx ~/Documents/A4VAI-PILS/ROS2/ros2_ws 
./scripts/run.sh onboard ros2 make-tensorRT-engine.sh 
./scripts/run.sh onboard ros2 build ros2_ws 
./scripts/run.sh onboard ros2 stop 
wget https://github.com/JOCIIIII/PX4-PILS-Runner/releases/download/Resources/px4_ros.onboard.tar -O ~/Documents/A4VAI-PILS/ROS2/px4_ros.tar.gz 
tar -xvf ~/Documents/A4VAI-PILS/ROS2/px4_ros.tar.gz -C ~/Documents/A4VAI-PILS/ROS2 