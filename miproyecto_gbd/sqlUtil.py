import mysql.connector as con
import os
import pandas as pd

def connect():
    """Connect to MySQL database using environment variables."""
    conn = None
    try:
        conn = con.connect(
            host=os.environ.get('DB_HOST', 'localhost'),
            port=int(os.environ.get('DB_PORT', '3306')),
            database=os.environ.get('DB_NAME', 'clases_ceu_bc_prof'),
            user=os.environ.get('DB_USER', 'root'),
            password=os.environ.get('DB_PASSWORD', ''),
            charset='utf8mb4'
        )
        if conn.is_connected():
            print('Connected to MySQL database')
        else:
            print('Connection failed.')

    except Exception as e:
        print("error in connection",e)

 
    return conn

def exQuery (q):
    mydb = None
    try:
        mydb = connect()
        if mydb is None or not mydb.is_connected():
            return []

        print(mydb.is_connected())
        query = q
        mycursor=mydb.cursor()    
        mycursor.execute(query)
        resultado=mycursor.fetchall()
        return resultado
    except Exception as e:
        print('Error ejecutando consulta:', e)
        return []
    finally:
        if mydb is not None and mydb.is_connected():
            mydb.close()

def exQueryDataframe(q):
    mydb = None
    try:
        mydb = connect()
        if mydb is None or not mydb.is_connected():
            return pd.DataFrame()

        result_dataFrame = pd.read_sql(q,mydb)
        return result_dataFrame
    except Exception as e:
        print('Error ejecutando consulta dataframe:', e)
        return pd.DataFrame()
    finally:
        if mydb is not None and mydb.is_connected():
            mydb.close()
