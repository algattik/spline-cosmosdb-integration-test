#!/bin/bash

# Strict mode, fail on any error
set -euo pipefail

read cosmosdb_instance < cosmosdb_instance.txt

# Delete the test Cosmos DB database.
az cosmosdb delete -g $RESOURCE_GROUP -n $cosmosdb_instance
