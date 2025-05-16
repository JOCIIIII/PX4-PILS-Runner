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

# CHCEK IF DIRECTORY PX4-Autopilot AND gazebo-classic EXISTS
CheckDirExists "PX4-Autopilot"
CheckDirExists "PX4-Autopilot/Tools/simulation/gazebo-classic"

# COPY THE CUSTOM PX4 FILES TO THE PX4-Autopilot DIRECTORY
# >>>----------------------------------------------------
cp A4VAI-Custom-PX4-File/msg/PathFollowingAttCmd.msg                      PX4-Autopilot/msg/PathFollowingAttCmd.msg
cp A4VAI-Custom-PX4-File/msg/FusionWeight.msg                             PX4-Autopilot/msg/FusionWeight.msg
cp A4VAI-Custom-PX4-File/msg/CMakeLists.txt                               PX4-Autopilot/msg/CMakeLists.txt
cp A4VAI-Custom-PX4-File/mc_pos_control/MulticopterPositionControl.cpp    PX4-Autopilot/src/modules/mc_pos_control/MulticopterPositionControl.cpp
cp A4VAI-Custom-PX4-File/mc_pos_control/MulticopterPositionControl.hpp    PX4-Autopilot/src/modules/mc_pos_control/MulticopterPositionControl.hpp
cp A4VAI-Custom-PX4-File/mc_pos_control/CMakeLists.txt                    PX4-Autopilot/src/modules/mc_pos_control/CMakeLists.txt
cp A4VAI-Custom-PX4-File/uxrce_dds_client/dds_topics.yaml                 PX4-Autopilot/src/modules/uxrce_dds_client/dds_topics.yaml

# CHECK IF THE FILE sitl_run.sh EXISTS
CheckFileExists "PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_run.sh"

# BACKUP THE ORIGINAL sitl_run.sh
cp \
    PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_run.sh \
    PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_run.bak

# DELETE EXCEPT THE FIRST LINE TO BUILD PX4-sitl WHILE NOT RUNNING PX4-SITL
sed -i '2,$d' PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_run.sh

# BUILD PX4-SITL
(cd PX4-Autopilot || exit 1; make px4_sitl gazebo-classic)

# RESTORE THE ORIGINAL sitl_run.sh
mv \
    PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_run.bak \
    PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_run.sh

# SET THE PERMISSIONS OF THE PX4-Autopilot DIRECTORY
chmod -R o+rwx $(dirname "$BASE_DIR")

EchoGreen "[$(basename $0)] PX4-sitl BUILT SUCCESSFULLY."
EchoBoxLine

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<