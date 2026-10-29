#!/usr/bin/env bash
#
# 04-smb-enumeracao.sh
# Verificação e enumeração DIDÁTICA de SMB no laboratório isolado.
# Uso: ./04-smb-enumeracao.sh <IP_DO_ALVO>
# Onde rodar: Kali Linux (alvo = Metasploitable 2 na rede interna)
#
# Objetivo: confirmar se o SMB existe, descobrir versão e enumerar
# compartilhamentos/usuários para estudo (base do password spraying).
# ⚠️ USO RESTRITO AO LABORATÓRIO PRÓPRIO E AUTORIZADO.
#
set -euo pipefail

ALVO="${1:-}"
if [[ -z "$ALVO" ]]; then
  echo "Uso: $0 <IP_DO_ALVO>  (ex.: $0 10.10.10.5)"
  exit 1
fi

if ! [[ "$ALVO" =~ ^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.) ]]; then
  echo "[ABORTADO] '$ALVO' não parece um IP privado de laboratório."
  exit 1
fi

echo "[*] 1) O serviço SMB está presente? (139/445)"
nmap -p 139,445 -sV "$ALVO"

echo
echo "[*] 2) Descoberta de SO e compartilhamentos via scripts NSE do nmap"
nmap --script smb-os-discovery,smb-enum-shares,smb-enum-users -p 445 "$ALVO" || \
  echo "[aviso] Alguns scripts NSE podem não retornar dados no Samba antigo do Metasploitable."

echo
echo "[*] 3) (Opcional) Enumeração com enum4linux, se instalado"
if command -v enum4linux >/dev/null 2>&1; then
  enum4linux -U "$ALVO" || echo "[aviso] enum4linux retornou com avisos."
else
  echo "    enum4linux não instalado. Instale com: sudo apt install -y enum4linux"
fi

echo
echo "[OK] Enumeração concluída. Se o spraying NÃO for viável (versão/módulo incompatível),"
echo "    documente o MOTIVO em docs/resultados.md e use esta enumeração como alternativa didática."
echo
echo "    Exemplo de password spraying CONTROLADO (1 senha fictícia x vários usuários):"
echo "    medusa -h $ALVO -U wordlists/usuarios-ficticios.txt -p 'Senha@123' -M smbnt -t 1"
