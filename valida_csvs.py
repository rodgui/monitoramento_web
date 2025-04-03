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
        print("✅ ping_log.csv validado com sucesso.")
    else:
        print("⚠️ ping_log.csv não encontrado.")

    if os.path.exists(speed_path):
        validar_speedtest_log(speed_path)
        print("✅ speedtest_log.csv validado com sucesso.")
    else:
        print("⚠️ speedtest_log.csv não encontrado.")

if __name__ == "__main__":
    main()
