#!/bin/bash
SERVERNAME=$1
MySQLUSERNAME=$2
MySQLUSERLOGINPASSWORD=$3
MONITORINGUSERNAME=$4
MONITORINGLOGINPASSWORD=$5
ADMINISTRATORLOGIN=$6
ADMINISTRATORLOGINPASSWORD=$7
export DEBIAN_FRONTEND=noninteractive
cd /tmp 
curl -OL  https://github.com/sysown/proxysql/releases/download/v2.0.6/proxysql_2.0.6-ubuntu18_amd64.deb
sudo dpkg -i proxysql_* 
sudo apt-get update
sudo apt-get install mysql-client
sudo systemctl start proxysql
cp proxysqldb.sql /tmp/proxysqldb.sql
sed -i -e "s/SERVERNAME/$SERVERNAME/g" -e "s/MONITORINGUSERNAME/$MONITORINGUSERNAME/g" -e "s/MONITORINGLOGINPASSWORD/$MONITORINGLOGINPASSWORD/g" /tmp/proxysqldb.sql
mysql -u admin -padmin -h 127.0.0.1 -P 6032 </tmp/proxysqldb.sql
cp masterdb.sql /tmp/masterdb.sql
sed -i -e "s/MySQLUSERNAME/$MySQLUSERNAME/g" -e "s/MySQLUSERLOGINPASSWORD/$MySQLUSERLOGINPASSWORD/g" -e "s/MONITORINGUSERNAME/$MONITORINGUSERNAME/g" -e "s/MONITORINGLOGINPASSWORD/$MONITORINGLOGINPASSWORD/g" /tmp/masterdb.sql
mysql -h "$SERVERNAME.mysql.database.azure.com" -u "$ADMINISTRATORLOGIN@$SERVERNAME" -p"$ADMINISTRATORLOGINPASSWORD"</tmp/masterdb.sql