#!/bin/bash

# Configurations
export DLIO_WORKLOAD=scr_megatron_deepspeed
export NUM_NODES=2
export PPN=8
export GENERATE_DATA="0"
export JOB_TIME=60


export GITHUB_WORKSPACE=/usr/workspace/haridev/scr-dlio
export INSTALL_DIR=/usr/workspace/haridev/scr-dlio/venv
export DLIO_DATA_DIR=/p/lustre2/haridev/dlio/scr/dataset/scr_megatron_deepspeed_medium
export DLIO_CHECKPOINT_DIR=/p/lustre2/haridev/dlio/scr/checkpoints/scr_megatron_deepspeed_medium
export SCR_CACHE_DIR=/dev/shm/haridev/scr/checkpoints/scr_megatron_deepspeed #/l/ssd/haridev/scr/checkpoints

# DLIO Profiler Configurations
export DLIO_PROFILER_ENABLE=1
export DLIO_PROFILER_INC_METADATA=1
export DLIO_PROFILER_DATA_DIR=${DLIO_DATA_DIR}:${DLIO_CHECKPOINT_DIR}:${SCR_CACHE_DIR}
export DLIO_PROFILER_LOG_LEVEL=ERROR
export DLIO_PROFILER_BIND_SIGNALS=0
export MV2_BCAST_HWLOC_TOPOLOGY=0

# SCR Configuration
export SCR_CACHE_BASE=${SCR_CACHE_DIR}
export SCR_CACHE_SIZE=16
export SCR_FLUSH_ASYNC=1
export SCR_FLUSH=1
export SCR_FLUSH_TYPE=PTHREAD
export SCR_CACHE_BYPASS=0
export SCR_CACHE_PURGE=1
export SCR_PREFIX=${DLIO_CHECKPOINT_DIR}
#export SCR_DEBUG=1

export CONFIG_ARG="--config-dir=${GITHUB_WORKSPACE}/scr_dlio_benchmark/configs"

mkdir -p $DLIO_DATASET_DIR $DLIO_CHECKPOINT_DIR
source ${GITHUB_WORKSPACE}/scripts/modules.sh
source ${INSTALL_DIR}/bin/activate

# Derived PATHS
export PATH=${PATH}:${INSTALL_DIR}/bin:${INSTALL_DIR}/sbin
export LD_LIBRARY_PATH=${INSTALL_DIR}/lib:${INSTALL_DIR}/lib64:${LD_LIBRARY_PATH}
export PYTHONPATH=${GITHUB_WORKSPACE}:${INSTALL_DIR}/lib/python3.9/site-packages:$PYTHONPATH
echo ${PYTHONPATH}
unset LUA_PATH
unset LUA_CPATH
