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

y=$(date '+%Y')
m=$(date '+%m')
d=$(date '+%d')
h=00

ym=$(date --date=1day '+%Y')
mm=$(date --date=1day '+%m')
dm=$(date --date=1day '+%d')
hm=00

ye=$(date --date=2day '+%Y')
me=$(date --date=2day '+%m')
de=$(date --date=2day '+%d')
he=00

. ./wrfnwp_wps.sh

. ./wrfnwp_model.sh

. ./wrfnwp_postproc.sh
