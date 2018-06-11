import psycopg2 
import time
import getpass
from random import randint
import argparse
import mysql.connector
import sys

parser = argparse.ArgumentParser(description='Description of your program')
parser.add_argument('--platform', help='Database platform. Either mysql or pg (short for PostgreSQL)', required=True)
parser.add_argument('--host', help='Host server', required=True)
parser.add_argument('--database', help='Database', required=True)
parser.add_argument('--user', help='User', required=True)
args = vars(parser.parse_args())

platform = args['platform']
host = args['host']
database = args['database']
user = args['user']
pwd = getpass.getpass()

if platform.lower() == 'pg':
    conn = psycopg2.connect(host=host,database=database, user=user, password=pwd)
    cur = conn.cursor()
elif platform.lower() == 'mysql':
    conn = mysql.connector.connect(host=host,database=database, user=user, password=pwd)
    cur = conn.cursor()
else:
    raise sys.exit("No valid database platform selected. Only mysql and pg supported.")

print("Connected to server. Now querying orders")

for i in range(1,1501):
    time.sleep(5)
    catalogid = randint(1,5)
    quantity = randint(1,5) * 5
    sql = 'SELECT id, orderdate FROM order_view LIMIT 1'
    cur.execute(sql)
    row = cur.fetchone()
    conn.commit()

    if row is not None:
        print("Latest order # " + str(row[0]) + ". Order date - " + str(row[1]))    
    else:
        print("No orders in the database")    

