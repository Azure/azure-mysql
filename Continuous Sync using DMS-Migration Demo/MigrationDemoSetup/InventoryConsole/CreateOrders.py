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
    returnclause = 'RETURNING id'
elif platform.lower() == 'mysql':
    conn = mysql.connector.connect(host=host,database=database, user=user, password=pwd)
    cur = conn.cursor()
    returnclause = ''
else:
    raise sys.exit("No valid database platform selected")

print("Connected to server. Now creating new orders")

for i in range(1,1501):
    time.sleep(5)
    catalogid = randint(1,5)
    quantity = randint(1,5) * 5
    sql = 'INSERT INTO orders (catalogid, quantity) values ({0},{1}){2}'.format(catalogid, quantity, returnclause)
    cur.execute(sql)
    if platform.lower() == 'pg':
        id = cur.fetchone()[0]
        conn.commit()
    elif platform.lower() == 'mysql':
        conn.commit()
        qsql = 'SELECT max(id) from orders'
        cur.execute(qsql)
        row = cur.fetchone()
        id = row[0]
    else:
        id = 0

    print("Created order # " + str(id))    
