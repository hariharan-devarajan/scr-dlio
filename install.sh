#!/bin/bash

# This script focuses on installing all required components for testing on Corona.

export PROJECT_DIR=$PWD
export SCR_DLIO_INSTALL_DIR=$PROJECT_DIR/venv

echo Cleaning existing environment.
rm -r ${SCR_DLIO_INSTALL_DIR}/*

mkdir -p ${SCR_DLIO_INSTALL_DIR}


module load python/3.9.12

python -m venv ${SCR_DLIO_INSTALL_DIR}

# Install SCR
pushd ${PROJECT_DIR}/dependency/scr
./bootstrap.sh
cd build
cmake -DCMAKE_INSTALL_PREFIX=${SCR_DLIO_INSTALL_DIR} ..
make install
popd

# Install DLIO benchmark
source ${SCR_DLIO_INSTALL_DIR}/bin/activate
pip install -r ${PROJECT_DIR}/requirements.txt


# Install SCR Python Binding
pushd ${PROJECT_DIR}/dependency/scr/python
pip install .
popd
