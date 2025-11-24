# **Módulo 3 – Org. lógica e física dos dados**

## **Atividade 3.a – Criar Base de Dados**

1. Conecte-se ao PostgreSQL com o superusuário.
2. Crie a base de dados **curso**.
3. Liste as bases de dados existentes.

---

## **Atividade 3.b – Criar Schemas**

1. Conecte-se ao PostgreSQL com o superusuário na base **curso**.
2. Crie os schemas **vendas** e **estoque**.
3. Liste os schemas existentes.

---

## **Atividade 3.c – Criar Tablespace**

1. Crie o diretório **/db/data2**.
2. Conecte-se ao PostgreSQL com o superusuário.
3. Crie o tablespace **tbs_dados2**.
4. Utilize o tablespace criando a tabela:

   ```sql
   CREATE TABLE estoque.produto (id int, nome varchar(50));
   ```
5. Mova a tabela para o novo tablespace.

---

## **Atividade 3.d – SEARCH_PATH**

1. Conecte-se ao PostgreSQL com o superusuário na base **curso**.
2. Crie a tabela:

   ```sql
   CREATE TABLE vendas.produto (id int, nome varchar(50));
   ```
3. Defina o search_path:

   ```sql
   SET search_path = vendas, estoque;
   ```
4. Insira dados:

   ```sql
   INSERT INTO produto VALUES (10, 'margarina');
   ```
5. Redefina o search_path:

   ```sql
   SET search_path = estoque;
   ```
6. Insira novamente:

   ```sql
   INSERT INTO produto VALUES (10, 'margarina');
   ```
7. Consulte os dados nas duas tabelas **vendas.produto** e **estoque.produto**.

---

## **Atividade 3.e – Localizar Dados na Estrutura de Diretórios**

1. Acesse e liste o conteúdo do diretório de tablespaces do PostgreSQL.
2. Localize os arquivos correspondentes à tabela **estoque.produto** dentro dos diretórios de tablespaces.

---

## **Atividade 3.f – Executar Script na Base curso**

Execute o script para criar e carregar tabelas na base **curso**:

```bash
psql -d curso < /curso/scripts/curso.sql
```

---

## **Atividade 3.g – Consultar Catálogo para Listar Tabelas**

1. Conecte-se na base **curso**.
2. Escreva uma query que consulte **pg_class** para listar somente tabelas.
3. Escreva outra query que liste apenas tabelas que possuem índice.

---

## **Atividade 3.h – Listar as Visões**

Através do catálogo do PostgreSQL, escreva uma query que liste todas as visões existentes.
