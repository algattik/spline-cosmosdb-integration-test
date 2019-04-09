#!/bin/bash

# Strict mode, fail on any error
set -euo pipefail

# Clone the repository to be tested
git clone --single-branch --branch $GIT_BRANCH https://github.com/algattik/spline.git

# The name of the Cosmos DB instance where tests will be run. Generate a unique name.
COSMOSDB_INSTANCE="$COSMOSDB_NAME_PREFIX$BUILD_BUILDID"

# Set job variable from script, so Cosmos DB can be deleted after build
echo "##vso[task.setvariable variable=COSMOSDB_INSTANCE]$COSMOSDB_INSTANCE"

# Create a Cosmos DB database. This command has no effect if the database already exists.
az cosmosdb create -g $RESOURCE_GROUP -n $COSMOSDB_INSTANCE --kind MongoDB --capabilities EnableAggregationPipeline -o table

# Get the connection string (in mongodb:// format) to the Cosmos DB account.
# The connection string contains the account key.
# Example connection string:
#    mongodb://mycosmosdb:kmRux...XBQ==@mycosmosdb.documents.azure.com:10255/?ssl=true&replicaSet=globaldb
COSMOSDB_CONN_STRING=$(az cosmosdb list-connection-strings -g $RESOURCE_GROUP -n $COSMOSDB_INSTANCE --query connectionStrings[0].connectionString -o tsv)

# Add the database name within the connection string (before the '?' delimiter).
COSMOSDB_CONN_STRING=${COSMOSDB_CONN_STRING/\?/testdb?}

# Set job variable from script, to be used by Maven task
echo "##vso[task.setvariable variable=COSMOSDB_CONN_STRING]$COSMOSDB_CONN_STRING"
