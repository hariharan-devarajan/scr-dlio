#!/bin/bash

source setup_env.sh

flux run -N $((NUM_NODES)) --tasks-per-node=1 mkdir -p $SCR_CACHE_DIR
flux run -N $((NUM_NODES)) --tasks-per-node=1 rm -rf $SCR_CACHE_DIR/*
flux run -N $((NUM_NODES)) --tasks-per-node=1 mkdir -p $DLIO_CHECKPOINT_DIR
flux run -N $((NUM_NODES)) --tasks-per-node=1 rm -rf $DLIO_CHECKPOINT_DIR/*

if [[ "${GENERATE_DATA}" == "1" ]]; then
# Generate Data for Workload
echo Generating DLIO Dataset
flux submit -N $((NUM_NODES)) --tasks-per-node=$((PPN)) dlio_benchmark ${CONFIG_ARG} workload=${DLIO_WORKLOAD} ++workload.dataset.data_folder=${DLIO_DATA_DIR} ++workload.workflow.generate_data=True ++workload.workflow.train=False
GEN_PID=$(flux job last)
flux job attach ${GEN_PID}
echo "Run with Data Generate 0 for Training"
exit
fi

# Run Training
echo Running DLIO Training for ${DLIO_WORKLOAD}
flux submit -N $((NUM_NODES)) -o cpu-affinity=off -o mpibind=off --tasks-per-node=$((PPN)) dlio_benchmark ${CONFIG_ARG} workload=${DLIO_WORKLOAD} ++workload.dataset.data_folder=${DLIO_DATA_DIR} ++workload.checkpoint.checkpoint_folder=${DLIO_CHECKPOINT_DIR} ++workload.workflow.generate_data=False ++workload.workflow.train=True
RUN_PID=$(flux job last)
flux job attach ${RUN_PID} > ${DYAD_DLIO_RUN_LOG} 2>&1
echo "Finished Executing check ${DYAD_DLIO_RUN_LOG} for output"