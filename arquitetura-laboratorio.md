# 🏗️ Arquitetura do Laboratório

Este documento descreve a montagem do ambiente isolado usado na auditoria de senhas.

---

## 1. Visão geral

| Máquina | Papel | Sistema | Rede |
|---|---|---|---|
| **Host** | Seu computador (roda o VirtualBox) | Windows / macOS / Linux | — |
| **Kali Linux** | Máquina de testes (atacante autorizado) | Kali (Debian) | NAT + Rede interna `labsec` |
| **Metasploitable 2** | Alvo deliberadamente vulnerável | Ubuntu 8.04 (antigo) | Apenas Rede interna `labsec` |

---

## 2. Por que a rede precisa ser isolada — comparação dos modos

| Modo | Internet? | Alcança a rede doméstica? | VMs se enxergam? | Recomendado aqui? |
|---|---|---|---|---|
| **NAT** | ✅ | ❌ | ❌ (isoladas entre si) | Só para dar internet ao Kali |
| **Bridge** | ✅ | ✅ (vira um host real na sua LAN) | ✅ | 🚫 **NUNCA** para o alvo vulnerável |
| **Host-only** | ❌ | ❌ | ✅ (+ host) | ✅ Alternativa válida |
| **Rede interna** | ❌ | ❌ | ✅ (só VMs) | ✅✅ **Escolhido** |

**Decisão:** usamos **Rede interna** (nome `labsec`) entre Kali e Metasploitable — isolamento
máximo. O Metasploitable **nunca** recebe internet nem entra na rede doméstica. O Kali, quando
precisa atualizar, usa um **segundo adaptador em NAT**.

> 🚫 **Regra crítica:** jamais colocar o Metasploitable 2 em **Bridge**. Isso exporia uma máquina
> propositalmente vulnerável à sua rede Wi-Fi/doméstica. Esse é exatamente o erro que o desafio
> manda evitar.

---

## 3. Passo a passo da montagem

### 3.1 Importar o Kali (imagem pronta)

1. Baixe em https://www.kali.org/get-kali/ → aba **Virtual Machines** → **VirtualBox**.
2. Extraia o `.7z`. Dê **duplo clique no arquivo `.vbox`** (ou VirtualBox → *Arquivo → Importar/Adicionar*).
3. Login padrão: **`kali` / `kali`**.

### 3.2 Criar a VM do Metasploitable 2 (a partir do `.vmdk`)

O Metasploitable 2 **não é um instalador**; o `.zip` contém um disco `.vmdk` pronto.

1. Baixe em https://sourceforge.net/projects/metasploitable/ e extraia o `.zip`.
2. VirtualBox → **Novo**:
   - Nome: `Metasploitable2`
   - Tipo: **Linux**, Versão: **Ubuntu (64-bit)** (ou 32-bit se necessário)
   - Memória: 512 MB–1024 MB
   - Disco: **"Usar um arquivo de disco rígido virtual existente"** → selecione o **`Metasploitable.vmdk`** extraído.
3. Conclua. **Não** instale nada — o sistema já está pronto.
4. Login padrão: **`msfadmin` / `msfadmin`**.

### 3.3 Configurar a rede interna

Para **cada** VM: *Configurações → Rede*.

**Metasploitable 2:**
- Adaptador 1: **Conectado a: Rede interna** · Nome: **`labsec`**

**Kali:**
- Adaptador 1: **NAT** (internet para `apt update`)
- Adaptador 2: **Habilitar** → **Rede interna** · Nome: **`labsec`**

> Os dois precisam usar **exatamente o mesmo nome** de rede interna (`labsec`) para se enxergarem.

---

## 4. Identificar IPs e testar conectividade

Ligue as duas VMs.

**No Metasploitable 2** (terminal, login `msfadmin`):
```bash
ifconfig
```
Procure a interface da rede interna (ex.: `eth0`) e anote o `inet addr` (ex.: `10.10.10.5` ou
algo como `192.168.56.x` / `10.0.2.x` dependendo do DHCP).

**No Kali** (terminal):
```bash
ip addr
```
Anote o IP do adaptador da rede interna (geralmente `eth1`, já que `eth0` é o NAT).

**No Kali — testar se o alvo responde:**
```bash
ping -c 4 <IP_DO_METASPLOITABLE>
```

**Resultado esperado (exemplo):**
```
64 bytes from 10.10.10.5: icmp_seq=1 ttl=64 time=0.42 ms
...
4 packets transmitted, 4 received, 0% packet loss
```

> ✅ **0% packet loss = conectividade OK.** Só então siga para o reconhecimento (Etapa 4).

### Erros comuns

| Sintoma | Causa provável | Solução |
|---|---|---|
| `Destination Host Unreachable` | Nomes de rede interna diferentes | Garanta `labsec` idêntico nas duas VMs |
| VM sem IP na rede interna | Sem DHCP na rede interna | Configure IP estático, ou use **Host-only** (tem DHCP do VirtualBox) |
| `ping` some mas serviços não | Firewall do alvo | No Metasploitable 2 geralmente não há; revise adaptadores |

> 💡 **Dica para iniciantes:** se a rede interna não distribuir IP automaticamente, a opção
> **Host-only** é mais amigável (o VirtualBox tem um servidor DHCP próprio). O isolamento continua
> seguro — apenas o seu host passa a enxergar as VMs também.

---

## 5. Observação sobre Apple Silicon (M1/M2/M3)

O VirtualBox executa imagens **x86/x86-64**. Em Macs com **Apple Silicon**, essas imagens não
rodam nativamente. Alternativas:
- Usar um **host x86** (PC Windows/Linux).
- Usar **UTM/QEMU** (emulação), com perda de desempenho.

Documente no projeto qual caminho você seguiu.
