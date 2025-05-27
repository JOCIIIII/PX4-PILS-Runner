#!/bin/bash

./scripts/run.sh sim px4 clone
./scripts/run.sh sim px4 build
./scripts/run.sh sim px4 stop
mkdir -p ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src
git clone https://github.com/JOCIIIII/A4VAI-ROS2-Util-Package.git ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src
chmod -R o+wrx ~/Documents/A4VAI-PILS/ROS2/ros2_ws 
./scripts/run.sh sim ros2 build ros2_ws 
./scripts/run.sh sim ros2 stop 
wget https://github.com/kestr31/PX4-SITL-Runner/releases/download/Resources/airsim.tar.gz -O ~/Documents/A4VAI-PILS/ROS2/airsim.tar.gz 
wget https://github.com/kestr31/PX4-SITL-Runner/releases/download/Resources/px4_ros.tar.gz -O ~/Documents/A4VAI-PILS/ROS2/px4_ros.tar.gz 
tar -zxvf ~/Documents/A4VAI-PILS/ROS2/airsim.tar.gz -C ~/Documents/A4VAI-PILS/ROS2 
tar -zxvf ~/Documents/A4VAI-PILS/ROS2/px4_ros.tar.gz -C ~/Documents/A4VAI-PILS/ROS2 
git clone https://github.com/dheera/rosboard.git -b v1.3.1 ~/Documents/A4VAI-PILS/ROS2/rosboard 
wget https://github.com/kestr31/PX4-SITL-Runner/releases/download/Resources/GazeboDrone -O ~/Documents/A4VAI-PILS/Gazebo-Classic/GazeboDrone 
chmod +x ~/Documents/A4VAI-PILS/Gazebo-Classic/GazeboDrone 
wget https://github.com/kestr31/PX4-SITL-Runner/releases/download/Resources/settings.json -O ~/Documents/A4VAI-PILS/AirSim/settings.json


