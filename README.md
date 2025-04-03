# Monitoramento Simples de Link de Internet

Este projeto permite monitorar a **disponibilidade**, **latência** e **velocidade** da sua conexão com a internet usando um Raspberry Pi (ou qualquer Linux), `fping`, `speedtest-cli` e visualização via Flask + Chart.js.

## Recursos

- Coleta de latência via `fping`
- Coleta de velocidade com `speedtest-cli`
- Dashboard web com gráficos em tempo real (Chart.js)
- Validação automática dos arquivos CSV
- Instalação automatizada via `setup.sh`

## Instalação

```bash
chmod +x setup.sh
./setup.sh
