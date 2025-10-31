# Módulo 2 – Operação e configuração

### **Atividade 2.a – Criar conta**

Para criar a conta do superusuário `postgres` e configurar as variáveis de ambiente, siga estes passos:

1. **Criação do Usuário 'postgres' (como root ou usando sudo):**

   * Crie o usuário e seu grupo:

     ```bash
     sudo useradd --create-home --user-group --shell /bin/bash postgres
     ```
   * Defina uma senha para o novo usuário:

     ```bash
     sudo passwd postgres
     ```
   * (Assumindo que seu diretório de dados será `/db`, conforme os slides, dê a permissão ao usuário `postgres`):

     ```bash
     sudo chown -R postgres /db
     ```

2. **Configurar Variáveis de Ambiente (como usuário postgres):**

   * Faça login como o usuário `postgres`:

     ```bash
     su - postgres
     ```
   * Edite o arquivo `.bashrc` na home do usuário `postgres` (ex: `vi ~/.bashrc`).
   * Adicione as seguintes linhas ao final do arquivo:

     ```bash
     PATH=$PATH:/usr/local/pgsql/bin:$HOME/bin
     PGDATA=/db/data/
     export PATH PGDATA
     ```
   * Para aplicar as variáveis, saia e entre novamente (ou execute `source ~/.bashrc`).

---

### **Atividade 2.b – Inicialização da área de dados**

1. **Executar a Inicialização (como usuário postgres):**

   * Para inicializar a área de dados (definida em `$PGDATA`) com a verificação de consistência (checksums) habilitada, execute:

     ```bash
     initdb --data-checksums
     ```
   * (Se a variável $PGDATA não estiver configurada, você pode especificá-la manualmente: `initdb -D /db/data --data-checksums`).

2. **Análise da Saída (O que é feito durante a operação):**

   * A saída do comando `initdb` informa as seguintes ações:
   * Confirma que os arquivos pertencerão ao usuário "postgres".
   * Define o `locale` (ex: "en_US.UTF-8") e o `encoding` (ex: "UTF8") padrões do cluster.
   * Define a configuração de busca de texto padrão (ex: "english").
   * Confirma que **"Data page checksums are enabled"** (verificação de dados corrompidos).
   * Cria os diretórios e subdiretórios necessários (ex: `/db/data`).
   * Seleciona valores padrões para `max_connections` (100) e `shared_buffers` (128MB).
   * Cria os arquivos de configuração (como `postgresql.conf` e `pg_hba.conf`).
   * Executa scripts de inicialização (bootstrap).
   * Exibe um aviso sobre a configuração de autenticação local (por padrão "trust").
   * Informa que a inicialização foi bem-sucedida e sugere o comando para iniciar o banco.

---

### **Atividade 2.c – Inicialização do PostgreSQL**

1. **Iniciar o PostgreSQL com um arquivo de log (como usuário postgres):**

   * O próprio `initdb` sugere o comando. O utilitário `pg_ctl` é a forma recomendada. Para especificar um arquivo de log, use a opção `-l`:

     ```bash
     pg_ctl -l /db/data/log/meu_logfile.log start
     ```
   * (Note: O caminho `/db/data` é o $PGDATA. O slide sugere `pg_ctl -D /db/data -l logfile start`. Se $PGDATA estiver configurado (Atividade 2.a), o `-D` é opcional).

2. **Parar o banco usando o modo smart (como usuário postgres):**

   * O modo "smart" (sinal TERM) é o padrão "s" do `pg_ctl stop`.

     ```bash
     pg_ctl stop -m s
     ```

3. **Consultar o conteúdo do arquivo de log:**

   * Use um comando Linux como `cat` ou `less`:

     ```bash
     cat /db/data/log/meu_logfile.log
     ```

---

### **Atividade 2.d – Configurar o arquivo de log**

1. **Editar o arquivo de configuração (como usuário postgres):**

   * Abra o `postgresql.conf` no seu diretório `$PGDATA`:

     ```bash
     vi $PGDATA/postgresql.conf
     ```
   * Procure o parâmetro `logging_collector` e altere-o para `ON`:

     ```ini
     logging_collector = on
     ```

2. **Inicie o PostgreSQL (sem informar arquivo de log):**

   * Como o `logging_collector` está ativado, o PostgreSQL gerenciará os logs automaticamente. Use o comando de start padrão:

     ```bash
     pg_ctl start
     ```

3. **Pare o banco usando o modo immediate (como usuário postgres):**

   * O modo "immediate" (sinal QUIT) é a opção "i":

     ```bash
     pg_ctl stop -m i
     ```

4. **Verificar o diretório PGDATA/log e consultar o log:**

   * Liste o conteúdo do diretório de log:

     ```bash
     ls -l $PGDATA/log
     ```
   * Consulte o novo arquivo de log gerado:

     ```bash
     cat $PGDATA/log/postgresql-....log
     ```

5. **Análise das Diferenças:**

   * O log da Atividade 2.c era apenas um redirecionamento da saída padrão (`stdout`/`stderr`).
   * O log da Atividade 2.d, com `logging_collector = on`, é mais completo e inclui PIDs, timestamps e rotação automática.
   * A parada "immediate" gera mensagem de "immediate shutdown", enquanto a "smart" gera "smart shutdown".

---

### **Atividade 2.e – Recarregar as configurações**

1. **Conecte-se e verifique o work_mem (como usuário postgres):**

   ```bash
   psql
   ```

   Dentro do psql:

   ```sql
   show "work_mem";
   ```

   * (O valor padrão deve ser 4MB).

2. **Saia do psql:**

   ```sql
   \q
   ```

3. **Edite o arquivo de configuração (como usuário postgres):**

   ```bash
   vi $PGDATA/postgresql.conf
   ```

   * Altere o parâmetro `work_mem` para 8MB:

     ```ini
     work_mem = 8MB
     ```

4. **Recarregue as configurações do PostgreSQL:**

   ````
   ```bash
   pg_ctl reload
   ```
   ````

5. **Conecte-se e verifique novamente:**

   ```bash
   psql
   ```

   Dentro do psql:

   ```sql
   show "work_mem";
   ```

   * (O valor agora deve refletir "8MB").

---

### **Atividade 2.f – Shared Buffers**

1. **Análise do Valor:**

   * O valor padrão de `shared_buffers` (128MB) é considerado "extremamente baixo".
   * A recomendação para um servidor dedicado é iniciar com **20% a 25% da memória física**.
   * Exemplo: Se o servidor tem 8GB de RAM, 20% são 1.6GB, então `shared_buffers = 1638MB`.

2. **Ajuste do Parâmetro (como usuário postgres):**

   * Edite o arquivo de configuração:

     ```bash
     vi $PGDATA/postgresql.conf
     ```
   * Ajuste o valor:

     ```ini
     shared_buffers = 1638MB
     ```

3. **Reinicie o PostgreSQL:**

   ````
   ```bash
   pg_ctl restart
   ```
   ````

---

### **Atividade 2.g – Permitir conexões remotas**

* Para permitir conexões remotas, edite o `postgresql.conf` e ajuste o parâmetro `listen_addresses`.

1. **Editar o `postgresql.conf` (como usuário postgres):**

   ```bash
   vi $PGDATA/postgresql.conf
   ```
2. **Ajustar o Parâmetro:**

   * Altere o valor de `listen_addresses`:

     ```ini
     listen_addresses = '*'
     ```
3. **Reiniciar o PostgreSQL:**
   `bash
       pg_ctl restart
       `
   *(Nota: também será necessário ajustar o `pg_hba.conf` para permitir conexões externas.)*

---

### **Atividade 2.h – Work_mem (sem editar o arquivo)**

* O comando `ALTER SYSTEM` permite alterar configurações globais sem editar o arquivo `.conf`.

1. **Conecte-se ao psql (como usuário postgres):**

   ```bash
   psql
   ```
2. **Execute o ALTER SYSTEM:**
   `sql
       ALTER SYSTEM SET work_mem = '16MB';
       `
3. **Recarregue a Configuração (via SQL):**
   `sql
       SELECT pg_reload_conf();
       `
4. **Saia e verifique (opcional):**
   `sql
       show "work_mem";
       `

---

### **Atividade 2.i – PAGER**

* A variável `PAGER` controla o comportamento de exibição do `psql`.
  Para habilitar o scroll horizontal (sem quebra de linha), defina a variável no `.bashrc`.

1. **Edite o `.bashrc` (como usuário postgres):**

   ```bash
   vi ~/.bashrc
   ```
2. **Adicione a variável PAGER:**
   `bash
       export PAGER='less -S'
       `

   * Exemplo completo do `.bashrc`:

     ```bash
     PATH=$PATH:/usr/local/pgsql/bin:$HOME/bin
     PGDATA=/db/data/
     export PATH PGDATA
     export PAGER='less -S'
     ```
3. **Aplique as mudanças (ex: `source ~/.bashrc`) e conecte-se ao `psql`.**
   O scroll horizontal estará ativado.
