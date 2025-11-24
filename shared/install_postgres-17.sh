#!/bin/bash
#
# Script de instalação do PostgreSQL 17 no CentOS a partir do código fonte

set -eux

# ==============================
# Variáveis principais
# ==============================
source ./pg_env.sh

echo "======================================"
echo "PostgreSQL ${PG_VERSION} - Instalação no CentOS"
echo "======================================"

# ==============================
# 1. Dependências obrigatórias
# ==============================
echo "[1/8] Instalando dependências..."
dnf install -y \
  ${PG_BUILD_DEPS} \
  readline-devel \
  zlib-devel \
  wget \
  libicu-devel \
  glibc-langpack-en

# ==============================
# 2. Criar usuário e diretórios
# ==============================
echo "[2/8] Criando usuário ${PG_USER} e diretórios..."
if ! id -u ${PG_USER} >/dev/null 2>&1; then
  useradd -m -d ${PG_HOME} --user-group -s /bin/bash ${PG_USER}
fi

mkdir -p ${PG_HOME} ${PG_INSTALL_DIR} /db ${PGDATA}
chown -R ${PG_USER}:${PG_USER} ${PG_HOME} ${PG_INSTALL_DIR} /db ${PGDATA}

# Adiciona variáveis de ambiente ao .bashrc do usuário postgres
{
  echo ""
  echo "# PostgreSQL Envs"
  echo "export PATH=${PGBIN}:\$PATH"
  echo "export PGDATA=${PGDATA}"
  echo "export PGBIN=${PGBIN}"
  echo "export LANG=en_US.UTF-8"
  echo "export LC_ALL=en_US.UTF-8"
  echo 'export PAGER="less -S"'
} >> "${PG_HOME}/.bashrc"

# ==============================
# 3. Baixar código fonte
# ==============================
echo "[3/8] Verificando código fonte..."
if [ -f "${TARBALL}" ]; then
  echo "→ Fonte já existente em ${TARBALL}, pulando download."
else
  echo "→ Baixando PostgreSQL ${PG_VERSION}..."
  wget -q --show-progress -O "${TARBALL}" "${DOWNLOAD_URL}"
fi

# ==============================
# 4. Extrair código fonte
# ==============================
if [ ! -d "${SRC_DIR}" ]; then
  echo "[4/8] Extraindo código fonte..."
  tar -xzf "${TARBALL}" -C /tmp/
else
  echo "[4/8] Diretório fonte já existe, pulando extração."
fi

cd "${SRC_DIR}"

# ==============================
# 5. Compilar e testar
# ==============================
if [ -x "${PGBIN}/postgres" ]; then
  echo "[5/8] PostgreSQL já compilado em ${PGBIN}, pulando compilação."
else
  echo "[5/8] Compilando PostgreSQL..."
  ./configure \
    --prefix=${PG_INSTALL_DIR} \
    --with-systemd \
    --without-icu \
    2>&1 \
    | tee "${CONFIGURE_LOG}"
    
  make -j"$(nproc)" 2>&1 | tee "${MAKE_COMPILE_LOG}"

  echo "→ Executando testes de regressão com 'make check'..."
  rm -rf "${SRC_DIR}/tmp_install"
  chown -R ${PG_USER}:${PG_USER} "${SRC_DIR}"

  if su - ${PG_USER} -c "cd ${SRC_DIR} && make check" > "${REGRESSION_LOG}" 2>&1; then
    echo "✓ Teste de regressão concluído com sucesso."
  else
    echo "⚠️ Teste de regressão falhou. Detalhes:"
    if [ -f "${SRC_DIR}/tmp_install/log/initdb-template.log" ]; then
      echo "=== Log do initdb-template ==="
      cat "${SRC_DIR}/tmp_install/log/initdb-template.log"
    fi
    echo "=== Últimas linhas do regression.log ==="
    tail -50 "${REGRESSION_LOG}"
    read -p "Deseja continuar a instalação mesmo assim? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
      exit 1
    fi
  fi

  echo "→ Instalando binários..."
 make install 2>&1 | tee "${MAKE_INSTALL_LOG}"
  chown -R ${PG_USER}:${PG_USER} ${PG_INSTALL_DIR}
fi

# ==============================
# 6. Configurar cluster
# ==============================
echo "[6/8] Configurando cluster..."
for user_home in /home/vagrant /root; do
  if [ -d "$user_home" ]; then
    {
      echo ""
      echo "# PostgreSQL Envs"
      echo "export PATH=${PGBIN}:\$PATH"
      echo "export PGDATA=${PGDATA}"
    } >> "$user_home/.bashrc"
  fi
done

if [ ! -f "${PGDATA}/PG_VERSION" ]; then
  echo "→ Inicializando cluster com checksums de dados..."
  su - ${PG_USER} -c "LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 ${PGBIN}/initdb --data-checksums -D ${PGDATA}"
else
  echo "→ Cluster já inicializado em ${PGDATA}."
fi

su - ${PG_USER} -c "echo \"listen_addresses = '*'\" >> ${PGDATA}/postgresql.conf"
su - ${PG_USER} -c "echo \"host all all 0.0.0.0/0 trust\" >> ${PGDATA}/pg_hba.conf"

# ==============================
# 7. Iniciar PostgreSQL
# ==============================
echo "[7/8] Iniciando PostgreSQL..."
# Se o PostgreSQL estiver rodando, pare ele. Se não estiver, tudo bem, continue.
su - ${PG_USER} -c "${PGBIN}/pg_ctl -D ${PGDATA} -m fast stop" 2>/dev/null || true
sleep 1
su - ${PG_USER} -c "${PGBIN}/pg_ctl -D ${PGDATA} -l ${PGLOG} start"
sleep 3

if su - ${PG_USER} -c "${PGBIN}/pg_ctl -D ${PGDATA} status" > /dev/null 2>&1; then
  echo "✓ PostgreSQL ${PG_VERSION} instalado e iniciado com sucesso!"
else
  echo "⚠️ PostgreSQL instalado mas não está rodando. Verifique  ${PGLOG}"
fi

echo ""
echo "Para usar:"
echo "  sudo su - postgres"
echo "  psql"
echo ""
echo "Arquivos:"
echo "  Binários: ${PGBIN}/"
echo "  Dados:    ${PGDATA}"
echo "  Logs:     ${PGLOG}"
echo ""
echo "Comandos úteis:"
echo "  pg_ctl status"
echo "  pg_ctl stop"
echo "  pg_ctl start"
echo ""

# ==============================
# 8. Limpeza (opcional)
# ==============================
# echo "[8/8] Limpeza..."
# read -p "Deseja remover código fonte e dependências de compilação? (s/N): " -n 1 -r
# echo
# if [[ $REPLY =~ ^[Ss]$ ]]; then
#   echo "→ Removendo código fonte..."
#   rm -rf "${SRC_DIR}" "${TARBALL}"

#   echo "→ Removendo pacotes usados apenas na compilação..."
#   dnf remove -y ${PG_BUILD_DEPS}

#   echo "✓ Limpeza concluída."
# else
#   echo "→ Código fonte e pacotes mantidos."
# fi

# echo ""
# echo "Instalação concluída!"

