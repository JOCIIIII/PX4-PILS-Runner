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

EchoGreen "[$(basename "$0")] DEBUG MDOE ENABLED FOR PX4 WORKSPACE"
EchoGreen "[$(basename "$0")] THIS CONTAINER WILL DO NOTHING WHEN DEPLOYED (sleep infinity)"
EchoGreen "[$(basename "$0")] YOU CAN WORK INSIDE THE CONTAINER BY FOLLOWING METHODS:"
EchoGreen "[$(basename "$0")] *   1. BY ATTACHING TERMINAL BY 'docker exec -it px4-env bash'"
EchoGreen "[$(basename "$0")] *   2. BY USING VISUAL STUDIO CODE \"REMOTE DEV\" EXTENSION"

sleep infinity

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<