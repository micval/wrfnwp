#!/bin/bash -x

. ./wrfnwp_global_conf.sh
. ./wrfnwp_local_conf.sh

PROJECT=wrfnwp
EXP=daily_run_cecilia_domain_10km
MY_WORK_DIR=$PROJECTS_DIR/$PROJECT/$EXP
MY_DATA_DIR=$LOCAL_DATA_DIR/$PROJECT/

export PROJECT
export EXP
export MY_WORK_DIR
export MY_DATA_DIR

print_log_message "Starting job $0: $PROJECT $EXP run"

. ./wrfnwp_wps.sh

. ./wrfnwp_model.sh

. ./wrfnwp_postproc.sh
