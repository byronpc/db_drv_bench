-----------------------------
mysql-5.7.24-0ubuntu0.16.04.1
-----------------------------

mysql_pool_test:bench(1000000, 8, pool, false). (20 pool size)
### 115116 ms 8695 req/sec

mysql_pool_test:bench(1000000, 16, pool, false). (20 pool size)
### 106428 ms 9433 req/sec

mysql_connection_test:bench(1000000, 8, false).
### 105910 ms 9523 req/sec

mysql_connection_test:bench(1000000, 16, false).
### 99096 ms 10101 req/sec

-----------
psql-9.5.14
-----------
epgsql_test:bench(1000000, 8, false).
### 117262 ms 8547 req/sec

epgsql_test:bench(1000000, 16, false).
### 96482 ms 10416 req/sec

pgapp_test:bench(1000000, 8, false). (20 pool size)
### 178114 ms 5617 req/sec

pgapp_test:bench(1000000, 16, false).
### 167532 ms 5988 req/sec