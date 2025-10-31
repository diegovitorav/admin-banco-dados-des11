

### **Atividade 3.a – Criar base de dados**

*   Conecte-se ao PostgreSQL com o superusuário;
*   Crie a base ‘curso’;
*   Liste as bases de dados existentes.

* * *

### **Atividade 3.b – Criar schemas**

*   Conecte-se ao PostgreSQL com o superusuário na base curso;
*   Crie os schemas ‘vendas’ e ‘estoque’;
*   Liste os schemas existentes.

* * *

### **Atividade 3.c – Criar tablespace**

*   Crie o diretório `/db/data2`;
*   Conecte-se ao PostgreSQL com o superusuário;
*   Crie o tablespace “tbs\_dados2”;
*   Use o tablespace;
*   Crie uma tabela com o seguinte código:
    ```sql
    CREATE TABLE estoque.produto (id int, nome varchar(50));
    ```
*   Mova a tabela para o novo tablespace.

* * *

### **Atividade 3.d – SEARCH\_PATH**

*   Conecte-se ao PostgreSQL com o superusuário na base curso;
*   Crie uma tabela com o seguinte código:
    ```sql
    CREATE TABLE vendas.produto (id int, nome varchar(50));
    ```
*   Defina a variável `search_path`:
    ```sql
    SET search_path = vendas, estoque;
    ```
*   Insira dados na tabela produto:
    ```sql
    INSERT INTO produto VALUES(10, ’margarina’);
    ```
*   Redefina a variável `search_path`:
    ```sql
    SET search_path = estoque;
    ```
*   Insira dados novamente na tabela produto:
    ```sql
    INSERT INTO produto VALUES(10, ’margarina’);
    ```
*   Consulte os dados nas duas tabelas.

* * *

### **Atividade 3.e – Localizar dados na estrutura de diretórios**

*   Acesse e liste o conteúdo do diretório de tablespaces;
*   Encontre os arquivos da tabela `estoque.produto` nos diretórios.

* * *

### **Atividade 3.f – Executar script na tabela curso**

*   Executa o seguinte script para criar e carregar tabelas na base curso:
    ```bash
    $ psql -d curso < /curso/scripts/curso.sql
    ```

* * *

### **Atividade 3.g – Consultar catálogo para listar as tabelas**

*   Conecte na base curso;
*   Escreva uma query que consulte a tabela do catálogo `pg_class` para listar apenas as tabelas;
*   Escreva outra query para listar apenas as tabelas que possuem índice.

* * *

### **Atividade 3.h – Listar as visões**

*   Através do catálogo, escreva uma query que liste as visões existentes.
