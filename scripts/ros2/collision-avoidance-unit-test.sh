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

mkdir -p ${WORKSPACE_DIR}/ca_ws

tar -zxvf ${WORKSPACE_DIR}/deps_include.tar.gz -C /usr/local/include
tar -zxvf ${WORKSPACE_DIR}/deps_lib.tar.gz -C /usr/local/lib

source ${BASE_DIR}/sourceAll.sh

CheckFileExists ${BASE_DIR}/uxrce-dds.sh
CheckFileExecutable ${BASE_DIR}/uxrce-dds.sh

CheckFileExists ${BASE_DIR}/airsim-bridge.sh
CheckFileExecutable ${BASE_DIR}/airsim-bridge.sh

# CREATE DIRECTORY FOR LOGS
CheckDirExists ${WORKSPACE_DIR}/logs create
rm -rf ${WORKSPACE_DIR}/logs/*

# CREATE LOG FILES
touch ${WORKSPACE_DIR}/logs/uxrce-dds.log
touch ${WORKSPACE_DIR}/logs/airsim-bridge.log

# RUN THE SHELL SCRIPTS AND LOG THE OUTPUT
${BASE_DIR}/uxrce-dds.sh 2>&1 | tee ${WORKSPACE_DIR}/logs/uxrce-dds.log &
${BASE_DIR}/airsim-bridge.sh 2>&1 | tee ${WORKSPACE_DIR}/logs/airsim-bridge.log &

CheckDirExists ${WORKSPACE_DIR}/ros2_ws/build/algorithm_test/algorithm_test/collosion_avoidance_unit_test/log create
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# USER-DEFINED SATEMENTS
# >>>----------------------------------------------------

touch ${WORKSPACE_DIR}/logs/algorithm_test.log
touch ${WORKSPACE_DIR}/logs/collision_avoidance.log
touch ${WORKSPACE_DIR}/logs/pub_depth.log
touch ${WORKSPACE_DIR}/logs/plot.log

# ros2 run algorithm_test collision_avoidance_test 2>&1 | tee ${WORKSPACE_DIR}/logs/algorithm_test.log &
# ros2 run collision_avoidance collision_avoidance 2>&1 | tee ${WORKSPACE_DIR}/logs/collision_avoidance.log &
# ros2 run pub_depth pub_depth 2>&1 | tee ${WORKSPACE_DIR}/logs/pub_depth.log &

# ros2 run plotter plot 2>&1 | tee ${WORKSPACE_DIR}/logs/plot.log &

ros2 run rs_converter rs_converter 2>&1 | tee ${WORKSPACE_DIR}/logs/rs_converter.log &
ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 base_link velodyne 2>&1 | tee ${WORKSPACE_DIR}/logs/tf2_ros.log &
ros2 run rs_converter point_cloud_filter_node 2>&1 | tee ${WORKSPACE_DIR}/logs/point_cloud_filter_node.log &
ros2 run rs_converter point_cloud_feature_extractor 2>&1 | tee ${WORKSPACE_DIR}/logs/point_cloud_feature_extractor.log &
# ros2 run jbnu_obstacle_avoidance jbnu_obstacle_avoidance 2>&1 | tee ${WORKSPACE_DIR}/logs/jbnu_obstacle_avoidance.log &

# RUN ROSBOARD FOR ROS2 TOPIC VISUALIZATION
EchoGreen "Running ROSBOARD for ROS2 topic visualization..."
${WORKSPACE_DIR}/rosboard/run

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
