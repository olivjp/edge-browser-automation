---
name: edge-browser-automation
description: >-
  Deterministic browser automation and web extraction using the user's running
  Microsoft Edge browser (http://127.0.0.1:9222 via chrome-devtools MCP). Use
  whenever the user asks to access their personal accounts, check orders,
  wishlists, cart, favorites, or private sessions (Airbnb, Mercado Livre, LinkedIn,
  YouTube, UFSCar, etc.), or automate web tasks. Enforces a secure human-in-the-loop
  hand-off protocol whenever login or 2FA is required.
---

# Microsoft Edge Authenticated Browser Automation

This skill establishes the deterministic operating standard for interacting with websites, web applications, and user accounts through the user's live **Microsoft Edge** browser.

---

## 1. Environment & Connectivity

* **Active Endpoint:** Microsoft Edge running with `--remote-debugging-port=9222`, connected to MCP `chrome-devtools`.
* **Session Scope:** The user's active cookies, stored sessions, bookmarks, and accounts are already present in Edge.
* **Core Directive:** **NEVER** assume an account is inaccessible, and **NEVER** divert to indirect sources (e.g. searching Gmail, local files, or public search engines) when the user asks for information from a specific platform or account ("veja meu Airbnb", "minhas compras", "minha conta", "minhas vagas"). Always inspect Edge first!

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
               LinkedIn, YouTube [histórico/inscrições], Portais Acadêmicos/UFSCar, etc.)
              └── SIM: Chame esta skill e use 'chrome-devtools' no Edge (porta 9222).
                       (Se a sessão estiver deslogada, use o Protocolo Seguro da Seção 3).
```

### Regras de Ouro:
* **Nunca use o Edge para serviços com MCP nativo:** Se o usuário pedir "veja meus e-mails", "minha agenda de hoje" ou "minhas anotações no Obsidian", use o MCP respectivo diretamente.
* **Nunca use o Edge para buscas que dispensam login:** Se a informação puder ser resolvida com busca aberta, não toque nas abas do usuário.
* **Use o Edge sempre que exigir a identidade/sessão do usuário:** Wishlists do Airbnb, histórico de compras de marketplaces, redes sociais ou sistemas acadêmicos/corporativos.

---

## 3. Secure Human-in-the-Loop Hand-off Protocol

To protect privacy and credentials (passwords, biometrics, 2FA, SMS codes):

1. **Tab Check (`list_pages`):** Check if the page is already open. If yes, reuse `pageId`. If not, navigate via `navigate_page`.
2. **Snapshot Inspection (`take_snapshot`):** Inspect the page elements.
3. **Authentication Check:**
   * **Authenticated (Profile, Dashboard, Dados visíveis):** Proceed with extraction/actions autonomously.
   * **Unauthenticated (Tela de Login, "Entrar", CAPTCHA, 2FA):**
     * **CRITICAL RULE:** **NEVER** ask for passwords, **NEVER** type credentials into password fields.
     * **IMMEDIATELY PAUSE** and send a hand-off message:
       > *"Abri a página de login do [Site] no seu Microsoft Edge. Por favor, faça login com sua conta com segurança no navegador e me mande uma mensagem rápida aqui (ex: 'pronto' ou 'ok') quando terminar para eu continuar."*
     * Stop calling tools and wait for user confirmation.
     * Upon user confirmation, take a fresh snapshot and resume.

---

## 4. Universal Platform Applicability

This protocol applies globally to any domain:

* **Travel & Stays:** Airbnb, Booking, Decolar, companhias aéreas (check-in, voos, wishlists).
* **E-Commerce & Marketplaces:** Mercado Livre, Amazon, Shopee (rastreio, compras, favoritos).
* **Professional & Academic:** LinkedIn, GitHub, Notion, UFSCar / SIGA / Prograd.
* **Financial & Subscription Portals:** Dashboards e extratos onde o login do usuário for necessário.
