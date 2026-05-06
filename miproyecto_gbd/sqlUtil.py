import mysql.connector as con
import sys
import pandas as pd

def connect():
    print("Connecting to MySQL database")       
    """ Connect to MySQL database """
    conn = None
    try:
        conn = con.connect(host='localhost',
                            database='clases_ceu_bc_prof',
                            user='root',
                            password='')
        if conn.is_connected():
            print('Connected to MySQL database')
        else:
            print('Connection failed.')

    except Exception as e:
        print("error in connection",e)

 
    return conn

def exQuery (q):

    try:
        mydb = connect()
    #Definición de una query de ejemplo
        print(mydb.is_connected())
        query = q
        mycursor=mydb.cursor()    
        mycursor.execute(query)
        #print("query") 
        resultado=mycursor.fetchall()
        mydb.close() 
        return resultado
    except Exception as e:
    #    mydb.close()
        #print('error')
        return []

def exQueryDataframe(q):
    try:
        mydb = connect()
        result_dataFrame = pd.read_sql(q,mydb)
        #print(result_dataFrame)
        mydb.close() 
        return result_dataFrame
    except Exception as e:
        return pd.DataFrame()
