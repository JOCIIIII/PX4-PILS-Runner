#!/bin/bash

# INITIAL STATEMENTS
# >>>----------------------------------------------------

# SET THE BASIC ENVIRONMENT VARIABLE
export TERM=xterm-256color

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(readlink -f "$0"))

# SOURCE THE ENVIRONMENT AND FUNCTION DEFINITIONS
for file in ${BASE_DIR}/include/*.sh; do
    source ${file}
done
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# MAIN STATEMENTS
# >>>----------------------------------------------------

PX4_BUILD_DIR="PX4-Autopilot/build/px4_sitl_default"
PX4_INIT_SCRIPT="${PX4_BUILD_DIR}/etc/init.d-posix/rcS"

CheckDirExists "PX4-Autopilot"
CheckDirExists "${PX4_BUILD_DIR}/etc/init.d-posix"
CheckFileExists "${PX4_INIT_SCRIPT}"

EchoGreen "[$(basename $0)] SETTING uXRCE DDS AGENT IP TARGET."

# FIND THE LINE NUMVER CONTAINING "uxrce_dds_client start"
LINE_NUMBER=$(grep -n "uxrce_dds_client start" ${PX4_INIT_SCRIPT} | cut -d: -f1)

# REPLACE THE LINE WITH "uxrce_dds_client start -t udp -h ${ROS2_IP} -p $uxrce_dds_port $uxrce_dds_ns"
sed -i "${LINE_NUMBER}s/.*/uxrce_dds_client start -t udp -h ${ROS2_IP} -p \$uxrce_dds_port \$uxrce_dds_ns/" ${PX4_INIT_SCRIPT}

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<