# EXTRA CREDIT AND OPTIONAL (3 points)
# migrations.py
#
# This file is responsible for managing database migrations. Migrations allow you to manage changes
# to the database schema over time, including creating tables, adding columns, and modifying the schema.
#
# Students are required to implement the following methods to perform migration tasks on the database.
#
# Example migration tasks include:
#   - Creating a new table.
#   - Adding new columns to an existing table.
#   - Removing columns from an existing table.
#   - Renaming columns in a table.
#   - Altering column types or constraints.
#
# Each method should:
#   - Open a connection and cursor to the database.
#   - Ensure the connection and cursor are properly closed after the operation, even in case of errors.
#   - Handle exceptions with appropriate error messages.
#   - Commit the transaction if the operation is successful, and rollback if there is an error.

from dbconnectors import MySQL

class Migrations:

    @classmethod
    def create_table(cls, table_name, schema):
        conn, cursor = None, None
        try:
            conn, cursor = MySQL.get_db_connection()
            query = f"CREATE TABLE {table_name} ({schema});"
            cursor.execute(query)
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            print("Error creating table:", e)
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    @classmethod
    def add_column(cls, table_name, column_name, column_type):
        conn, cursor = None, None
        try:
            conn, cursor = MySQL.get_db_connection()
            query = f"ALTER TABLE {table_name} ADD COLUMN {column_name} {column_type};"
            cursor.execute(query)
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            print("Error adding column:", e)
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    @classmethod
    def remove_column(cls, table_name, column_name):
        conn, cursor = None, None
        try:
            conn, cursor = MySQL.get_db_connection()
            query = f"ALTER TABLE {table_name} DROP COLUMN {column_name};"
            cursor.execute(query)
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            print("Error removing column:", e)
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    @classmethod
    def rename_column(cls, table_name, old_column_name, new_column_name):
        conn, cursor = None, None
        try:
            conn, cursor = MySQL.get_db_connection()
            query = f"ALTER TABLE {table_name} RENAME COLUMN {old_column_name} TO {new_column_name};"
            cursor.execute(query)
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            print("Error renaming column:", e)
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    @classmethod
    def change_column_type(cls, table_name, column_name, new_column_type):
        conn, cursor = None, None
        try:
            conn, cursor = MySQL.get_db_connection()
            query = f"ALTER TABLE {table_name} MODIFY COLUMN {column_name} {new_column_type};"
            cursor.execute(query)
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            print("Error changing column type:", e)
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    @classmethod
    def add_constraint(cls, table_name, constraint_type, column_name, constraint_name):
        conn, cursor = None, None
        try:
            conn, cursor = MySQL.get_db_connection()
            query = f"ALTER TABLE {table_name} ADD CONSTRAINT {constraint_name} {constraint_type} ({column_name});"
            cursor.execute(query)
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            print("Error adding constraint:", e)
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    @classmethod
    def remove_constraint(cls, table_name, constraint_name):
        conn, cursor = None, None
        try:
            conn, cursor = MySQL.get_db_connection()
            query = f"ALTER TABLE {table_name} DROP CONSTRAINT {constraint_name};"
            cursor.execute(query)
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            print("Error removing constraint:", e)
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    @classmethod
    def rename_table(cls, old_table_name, new_table_name):
        conn, cursor = None, None
        try:
            conn, cursor = MySQL.get_db_connection()
            query = f"RENAME TABLE {old_table_name} TO {new_table_name};"
            cursor.execute(query)
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            print("Error renaming table:", e)
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    @classmethod
    def apply_migration(cls, migration_file):
        conn, cursor = None, None
        try:
            conn, cursor = MySQL.get_db_connection()
            with open(migration_file, 'r') as file:
                sql = file.read()
                cursor.execute(sql, multi=True)
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            print("Error applying migration:", e)
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    @classmethod
    def rollback_migration(cls, migration_file):
        conn, cursor = None, None
        try:
            conn, cursor = MySQL.get_db_connection()
            with open(migration_file, 'r') as file:
                sql = file.read()
                cursor.execute(sql, multi=True)
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            print("Error rolling back migration:", e)
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()
