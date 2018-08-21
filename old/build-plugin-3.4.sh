#!/bin/bash

pushd `dirname $0` > /dev/null
SCRIPT_PATH=`pwd`
popd > /dev/null

DATE_TIME=$(date "+%Y.%m.%d-%H.%M.%S")

PLUGIN_BUILD_LOG_PATH=${SCRIPT_PATH}/log-files/${DATE_TIME}.log;

${SCRIPT_PATH}/collect_binaries.sh Linux-x86_64 lnx 64 ctd &>>${PLUGIN_BUILD_LOG_PATH};
${SCRIPT_PATH}/collect_binaries.sh Mac-x86_64 mac 64 &>>${PLUGIN_BUILD_LOG_PATH};
${SCRIPT_PATH}/collect_binaries.sh Windows-x86_64 win 64 &>>${PLUGIN_BUILD_LOG_PATH};

${SCRIPT_PATH}/build-seqan.sh seqan-v2.3.2 &>>${PLUGIN_BUILD_LOG_PATH};

${SCRIPT_PATH}/build-plugin.sh develop 3.4 &>>${PLUGIN_BUILD_LOG_PATH};
