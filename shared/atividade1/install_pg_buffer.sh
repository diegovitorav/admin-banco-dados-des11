#!/bin/bash
#
# Instalação da extensão pg_buffercache a partir do código-fonte no CentOS

set -e

# Caminhos principais
PG_VERSION="17.2"
PG_USER="postgres"
PG_INSTALL_DIR="/usr/local/pgsql"
PG_CONTRIB_DIR="/tmp/postgresql-${PG_VERSION}/contrib/pg_buffercache"
PGDATA="/db/data"
PGBIN="${PG_INSTALL_DIR}/bin"

echo "======================================"
echo "Instalando extensão pg_buffercache"
echo "======================================"

# ==============================
# 1. Verificar diretório da extensão
# ==============================
echo "[1/2] Verificando diretório da extensão..."
if [ ! -d "${PG_CONTRIB_DIR}" ]; then
  echo "❌ Diretório da extensão não encontrado: ${PG_CONTRIB_DIR}"
  echo "Certifique-se de que o código-fonte do PostgreSQL foi extraído em /tmp."
  exit 1
fi

# ==============================
# 2. Compilar e instalar extensão
# ==============================
echo "[2/2] Compilando e instalando extensão..."
cd "${PG_CONTRIB_DIR}"
make
make install

echo "✓ Extensão pg_buffercache instalada com sucesso."

# ==============================
# Ativar extensão no PostgreSQL
# ==============================
if ! su - ${PG_USER} -c "${PGBIN}/pg_ctl -D ${PGDATA} status" > /dev/null 2>&1; then
  echo "⚠️ PostgreSQL não está rodando. Inicie o serviço antes de usar a extensão."
  exit 0
fi

# echo "→ Criando extensão na base 'postgres'..."
# su - ${PG_USER} -c "${PGBIN}/psql -d postgres -c 'CREATE EXTENSION pg_buffercache;'"

# echo "✓ Extensão pg_buffercache ativada na base 'postgres'."
