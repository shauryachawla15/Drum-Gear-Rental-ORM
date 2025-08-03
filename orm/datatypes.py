# datatypes.py
#
# This file defines the data types used in the ORM framework. Each class represents
# a specific column type that can be used in the database schema. These types
# are then used by the ORM's base class to define columns in database tables.
#
# The `Column` class in the ORM will reference these data types to configure the
# column's behavior, such as validating values, determining the SQL representation,
# and enforcing constraints.
#
# For example,
#   - The `Integer` class represents an INTEGER column type in SQL.
#   - The `String` class represents a TEXT column type with an optional length constraint.
#   - The `Boolean` class represents a BOOLEAN column type.
#
# Students should implement the missing methods for each type (e.g., `get_sql`, `validate`)
# to ensure proper integration with the ORM and the generation of valid SQL queries.
#
# Example usage in the ORM base class:
#
#   class User:
#       id = Column(Integer, primary_key=True)   # An INTEGER primary key column
#       name = Column(String(255), nullable=False)  # A TEXT column with a length of 255, not nullable
#       is_active = Column(Boolean, default=True)  # A BOOLEAN column with a default value of True
#       created_at = Column(Date)  # A DATE column
#
#   This would represent a "User" table with columns: "id", "name", "is_active", and "created_at".
#   The ORM will use the data types (Integer, String, Boolean, Date) to validate values and generate
#   SQL queries when interacting with the database.

class Integer:
    def __init__(self, type="INTEGER"):
        self.type = type

    def validate(self):
        """Validates if the type is a known integer SQL type."""
        return self.type.upper() in ["INTEGER", "INT", "TINYINT", "SMALLINT", "BIGINT"]

    def get_sql(self):
        return self.type.upper()


class String:
    def __init__(self, type='TEXT', length=None):
        self.type = type
        self.length = length

    def validate_length(self):
        """Ensures that the string length is a positive integer if defined."""
        if self.length is None:
            return True
        return isinstance(self.length, int) and self.length > 0

    def get_sql(self):
        """Return the SQL string type, with length if defined (e.g., VARCHAR(255))."""
        if self.length:
            return f"{self.type.upper()}({self.length})"
        return self.type.upper()


class Float:
    def __init__(self, type='FLOAT'):
        self.type = type

    def validate(self):
        """Ensure this is a valid SQL float-compatible type."""
        return self.type.upper() in ["FLOAT", "REAL", "DOUBLE", "DECIMAL"]

    def get_sql(self):
        """Return the SQL representation of this float type."""
        return self.type.upper()


class Boolean:
    def __init__(self):
        self.type = "BOOLEAN"

    def validate(self):
        """Boolean fields should accept only True, False, or None."""
        return self.type.upper() == "BOOLEAN"

    def get_sql(self):
        """Return the SQL BOOLEAN type."""
        return self.type.upper()


class Date:
    def __init__(self, type='DATE'):
        self.type = type

    def validate(self):
        """Check if the type is a valid SQL date/time format."""
        return self.type.upper() in ["DATE", "DATETIME", "TIMESTAMP"]

    def get_sql(self):
        """Return the SQL representation of this date type."""
        return self.type.upper()


class Blob:
    def __init__(self):
        self.type = "BLOB"

    def validate(self):
        """Ensure that the type is specifically BLOB (used for binary data)."""
        return self.type.upper() == "BLOB"

    def get_sql(self):
        """Return the SQL BLOB type."""
        return self.type.upper()
