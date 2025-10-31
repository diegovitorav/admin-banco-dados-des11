## 📘 Instalação Automatizada do PostgreSQL 17.2 em VM Vagrant (CentOS Stream)

Este projeto provisiona automaticamente uma **máquina virtual CentOS Stream** via **Vagrant** e executa o **script de instalação do PostgreSQL 17.2** a partir do código-fonte.

Ideal para **laboratórios de estudo, testes de compilação** e **ambientes isolados de desenvolvimento**.

---

### Estrutura do Projeto

```
postgresql-vagrant/
├── config.yml
├── Vagrantfile
├── scripts/
│   └── add_user.sh
├── shared/
│   ├── install_pg_buffer.sh
│   └── install_postgres-17.sh
├── README.md                  ← Guia principal (execução automatizada)
└── docs/
    └── manual_install.md      ← Guia detalhado da instalação manual

```

* **Vagrantfile** → Define a VM CentOS e suas dependências básicas.
* **config.yml** → Centraliza as configurações (nome, IP, CPU, RAM).
* **shared/install_postgres-17.sh** → Script principal que instala e inicia o PostgreSQL 17.2.

---

## 🚀 Subindo a Infraestrutura

### 1️⃣ Pré-requisitos

Certifique-se de ter instalado no host:

* [VirtualBox](https://www.virtualbox.org)
* [Vagrant](https://developer.hashicorp.com/vagrant)

Verifique:

```bash
vagrant --version
virtualbox --help
```

---

### 2️⃣ Configurar a VM

Ajuste os parâmetros no arquivo `config.yml` conforme desejado (CPU, memória, IP, nome da VM).

---

### 3️⃣ Criar e iniciar a VM

No diretório do projeto:

```bash
vagrant up
```

Isso criará automaticamente uma VM CentOS Stream, atualizará os pacotes e instalará dependências básicas (via provisionamento definido no `Vagrantfile`).

---

### 4️⃣ Acessar a VM

Após a criação:

```bash
vagrant ssh vm02
```

---

### 5️⃣ Executar o Script de Instalação

Dentro da VM, o diretório compartilhado `/vagrant` contém o script de instalação do PostgreSQL.
Execute-o com privilégios de root:

```bash
cd /vagrant
./install_postgres-17.sh
```

O script executará todas as etapas de instalação, compilação e inicialização do PostgreSQL 17.2 automaticamente.

---

### 6️⃣ Testar a Instalação

Acesse o usuário `postgres`:

```bash
sudo su - postgres
psql
```

Dentro do `psql`, confirme a instalação:

```sql
SELECT version();
SHOW data_checksums;
```

Saída esperada:

```
PostgreSQL 17.2 ...
data_checksums | on
```

---

### 7️⃣ Encerrar e Gerenciar a VM

| Comando                         | Descrição                     |
| ------------------------------- | ----------------------------- |
| `vagrant halt`                  | Desliga a VM                  |
| `vagrant up`                    | Inicia novamente              |
| `vagrant destroy`               | Remove completamente          |
| `vagrant snapshot save pg17_ok` | Cria snapshot após instalação |

---

### ✅ Resultado Esperado

Ao final da execução, o PostgreSQL 17.2 estará:

* Instalado a partir do **código-fonte oficial**;
* Rodando como serviço sob o usuário **postgres**;
* Acessível via `psql` na própria VM;
* Configurado com `data_checksums` habilitado e `listen_addresses='*'`.

---

### 🧠 Dica

Se quiser reutilizar o ambiente sem reinstalar tudo, basta:

```bash
vagrant up
vagrant ssh
sudo su - postgres
psql
```

## 📖 Referência: Instalação Manual

Se preferir realizar o processo manualmente, passo a passo (sem o uso do Vagrant), consulte:

📘 [`docs/manual_install.md`](docs/manual_instalacao_posgres17.md)

Esse guia detalha a **instalação, compilação, configuração e inicialização do PostgreSQL 17.2** a partir do código-fonte oficial, reproduzindo exatamente as etapas do script `shared/install_postgres-17.sh`.
