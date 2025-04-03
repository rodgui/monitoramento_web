
# 📡 Monitoramento Simples de Link de Internet

Este projeto permite monitorar a **disponibilidade**, **latência** e **velocidade** da sua conexão com a internet usando um Raspberry Pi (ou qualquer sistema Linux). A visualização dos dados é feita via dashboard web com Flask + Chart.js.

---

## 🚀 Recursos

- Coleta de latência com `fping`
- Coleta de velocidade com `speedtest-cli`
- Dashboard web com gráficos atualizados em tempo real
- Validação automática dos arquivos CSV
- Instalação automatizada com `setup.sh`
- Configuração centralizada via `config.local`
- Agendamento automático via `crontab`

---

## 📂 Requisitos de Estrutura

O projeto deve ser instalado no diretório **`~/monitoramento`**.
 O script `setup.sh` garante que tudo seja instalado corretamente nesse caminho.

---

## 📦 Instalação

Clone o repositório e execute o script de instalação:

```bash
git clone git@github.com:seuusuario/monitoramento_web.git
cd monitoramento_web
chmod +x setup.sh
./setup.sh
```
## 🧪 Modo Dry-Run

Para simular a instalação sem executar nenhum comando real (útil para validação):

```bash
./setup.sh --dry-run
```

## ⚙️ Configuração Local

Após a instalação, você pode personalizar as variáveis de ambiente no arquivo config.local.

Crie a partir do exemplo:

```bash
cp config.local.example config.local
```

Abra e edite conforme sua necessidade:

```bash
nano config.local
```

Exemplo de conteúdo:

```bash
# Porta onde o servidor Flask será executado
PORTA_SERVIDOR=8080
# IP de destino para teste de latência com fping
IP_TESTE=8.8.8.8
# Habilitar (1) ou desabilitar (0) coleta de velocidade com speedtest-cli
COLETA_SPEEDTEST=1
```

## 🖥️ Execução do Dashboard Web
Após configurado, execute o servidor web com:

```bash
cd ~/monitoramento
python3 app.py
```

Acesse no navegador:

```bash
http://<IP_DO_DISPOSITIVO>:<PORTA_SERVIDOR>
```

## ⏱️ Agendamento Automático (via cron)

O setup.sh configura automaticamente o agendamento periódico:

Script: coleta_fping.sh - Intervalo: A cada 5 minutos
Script: coleta_speedtest.sh - Intervalo: A cada 1 hora

Verifique com:
```bash
crontab -l
```

## 🧼 Validação de Dados

Após cada execução de coleta, o script valida_csvs.py é chamado automaticamente para garantir integridade dos arquivos:
	•	ping_log.csv
	•	speedtest_log.csv

Ele remove entradas corrompidas ou incompletas.

## 📁 Estrutura do Projeto

```
monitoramento/
├── app.py                  # Servidor Flask com APIs
├── coleta_fping.sh         # Coleta de latência
├── coleta_speedtest.sh     # Coleta de velocidade
├── config.local            # Configuração personalizada (não versionado)
├── config.local.example    # Exemplo de configuração
├── index.html              # Dashboard web com Chart.js
├── ping_log.csv            # Histórico de latência
├── speedtest_log.csv       # Histórico de velocidade
├── setup.sh                # Script de instalação automatizada
├── valida_csvs.py          # Validador de arquivos CSV
```

## 💬 Colabore

Contribuições são bem-vindas!
	•	🌱 Abra uma issue para relatar bugs ou sugerir melhorias.
	•	🚀 Envie um Pull Request com correções ou novos recursos.
	•	⭐ Dê uma estrela no repositório se achou útil!
