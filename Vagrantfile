# Vagrantfile - PostgreSQL 17 (CentOS Stream 10)

require "yaml"

# Carrega variáveis do arquivo config.yml
config = YAML.load_file("config.yml")

BOX_IMAGE   = config["box_image"]
VM_CPUS     = config["vm_cpus"]
VM_MEMORY   = config["vm_memory"]
NETWORK_IP  = config["network_ip"]
VM_HOSTNAME = config["vm_hostname"]
VM_NAME     = config["vm_name"]
SSH_HOST_PORT = config["ssh_host_port"]

Vagrant.configure("2") do |cfg|
  cfg.vm.define VM_NAME do |node|
    node.vm.box = BOX_IMAGE
    node.vm.hostname = VM_HOSTNAME

    node.vm.synced_folder "./shared", "/vagrant"

    node.vm.network "private_network", ip: NETWORK_IP

    # Redirecionamento de porta SSH (guest 22 → host 2222)
    node.vm.network "forwarded_port", guest: 22, host: 2222, id: "ssh"

    node.vm.provider "virtualbox" do |vb|
      vb.name = VM_NAME
      vb.cpus = VM_CPUS
      vb.memory = VM_MEMORY
      vb.linked_clone = true
    end

    # Atualização de pacotes e instalação de dependências básicas para CentOS
    node.vm.provision "shell", inline: <<-SHELL
      echo "==> Atualizando pacotes..."
      yum update -y

      echo "==> Instalando dependências básicas..."
      yum install -y curl wget gnupg2 ca-certificates vim \
        tar gzip unzip net-tools sudo which nano
    SHELL

    node.vm.provision "shell", path: "./scripts/add_user.sh"
  end
end
