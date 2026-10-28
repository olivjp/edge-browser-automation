@echo off
echo Iniciando Google Chrome com perfil persistente (.agent-browser-chrome) e porta 9222...
start "" "chrome.exe" --remote-debugging-port=9222 --user-data-dir="%USERPROFILE%\.agent-browser-chrome" --no-first-run --no-default-browser-check
echo Concluido! O Chrome esta pronto para conectar ao MCP chrome-devtools.
