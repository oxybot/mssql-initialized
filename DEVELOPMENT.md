# Development Build

```bash
docker build --tag mssql-initialized .
```

# Development Test 1 - Complete scope

```bash
# Start the container
docker run --name mssql -d -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD=<Secure@Passw0ord> -e MSSQL_DATABASE=test -e MSSQL_USER=test -e MSSQL_PASSWORD=test@Passw0rd mssql-initialized

# Connect to the container
docker exec -it mssql "bash"

# Connect to the database
/opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -d master

# Confirm execution of all setup scripts
USE test;
GO
```

# Development Test 2 - Reduced scope (only database)

```bash
# Start the container
docker run --name mssql -d -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD=<Secure@Passw0ord> -e MSSQL_DATABASE=test -e mssql-initialized

# Connect to the container
docker exec -it mssql "bash"

# Connect to the database
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -d master

# Confirm execution of all setup scripts
USE test;
GO
```
