```
docker run -p 80:80 \
    -e 'PGADMIN_DEFAULT_EMAIL=micahtmiller@gmail.com' \
    -e 'PGADMIN_DEFAULT_PASSWORD=m1miller' \
    -d dpage/pgadmin4
```

```
./cloud_sql_proxy -instances=sandbox-mtm:us-central1:vorto1=tcp:5432
```

```
psql "dbname=public host=localhost user=micahtmiller password=m1miller port=5432 sslmode=disable"
```