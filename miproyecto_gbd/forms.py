from django import forms
from .funciones import anios, meses


class ConsultaEuriborForm(forms.Form):
    nombre = forms.CharField(label='Nombre: ', max_length=40)
    anio = forms.ChoiceField(label='Año: ', choices=[])
    mes = forms.ChoiceField(label='Mes: ', choices=[])

    def __init__(self, *args, **kwargs):
        anio_seleccionado = kwargs.pop('anio', None)
        super().__init__(*args, **kwargs)

        anios_disponibles = anios()
        self.fields['anio'].choices = anios_disponibles

        if not anio_seleccionado and anios_disponibles:
            anio_seleccionado = anios_disponibles[0][0]

        self.fields['mes'].choices = meses(anio_seleccionado)
