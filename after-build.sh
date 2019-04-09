#!/bin/bash

# Strict mode, fail on any error
set -euo pipefail

# Delete the test Cosmos DB database.
az cosmosdb delete -g $RESOURCE_GROUP -n $COSMOSDB_INSTANCE
