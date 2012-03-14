#!/bin/bash

if [ "$MY_WORK_DIR" == "" ]; then
    echo "### $0 : configuration variables not set - this script must be run from the jobdeck!"
    exit
fi

print_log_message "Starting $0: Data preprocessing"

if [ ! -d $MY_WORK_DIR/wps ]; then
    mkdir -p $MY_WORK_DIR/wps
    cp -Rd $WRF_SRC_PATH/WPS/* $MY_WORK_DIR/wps
fi

cd $MY_WORK_DIR/wps

ln -sf $WRF_SRC_PATH/WPS/ungrib/Variable_Tables/Vtable.$GLOBAL_MODEL Vtable

today_dir=d.${y}${m}${d}

./link_grib.csh $MY_DATA_DIR/$today_dir/gfs.t${h}z*.grib2

#editace namelist.wps
cat > namelist.wps  <<EOF_DATE
&share
 wrf_core = 'ARW',
 max_dom = 1,
 start_date = '${y}-${m}-${d}_${h}:00:00','${y}-${m}-${d}_${h}:00:00','${y}-${m}-${d}_${h}:00:00',
 end_date   = '${ye}-${me}-${de}_${he}:00:00','${ye}-${me}-${de}_${he}:00:00','${ye}-${me}-${de}_${he}:00:00',
 interval_seconds = 10800
 io_form_geogrid = 2,
/

&geogrid
 parent_id         =   1,   1,   2,
 parent_grid_ratio =   1,   5,   2,
 i_parent_start    =   1,  80,  22,
 j_parent_start    =   1,  64,  16,
 e_we              = 184,  251,  81,
 e_sn              = 164,  151,  61,
 geog_data_res     = '10m','2m','2m',
 dx = 10000,
 dy = 10000,
 map_proj = 'lambert',
 ref_lat   =  49.00,
 ref_lon   =  15.80,
 truelat1  =  45.0,
 truelat2  =  52.0,
 stand_lon =  15.8,
 geog_data_path = '/data/met/DATA/geog'
/

&ungrib
 out_format = 'WPS',
 prefix = '$GLOBAL_MODEL',
/

&metgrid
 fg_name = '$GLOBAL_MODEL'
 io_form_metgrid = 2,
/

EOF_DATE

./geogrid.exe
./ungrib.exe
./metgrid.exe


# Remove temporary files from ungrib
rm $GLOBAL_MODEL:*

#premisteni dat z metgridu
for ((t=0;t<=21;t+=3))
do
  hour=`printf %02d $t`
  mv met_em.d01.${y}-${m}-${d}_${hour}:00:00.nc       /data/met/WRF/WRFV3/run
  mv met_em.d01.${ym}-${mm}-${dm}_${hour}:00:00.nc    /data/met/WRF/WRFV3/run   
 # mv met_em.d02.${y}-${m}-${d}_${hour}:00:00.nc       /data/met/WRF/WRFV3/run
 # mv met_em.d02.${ym}-${mm}-${dm}_${hour}:00:00.nc    /data/met/WRF/WRFV3/run
 # mv met_em.d03.${y}-${m}-${d}_${hour}:00:00.nc       /data/met/WRF/WRFV3/run
 # mv met_em.d03.${ym}-${mm}-${dm}_${hour}:00:00.nc    /data/met/WRF/WRFV3/run
done
  mv met_em.d01.${ye}-${me}-${de}_00:00:00.nc         /data/met/WRF/WRFV3/run
 # mv met_em.d02.${ye}-${me}-${de}_00:00:00.nc         /data/met/WRF/WRFV3/run
 # mv met_em.d03.${ye}-${me}-${de}_00:00:00.nc         /data/met/WRF/WRFV3/run

#schovani nactenych dat
cd ~/data/DATA/icbc
for ((t=0;t<=48;t+=3))
do 
  hour=`printf %02d $t`	 
  mv gfs.t${h}z.pgrbf${hour}.grib2 d.${y}${m}${d}
done
