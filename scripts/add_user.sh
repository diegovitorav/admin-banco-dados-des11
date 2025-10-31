#!/bin/bash

NEW_USER=aluno
PASSWORD=teste
VAGRANT_SSH_DIR="/vagrant/.ssh"

echo "Etapa 1 - Criar usuário ${NEW_USER}"
useradd -m -s /bin/bash ${NEW_USER}
echo "${NEW_USER}:${PASSWORD}" | chpasswd

echo "Etapa 2 - Criar diretório .ssh"
install -d -m 700 -o ${NEW_USER} -g ${NEW_USER} /home/${NEW_USER}/.ssh

echo "Etapa 3 - Gerar par de chaves SSH"
sudo -u ${NEW_USER} ssh-keygen -t rsa -b 2048 \
  -f /home/${NEW_USER}/.ssh/id_rsa \
  -N "" \
  -C "${NEW_USER}@$(hostname)"

echo "Etapa 4 - Configurar authorized_keys"
cat /home/${NEW_USER}/.ssh/id_rsa.pub > /home/${NEW_USER}/.ssh/authorized_keys
chmod 600 /home/${NEW_USER}/.ssh/authorized_keys
chown ${NEW_USER}:${NEW_USER} /home/${NEW_USER}/.ssh/authorized_keys

echo "Etapa 5 - Copiar diretório .ssh para /vagrant/.ssh"
mkdir -p "${VAGRANT_SSH_DIR}"
cp -r /home/${NEW_USER}/.ssh/* "${VAGRANT_SSH_DIR}/"
chown -R ${NEW_USER}:${NEW_USER} "${VAGRANT_SSH_DIR}"
chmod 700 "${VAGRANT_SSH_DIR}"

echo "Etapa 6 - Adicionar sudo sem senha"
echo "${NEW_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${NEW_USER}
chmod 440 /etc/sudoers.d/${NEW_USER}

echo "Etapa 7 - Exibir chaves"
echo "=========================================="
echo "Chave privada:"
cat /home/${NEW_USER}/.ssh/id_rsa
echo "=========================================="
echo "Chave pública:"
cat /home/${NEW_USER}/.ssh/id_rsa.pub
echo "=========================================="

echo "Concluído! As chaves também foram copiadas para ${VAGRANT_SSH_DIR}"
