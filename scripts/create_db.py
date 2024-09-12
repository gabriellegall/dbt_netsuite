# pip install pyodbc
import pyodbc
import time

# Sleep for 15 seconds
time.sleep(15)

# Create the DB if it does not exist
server = 'localhost' 
username = 'sa'
password = 'Strong&Password=94210'

conn_str = (
    f'DRIVER={{ODBC Driver 17 for SQL Server}};'
    f'SERVER={server},1433;'
    f'UID={username};'
    f'PWD={password};'
)

conn = pyodbc.connect(conn_str, autocommit=True)
cursor = conn.cursor()

create_db_query = '''
    IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'netsuite')
    BEGIN
        CREATE DATABASE netsuite;
    END
'''

alter_login_query = f'''
    ALTER LOGIN {username} WITH DEFAULT_LANGUAGE = British;
'''

try:
    cursor.execute(create_db_query)
    conn.commit()
    print("Database created successfully.")
    
    cursor.execute(alter_login_query)
    conn.commit()
    print("Login language set to British successfully.")
    
finally:
    conn.close()