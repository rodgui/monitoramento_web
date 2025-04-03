#!/bin/bash

CONFIG=~/monitoramento/config.local
[ -f "$CONFIG" ] && source "$CONFIG"

# ❌ Se estiver desativado no config, sai silenciosamente
[ "$COLETA_SPEEDTEST" != "1" ] && exit 0

ARQUIVO=~/monitoramento/speedtest_log.csv
DATA=$(date "+%Y-%m-%d %H:%M:%S")

RESULT=$(speedtest-cli --simple | awk '/Ping/ {ping=$2} /Download/ {down=$2} /Upload/ {up=$2} END {print ping","down","up}')
echo "$DATA,$RESULT" >> "$ARQUIVO"

python3 ~/monitoramento/valida_csvs.py