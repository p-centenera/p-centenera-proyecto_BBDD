# Proyecto Django: Esqueleto de formulario y gráficas de Euribor

Este repositorio contiene un sitio Django sencillo orientado a:
- mostrar una página de inicio,
- consultar el Euribor por año y mes,
- generar y visualizar dos gráficas (general y mes a mes).

La documentación describe solo los elementos que existen en este proyecto.

## 1. Estructura del proyecto

```text
esqueleto_formulario/
├─ manage.py
├─ db.sqlite3
├─ prototipo.sql
├─ static/
│  ├─ css/
│  │  └─ main.css
│  ├─ euribor.png
│  └─ euriborMes.png
├─ templates/
│  ├─ base.html
│  ├─ home.html
│  ├─ formulario.html
│  ├─ euribor.html
│  ├─ euriborMes.html
│  └─ navbar.html
└─ miproyecto_gbd/
   ├─ __init__.py
   ├─ asgi.py
   ├─ settings.py
   ├─ urls.py
   ├─ views.py
   ├─ forms.py
   ├─ funciones.py
   ├─ sqlUtil.py
   └─ wsgi.py
```

## 2. Archivos principales y responsabilidad

### 2.1 Arranque y configuración
- `manage.py`: comando de entrada para ejecutar el servidor y tareas de Django.
- `miproyecto_gbd/settings.py`: configuración general (templates, estáticos, middleware, etc.).
- `miproyecto_gbd/asgi.py` y `miproyecto_gbd/wsgi.py`: puntos de despliegue ASGI/WSGI.

### 2.2 Enrutado y vistas
- `miproyecto_gbd/urls.py`: define las rutas públicas del sitio:
  - `/` -> `home`
  - `/formulario/` -> formulario de consulta
  - `/formulario/meses/<anio>/` -> endpoint JSON para cargar meses por año
  - `/euribor/` -> gráfica general
  - `/grafica/` -> gráfica mes a mes
- `miproyecto_gbd/views.py`: lógica de cada página y conexión con plantillas.

### 2.3 Formulario
- `miproyecto_gbd/forms.py`:
  - define `ConsultaEuriborForm` con campos `nombre`, `anio` y `mes`.
  - carga años y meses dinámicamente desde base de datos usando funciones auxiliares.

### 2.4 Lógica de datos y gráficas
- `miproyecto_gbd/funciones.py`:
  - consulta del valor Euribor por mes/año,
  - listado de años y meses disponibles,
  - generación de gráficas con Matplotlib,
  - generación de imagen de respaldo cuando no hay datos.
- `miproyecto_gbd/sqlUtil.py`:
  - conexión y ejecución de consultas SQL (`mysql.connector` + `pandas`).

## 3. Plantillas (templates)

- `templates/base.html`: plantilla base común (estructura principal, navbar y bloques).
- `templates/navbar.html`: barra de navegación entre páginas.
- `templates/home.html`: página inicial.
- `templates/formulario.html`: formulario de consulta y script para actualizar meses según año.
- `templates/euribor.html`: muestra la imagen `static/euribor.png`.
- `templates/euriborMes.html`: muestra la imagen `static/euriborMes.png`.

## 4. Flujo funcional de la aplicación

1. El usuario entra en `home`.
2. Desde la navegación va a `Consulta Euribor`.
3. En el formulario:
   - se cargan años disponibles,
   - al cambiar el año, se consulta `/formulario/meses/<anio>/` y se actualiza el selector de meses.
4. Al enviar el formulario, se consulta el valor de Euribor y se muestra el resultado.
5. En las opciones de gráficas:
   - `/euribor/` genera/actualiza la gráfica general,
   - `/grafica/` genera/actualiza la gráfica mensual.

## 5. Archivos estáticos

- `static/css/main.css`: estilos de la web.
- `static/euribor.png` y `static/euriborMes.png`: imágenes generadas por las vistas de gráficas.

## 6. Ejecución local

Con el entorno Python activo:

1. Instalar dependencias de base de datos para Django y consultas:

```bash
pip install mysqlclient mysql-connector-python pandas matplotlib
```

2. Configurar variables de entorno MySQL (PowerShell):

```powershell
$env:DB_HOST="localhost"
$env:DB_PORT="3306"
$env:DB_NAME="clases_ceu_bc_prof"
$env:DB_USER="root"
$env:DB_PASSWORD=""
```

3. Iniciar servidor:

```bash
python manage.py runserver
```

Y abrir en navegador:

- `http://127.0.0.1:8000/`

## 7. Alcance de este proyecto

Este proyecto está documentado tal y como está construido actualmente: rutas, vistas, formularios, utilidades SQL, plantillas y estáticos.
No incluye documentación de componentes que no están presentes en este código.
