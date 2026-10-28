# 🌐 Edge / Chrome Authenticated Browser Automation Skill

Skill determinística para agentes de IA (Google Antigravity, Claude Code, Cursor, Cline, Roo, etc.) que permite automatizar e extrair dados de plataformas web usando a sua **sessão real do navegador já autenticada** (Edge ou Chrome via MCP Chrome DevTools).

---

## 🎯 Por que essa skill existe?

Muitas plataformas populares **não têm MCP dedicado ou APIs abertas fáceis** para acessar dados da sua conta pessoal:
- 🏖️ **Airbnb:** favoritos, reservas, histórico de viagens, mensagens de anfitrião.
- 💼 **LinkedIn:** vagas salvas, conexões, candidaturas, feed.
- 📦 **Mercado Livre / Amazon / Shopee:** rastreio de pacotes, histórico de compras, listas de desejos.
- 🎓 **Portais Acadêmicos e Corporativos:** UFSCar, SIGA, Notion, dashboards internos.
- 📺 **YouTube:** histórico, playlists, inscrições.

Sem essa skill, agentes de IA costumam:
1. Alucinar ou tentar buscar informações pessoais no Google público.
2. Desistir dizendo que não têm acesso à plataforma.
3. Ou, pior, tentar pedir sua senha no chat.

**Com esta skill**, o agente sabe exatamente quando inspecionar o seu navegador aberto, aproveita seus cookies/sessões existentes e nunca pede sua senha!

---

## 🔒 Segurança (Protocolo Human-in-the-Loop)

- **Sem risco de vazamento de credenciais:** O agente **NUNCA** pede senhas, **NUNCA** digita credenciais em campos de senha e **NUNCA** tem acesso aos seus tokens brutos.
- **Login assistido:** Se a sessão na página estiver expirada ou deslogada, o agente pausa automaticamente, avisa você no chat para fazer o login/2FA com segurança no navegador e aguarda sua confirmação (`"pronto"` / `"ok"`) antes de continuar.

---

## 🚀 Como Usar

### 1. Inicie seu navegador com a porta de depuração (9222)

Para o agente conseguir interagir com o navegador, ele precisa ser iniciado com a porta de depuração aberta:

#### No Windows:
- **Microsoft Edge:**
  Execute no terminal:
  ```powershell
  start msedge --remote-debugging-port=9222
  ```
  *(Ou dê duplo clique no script incluso `start-edge-debug.bat`)*

- **Google Chrome:**
  Execute no terminal:
  ```powershell
  start chrome --remote-debugging-port=9222
  ```
  *(Ou dê duplo clique no script incluso `start-chrome-debug.bat`)*

#### No macOS / Linux:
```bash
# macOS Edge
open -a "Microsoft Edge" --args --remote-debugging-port=9222

# macOS Chrome
open -a "Google Chrome" --args --remote-debugging-port=9222

# Linux Chrome
google-chrome --remote-debugging-port=9222
```

---

### 2. Configure o MCP `chrome-devtools` no seu agente

Adicione o servidor MCP de Chrome DevTools na configuração de MCPs do seu ambiente (ex: `mcp_config.json`, `claude_desktop_config.json`, ou nas configurações do Antigravity):

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest", "--browser-url=http://127.0.0.1:9222"]
    }
  }
}
```

---

### 3. Instale a Skill no seu Agente

Copie a pasta desta skill ou o arquivo `SKILL.md` para o diretório de skills do seu agente:

- **Antigravity (Global):**
  `~/.gemini/config/skills/edge-browser-automation/SKILL.md`
- **Antigravity (Projeto Local):**
  `.gemini/skills/edge-browser-automation/SKILL.md`
- **Claude / Cursor / outros:**
  Cole as instruções de `SKILL.md` nas regras globais (`CLAUDE.md`, `.cursorrules` ou pasta de skills).

---

## 💡 Exemplos de Prompts para testar

Com o navegador aberto na porta 9222 e logado nas suas contas:

- *"Dê uma olhada nos meus favoritos do Airbnb e liste as casas em Ubatuba."*
- *"Acesse minhas últimas compras no Mercado Livre e veja o status de entrega do pedido mais recente."*
- *"Olhe no meu LinkedIn as últimas vagas salvas para Desenvolvedor Python e resuma os requisitos."*
- *"Verifique minhas notas mais recentes no portal do aluno."*

O agente fará a triagem automática, conectará nas abas do navegador via MCP e extrairá os dados com segurança!
