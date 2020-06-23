# Overview

* Create sql instance
    * deploy.sh
* Import sql dump file
* Create connection using cloud_sql_proxy
* Configure pgadmin4 (docker)
    * Caveat: Since I'm trying to connect to localhost, the connection host is `host.docker.internal`
* Explore data and identify invalid deliveries
    * invalid_deliveries.sql


# pgadmin4

* Pull and run

```
docker pull dpage/pgadmin4:latest
docker run -p 80:80 \
    -e 'PGADMIN_DEFAULT_EMAIL=xxxx@gmail.com' \
    -e 'PGADMIN_DEFAULT_PASSWORD=xxxx' \
    -d dpage/pgadmin4
```

# Cloud SQL Proxy
```
./cloud_sql_proxy -instances=sandbox-mtm:us-central1:vorto1=tcp:5432
```

## Manual connection test
```
psql "dbname=public host=localhost user=xxxx password=xxxx port=5432 sslmode=disable"
```