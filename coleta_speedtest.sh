#!/bin/bash
ARQUIVO=~/monitoramento/speedtest_log.csv

DATA=$(date "+%Y-%m-%d %H:%M:%S")
RESULT=$(speedtest-cli --simple | awk '/Ping/ {ping=$2} /Download/ {down=$2} /Upload/ {up=$2} END {print ping","down","up}')

echo "$DATA,$RESULT" >> "$ARQUIVO"

# Validar após escrever
python3 ~/monitoramento/valida_csvs.py
