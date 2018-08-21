#!/bin/bash

umask 002

SCRIPT_PATH=`dirname $0`

# load path options
source ${SCRIPT_PATH}/config.sh
source ${SCRIPT_PATH}/functions.sh

# either take the first argument of the script or (if nothing was given) the default branch (develop)
GKN_BRANCH=${1:-$GKN_DEFAULT_BRANCH}
TARGET_DIR=${2:-trunk}

# NGS toolbox variables
NGS_TOOLBOX_REPO=${BUILD_DIR}/external_ngs_toolbox
NGS_TOOLBOX_WFPD=${NGS_TOOLBOX_REPO}/workflow_plugin_dir
NGS_TOOLBOX_TARGET=${REMOTE_TARGET}/${TARGET_DIR}/ngs_toolbox_knime_package

# fetch updates for node generator
git_update ${GKN_SOURCE} ${GKN_BRANCH}

# fetch updates for toolbox
git_update ${NGS_TOOLBOX_REPO} master

# get the qualifier of the ngstoolbox
NGS_TOOLBOX_QUALIFIER=$(git_last_change_date ${NGS_TOOLBOX_REPO})
# get the qualifier of GKN repo
GKN_QUALIFIER=$(git_last_change_date ${GKN_SOURCE})

# replace qualifier 
replace_qualifier_in_file ${NGS_TOOLBOX_WFPD} "plugin.properties" ${NGS_TOOLBOX_QUALIFIER}

# build the plugin source code
pushd ${GKN_SOURCE}

mkdir -p ${NGS_TOOLBOX_TARGET}
mkdir -p ${PLUGIN_BUILD}
rm -rf ${REMOTE_TARGET}/${TARGET_DIR}
mkdir -p ${REMOTE_TARGET}/${TARGET_DIR}

# build external apps
echo "
===================================================
            Building External NGS plugins!....
==================================================="
ant -Dplugin.dir=${NGS_TOOLBOX_WFPD} -Dcustom.plugin.generator.target=${NGS_TOOLBOX_TARGET}

echo "
===================================================
            Building SeqAn plugins!....
==================================================="
ant -Dplugin.dir=${PLUGIN_CENTRAL_PATH} -Dcustom.plugin.generator.target=${PLUGIN_BUILD}

popd

# reset plugin.properties to original/umodifed stat
pushd ${NGS_TOOLBOX_REPO}
git checkout -- `find ${NGS_TOOLBOX_WFPD} -name plugin.properties`
popd

# copy to final, remote-accessible target
rsync -avzO --delete --exclude ".git" ${PLUGIN_BUILD}/ ${REMOTE_TARGET}/${TARGET_DIR}/seqan_knime_package

echo "
===================================================
            Creating Feature Files!....
==================================================="
${SCRIPT_PATH}/create_feature_xml.sh ${GASIC_DEFAULT_BRANCH} ${TARGET_DIR}


chmod -R +775 ${REMOTE_TARGET}/${TARGET_DIR}
