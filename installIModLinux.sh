#!/bin/bash
# installs iMOD on linux using wine
#
# ensure that wine 32-bit is installed
# wine 32-bit can be installed by executing: ./installWine32Bit.sh

if [ $# -lt 2 ];
then
	echo "Error: insufficient parameters"
	echo "Usage: installIModLinux.sh <iMOD zip file> <Installation Location>"
	echo "Installs iMOD to the specified location"
	exit
fi

zipIMOD="$1"
finstall="$2"
iModInstall="${finstall}/iMOD_exe"

cwd=$( pwd )

if [ ${zipIMOD:0:1} == "/" ];
then
	zipPath="${zipIMOD}"
else
	zipPath="${cwd}/${zipIMOD}"
fi

if [ ! -f "${zipPath}" ];
then
	echo "Error - could not access the iMOD zip at ${zipPath}"
	exit
fi


#create the install location (if it does not exist)
if [ ! -d "${finstall}" ];
then
	mkdir -p "${finstall}"
fi

if [ ! -d "${iModInstall}" ];
then
	mkdir -p "${iModInstall}"
fi


#start up the virtual display
Xvfb :0 -screen 0 1024x768x16 &
export DISPLAY=:0


#set up wine configuration
export WINEPREFIX="${finstall}/iMOD_wine"

if [ ! -d "${WINEPREFIX}" ];
then
	export WINEARCH="win64"
	wineboot
fi

rm -fr "${WINEPREFIX}/dosdevices/z:"
ln -s "${finstall}" "${WINEPREFIX}/dosdevices/z:"


#install iMOD
cd "${iModInstall}"
ln -sf "${zipPath}" iMOD.zip
unzip iMOD.zip

exePath=$( ls -1 `pwd`/iMOD_setup_*.exe )
rm iMOD.zip


echo "N" | wine "${exePath}"


#go back to the original directory
cd ${cwd}

if [ -d "${iModInstall}/bin" ];
then
	echo "iMOD installed successfully in ${iModInstall}"
	mkdir "${iModInstall}/testRuns"
else
	echo "An error occurred on installed iMOD"
fi

