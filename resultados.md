# 📊 Resultados Observados

> ⚠️ **TEMPLATE — a preencher com a saída REAL dos seus testes.**
> Não invente resultados, não declare sucesso sem evidência e **não publique senhas reais**.
> Para credenciais fictícias descobertas no lab, você pode mascarar parcialmente (ex.: `ms****in`).

Para cada cenário, diferencie claramente: **Observado** (o que a saída mostrou), **Hipótese** (o
que você supõe) e **Recomendação** (como corrigir).

---

## Cenário 1 — FTP (Medusa)

| Campo | Conteúdo |
|---|---|
| **Serviço testado** | FTP (21/tcp) no Metasploitable 2 |
| **Objetivo da auditoria** | _(preencher)_ |
| **Configuração utilizada** | `medusa -M ftp -t 1 -f` · wordlists fictícias |
| **Quantidade de tentativas** | _(preencher — nº de usuários × senhas)_ |
| **Resultado observado** | _(preencher — colar a linha SUCCESS/ERROR real)_ |
| **Evidências disponíveis** | `images/ftp-medusa.png` _(a adicionar)_ |
| **Risco identificado** | _(preencher)_ |
| **Impacto potencial** | _(preencher)_ |
| **Limitações do teste** | _(preencher)_ |
| **Recomendação de correção** | _(preencher)_ |
| **Como verificar a correção** | _(preencher)_ |

**Saída real (cole aqui):**
```text
(cole a saída do Medusa aqui)
```

---

## Cenário 2 — DVWA (login web)

| Campo | Conteúdo |
|---|---|
| **Serviço testado** | DVWA (HTTP/80) — nível de segurança: _(Low/Medium/High)_ |
| **Objetivo da auditoria** | _(preencher)_ |
| **Configuração utilizada** | _(script local / tentativa manual)_ |
| **Quantidade de tentativas** | _(preencher)_ |
| **Resultado observado** | _(preencher)_ |
| **Evidências disponíveis** | `images/dvwa-login.png` _(a adicionar)_ |
| **Risco identificado** | _(preencher)_ |
| **Impacto potencial** | _(preencher)_ |
| **Limitações do teste** | _(preencher — ex.: token CSRF impediu automação direta)_ |
| **Recomendação de correção** | _(preencher)_ |
| **Como verificar a correção** | _(preencher — testar nível Medium/High)_ |

**Observações (antes/depois das proteções):**
```text
(descreva a diferença de comportamento entre Low e Medium/High)
```

---

## Cenário 3 — SMB (password spraying / enumeração)

| Campo | Conteúdo |
|---|---|
| **Serviço testado** | SMB (445/tcp) — Samba no Metasploitable 2 |
| **Objetivo da auditoria** | _(preencher)_ |
| **Configuração utilizada** | _(nmap NSE / enum4linux / medusa smbnt)_ |
| **Quantidade de tentativas** | _(preencher)_ |
| **Resultado observado** | _(preencher)_ |
| **Evidências disponíveis** | `images/smb-enum.png` _(a adicionar)_ |
| **Risco identificado** | _(preencher)_ |
| **Impacto potencial** | _(preencher)_ |
| **Limitações do teste** | _(preencher — ex.: versão antiga do Samba, módulo incompatível)_ |
| **Recomendação de correção** | _(preencher)_ |
| **Como verificar a correção** | _(preencher)_ |

**Saída real (cole aqui):**
```text
(cole a saída do nmap/enum4linux/medusa aqui)
```

---

## Resumo consolidado

| Cenário | Viável no lab? | Resultado | Risco principal |
|---|---|---|---|
| FTP | _(sim/não)_ | _(preencher)_ | _(preencher)_ |
| DVWA | _(sim/não)_ | _(preencher)_ | _(preencher)_ |
| SMB | _(sim/parcial/não)_ | _(preencher)_ | _(preencher)_ |

> Se algum cenário **não** foi viável, registre aqui o **motivo técnico** e a **alternativa**
> didática adotada. Isso vale tanto quanto um teste bem-sucedido.
