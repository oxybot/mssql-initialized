#!/bin/bash

# Test the environment variables
if [[ -z "$MSSQL_SA_PASSWORD" ]]; then
    >&2 echo "MSSQL_SA_PASSWORD undefined - can't initialize the database"
    exit 1
fi

if [[ -n "$MSSQL_DATABASE" ]]; then
    if [[ -z "$MSSQL_USER" ]] && [[ -n "$MSSQL_PASSWORD" ]]; then
        >&2 echo "MSSQL_USER undefined - can't initialize the database"
        exit 1
    fi
    if [[ -n "$MSSQL_USER" ]] && [[ -z "$MSSQL_PASSWORD" ]]; then
        >&2 echo "MSSQL_PASSWORD undefined - can't initialize the database"
        exit 1
    fi
fi

# Start the script to create the DB and user
./configure-db.sh 2> configure-db.log 1> configure-db.log &

# Start SQL Server
/opt/mssql/bin/sqlservr
