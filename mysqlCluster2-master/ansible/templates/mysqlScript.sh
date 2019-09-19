#!/bin/bash
mysql -u root  -e STATUS
mysql <<EOFMYSQL
use mysql;
select user, host from mysql.user;

alter user 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'passw0rd';

reset master;
EOFMYSQL

