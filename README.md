# Drum-Gear-Rental-ORM
A custom Python ORM project for managing drum gear rentals. Includes core ORM engine, models (Customer, Product, Rental), and test cases for CRUD operations, relationships, and schema enforcement. Built for CSC 675 Database Systems (Summer 2025).

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
