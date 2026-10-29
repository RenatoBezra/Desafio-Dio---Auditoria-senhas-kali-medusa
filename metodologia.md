# 🧪 Metodologia dos Testes

Conceitos antes dos comandos. Cada cenário é limitado ao laboratório isolado, com **poucas
tentativas**, escopo explícito e **contas fictícias**.

---

## 1. Conceitos fundamentais

### Força bruta vs. Dicionário vs. Password spraying

| Técnica | Como funciona | Risco de bloqueio |
|---|---|---|
| **Força bruta** | Testa **todas** as combinações possíveis de caracteres | Alto (muitas tentativas por conta) |
| **Ataque de dicionário** | Testa uma **lista** de senhas prováveis (wordlist) | Alto por conta |
| **Password spraying** | Testa **1 senha comum** contra **muitos usuários** antes de tentar a próxima | **Baixo** — evita lockout por conta |

> O password spraying é "silencioso" porque faz **poucas tentativas por usuário**, driblando
> políticas de bloqueio. Entender isso é essencial para **projetar a defesa** (monitorar falhas
> distribuídas, não só por conta).

### Autenticação FTP
O FTP (porta 21) autentica com **usuário + senha em texto claro**. Sem TLS, as credenciais
trafegam legíveis na rede — por isso é um serviço ótimo para **estudo didático** e péssimo para
produção.

### O papel do Medusa
**Medusa** é um verificador de login **modular e paralelo**: FTP, SSH, SMB, HTTP, etc., cada um
em um **módulo** (`-M`). Ele **não "quebra" nada por mágica** — apenas tenta credenciais de uma
wordlist e reporta a resposta do serviço. A compatibilidade depende do **módulo existir** na sua
versão e do **protocolo** do alvo.

---

## 2. Ciclo aplicado a cada cenário

1. **Reconhecimento** — `nmap -sV` identifica serviço e versão.
2. **Compatibilidade** — `medusa -d` lista módulos; `medusa -M <mod> -q` mostra opções do módulo.
3. **Wordlist fictícia** — arquivos pequenos em `wordlists/`.
4. **Execução controlada** — `-t 1` (1 thread), lista curta, alvo único.
5. **Observação** — copiar a **saída real** (nunca inventar).
6. **Análise** — risco, impacto, limitações.
7. **Mitigação** — correção + forma de verificar.

---

## 3. Cenário 1 — Auditoria FTP (Medusa)

**Objetivo:** demonstrar que um FTP com senha fraca/padrão cede a um teste de dicionário pequeno.

**Onde:** comandos no **Kali**, alvo = Metasploitable 2.

**Passos:**
```bash
# 1) confirmar que a porta 21 está aberta
nmap -p 21 -sV <ALVO>

# 2) confirmar o módulo ftp do Medusa
medusa -d | grep -i ftp

# 3) auditoria controlada (poucas tentativas)
medusa -h <ALVO> -U wordlists/usuarios-ficticios.txt \
       -P wordlists/senhas-ficticias.txt -M ftp -t 1 -f
```
- `-h` alvo · `-U` lista de usuários · `-P` lista de senhas · `-M ftp` módulo · `-t 1` 1 conexão
  por vez · `-f` para no primeiro sucesso por host.

**Como reconhecer sucesso/falha:** o Medusa marca `ACCOUNT FOUND` com `[SUCCESS]` quando a
credencial é aceita, e `[ERROR]`/sem sucesso quando não. **Registre a linha exata** (sem expor a
senha completa — veja `docs/resultados.md`).

> Validação adicional: confirme o acesso logando manualmente uma vez (`ftp <ALVO>`), para provar
> que o resultado é real e não um falso positivo.

---

## 4. Cenário 2 — DVWA (login web)

**Objetivo:** estudar como um formulário processa credenciais e o que acontece **sem limitação de
tentativas**.

**Pontos conceituais:**
- O login web envia usuário/senha por **HTTP POST**; o servidor compara com o banco.
- Proteções contra tentativas repetidas: **rate limiting**, **CAPTCHA**, **lockout**, **tokens CSRF**.
- No DVWA em nível **Low**, não há essas proteções → serve para observar o comportamento.

> ⚠️ **Medusa nem sempre é compatível com formulários web.** Depende de token CSRF, cookies de
> sessão e dos parâmetros exatos do POST. Se a integração não for viável, a **alternativa didática**
> recomendada é um **script local restrito ao DVWA** (ver `scripts/03-dvwa-teste-login.py`), que
> faz **poucas** tentativas e **documenta** as respostas — sem contornar proteção de sistema real.

**Comparação antes/depois:** teste o DVWA em nível **Low** e depois em **Medium/High**, e
documente a diferença de comportamento (surgimento de token, atraso, bloqueio).

---

## 5. Cenário 3 — Password spraying em SMB

**Objetivo:** entender spraying e enumeração de usuários em SMB (porta 445).

**Passos de verificação (no Kali):**
```bash
# o serviço SMB existe?
nmap -p 139,445 -sV <ALVO>

# enumeração básica de SMB (scripts NSE do nmap)
nmap --script smb-os-discovery,smb-enum-shares -p 445 <ALVO>
```
- Se disponível, ferramentas como `enum4linux` ajudam na enumeração de usuários **no laboratório**.

**Spraying controlado (conceito):** testar **1 senha fictícia** contra a **lista de usuários
fictícios**, poucas tentativas:
```bash
medusa -h <ALVO> -U wordlists/usuarios-ficticios.txt -p 'Senha@123' -M smbnt -t 1
```
- `-p` (minúsculo) = **uma única senha** contra todos os usuários → padrão de **spraying**.

> ⚠️ **Compatibilidade:** o Metasploitable 2 usa um **Samba antigo**. O módulo `smbnt` pode se
> comportar diferente de um Windows real. Se o spraying/enumeração **não** forem viáveis, documente
> o **motivo técnico** (versão do Samba, módulo indisponível) e apresente a enumeração via
> `nmap`/`enum4linux` como **alternativa didática**. **Não** force nem invente resultado.

---

## 6. Princípios de ética e registro

- Apenas **VMs próprias**, rede isolada, **contas fictícias**.
- **Poucas tentativas**, escopo explícito, sem automação indiscriminada.
- **Nunca** afirmar que um acesso foi validado sem a **saída real** + verificação manual.
- Separar com clareza: **observado** × **hipótese** × **recomendação**.
