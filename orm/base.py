# base.py
#
# This file defines the `Base` class, which serves as the foundation for all ORM models.
# The `Base` class provides essential methods for interacting with the database, such as:
#   - `save()`: Insert or update the current model instance in the database.
#   - `_insert()`: Insert the current instance into the database (private method).
#   - `_update()`: Update the current instance in the database (private method).
#   - `get()`: Retrieve a record by its ID.
#   - `delete()`: Delete a record by its ID.
#   - `get_all()`: Retrieve all records of the model from the database.
#   - `query()`: Query records based on filter conditions.
#   - `create_table()`: Create a table in the database based on the model's schema.
#   - `create_schema()`: Generate the schema for the model in the database.
#   - `join()`: Join multiple models together for data retrieval.
#   - `where()`: Add WHERE conditions to queries.
#   - `having()`: Add HAVING conditions to queries.
#   - `group_by()`: Add GROUP BY clauses to queries.
#
# Connection management is critical. Every method interacting with the database must:
#   - Open a new connection and cursor at the start of the operation.
#   - Close the cursor and connection after the operation is complete,
#     whether the operation is successful or not, to avoid memory leaks.
#   - Transactions must be committed on success, and rolled back on failure.
#
# Students should implement proper connection management in each method, including:
#   - Using `try`, `except`, and `finally` to ensure the connection and cursor are always closed.
#   - Handling potential exceptions during database operations and performing rollbacks if needed.
#
# Example usage of the Base class:
#
#   class User(Base):
#       def __init__(self, **kwargs):
#           super().__init__(**kwargs)
#           self.name = kwargs.get('name')
#           self.email = kwargs.get('email')
#
#   # Using the `User` model:
#   user = User(name='Alice', email='alice@example.com')
#   user.save()  # Insert or update the user record in the database.
#
#   # Example of using WHERE condition:
#   where_condition = User.where(name="Alice", age=25)
#   query = f"SELECT * FROM users {where_condition}"
#   print(query)  # Output: SELECT * FROM users WHERE name = 'Alice' AND age = 25
#
#   # Example of using GROUP BY:
#   group_by_condition = User.group_by('name')
#   query = f"SELECT name, COUNT(*) FROM users {group_by_condition} HAVING COUNT(*) > 5"
#   print(query)  # Output: SELECT name, COUNT(*) FROM users GROUP BY name HAVING COUNT(*) > 5
#
#   # Example of using HAVING condition:
#   having_condition = User.having(count="orders", condition="> 5")
#   query = f"SELECT * FROM users {having_condition}"
#   print(query)  # Output: SELECT * FROM users HAVING COUNT(orders) > 5
#
# The `Base` class is meant to be subclassed, and any model that extends `Base` will automatically
# inherit the methods for database interaction.


from dbconnectors import MySQL
from columns import Column


class Base:
    def __init__(self, **kwargs):
        # Initialize model instance with attributes.
        self._db = MySQL() # instance of MySQL connector
        for key, value in kwargs.items():
            setattr(self, key, value)


    def save(self):
    # Insert or update the record in the database.
       if hasattr(self, 'id') and self.id is not None:
        self._update()
       else:
        self._insert()

    def _insert(self):
        #Insert the current instance into the database."""
         conn = self._db.connect()
         cursor = conn.cursor()
    try:
        table = self.__class__.__name__.lower()
        fields = []
        values = []
        for attr, val in self.__dict__.items():
            if not attr.startswith('_'):
                fields.append(attr)
                values.append(val)
        columns_str = ", ".join(fields)
        placeholders = ", ".join(["%s"] * len(values))
        sql = f"INSERT INTO {table} ({columns_str}) VALUES ({placeholders})"
        cursor.execute(sql, values)
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"Insert failed: {e}")
    finally:
        cursor.close()
        conn.close()
    

    def _update(self):
        # Update the current instance in the database.
        conn = self._db.connect()
        cursor = conn.cursor()
    try:
        table = self.__class__.__name__.lower()
        fields = []
        values = []
        for attr, val in self.__dict__.items():
            if not attr.startswith('_') and attr != 'id':
                fields.append(f"{attr} = %s")
                values.append(val)
        values.append(self.id)  # for WHERE condition
        sql = f"UPDATE {table} SET {', '.join(fields)} WHERE id = %s"
        cursor.execute(sql, values)
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"Update failed: {e}")
    finally:
        cursor.close()
        conn.close()


    @classmethod
    def get(cls, table, id):
        # Retrieve a record from the database by its ID.
        conn = cls()._db.connect()
        cursor = conn.cursor(dictionary=True)
        try:
            sql = f"SELECT * FROM {table} WHERE id = %s"
            cursor.execute(sql, (id,))
            result = cursor.fetchone()
            return result
        except Exception as e:
            print(f"Get failed: {e}")
        finally:
            cursor.close()
            conn.close()
        


    @classmethod
    def delete(cls, table, id):
        # Delete a record from the database by its ID.

        conn = cls()._db.connect()
        cursor = conn.cursor()
        try:
            sql = f"DELETE FROM {table} WHERE id = %s"
            cursor.execute(sql, (id,))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"Delete failed: {e}")
        finally:
            cursor.close()
            conn.close()


    @classmethod
    def get_all(cls, table=None):
        # Retrieve all records of this model from the database.

        conn = cls()._db.connect()
        cursor = conn.cursor(dictionary=True)
        try:
            if table is None:
                table = cls.__name__.lower()
            sql = f"SELECT * FROM {table}"
            cursor.execute(sql)
            results = cursor.fetchall()
            return results
        except Exception as e:
            print(f"Get all failed: {e}")
        finally:
            cursor.close()
            conn.close()
        

    @classmethod
    def query(cls, **filters):
        # Query records based on filters.

        conn = cls()._db.connect()
        cursor = conn.cursor(dictionary=True)
        try:
            table = cls.__name__.lower()
            conditions = " AND ".join([f"{k} = %s" for k in filters])
            values = tuple(filters.values())
            sql = f"SELECT * FROM {table} WHERE {conditions}"
            cursor.execute(sql, values)
            results = cursor.fetchall()
            return results
        except Exception as e:
            print(f"Query failed: {e}")
        finally:
            cursor.close()
            conn.close()

       

    @classmethod
    def create_table(cls, table_name, schema=None):
        # Create a table for an existing schema.

        conn = cls()._db.connect()
        cursor = conn.cursor()
        try:
            sql = f"CREATE TABLE IF NOT EXISTS {table_name} ({schema})"
            cursor.execute(sql)
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"Create table failed: {e}")
        finally:
            cursor.close()
            conn.close()
        

    @classmethod
    def create_schema(cls, descriptor=None):
        # Generate the schema for the model in the database.

        conn = cls()._db.connect()
        cursor = conn.cursor()
        try:
            sql = f"CREATE SCHEMA IF NOT EXISTS {descriptor}"
            cursor.execute(sql)
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"Create schema failed: {e}")
        finally:
            cursor.close()
            conn.close()
        

    @classmethod
    def join(cls, models):
        #Join multiple models to organize your data.

        conn = cls()._db.connect()
        cursor = conn.cursor(dictionary=True)
        try:
            join_query = " JOIN ".join(models)
            sql = f"SELECT * FROM {join_query}"
            cursor.execute(sql)
            results = cursor.fetchall()
            return results
        except Exception as e:
            print(f"Join failed: {e}")
        finally:
            cursor.close()
            conn.close()
        
@classmethod
def where(cls, **conditions):
    """Add WHERE conditions to a query."""
    return "WHERE " + " AND ".join([f"{k} = '{v}'" for k, v in conditions.items()])

@classmethod
def having(cls, **conditions):
    """Add HAVING conditions to a query."""
    return "HAVING " + " AND ".join([f"COUNT({k}) {v}" for k, v in conditions.items()])

@classmethod
def group_by(cls, *columns):
    """Add GROUP BY clauses to a query."""
    return "GROUP BY " + ", ".join(columns)
