#!/bin/bash

# Wait 60 seconds for SQL Server to start up by ensuring that 
# calling SQLCMD does not return an error code, which will ensure that sqlcmd is accessible
# and that system and user databases return "0" which means all databases are in an "online" state
# https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-databases-transact-sql?view=sql-server-2017 

DBSTATUS=1
ERRCODE=1
i=0

echo "Starting configure-db script"

while [[ $i -lt 60 ]] && [[ $ERRCODE -ne 0 ]]; do
	i=$((i+1))
	DBSTATUS=$(/opt/mssql-tools/bin/sqlcmd -h -1 -t 1 -U SA -P $MSSQL_SA_PASSWORD -Q "SET NOCOUNT ON; Select SUM(state) from sys.databases")
	ERRCODE=$?
	sleep 1
done

if [[ $ERRCODE -ne 0 ]]; then 
	echo "SQL Server took more than 60 seconds to start up or one or more databases are not in an ONLINE state"
	exit 1
fi

# Run the setup scripts to create the DB and the schema in the DB
if [[ -n "$MSSQL_DATABASE" ]]; then
	# Create the database
	/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -d master -i setup-db.sql \
		-v MSSQL_DATABASE=$MSSQL_DATABASE

	if [[ -n "$MSSQL_USER" ]]; then
		# Create the user
		/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -d $MSSQL_DATABASE -i setup-user.sql \
			-v MSSQL_DATABASE=$MSSQL_DATABASE \
			-v MSSQL_USER=$MSSQL_USER \
			-v MSSQL_PASSWORD=$MSSQL_PASSWORD

		# Finalize the setup as the dedicated user
		/opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -d $MSSQL_DATABASE -i init.sql
	fi

	# Finalize the setup as the System Administrator
	/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -d master -i init-sa.sql \
		-v MSSQL_DATABASE=$MSSQL_DATABASE \
		-v MSSQL_USER=$MSSQL_USER
fi

echo "Ending configure-db script"
