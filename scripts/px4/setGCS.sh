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
PX4_MAVLINK_INIT_SCRIPT="${PX4_BUILD_DIR}/etc/init.d-posix/px4-rc.mavlink"

CheckDirExists "PX4-Autopilot"
CheckDirExists "${PX4_BUILD_DIR}/etc/init.d-posix"
CheckFileExists "${PX4_MAVLINK_INIT_SCRIPT}"

EchoGreen "[$(basename $0)] SETTING CONNECTION TO QGC."
if [ ! -z "${QGC_IP}" ]; then 
    # FIND THE LINE NUMVER CONTAINING "-u $udp_gcs_port_local -r"
    LINE_NUMBER=$(grep -n "\-u \$udp_gcs_port_local \-r" ${PX4_MAVLINK_INIT_SCRIPT} | cut -d: -f1)

    # REPLACE THE LINE WITH "mavlink start -x -t ${QGC_IP} -u $udp_gcs_port_local -r 4000000 -f"
    sed -i "${LINE_NUMBER}s/.*/mavlink start -x -t ${QGC_IP} -u \$udp_gcs_port_local -r 4000000 -f/" ${PX4_MAVLINK_INIT_SCRIPT}

    EchoGreen "[$(basename $0)] PX4 WILL BE LISTEN TO THE QGC AT ${QGC_IP}."
else
    EchoYellow "[$(basename $0)] PX4 WILL BE LISTEN TO THE QGC AT localhost."
fi
