#!/bin/bash

# SCRIPT TO RUN CONTAINER FOR TESTING

# INITIAL STATEMENTS
# >>>----------------------------------------------------

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(readlink -f "$0"))
REPO_DIR=$(dirname $(dirname $(readlink -f "$0")))

# SOURCE THE ENVIRONMENT AND FUNCTION DEFINITIONS
for file in ${BASE_DIR}/include/*.sh; do
    source ${file}
done
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# INPUT STATEMENT 1 VALIDITY CHECK
# >>>----------------------------------------------------

# DECLARE DICTIONARY OF USAGE STATEMENTS 1
## KEY: ARGUMENT, CONTENT: DESCRIPTION
declare -A usageState1
usageState1["sim"]="SETUP THE SIMULATION ENVIRONMENT"
usageState1["onboard"]="SETUP THE ONBOARD COMPUTER"

CheckValidity $0 usageState1 1 "$@"
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# RUN PROCESS PER ARGUMENT
# >>>----------------------------------------------------
if [ "$1x" == "simx" ]; then
    # INPUT STATEMENT 2 VALIDITY CHECK
    # >>>----------------------------------------------------
    declare -A usageState2
    usageState2["gazebo-classic-pils"]="DEPLOY GAZEBO PILS CONTAINER"
    usageState2["gazebo-classic-airsim-pils"]="DEPLOY GAZEBO-AIRSIM PILS CONTAINER"
    usageState2["px4"]="DEPLOY PX4-AUTOPILOT CONTAINER"
    usageState2["gazebo-classic"]="DEPLOY GAZEBO-CLASSIC CONTAINER"
    usageState2["gazebo"]="DEPLOY GAZEBO CONTAINER"
    usageState2["airsim"]="DEPLOY AIRSIM CONTAINER"
    usageState2["ros2"]="DEPLOY ROS2 CONTAINER"
    usageState2["qgc"]="DEPLOY QGroundControl CONTAINER"

    CheckValidity $0 usageState2 2 "$@"
    # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    # RUN PROCESS PER ARGUMENT
    # >>>----------------------------------------------------
    # PERFORM BASIC SETUP
    ## WORKSPACE DIRECTORIES, ENVIRONMENT VARIABLES, AND DISPLAY SETTINGS
    SimBasicSetup

    if [ "$2x" == "gazebo-classic-pilsx" ]; then
        # INPUT STATEMENT 3 VALIDITY CHECK
        # >>>----------------------------------------------------
        declare -A usageState3
        usageState3["run"]="RUN PX4-AUTOPILOT PILS IN GAZEBO-CLASSIC"
        usageState3["debug"]="RUN PX4-AUTOPILOT PILS IN GAZEBO-CLASSIC IN DEBUG MODE (OPTION: SERVICE(S) TO STOP)"
        usageState3["stop"]="STOP PX4-AUTOPILOT PILS IN GAZEBO-CLASSIC IF IT IS RUNNING"

        CheckValidity $0 usageState3 3 "$@"
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        # RUN FOR EACH ARGUMENT
        # >>>----------------------------------------------------
        # ACTION: stop. STOP THE CONTAINER
        if [ "$3x" == "stopx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"

            EchoYellow "[$(basename "$0")] THIS FEATURE IS FOR CONVENIENCE."
            EchoYellow "[$(basename "$0")] IT IS RECOMMENDED TO USE stop.sh SCRIPT TO STOP THE CONTAINER."

            ${BASE_DIR}/stop.sh $1 $2
            exit 0
        # ACTION: debug. RUN THE CONTAINER IN DEBUG MODE (sleep infinity)
        elif [ "$3x" == "debugx" ]; then
            EchoGreen "[$(basename "$0")] RUNNING GAZEBO-CLASSIC-PILS CONTAINER(S) IN DEBUG MODE."
            # WHEN NUMBER OF ARGUMENTS IS 2
            if [ $# -eq 3 ]; then
                EchoGreen "[$(basename "$0")] SETTING ALL CONTAINERS IN DEBUG MODE"
                SetRunModePX4 $0 debug
                SetRunModeGazeboClassic $0 debug
                SetRunModeQGC $0 debug
            else
                # FOR EACH ARGUMENT STARTING FROM THE THIRD ARGUMENT, SET THE COMMAND TO THE .env FILE
                for arg in "${@:3}"; do
                    if [ "${arg}x" == "px4x" ]; then
                        SetRunModePX4 $0 debug
                    elif [ "${arg}x" == "gazebo-classicx" ]; then
                        SetRunModeGazeboClassic $0 debug
                    elif [ "${arg}x" == "qgcx" ]; then
                        SetRunModeQGC $0 debug
                    else
                        EchoRed "[$(basename "$0")] INVALID INPUT \"$arg\". PLEASE USE ARGUMENT AMONG"
                        EchoRed "*   \"px4\""
                        EchoRed "*   \"gazebo-classic\""
                        EchoRed "*   \"qgc\""
                        EchoRed "TO STOP THE CONTAINER SELECTIVELY OR LEAVE IT EMPTY TO STOP EVERYTHING."
                        exit 1
                    fi
                done
            fi

            SetRunModePX4 $0 gazebo-classic-sitl
            SetRunModeGazeboClassic $0 gazebo-classic-sitl
            SetRunModeQGC $0 normal
        # ACTION: run. RUN THE PX4-GAZEBO-CLASSIC PILS SIMULATION
        elif [ "$3x" == "runx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"

            SetRunModePX4 $0 gazebo-classic-sitl
            SetRunModeGazeboClassic $0 gazebo-classic-sitl
            SetRunModeQGC $0 normal
        fi
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    elif [ "$2x" == "gazebo-classic-airsim-pilsx" ]; then
        # INPUT STATEMENT 3 VALIDITY CHECK
        # >>>----------------------------------------------------
        declare -A usageState3
        usageState3["run"]="RUN PX4-AUTOPILOT PILS IN GAZEBO-CLASSIC"
        usageState3["debug"]="RUN PX4-AUTOPILOT PILS IN GAZEBO-CLASSIC IN DEBUG MODE (OPTION: SERVICE(S) TO STOP)"
        usageState3["stop"]="STOP PX4-AUTOPILOT PILS IN GAZEBO-CLASSIC IF IT IS RUNNING"

        CheckValidity $0 usageState3 3 "$@"
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        # RUN FOR EACH ARGUMENT
        # >>>----------------------------------------------------
        # ACTION: stop. STOP THE CONTAINER
        if [ "$3x" == "stopx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"

            EchoYellow "[$(basename "$0")] THIS FEATURE IS FOR CONVENIENCE."
            EchoYellow "[$(basename "$0")] IT IS RECOMMENDED TO USE stop.sh SCRIPT TO STOP THE CONTAINER."

            ${BASE_DIR}/stop.sh $1 $2
            exit 0
        # ACTION: debug. SET CONTAINERS IN DEBUG MODE
        elif [ "$3x" == "debugx" ]; then
            EchoGreen "[$(basename "$0")] RUNNING GAZEBO-CLASSIC-PILS CONTAINERs IN DEBUG MODE."
            # WHEN NUMBER OF ARGUMENTS IS 2. SET ALL CONTAINERS IN DEBUG MODE
            if [ $# -eq 3 ]; then
                EchoGreen "[$(basename "$0")] SETTING ALL CONTAINERS IN DEBUG MODE"
                SetRunModePX4 $0 debug
                SetRunModeGazeboClassic $0 debug
                SetRunModeAirSim $0 debug
                SetRunModeROS2 $0 $1 debug
                SetRunModeQGC $0 debug
            # IF NOT, SET THE DEBUG MODE FOR THE SELECTED CONTAINERS
            else
                # FOR EACH ARGUMENT STARTING FROM THE THIRD ARGUMENT, SET THE COMMAND TO THE .env FILE
                for arg in "${@:3}"; do
                    echo $arg
                    if [ "${arg}x" == "px4x" ]; then
                        SetRunModePX4 $0 debug
                    elif [ "${arg}x" == "gazebo-classicx" ]; then
                        SetRunModeGazeboClassic $0 debug
                    elif [ "${arg}x" == "airsimx" ]; then
                        SetRunModeAirSim $0 debug
                    elif [ "${arg}x" == "ros2x" ]; then
                        SetRunModeROS2 $0 $1 debug
                    elif [ "${arg}x" == "qgcx" ]; then
                        SetRunModeQGC $0 debug
                    else
                      CLASSIC PILS SIMULATION  EchoRed "*   \"gazebo-classic\""
                        EchoRed "*   \"airsim\""
                        EchoRed "*   \"ros2\""
                        EchoRed "*   \"qgc\""
                        EchoRed "TO STOP THE CONTAINER SELECTIVELY OR LEAVE IT EMPTY TO STOP EVERYTHING."
                        exit 1
                    fi
                done
            fi

            SetRunModePX4 $0 gazebo-classic-airsim-sitl
            SetRunModeGazeboClassic $0 gazebo-classic-airsim-sitl
            SetRunModeAirSim $0 gazebo-classic-airsim-pils
            SetRunModeROS2 $0 $1 gazebo-classic-airsim-pils
            SetRunModeQGC $0 normal
        # ACTION: run. RUN THE PX4-GAZEBO-CLASSIC-AIRSIM PILS SIMULATION
        elif [ "$3x" == "runx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"

            SetRunModePX4 $0 gazebo-classic-airsim-sitl
            SetRunModeGazeboClassic $0 gazebo-classic-airsim-sitl
            SetRunModeAirSim $0 gazebo-classic-airsim-pils
            SetRunModeROS2 $0 $1 gazebo-classic-airsim-pils
            SetRunModeQGC $0 normal
        fi
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    elif [ "$2x" == "px4x" ]; then
        # INPUT STATEMENT 2 VALIDITY CHECK
        # >>>----------------------------------------------------
        declare -A usageState3
        usageState3["clone"]="CLONE PX4-AUTOPILOT REPOSITORY"
        usageState3["build"]="BUILD PX4-AUTOPILOT INSIDE THE CONTAINER"
        usageState3["clean"]="CLEAN PX4-AUTOPILOT BUILD"
        usageState3["sitl-gazebo-classic-standalone"]="RUN PX4-AUTOPILOT SITL IN GAZEBO-CLASSIC IN STANDALONE MODE (ON ONE CONTAINER)"
        usageState3["debug"]="RUN PX4-AUTOPILOT CONTAINER IN DEBUG MODE (sleep infinity)"
        usageState3["stop"]="STOP PX4-AUTOPILOT CONTAINER IF IT IS RUNNING"

        CheckValidity $0 usageState3 3 "$@"
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        # RUN FOR EACH ARGUMENT
        # >>>----------------------------------------------------
        # ACTION: stop. STOP THE CONTAINER
        if [ "$3x" == "stopx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"

            EchoYellow "[$(basename "$0")] THIS FEATURE IS FOR CONVENIENCE."
            EchoYellow "[$(basename "$0")] IT IS RECOMMENDED TO USE stop.sh SCRIPT TO STOP THE CONTAINER."

            ${BASE_DIR}/stop.sh $1 $2
            exit 0
        # ACTIONS: debug. RUN THE CONTAINER IN DEBUG MODE
        elif [ "$3x" == "debugx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModePX4 $0 debug
        elif [ "$3x" == "clonex" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModePX4 $0 clone
        elif [ "$3x" == "buildx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModePX4 $0 build
        elif [ "$3x" == "cleanx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModePX4 $0 clean
        elif [ "$3x" == "sitl-gazebo-classic-standalonex" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModePX4 $0 sitl-gazebo-classic-standalone
        fi
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    elif [ "$2x" == "gazebo-classicx" ]; then
        # INPUT STATEMENT 2 VALIDITY CHECK
        # >>>----------------------------------------------------
        declare -A usageState3
        usageState3["sitl-px4"]="RUN PX4-AUTOPILOT SITL IN GAZEBO-CLASSIC"
        usageState3["debug"]="RUN GAZEBO-CLASSIC CONTAINER IN DEBUG MODE (sleep infinity)"
        usageState3["stop"]="STOP GAZEBO-CLASSIC CONTAINER IF IT IS RUNNING"
    
        CheckValidity $0 usageState3 3 "$@"
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        # RUN FOR EACH ARGUMENT
        # >>>----------------------------------------------------
        # ACTION: stop. STOP THE CONTAINER
        if [ "$3x" == "stopx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"

            EchoYellow "[$(basename "$0")] THIS FEATURE IS FOR CONVENIENCE."
            EchoYellow "[$(basename "$0")] IT IS RECOMMENDED TO USE stop.sh SCRIPT TO STOP THE CONTAINER."

            ${BASE_DIR}/stop.sh $1 $2
            exit 0
        # ACTION: debug. RUN THE CONTAINER IN DEBUG MODE
        elif [ "$3x" == "debugx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeGazeboClassic $0 debug
        elif [ "$3x" == "sitl-px4x" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeGazeboClassic $0 sitl-px4
        fi
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    elif [ "$2x" == "gazebox" ]; then
        EchoRed "[$(basename "$0")] NOT IMPLEMENTED YET"
        exit 1
    elif [ "$2x" == "airsimx" ]; then
        # INPUT STATEMENT 2 VALIDITY CHECK
        # >>>----------------------------------------------------
        declare -A usageState3
        usageState3["debug"]="RUN AIRSIM CONTAINER IN DEBUG MODE (sleep infinity)"
        usageState3["stop"]="STOP AIRSIM CONTAINER IF IT IS RUNNING"
        usageState3["auto"]="RUN AIRSIM CONTAINER IN AUTO MODE (run .sh file in /home/ue4/workspace/binary)"
        usageState3["*.sh"]="RUN AIRSIM CONTAINER IN MANUAL MODE (run specific .sh file)"
    
        CheckValidity $0 usageState3 3 "$@"
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        # RUN FOR EACH ARGUMENT
        # >>>----------------------------------------------------
        # ACTION: stop. STOP THE CONTAINER
        if [ "$3x" == "stopx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"

            EchoYellow "[$(basename "$0")] THIS FEATURE IS FOR CONVENIENCE."
            EchoYellow "[$(basename "$0")] IT IS RECOMMENDED TO USE stop.sh SCRIPT TO STOP THE CONTAINER."

            ${BASE_DIR}/stop.sh $1 $2
            exit 0
        # ACTION: debug. RUN THE CONTAINER IN DEBUG MODE
        elif [ "$3x" == "debugx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeAirSim $0 debug
        # ACTION: auto. RUN THE CONTAINER IN AUTO MODE (run .sh file in /home/ue4/workspace/binary)
        elif [ "$3x" == "autox" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeAirSim $0 auto
        # ACTION: *.sh. RUN THE CONTAINER IN MANUAL MODE (run specific .sh file)
        elif [[ "$3x" == *".shx" ]]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeAirSim $0 $2
        fi
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    elif [ "$2x" == "ros2x" ]; then
        # INPUT STATEMENT 2 VALIDITY CHECK
        # >>>----------------------------------------------------
        declare -A usageState3
        usageState3["debug"]="RUN ROS2 CONTAINER IN DEBUG MODE (sleep infinity)"
        usageState3["stop"]="STOP ROS2 CONTAINER IF IT IS RUNNING"
        usageState3["build"]="BUILD ROS2 PACKAGES INSIDE THE CONTAINER (TARGET_WORKSPACE(S) IS(ARE) OPTIONAL)"
        usageState3["*.sh"]="RUN ROS2 CONTAINER IN MANUAL MODE (run specific shell script)"
    
        CheckValidity $0 usageState3 3 "$@"
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        # RUN FOR EACH ARGUMENT
        # >>>----------------------------------------------------
        # ACTION: stop. STOP THE CONTAINER
        if [ "$3x" == "stopx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"

            EchoYellow "[$(basename "$0")] THIS FEATURE IS FOR CONVENIENCE."
            EchoYellow "[$(basename "$0")] IT IS RECOMMENDED TO USE stop.sh SCRIPT TO STOP THE CONTAINER."

            ${BASE_DIR}/stop.sh $1 $2
            exit 0
            # ACTION: debug. RUN THE CONTAINER IN DEBUG MODE
        elif [ "$3x" == "debugx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeROS2 $0 $1 debug
        # ACTION: build. BUILD ROS2 PACKAGES INSIDE THE CONTAINER
        elif [ "$3x" == "buildx" ]; then
            # IF ADDITIONAL DIRECTORIES ARE PROVIDED, PASS THEM TO THE BUILD SCRIPT
            if [ $# -ge 3 ]; then
                # DUE TO SED ESCAPE ISSUE, ADDITIONAL ENVIRONMENT VARIABLE IS SET
                TARGET_ROS2_WORKSPACES=${@:3}
                SetRunModeROS2 $0 $1 "build ${TARGET_ROS2_WORKSPACES}"
            # ELSE, RUN THE BUILD SCRIPT. THIS WILL BUILD ALL PACKAGES IN THE ALL DIRECTORIES THAT HAVE NON-EMPTY 'src' SUBDIRECTORY
            else
                SetRunModeROS2 $0 $1 "build"
            fi
        # ACTION: *.sh. RUN THE CONTAINER IN MANUAL MODE (RUN SPECIFIC SHELL SCRIPT)
        elif [[ "$3x" == *".shx" ]]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeROS2 $0 $1 $2
        fi
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    elif [ "$2x" == "qgcx" ]; then
        # INPUT STATEMENT 2 VALIDITY CHECK
        # >>>----------------------------------------------------
        declare -A usageState3
        usageState3["debug"]="RUN QGroundControl CONTAINER IN DEBUG MODE (sleep infinity)"
        usageState3["stop"]="STOP QGroundControl CONTAINER IF IT IS RUNNING"
        usageState3["run"]="RUN QGroundControl CONTAINER IN NORMAL MODE"
    
        CheckValidity $0 usageState3 3 "$@"
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        # RUN FOR EACH ARGUMENT
        # >>>----------------------------------------------------
        # ACTION: stop. STOP THE CONTAINER
        if [ "$3x" == "stopx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"

            EchoYellow "[$(basename "$0")] THIS FEATURE IS FOR CONVENIENCE."
            EchoYellow "[$(basename "$0")] IT IS RECOMMENDED TO USE stop.sh SCRIPT TO STOP THE CONTAINER."

            ${BASE_DIR}/stop.sh $1 $2
            exit 0
        # ACTION: debug. RUN THE CONTAINER IN DEBUG MODE (sleep infinity)
        elif [ "$3x" == "debugx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeQGC $0 debug
        # ACTION: run. RUN THE CONTAINER IN NORMAL MODE
        elif [ "$3x" == "runx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeQGC $0 normal
        fi
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    fi
elif [ "$1x" == "onboardx" ]; then
    # INPUT STATEMENT 2 VALIDITY CHECK
    # >>>----------------------------------------------------
    declare -A usageState2
    usageState2["gazebo-classic-pils"]="DEPLOY GAZEBO PILS CONTAINER"
    usageState2["gazebo-classic-airsim-pils"]="DEPLOY GAZEBO-AIRSIM PILS CONTAINER"
    usageState2["ros2"]="DEPLOY ROS2 CONTAINER"

    CheckValidity $0 usageState2 2 "$@"

    # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    # RUN PROCESS PER ARGUMENT
    # >>>----------------------------------------------------
    # PERFORM BASIC SETUP
    ## WORKSPACE DIRECTORIES, ENVIRONMENT VARIABLES, AND DISPLAY SETTINGS
    OnboardBasicSetup

    if [ "$2x" == "gazebo-classic-pilsx" ]; then
        # INPUT STATEMENT 3 VALIDITY CHECK
        declare -A usageState3
        usageState3["run"]="RUN ONBOARD ARGUMENT"
        usageState3["stop"]="STOP ONBOARD ARGUMENT IF IT IS RUNNING"

        CheckValidity $0 usageState3 3 "$@"

        if [ "$3x" == "runx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeROS2 $0 $1 gazebo-classic-pils
        elif [ "$3x" == "stopx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            ${BASE_DIR}/stop.sh $1 $2
            exit 0
        fi
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    elif [ "$2x" == "gazebo-classic-airsim-pilsx" ]; then
        # INPUT STATEMENT 3 VALIDITY CHECK
        declare -A usageState3
        usageState3["run"]="RUN ONBOARD ARGUMENT"
        usageState3["stop"]="STOP ONBOARD ARGUMENT IF IT IS RUNNING"

        CheckValidity $0 usageState3 3 "$@"

        if [ "$3x" == "runx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeROS2 $0 $1 gazebo-classic-airsim-pils
        elif [ "$3x" == "stopx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            ${BASE_DIR}/stop.sh $1 $2
            exit 0
        fi
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    elif [ "$2x" == "ros2x" ]; then
        # INPUT STATEMENT 3 VALIDITY CHECK
        declare -A usageState3
        usageState3["unit-test"]="UNIT TEST INDIVIDUAL ALGORITHMS IN ONBOARD ENVIRONMENT"
        usageState3["integration-test"]="INTEGRATION TEST INDIVIDUAL ALGORITHMS IN ONBOARD ENVIRONMENT"
        usageState3["debug"]="RUN ONBOARD ARGUMENT IN DEBUG MODE (sleep infinity)"
        usageState3["build"]="BUILD ONBOARD ARGUMENT"
        usageState3["stop"]="STOP ONBOARD ARGUMENT IF IT IS RUNNING"
        usageState3["*.sh"]="RUN ONBOARD ARGUMENT IN MANUAL MODE (run specific shell script)"

        CheckValidity $0 usageState3 3 "$@"

        if [ "$3x" == "unit-testx" ]; then
            # INPUT STATEMENT 4 VALIDITY CHECK
            declare -A usageState4
            usageState4["path-planning"]="RUNNING PATH PLANNIG UNIT TEST"
            usageState4["path-following"]="RUNNING PATH FOLLOWING UNIT TEST"
            usageState4["collision-avoidance"]="RUNNING COLLISION AVOIDANCE UNIT TEST"

            CheckValidity $0 usageState4 4 "$@"

            if [ "$4x" == "path-planningx" ]; then
                # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
                LimitNumArgument $0 4 "$@"
                SetRunModeROS2 $0 $1 path-planning-unit-test.sh
            elif [ "$4x" == "path-followingx" ]; then
                # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
                LimitNumArgument $0 4 "$@"
                SetRunModeROS2 $0 $1 path-following-unit-test.sh
            elif [ "$4x" == "collision-avoidancex" ]; then
                # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
                LimitNumArgument $0 4 "$@"
                SetRunModeROS2 $0 $1 collision-avoidance-unit-test.sh
            fi
        elif [ "$3x" == "integration-testx" ]; then
            # INPUT STATEMENT 4 VALIDITY CHECK
            declare -A usageState4
            usageState4["pp-pf-integration"]="RUNNING PATH PLANNING AND PATH FOLLOWING INTEGRATION TEST"
            usageState4["pf-ca-integration"]="RUNNING PATH FOLLOWING AND COLLISION AVOIDANCE INTEGRATION TEST"

            CheckValidity $0 usageState4 4 "$@"

            if [ "$4x" == "pp-pf-integrationx" ]; then
                # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
                LimitNumArgument $0 4 "$@"
                SetRunModeROS2 $0 $1 pp-pf-integration-test.sh
            elif [ "$4x" == "pf-ca-integrationx" ]; then
                # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
                LimitNumArgument $0 4 "$@"
                SetRunModeROS2 $0 $1 pf-ca-integration-test.sh
            fi
        elif [ "$3x" == "debugx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeROS2 $0 $1 debug
        elif [ "$3x" == "buildx" ]; then
            # IF ADDITIONAL DIRECTORIES ARE PROVIDED, PASS THEM TO THE BUILD SCRIPT
            if [ $# -ge 4 ]; then
                # DUE TO SED ESCAPE ISSUE, ADDITIONAL ENVIRONMENT VARIABLE IS SET
                TARGET_ROS2_WORKSPACES=${@:4}
                SetRunModeROS2 $0 $1 "build ${TARGET_ROS2_WORKSPACES}"
            # ELSE, RUN THE BUILD SCRIPT. THIS WILL BUILD ALL PACKAGES IN THE ALL DIRECTORIES THAT HAVE NON-EMPTY 'src' SUBDIRECTORY
            else
                SetRunModeROS2 $0 $1 "build"
            fi
        elif [ "$3x" == "stopx" ]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            ${BASE_DIR}/stop.sh $1 $2
            exit 0
        elif [[ "$3x" == *".shx" ]]; then
            # DO NOT ALLOW ADDITIONAL ARGUMENTS FOR THIS ACTION
            LimitNumArgument $0 3 "$@"
            SetRunModeROS2 $0 $1 $3
        fi
        # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    fi
    # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
fi
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

if [ "$1x" == "simx" ]; then
    (cd ${PILS_DEPLOY_DIR} && \
    docker compose -f ${PILS_DEPLOY_DIR}/compose.sim.yml \
        --env-file ./envs/common.env \
        --env-file ./envs/px4.env \
        --env-file ./envs/gazebo-classic.env \
        --env-file ./envs/airsim.env \
        --env-file ./envs/ros2.sim.env \
        --env-file ./envs/qgc.env \
        --profile $2 up)
# ELSE, IT IS AN ONBOARD ARGUMENT
elif [ "$1x" == "onboardx" ]; then
    (cd ${PILS_DEPLOY_DIR} && \
    docker compose -f ${PILS_DEPLOY_DIR}/compose.onboard.yml \
        --env-file ./envs/common.env \
        --env-file ./envs/ros2.onboard.env \
        --env-file ./envs/px4.env \
        --profile $2 up)
fi
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
