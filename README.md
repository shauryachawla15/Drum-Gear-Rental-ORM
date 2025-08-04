# Drum-Gear-Rental-ORM
A custom Python ORM project for managing drum gear rentals. Includes core ORM engine, models (Customer, Product, Rental), and test cases for CRUD operations, relationships, and schema enforcement. Built for CSC 675 Database Systems (Summer 2025) from June 2025- August 2025.

## 📦 Overview
- Models: Customer, Product, Rental
- Custom ORM: supports save(), get_all(), delete(), query(), constraints, and foreign keys
- Lightweight and built for educational use

## 📂 Structure
- `orm/`: core ORM engine (`base.py`, `columns.py`, `datatypes.py`, `migrations.py`)
- `models/`: project models
- `tests.py`: example demo/test script
- `README.md`

## 🧪 Live Demo
To run:
```bash
python tests.py

### 🛠️ Database Setup

To connect to the MySQL database:

1. Ensure MySQL is running locally.
2. Update `dbconnectors.py` with your credentials.
3. Run the schema SQL file:
   ```bash
   mysql -u your_username -p drum_rental_db < drum_rental.sql
