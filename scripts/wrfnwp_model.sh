#!/bin/bash

echo "### "`date`" Starting $0: Model run"

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

