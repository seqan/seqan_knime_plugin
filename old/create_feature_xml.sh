#!/bin/bash

umask 002
# get some helper functions
SCRIPT_PATH=`dirname $0`

source ${SCRIPT_PATH}/functions.sh
source ${SCRIPT_PATH}/config.sh

# either take the first argument of the script or (if nothing was given) the default branch (develop)
GASIC_BRANCH=${1:-$GASIC_DEFAULT_BRANCH}
TARGET_DIR=${2:-trunk}


# settings
TARGET_FEATURE_DIR=${REMOTE_TARGET}/${TARGET_DIR}/seqan_ngs_toolbox/de.seqan.seqanngstoolbox
TARGET_TEST_FEATURE_DIR=${REMOTE_TARGET}/${TARGET_DIR}/seqan_ngs_toolbox/de.seqan.seqanngstoolbox.testing.feature
TARGET_FEATURE_XML=${TARGET_FEATURE_DIR}/feature.xml
FEATURE_XML_TEMPLATE=${SCRIPT_PATH}/feature.xml.tmpl
mkdir -p ${TARGET_FEATURE_DIR}

# we include gasic also in our package
GASIC_SOURCE=${BUILD_DIR}/de.seqan.knime.gasic
git_update $GASIC_SOURCE $GASIC_BRANCH


# find suitable qualifier
SEQAN_QUALIFIER=$(git_last_change_date ${SEQAN_SOURCE})
GASIC_QUALIFIER=$(git_last_change_date ${GASIC_SOURCE})
GKN_QUALIFIER=$(git_last_change_date ${GKN_SOURCE})
NGS_QUALIFIER=$(git_last_change_date ${BUILD_DIR}/external_ngs_toolbox)
echo "${BUILD_DIR}/external_ngs_toolbox"
echo "GASiC Qualifier: ${GASIC_QUALIFIER}"
echo "Generic KNIME Node (GKN) Qualifier: ${GKN_QUALIFIER}"
echo "SeqAn repository Qualifier: ${SEQAN_QUALIFIER}"
echo "External NGS toolbox Qualifier: ${NGS_QUALIFIER}"

CHOSEN_QUALIFIER=${SEQAN_QUALIFIER}
CHOSEN_QUALIFIER_NAME="SeqAn repository Qualifier"

if [ "${GASIC_QUALIFIER}" \> "${CHOSEN_QUALIFIER}" ]; then
    CHOSEN_QUALIFIER=${GASIC_QUALIFIER}
    CHOSEN_QUALIFIER_NAME="GASiC Qualifier"
elif [ "${GKN_QUALIFIER}" \> "${CHOSEN_QUALIFIER}" ]; then
    CHOSEN_QUALIFIER=${GKN_QUALIFIER}
    CHOSEN_QUALIFIER_NAME="Generic KNIME Node (GKN) Qualifier"
elif [ "${NGS_QUALIFIER}" \> "${CHOSEN_QUALIFIER}" ]; then
    CHOSEN_QUALIFIER=${NGS_QUALIFIER}
    CHOSEN_QUALIFIER_NAME="External NGS toolbox Qualifier"
fi

echo "The latest Qualifier i.e.,  ${CHOSEN_QUALIFIER_NAME}: ${CHOSEN_QUALIFIER} will be used for the plugin"


cat > ${TARGET_FEATURE_XML} << EOF
<?xml version="1.0" encoding="UTF-8"?>
<feature
      id="de.seqan.seqanngstoolbox"
      label="SeqAn NGS ToolBox"
      version="0.2.0.v${CHOSEN_QUALIFIER}"
      provider-name="Freie Universitaet Berlin">

   <description>
     This feature bundles the SeqAn Nodes and the SeqAn NGS Toolbox.
   </description>

   <copyright>
   Copyright (c) 2006-2014, Knut Reinert, FU Berlin
All rights reserved.

   </copyright>

   <license>
   BSD 3-Clause License

==========================================================================
                SeqAn - The Library for Sequence Analysis
==========================================================================
Copyright (c) 2006-2014, Knut Reinert, FU Berlin
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Knut Reinert or the FU Berlin nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS &quot;AS IS&quot;
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL KNUT REINERT OR THE FU BERLIN BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
DAMAGE.

   </license>

   <includes
         id="de.seqan.feature"
         version="0.0.0"/>

   <includes
         id="de.seqan.ngs_toolbox.feature"
         version="0.0.0"/>


   <includes
         id="de.seqan.knime.gasic.feature"
         version="0.0.0"/>

</feature>
EOF

echo "bin.includes = feature.xml">${TARGET_FEATURE_DIR}/build.properties


# duplicate the feature and build.properties files to the test feature dir  
mkdir -p ${TARGET_TEST_FEATURE_DIR}
cp ${TARGET_FEATURE_DIR}/feature.xml ${TARGET_TEST_FEATURE_DIR}/
cp ${TARGET_FEATURE_DIR}/build.properties ${TARGET_TEST_FEATURE_DIR}/
