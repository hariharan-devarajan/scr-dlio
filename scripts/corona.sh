#!/bin/bash

source ./setup_env.sh
rm *.core flux.log
rm -rf logs/* profiler/*
flux alloc -t ${JOB_TIME} -q pdebug -N $NUM_NODES --exclusive --broker-opts=--setattr=log-filename=./logs/flux.log ./run.sh
