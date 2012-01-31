#!/bin/bash

. ./wrf_global_conf.sh

PROJECT=wrfnwp
EXP=wrf_run_cecilia_domain_10km
MY_WORK_DIR=$PROJECTS_DIR/$PROJECT/$EXP
MY_DATA_DIR=$DATA_DIR/$PROJECT/

export PROJECT
export EXP
export MY_WORK_DIR
export MY_DATA_DIR

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

if [ ! -d $DATA_DIR/icbc ]; then
    mkdir -p $DATA_DIR/icbc
fi

cd $DATA_DIR/icbc

today_dir=d.${y}${m}${d}

mkdir $today_dir
cd $today_dir

#. /home/met/bin/gfortran-vars.sh
for ((t=0;t<=48;t+=3))
do
  hour=`printf %02d $t`
  f=gfs.t${h}z.pgrbf${hour}.grib2
  wget $GFS_DATA_URL/gfs.${y}${m}${d}${h}/$f
done

#FIXME

cd ~/data/WRF/WPS

#linky
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
./link_grib.csh /home/met/data/DATA/icbc/gfs.t${h}z

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
 prefix = 'GFS2',
/

&metgrid
 fg_name = 'GFS2'
 io_form_metgrid = 2,
/

EOF_DATE
#konec editace namelist.wps

. /home/met/bin/gfortran-vars.sh
./geogrid.exe
./ungrib.exe
./metgrid.exe

#smazani dat z ungribu
for ((t=0;t<=21;t+=3))
do
  hour=`printf %02d $t`
  rm GFS2:${y}-${m}-${d}_${hour}        
  rm GFS2:${ym}-${mm}-${dm}_${hour}    
done	
  rm GFS2:${ye}-${me}-${de}_00         

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

cd /data/met/WRF/WRFV3/run
#editace namelist.input
cat > namelist.input  <<EOF_DATE
 &time_control
 run_days                            = 0,
 run_hours                           = 48,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = ${y}, ${y}, ${y},
 start_month                         = ${m},   ${m},   ${m},
 start_day                           = ${d},   ${d},   ${d},
 start_hour                          = ${h},   ${h},   ${h},
 start_minute                        = 00,   00,   00,
 start_second                        = 00,   00,   00,
 end_year                            = ${ye}, ${ye}, ${ye},
 end_month                           = ${me},   ${me},   ${me},
 end_day                             = ${de},   ${de},   ${de},
 end_hour                            = ${he},   ${he},   ${he},
 end_minute                          = 00,   00,   00,
 end_second                          = 00,   00,   00,
 interval_seconds                    = 10800
 input_from_file                     = .true.,.true.,.true.,
 history_interval                    = 180,  180,   180,
 frames_per_outfile                  = 1000, 1000, 1000,
 restart                             = .false.,
 restart_interval                    = 5000,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 debug_level                         = 0
 /
 &domains
 time_step                           = 60,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = 1,
 e_we                                = 184,   251,    81,
 e_sn                                = 164,   151,    61,
 e_vert                              = 28,    28,    28,
 p_top_requested                     = 5000,
 num_metgrid_levels                  = 27,
 num_metgrid_soil_levels             = 4,
 dx                                  = 10000, 2000,  12500,
 dy                                  = 10000, 2000,  12500,
 grid_id                             = 1,     2,     3,
 parent_id                           = 0,     1,     2,
 i_parent_start                      = 1,     80,    22,
 j_parent_start                      = 1,     64,    16,
 parent_grid_ratio                   = 1,     5,     2,
 parent_time_step_ratio              = 1,     5,     2,
 feedback                            = 1,
 smooth_option                       = 0
 /

 &physics
 mp_physics                          = 3,     3,     3,
 ra_lw_physics                       = 1,     1,     1,
 ra_sw_physics                       = 1,     1,     1,
 radt                                = 30,    30,    30,
 sf_sfclay_physics                   = 1,     1,     1,
 sf_surface_physics                  = 2,     2,     2,
 bl_pbl_physics                      = 1,     1,     1,
 bldt                                = 0,     0,     0,
 cu_physics                          = 1,     1,     1,
 cudt                                = 5,     5,     5,
 isfflx                              = 1,
 ifsnow                              = 0,
 icloud                              = 1,
 surface_input_source                = 1,
 num_soil_layers                     = 4,
 sf_urban_physics                    = 0,
 maxiens                             = 1,
 maxens                              = 3,
 maxens2                             = 3,
 maxens3                             = 16,
 ensdim                              = 144,
 /

 &fdda
 /

 &dynamics
 w_damping                           = 0,
 diff_opt                            = 1,
 km_opt                              = 4,
 diff_6th_opt                        = 0,      0,      0,
 diff_6th_factor                     = 0.12,   0.12,   0.12,
 base_temp                           = 290.
 damp_opt                            = 0,
 zdamp                               = 5000.,  5000.,  5000.,
 dampcoef                            = 0.2,    0.2,    0.2
 khdif                               = 0,      0,      0,
 kvdif                               = 0,      0,      0,
 non_hydrostatic                     = .false., .true., .true.,
 moist_adv_opt                       = 1,      1,      1,
 scalar_adv_opt                      = 1,      1,      1,
 /

 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4,
 specified                           = .true., .false.,.false.,
 nested                              = .false., .true., .true.,
 /
	
 &grib2
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /
EOF_DATE
#konec editace namelist.input

. /home/met/bin/gfortran-vars.sh
./real.exe

#smazani dat z metgridu
for ((t=0;t<=21;t+=3))
do
  hour=`printf %02d $t`
  rm met_em.d01.${y}-${m}-${d}_${hour}:00:00.nc      
  rm met_em.d01.${ym}-${mm}-${dm}_${hour}:00:00.nc   
#  rm met_em.d02.${y}-${m}-${d}_${hour}:00:00.nc      
#  rm met_em.d02.${ym}-${mm}-${dm}_${hour}:00:00.nc   
#  rm met_em.d03.${y}-${m}-${d}_${hour}:00:00.nc      
#  rm met_em.d03.${ym}-${mm}-${dm}_${hour}:00:00.nc   
done
 rm met_em.d01.${ye}-${me}-${de}_00:00:00.nc         
# rm met_em.d02.${ye}-${me}-${de}_00:00:00.nc         
# rm met_em.d03.${ye}-${me}-${de}_00:00:00.nc         


ulimit -s unlimited
mpirun -n 8 wrf.exe

cd out
mkdir d10.${y}${m}${d}
cd ..
#presun dat z wrf na ARWpost

 mv wrfout_d01_${y}-${m}-${d}_${h}:00:00         /data/met/WRF/ARWpost
# mv wrfout_d02_${y}-${m}-${d}_${h}:00:00         /data/met/WRF/ARWpost
 #mv wrfout_d03_${y}-${m}-${d}_${h}:00:00         /data/met/WRF/ARWpost


cd /data/met/WRF/ARWpost
#editace namelist.ARWpost
cat > namelist.ARWpost <<EOF_DATE
&datetime
 start_date = '${y}-${m}-${d}_${h}:00:00',
 end_date   = '${ye}-${me}-${de}_${he}:00:00',
 interval_seconds = 10800,
 tacc = 0,
 debug_level = 0,
/

&io
 io_form_input  = 2,
 input_root_name = './wrfout_d01_${y}-${m}-${d}_${h}:00:00'
 output_root_name = './out.d01_${h}'
 plot = 'all_list'
 fields = 'height,pressure,tk,tc,slp'
 output_type = 'grads'
 mercator_defs = .true.
/
 split_output = .true.
 frames_per_outfile = 2

 output_type = 'grads'
 output_type = 'v5d'

 plot = 'all'
 plot = 'list'
 plot = 'all_list'
! Below is a list of all available diagnostics
 fields = 'height,geopt,theta,tc,tk,td,td2,rh,rh2,umet,vmet,pressure,u10m,v10m,wdir,wspd,wd10,ws10,slp,mcape,mcin,lcl,lfc,cape,cin,dbz,max_dbz,clfr'


&interp
 interp_method = 1,
 interp_levels = 1000.,950.,900.,850.,800.,750.,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.,
/
 extrapolate = .true.

 interp_method = 1,     ! 0 is model levels, -1 is nice height levels, 1 is user specified pressure/height

 interp_levels = 1000.,950.,900.,850.,800.,750.,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.,
			 interp_levels = 0.25, 0.50, 0.75, 1.00, 2.00, 3.00, 4.00, 5.00, 6.00, 7.00, 8.00, 9.00, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0,

EOF_DATE
#konec editace ARWpost
. /home/met/bin/gfortran-vars.sh
./ARWpost.exe


#presun dat wrf do out
 mv wrfout_d01_${y}-${m}-${d}_${h}:00:00         /data/met/WRF/WRFV3/run/out/d10.${y}${m}${d}
 #mv wrfout_d02_${y}-${m}-${d}_${h}:00:00         /data/met/WRF/WRFV3/run/out/d10.${y}${m}${d}
 #mv wrfout_d03_${y}-${m}-${d}_${h}:00:00         /data/met/WRF/WRFV3/run/out/d.${y}${m}${d}

#tvorba obrazku v gradsu
export GADDIR=/usr/local/grads/data
cd
cd /home/met/data/WRF/ARWpost/scripts
/usr/local/grads/bin/grads -blc 'tat1.gs'
#/usr/local/grads/bin/grads -blc 'tat12.gs'

#ulozeni obrazku
cd /home/met/data/WRF/ARWpost/scripts/obr/10km
mkdir d.${y}${m}${d}
cd /home/met/data/WRF/ARWpost/scripts

for ((t=6;t<=48;t+=6))
do
 #mv 11.2prizemni_tlak_+${t}h.gif obr/2km/d.${y}${m}${d}
 #mv 11.2srazky_+${t}h.gif        obr/2km/d.${y}${m}${d}
 #mv 11.2tc2m_+${t}h.gif          obr/2km/d.${y}${m}${d}
 mv 11prizemni_tlak_+${t}h.gif obr/10km/d.${y}${m}${d}
 mv 11srazky_+${t}h.gif        obr/10km/d.${y}${m}${d}
 mv 11tc2m_+${t}h.gif          obr/10km/d.${y}${m}${d}
 mv 11gp+T.300_+${t}h.gif obr/10km/d.${y}${m}${d}
 mv 11gp+T.500_+${t}h.gif obr/10km/d.${y}${m}${d}
 mv 11gp+T.700_+${t}h.gif obr/10km/d.${y}${m}${d}
 mv 11gp+T.850_+${t}h.gif obr/10km/d.${y}${m}${d}
 mv 11vitr.300_+${t}h.gif obr/10km/d.${y}${m}${d}
 mv 11vitr.500_+${t}h.gif obr/10km/d.${y}${m}${d}
 mv 11vitr.700_+${t}h.gif obr/10km/d.${y}${m}${d}
 mv 11vitr.850_+${t}h.gif obr/10km/d.${y}${m}${d}
done

#presun obrazku na meop0
 cd /home/met/data/WRF/ARWpost/scripts
  ./presun.10km_na_meop0

#end






