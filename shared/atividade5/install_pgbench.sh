#!/bin/bash
#
# Instalação e configuração do pgbench a partir do código-fonte no CentOS

set -e

# Caminhos principais
PG_VERSION="17.2"
PG_USER="postgres"
PG_INSTALL_DIR="/usr/local/pgsql"
PG_SOURCE_DIR="/tmp/postgresql-${PG_VERSION}"
PG_CONTRIB_DIR="${PG_SOURCE_DIR}/src/bin/pgbench"
PGDATA="/db/data"
PGBIN="${PG_INSTALL_DIR}/bin"

echo "======================================"
echo "Instalando e configurando pgbench"
echo "======================================"

# ==============================
# 1. Verificar código-fonte
# ==============================
echo "[1/4] Verificando código-fonte do PostgreSQL..."
if [ ! -d "${PG_SOURCE_DIR}" ]; then
  echo "❌ Código-fonte não encontrado em ${PG_SOURCE_DIR}"
  echo "Baixando PostgreSQL ${PG_VERSION}..."
  cd /tmp
  curl -O https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.gz
  tar -xzf postgresql-${PG_VERSION}.tar.gz
fi

if [ ! -d "${PG_CONTRIB_DIR}" ]; then
  echo "❌ Diretório do pgbench não encontrado: ${PG_CONTRIB_DIR}"
  exit 1
fi

# ==============================
# 2. Configurar código-fonte
# ==============================
echo "[2/4] Configurando código-fonte do PostgreSQL..."
cd "${PG_SOURCE_DIR}"

# Verificar se já foi configurado
if [ ! -f "src/Makefile.global" ]; then
  echo "Executando ./configure..."
  ./configure --prefix=${PG_INSTALL_DIR}
else
  echo "✓ Código-fonte já configurado."
fi

# ==============================
# 3. Compilar e instalar pgbench
# ==============================
echo "[3/4] Compilando e instalando pgbench..."
cd "${PG_CONTRIB_DIR}"
make
sudo make install

echo "✓ pgbench instalado com sucesso em ${PGBIN}/pgbench"

# ==============================
# 4. Criar base de testes
# ==============================
echo "[4/4] Criando base de testes para pgbench..."

if ! su - ${PG_USER} -c "${PGBIN}/pg_ctl -D ${PGDATA} status" > /dev/null 2>&1; then
  echo "⚠️ PostgreSQL não está rodando. Inicie o serviço antes de criar a base."
  echo "======================================"
  echo "pgbench instalado com sucesso!"
  echo "Para criar a base de testes manualmente:"
  echo "1. Inicie o PostgreSQL"
  echo "2. Execute: su - ${PG_USER} -c \"${PGBIN}/createdb pgbench\""
  echo "3. Execute: su - ${PG_USER} -c \"${PGBIN}/pgbench -i -s 10 pgbench\""
  echo "======================================"
  exit 0
fi

# Criar base de testes chamada "pgbench" (se não existir)
if su - ${PG_USER} -c "${PGBIN}/psql -lqt" | cut -d \| -f 1 | grep -qw pgbench; then
  echo "⚠️ Base 'pgbench' já existe. Pulando criação."
else
  echo "Criando base 'pgbench'..."
  su - ${PG_USER} -c "${PGBIN}/createdb pgbench"
  echo "✓ Base criada."
fi

# Inicializar a base com dados padrão do pgbench
echo "Inicializando dados (escala 10)..."
su - ${PG_USER} -c "${PGBIN}/pgbench -i -s 10 pgbench"

echo "✓ Base de testes 'pgbench' criada e inicializada com sucesso."
echo "======================================"
echo "pgbench instalado e configurado!"
echo ""
echo "Exemplos de uso:"
echo "  # Teste simples (10 clientes, 1000 transações)"
echo '  su - postgres -c "/usr/local/pgsql/bin/pgbench -c 10 -t 1000 pgbench"'
echo ""
echo "  # Teste com duração (10 clientes, 60 segundos)"
echo '  su - postgres -c "/usr/local/pgsql/bin/pgbench -c 10 -T 60 pgbench"'
echo ""
echo "  # Teste com múltiplas threads (20 clientes, 4 threads, 30 segundos)"
echo '  su - postgres -c "/usr/local/pgsql/bin/pgbench -c 20 -j 4 -T 30 pgbench"'
echo "======================================"
