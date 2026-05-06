#!/usr/bin/env bash
set -euo pipefail

# Script para macOS: prepara entorno Django + MySQL (sin crear/importar BD).
# Uso:
#   bash preparar_entorno_macos.sh

MIN_PYTHON_MAJOR=3
MIN_PYTHON_MINOR=10
VENV_DIR=".venv"

log() {
  echo "[INFO] $*"
}

warn() {
  echo "[WARN] $*"
}

err() {
  echo "[ERROR] $*" >&2
}

find_python() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
    return
  fi

  if command -v python >/dev/null 2>&1; then
    echo "python"
    return
  fi

  err "No se encontro Python en PATH. Instala Python 3.10+ e intenta de nuevo."
  err "Sugerencia: brew install python@3.11"
  exit 1
}

PYTHON_CMD="$(find_python)"
log "Python detectado: ${PYTHON_CMD}"

PYTHON_VERSION_OK="$(${PYTHON_CMD} -c 'import sys; print(1 if sys.version_info >= (3, 10) else 0)' 2>/dev/null || echo 0)"
if [ "${PYTHON_VERSION_OK}" != "1" ]; then
  FOUND_VERSION="$(${PYTHON_CMD} -c 'import sys; print(".".join(map(str, sys.version_info[:3])))' 2>/dev/null || echo 'desconocida')"
  err "Version de Python no compatible: ${FOUND_VERSION}. Se requiere Python 3.10 o superior."
  exit 1
fi

FOUND_VERSION="$(${PYTHON_CMD} -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
log "Version de Python compatible: ${FOUND_VERSION}"

if ! ${PYTHON_CMD} -m pip --version >/dev/null 2>&1; then
  warn "pip no disponible en este Python. Intentando instalar con ensurepip..."
  ${PYTHON_CMD} -m ensurepip --upgrade
fi

log "Actualizando pip base..."
${PYTHON_CMD} -m pip install --upgrade pip setuptools wheel

if [ ! -d "${VENV_DIR}" ]; then
  log "Creando entorno virtual en ${VENV_DIR}..."
  ${PYTHON_CMD} -m venv "${VENV_DIR}"
else
  log "El entorno virtual ${VENV_DIR} ya existe. Se reutilizara."
fi

# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"

log "Actualizando herramientas dentro del entorno virtual..."
python -m pip install --upgrade pip setuptools wheel

log "Instalando dependencias del proyecto..."
python -m pip install "Django>=4.1,<5" mysql-connector-python pandas matplotlib

if python -m pip install mysqlclient; then
  log "mysqlclient instalado correctamente."
else
  warn "No se pudo instalar mysqlclient."
  warn "Si usas macOS con Homebrew, prueba antes: brew install mysql-client pkg-config"
  warn "Instalando PyMySQL como alternativa compatible..."
  python -m pip install PyMySQL
  warn "Para usar PyMySQL con Django, agrega en miproyecto_gbd/__init__.py:"
  warn "import pymysql"
  warn "pymysql.install_as_MySQLdb()"
fi

log "Ejecutando chequeo basico de Django..."
if python manage.py check >/dev/null 2>&1; then
  log "Chequeo Django OK."
else
  warn "El chequeo Django devolvio avisos/errores. Revisa DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, DB_PORT."
fi

cat <<EOF

Preparacion completada (sin creacion/importacion de base de datos).

Siguientes pasos:
1) Activa el entorno virtual:
   source .venv/bin/activate

2) Define variables de entorno MySQL si aplica:
   export DB_HOST=localhost
   export DB_PORT=3306
   export DB_NAME=clases_ceu_bc_prof
   export DB_USER=root
   export DB_PASSWORD=

3) Ejecuta el servicio:
   python manage.py runserver

EOF
