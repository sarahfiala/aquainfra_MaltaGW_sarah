#!/bin/bash

BASEDIR="/app"
#iModDir="${BASEDIR}/iMOD_exe"
#IMOD_WQ_BIN="${iModDir}/bin/iMOD-WQ_V5_6_1.exe"
#iModLink="${iModDir}/testRuns/MaltaGW_Model"
SEAWATEXE="${BASEDIR}/SEAWAT/swt_v4.exe"

MOD_DIR="${BASEDIR}/model_files/malta_simulation/Malta_Model/malta_sp0/Malta_Model"
NPROCS=1
NAMFILE="Malta_Model.nam_swt"
#OUTPUT_DIR="${BASEDIR}/example_results"

venvDir="${BASEDIR}/venv"

cwd=$( pwd )
#mkdir -p "$OUTPUT_DIR"

#LOGFILE="${OUTPUT_DIR}/run_$(date +%Y%m%d_%H%M%S).log"


#clear the model file
if [ -d ${MOD_DIR} ];
then
	rm -fr ${MOD_DIR}/*
fi


#---------- Prepare the run-time parameters ----------------------
cuser_sealevels=""
csealevel_int=""
cuser_recharge=""

if [ $# -gt 0 ];
then
	cuser_sealevels="--user_sealevels \"$1\""	
fi

if [ $# -gt 1 ];
then
	csealevel_int="--sealevel_int \"$2\""	
fi

if [ $# -gt 2 ];
then
	cuser_recharge="--user_recharge \"$3\""	
fi



#---------- RUN THE PYTHON to prepare the name file ---------------------
source ${venvDir}/bin/activate
echo "Executing the python script to prepare the input file for the GW model"
echo "python3 setupSeaWAT.combined.py ${cuser_sealevels} ${csealevel_int} ${cuser_recharge} "
python3 setupSeaWAT.combined.py ${cuser_sealevels} ${csealevel_int} ${cuser_recharge} 
deactivate
echo "----------------------------"
echo


# --------- RUN THE SEAWAT MODEL ------------- 
echo "Starting SEAWAT ..."
#export WINEPREFIX="${iModDir}/iMOD_wine"
cd ${MOD_DIR}
pwd
echo "wine \"${SEAWATEXE}\" \"${NAMFILE}\""
echo "-------------------------"
wine "${SEAWATEXE}" "${NAMFILE}"
#wine "${SEAWATEXE}" "${NAMFILE}" > "${LOGFILE}" 2>&1
cd ${cwd}



#---------- RUN THE PYTHON to generate the file nc file ---------------------
source ${venvDir}/bin/activate
echo "Executing the python script to convert the SEAWAT run into netcdf"
echo "python3 setupSeaWAT.py ${cuser_sealevels} ${csealevel_int} ${cuser_recharge} "
python3 convertSeaWatOutputToNC.py --ucn ${MOD_DIR}/MT3D001.UCN --dis ${MOD_DIR}/Malta_Model.dis --output /out/salt_flow.nc
deactivate
echo "----------------------------"
echo




EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Simulation for sm_1 completed successfully."
else
    echo "❌ Simulation for sm_1 failed with exit code $EXIT_CODE."
fi

