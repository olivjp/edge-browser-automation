---
name: edge-browser-automation
description: >-
  Deterministic browser automation and web extraction using the user's running
  Microsoft Edge browser (http://127.0.0.1:9222 via chrome-devtools MCP). Use
  whenever the user asks to access their personal accounts, check orders,
  wishlists, cart, favorites, posts, or private sessions (Airbnb, Mercado Livre, LinkedIn,
  YouTube, UFSCar, etc.), or automate web tasks. Includes zero-friction Auto-Boot
  when port 9222 is closed and a secure human-in-the-loop hand-off protocol whenever
  login or 2FA is required.
---

# Microsoft Edge Authenticated Browser Automation

This skill establishes the deterministic operating standard for interacting with websites, web applications, and user accounts through the user's **Microsoft Edge** browser on port `9222`.

---

## 1. Environment, Connectivity & Zero-Friction Auto-Boot

* **Active Endpoint:** Microsoft Edge running with `--remote-debugging-port=9222` and persistent profile `--user-data-dir="$env:USERPROFILE\.agent-browser"`, connected to MCP `chrome-devtools`.
* **Session Scope:** Cookies, stored sessions, and logins (Airbnb, LinkedIn, Mercado Livre, etc.) persist permanently inside `.agent-browser` across sessions.
* **Core Directive:** **NEVER** assume an account is inaccessible, **NEVER** divert to indirect sources (e.g. searching Gmail, local files, or public search engines), and **NEVER** ask the user to manually close or open Edge when port `9222` is not listening!

### Mandatory Auto-Boot Protocol (When Port 9222 is Closed)
If `list_pages` fails with `ECONNREFUSED 127.0.0.1:9222`:
1. **DO NOT** ask the user to restart Edge or run a `.bat` file.
2. **Immediately and autonomously** boot the persistent `.agent-browser` browser instance detached from the shell job object using WMI (`Win32_Process.Create`):
   ```powershell
   Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
       CommandLine = '"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --remote-debugging-port=9222 --user-data-dir="' + $env:USERPROFILE + '\.agent-browser" --no-first-run --no-default-browser-check'
   }
   Start-Sleep -Seconds 2
   ```
   *(Why WMI + `--user-data-dir`? Modern Chromium/Edge v136+ requires `--user-data-dir` to enable port 9222, allows launching alongside normal Edge windows without conflict, and `Win32_Process.Create` prevents the browser from being killed when the `run_command` session ends).*
3. Call `list_pages` again and proceed immediately!

---

## 2. Deterministic Intent Routing (Triagem de Execução)

Antes de executar qualquer ação, avalie rigorosamente o fluxo em 3 etapas para não desperdiçar tokens nem abrir o navegador desnecessariamente:

```
[Pedido do Usuário envolvendo dados web ou plataformas]
       │
       ├── 1. A plataforma possui MCP Dedicado instalado e ativo?
       │      (Ex: Gmail, Google Drive, Google Calendar, Google Docs/Sheets, Slack, Obsidian)
       │      └── SIM: Use as ferramentas nativas do MCP (ex: google-workspace, slack, obsidian).
       │               NÃO abra o Edge nem use chrome-devtools.
       │
       ├── 2. A informação é pública e NÃO exige login/sessão do usuário?
       │      (Ex: notícias, documentação técnica, clima, cotações, busca genérica na web)
       │      └── SIM: Use 'search_web' (Google público).
       │               NÃO abra o Edge.
       │
       └── 3. É conta pessoal / privada de plataforma SEM MCP próprio?
              (Ex: Airbnb [favoritos/reservas], Mercado Livre [compras/carrinho],
               LinkedIn [posts/vagas/mensagens], YouTube [histórico/inscrições], Portais Acadêmicos/UFSCar, etc.)
              └── SIM: Chame esta skill e use 'chrome-devtools' no Edge (porta 9222).
                       - Se a porta 9222 estiver fechada: execute o Auto-Boot da Seção 1 automaticamente.
                       - Se a sessão no site estiver deslogada: use o Protocolo Seguro da Seção 3.
```

### Regras de Ouro:
* **Nunca use o Edge para serviços com MCP nativo:** Se o usuário pedir "veja meus e-mails", "minha agenda de hoje" ou "minhas anotações no Obsidian", use o MCP respectivo diretamente.
* **Nunca use o Edge para buscas que dispensam login:** Se a informação puder ser resolvida com busca aberta, não toque nas abas do usuário.
* **Use o Edge sempre que exigir a identidade/sessão do usuário:** Wishlists do Airbnb, posts/vagas do LinkedIn, histórico de compras de marketplaces ou sistemas acadêmicos/corporativos.

---

## 3. Secure Human-in-the-Loop Hand-off Protocol

To protect privacy and credentials (passwords, biometrics, 2FA, SMS codes):

1. **Tab Check (`list_pages`):** Check if the page is already open (auto-booting Edge via Section 1 if port 9222 is closed). If open, reuse `pageId`. If not, navigate via `navigate_page`.
2. **Snapshot Inspection (`take_snapshot`):** Inspect the page elements.
3. **Authentication Check:**
   * **Authenticated (Profile, Dashboard, Dados visíveis):** Proceed with extraction/actions autonomously.
   * **Unauthenticated (Tela de Login, "Entrar", CAPTCHA, 2FA):**
     * **CRITICAL RULE:** **NEVER** ask for passwords, **NEVER** type credentials into password fields.
     * **IMMEDIATELY PAUSE** and send a hand-off message:
       > *"Abri a página de login do [Site] no seu Microsoft Edge. Por favor, faça login com sua conta com segurança no navegador (o login ficará salvo para as próximas vezes) e me mande um 'pronto' ou 'ok' aqui quando terminar para eu continuar."*
     * Stop calling tools and wait for user confirmation.
     * Upon user confirmation, take a fresh snapshot and resume.

---

## 4. Universal Platform Applicability

This protocol applies globally to any domain:

* **Travel & Stays:** Airbnb, Booking, Decolar, companhias aéreas (check-in, voos, wishlists).
* **E-Commerce & Marketplaces:** Mercado Livre, Amazon, Shopee (rastreio, compras, favoritos).
* **Professional & Academic:** LinkedIn (posts, métricas, vagas, conexões), GitHub, Notion, UFSCar / SIGA / Prograd.
* **Financial & Subscription Portals:** Dashboards e extratos onde o login do usuário for necessário.
