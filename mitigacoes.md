# 🛡️ Medidas de Mitigação

Para cada risco estudado, como **prevenir** e como **verificar** se a correção funcionou.
Este é o coração defensivo do projeto.

---

## 1. Senhas fracas, previsíveis ou padrão

**Risco:** credenciais como `msfadmin/msfadmin`, `admin/admin`, `123456` são adivinhadas em
segundos por um ataque de dicionário.

**Mitigações:**
- Exigir senhas **longas** (≥ 12–16 caracteres), **únicas** e preferencialmente geradas por
  gerenciador de senhas.
- **Proibir credenciais padrão** — trocar toda senha default na implantação.
- Bloquear senhas conhecidas (listas de senhas vazadas / *have i been pwned*).

**Verificação:** tentar novamente o teste de dicionário fictício → deve **falhar** em todas as
tentativas.

---

## 2. Reutilização de senhas entre contas

**Risco:** uma senha vazada abre várias contas (facilita password spraying).

**Mitigações:**
- Senha **exclusiva por serviço**.
- Monitorar vazamentos e forçar troca quando detectados.

**Verificação:** auditoria periódica; teste de spraying com senha comum → sem sucesso.

---

## 3. Ausência de limitação de tentativas (rate limiting)

**Risco:** o atacante tenta milhares de senhas sem obstáculo (visto no DVWA nível Low).

**Mitigações:**
- **Rate limiting**: limitar tentativas por IP/conta por janela de tempo.
- **Atraso progressivo** (backoff exponencial) após falhas.
- **CAPTCHA** após N falhas.
- **Tokens CSRF** e sessões (dificultam automação cega).

**Verificação:** repetir as tentativas → o serviço deve atrasar/bloquear/exigir CAPTCHA após o
limite (comparar com o comportamento do nível Low).

---

## 4. Autenticação multifator (MFA)

**Risco:** só a senha é um único ponto de falha.

**Mitigações:**
- **MFA** (TOTP, chave de segurança FIDO2) onde aplicável.

**Verificação:** mesmo com a senha correta, o acesso deve exigir o segundo fator.

---

## 5. Monitoramento e alertas

**Risco:** ataques passam despercebidos.

**Mitigações:**
- **Log** de falhas de autenticação.
- **Alertas** para padrões suspeitos (muitas falhas, ou **1 senha** contra **muitos usuários** =
  padrão de spraying).
- Ferramentas como `fail2ban` para banir IPs com falhas repetidas.

**Verificação:** gerar falhas controladas → confirmar que o log registra e o alerta dispara.

---

## 6. Redução de superfície de ataque

**Risco:** serviços inseguros ou desnecessários expostos (FTP em texto claro, SMB legado).

**Mitigações:**
- **Desativar serviços desnecessários**.
- Substituir protocolos inseguros: **FTP → SFTP/FTPS**, SMBv1 → versões atuais.
- **Firewall** e **segmentação de rede** (acesso só de onde é necessário).
- **Atualizar** e aplicar **configuração segura** (hardening).

**Verificação:** `nmap` após o hardening → portas desnecessárias fechadas; serviços atualizados.

---

## 7. Políticas de bloqueio que evitam abuso (anti-DoS por lockout)

**Risco:** um lockout agressivo pode ser usado para **negar serviço** (travar contas de propósito).

**Mitigações:**
- Preferir **atraso progressivo** e bloqueio por **IP/origem**, não só por conta.
- Lockouts temporários com desbloqueio automático.
- Alertar o usuário legítimo sem travar indefinidamente.

**Verificação:** simular falhas distribuídas → contas legítimas continuam acessíveis; atacante é
contido.

---

## Tabela-resumo

| Risco | Mitigação principal | Como verificar |
|---|---|---|
| Senha fraca/padrão | Senhas fortes + proibir default | Dicionário falha |
| Reutilização | Senha única por serviço | Spraying falha |
| Sem rate limiting | Rate limit + backoff + CAPTCHA | Bloqueio após N falhas |
| Só senha | MFA | 2º fator exigido |
| Sem visibilidade | Logs + alertas + fail2ban | Alerta dispara |
| Serviços inseguros | Desativar/atualizar/segmentar | nmap pós-hardening |
| Lockout abusivo | Backoff + bloqueio por IP | Conta legítima acessível |
