#!/bin/bash

# GAZEBO-ONLY LAUNCH SCRIPT (WITHOUT PX4 SITL)
# Modified from sitl-px4.sh to run only Gazebo Classic

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

# SET ENVIRONMENT VARIABLES
PX4_WORKSPACE=/home/user/workspace/px4
GAZEBO_WORKSPACE=/home/user/workspace/gazebo

PX4_SOURCE_DIR=${PX4_WORKSPACE}/PX4-Autopilot
PX4_SIM_DIR=${PX4_WORKSPACE}/PX4-Autopilot/Tools/simulation
PX4_BUILD_DIR=${PX4_WORKSPACE}/PX4-Autopilot/build/px4_sitl_default
PX4_BINARY_DIR=${PX4_WORKSPACE}/PX4-Autopilot/build/px4_sitl_default/bin

source /usr/share/gazebo/setup.bash
export GAZEBO_RESOURCE_PATH=${GAZEBO_RESOURCE_PATH}:${GAZEBO_WORKSPACE}/worlds

# CHECK IF THE DIRECTORIES EXIST
CheckDirExists ${PX4_SOURCE_DIR}
CheckDirExists ${PX4_SIM_DIR}

# COPY GAZEBO RESOURCES IF THEY EXIST
if [ -d ${GAZEBO_WORKSPACE}/media ]; then
    if [ -z "$(ls -A ${GAZEBO_WORKSPACE}/media)" ]; then
        EchoYellow "[$(basename $0)] ${GAZEBO_WORKSPACE}/media IS EMPTY."
    else
        cp -r ${GAZEBO_WORKSPACE}/media/* /usr/share/gazebo-11/media
    fi
fi

# COPY GAZEBO WORLDS IF THEY EXIST
if [ -d ${GAZEBO_WORKSPACE}/worlds ]; then
    if [ ! -f "$(ls -A ${GAZEBO_WORKSPACE}/worlds/*.world 2>/dev/null | head -1)" ]; then
        EchoYellow "[$(basename $0)] ${GAZEBO_WORKSPACE}/worlds DOES NOT CONTAIN ANY .world FILES."
    else
        mkdir -p ${PX4_WORKSPACE}/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic/worlds
        cp -r ${GAZEBO_WORKSPACE}/worlds/*.world ${PX4_WORKSPACE}/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic/worlds
    fi
fi

# RUN ADDITIONAL SETUP SCRIPT IF IT EXISTS
if [ -f ${GAZEBO_WORKSPACE}/worlds/${PILS_WORLD}.sh ]; then
    EchoYellow "[$(basename $0)] ADDITIONAL SETUP SCRIPT ${PILS_WORLD}.sh FOUND."
    EchoYellow "[$(basename $0)] RUNNING ${PILS_WORLD}.sh."
    ${GAZEBO_WORKSPACE}/worlds/${PILS_WORLD}.sh
fi

# ============================================
# SETUP FOR AIRSIM INTEGRATION
# ============================================
EchoGreen "[$(basename $0)] Setting up AirSim integration..."

# Check if separateFromGazebo.sh exists
if [ -f ${BASE_DIR}/separateFromGazebo.sh ]; then
    EchoGreen "[$(basename $0)] Running separateFromGazebo.sh for AirSim..."
    ${BASE_DIR}/separateFromGazebo.sh airsim
else
    EchoYellow "[$(basename $0)] separateFromGazebo.sh not found. Skipping AirSim setup."
fi

# CREATE DIRECTORY FOR LOGS
CheckDirExists ${GAZEBO_WORKSPACE}/logs create
rm -rf ${GAZEBO_WORKSPACE}/logs/*

# CREATE LOG FILES
touch ${GAZEBO_WORKSPACE}/logs/gazebo.log

# ============================================
# SETUP GAZEBO ENVIRONMENT (NEW APPROACH)
# ============================================
EchoGreen "[$(basename $0)] Setting up Gazebo environment..."

cd ${PX4_SOURCE_DIR}

# Source Gazebo setup script
source Tools/simulation/gazebo-classic/setup_gazebo.bash ${PX4_SOURCE_DIR} ${PX4_BUILD_DIR}

# Display environment variables for debugging
EchoGreen "[$(basename $0)] GAZEBO_PLUGIN_PATH: ${GAZEBO_PLUGIN_PATH}"
EchoGreen "[$(basename $0)] GAZEBO_MODEL_PATH: ${GAZEBO_MODEL_PATH}"
EchoGreen "[$(basename $0)] LD_LIBRARY_PATH: ${LD_LIBRARY_PATH}"

# ============================================
# LAUNCH GAZEBO ONLY (WITHOUT PX4 SITL)
# ============================================
WORLD_FILE="Tools/simulation/gazebo-classic/sitl_gazebo-classic/worlds/${PILS_WORLD}.world"

if [ ! -f "${WORLD_FILE}" ]; then
    EchoRed "[$(basename $0)] ERROR: World file not found: ${WORLD_FILE}"
    EchoYellow "[$(basename $0)] Available world files:"
    ls -1 Tools/simulation/gazebo-classic/sitl_gazebo-classic/worlds/*.world
    exit 1
fi

EchoGreen "[$(basename $0)] Launching Gazebo Classic..."
EchoGreen "[$(basename $0)] World: ${PILS_WORLD}"
EchoGreen "[$(basename $0)] Airframe: ${PILS_AIRFRAME}"
EchoGreen "[$(basename $0)] World file: ${WORLD_FILE}"

# Check if model exists in world file
if grep -q "name='${PILS_AIRFRAME}'" "${WORLD_FILE}"; then
    EchoGreen "[$(basename $0)] Model '${PILS_AIRFRAME}' found in world file, skipping dynamic spawn"
else
    EchoYellow "[$(basename $0)] WARNING: Model '${PILS_AIRFRAME}' not found in world file"
    EchoYellow "[$(basename $0)] You may need to spawn the model manually"
fi

# Launch Gazebo in the background with logging
gazebo --verbose "${WORLD_FILE}" 2>&1 | tee ${GAZEBO_WORKSPACE}/logs/gazebo.log &

EchoGreen "[$(basename $0)] Gazebo launched. Logs: ${GAZEBO_WORKSPACE}/logs/gazebo.log"

# ============================================
# WAIT FOR AIRSIM AND LAUNCH GAZEBODRONE BRIDGE
# ============================================
EchoGreen "[$(basename $0)] Waiting for AirSim to be ready..."

# Wait for AirSim log file
AIRSIM_LOG="/home/user/workspace/airsim/log"
TIMEOUT=120  # Increased timeout
ELAPSED=0

while [ ! -f "${AIRSIM_LOG}" ] && [ ${ELAPSED} -lt ${TIMEOUT} ]; do
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done

if [ ${ELAPSED} -ge ${TIMEOUT} ]; then
    EchoYellow "[$(basename $0)] WARNING: AirSim log file not found after ${TIMEOUT} seconds"
    EchoYellow "[$(basename $0)] GazeboDrone bridge will not start automatically"
else
    # Wait for SimpleFlight to appear in log
    EchoGreen "[$(basename $0)] AirSim log found. Waiting for SimpleFlight..."

    while ! grep -q "SimpleFlight" "${AIRSIM_LOG}"; do
        sleep 0.5
    done

    EchoGreen "[$(basename $0)] AirSim SimpleFlight detected!"

    # Additional wait for AirSim API server to be fully ready
    EchoGreen "[$(basename $0)] Waiting for AirSim API server to initialize..."
    sleep 10  # Give AirSim API server time to start

    # Verify API server is listening
    RETRY=0
    while [ ${RETRY} -lt 30 ]; do
        if netstat -tln 2>/dev/null | grep -q ":41451" || ss -tln 2>/dev/null | grep -q ":41451"; then
            EchoGreen "[$(basename $0)] AirSim API server is ready on port 41451"
            break
        fi
        sleep 1
        RETRY=$((RETRY + 1))
    done

    # Check if GazeboDrone binary exists
    GAZEBODRONE_BIN="${GAZEBO_WORKSPACE}/GazeboDrone"
    if [ ! -f "${GAZEBODRONE_BIN}" ]; then
        EchoRed "[$(basename $0)] ERROR: GazeboDrone binary not found at ${GAZEBODRONE_BIN}"
        EchoYellow "[$(basename $0)] Skipping bridge initialization"
    else
        # Launch GazeboDrone bridge (no IP argument needed - auto-discovers on host network)
        EchoGreen "[$(basename $0)] Launching GazeboDrone bridge..."

        # Clear old log
        echo "" > ${GAZEBO_WORKSPACE}/logs/gazebodrone.log

        # Start GazeboDrone in background
        ${GAZEBODRONE_BIN} >> ${GAZEBO_WORKSPACE}/logs/gazebodrone.log 2>&1 &

        BRIDGE_PID=$!
        EchoGreen "[$(basename $0)] GazeboDrone bridge started (PID: ${BRIDGE_PID})"

        # Wait for connection to establish
        EchoGreen "[$(basename $0)] Waiting for GazeboDrone to connect..."
        RETRY_COUNT=0
        MAX_RETRIES=30

        while [ ${RETRY_COUNT} -lt ${MAX_RETRIES} ]; do
            if grep -q "Connected!" ${GAZEBO_WORKSPACE}/logs/gazebodrone.log 2>/dev/null; then
                EchoGreen "[$(basename $0)] GazeboDrone successfully connected to AirSim!"

                # Additional wait for initial sync
                sleep 3
                EchoGreen "[$(basename $0)] Initial synchronization complete"
                break
            fi
            sleep 1
            RETRY_COUNT=$((RETRY_COUNT + 1))
        done

        if [ ${RETRY_COUNT} -ge ${MAX_RETRIES} ]; then
            EchoYellow "[$(basename $0)] WARNING: GazeboDrone connection timeout"
            EchoYellow "[$(basename $0)] Check logs: ${GAZEBO_WORKSPACE}/logs/gazebodrone.log"
            EchoYellow "[$(basename $0)] You may need to manually restart GazeboDrone"
        fi

        EchoGreen "[$(basename $0)] Bridge logs: ${GAZEBO_WORKSPACE}/logs/gazebodrone.log"
    fi
fi

# Keep container running
sleep infinity

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
