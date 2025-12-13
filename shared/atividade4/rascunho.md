<table style="width:100%; border-collapse: collapse;">
  <tr>
    <td style="width: 120px;">
      <img src="imagens/escola_superior_de_redes.png" alt="Escola Superior de Redes - RNP" width="120"/>
    </td>
    <td style="vertical-align: middle; text-align: left;">
      <h1 style="margin: 0; color: #0f308dff;">Administração de Bancos de Dados</h1>
    </td>
  </tr>
</table>

<p style="margin: 4px 0 0 0; font-size: 14px; color: #333;">Aluno: <strong>Diego Vitor Soares dos Santos</strong></p>
<p style="margin: 4px 0 0 0; font-size: 14px; color: #333;">Cod. Turma: <strong>DES11</strong></p>
<p style="margin: 4px 0 0 0; font-size: 14px; color: #333;">Data: <strong>29 de novembro de 2025</strong></p>


# **Módulo 4 – Administrando Usuário e Segurança**


## ⚙️ **Ambiente de Teste**

* **Virtualização:** Vagrant + VirtualBox
* **Sistema Operacional:** CentOS Stream 9 (Kernel 5.x)
* **PostgreSQL:** 17.2 (estável)
* **Fonte oficial:**
  [https://ftp.postgresql.org/pub/source/v17.2/postgresql-17.2.tar.gz](https://ftp.postgresql.org/pub/source/v17.2/postgresql-17.2.tar.gz)

---

## a) Criar ROLES

**Objetivos:**

1.  Criar as seguintes ROLES com permissão de conexão (`LOGIN`) e senha definida:
      * `gerente`
      * `controller`
      * `jsilva`
      * `moliveira`
      * `psouza`
      * `contábil`
2.  **Restrição Temporal:** Definir a role **psouza** como válida por apenas **1 mês**.
3.  **Permissões Elevadas:** Permitir que a role **gerente** possa:
      * Criar bases de dados (`CREATEDB`).
      * Criar outras roles (`CREATEROLE`).


### 1\.1 Comandos Utilizados criar as Roles
Abaixo, os procedimentos para criar todas as roles com permissão de conexão (`LOGIN`) e senha definida:

```sql
CREATE ROLE gerente LOGIN PASSWORD 'atividade4.des11';
CREATE ROLE controller LOGIN PASSWORD 'atividade4.des11';
CREATE ROLE jsilva LOGIN PASSWORD 'atividade4.des11';
CREATE ROLE moliveira LOGIN PASSWORD 'atividade4.des11';
CREATE ROLE psouza LOGIN PASSWORD 'atividade4.des11';
CREATE ROLE "contábil" LOGIN PASSWORD 'atividade4.des11';
```

Query de validação (Verificação do atributo rolcanlogin):
```sql
SELECT rolname, rolcanlogin
FROM pg_roles
WHERE rolname IN ('gerente','controller','jsilva','moliveira','psouza','contábil');
```

### 1\.2 Resultado da Execução no terminal

```bash
[postgres@vm02 vagrant]$ psql
psql (17.2)
Type "help" for help.

postgres=# \du
                             List of roles
 Role name |                         Attributes                         
-----------+------------------------------------------------------------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS

postgres=# CREATE ROLE gerente LOGIN PASSWORD 'atividade4.des11';
CREATE ROLE
postgres=# CREATE ROLE controller LOGIN PASSWORD 'atividade4.des11';
CREATE ROLE
postgres=# CREATE ROLE jsilva LOGIN PASSWORD 'atividade4.des11';
CREATE ROLE
postgres=# CREATE ROLE moliveira LOGIN PASSWORD 'atividade4.des11';
CREATE ROLE
postgres=# CREATE ROLE psouza LOGIN PASSWORD 'atividade4.des11';
CREATE ROLE
postgres=# CREATE ROLE "contábil" LOGIN PASSWORD 'atividade4.des11';
CREATE ROLE
postgres=# \du
                              List of roles
 Role name  |                         Attributes                         
------------+------------------------------------------------------------
 controller | 
 contábil   | 
 gerente    | 
 jsilva     | 
 moliveira  | 
 postgres   | Superuser, Create role, Create DB, Replication, Bypass RLS
 psouza     | 

postgres=# exit
[postgres@vm02 vagrant]$ psql -U gerente -d postgres
psql (17.2)
Type "help" for help.

postgres=> SELECT CURRENT_USER;
 current_user 
--------------
 gerente
(1 row)

postgres=> SELECT rolname, rolcanlogin
FROM pg_roles
WHERE rolname IN ('gerente','controller','jsilva','moliveira','psouza','contábil');
  rolname   | rolcanlogin 
------------+-------------
 gerente    | t
 controller | t
 jsilva     | t
 moliveira  | t
 psouza     | t
 contábil   | t
(6 rows)

postgres=> SELECT NOW();
              now              
-------------------------------
 2025-12-13 14:01:21.842454+00
(1 row)

postgres=> 
```

### 2.1 Aplicação de Restrições Temporais

Com as roles criadas, a próxima etapa é aplicar regras para que a role **psouza** seja válida por apenas **1 mês**.

```sql
-- Definir variável com a data de expiração (hoje + 1 mês)
\set validade `date -d "+1 month" +"%Y-%m-%d"`

-- Alterar a validade da role existente
ALTER ROLE psouza VALID UNTIL :'validade';
```

Query de validação no catálogo do sistema:

```sql
SELECT rolname, valuntil 
FROM pg_roles 
WHERE rolname = 'psouza';
```

### 2.2 Resultado da Execução no terminal

```bash
[postgres@vm02 vagrant]$ psql
psql (17.2)
Type "help" for help.

postgres=# \du
                              List of roles
 Role name  |                         Attributes                         
------------+------------------------------------------------------------
 controller | 
 contábil   | 
 gerente    | 
 jsilva     | 
 moliveira  | 
 postgres   | Superuser, Create role, Create DB, Replication, Bypass RLS
 psouza     | 

postgres=# \set validade `date -d "+1 month" +"%Y-%m-%d"`
postgres=# ALTER ROLE psouza VALID UNTIL :'validade';
ALTER ROLE
postgres=# \du
                              List of roles
 Role name  |                         Attributes                         
------------+------------------------------------------------------------
 controller | 
 contábil   | 
 gerente    | 
 jsilva     | 
 moliveira  | 
 postgres   | Superuser, Create role, Create DB, Replication, Bypass RLS
 psouza     | Password valid until 2026-01-13 00:00:00+00
postgres=# SELECT rolname, rolvaliduntil
FROM pg_authid
WHERE rolname = 'psouza';
 rolname |     rolvaliduntil      
---------+------------------------
 psouza  | 2026-01-13 00:00:00+00
(1 row)

postgres=#
```

### 3.1 Alteração das permissões
Nesta etapa, será realizada a elevação de privilégios da role ***gerente**. Serão concedidos os atributos CREATEDB e CREATEROLE, conferindo à role capacidades administrativas para criar bancos de dados e gerenciar outros usuários.

```sql
ALTER ROLE gerente CREATEDB CREATEROLE;
```

Query para validar se os atributos (`rolcreatedb` e `rolcreaterole`) foram definidos como verdadeiros (`t`):

```sql
SELECT rolname, rolcreatedb, rolcreaterole 
FROM pg_roles 
WHERE rolname = 'gerente';
```

### 3.2 Resultado da Execução no terminal

```bash
postgres=# \du
                              List of roles
 Role name  |                         Attributes                         
------------+------------------------------------------------------------
 controller | 
 contábil   | 
 gerente    | 
 jsilva     | 
 moliveira  | 
 postgres   | Superuser, Create role, Create DB, Replication, Bypass RLS
 psouza     | Password valid until 2026-01-13 00:00:00+00

postgres=# ALTER ROLE gerente CREATEDB CREATEROLE;
ALTER ROLE
postgres=# SELECT rolname, rolcreatedb, rolcreaterole 
FROM pg_roles 
WHERE rolname = 'gerente';
 rolname | rolcreatedb | rolcreaterole 
---------+-------------+---------------
 gerente | t           | t
(1 row)

postgres=# \du
                              List of roles
 Role name  |                         Attributes                         
------------+------------------------------------------------------------
 controller | 
 contábil   | 
 gerente    | Create role, Create DB
 jsilva     | 
 moliveira  | 
 postgres   | Superuser, Create role, Create DB, Replication, Bypass RLS
 psouza     | Password valid until 2026-01-13 00:00:00+00
```

-----

## b) Criação de Grupo e Associação de Membros

**Objetivos:**

1. Conectar com o usuário **gerente**.
2. Criar a **ROLE** para o grupo **contabilidade**.
3. Adicionar as seguintes roles ao grupo **contabilidade**:

   * **jsilva**
   * **moliveira**
   * **psouza**


### 1\. Conexão e Execução

Como o usuário `gerente` agora possui o atributo `CREATEROLE`, ele tem permissão para criar o grupo e gerenciar os membros.

**Comando para conectar como gerente:**

```bash
psql -U gerente -d postgres
```

**Comandos SQL para criar o grupo e adicionar membros:**

```sql
-- 1. Criação da Role de grupo
CREATE ROLE contabilidade NOLOGIN;

-- 2. Adicionar usuários ao grupo contabilidade
GRANT contabilidade TO jsilva, moliveira, psouza;
```

### 2\. Validação da Estrutura de Grupo

Para confirmar se a role `contabilidade` foi criada e se os membros foram associados corretamente.

**Query de verificação:**

```sql
-- Listar o grupo e seus membros
SELECT r.rolname AS nome_grupo, 
       ARRAY(SELECT u.rolname 
             FROM pg_auth_members m 
             JOIN pg_roles u ON m.member = u.oid 
             WHERE m.roleid = r.oid) as membros
FROM pg_roles r
WHERE r.rolname = 'contabilidade';
```

### 3\. Resultado da Execução no terminal

```bash
[postgres@vm02 vagrant]$ psql -U gerente -d postgres
psql (17.2)
Type "help" for help.

postgres=> CREATE ROLE contabilidade NOLOGIN;
CREATE ROLE
postgres=> GRANT contabilidade TO jsilva, moliveira, psouza;
GRANT ROLE
postgres=> \du
                               List of roles
   Role name   |                         Attributes                         
---------------+------------------------------------------------------------
 contabilidade | Cannot login
 controller    | 
 contábil      | 
 gerente       | Create role, Create DB
 jsilva        | 
 moliveira     | 
 postgres      | Superuser, Create role, Create DB, Replication, Bypass RLS
 psouza        | Password valid until 2026-01-13 00:00:00+00

postgres=> SELECT r.rolname AS nome_grupo, 
       ARRAY(SELECT u.rolname 
             FROM pg_auth_members m 
             JOIN pg_roles u ON m.member = u.oid 
             WHERE m.roleid = r.oid) as membros
FROM pg_roles r
WHERE r.rolname = 'contabilidade';
  nome_grupo   |              membros              
---------------+-----------------------------------
 contabilidade | {gerente,jsilva,moliveira,psouza}
(1 row)

postgres=> 
```

## c) Criação de bases e schemas

1. Conectar com o usuário **gerente**.
2. Criar a base de dados **sis_contabil**.
3. Dentro da base, criar o schema **controladoria**.
4. Fornecer permissão para a role controller no schema controladoria poder criar objetos e usar o schema.

Considerando que a conexão com o usuário gerente permanece ativa da etapa anterior, executamos diretamente os seguintes comandos SQL.

### 1\. Criação da base de dados e schema

```sql
-- Criar a base de dados
CREATE DATABASE sis_contabil;

-- Conectar-se à base sis_contabil
\c sis_contabil

-- Criar o schema controladoria
CREATE SCHEMA controladoria;

-- Fornecer permissões para a role controller no schema controladoria
GRANT USAGE ON SCHEMA controladoria TO controller;
GRANT CREATE ON SCHEMA controladoria TO controller;
```

### 2\. Resultado da Execução no terminal

```bash
postgres=> SELECT CURRENT_USER;
 current_user 
--------------
 gerente
(1 row)

postgres=> CREATE DATABASE sis_contabil;
CREATE DATABASE
postgres=> SELECT datname 
FROM pg_database;
   datname    
--------------
 postgres
 template1
 template0
 sis_contabil
(4 rows)

postgres=> \c sis_contabil
You are now connected to database "sis_contabil" as user "gerente".
sis_contabil=> CREATE SCHEMA controladoria;
CREATE SCHEMA
sis_contabil=> \dn
          List of schemas
     Name      |       Owner       
---------------+-------------------
 controladoria | gerente
 public        | pg_database_owner
(2 rows)

sis_contabil=> GRANT USAGE ON SCHEMA controladoria TO controller;
GRANT
sis_contabil=> GRANT CREATE ON SCHEMA controladoria TO controller;
GRANT
sis_contabil=> \du+
                                      List of roles
   Role name   |                         Attributes                         | Description 
---------------+------------------------------------------------------------+-------------
 contabilidade | Cannot login                                               | 
 controller    |                                                            | 
 contábil      |                                                            | 
 gerente       | Create role, Create DB                                     | 
 jsilva        |                                                            | 
 moliveira     |                                                            | 
 postgres      | Superuser, Create role, Create DB, Replication, Bypass RLS | 
 psouza        | Password valid until 2026-01-13 00:00:00+00                | 

sis_contabil=>
```

### d) Permissões

1. **Conexão com o usuário gerente**  
   - Conceder permissão ao grupo **contabilidade** para utilizar o *schema* **controladoria**.

2. **Conexão com o usuário controller**  
   - Criar a tabela **contas** no *schema* **controladoria** com o seguinte código SQL:  

   ```sql
   CREATE TABLE controladoria.contas (
       id INT,
       numero INT,
       responsavel VARCHAR(50)
   );
   ```

3. **Concessão de permissões**  
   - Permissão de uso do *schema* **controladoria** para o grupo **contabilidade**.  
   - Permissão de **consulta** à tabela **contas** para o grupo **contabilidade**.  
   - Permissão de **atualização** da coluna `numero` da tabela **contas** para a *role* **jsilva**.  
   - Permissão de **inserção e exclusão** na tabela **contas**, com possibilidade de repassar o privilégio, para a *role* **moliveira**.  


## 1. Concessão de Permissão ao Grupo

**Conexão com o usuário gerente:**

```bash
psql -U gerente -d sis_contabil
```


```sql
GRANT USAGE ON SCHEMA controladoria TO contabilidade;
```

### 1\.1 Resultado da Execução no terminal

```bash
[postgres@vm02 vagrant]$ psql -U gerente -d sis_contabil
psql (17.2)
Type "help" for help.

sis_contabil=> \dn+ controladoria
                        List of schemas
     Name      |  Owner  |   Access privileges   | Description 
---------------+---------+-----------------------+-------------
 controladoria | gerente | gerente=UC/gerente   +| 
               |         | controller=UC/gerente | 
(1 row)

sis_contabil=> GRANT USAGE ON SCHEMA controladoria TO contabilidade;
GRANT
sis_contabil=> \dn+ controladoria
                         List of schemas
     Name      |  Owner  |    Access privileges    | Description 
---------------+---------+-------------------------+-------------
 controladoria | gerente | gerente=UC/gerente     +| 
               |         | controller=UC/gerente  +| 
               |         | contabilidade=U/gerente | 
(1 row)

```

---

## 2. Criação da Tabela

**Conexão com o usuário controller:**

```bash
psql -U controller -d sis_contabil
```

**Comando SQL:**

```sql
CREATE TABLE controladoria.contas (
    id INT,
    numero INT,
    responsavel VARCHAR(50)
);
```

### 2\.1 Resultado da Execução no terminal

```bash
[postgres@vm02 vagrant]$ psql -U controller -d sis_contabil
psql (17.2)
Type "help" for help.

sis_contabil=> CREATE TABLE controladoria.contas (
    id INT,
    numero INT,
    responsavel VARCHAR(50)
);
CREATE TABLE
sis_contabil=> \dt controladoria.*
              List of relations
    Schema     |  Name  | Type  |   Owner    
---------------+--------+-------+------------
 controladoria | contas | table | controller
(1 row)

sis_contabil=> 
```

---

## 3. Concessão de Permissões Específicas

**Retornar à conexão com o usuário gerente:**

```bash
psql -U gerente -d sis_contabil
```

**Comandos SQL:**

```sql
-- 1. Permissão de uso do schema controladoria para o grupo contabilidade
GRANT USAGE ON SCHEMA controladoria TO GROUP contabilidade;

-- 2. Permissão de consulta (SELECT) à tabela contas para o grupo contabilidade
GRANT SELECT ON controladoria.contas TO GROUP contabilidade;

-- 3. Permissão de atualização apenas da coluna 'numero' da tabela contas para a role jsilva
GRANT UPDATE (numero) ON controladoria.contas TO jsilva;

-- 4. Permissão de inserção e exclusão na tabela contas,
-- com possibilidade de repassar o privilégio, para a role moliveira
GRANT INSERT, DELETE ON controladoria.contas TO moliveira WITH GRANT OPTION;

```

### 3\.1 Resultado da Execução no terminal

```bash
sis_contabil=> GRANT USAGE ON SCHEMA controladoria TO GROUP contabilidade;
WARNING:  no privileges were granted for "controladoria"
GRANT
sis_contabil=> \dn+ controladoria
                         List of schemas
     Name      |  Owner  |    Access privileges    | Description 
---------------+---------+-------------------------+-------------
 controladoria | gerente | gerente=UC/gerente     +| 
               |         | controller=UC/gerente  +| 
               |         | contabilidade=U/gerente | 
(1 row)

sis_contabil=> GRANT SELECT ON controladoria.contas TO GROUP contabilidade;
GRANT
sis_contabil=> GRANT UPDATE (numero) ON controladoria.contas TO jsilva;
GRANT
sis_contabil=> GRANT INSERT, DELETE ON controladoria.contas TO moliveira WITH GRANT OPTION;
GRANT
sis_contabil=> \dn+ controladoria
                         List of schemas
     Name      |  Owner  |    Access privileges    | Description 
---------------+---------+-------------------------+-------------
 controladoria | gerente | gerente=UC/gerente     +| 
               |         | controller=UC/gerente  +| 
               |         | contabilidade=U/gerente | 
(1 row)
sis_contabil=> SELECT nspname AS schema,
       nspowner::regrole AS owner,
       nspacl
FROM pg_namespace
WHERE nspname = 'controladoria';
    schema     |  owner  |                               nspacl                               
---------------+---------+--------------------------------------------------------------------
 controladoria | gerente | {gerente=UC/gerente,controller=UC/gerente,contabilidade=U/gerente}
(1 row)
sis_contabil=> SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'controladoria'
  AND table_name = 'contas';
    grantee    | privilege_type 
---------------+----------------
 controller    | INSERT
 controller    | SELECT
 controller    | UPDATE
 controller    | DELETE
 controller    | TRUNCATE
 controller    | REFERENCES
 controller    | TRIGGER
 moliveira     | INSERT
 moliveira     | DELETE
 contabilidade | SELECT
(10 rows)
```

### e) Remover usuário

1. **Ação necessária**  
   - Remover o usuário **psouza** do grupo **contabilidade**.

## 1. Remoção do Usuário do Grupo

**Conexão com o usuário gerente:**

```bash
psql -U gerente -d sis_contabil
```

**Comando SQL:**

```sql
REVOKE contabilidade FROM psouza;
```

### 1\.1 Resultado da Execução no terminal

```bash
[postgres@vm02 vagrant]$ psql -U gerente -d sis_contabil
psql (17.2)
Type "help" for help.

sis_contabil=> SELECT u.rolname AS usuario, r.rolname AS role_granted
FROM pg_roles r
JOIN pg_auth_members m ON r.oid = m.roleid
JOIN pg_roles u ON u.oid = m.member
WHERE r.rolname = 'contabilidade';
  usuario  | role_granted  
-----------+---------------
 gerente   | contabilidade
 jsilva    | contabilidade
 moliveira | contabilidade
 psouza    | contabilidade
(4 rows)

sis_contabil=> REVOKE contabilidade FROM psouza;
REVOKE ROLE
sis_contabil=> SELECT u.rolname AS usuario, r.rolname AS role_granted
FROM pg_roles r
JOIN pg_auth_members m ON r.oid = m.roleid
JOIN pg_roles u ON u.oid = m.member
WHERE r.rolname = 'contabilidade';
  usuario  | role_granted  
-----------+---------------
 gerente   | contabilidade
 jsilva    | contabilidade
 moliveira | contabilidade
(3 rows)
```

---

### f) Autenticação

1. **Configuração geral**  
   - Definir autenticação por senha utilizando o método **MD5**.

2. **Regras específicas de acesso**  
   - **Grupo contabilidade**  
     - Base de dados: **sis_contabil**  
     - Rede: **172.15.10.0/24**  
     - Método: **md5**

   - **Usuário contabil**  
     - Base de dados: **sis_contabil**  
     - Servidor: **172.2.18.25/32**  
     - Método: **md5**

   - **Usuário gerente**  
     - Bases: **todas**  
     - Rede: **2001:db8:3003::/48** (IPv6)  
     - Método: **md5**

## 1. Configuração do Arquivo pg_hba.conf

**Localização do arquivo:**

```bash
[postgres@vm02 vagrant]$ psql -c "SHOW hba_file;"
       hba_file       
----------------------
 /db/data/pg_hba.conf
(1 row)
```

**Edição do arquivo:**

```bash
nano /var/lib/pgsql/data/pg_hba.conf
```

---

## 2. Regras de Autenticação

**Adicionar as seguintes linhas ao arquivo `pg_hba.conf`:**

```bash
cat >> /db/data/pg_hba.conf << 'EOF'

# Grupo contabilidade - rede 172.15.10.0/24
host    sis_contabil    +contabilidade    172.15.10.0/24    md5

# Usuário contábil - servidor específico
host    sis_contabil    contábil          172.2.18.25/32    md5

# Usuário gerente - rede IPv6
host    all             gerente           2001:db8:3003::/48    md5
EOF
```
---

## 3. Recarregar Configurações

```bash
psql -c "SELECT pg_reload_conf();"
```

---

## 4. Resultado da Execução no Terminal

```bash
[postgres@vm02 vagrant]$ cat >> /db/data/pg_hba.conf << 'EOF'

# Grupo contabilidade - rede 172.15.10.0/24
host    sis_contabil    +contabilidade    172.15.10.0/24    md5

# Usuário contábil - servidor específico
host    sis_contabil    contábil          172.2.18.25/32    md5

# Usuário gerente - rede IPv6
host    all             gerente           2001:db8:3003::/48    md5
EOF
[postgres@vm02 vagrant]$ tail -10 /db/data/pg_hba.conf
host all all 0.0.0.0/0 trust

# Grupo contabilidade - rede 172.15.10.0/24
host    sis_contabil    +contabilidade    172.15.10.0/24    md5

# Usuário contábil - servidor específico
host    sis_contabil    contábil          172.2.18.25/32    md5

# Usuário gerente - rede IPv6
host    all             gerente           2001:db8:3003::/48    md5
[postgres@vm02 vagrant]$ psql -c "SELECT pg_reload_conf();"
 pg_reload_conf 
----------------
 t
(1 row)
```


### g) Adicionar Dados

1. **Conexão**  
   - Conecte-se com um usuário que possua permissão de **inserir dados** na tabela `controladoria.contas` (conforme definido no item d).

2. **Inserção de registros**  
   ```sql
   INSERT INTO controladoria.contas(id, numero, responsavel) VALUES (1, 1000, 'jsilva');
   INSERT INTO controladoria.contas(id, numero, responsavel) VALUES (2, 2000, 'psouza');
   INSERT INTO controladoria.contas(id, numero, responsavel) VALUES (3, 2000, 'moliveira');
   ```

3. **Habilitar segurança por registro (Row-Level Security)**  
   ```sql
   ALTER TABLE controladoria.contas ENABLE ROW LEVEL SECURITY;
   ```

4. **Criar política de acesso por responsável**  
   - Cada usuário só pode acessar os registros cujo campo `responsavel` corresponda ao seu nome de usuário:
   ```sql
   CREATE POLICY contas_responsavel_policy
   ON controladoria.contas
   FOR ALL
   USING (responsavel = current_user);
   ```

   > Essa política garante que cada usuário veja apenas os registros onde ele é o responsável.

5. **Consulta com usuários específicos**  
   - Conecte-se como `jsilva`, `psouza` ou `moliveira` e execute:
   ```sql
   SELECT * FROM controladoria.contas;
   ```
   - O resultado mostrará apenas os registros cujo `responsavel` seja o usuário conectado.

6. **Consulta com superusuário**  
   - Conecte-se como superusuário (ex.: `controller`) e execute:
   ```sql
   SELECT * FROM controladoria.contas;
   ```
   - O superusuário visualizará **todos os registros**, independentemente da política de segurança.

## 1. Resultado da Execução no Terminal

Abaixo é mostrado a execução direta dos comandos a partir das atividades descritas na letra g)

```bash
[postgres@vm02 vagrant]$ psql -U gerente -d sis_contabil
psql (17.2)
Type "help" for help.

sis_contabil=> SELECT relname AS table_name,
       relacl
FROM pg_class
WHERE relname = 'contas';
 table_name |                                        relacl                                         
------------+---------------------------------------------------------------------------------------
 contas     | {controller=arwdDxtm/controller,contabilidade=r/controller,moliveira=a*d*/controller}
(1 row)

sis_contabil=> exit
[postgres@vm02 vagrant]$ psql -U moliveira -d sis_contabil
psql (17.2)
Type "help" for help.

sis_contabil=> INSERT INTO controladoria.contas(id, numero, responsavel) VALUES (1, 1000, 'jsilva');
INSERT 0 1
sis_contabil=> INSERT INTO controladoria.contas(id, numero, responsavel) VALUES (2, 2000, 'psouza');
INSERT 0 1
sis_contabil=> INSERT INTO controladoria.contas(id, numero, responsavel) VALUES (3, 2000, 'moliveira');
INSERT 0 1
sis_contabil=> ALTER TABLE controladoria.contas ENABLE ROW LEVEL SECURITY;
ERROR:  must be owner of table contas
sis_contabil=> exit
[postgres@vm02 vagrant]$ psql -U controller -d sis_contabil
psql (17.2)
Type "help" for help.

sis_contabil=> ALTER TABLE controladoria.contas ENABLE ROW LEVEL SECURITY;
ALTER TABLE
sis_contabil=>    CREATE POLICY contas_responsavel_policy
   ON controladoria.contas
   FOR ALL
   USING (responsavel = current_user);
CREATE POLICY
sis_contabil=> exit
[postgres@vm02 vagrant]$ psql -U jsilva -d sis_contabil
psql (17.2)
Type "help" for help.

sis_contabil=> SELECT * FROM controladoria.contas;
 id | numero | responsavel 
----+--------+-------------
  1 |   1000 | jsilva
(1 row)

sis_contabil=> exit
[postgres@vm02 vagrant]$ psql -U moliveira -d sis_contabil
psql (17.2)
Type "help" for help.

sis_contabil=> SELECT * FROM controladoria.contas;
 id | numero | responsavel 
----+--------+-------------
  3 |   2000 | moliveira
(1 row)
sis_contabil=> exit
[postgres@vm02 vagrant]$ psql -U controller -d sis_contabil
psql (17.2)
Type "help" for help.

sis_contabil=> SELECT * FROM controladoria.contas;
 id | numero | responsavel 
----+--------+-------------
  1 |   1000 | jsilva
  2 |   2000 | psouza
  3 |   2000 | moliveira
(3 rows)

```