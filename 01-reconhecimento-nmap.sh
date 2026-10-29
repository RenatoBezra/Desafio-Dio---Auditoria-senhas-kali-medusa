#!/usr/bin/env bash
#
# 01-reconhecimento-nmap.sh
# Reconhecimento de serviços do ALVO no laboratório isolado.
# Uso: ./01-reconhecimento-nmap.sh <IP_DO_ALVO>
# Onde rodar: Kali Linux (alvo = Metasploitable 2 na rede interna)
#
# ⚠️ USO RESTRITO AO LABORATÓRIO PRÓPRIO E AUTORIZADO.
#
set -euo pipefail

ALVO="${1:-}"
if [[ -z "$ALVO" ]]; then
  echo "Uso: $0 <IP_DO_ALVO>  (ex.: $0 10.10.10.5)"
  exit 1
fi

# Confirmação simples de que o alvo é um IP privado de laboratório.
if ! [[ "$ALVO" =~ ^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.) ]]; then
  echo "[ABORTADO] '$ALVO' não parece um IP privado de laboratório."
  echo "Este script só deve ser usado em rede isolada (10.x, 192.168.x, 172.16-31.x)."
  exit 1
fi

echo "[*] Alvo: $ALVO"
echo "[*] Ping de sanidade..."
ping -c 2 "$ALVO" || { echo "[ERRO] Alvo não responde ao ping. Verifique a rede interna."; exit 1; }

echo "[*] Varredura de portas comuns do laboratório (-sV = detecta versões)..."
# Portas: 21 FTP, 22 SSH, 80 HTTP(DVWA), 139/445 SMB, 3306 MySQL
nmap -sV -p 21,22,80,139,445,3306 "$ALVO"

echo
echo "[OK] Reconhecimento concluído. Anote as versões para checar compatibilidade dos módulos."
