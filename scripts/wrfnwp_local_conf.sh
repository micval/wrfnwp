#!/bin/bash

echo "### "`date`" Starting $0: Local configuration settings"

export SIMULATION_OFFLINE=0
export SIMULATION_TIMESPAN=48 # simulation timespan in hours
export GLOBAL_MODEL=GFS

# In case of offline simulation set time parameters
if [ "$SIMULATION_OFFLINE" == "1" -o "$SIMULATION_OFFLINE" == "yes" -o "$SIMULATION_OFFLINE" == "true" ]; then
    # fill in required parameters settings
fi
