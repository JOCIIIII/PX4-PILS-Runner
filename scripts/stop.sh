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
    EchoRed "Usage: $0 [sim|onboard]"
    EchoRed "sim: STOP SIMULATION CONTAINERS"
    EchoRed "onboard: STOP ONBOARD CONTAINERS"
    exit 1
}

usageState2(){
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
elif [ $# -eq 1 ]; then
    usageState2 $0
else
    if [ "$2x" != "gazebo-classic-PILSx" ] && \
       [ "$2x" != "gazebo-classic-airsim-PILSx" ] && \
       [ "$2x" != "px4x" ] && \
       [ "$2x" != "gazebo-classicx" ] && \
       [ "$2x" != "gazebox" ] && \
       [ "$2x" != "airsimx" ] && \
       [ "$2x" != "ros2x" ] && \
       [ "$2x" != "qgcx" ]; then
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
if [ "$1x" == "simx" ]; then
    CheckFileExists ${PILS_DEPLOY_DIR}/compose.sim.yml
elif [ "$1x" == "onboardx" ]; then
    CheckFileExists ${PILS_DEPLOY_DIR}/compose.onboard.yml
else
    EchoRed "[$(basename "$0")] INVALID ARGUMENT"
    exit 1
fi

CheckFileExists ${PILS_ENV_DIR}/common.env
CheckFileExists ${PILS_ENV_DIR}/px4.env
CheckFileExists ${PILS_ENV_DIR}/gazebo-classic.env
CheckFileExists ${PILS_ENV_DIR}/airsim.env
CheckFileExists ${PILS_ENV_DIR}/ros2.env
CheckFileExists ${PILS_ENV_DIR}/qgc.env

# RUN PROCESS PER ARGUMENT
if [ "$2x" == "gazebo-classic-PILSx" ]; then
    EchoYellow "[$(basename "$0")] STOPPING GAZEBO-CLASSIC-PILS CONTAINERS..."
elif [ "$2x" == "gazebo-classic-airsim-PILSx" ]; then
    EchoYellow "[$(basename "$0")] STOPPING GAZEBO-CLASSIC-AIRSIM-PILS CONTAINERS..."
elif [ "$2x" == "px4x" ]; then
    EchoYellow "[$(basename "$0")] STOPPING PX4 CONTAINER..."
elif [ "$2x" == "gazebo-classicx" ]; then
    EchoYellow "[$(basename "$0")] STOPPING GAZEBO-CLASSIC CONTAINER..."
elif [ "$2x" == "gazebox" ]; then
    EchoRed "[$(basename "$0")] NOT IMPLEMENTED YET"
    exit 1
elif [ "$2x" == "airsimx" ]; then
    EchoYellow "[$(basename "$0")] STOPPING AIRSIM CONTAINER..."
elif [ "$2x" == "ros2x" ]; then
    EchoYellow "[$(basename "$0")] STOPPING ROS2 CONTAINER..."
elif [ "$2x" == "qgcx" ]; then
    EchoYellow "[$(basename "$0")] STOPPING QGroundControl CONTAINER..."
fi

if [ "$1x" == "simx" ]; then
    (cd ${PILS_DEPLOY_DIR} && \
    docker compose -f ${PILS_DEPLOY_DIR}/compose.sim.yml \
        --env-file ./envs/common.env \
        --env-file ./envs/px4.env \
        --env-file ./envs/gazebo-classic.env \
        --env-file ./envs/airsim.env \
        --env-file ./envs/ros2.env \
        --env-file ./envs/qgc.env \
        --profile $2 down)
# ELSE, IT IS AN ONBOARD ARGUMENT
elif [ "$1x" == "onboardx" ]; then
    (cd ${PILS_DEPLOY_DIR} && \
    docker compose -f ${PILS_DEPLOY_DIR}/compose.onboard.yml \
        --env-file ./envs/common.env \
        --env-file ./envs/ros2.env \
        --env-file ./envs/px4.env \
        --profile $2 down)
else
    EchoRed "[$(basename "$0")] INVALID ARGUMENT"
    exit 1
fi
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
