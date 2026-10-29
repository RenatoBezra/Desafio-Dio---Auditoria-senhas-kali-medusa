#!/usr/bin/env bash
#
# 02-auditoria-ftp-medusa.sh
# Auditoria DIDÁTICA e CONTROLADA de autenticação FTP com Medusa.
# Uso: ./02-auditoria-ftp-medusa.sh <IP_DO_ALVO>
# Onde rodar: Kali Linux (alvo = Metasploitable 2 na rede interna)
#
# Escopo: 1 host, wordlists PEQUENAS e FICTÍCIAS, 1 conexão por vez (-t 1).
# ⚠️ USO RESTRITO AO LABORATÓRIO PRÓPRIO E AUTORIZADO.
#
set -euo pipefail

ALVO="${1:-}"
DIR="$(cd "$(dirname "$0")/.." && pwd)"
USERS="$DIR/wordlists/usuarios-ficticios.txt"
PASS="$DIR/wordlists/senhas-ficticias.txt"

if [[ -z "$ALVO" ]]; then
  echo "Uso: $0 <IP_DO_ALVO>  (ex.: $0 10.10.10.5)"
  exit 1
fi

if ! [[ "$ALVO" =~ ^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.) ]]; then
  echo "[ABORTADO] '$ALVO' não parece um IP privado de laboratório."
  exit 1
fi

[[ -f "$USERS" ]] || { echo "[ERRO] Wordlist de usuários não encontrada: $USERS"; exit 1; }
[[ -f "$PASS"  ]] || { echo "[ERRO] Wordlist de senhas não encontrada: $PASS"; exit 1; }

echo "[*] Confirmando o módulo FTP do Medusa nesta versão..."
medusa -d | grep -i ftp || { echo "[ERRO] Módulo ftp não encontrado. Verifique: medusa -d"; exit 1; }

echo "[*] Alvo: $ALVO | usuários: $(wc -l < "$USERS") | senhas: $(wc -l < "$PASS")"
echo "[*] Iniciando auditoria FTP controlada (-t 1 -f). Registre a saída REAL abaixo."
echo "-----------------------------------------------------------------------"

# -h alvo | -U usuarios | -P senhas | -M ftp | -t 1 (1 conexão) | -f (para no 1º sucesso do host)
medusa -h "$ALVO" -U "$USERS" -P "$PASS" -M ftp -t 1 -f

echo "-----------------------------------------------------------------------"
echo "[OK] Fim da auditoria. Copie a linha SUCCESS/ERROR para docs/resultados.md."
echo "    Valide manualmente qualquer sucesso:  ftp $ALVO"
echo "    NÃO publique a senha completa no repositório."
