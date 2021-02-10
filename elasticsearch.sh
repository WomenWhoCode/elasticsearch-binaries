#!/bin/bash
# Install a custom ElasticSearch version - https://www.elastic.co/products/elasticsearch
#
# To run this script in Codeship, add the following
# command to your project's test setup command:
# \curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/elasticsearch.sh | bash -s
#
# Add at least the following environment variables to your project configuration
# (otherwise the defaults below will be used).
# * ELASTICSEARCH_VERSION
# * ELASTICSEARCH_PORT
#
# Plugins can be installed by defining the following environment variables:
# * ELASTICSEARCH_PLUGINS="analysis-icu ingest-attachment"
#
ELASTICSEARCH_VERSION=5.4.3
ELASTICSEARCH_PORT=${ELASTICSEARCH_PORT:="9333"}
ELASTICSEARCH_DIR=${ELASTICSEARCH_DIR:="$HOME/el"}
ELASTICSEARCH_PLUGINS=${ELASTICSEARCH_PLUGINS:=""}

# The download location of version 5.x and above, and 2.x follows a different URL structure than 1.x.
# Make sure to use Oracle JDK 8 for Elasticsearch 5.x and above - run the following commands in your setup steps:
# source $HOME/bin/jdk/jdk_switcher
# jdk_switcher home oraclejdk8
# jdk_switcher use oraclejdk8
set -e

ELASTICSEARCH_DL_URL="https://github.com/WomenWhoCode/elasticsearch-binaries/blob/main/elasticsearch-5.4.3.tar.gz?raw=true"
ELASTICSEARCH_PLUGIN_BIN="${ELASTICSEARCH_DIR}/bin/elasticsearch-plugin"

CACHED_DOWNLOAD="${HOME}/cache/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz"

mkdir -p "${ELASTICSEARCH_DIR}"
wget --continue --output-document "${CACHED_DOWNLOAD}" "${ELASTICSEARCH_DL_URL}"
tar -xaf "${CACHED_DOWNLOAD}" --strip-components=1 --directory "${ELASTICSEARCH_DIR}"

echo "http.port: ${ELASTICSEARCH_PORT}" >> ${ELASTICSEARCH_DIR}/config/elasticsearch.yml

if [ "$ELASTICSEARCH_PLUGINS" ]
then
  for i in $ELASTICSEARCH_PLUGINS ; do
    eval "${ELASTICSEARCH_PLUGIN_BIN} install -b ${i}"
  done
fi

# Make sure to use the exact parameters you want for ElasticSearch
bash -c "${ELASTICSEARCH_DIR}/bin/elasticsearch 2>&1 >/dev/null" >/dev/null & disown
wget --retry-connrefused --tries=0 --waitretry=1 -O- -nv http://localhost:${ELASTICSEARCH_PORT}
