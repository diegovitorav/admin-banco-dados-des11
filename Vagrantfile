# Vagrantfile - Todas as configurações internas

VMS = [
  {
    box_image: "centos/stream9",
    vm_name: "vm02",
    vm_hostname: "vm02",
    network_ip: "192.168.56.15",
    vm_cpus: 2,
    vm_memory: 2048,
    ssh_host_port: 2222
  },
  {
    box_image: "centos/stream9",
    vm_name: "vm03",
    vm_hostname: "vm03",
    network_ip: "192.168.56.16",
    vm_cpus: 2,
    vm_memory: 1024,
    ssh_host_port: 2223
  }
]

Vagrant.configure("2") do |cfg|
  VMS.each do |vm|
    cfg.vm.define vm[:vm_name] do |node|
      node.vm.box = vm[:box_image]
      node.vm.hostname = vm[:vm_hostname]

      node.vm.synced_folder "./shared", "/vagrant"

      node.vm.network "private_network", ip: vm[:network_ip]

      node.vm.network "forwarded_port",
                      guest: 22,
                      host: vm[:ssh_host_port],
                      id: "ssh_#{vm[:vm_name]}"

      node.vm.provider "virtualbox" do |vb|
        vb.name = vm[:vm_name]
        vb.cpus = vm[:vm_cpus]
        vb.memory = vm[:vm_memory]
        vb.linked_clone = true
      end

      # Adiciona disco somente para vm02
      if vm[:vm_name] == "vm02"
        node.vm.disk :disk, size: "20GB", primary: true
      end

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
end
