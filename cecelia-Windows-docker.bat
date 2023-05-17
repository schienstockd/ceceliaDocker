@echo off

:: define conda directory
:: TODO can you get the installation directory?
set CONDA_DIR=%UserProfile%\Miniconda3
set CONDA_BIN=%CONDA_DIR%\condabin

echo ">> START Cecelia"

set CONDA_ENV=r-cecelia-gui-env
set KMP_DUPLICATE_LIB_OK=TRUE

:: run cecelia
%CONDA_BIN%\conda run -n %CONDA_ENV% --no-capture-output python cecelia-docker.py
