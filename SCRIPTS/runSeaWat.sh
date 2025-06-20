#!/bin/bash

BASEDIR="/app"
iModDir="${BASEDIR}/iMOD_exe"
IMOD_WQ_BIN="${iModDir}/bin/iMOD-WQ_V5_6_1.exe"
iModLink="${iModDir}/testRuns/MaltaGW_Model"

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



#---------- RUN THE PYTHON to prepare the iMOD input file ---------------------
source ${venvDir}/bin/activate
echo "Executing the python script to prepare the input file for the GW model"
echo "python3 setupSeaWAT.py ${cuser_sealevels} ${csealevel_int} ${cuser_recharge} "
python3 setupSeaWAT.py ${cuser_sealevels} ${csealevel_int} ${cuser_recharge} 
deactivate
echo "----------------------------"
echo


# --------- RUN THE IMOD MODEL ------------- 
echo "Starting iMOD-WQ for sm_1 ..."
export WINEPREFIX="${iModDir}/iMOD_wine"
cd ${MOD_DIR}
pwd
echo "wine \"${IMOD_WQ_BIN}\" \"${NAMFILE}\""
echo "-------------------------"
wine "${IMOD_WQ_BIN}" "${NAMFILE}"
#wine "${IMOD_WQ_BIN}" "${NAMFILE}" > "${LOGFILE}" 2>&1

echo
echo "Copying the output"
ofpath="${MOD_DIR}/concvelo.tec"
if [ -f ${ofpath} ];
then
	echo "mv -f ${ofpath} /out/salt_flow.tec"
	mv -f ${ofpath} /out/salt_flow.tec
fi


cd ${cwd}

EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Simulation for sm_1 completed successfully."
else
    echo "❌ Simulation for sm_1 failed with exit code $EXIT_CODE."
fi

