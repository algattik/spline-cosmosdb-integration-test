#!/bin/bash

# Strict mode, fail on any error
set -euo pipefail

# Clone the repository to be tested
git clone --single-branch --branch $GIT_BRANCH https://github.com/algattik/spline.git

# The name of the Cosmos DB instance where tests will be run. Generate a unique name.
cosmosdb_instance="$COSMOSDB_NAME_PREFIX$BUILD_BUILDID"
echo $cosmosdb_instance > cosmosdb_instance.txt

# Create a Cosmos DB database. This command has no effect if the database already exists.
az cosmosdb create -g $RESOURCE_GROUP -n $cosmosdb_instance --kind MongoDB --capabilities EnableAggregationPipeline -o table 

# Get the connection string (in mongodb:// format) to the Cosmos DB account.
# The connection string contains the account key.
# Example connection string:
#    mongodb://mycosmosdb:kmRux...XBQ==@mycosmosdb.documents.azure.com:10255/?ssl=true&replicaSet=globaldb
COSMOSDB_CONN_STRING=$(az cosmosdb list-connection-strings -g $RESOURCE_GROUP -n $cosmosdb_instance --query connectionStrings[0].connectionString -o tsv)

# Add the database name within the connection string (before the '?' delimiter).
COSMOSDB_CONN_STRING=${COSMOSDB_CONN_STRING/\?/testdb?}

# Write a settings.xml file for maven to set the test.spline.mongodb.url system property to our connection string.
# The '&' character within $COSMOSDB_CONN_STRING is escaped in order to be XML-safe.
cat << XML > maven_settings.xml 
<?xml version="1.0"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.1.0">
  <profiles>
    <profile>
      <id>inject_cosmosdb_test_url</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <properties>
        <test.spline.mongodb.url>${COSMOSDB_CONN_STRING//&/&amp;}</test.spline.mongodb.url>
      </properties>
    </profile>
  </profiles>
  <activeProfiles>
    <activeProfile>inject_cosmosdb_test_url</activeProfile>
  </activeProfiles>
</settings>
XML
