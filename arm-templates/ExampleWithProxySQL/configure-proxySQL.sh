#!/bin/bash

SERVERNAME=$1
MySQLUSERNAME=$2
MySQLUSERLOGINPASSWORD=$3
MONITORINGUSERNAME=$4
MONITORINGLOGINPASSWORD=$5

export DEBIAN_FRONTEND=noninteractive
cd /tmp 
curl -OL  https://github.com/sysown/proxysql/releases/download/v2.0.6/proxysql_2.0.6-ubuntu18_amd64.deb
sudo dpkg -i proxysql_* 
sudo apt-get update
sudo apt-get install mysql-client​
sudo systemctl start proxysql
mysql –u admin –p admin -h127.0.0.1 -P6032
insert into mysql_servers(hostgroup_id,hostname,port,weight,comment) values(1,'$SERVERNAME.mysql.database.azure.com',3306,1,'Write Group');
insert into mysql_servers(hostgroup_id,hostname,port,weight,comment) values(2,'$SERVERNAME-1.mysql.database.azure.com',3306,1,'Read Group');
UPDATE mysql_servers SET use_ssl=1 WHERE hostgroup_id=1; 
UPDATE mysql_servers SET use_ssl=1 WHERE hostgroup_id=2; 
insert into mysql_users(username,password,default_hostgroup,transaction_persistent)values($MySQLUSERNAME,$MySQLUSERLOGINPASSWORD,1,1);
set mysql-monitor_username=$MONITORINGUSERNAME; 
set mysql-monitor_password=$MONITORINGLOGINPASSWORD;
insert into mysql_query_rules(rule_id,active,match_digest,destination_hostgroup,apply)values(1,1,'^SELECT.*FOR UPDATE$',1,1); 
insert into mysql_query_rules(rule_id,active,match_digest,destination_hostgroup,apply)values(2,1,'^SELECT',2,1);
load mysql users to runtime; 
load mysql servers to runtime; 
load mysql query rules to runtime; 
load mysql variables to runtime; 
load admin variables to runtime; 
save mysql users to disk; 
save mysql servers to disk; 
save mysql query rules to disk; 
save mysql variables to disk; 
save admin variables to disk;