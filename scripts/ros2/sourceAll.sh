#! /bin/bash

# SCRIPT TO BUILD ROS2 PACKAGE INSIDE THE CONTAINER

# INITIAL STATEMENTS
# >>>----------------------------------------------------

# SET THE BASIC ENVIRONMENT VARIABLE
export TERM=xterm-256color

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(readlink -f "$0"))
WORKSPACE_DIR=$(dirname $(dirname $(readlink -f "$0")))

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# MAIN STATEMENTS
# >>>----------------------------------------------------

echo "[$(basename "$0")] SOURCING /opt/ros/${ROS_DISTRO}/setup.bash"
echo source /opt/ros/${ROS_DISTRO}/setup.bash

if ! grep -q "source /opt/ros/${ROS_DISTRO}/setup.bash" ${HOME}/.bashrc; then
    echo "[$(basename "$0")] ADDING SOURCE STATEMENT TO ${HOME}/.bashrc"
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ${HOME}/.bashrc
fi

if [ $# -eq 0 ]; then
    # FOR ALL DIRECTORIES IN ${BASE_DIR}/ros2
    # FIND ALL DIRECTORIES WHICH HAS SUBDIRECTORY 'src'
    for dir in $(find ${WORKSPACE_DIR} -maxdepth 1 -mindepth 1 -type d)
    do
        # CASE 1: THE DIRECTORY HAS 'src' SUBDIRECTORY
        if [ -d "${dir}/install" ]; then
            # CHECK IF 'install' DIRECTORY IS EMPTY
            # IF EMPTY, SKIP THE BUILD
            if [ -z "$(ls -A ${dir}/install)" ]; then
                echo "[$(basename "$0")] ${dir}/install IS EMPTY"
                echo "[$(basename "$0")] SKIPPING ${dir}"
            # ELSE, BUILD THE PACKAGES
            else
                echo "[$(basename "$0")] SOURCING ${dir}/install/setup.bash"

                source ${dir}/install/setup.bash

                if ! grep -q "source ${dir}/install/setup.bash" ${HOME}/.bashrc; then
                    echo "[$(basename "$0")] ADDING SOURCE STATEMENT TO ${HOME}/.bashrc"
                    echo "source ${dir}/install/setup.bash" >> ${HOME}/.bashrc
                fi
            fi
        # CASE 2: THE DIRECTORY DOES NOT HAVE 'src' SUBDIRECTORY
        else
            echo "[$(basename "$0")] ${dir} DOES NOT SEEM TO BE A ROS2 WORKSPACE"
        fi
    done
else
    for dir in "$@"
    do
        if [ ! -d ${WORKSPACE_DIR}/${dir} ]; then
            echo "[$(basename "$0")] ${dir} DOES NOT EXIST"
            exit 1
        fi

        if [ -z "$(ls -A ${WORKSPACE_DIR}/${dir})" ]; then
            echo "[$(basename "$0")] ${dir} IS EMPTY"
            exit 1
        fi

        echo "[$(basename "$0")] SOURCING ./${dir}/install/setup.bash"
        source ${WORKSPACE_DIR}/${dir}/install/setup.bash

        if ! grep -q "source ${WORKSPACE_DIR}/${dir}/install/setup.bash" ${HOME}/.bashrc; then
            echo "[$(basename "$0")] ADDING SOURCE STATEMENT TO ${HOME}/.bashrc"
            echo "source ${WORKSPACE_DIR}/${dir}/install/setup.bash" >> ${HOME}/.bashrc
        fi
    done
fi

echo "[$(basename "$0")] FINISHED SOURCING PACKAGES"

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<