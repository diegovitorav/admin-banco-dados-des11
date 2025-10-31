#!/bin/bash

# Verificar se o diretório /etc/vbox existe, se não, criar
if [ ! -d "/etc/vbox" ]; then
  sudo mkdir -p /etc/vbox
fi

# Adicionar o intervalo de IP permitido ao arquivo networks.conf
echo "* 0.0.0.0/0 ::/0" | sudo tee /etc/vbox/networks.confvagrant up
