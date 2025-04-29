#!/bin/bash
echo "=== CONFIGURANDO PROXY COM AUTENTICAÇÃO PARA APT ==="

# Variáveis de proxy
PROXY_USER=""
PROXY_PASS=""
PROXY_HOST=""
PROXY_PORT=""
PROXY_URL="http://${PROXY_USER}:${PROXY_PASS}@${PROXY_HOST}:${PROXY_PORT}/"

# 1. Criar arquivo de configuração do proxy para APT
echo "➤ Escrevendo proxy em /etc/apt/apt.conf.d/95proxy"
cat <<EOF | sudo tee /etc/apt/apt.conf.d/95proxy > /dev/null
Acquire::http::Proxy "${PROXY_URL}";
Acquire::https::Proxy "${PROXY_URL}";
EOF
sudo chmod 644 /etc/apt/apt.conf.d/95proxy

# 2. Remover repositórios problemáticos
echo "➤ Removendo repositórios problemáticos"

# Backups
SOURCES_LIST="/etc/apt/sources.list"
BACKUP_FILE="/etc/apt/sources.list.bkp_$(date +%Y%m%d_%H%M%S)"
sudo cp "$SOURCES_LIST" "$BACKUP_FILE"
echo "   ✓ Backup de sources.list salvo em $BACKUP_FILE"

# Comentando no arquivo principal
sudo sed -i '/repo.mysql.com/ s/^/#/' "$SOURCES_LIST"
sudo sed -i '/repository.spotify.com/ s/^/#/' "$SOURCES_LIST"
sudo sed -i '/download.konghq.com/ s/^/#/' "$SOURCES_LIST"

# Remover ou comentar arquivos extras
echo "   Limpando /etc/apt/sources.list.d/..."
for f in /etc/apt/sources.list.d/*.list; do
    if grep -q -E 'repo.mysql.com|repository.spotify.com|download.konghq.com' "$f"; then
        echo "   → Comentando entradas em: $f"
        sudo sed -i '/repo.mysql.com/ s/^/#/' "$f"
        sudo sed -i '/repository.spotify.com/ s/^/#/' "$f"
        sudo sed -i '/download.konghq.com/ s/^/#/' "$f"
    fi
done

# 3. Executar apt-get update
echo "=== EXECUTANDO apt-get update ==="
sudo apt-get update

# 4. Verificação de sucesso
if [ $? -eq 0 ]; then
    echo "apt-get update executado com sucesso!"
else
    echo "Falha ao executar apt-get update. Verifique se ainda há repositórios inválidos."
fi
