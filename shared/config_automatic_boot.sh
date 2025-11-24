#!/bin/bash

# ==============================
# Variáveis principais
# ==============================
source ./pg_env.sh

# Caminhos
SCRIPT_ORIG="/tmp/postgresql-17.2/contrib/start-scripts/linux"
SCRIPT_DEST="/etc/init.d/postgresql"

# Verifica se o script de origem existe
if [ ! -f "$SCRIPT_ORIG" ]; then
  echo "Erro: Script de origem não encontrado em $SCRIPT_ORIG"
  exit 1
fi

# Copia o script para /etc/init.d
echo "Copiando script para $SCRIPT_DEST..."
sudo cp "$SCRIPT_ORIG" "$SCRIPT_DEST"

# Torna o script executável
echo "Definindo permissões de execução..."
sudo chmod +x "$SCRIPT_DEST"

# Atualiza PGDATA e prefix com sed
echo "Atualizando variáveis PGDATA e prefix..."
sudo sed -i "s|^PGDATA=.*|PGDATA=\"$PGDATA\"|" "$SCRIPT_DEST"
sudo sed -i "s|^prefix=.*|prefix=\"$PREFIX\"|" "$SCRIPT_DEST"

# Adiciona o serviço ao chkconfig
echo "Registrando serviço no chkconfig..."
sudo chkconfig --add postgresql

echo "Configuração concluída com sucesso!"
