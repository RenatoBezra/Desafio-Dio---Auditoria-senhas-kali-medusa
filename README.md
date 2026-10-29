# 🔐 Auditoria de Senhas com Kali Linux, Medusa e Ambientes Vulneráveis

> Laboratório prático e **isolado** de auditoria de autenticação, desenvolvido como desafio do bootcamp da **[DIO — Digital Innovation One](https://www.dio.me/)**.
> Foco em **segurança defensiva**: entender, em ambiente autorizado, por que senhas fracas são perigosas e **como se proteger**.

![Status](https://img.shields.io/badge/status-laborat%C3%B3rio%20did%C3%A1tico-blue)
![Escopo](https://img.shields.io/badge/escopo-apenas%20VMs%20pr%C3%B3prias-success)
![Uso](https://img.shields.io/badge/uso-%C3%A9tico%20e%20autorizado-important)

---

## 📑 Sumário

1. [Título e contexto](#-1-título-e-contexto)
2. [Objetivos de aprendizagem](#-2-objetivos-de-aprendizagem)
3. [Tecnologias e ferramentas](#-3-tecnologias-e-ferramentas)
4. [Arquitetura do laboratório](#-4-arquitetura-do-laboratório)
5. [Requisitos para reprodução](#-5-requisitos-para-reprodução)
6. [Configuração do ambiente](#-6-configuração-do-ambiente)
7. [Metodologia dos testes](#-7-metodologia-dos-testes)
8. [Cenários: FTP, DVWA e SMB](#-8-cenários-ftp-dvwa-e-smb)
9. [Comandos utilizados e explicações](#-9-comandos-utilizados-e-explicações)
10. [Resultados observados](#-10-resultados-observados)
11. [Evidências e capturas de tela](#-11-evidências-e-capturas-de-tela)
12. [Vulnerabilidades e limitações](#-12-vulnerabilidades-e-limitações-identificadas)
13. [Medidas de mitigação](#-13-medidas-de-mitigação)
14. [Conclusão e aprendizados](#-14-conclusão-e-aprendizados)
15. [Aviso de uso ético](#-15-aviso-de-uso-ético-e-autorizado)
16. [Referências](#-16-referências-oficiais)

---

## 🏷️ 1. Título e contexto

**Auditoria de Senhas com Kali Linux, Medusa e Ambientes Vulneráveis.**

Este repositório documenta a construção de um **laboratório virtual isolado** para o estudo de
**auditoria de autenticação**. O objetivo é demonstrar, de forma **didática, controlada e
reproduzível**, os riscos associados a:

- senhas fracas e previsíveis;
- credenciais padrão (default) não alteradas;
- reutilização de senhas entre contas;
- ausência de limitação de tentativas de login.

O trabalho faz parte de um desafio prático da **DIO** e foi construído com foco em
**segurança defensiva** — ou seja, entender o ataque para saber **como prevenir**.

> ⚠️ **Todos os testes são realizados exclusivamente em máquinas virtuais próprias**, em rede
> isolada, com **contas fictícias** e serviços **deliberadamente vulneráveis** (Metasploitable 2 e
> DVWA). Nenhum sistema real, de terceiros ou da internet é utilizado.

---

## 🎯 2. Objetivos de aprendizagem

Ao concluir este laboratório, o estudante é capaz de:

- [ ] Montar e isolar um laboratório de segurança em VirtualBox.
- [ ] Diferenciar os modos de rede (NAT, Bridge, Host-only, Rede interna) e seus riscos.
- [ ] Realizar reconhecimento de rede e serviços com **Nmap**.
- [ ] Compreender **ataque de força bruta**, **ataque de dicionário** e **password spraying**.
- [ ] Executar uma **auditoria controlada de FTP** com **Medusa**.
- [ ] Estudar autenticação web com o **DVWA** e a ausência de rate limiting.
- [ ] Entender o funcionamento do **SMB** e a enumeração de usuários.
- [ ] Interpretar resultados e propor **medidas de mitigação**.
- [ ] Documentar e publicar um projeto profissional no **GitHub**.

---

## 🧰 3. Tecnologias e ferramentas

| Ferramenta | Papel no laboratório | Referência |
|---|---|---|
| **VirtualBox** | Virtualização das máquinas | https://www.virtualbox.org/ |
| **Kali Linux** | Máquina de testes (atacante autorizado) | https://www.kali.org/ |
| **Metasploitable 2** | Alvo com serviços vulneráveis (FTP, SMB, etc.) | https://docs.rapid7.com/metasploit/metasploitable-2/ |
| **DVWA** | Aplicação web vulnerável para estudo de login | https://github.com/digininja/DVWA |
| **Nmap** | Reconhecimento de rede e serviços | https://nmap.org/book/ |
| **Medusa** | Auditoria de autenticação (brute force modular) | http://foofus.net/goons/jmk/medusa/medusa.html |
| **Git / GitHub** | Versionamento e publicação | https://docs.github.com/ |

---

## 🏗️ 4. Arquitetura do laboratório

```
┌───────────────────────────────────────────────────────────────┐
│                     COMPUTADOR HOSPEDEIRO (HOST)                │
│                        VirtualBox instalado                     │
│                                                                 │
│   ┌─────────────────────────┐     ┌─────────────────────────┐  │
│   │     KALI LINUX          │     │   METASPLOITABLE 2      │  │
│   │  (máquina de testes)    │     │   (alvo vulnerável)     │  │
│   │                         │     │                         │  │
│   │  Adaptador 1: NAT       │     │  Adaptador 1:           │  │
│   │   (internet p/ updates) │     │   REDE INTERNA "labsec" │  │
│   │  Adaptador 2:           │     │                         │  │
│   │   REDE INTERNA "labsec" │◄───►│  Serviços:              │  │
│   │                         │     │   21/FTP  445/SMB ...   │  │
│   │  Ferramentas:           │     │   DVWA (via Apache)     │  │
│   │   nmap, medusa, git     │     │                         │  │
│   └─────────────────────────┘     └─────────────────────────┘  │
│            IP ex.: 10.10.10.X            IP ex.: 10.10.10.Y     │
│                                                                 │
│   🔒 Rede interna "labsec": SEM internet, SEM rede doméstica    │
└───────────────────────────────────────────────────────────────┘
```

Detalhes completos e a justificativa de cada escolha de rede estão em
**[`docs/arquitetura-laboratorio.md`](docs/arquitetura-laboratorio.md)**.

---

## 💻 5. Requisitos para reprodução

- Computador com **virtualização habilitada** na BIOS/UEFI (VT-x / AMD-V).
- **8 GB de RAM** ou mais recomendados (2 VMs rodando).
- **~30 GB** de espaço livre em disco.
- **VirtualBox** (+ Extension Pack opcional).
- Imagens oficiais:
  - **Kali Linux** (imagem pronta para VirtualBox): https://www.kali.org/get-kali/
  - **Metasploitable 2** (`.zip` → `.vmdk`): https://sourceforge.net/projects/metasploitable/

> 💡 Em **Mac com Apple Silicon (M1/M2/M3)** o VirtualBox x86 não executa essas imagens.
> Nesse caso, alternativas são UTM/QEMU ou um host x86. Veja observações em
> [`docs/arquitetura-laboratorio.md`](docs/arquitetura-laboratorio.md).

---

## ⚙️ 6. Configuração do ambiente

O passo a passo detalhado (import do Kali, criação da VM do Metasploitable a partir do `.vmdk`,
configuração da rede interna, identificação de IPs e teste de conectividade) está em
**[`docs/arquitetura-laboratorio.md`](docs/arquitetura-laboratorio.md)**.

Resumo dos comandos de verificação:

```bash
# No Kali e no Metasploitable — descobrir o IP da interface
ip addr            # (Kali)
ifconfig           # (Metasploitable 2, sistema antigo)

# No Kali — testar se o alvo responde
ping -c 4 <IP_DO_METASPLOITABLE>
```

> ✅ **Só avance para os testes depois que o `ping` funcionar.** Sem conectividade na rede
> isolada, nenhum cenário faz sentido.

---

## 🧪 7. Metodologia dos testes

A metodologia completa está em **[`docs/metodologia.md`](docs/metodologia.md)**. Em resumo,
cada cenário segue o ciclo:

1. **Reconhecimento** — identificar o serviço e a versão (Nmap).
2. **Verificação de compatibilidade** — confirmar módulo/ferramenta adequados (`medusa -d`, `medusa -h`).
3. **Preparação** — wordlists **pequenas e fictícias** (`wordlists/`).
4. **Execução controlada** — escopo explícito, poucas tentativas, sem automação indiscriminada.
5. **Observação** — registrar a saída **real** do comando.
6. **Análise** — risco, impacto, limitações.
7. **Mitigação** — como corrigir e como verificar a correção.

---

## 🎯 8. Cenários: FTP, DVWA e SMB

| # | Cenário | Serviço | Técnica estudada | Documentação |
|---|---|---|---|---|
| 1 | Auditoria de autenticação FTP | 21/tcp | Força bruta / dicionário | [metodologia](docs/metodologia.md) · [scripts](scripts/) |
| 2 | Login da aplicação web DVWA | 80/tcp | Tentativas repetidas / rate limiting | [metodologia](docs/metodologia.md) · [scripts](scripts/) |
| 3 | Password spraying em SMB | 445/tcp | Spraying + enumeração de usuários | [metodologia](docs/metodologia.md) · [scripts](scripts/) |

> O detalhamento técnico de cada cenário — incluindo **quando um cenário NÃO é viável** no
> ambiente e qual a **alternativa didática** — está em [`docs/metodologia.md`](docs/metodologia.md).

---

## 💬 9. Comandos utilizados e explicações

Os scripts auxiliares em [`scripts/`](scripts/) contêm **todos os comandos comentados**,
com finalidade, parâmetros e máquina de execução. Exemplos resumidos:

```bash
# Reconhecimento (no Kali) — identifica portas e versões no alvo
nmap -sV -p 21,80,139,445 <IP_DO_METASPLOITABLE>

# Consultar módulos e ajuda do Medusa (no Kali) — confirmar compatibilidade ANTES de testar
medusa -d          # lista os módulos disponíveis
medusa -h          # ajuda geral

# Auditoria FTP controlada (no Kali) — escopo explícito, poucas tentativas
medusa -h <IP_DO_METASPLOITABLE> -U wordlists/usuarios-ficticios.txt \
       -P wordlists/senhas-ficticias.txt -M ftp -t 1
```

> Explicação parâmetro a parâmetro em [`scripts/README.md`](scripts/README.md).

---

## 📊 10. Resultados observados

> ⚠️ **Esta seção deve ser preenchida com a saída REAL dos comandos executados no seu lab.**
> Não inclua credenciais reais nem invente resultados. Use o template em
> **[`docs/resultados.md`](docs/resultados.md)**.

| Cenário | Tentativas | Resultado observado | Evidência |
|---|---|---|---|
| FTP | _(preencher)_ | _(preencher — sucesso/falha conforme saída real)_ | `images/...` |
| DVWA | _(preencher)_ | _(preencher)_ | `images/...` |
| SMB | _(preencher)_ | _(preencher)_ | `images/...` |

---

## 📸 11. Evidências e capturas de tela

As capturas ficam em [`images/`](images/). A lista do que cada print deve comprovar — e **como
ocultar dados sensíveis** — está em [`images/README.md`](images/README.md).

---

## 🐞 12. Vulnerabilidades e limitações identificadas

> Diferencie sempre **resultado observado**, **hipótese** e **recomendação**. Preencha com base
> em evidências reais (ver [`docs/resultados.md`](docs/resultados.md)).

Exemplos de **limitações** típicas do ambiente (preencher conforme o seu caso):

- O módulo X do Medusa pode não existir na versão instalada → documentar e usar alternativa.
- O formulário do DVWA pode exigir token CSRF/sessão → Medusa HTTP pode não ser direto.
- O SMB do Metasploitable 2 (Samba antigo) pode se comportar diferente de um Windows real.

---

## 🛡️ 13. Medidas de mitigação

Resumo (detalhado em [`docs/mitigacoes.md`](docs/mitigacoes.md)):

- 🔑 Senhas **longas, únicas e aleatórias**; proibir senhas padrão.
- 🔐 **Autenticação multifator (MFA)** onde aplicável.
- 🚦 **Limitação de tentativas** (rate limiting) e atraso progressivo.
- 👀 **Monitoramento** de falhas de autenticação e alertas de padrões suspeitos.
- 🧹 **Desativar serviços desnecessários** (ex.: FTP em texto claro).
- 🌐 **Restrição de acesso de rede** (firewall, segmentação).
- 🔄 **Atualização e configuração segura** dos serviços.
- 🧩 Políticas de bloqueio que **evitem bloqueios abusivos** (DoS por lockout).

---

## 🧠 14. Conclusão e aprendizados

> _(Escreva aqui, com suas palavras, o que você aprendeu — isso é o que o instrutor da DIO e um
> entrevistador querem ver.)_ Pontos sugeridos:

- Diferença prática entre força bruta, dicionário e password spraying.
- Por que o **isolamento de rede** é inegociável em um lab ofensivo.
- Como uma única senha fraca ou padrão compromete um serviço inteiro.
- Como as mitigações (MFA, rate limiting, monitoramento) cortam esses riscos.

---

## 📜 15. Aviso de uso ético e autorizado

Este material é **estritamente educacional**. Todas as atividades foram projetadas para
**máquinas virtuais próprias**, em **rede isolada**, com **contas fictícias** e serviços
**deliberadamente vulneráveis**.

**É proibido** utilizar estas técnicas, scripts ou wordlists contra sistemas, redes, contas ou
dados **de terceiros** ou **sem autorização explícita por escrito**. O autor não se responsabiliza
pelo uso indevido. Teste de segurança sem autorização é **crime** (no Brasil, cf. Lei nº 12.737/2012
e Lei nº 14.155/2021).

---

## 📚 16. Referências oficiais

- Kali Linux — https://www.kali.org/
- DVWA — https://github.com/digininja/DVWA
- Medusa — http://foofus.net/goons/jmk/medusa/medusa.html
- Nmap Reference Guide — https://nmap.org/book/
- Metasploitable 2 (Rapid7) — https://docs.rapid7.com/metasploit/metasploitable-2/
- GitHub Docs — https://docs.github.com/
- Sintaxe Markdown do GitHub — https://docs.github.com/pt/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax
- GitHub Quick Start (DIO) — https://github.com/digitalinnovationone/github-quickstart

---

<div align="center">

**Desafio DIO · Segurança Ofensiva Ética · Laboratório Isolado**
Feito com foco em aprendizado defensivo. 🔐

</div>
