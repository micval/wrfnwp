#!/bin/bash

echo "### "`date`" Starting $0: Data postprocessing"

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
