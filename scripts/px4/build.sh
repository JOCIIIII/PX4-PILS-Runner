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
chmod -R o+rwx $(dirname "$BASE_DIR")/PX4-Autopilot

EchoGreen "[$(basename $0)] PX4-sitl BUILT SUCCESSFULLY."
EchoBoxLine

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<