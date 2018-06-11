"""
Routes and views for the flask application.
"""

from datetime import datetime
from flask import request, render_template
from Inventory import app
from flask_sqlalchemy import SQLAlchemy

"""Setup Alchemy"""
DB = SQLAlchemy(app)

from Inventory.models import *

from flaskext.mysql import MySQL
mysql = MySQL()
host = ""
demo = Demo()

@app.route('/')
@app.route('/home')
def home():
    """Renders the home page."""
    return render_template(
        'index.html',
        title='Home Page'
    )

@app.route('/mysqllogin', methods = ['GET'])
def view_mysqllogin_form():
    return render_template('mysql_login.html')

@app.route('/mysqllogin', methods = ['POST'])
def mysql_login_form():
    host = request.form.get('host')
    user = request.form.get('user')
    password = request.form.get('password')
    app.config['MYSQL_DATABASE_USER'] = user
    app.config['MYSQL_DATABASE_PASSWORD'] = password
    app.config['MYSQL_DATABASE_DB'] = 'inventory'
    app.config['MYSQL_DATABASE_HOST'] = host
    mysql.init_app(app)
    demo.type = "MySQL"
    return render_template('orders_redirect.html')

@app.route('/pgsqllogin', methods = ['GET'])
def view_pgsqllogin_form():
    return render_template('pgsql_login.html')

@app.route('/pgsqllogin', methods = ['POST'])
def pgsql_login_form():
    host = request.form.get('host')
    user = request.form.get('user')
    password = request.form.get('password')
    connString = 'postgresql+psycopg2://{}:{}@{}/{}'.format(user, password, host, 'inventory')
    app.config['SQLALCHEMY_DATABASE_URI'] = connString
    app.config['MYSQL_DATABASE_HOST'] = host
    DB = SQLAlchemy(app)
    demo.type = "PostgreSQL"
    return render_template('orders_redirect.html')

@app.route('/cutover', methods = ['GET'])
def cutover_form():
    if demo.type == "MySQL":
        return view_mysqllogin_form()
    else:
        return view_pgsqllogin_form()

@app.route('/cutover', methods = ['POST'])
def cutover_form_post():
    if demo.type == "MySQL":
        return mysql_login_form()
    else:
        return pgsql_login_form()

@app.route('/orders', methods = ['GET'])
def get_orders_form():
    if demo.type == "MySQL":
        return mysql_getorders(mysql, app.config['MYSQL_DATABASE_HOST'], demo)
    else:
        return pgsql_getorders(app.config['MYSQL_DATABASE_HOST'], demo)

"""MySQL Functions"""
def mysql_getorders(mysql, host, demo):
    connection = mysql.connect()
    cursor = connection.cursor()
    cursor.execute("select o.id, c.name, o.orderdate, o.quantity from orders o, catalog c where o.catalogid = c.id")
    data = cursor.fetchall()
    orders = []
    for item in data:
        order = OrderView(item[1],item[2],item[3],item[0])
        orders.append(order)
    connection.close()
    return render_template(
        'orders.html',
        title='Orders',
        orders = orders,
        host = host,
        demo = demo.type,
    )

"""PostgreSQL Functions"""
def pgsql_getorders(host, demo):
    orders = OrderView.query.all()
    return render_template(
        'orders.html',
        title='Orders',
        orders = orders,
        host = host,
        demo = demo.type
    )