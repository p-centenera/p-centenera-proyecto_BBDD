from .sqlUtil import exQuery
from .sqlUtil import exQueryDataframe
import pandas as pd
import matplotlib.pyplot as plt
import datetime
import numpy as np


def _guardar_grafico_sin_datos(ruta_salida, titulo):
    """Genera una imagen simple cuando no hay datos para graficar."""
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.axis('off')
    ax.text(0.5, 0.5, titulo, ha='center', va='center', fontsize=14)
    plt.tight_layout()
    plt.savefig(ruta_salida, bbox_inches='tight', dpi=100)
    plt.close()

def consultaEuribor(mes,anio):
    """Devuelve el valor de Euribor para un mes y año concretos."""
    return exQuery("select valor from euribor where anio="+str(anio)+" and mes="+str(mes))[0][0]

def anios():
    """Obtiene los años disponibles en la tabla euribor para poblar el formulario."""
    result= exQuery("select distinct anio,anio from euribor order by anio")
    
    print ("anios:",result)
    return result

def meses(anio):
    """Obtiene los meses disponibles de un año; si el año no es válido, devuelve lista vacía."""
    try:
        anio_int = int(anio)
    except (TypeError, ValueError):
        return []

    return exQuery(
        "select distinct mes, mes from euribor "
        "where anio=" + str(anio_int) + " order by mes"
    )
def graficoEuribor():
    """Genera un gráfico de barras con toda la serie temporal de Euribor."""
    result_dataFrame=exQueryDataframe( "select mes, anio, valor from euribor;")
    columnas_esperadas = {'mes', 'anio', 'valor'}
    if result_dataFrame.empty or not columnas_esperadas.issubset(result_dataFrame.columns):
        _guardar_grafico_sin_datos('static/euribor.png', 'No hay datos disponibles para Euribor')
        return

    result_dataFrame['datetime'] = result_dataFrame.apply(lambda row : datetime.date(year=int(row['anio']),month=int(row['mes']),day=1), axis=1)
#result_dataFrame['datetime'] = result_dataFrame.apply(lambda row : print(row), axis=1)
    grafico_figura = plt.figure(figsize=(10,5))
    ejes = grafico_figura.add_axes([0,0,1,1])
    ejes.bar(result_dataFrame['datetime'],result_dataFrame['valor'])
    plt.xlabel('Fecha de actualización')
    plt.ylabel('Valor alcanzado')
    plt.tight_layout()
    plt.savefig('static/euribor.png',bbox_inches='tight',dpi=100)
    plt.close()

def graficoEuriborMes():
    """Genera un gráfico tipo stem para visualizar la evolución mensual de Euribor."""
    result_dataFrame=exQueryDataframe( "select mes, anio, valor from euribor;")
    columnas_esperadas = {'mes', 'anio', 'valor'}
    if result_dataFrame.empty or not columnas_esperadas.issubset(result_dataFrame.columns):
        _guardar_grafico_sin_datos('static/euriborMes.png', 'No hay datos disponibles para Euribor mes a mes')
        return

    result_dataFrame['datetime'] = result_dataFrame.apply(lambda row : datetime.date(year=int(row['anio']),month=int(row['mes']),day=1), axis=1)
    plt.style.use('_mpl-gallery')



# plot
#agrandar el eje x
    plt.rcParams['figure.figsize'] = [10, 5]
    #grafico_figura = plt.figure(figsize=(200,50))
 
    fig, ax = plt.subplots()
    ax.stem(result_dataFrame['datetime'], result_dataFrame['valor'])
    plt.xlabel('Fecha')
    plt.ylabel('Valor')
    plt.tight_layout()
    plt.savefig('static/euriborMes.png',bbox_inches='tight',dpi=100)
    plt.close()

