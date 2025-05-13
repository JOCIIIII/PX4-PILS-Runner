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

CheckDirExists ${WORKSPACE_DIR}/px4_ros
CheckDirEmpty ${WORKSPACE_DIR}/px4_ros

CheckDirExists ${WORKSPACE_DIR}/px4_ros/install
CheckFileExists ${WORKSPACE_DIR}/px4_ros/install/setup.bash

source /opt/ros/${ROS_DISTRO}/setup.bash
source ${WORKSPACE_DIR}/px4_ros/install/setup.bash

EchoYellow "[$(basename $0)] STARRTING uXRCE DDS AGENT."
MicroXRCEAgent udp4 -p 8888

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<