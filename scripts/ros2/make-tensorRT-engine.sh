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

cd ros2/scripts

python3 tensorrt_engine_build.py --onnx_path ~/workspace/ros2/ros2_ws/src/pathplanning/pathplanning/model/weight.onnx --engine_path_fp16 ~/workspace/ros2/ros2_ws/src/pathplanning/pathplanning/model/weight.onnx_fp16.trt --engine_path_int8 ~/workspace/ros2/ros2_ws/src/pathplanning/pathplanning/model/weight.onnx_int8.trt

chmod -R o+rwx ~/workspace/ros2/ros2_ws/src/pathplanning/pathplanning/model
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<