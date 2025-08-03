# test.py
#
# This file is meant for testing the functionality of the models you define in models.py.
# Use it as a sandbox to manually verify that your model classes and their methods work correctly.
#
# Suggested tests include:
#   - Creating, updating, and deleting records
#   - Querying and retrieving data
#   - Retrieving data using filters such as having and where
#   - Applying group_by and order_by for data retrieved
#   - Testing relationships between models (e.g., foreign keys, joins)
#   - OPTIONAL AND EXTRA CREDIT ONLY: test your migrations properly
#
# Guidelines:
#   - Import your model classes from models.py
#   - Use the database connector provided (e.g., from db.py) to connect to your test database
#   - Clean up test data between runs if needed
#
# NOTE: This is not a formal unit test file. You are encouraged to add and run meaningful tests
# here as you build your ORM functionality.

from models.models import Customer, Product, Rental

# --- CREATE ---
cust1 = Customer(name="Shaurya", email="shaurya@example.com", phone="9999999999", address="Delhi")
cust1.save()


# Creating a product to rent, like drums hardware stands.
prod1 = Product(name="TAMA Hi-Hat Stand", brand="TAMA", category="Cymbal Stand", price_per_day=250.0)
prod1.save()


# Creating a rental linking customer and product.
rental1 = Rental(customer_id=cust1.id, product_id=prod1.id, rental_date="2025-07-30", return_date="2025-08-01", total_price=500.0)
rental1.save()

# READ
all_customers = Customer.get_all()
for c in all_customers:
    print(f"Customer: {c.name} | Email: {c.email}")

# UPDATE: Changing customer phone number and saving it.
cust1.phone = "8888888888"
cust1.save()

# DELETE
Rental.delete(id=rental1.id)
