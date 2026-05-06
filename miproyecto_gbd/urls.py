from django.urls import path

from . import views

urlpatterns = [
    # Página de inicio de la aplicación.
    path('', views.home, name='home'),
    # Vista con la gráfica general de Euribor.
    path('euribor/', views.euribor, name='euribor'),
    # Formulario de consulta de Euribor por año y mes.
    path('formulario/', views.formularioConsultaEuribor, name='formularioConsultaEuribor'),
    # Endpoint AJAX: devuelve los meses disponibles para el año indicado.
    path('formulario/meses/<int:anio>/', views.mesesPorAnio, name='mesesPorAnio'),
    # Vista con la gráfica de evolución mes a mes.
    path('grafica/', views.grafica, name='grafica')
]