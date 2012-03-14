#!/bin/bash

function print_log_message {
    if [ "$2" == "" ]; then
        level="INFO"
    else
        level=$2
    fi

    echo "### "`printf %5s $level`": "`date`" "$1
}

function check_true_value {
    arg=`echo $1 |tr [:upper:] [:lower:]`
    if [ "$arg" == "1" -o "$arg" == "yes" -o "$arg" == "true" ]; then
        return 0
    else
        return 1
    fi
}

print_log_message "Starting $0: Global configuration settings"

export GFS_DATA_URL="ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod"
export GFS_TIMESTEP=3
export PROJECTS_DIR=$HOME/projects
export GLOBAL_DATA_DIR=/home/data
export LOCAL_DATA_DIR=$HOME/data
export WRF_VERSION=3.3.1
export WRF_SRC_PATH=/home/met/src/wrf-$VERSION
