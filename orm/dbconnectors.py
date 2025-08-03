import mysql.connector

# This module provides a basic MySQL connector to establish a connection and get a cursor.
# It is designed to be used as the database backend for the ORM project.
#
# Example usage:
#     from dbconnectors import MySQL
#     conn, cur = MySQL.get_db_connection()
#     cur.execute("SELECT * FROM users")
#     results = cur.fetchall()
#     for row in results:
#        print(row)
#     conn.close()
#
# IMPORTANT:
# While this implementation only supports MySQL, it is structured so that other relational
# database connectors (e.g., PostgreSQL, SQLite) can be added in the future with minimal changes.
# Students do NOT need to implement support for other databases for this project.
# They may use the MySQL connector provided here as-is.

class MySQL:
    @staticmethod
    def get_db_connection():
        """
        Establishes and returns a connection and cursor to a MySQL database.

        Returns:
            tuple: (connection, cursor) where:
                - connection is mysql.connector connection object
                - cursor is a cursor object to execute SQL queries

        Raises:
            mysql.connector.Error: If there is an error during connection
        """
        connection = mysql.connector.connect(
            host="localhost",         # Host where the MySQL server is running
            user="root",              # Username for the database
            password="password",      # Password for the user
            database="your_database"  # Name of the database to connect to
        )
        cursor = connection.cursor()
        return connection, cursor


