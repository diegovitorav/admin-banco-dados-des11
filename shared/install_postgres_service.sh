#!/bin/bash
set -e

# ==============================
# Variáveis principais
# ==============================
source ./pg_env.sh

SERVICE_NAME="postgresql-17.service"
SERVICE_PATH="/etc/systemd/system"
SERVICE_FILE="${SERVICE_PATH}/${SERVICE_NAME}"

echo "🔧 Instalando serviço ${SERVICE_NAME}..."

# Remove arquivo antigo se existir
if [ -f "${SERVICE_FILE}" ]; then
    echo "🗑️  Removendo arquivo antigo..."
    sudo systemctl stop "${SERVICE_NAME}" 2>/dev/null || true
    sudo systemctl disable "${SERVICE_NAME}" 2>/dev/null || true
    sudo rm -f "${SERVICE_FILE}"
fi

# ============================================
# Novo serviço systemd (Type=simple)
# ============================================
sudo tee "${SERVICE_FILE}" > /dev/null <<EOF
[Unit]
Description=PostgreSQL ${PG_VERSION} Database Server
After=network.target

[Service]
Type=simple
User=${PG_USER}
Group=${PG_USER}
Environment=PGDATA=${PGDATA}
ExecStart=${PGBIN}/postgres -D ${PGDATA}
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=mixed
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 644 "${SERVICE_FILE}"

echo "✅ Serviço criado em ${SERVICE_FILE}"

# Verifica se o arquivo foi criado
if [ ! -f "${SERVICE_FILE}" ]; then
    echo "❌ ERRO: Arquivo ${SERVICE_FILE} não foi criado!"
    exit 1
fi

echo ""
echo "📄 Conteúdo do arquivo criado:"
cat "${SERVICE_FILE}"

echo ""
echo "🔄 Recarregando systemd..."
sudo systemctl daemon-reload

# Testa sintaxe
echo ""
echo "🔍 Testando sintaxe do arquivo de serviço..."
if ! sudo systemd-analyze verify "${SERVICE_FILE}" 2>&1; then
    echo "⚠️  Aviso: Podem haver problemas na sintaxe do arquivo"
fi

# Verifica se o PostgreSQL está rodando fora do systemd
if sudo -u "${PG_USER}" "${PGBIN}/pg_ctl" status -D "${PGDATA}" 2>/dev/null | grep -q "server is running"; then
  echo ""
  echo "🛑 PostgreSQL está rodando fora do systemd. Parando instância manualmente..."
  sudo -u "${PG_USER}" "${PGBIN}/pg_ctl" stop -D "${PGDATA}" -m fast
  sleep 2
fi

echo ""
echo "🚀 Habilitando serviço..."
sudo systemctl enable "${SERVICE_NAME}"

echo ""
echo "▶️  Iniciando serviço..."
sudo systemctl start "${SERVICE_NAME}"

sleep 3

echo ""
echo "📋 Status do serviço:"
sudo systemctl status "${SERVICE_NAME}" --no-pager || true

echo ""
echo "✅ Instalação concluída!"
