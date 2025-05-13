#!/bin/bash

# SCRIPT TO STOP CONTAINERS CREATED FOR TESTING

# INITIAL STATEMENTS
# >>>----------------------------------------------------

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(readlink -f "$0"))
REPO_DIR=$(dirname $(dirname $(readlink -f "$0")))

# SOURCE THE ENVIRONMENT AND FUNCTION DEFINITIONS
source ${BASE_DIR}/include/commonFcn.sh
source ${BASE_DIR}/include/commonEnv.sh

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# DEFINE USAGE FUNCTION
# >>>----------------------------------------------------

usageState1(){
    EchoRed "Usage: $0 [gazebo-classic-PILS|gazebo-classic-airsim-PILS|px4|gazebo-classic|gazebo|airsim|ros2|qgc]"
    EchoRed "gazebo-classic-PILS: STOP GAZEBO PILS CONTAINERS"
    EchoRed "gazebo-classic-airism-PILS: STOP GAZEBO-AIRSIM PILS CONTAINERS"
    EchoRed "px4: STOP PX4-AUTOPILOT CONTAINER"
    EchoRed "gazebo-classic: STOP GAZEBO-CLASSIC CONTAINER"
    EchoRed "gazebo: STOP GAZEBO CONTAINER"
    EchoRed "airsim: STOP AIRSIM CONTAINER"
    EchoRed "ros2: STOP ROS2 CONTAINER"
    EchoRed "qgc: STOP QGroundControl CONTAINER"
    exit 1
}

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# CHECK IF ANY INPUT ARGUMENTS ARE PROVIDED
# >>>----------------------------------------------------

if [ $# -eq 0 ]; then
    usageState1 $0
else
    if [ "$1x" != "gazebo-classic-PILSx" ] && \
       [ "$1x" != "gazebo-classic-airsim-PILSx" ] && \
       [ "$1x" != "px4x" ] && \
       [ "$1x" != "gazebo-classicx" ] && \
       [ "$1x" != "gazebox" ] && \
       [ "$1x" != "airsimx" ] && \
       [ "$1x" != "ros2x" ] && \
       [ "$1x" != "qgcx" ]; then
        EchoRed "[$(basename "$0")] INVALID INPUT. PLEASE USE ARGUMENT AMONG
        \"gazebo-classic-PILS\"
        \"gazebo-classic-airsim-PILS\"
        \"px4\"
        \"gazebo-classic\"
        \"gazebo\"
        \"airsim\"
        \"ros2\"
        \"qgc\"."
        exit 1
    fi
fi

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# COMMON STATEMENTS
# >>>----------------------------------------------------

CheckFileExists ${PILS_DEPLOY_DIR}/compose.yml

CheckFileExists ${PILS_ENV_DIR}/common.env
CheckFileExists ${PILS_ENV_DIR}/px4.env
CheckFileExists ${PILS_ENV_DIR}/gazebo-classic.env
CheckFileExists ${PILS_ENV_DIR}/airsim.env
CheckFileExists ${PILS_ENV_DIR}/ros2.env
CheckFileExists ${PILS_ENV_DIR}/qgc.env

# RUN PROCESS PER ARGUMENT
if [ "$1x" == "gazebo-classic-PILSx" ]; then
    EchoYellow "[$(basename "$0")] STOPPING GAZEBO-CLASSIC-PILS CONTAINERS..."
elif [ "$1x" == "gazebo-classic-airsim-PILSx" ]; then
    EchoYellow "[$(basename "$0")] STOPPING GAZEBO-CLASSIC-AIRSIM-PILS CONTAINERS..."
elif [ "$1x" == "px4x" ]; then
    EchoYellow "[$(basename "$0")] STOPPING PX4 CONTAINER..."
elif [ "$1x" == "gazebo-classicx" ]; then
    EchoYellow "[$(basename "$0")] STOPPING GAZEBO-CLASSIC CONTAINER..."
elif [ "$1x" == "gazebox" ]; then
    EchoRed "[$(basename "$0")] NOT IMPLEMENTED YET"
    exit 1
elif [ "$1x" == "airsimx" ]; then
    EchoYellow "[$(basename "$0")] STOPPING AIRSIM CONTAINER..."
elif [ "$1x" == "ros2x" ]; then
    EchoYellow "[$(basename "$0")] STOPPING ROS2 CONTAINER..."
elif [ "$1x" == "qgcx" ]; then
    EchoYellow "[$(basename "$0")] STOPPING QGroundControl CONTAINER..."
fi

cd ${PILS_DEPLOY_DIR}

# IF THE ARGUMENT IS NOT ros2, THEN IT IS A SIMULATION ARGUMENT
if [ "$1x" != "ros2x" ]; then
    docker compose -f ${PILS_DEPLOY_DIR}/compose.yml \
        --env-file ./envs/common.env \
        --env-file ./envs/px4.env \
        --env-file ./envs/gazebo-classic.env \
        --env-file ./envs/airsim.env \
        --env-file ./envs/qgc.env \
        --profile $1 down
# ELSE, IT IS AN ONBOARD ARGUMENT
elif [ "$1x" == "ros2x" ]; then
    docker compose -f ${PILS_DEPLOY_DIR}/compose.onboard.yml \
        --env-file ./envs/ros2.env \
        --profile $1 down
fi
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
