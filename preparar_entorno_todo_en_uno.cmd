@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Script CMD todo en uno para Django + MySQL.
REM Incluye: entorno Python, dependencias, creacion de BD e importacion de prototipo.sql.
REM Uso:
REM   preparar_entorno_todo_en_uno.cmd

set "MIN_MAJOR=3"
set "MIN_MINOR=10"
set "VENV_DIR=.venv"
set "SQL_FILE=prototipo.sql"

if "%DB_HOST%"=="" set "DB_HOST=localhost"
if "%DB_PORT%"=="" set "DB_PORT=3306"
if "%DB_NAME%"=="" set "DB_NAME=clases_ceu_bc_prof"
if "%DB_USER%"=="" set "DB_USER=root"
if "%DB_PASSWORD%"=="" set "DB_PASSWORD="

echo [INFO] Iniciando preparacion TODO EN UNO...

REM Detectar Python
set "PYTHON_CMD="
where python >nul 2>nul
if %ERRORLEVEL%==0 (
    set "PYTHON_CMD=python"
) else (
    where py >nul 2>nul
    if %ERRORLEVEL%==0 (
        set "PYTHON_CMD=py -3"
    )
)

if "%PYTHON_CMD%"=="" (
    echo [ERROR] No se encontro Python en PATH. Instala Python 3.10+ e intenta de nuevo.
    exit /b 1
)

echo [INFO] Python detectado: %PYTHON_CMD%

REM Comprobar version minima de Python
for /f "usebackq delims=" %%v in (`%PYTHON_CMD% -c "import sys; print('.'.join(map(str, sys.version_info[:3])))"`) do set "PYVER=%%v"
for /f "tokens=1,2 delims=." %%a in ("%PYVER%") do (
    set "MAJOR=%%a"
    set "MINOR=%%b"
)

if %MAJOR% LSS %MIN_MAJOR% (
    echo [ERROR] Version de Python no compatible: %PYVER%. Se requiere Python 3.10 o superior.
    exit /b 1
)
if %MAJOR% EQU %MIN_MAJOR% if %MINOR% LSS %MIN_MINOR% (
    echo [ERROR] Version de Python no compatible: %PYVER%. Se requiere Python 3.10 o superior.
    exit /b 1
)

echo [INFO] Version de Python compatible: %PYVER%

REM Verificar pip
%PYTHON_CMD% -m pip --version >nul 2>nul
if not %ERRORLEVEL%==0 (
    echo [WARN] pip no disponible. Intentando instalar con ensurepip...
    %PYTHON_CMD% -m ensurepip --upgrade
    if not %ERRORLEVEL%==0 (
        echo [ERROR] No se pudo inicializar pip.
        exit /b 1
    )
)

echo [INFO] Actualizando pip base...
%PYTHON_CMD% -m pip install --upgrade pip setuptools wheel
if not %ERRORLEVEL%==0 (
    echo [ERROR] Fallo al actualizar pip base.
    exit /b 1
)

REM Crear/reutilizar entorno virtual
if exist "%VENV_DIR%\Scripts\python.exe" (
    echo [INFO] El entorno virtual %VENV_DIR% ya existe. Se reutilizara.
) else (
    echo [INFO] Creando entorno virtual en %VENV_DIR%...
    %PYTHON_CMD% -m venv "%VENV_DIR%"
    if not %ERRORLEVEL%==0 (
        echo [ERROR] Fallo al crear el entorno virtual.
        exit /b 1
    )
)

set "VENV_PY=%VENV_DIR%\Scripts\python.exe"
if not exist "%VENV_PY%" (
    echo [ERROR] No se encontro el Python del entorno virtual: %VENV_PY%
    exit /b 1
)

echo [INFO] Actualizando herramientas dentro del entorno virtual...
"%VENV_PY%" -m pip install --upgrade pip setuptools wheel
if not %ERRORLEVEL%==0 (
    echo [ERROR] Fallo al actualizar herramientas dentro del entorno virtual.
    exit /b 1
)

echo [INFO] Instalando dependencias del proyecto...
"%VENV_PY%" -m pip install "Django>=4.1,<5" mysql-connector-python pandas matplotlib
if not %ERRORLEVEL%==0 (
    echo [ERROR] Fallo al instalar dependencias principales.
    exit /b 1
)

echo [INFO] Intentando instalar mysqlclient...
"%VENV_PY%" -m pip install mysqlclient
if %ERRORLEVEL%==0 (
    echo [INFO] mysqlclient instalado correctamente.
) else (
    echo [WARN] No se pudo instalar mysqlclient.
    echo [WARN] Instalando PyMySQL como alternativa compatible...
    "%VENV_PY%" -m pip install PyMySQL
    if not %ERRORLEVEL%==0 (
        echo [ERROR] Fallo al instalar PyMySQL alternativo.
        exit /b 1
    )
    echo [WARN] Para usar PyMySQL con Django, agrega en miproyecto_gbd\__init__.py:
    echo [WARN] import pymysql
    echo [WARN] pymysql.install_as_MySQLdb()
)

REM Preparar importacion MySQL
where mysql >nul 2>nul
if not %ERRORLEVEL%==0 (
    echo [WARN] No se encontro el cliente mysql en PATH.
    echo [WARN] Se omite creacion/importacion de base de datos.
) else (
    if not exist "%SQL_FILE%" (
        echo [WARN] No se encontro %SQL_FILE% en la raiz del proyecto.
        echo [WARN] Se omite importacion SQL.
    ) else (
        echo [INFO] Preparando base de datos MySQL: %DB_NAME%

        set "MYSQL_AUTH=-h %DB_HOST% -P %DB_PORT% -u %DB_USER%"
        if not "%DB_PASSWORD%"=="" set "MYSQL_AUTH=!MYSQL_AUTH! --password=%DB_PASSWORD%"

        mysql !MYSQL_AUTH! -e "CREATE DATABASE IF NOT EXISTS `%DB_NAME%` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
        if not !ERRORLEVEL!==0 (
            echo [ERROR] Fallo al crear/verificar la base de datos %DB_NAME%.
            exit /b 1
        )

        echo [INFO] Importando %SQL_FILE% en la base %DB_NAME%...
        mysql !MYSQL_AUTH! %DB_NAME% < "%SQL_FILE%"
        if not !ERRORLEVEL!==0 (
            echo [ERROR] Fallo al importar %SQL_FILE% en %DB_NAME%.
            exit /b 1
        )

        echo [INFO] Importacion SQL completada.
    )
)

echo [INFO] Ejecutando chequeo basico de Django...
"%VENV_PY%" manage.py check >nul 2>nul
if %ERRORLEVEL%==0 (
    echo [INFO] Chequeo Django OK.
) else (
    echo [WARN] El chequeo Django devolvio avisos/errores. Revisa DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, DB_PORT.
)

echo.
echo Preparacion TODO EN UNO completada.
echo.
echo Siguientes pasos:
echo 1^) Activar entorno virtual:
echo    .\.venv\Scripts\activate
echo.
echo 2^) Si necesitas ajustar variables MySQL:
echo    set DB_HOST=localhost
echo    set DB_PORT=3306
echo    set DB_NAME=clases_ceu_bc_prof
echo    set DB_USER=root
echo    set DB_PASSWORD=
echo.
echo 3^) Arrancar servicio:
echo    python manage.py runserver

exit /b 0
