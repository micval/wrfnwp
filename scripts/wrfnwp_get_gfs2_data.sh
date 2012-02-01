#!/bin/bash

if [ "$MY_DATA_DIR" == "" -o "$SIMULATION_TIMESPAN"=="" -o "$GFS_TIMESTEP" == "" -o "$GFS_DATA_URL" == "" ]; then
    echo "### $0 : configuration variables not set - this script must be run from the jobdeck!"
    exit
fi

echo "### "`date`" Starting $0: GFS data download"

if [ ! -d $MY_DATA_DIR/gfs2 ]; then
    mkdir -p $MY_DATA_DIR/gfs2
fi

cd $MY_DATA_DIR/gfs2

today_dir=d.${y}${m}${d}

mkdir $today_dir
cd $today_dir

for ((t=0;t<=$SIMULATION_TIMESPAN;t+=$GFS_TIMESTEP))
do
  hour=`printf %02d $t`
  f=gfs.t${h}z.pgrbf${hour}.grib2
  wget $GFS_DATA_URL/gfs.${y}${m}${d}${h}/$f
done
