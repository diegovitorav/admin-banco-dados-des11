# 📘 Instalação Manual do PostgreSQL 17.2 a partir do Código Fonte (CentOS)

Este guia descreve **passo a passo** o processo de **instalação, compilação e configuração do PostgreSQL 17.2** em sistemas **CentOS**, reproduzindo manualmente as ações realizadas pelo script `shared/install_postgres-17.sh`.

---

##  Visão Geral

A instalação é feita **a partir do código-fonte oficial** do PostgreSQL, com criação de um ambiente dedicado ao usuário `postgres`, compilação do binário, execução de testes de regressão e inicialização de um novo cluster de dados.

Ao final, o PostgreSQL será executado em `/usr/local/pgsql`, com dados em `/db/data` e ambiente configurado automaticamente para o usuário `postgres`.

---

## ⚙️ Pré-requisitos

Certifique-se de estar logado como `root` ou ter permissões de `sudo`.

### Pacotes obrigatórios:

```bash
dnf install -y \
  gcc gcc-c++ make readline-devel zlib-devel wget \
  libicu-devel bison flex sudo glibc-langpack-en perl
```

Esses pacotes garantem que o sistema tenha compiladores, bibliotecas de leitura, compressão e internacionalização necessárias para compilar o PostgreSQL.

---

## 👤 Criar usuário e diretórios

Crie o usuário padrão do PostgreSQL e os diretórios base de instalação e dados:

```bash
useradd -m -d /home/postgres --user-group -s /bin/bash postgres

mkdir -p /home/postgres /usr/local/pgsql /db /db/data
chown -R postgres:postgres /home/postgres /usr/local/pgsql /db /db/data
```

---

## 🌐 Definir variáveis principais

Estas variáveis são utilizadas durante o processo de instalação:

| Variável         | Valor                                                                | Descrição                          |
| ---------------- | -------------------------------------------------------------------- | ---------------------------------- |
| `PG_VERSION`     | `17.2`                                                               | Versão a ser instalada             |
| `PG_USER`        | `postgres`                                                           | Usuário padrão                     |
| `PG_HOME`        | `/home/postgres`                                                     | Diretório home do usuário          |
| `PG_INSTALL_DIR` | `/usr/local/pgsql`                                                   | Caminho de instalação dos binários |
| `PGDATA`         | `/db/data`                                                           | Diretório do cluster de dados      |
| `PGBIN`          | `/usr/local/pgsql/bin`                                               | Caminho dos executáveis            |
| `SRC_DIR`        | `/tmp/postgresql-17.2`                                               | Diretório do código-fonte          |
| `TARBALL`        | `/tmp/postgresql-17.2.tar.gz`                                        | Arquivo fonte compactado           |
| `DOWNLOAD_URL`   | `https://ftp.postgresql.org/pub/source/v17.2/postgresql-17.2.tar.gz` | Fonte oficial                      |

---

## 📦 Baixar o código-fonte

```bash
cd /tmp
wget https://ftp.postgresql.org/pub/source/v17.2/postgresql-17.2.tar.gz
tar -xzf postgresql-17.2.tar.gz
cd postgresql-17.2
```

---

## 🧱 Compilar e testar o PostgreSQL

```bash
./configure --prefix=/usr/local/pgsql --without-icu
make -j"$(nproc)"
```

> ⚠️ A flag `--without-icu` desabilita suporte à internacionalização via ICU para simplificar a compilação.

### (Opcional) Executar testes de regressão

Esses testes garantem que o build funcione corretamente.

```bash
su - postgres -c "cd /tmp/postgresql-17.2 && make check" > /tmp/pg_regression.log 2>&1
```

Verifique o resultado:

```bash
tail -50 /tmp/pg_regression.log
```

---

## 🧩 Instalar binários compilados

```bash
make install
chown -R postgres:postgres /usr/local/pgsql
```

Os binários serão instalados em:

```
/usr/local/pgsql/bin/
├── initdb
├── pg_ctl
├── psql
└── ...
```

---

## 🧰 Configuração das variáveis de ambiente

Adicione as variáveis ao ambiente do usuário `postgres` e também ao `root` (ou `vagrant`, se aplicável):

```bash
cat <<'EOF' >> /home/postgres/.bashrc

# PostgreSQL Envs
export PATH=/usr/local/pgsql/bin:$PATH
export PGDATA=/db/data
export PGBIN=/usr/local/pgsql/bin
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
EOF
```

Para aplicar imediatamente:

```bash
source /home/postgres/.bashrc
```

---

## 🗄️ Inicializar o cluster de dados

Crie o cluster inicial com checksums de integridade:

```bash
su - postgres -c "initdb --data-checksums -D /db/data"
```

### Configurar acesso e escuta

```bash
su - postgres -c "echo \"listen_addresses = '*'\" >> /db/data/postgresql.conf"
su - postgres -c "echo \"host all all 0.0.0.0/0 trust\" >> /db/data/pg_hba.conf"
```

---

## 🚀 Iniciar o servidor PostgreSQL

```bash
su - postgres -c "pg_ctl -D /db/data -l /home/postgres/logfile start"
```

Verifique o status:

```bash
su - postgres -c "pg_ctl -D /db/data status"
```

Saída esperada:

```
pg_ctl: server is running (PID: 12345)
/usr/local/pgsql/bin/postgres "-D" "/db/data"
```

---

## 📂 Estrutura Final do Sistema

```
/usr/local/pgsql/
├── bin/
│   ├── initdb
│   ├── pg_ctl
│   ├── psql
│   └── ...
└── share/

/db/
└── data/
    ├── base/
    ├── global/
    ├── pg_hba.conf
    ├── postgresql.conf
    └── PG_VERSION

/home/postgres/
└── .bashrc
    logfile
```

---

## 💡 Comandos úteis

```bash
sudo su - postgres
psql            # Abre o shell SQL
pg_ctl status   # Verifica status do serviço
pg_ctl stop     # Para o PostgreSQL
pg_ctl start    # Inicia o PostgreSQL
```

---

## 🧹 Limpeza (opcional)

Para remover os arquivos-fonte após a instalação:

```bash
rm -rf /tmp/postgresql-17.2*
```

---

## ✅ Resumo Final

| Etapa | Descrição                           |
| ----- | ----------------------------------- |
| 1️⃣   | Instalação de dependências          |
| 2️⃣   | Criação do usuário e diretórios     |
| 3️⃣   | Download e extração do código-fonte |
| 4️⃣   | Compilação e testes de regressão    |
| 5️⃣   | Instalação dos binários             |
| 6️⃣   | Configuração do ambiente e cluster  |
| 7️⃣   | Inicialização e verificação         |
| 8️⃣   | Limpeza opcional                    |

