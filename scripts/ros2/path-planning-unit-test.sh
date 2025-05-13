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

source ${BASE_DIR}/sourceAll.sh

# CREATE DIRECTORY FOR LOGS
CheckDirExists ${WORKSPACE_DIR}/logs create
rm -rf ${WORKSPACE_DIR}/logs/*

CheckDirExists ${WORKSPACE_DIR}/ros2_ws/build/algorithm_test/algorithm_test/path_planning_unit_test/log create
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# USER-DEFINED SATEMENTS
# >>>----------------------------------------------------

touch ${WORKSPACE_DIR}/logs/Plan2WP.log
touch ${WORKSPACE_DIR}/logs/algorithm_test.log

ros2 run pathplanning Plan2WP 2>&1 | tee ${WORKSPACE_DIR}/logs/Plan2WP.log &
ros2 run algorithm_test path_planning_test 2>&1 | tee ${WORKSPACE_DIR}/logs/algorithm_test.log &

echo "running pathplanning unit test"

# PLACE USER-DEFINED SHELL SCRIPTS/COMMANDS HERE
# FOR EXAMPLE FOR RUNNING:
#   algorithm1 build at /home/user/workspace/ros2/alg_ws
# PLACE THE FOLLOWING COMMAND OR CREATE A SHELL SCRIPT WITH THE COMMAND:
#   source /opt/ros/${ROS_DISTRO}/setup.bash
#   source /home/user/workspace/ros2/alg_ws/install/setup.bash
#   ros2 run algorithm1 algorithm1_node
# CHECK uxrce-dds.sh, airsim-bridge.sh, AND THIS SCRIPT FOR EXAMPLES

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

sleep infinity
