# **Módulo 3 – Org. lógica e física dos dados**


Crie um arquivo de texto com o nome **DES11-Ativ4_[Seu_Nome]** e registre:

* os **comandos utilizados**;
* os **ajustes feitos em arquivos de configuração**;
* o **resultado obtido** em cada etapa.

Envie o arquivo até o prazo estipulado na Agenda do curso.

---

## **a) Criar Roles**

Criar as seguintes roles **com permissão de conexão e senha**:

* gerente
* controller
* jsilva
* moliveira
* psouza
* contábil

Regras adicionais:

1. A role **psouza** deve ser válida por apenas **1 mês**.
2. A role **gerente** deve possuir permissão de:

   * criar bases (**CREATEDB**);
   * criar outras roles (**CREATEROLE**).

---

## **b) Criar Role de Grupo**

Conectado como **gerente**:

1. Criar a role de grupo **contabilidade**.
2. Adicionar ao grupo **contabilidade** as roles:

   * jsilva
   * moliveira
   * psouza

---

## **c) Criar Base e Schema**

Conectado como **gerente**:

1. Criar a base **sis_contabil**.
2. Criar o schema **controladoria**.
3. Conceder à role **controller** permissão para:

   * criar objetos no schema (`CREATE`);
   * utilizar o schema (`USAGE`).

---

## **d) Permissões no Schema e Tabela**

Ainda conectado como **gerente**:

1. Conceder ao grupo **contabilidade**:

   * permissão de usar o schema **controladoria** (`USAGE`).

Conectado como **controller**:

2. Criar a tabela:

```sql
CREATE TABLE controladoria.contas (
    id INT,
    numero INT,
    responsavel VARCHAR(50)
);
```

3. Conceder as seguintes permissões:

* Para o grupo **contabilidade**:

  * permissão de usar o schema (`USAGE`);
  * permissão de consultar a tabela (`SELECT`).

* Para a role **jsilva**:

  * permissão de **UPDATE** somente na coluna **numero**.

* Para a role **moliveira**:

  * permissão de **INSERT** e **DELETE**, **com opção de repassar privilégios** (`WITH GRANT OPTION`).

---

## **e) Remover Usuário do Grupo**

* Remover a role **psouza** do grupo **contabilidade**.

---

## **f) Configurar Autenticação (pg_hba.conf)**

Autorizar autenticação via **MD5** da seguinte forma:

1. Para o grupo **contabilidade**, na base **sis_contabil**, rede **172.15.10.0/24**.
2. Para o usuário **contábil**, na base **sis_contabil**, host **172.2.18.25/32**.
3. Para o usuário **gerente**, em **todas as bases**, rede **2001:db8:3003::/48** (IPv6).

> Registrar no arquivo quais linhas foram adicionadas ao `pg_hba.conf`.

---

## **g) Inserir Dados e Configurar Segurança por Registro (RLS)**

Conecte-se com um usuário autorizado a inserir dados na tabela (ver item d).

1. Inserir os dados:

```sql
INSERT INTO controladoria.contas(id, numero, responsavel) VALUES (1, 1000, 'jsilva');
INSERT INTO controladoria.contas(id, numero, responsavel) VALUES (2, 2000, 'psouza');
INSERT INTO controladoria.contas(id, numero, responsavel) VALUES (2, 2000, 'moliveira');
```

2. Habilitar **RLS – Row Level Security** na tabela:

```sql
ALTER TABLE controladoria.contas ENABLE ROW LEVEL SECURITY;
```

3. Criar política para que **cada usuário só veja os registros cujo responsável seja ele**.

4. Consultar a tabela conectando-se como:

   * jsilva
   * psouza
   * moliveira

5. Depois, conectar como **superusuário** e consultar novamente a tabela.