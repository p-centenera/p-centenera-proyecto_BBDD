#!/usr/bin/env bash
set -euo pipefail

# Script todo en uno para este proyecto Django + MySQL.
# Hace lo siguiente:
# 1) Verifica Python 3.10+
# 2) Prepara .venv
# 3) Instala dependencias
# 4) Crea base de datos MySQL si no existe
# 5) Importa prototipo.sql
# 6) Ejecuta check de Django
#
# Uso:
#   bash preparar_entorno_todo_en_uno.sh
#
# Variables opcionales:
#   DB_HOST=localhost
#   DB_PORT=3306
#   DB_NAME=clases_ceu_bc_prof
#   DB_USER=root
#   DB_PASSWORD=

MIN_PYTHON_MAJOR=3
MIN_PYTHON_MINOR=10
VENV_DIR=".venv"
SQL_FILE="prototipo.sql"

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-clases_ceu_bc_prof}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"

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

  if command -v py >/dev/null 2>&1; then
    echo "py -3"
    return
  fi

  err "No se encontro Python en PATH. Instala Python 3.10+ e intenta de nuevo."
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
source "${VENV_DIR}/Scripts/activate" 2>/dev/null || source "${VENV_DIR}/bin/activate"

log "Actualizando herramientas dentro del entorno virtual..."
python -m pip install --upgrade pip setuptools wheel

log "Instalando dependencias del proyecto..."
python -m pip install "Django>=4.1,<5" mysql-connector-python pandas matplotlib

if python -m pip install mysqlclient; then
  log "mysqlclient instalado correctamente."
else
  warn "No se pudo instalar mysqlclient (puede requerir librerias de compilacion/sistema)."
  warn "Instalando PyMySQL como alternativa compatible..."
  python -m pip install PyMySQL
  warn "Para usar PyMySQL con Django, agrega estas lineas en miproyecto_gbd/__init__.py:"
  warn "import pymysql"
  warn "pymysql.install_as_MySQLdb()"
fi

if ! command -v mysql >/dev/null 2>&1; then
  warn "No se encontro el cliente mysql en PATH."
  warn "Se omite creacion/importacion de la base. Instala mysql client y relanza este script."
else
  if [ ! -f "${SQL_FILE}" ]; then
    warn "No se encontro ${SQL_FILE} en la raiz del proyecto. Se omite importacion SQL."
  else
    log "Preparando base de datos MySQL: ${DB_NAME}"

    MYSQL_ARGS=("-h" "${DB_HOST}" "-P" "${DB_PORT}" "-u" "${DB_USER}")
    if [ -n "${DB_PASSWORD}" ]; then
      MYSQL_ARGS+=("--password=${DB_PASSWORD}")
    fi

    mysql "${MYSQL_ARGS[@]}" -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

    log "Importando ${SQL_FILE} en la base ${DB_NAME}"
    mysql "${MYSQL_ARGS[@]}" "${DB_NAME}" < "${SQL_FILE}"

    log "Importacion SQL completada."
  fi
fi

log "Ejecutando chequeo basico de Django..."
if python manage.py check >/dev/null 2>&1; then
  log "Chequeo Django OK."
else
  warn "El chequeo Django devolvio avisos/errores. Revisa DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, DB_PORT."
fi

cat <<EOF

Preparacion todo en uno completada.

Siguientes pasos:
1) Activa el entorno virtual:
   - Linux/macOS: source .venv/bin/activate
   - Git Bash (Windows): source .venv/Scripts/activate

2) Si necesitas ajustar credenciales para ejecucion:
   export DB_HOST="${DB_HOST}"
   export DB_PORT="${DB_PORT}"
   export DB_NAME="${DB_NAME}"
   export DB_USER="${DB_USER}"
   export DB_PASSWORD="${DB_PASSWORD}"

3) Ejecuta el servicio:
   python manage.py runserver

EOF
