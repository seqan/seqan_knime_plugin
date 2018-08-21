#!/bin/bash
umask 002

SCRIPT_PATH=`dirname $0`

# load path options
source ${SCRIPT_PATH}/config.sh

ARCH=${1:-"Mac-x86_64"}
OS_SHORT=${2:-"mac"}
BIT_SIZE=${3:-"64"}
GENERATE_CTD=${4:- ""}

    echo "
===================================================
Gathering $ARCH binaries
==================================================="
mkdir -p ${PLUGIN_BINARIES}/${ARCH}/bin
chmod -R 775 ${PLUGIN_BINARIES}/${ARCH}/bin
for APP in $APPS;do

    echo "
App Name: $APP"
    LATEST_RELEASE=""
    if ls ${PACKAGES_DIR}/${APP}/*${ARCH}.* 1> /dev/null 2>&1; then
    for f in `ls -1v ${PACKAGES_DIR}/${APP}/*${ARCH}.*`;do
        LATEST_RELEASE=$f;
    done
    SPLITED_RELEASE=(${LATEST_RELEASE//-/ })
    RELEASE_PREFIX=${SPLITED_RELEASE[0]};
    RELEASE_VERSION=${SPLITED_RELEASE[1]};
    ZIP_FILE_NAME=${RELEASE_PREFIX}-${RELEASE_VERSION}-${ARCH}.zip
    TAR_FILE_NAME1=${RELEASE_PREFIX}-${RELEASE_VERSION}-${ARCH}.tar.bz2
    TAR_FILE_NAME2=${RELEASE_PREFIX}-${RELEASE_VERSION}-${ARCH}.tar.gz
    TAR_FILE_NAME3=${RELEASE_PREFIX}-${RELEASE_VERSION}-${ARCH}.tar.xz
    echo "The lattes version found was:  v${RELEASE_VERSION}"
    if [ -f ${ZIP_FILE_NAME} ]; then
        echo "extracting ${ZIP_FILE_NAME} to ${PLUGIN_BINARIES}/${ARCH}/."
        unzip -o ${ZIP_FILE_NAME} -d ${PLUGIN_BINARIES}/${ARCH}/
    else
        echo "ZIP file ${ZIP_FILE_NAME} does not exist. Trying with different tarballs"
        if [ -f ${TAR_FILE_NAME1} ]; then
        echo "extracting ${TAR_FILE_NAME1} to ${PLUGIN_BINARIES}/${ARCH}/."
        tar -xf ${TAR_FILE_NAME1} -C ${PLUGIN_BINARIES}/${ARCH}/
        else
        if [ -f ${TAR_FILE_NAME2} ]; then
            echo "extracting ${TAR_FILE_NAME2} to ${PLUGIN_BINARIES}/${ARCH}/."
            tar -xvzf ${TAR_FILE_NAME2} -C ${PLUGIN_BINARIES}/${ARCH}/
        else
        if [ -f ${TAR_FILE_NAME3} ]; then
            echo "extracting ${TAR_FILE_NAME3} to ${PLUGIN_BINARIES}/${ARCH}/."
            tar -xf ${TAR_FILE_NAME3} -C ${PLUGIN_BINARIES}/${ARCH}/
        else
            echo "[ERROR] unable to find tarballs (.bz2 .xz .gz). The KNIME plugin for ${APP} will not work on ${ARCH}"
            continue;
            fi
        fi
        fi
    fi
    mv ${PLUGIN_BINARIES}/${ARCH}/${APP}-${RELEASE_VERSION}-*/bin/* ${PLUGIN_BINARIES}/${ARCH}/bin/;
    rm -rf ${PLUGIN_BINARIES}/${ARCH}/${APP}-${RELEASE_VERSION}-*;
    else
        echo "Nothing found for ${ARCH}. The KNIME plugin for ${APP} will not work on ${ARCH}"
    fi
done
echo "
---------------------------------------------------
Zipping ${ARCH} executables to:
${PLUGIN_CENTRAL_PATH}/payload/binaries_${OS_SHORT}_${BIT_SIZE}.zip
---------------------------------------------------"
pushd ${PLUGIN_BINARIES}/${ARCH}
    zip -r ${PLUGIN_CENTRAL_PATH}/payload/binaries_${OS_SHORT}_${BIT_SIZE}.zip bin
popd

if [ "$GENERATE_CTD" = "ctd" ]; then
    echo "
---------------------------------------------------
Generating CTD files from Linux-x86_64 executables
---------------------------------------------------"
    for executable in ${PLUGIN_BINARIES}/Linux-x86_64/bin/*;do
        executablename=$(basename "$executable")
        eval ${executable} -write-ctd ${PLUGIN_CTDS}/${executablename}.ctd;
        echo "${PLUGIN_CTDS}/${executablename}.ctd"
    done
fi
rm -rf ${PLUGIN_BINARIES}/${ARCH};
