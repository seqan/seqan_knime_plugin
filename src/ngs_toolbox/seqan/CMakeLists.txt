# ============================================================================
#                  SeqAn - The Library for Sequence Analysis
# ============================================================================
#
# Copyright (c) 2006-2018, Knut Reinert & Freie Universitaet Berlin
# Copyright (c) 2016-2018, Knut Reinert & MPI Molekulare Genetik
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Knut Reinert or the FU Berlin nor the names of
#       its contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL KNUT REINERT OR THE FU BERLIN BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.
# ============================================================================

set (PLUGIN_CATEGORY_GROUP "SeqAn")

get_filename_component (plugin_build_subdir "${CMAKE_CURRENT_LIST_DIR}" NAME)

set (plugin_build_dir_cache "${plugin_build_dir}")
set (plugin_build_dir "${plugin_build_dir}/${plugin_build_subdir}")

file (COPY ${CMAKE_SOURCE_DIR}/../plugins/seqan_dll_provider/ DESTINATION ${plugin_build_dir})

set (PLUGIN_DEPENDENCY "de.seqan.gkn.dll_provider;bundle-version=\\\"0.0.1\\\"" CACHE INTERNAL "Adds dependecies to a generated GKN plugin" FORCE)
set (PLUGIN_EXECUTOR "SeqAnToolExecutor" CACHE INTERNAL "Sets the tool executor for the plugin" FORCE)
set (PLUGIN_DLL_HOST "de.seqan.gkn.dll_provider")

# First parse all plugins to be included.
add_subdirectories()

set (FEATURE_VERSION_MAJOR "3")
set (FEATURE_VERSION_MINOR "0")
set (FEATURE_VERSION_PATCH "0")

add_feature("SeqAn" "de.seqan.dynamic.feature" "description" "copyright" "license")

set (plugin_build_dir "${plugin_build_dir_cache}")

unset (plugin_build_dir_cache)
unset (plugin_build_subdir)
# Reset.
set (PLUGIN_DEPENDENCY "" CACHE INTERNAL "Adds dependecies to a generated GKN plugin" FORCE)
set(PLUGIN_EXECUTOR "LocalToolExecutor" CACHE INTERNAL "Sets the tool executor for the plugin" FORCE)
