@echo off
echo Iniciando Microsoft Edge com perfil persistente (.edge-agent) e porta 9222...
start "" "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --remote-debugging-port=9222 --user-data-dir="%USERPROFILE%\.edge-agent" --no-first-run --no-default-browser-check
echo Concluido! O Edge esta pronto para conectar ao MCP chrome-devtools.
