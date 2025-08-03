# models.py
#
# This file is where you define your ORM models. Models represent tables in the database,
# and each instance of a model corresponds to a row in that table.
#
# Models should inherit from the `Base` class, which provides methods for interacting with the database,
# such as saving records, querying, and deleting.
#
# In this file, you will:
#   - Define your own models, from your database schema in this project, by subclassing the `Base` class.
#   - Use `Column` objects to define columns and their types (e.g., `Integer`, `String`).
#   - Add attributes to each model class to represent columns in the corresponding database table.
#   - Define additional methods in the models as necessary for specific functionality (e.g., custom queries,
#     business logic, etc.).
#
#
# Students should implement their own models, specifying the columns using `Column` and selecting the appropriate
# `types` for each column, such as `Integer`, `String`, `Boolean`, etc.
#
# Below you can find two models examples that demonstrate the usage of the base class

from orm.base import Base
from orm.columns import Column
from orm.datatypes import Integer, String, Boolean, Date, Float



# Model: Customer
# Represents a customer who can rent gear.
class Customer(Base):
    id = Column(Integer(), primary_key=True)
    name = Column(String(100), nullable=False)
    email = Column(String(100), unique=True)
    phone = Column(String(15))
    address = Column(String(255))
    is_active = Column(Boolean(), default=True)


# Model: Product
# Represents gear, which is available for rent.
class Product(Base):
    id = Column(Integer(), primary_key=True)
    name = Column(String(100), nullable=False)
    brand = Column(String(50))
    category = Column(String(50))
    price_per_day = Column(Float())
    in_stock = Column(Boolean(), default=True)

# Model: Rental
# Represents a rental transaction between customer and product.
class Rental(Base):
    id = Column(Integer(), primary_key=True)
    customer_id = Column(Integer(), foreign_key="Customer(id)")
    product_id = Column(Integer(), foreign_key="Product(id)")
    rental_date = Column(Date())
    return_date = Column(Date())
    total_price = Column(Float())
