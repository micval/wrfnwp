#!/usr/bin/bash

echo "### "`date`" Starting $0: Global configuration settings"

export GFS_DATA_URL="ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod"
export GFS_TIMESTEP=3
export PROJECTS_DIR=$HOME/projects
export GLOBAL_DATA_DIR=/home/data
export LOCAL_DATA_DIR=$HOME/data
export WRF_VERSION=3.3.1
export WRF_SRC_PATH=/home/met/src/wrf-$VERSION
