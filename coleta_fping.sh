#!/bin/bash
CONFIG=~/monitoramento/config.local
[ -f "$CONFIG" ] && source "$CONFIG"

ARQUIVO=~/monitoramento/ping_log.csv
DESTINO=${IP_TESTE:-8.8.8.8}

DATA=$(date "+%Y-%m-%d %H:%M:%S")
FPING_RESULT=$(fping -c 5 -q "$DESTINO" 2>&1 | awk -F'/' '{print $(NF-1)}')
echo "$DATA,$FPING_RESULT" >> "$ARQUIVO"

# Validar após escrever
python3 ~/monitoramento/valida_csvs.py