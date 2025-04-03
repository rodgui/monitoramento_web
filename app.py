from flask import Flask, send_from_directory, jsonify
import pandas as pd
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(BASE_DIR, "config.local")

# Carrega variáveis da config.local
if os.path.exists(CONFIG_PATH):
    with open(CONFIG_PATH) as f:
        for line in f:
            if not line.strip() or line.startswith("#"):
                continue
            key, val = line.strip().split("=", 1)
            os.environ[key] = val

PORTA = int(os.getenv("PORTA_SERVIDOR", "8080"))

app = Flask(__name__)

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
    app.run(host="0.0.0.0", port=PORTA)