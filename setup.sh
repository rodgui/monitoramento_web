#!/bin/bash

MONITOR_DIR="$HOME/monitoramento"
DRY_RUN=false

log() {
    echo -e "[INFO] $1"
}

run() {
    if $DRY_RUN; then
        echo "[dry-run] $1"
    else
        eval "$1"
    fi
}

if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    log "Modo dry-run ativado. Nenhum comando será executado."
fi

log "Criando diretório: $MONITOR_DIR"
run "mkdir -p $MONITOR_DIR"

log "Instalando dependências via apt"
run "sudo apt update"
run "sudo apt install -y fping python3-pip"

log "Instalando speedtest-cli e Flask via pip"
run "pip3 install --user speedtest-cli flask pandas matplotlib"

log "Criando scripts de coleta"
cat << 'EOF' | run "tee $MONITOR_DIR/coleta_fping.sh > /dev/null"
#!/bin/bash
ARQUIVO=~/monitoramento/ping_log.csv
DESTINO="8.8.8.8"
DATA=$(date "+%Y-%m-%d %H:%M:%S")
FPING_RESULT=$(fping -c 5 -q $DESTINO 2>&1 | awk -F'/' '{print $(NF-1)}')
echo "$DATA,$FPING_RESULT" >> "$ARQUIVO"
python3 ~/monitoramento/valida_csvs.py
EOF

cat << 'EOF' | run "tee $MONITOR_DIR/coleta_speedtest.sh > /dev/null"
#!/bin/bash
ARQUIVO=~/monitoramento/speedtest_log.csv
DATA=$(date "+%Y-%m-%d %H:%M:%S")
RESULT=$(speedtest-cli --simple | awk '/Ping/ {ping=$2} /Download/ {down=$2} /Upload/ {up=$2} END {print ping","down","up}')
echo "$DATA,$RESULT" >> "$ARQUIVO"
python3 ~/monitoramento/valida_csvs.py
EOF

log "Criando script de validação de CSV"
cat << 'EOF' | run "tee $MONITOR_DIR/valida_csvs.py > /dev/null"
import os
import pandas as pd
from datetime import datetime

base_dir = os.path.dirname(os.path.abspath(__file__))

def validar_ping_log(path):
    linhas_validas = []
    with open(path, "r") as f:
        for linha in f:
            try:
                partes = linha.strip().split(",")
                if len(partes) != 2:
                    continue
                datetime.strptime(partes[0], "%Y-%m-%d %H:%M:%S")
                float(partes[1])
                linhas_validas.append(linha.strip())
            except:
                continue
    with open(path, "w") as f:
        f.write("\n".join(linhas_validas) + "\n")

def validar_speedtest_log(path):
    linhas_validas = []
    with open(path, "r") as f:
        for linha in f:
            try:
                partes = linha.strip().split(",")
                if len(partes) != 4:
                    continue
                datetime.strptime(partes[0], "%Y-%m-%d %H:%M:%S")
                float(partes[1])
                float(partes[2])
                float(partes[3])
                linhas_validas.append(linha.strip())
            except:
                continue
    with open(path, "w") as f:
        f.write("\n".join(linhas_validas) + "\n")

def main():
    ping_path = os.path.join(base_dir, "ping_log.csv")
    speed_path = os.path.join(base_dir, "speedtest_log.csv")

    if os.path.exists(ping_path):
        validar_ping_log(ping_path)
        print("✅ ping_log.csv validado.")
    if os.path.exists(speed_path):
        validar_speedtest_log(speed_path)
        print("✅ speedtest_log.csv validado.")

if __name__ == "__main__":
    main()
EOF

log "Criando app Flask e dashboard HTML"
cat << 'EOF' | run "tee $MONITOR_DIR/app.py > /dev/null"
from flask import Flask, send_from_directory, jsonify
import pandas as pd
import os

app = Flask(__name__)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

@app.route("/")
def index():
    return send_from_directory(BASE_DIR, "index.html")

@app.route("/latencia")
def latencia():
    path = os.path.join(BASE_DIR, "ping_log.csv")
    if not os.path.exists(path):
        return jsonify({"timestamps": [], "values": []})
    df = pd.read_csv(path, names=["timestamp", "latency"])
    return jsonify({
        "timestamps": df["timestamp"].tolist()[-50:],
        "values": df["latency"].tolist()[-50:]
    })

@app.route("/speed")
def speed():
    path = os.path.join(BASE_DIR, "speedtest_log.csv")
    if not os.path.exists(path):
        return jsonify({"timestamps": [], "download": [], "upload": []})
    df = pd.read_csv(path, names=["timestamp", "ping", "download", "upload"])
    return jsonify({
        "timestamps": df["timestamp"].tolist()[-50:],
        "download": df["download"].tolist()[-50:],
        "upload": df["upload"].tolist()[-50:]
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
EOF

cat << 'EOF' | run "tee $MONITOR_DIR/index.html > /dev/null"
<!DOCTYPE html>
<html>
<head>
    <title>Monitoramento de Internet</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <h2>Latência (fping)</h2>
    <canvas id="latencyChart" width="400" height="150"></canvas>
    <h2>Velocidade (Speedtest)</h2>
    <canvas id="speedChart" width="400" height="150"></canvas>
    <script>
    async function fetchData() {
        try {
            const latencyRes = await fetch('/latencia');
            const latencyData = await latencyRes.json();
            const speedRes = await fetch('/speed');
            const speedData = await speedRes.json();

            const ctx1 = document.getElementById('latencyChart').getContext('2d');
            new Chart(ctx1, {
                type: 'line',
                data: {
                    labels: latencyData.timestamps || [],
                    datasets: [{
                        label: 'Latência (ms)',
                        data: latencyData.values || [],
                        borderColor: 'blue',
                        fill: false
                    }]
                },
                options: { scales: { y: { beginAtZero: true } } }
            });

            const ctx2 = document.getElementById('speedChart').getContext('2d');
            new Chart(ctx2, {
                type: 'line',
                data: {
                    labels: speedData.timestamps || [],
                    datasets: [
                        {
                            label: 'Download (Mbps)',
                            data: speedData.download || [],
                            borderColor: 'green',
                            fill: false
                        },
                        {
                            label: 'Upload (Mbps)',
                            data: speedData.upload || [],
                            borderColor: 'orange',
                            fill: false
                        }
                    ]
                },
                options: { scales: { y: { beginAtZero: true } } }
            });

        } catch (error) {
            console.error("Erro ao carregar dados:", error);
        }
    }
    fetchData();
    </script>
</body>
</html>
EOF

log "Ajustando permissões"
run "chmod +x $MONITOR_DIR/*.sh"

log "Configurando crontab"
CRON_TEMP=$(mktemp)

run "bash -c 'crontab -l > $CRON_TEMP 2>/dev/null || true'"
run "bash -c \"echo '*/5 * * * * /bin/bash $MONITOR_DIR/coleta_fping.sh' >> $CRON_TEMP\""
run "bash -c \"echo '0 * * * * /bin/bash $MONITOR_DIR/coleta_speedtest.sh' >> $CRON_TEMP\""
run "crontab $CRON_TEMP"
run "rm $CRON_TEMP"

log "✅ Setup concluído. Execute com:"
echo "  cd ~/monitoramento && python3 app.py"

log "✅ Para testar dry-run:"
echo "  bash setup.sh --dry-run"
