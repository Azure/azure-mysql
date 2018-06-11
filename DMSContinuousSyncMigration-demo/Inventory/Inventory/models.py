from Inventory.views import DB
import time

class OrderView(DB.Model):
    __tablename__ = 'order_view'

    id = DB.Column(DB.Integer, primary_key=True)
    name = DB.Column(DB.String(600))
    orderdate = DB.Column(DB.Date)
    quantity = DB.Column(DB.Integer)    

    def __init__(self, name, orderdate, quantity, id = None):
        if(id is not None):
            self.id = id
        self.name = name
        self.orderdate = orderdate
        self.quantity = quantity

class Catalog(DB.Model):
    __tablename__ = 'catalog'
    id = DB.Column(DB.Integer, primary_key=True)
    name = DB.Column(DB.String(600))
    description = DB.Column(DB.String(1000))
    category = DB.Column(DB.String(200))

    def __init__(self, name, description, category, id = None):
        if (id is not None):
            self.id = id
        self.name = name
        self.description = description
        self.category = category

class Order(DB.Model):
    __tablename__ = 'orders'
    id = DB.Column(DB.Integer, primary_key=True)
    catalogid = DB.Column(DB.Integer)
    orderdate = DB.Column(DB.Date)
    quantity = DB.Column(DB.Integer)

    def __init__(self, catalogid, orderdate, quantity, id = None):
        if(id is not None):
            self.id = id
        self.catalogid = catalogid
        self.orderdate = orderdate
        self.quantity = quantity

class Demo:
    def __init__(self, type = None):
        self.type = type