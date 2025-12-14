#!/bin/bash
#
# Script para baixar e descompactar o PostgreSQL no /tmp

set -e

source ./pg_env.sh

echo "======================================"
echo "Baixando e descompactando PostgreSQL ${PG_VERSION}"
echo "======================================"

# 1. Instalar dependências de compilação
echo "[1/3] Instalando dependências..."
sudo yum install -y ${PG_BUILD_DEPS}

# 2. Baixar tarball
echo "[2/3] Baixando código-fonte..."
if [ ! -f "${TARBALL}" ]; then
  curl -o "${TARBALL}" "${DOWNLOAD_URL}"
else
  echo "✔ Tarball já existe em ${TARBALL}"
fi

# 3. Descompactar no /tmp
echo "[3/3] Extraindo código-fonte..."
if [ -d "${SRC_DIR}" ]; then
  echo "⚠ Diretório ${SRC_DIR} já existe. Removendo..."
  rm -rf "${SRC_DIR}"
fi

tar -xvf "${TARBALL}" -C /tmp

echo "✓ PostgreSQL ${PG_VERSION} baixado e extraído em ${SRC_DIR}"
echo "======================================"
echo "Agora você pode compilar acessando:"
echo "cd ${SRC_DIR} && ./configure --prefix=${PREFIX}"
echo "make > ${MAKE_COMPILE_LOG} 2>&1"
echo "sudo make install > ${MAKE_INSTALL_LOG} 2>&1"
echo "======================================"
