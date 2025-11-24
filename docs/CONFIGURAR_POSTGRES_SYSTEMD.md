### ✅ Arquivo `/etc/systemd/system/postgresql-17.service`

Antes de iniciar o serviço via systemd, certifique-se de que o processo do PostgreSQL iniciado manualmente pelo script de instalação foi encerrado.  
Isso evita conflitos entre instâncias e garante que o controle do banco seja assumido corretamente pelo systemd.


```ini
[Unit]
Description=PostgreSQL 17 database server
After=network.target

[Service]
Type=forking
User=postgres
Group=postgres
Environment=PGDATA=/usr/local/pgsql/data
ExecStart=/usr/local/pgsql/bin/pg_ctl start -D /usr/local/pgsql/data -l /usr/local/pgsql/logfile
ExecStop=/usr/local/pgsql/bin/pg_ctl stop -D /usr/local/pgsql/data
ExecReload=/usr/local/pgsql/bin/pg_ctl reload -D /usr/local/pgsql/data
PIDFile=/usr/local/pgsql/data/postmaster.pid
Restart=on-failure
TimeoutSec=300

[Install]
WantedBy=multi-user.target
```

---

### 🧩 Etapas para aplicar

1. **Salvar o arquivo**:
   ```bash
   sudo nano /etc/systemd/system/postgresql-17.service
   ```

2. **Recarregar o systemd**:
   ```bash
   sudo systemctl daemon-reexec
   sudo systemctl daemon-reload
   ```

3. **Habilitar e iniciar o serviço**:
   ```bash
   sudo systemctl enable postgresql-17
   sudo systemctl restart postgresql-17
   ```

4. **Verificar status**:
   ```bash
   sudo systemctl status postgresql-17
   ```

5. **📜 Ver logs**
   ```bash
   journalctl -u postgresql-17
   ```

