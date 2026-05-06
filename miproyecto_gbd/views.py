from audioop import reverse
from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect
from django.http import JsonResponse
from .forms import ConsultaEuriborForm
from .funciones import consultaEuribor
from .funciones import graficoEuribor
from .funciones import graficoEuriborMes
from .funciones import meses
# Create your views here.

def home(request):
    """Muestra la página principal de la aplicación."""
    return render(request, 'home.html')

    
def euribor(request):
    """Genera el gráfico general de Euribor y lo muestra en su plantilla."""
    graficoEuribor()
    return render(request, 'euribor.html')

def formularioConsultaEuribor(request):
    """Gestiona el formulario de consulta de Euribor para GET y POST."""
    # Esta vista gestiona tanto la carga inicial del formulario (GET)
    # como su envío y validación (POST).
    print("formulario",request.method)
    if request.method == "POST":
        # Se recupera el año enviado para reconstruir el formulario
        # con los meses válidos de ese año.
        anio_seleccionado = request.POST.get('anio')
        form = ConsultaEuriborForm(request.POST, anio=anio_seleccionado)
        reponse=render(request, 'formulario.html', {'form': form})
        if form.is_valid():
            # Si el formulario es válido, se leen los datos limpios
            # y se consulta el valor del Euribor para mes/año.
            print ("validado")
            nombre = form.cleaned_data['nombre']
            mes = form.cleaned_data['mes']
            anio = form.cleaned_data['anio']
            
            form.Euribor=consultaEuribor(mes,anio)
            # Se renderiza la misma plantilla mostrando el resultado.
            return render(request, 'formulario.html', {'form': form})
        else:
            # Si hay errores de validación, se redirige a la página del formulario
            # para reiniciar el flujo de entrada de datos.
            print("no validado")
            return HttpResponseRedirect("formulario/")
    else:
        # En GET se crea un formulario vacío con años y meses iniciales.
        print("get")
        form = ConsultaEuriborForm()
        return render(request, 'formulario.html', {'form': form})


def mesesPorAnio(request, anio):
    """Devuelve por JSON los meses disponibles para el año indicado."""
    meses_disponibles = meses(anio)
    return JsonResponse({'meses': meses_disponibles})

def grafica(request):
    """Genera y muestra el gráfico mensual de Euribor."""
    graficoEuriborMes()
    return render(request, 'euriborMes.html')

    
 
       
