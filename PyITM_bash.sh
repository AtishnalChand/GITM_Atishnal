#!/bin/bash

set -e

# Load Python
module purge
module load python3/3.9.2

# Create virtual environment
python3 -m venv --system-site-packages ~/venvs/pyitm-3.9

# Activate environment
source ~/venvs/pyitm-3.9/bin/activate

# Clone PyITM (only if not already cloned)
if [ ! -d "PyITM" ]; then
    git clone https://github.com/GITMCode/PyITM.git
fi

cd PyITM

# Install PyITM
python3 -m pip install --upgrade pip
python3 -m pip install .

# Test installation
python3 -c "import pyitm; print(pyitm.__file__)"

# Load NetCDF dependencies
module load netcdf hdf5

# Install netCDF4 in the same environment
#pip install --no-binary netCDF4 netCDF4

#
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install --no-cache-dir netCDF4

python3 -c "import numpy; print('numpy ok:', numpy.__version__)"
python3 -c "import netCDF4; print('netCDF4 ok:', netCDF4.__version__)"
python3 -c "import pyitm; print('pyitm ok')"

#

# Test netCDF4
python3 -c "import netCDF4; print(netCDF4.__file__)"