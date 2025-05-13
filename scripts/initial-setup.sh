#!/bin/bash

# INITIAL STATEMENTS
# >>>----------------------------------------------------

# SET THE BASIC ENVIRONMENT VARIABLE
export TERM=xterm-256color

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(readlink -f "$0"))
REPO_DIR=$(dirname $(dirname $(readlink -f "$0")))

# SOURCE THE ENVIRONMENT AND FUNCTION DEFINITIONS
source ${BASE_DIR}/include/commonFcn.sh
source ${BASE_DIR}/include/commonEnv.sh

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# MAIN STATEMENTS
# >>>----------------------------------------------------

PX4_WORKSPACE=${PILS_DEPLOY_DIR}/PX4-Autopilot
GAZEBO_CLASSIC_WORKSPACE=${PILS_DEPLOY_DIR}/Gazebo-Classic
AIRSIM_WORKSPACE=${PILS_DEPLOY_DIR}/AirSim
ROS2_WORKSPACE=${PILS_DEPLOY_DIR}/ROS2
QGC_WORKSPACE=${PILS_DEPLOY_DIR}/QGroundControl

EchoYellow "[$(basename $0)] CONFIGUREING INITIAL CONDITIONS."

# CLONING AND BUILDING PX4-AUTOPILOT
${BASE_DIR}/run.sh px4 clone
${BASE_DIR}/run.sh px4 build

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<