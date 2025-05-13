#! /bin/bash

# SCRIPT TO BUILD ROS2 PACKAGE INSIDE THE CONTAINER

# INITIAL STATEMENTS
# >>>----------------------------------------------------

# SET THE BASIC ENVIRONMENT VARIABLE
export TERM=xterm-256color

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(readlink -f "$0"))
WORKSPACE_DIR=$(dirname $(dirname $(readlink -f "$0")))

# SOURCE THE ENVIRONMENT AND FUNCTION DEFINITIONS
for file in ${BASE_DIR}/include/*.sh; do
    source ${file}
done
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# MAIN STATEMENTS
# >>>----------------------------------------------------

CheckDirExists ${WORKSPACE_DIR}/airsim
CheckDirEmpty ${WORKSPACE_DIR}/airsim

CheckDirExists ${WORKSPACE_DIR}/airsim/install
CheckFileExists ${WORKSPACE_DIR}/airsim/install/setup.bash

source /opt/ros/${ROS_DISTRO}/setup.bash
source ${WORKSPACE_DIR}/airsim/install/setup.bash

EchoYellow "[$(basename $0)] STARRTING AIRSIM ROS2 BRIDGE."

while ! grep -q "SimpleFlight" /home/user/workspace/airsim/log; do
    EchoYellow "[$(basename $0)] WAITING FOR THE AIRSIM TO START."
    sleep 0.5
done

ros2 launch airsim_ros_pkgs airsim_node.launch.py host_ip:=${AIRSIM_IP}

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<