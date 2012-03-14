#!/bin/bash

print_log_message "Starting $0: Local configuration settings"

export SIMULATION_OFFLINE=True
export SIMULATION_TIMESPAN=48 # simulation timespan in hours
export GLOBAL_MODEL=GFS

# In case of offline simulation set time parameters
if check_true_value $SIMULATION_OFFLINE; then
    print_log_message "Setting up offline simulation parameters..."
    # fill in required parameters settings
fi
