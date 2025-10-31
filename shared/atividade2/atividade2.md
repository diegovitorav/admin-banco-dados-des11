# Módulo 2 – Operação e configuração

### **Atividade 2.a – Criar conta**

*   Seguindo as instruções fornecidas nesta sessão, crie a conta do usuário postgres e configure as variáveis de ambiente para ele.

* * *

### **Atividade 2.b – Inicialização da área de dados**

*   Faça a inicialização da área de dados do PostgreSQL, seguindo as instruções fornecidas na sessão, com detecção de dados corrompidos.
*   Analise as informações geradas pela inicialização, listando o que é feito durante esta operação.

* * *

### **Atividade 2.c – Inicialização do PostgreSQL**

**Iniciar e parar o PostgreSQL:**

*   Inicie o PostgreSQL informando um arquivo de log;
*   Pare o banco usando o modo smart;
*   Consulte o conteúdo do arquivo de log.

* * *

### **Atividade 2.d – Configurar o arquivo de log**

*   Edite o arquivo de configuração do PostgreSQL e altere o parâmetro `logging_collector` para **ON**;
*   Inicie o PostgreSQL novamente sem informar um arquivo de log;
*   Pare o banco usando o modo **immediate**;
*   Verifique o diretório `PGDATA/log`;
*   Consulte o conteúdo do arquivo de log e verifique as diferenças nas mensagens mostradas no log gerado no item “c”.

* * *

### **Atividade 2.e – Recarregar as configurações**

*   Conecte-se no PostgreSQL com o **psql**;
*   Execute o comando:
    ```sql
    show "work_mem";
    ```
*   Saia do psql;
*   Edite o arquivo de configuração do PostgreSQL, aumentando o parâmetro `work_mem` para **8MB**;
*   Recarregue as configurações do PostgreSQL;
*   Conecte-se novamente com o **psql** e repita o comando acima.

* * *

### **Atividade 2.f**

*   Com base no que foi apresentado, analise qual valor deveria ser definido para o parâmetro `shared_buffers`.
*   Faça o ajuste do `shared_buffers` conforme recomendado;
*   Reinicie o PostgreSQL.

* * *

### **Atividade 2.g – Permitir conexões remotas**

*   Analisando a descrição do parâmetro `listen_addresses` nesta sessão, configure-o para permitir conexões remotas.

* * *

### **Atividade 2.h – Work\_mem**

*   Com base no que foi apresentado nesta sessão, faça a configuração do parâmetro `work_mem`.
*   Utilize o comando disponível que não exige a edição direta do arquivo de configuração.

* * *

### **Atividade 2.i – PAGER**

*   Habilite o scroll horizontal no **psql** com a variável `PAGER`, conforme mostrado na dica ao final do tópico sobre Operação do Banco de Dados.