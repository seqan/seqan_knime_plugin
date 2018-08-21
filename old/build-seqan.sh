#!/bin/bash
umask 002

SCRIPT_PATH=`dirname $0`

# load path options
source ${SCRIPT_PATH}/config.sh
source ${SCRIPT_PATH}/functions.sh

SEQAN_BRANCH=${1:-$SEQAN_DEFAULT_BRANCH}

# update seqan
git_update $SEQAN_SOURCE $SEQAN_BRANCH

# get the qualifier of SeqAn repo
SEQAN_QUALIFIER=$(git_last_change_date ${SEQAN_SOURCE})

# configure and build seqan 64Bit
echo "
===================================================
            Building SeqAn 64Bit 
==================================================="
# clear old plugin sources
rm -rf $PLUGIN_SOURCE_LOCAL
mkdir -p $PLUGIN_SOURCE_LOCAL

rm -r $SEQAN_BUILD
mkdir -p $SEQAN_BUILD
pushd ${SEQAN_BUILD}

# cmake -DCMAKE_CXX_COMPILER=$CXX_COMPILER -DWORKFLOW_PLUGIN_DIR=$PLUGIN_SOURCE_LOCAL -DSEQAN_STATIC_APPS=ON -DCMAKE_BUILD_TYPE=Release $SEQAN_SOURCE
cmake -DWORKFLOW_PLUGIN_DIR=$PLUGIN_SOURCE_LOCAL -DSEQAN_STATIC_APPS=ON -DCMAKE_BUILD_TYPE=Release $SEQAN_SOURCE

# build seqan
# we use make directly to keep going in case of errors
make prepare_workflow_plugin -k -j 16

popd

# ensure plugin central exists
ssh $PLUGIN_CENTRAL_HOST "mkdir -p ${PLUGIN_CENTRAL_PATH}"

# remove zipped binaries and ctds we have collected them from packages.seqan.de
rm -rf $PLUGIN_SOURCE_LOCAL/payload -rf $PLUGIN_SOURCE_LOCAL/descriptors;

# copy to central assembly location
rsync -avzO $PLUGIN_SOURCE_LOCAL/ $PLUGIN_CENTRAL/

# configure and build seqan 32Bit
echo "
===================================================
            Building SeqAn 32Bit
            Disabled - No Support
==================================================="

# clear old plugin sources
# rm -rf $PLUGIN_SOURCE_LOCAL
# mkdir -p $PLUGIN_SOURCE_LOCAL

# rm -r $SEQAN_BUILD
# mkdir -p $SEQAN_BUILD
# pushd ${SEQAN_BUILD}


#cmake -DCMAKE_CXX_COMPILER=$CXX_COMPILER -DWORKFLOW_PLUGIN_DIR=$PLUGIN_SOURCE_LOCAL -DCMAKE_CXX_FLAGS="$CXX_FLAGS_32" -DCMAKE_EXE_LINKER_FLAGS="$LINKER_FLAGS_32" -DSEQAN_STATIC_APPS=ON -DCMAKE_BUILD_TYPE=Release $SEQAN_SOURCE


# build seqan
# we use make directly to keep going in case of errors
# make prepare_workflow_plugin -k -j 16

# popd

# ensure plugin central exists
# ssh $PLUGIN_CENTRAL_HOST "mkdir -p ${PLUGIN_CENTRAL_PATH}"

# copy to central assembly location
# rsync -avzO $PLUGIN_SOURCE_LOCAL/ $PLUGIN_CENTRAL/
