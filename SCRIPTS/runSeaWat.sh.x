#!/bin/bash

if [ $# -gt 0 ];
then
	cuser_sealevels="--user_sealevels \"$1\""
else
	cuser_sealevels=""
fi

if [ $# -gt 1 ];
then
	csealevel_int="--sealevel_int \"$2\""
else
	csealevel_int=""
fi

if [ $# -gt 2 ];
then
	cuser_recharge="--user_recharge \"$3\""
else
	cuser_recharge=""
fi

BASEDIR="/app"
SEAWATEXE="${BASEDIR}/SEAWAT/swt_v4.exe"
#iModDir="${BASEDIR}/iMOD_exe"
#IMOD_WQ_BIN="${iModDir}/bin/iMOD-WQ_V5_6_1.exe"
iModLink="${BASEDIR}/testRuns/MaltaGW_Model"

MOD_DIR="${BASEDIR}/malta_simulation/Malta_Model/malta_sp0"
MOD_FOL="SP_0_to_19999"
NPROCS=1
NAMFILE="SP_0_to_19999.nam_swt"
OUTPUT_DIR="${BASEDIR}/example_results"

venvDir="${BASEDIR}/venv"

cwd=$( pwd )
mkdir -p "$OUTPUT_DIR"

LOGFILE="${OUTPUT_DIR}/run_$(date +%Y%m%d_%H%M%S).log"



#---------- RUN THE PYTHON to prepare the iMOD input file ---------------------
source ${venvDir}/bin/activate
cd ${BASEDIR}/SCRIPTS
echo "Executing the python script to prepare the input file for the GW model"
echo "python3 setup_SeaWat.py ${cuser_sealevels} ${csealevel_int} ${cuser_recharge}"
python3 setup_SeaWat.py ${cuser_sealevels} ${csealevel_int} ${cuser_recharge}
deactivate
echo "----------------------------"
echo



# --------- RUN THE IMOD MODEL ------------- 
if [ -L ${iModLink} ];
then
	rm ${iModLink}
fi

ln -s ${MOD_DIR}/${MOD_FOL} ${iModLink}

echo "Starting iMOD-WQ for sm_1 ..."
export WINEPREFIX="${iModDir}/iMOD_wine"
cd ${iModLink}
pwd
echo "wine \"${IMOD_WQ_BIN}\" \"${NAMFILE}\""
echo "-------------------------"
wine "${IMOD_WQ_BIN}" "${NAMFILE}"
#wine "${IMOD_WQ_BIN}" "${NAMFILE}" > "${LOGFILE}" 2>&1

cd ${cwd}

EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Simulation for sm_1 completed successfully."
else
    echo "❌ Simulation for sm_1 failed with exit code $EXIT_CODE."
fi

