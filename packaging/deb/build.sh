#!/bin/bash
# Script para criar um pacote .deb para a aplicação VPN IPsec Client

set -e  # Sair se qualquer comando falhar

# Definir variáveis
APP_NAME="vpn-ipsec-client"
APP_VERSION="0.7.0"
APP_MAINTAINER="VPN IPsec Client Team"
APP_DESCRIPTION="Cliente VPN IPsec para Linux com interface gráfica. Uma aplicação para gerenciar conexões VPN IPsec com uma interface gráfica amigável e integrada ao ambiente Linux."
DEBIAN_PACKAGE_NAME="${APP_NAME}_${APP_VERSION}_amd64.deb"
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$BUILD_DIR")")"
TEMP_DIR=$(mktemp -d)

echo "Iniciando processo de empacotamento para .deb..."
echo "Pacote: $DEBIAN_PACKAGE_NAME"
echo "Diretório temporário: $TEMP_DIR"

# Gerar ícones PNG se não existirem
ICON_GENERATOR="$PROJECT_ROOT/packaging/generate_icons.py"
if [ -f "$ICON_GENERATOR" ]; then
    echo ""
    echo "Gerando ícones PNG a partir do SVG..."
    if python3 "$ICON_GENERATOR" > /dev/null 2>&1; then
        echo "✓ Ícones gerados com sucesso."
    else
        echo "⚠ AVISO: Falha ao gerar ícones automaticamente."
        echo "  Execute manualmente: python3 packaging/generate_icons.py"
        echo "  Continuando com ícones de fallback..."
    fi
else
    echo "⚠ AVISO: Gerador de ícones não encontrado: $ICON_GENERATOR"
    echo "  Ícones PNG não serão incluídos no pacote."
fi

# Verificar se está rodando no Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Este script só pode ser executado no Linux"
    exit 1
fi

# Verificar se dpkg-deb está instalado
if ! command -v dpkg-deb >/dev/null 2>&1; then
    echo "dpkg-deb é necessário mas não está instalado. Abortando."
    echo "Instale com: sudo apt install dpkg-dev"
    exit 1
fi

echo "Criando estrutura do pacote Debian em $TEMP_DIR..."

# Diretórios principais
mkdir -p "$TEMP_DIR/DEBIAN"
mkdir -p "$TEMP_DIR/usr/bin"
mkdir -p "$TEMP_DIR/usr/lib/$APP_NAME"
mkdir -p "$TEMP_DIR/usr/share/applications"
mkdir -p "$TEMP_DIR/usr/share/icons/hicolor"

# Criar arquivo control
cat > "$TEMP_DIR/DEBIAN/control" << EOF
Package: $APP_NAME
Version: $APP_VERSION
Section: net
Priority: optional
Architecture: amd64
Depends: python3, python3-pip, python3-dev, build-essential, strongswan, libstrongswan-extra-plugins, libgl1, libegl1, libxcb-icccm4, libxcb-image0, libxcb-keysyms1, libxcb-randr0, libxcb-render-util0, libxcb-xinerama0, libxcb-xfixes0, libxrender1, libxkbcommon-x11-0
Maintainer: $APP_MAINTAINER
Description: $APP_DESCRIPTION
EOF

echo "Criando scripts de manutenção do pacote (postinst, postrm)..."
# Script post-instalação para instalar dependências Python e atualizar o cache de ícones
cat > "$TEMP_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/sh
set -e

if [ "$1" = "configure" ]; then
    echo "Configurando VPN IPsec Client..."

    # Atualizar cache de ícones
    echo "Atualizando cache de ícones..."
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
    fi

    # Instalar dependências Python
    echo "Instalando dependências Python..."
    APP_DIR="/usr/lib/vpn-ipsec-client"
    if [ -f "$APP_DIR/requirements.txt" ]; then
        echo "Encontrado requirements.txt em $APP_DIR"
        cd "$APP_DIR"
        # Instalar dependências system-wide com --break-system-packages para Ubuntu/Debian
        if python3 -m pip install --break-system-packages -r requirements.txt 2>/dev/null; then
            echo "Dependências Python instaladas com sucesso."
        else
            echo "AVISO: Falha ao instalar dependências Python automaticamente."
            echo "Por favor, instale manualmente com:"
            echo "  sudo pip3 install --break-system-packages -r $APP_DIR/requirements.txt"
        fi
    else
        echo "AVISO: requirements.txt não encontrado em $APP_DIR"
    fi

    # Configurar regra de sudoers para permitir execução de comandos ipsec sem senha
    echo "Configurando regras de sudo para comandos IPsec..."
    SUDOERS_FILE="/etc/sudoers.d/vpn-ipsec-client"

    # Identificar o usuário que instalou o pacote (SUDO_USER) ou o usuário atual
    INSTALLING_USER="${SUDO_USER:-${USER:-root}}"

    # Se não conseguimos identificar o usuário, permitir para o grupo sudo
    if [ -z "$INSTALLING_USER" ] || [ "$INSTALLING_USER" = "root" ]; then
        echo "Criando regra para grupo sudo..."
        cat > "$TEMP_DIR/SUDOERS_TEMP" << SUDOEOF
# Regra para VPN IPsec Client - permitir comandos ipsec sem senha
%sudo ALL=(ALL) NOPASSWD: /usr/sbin/ipsec
%admin ALL=(ALL) NOPASSWD: /usr/sbin/ipsec
SUDOEOF
    else
        echo "Criando regra para usuário $INSTALLING_USER..."
        cat > "$TEMP_DIR/SUDOERS_TEMP" << SUDOEOF
# Regra para VPN IPsec Client - permitir comandos ipsec sem senha
$INSTALLING_USER ALL=(ALL) NOPASSWD: /usr/sbin/ipsec
SUDOEOF
    fi

    # Instalar a regra de sudoers validando com visudo
    if [ -f "$TEMP_DIR/SUDOERS_TEMP" ]; then
        echo "Validando regra de sudoers com visudo..."
        if visudo -c -f "$TEMP_DIR/SUDOERS_TEMP" 2>/dev/null; then
            echo "Regra de sudoers válida. Instalando em $SUDOERS_FILE..."
            cp "$TEMP_DIR/SUDOERS_TEMP" "$SUDOERS_FILE"
            chmod 440 "$SUDOERS_FILE"
            echo "Regra de sudoers instalada com sucesso."
        else
            echo "ERRO: A regra de sudoers gerada é inválida!"
            echo "Não foi possível configurar automaticamente. Por favor, configure manualmente:"
            echo "  sudo visudo -f /etc/sudoers.d/vpn-ipsec-client"
            echo "E adicione a linha:"
            echo "  $INSTALLING_USER ALL=(ALL) NOPASSWD: /usr/sbin/ipsec"
            rm -f "$TEMP_DIR/SUDOERS_TEMP"
            exit 1
        fi
        rm -f "$TEMP_DIR/SUDOERS_TEMP"
    fi

    echo "Configuração concluída!"
fi

exit 0
EOF

# Script post-remoção para atualizar o cache de ícones
cat > "$TEMP_DIR/DEBIAN/postrm" << 'EOF'
#!/bin/sh
set -e

# Remover regra de sudoers se existir
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
    echo "Removendo regra de sudoers do VPN IPsec Client..."
    SUDOERS_FILE="/etc/sudoers.d/vpn-ipsec-client"
    if [ -f "$SUDOERS_FILE" ]; then
        rm -f "$SUDOERS_FILE"
        echo "Regra de sudoers removida."
    fi

    # Atualizar cache de ícones
    echo "Atualizando cache de ícones..."
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
    fi
fi

exit 0
EOF

# Dar permissão de execução para os scripts
chmod 755 "$TEMP_DIR/DEBIAN/postinst"
chmod 755 "$TEMP_DIR/DEBIAN/postrm"

echo "Copiando arquivos da aplicação..."
# Copiar arquivos principais
cp -r "$PROJECT_ROOT/src" "$TEMP_DIR/usr/lib/$APP_NAME/"
cp "$PROJECT_ROOT/main.py" "$TEMP_DIR/usr/lib/$APP_NAME/"
cp "$PROJECT_ROOT/requirements.txt" "$TEMP_DIR/usr/lib/$APP_NAME/" 2>/dev/null || echo "requirements.txt não encontrado"

# Criar script de inicialização
cat > "$TEMP_DIR/usr/bin/$APP_NAME" << 'EOF'
#!/bin/bash
# VPN IPsec Client launcher script

# Caminho para o diretório da aplicação
APP_DIR="/usr/lib/vpn-ipsec-client"

# Verificar se o diretório da aplicação existe
if [ ! -d "$APP_DIR" ]; then
    echo "Erro: Diretório da aplicação não encontrado em $APP_DIR"
    exit 1
fi

# Executar a aplicação
cd "$APP_DIR"
python3 main.py "$@"
EOF

chmod +x "$TEMP_DIR/usr/bin/$APP_NAME"

# Criar atalho da aplicação
cat > "$TEMP_DIR/usr/share/applications/$APP_NAME.desktop" << EOF
[Desktop Entry]
Name=VPN IPsec Client
Exec=$APP_NAME
Type=Application
Icon=vpn-ipsec-client
StartupWMClass=vpn-ipsec-client
Categories=Network;Utility;
Terminal=false
StartupNotify=true
Comment=Cliente VPN IPsec para Linux com interface gráfica
EOF

# Copiar ícones PNG em múltiplos tamanhos
ICON_SIZES="16x16 24x24 32x32 48x48 64x64 128x128 256x256 512x512"
ICON_SOURCE_DIR="$PROJECT_ROOT/packaging/icons_output/icons/hicolor"

if [ -d "$ICON_SOURCE_DIR" ]; then
    echo "Copiando ícones PNG de $ICON_SOURCE_DIR..."
    for size in $ICON_SIZES; do
        SRC="$ICON_SOURCE_DIR/$size/apps/$APP_NAME.png"
        DEST_DIR="$TEMP_DIR/usr/share/icons/hicolor/$size/apps"
        if [ -f "$SRC" ]; then
            mkdir -p "$DEST_DIR"
            cp "$SRC" "$DEST_DIR/"
            echo "  ✓ Copiado ícone ${size}.png"
        else
            echo "  ✗ Ícone ${size}.png não encontrado"
        fi
    done

    # Também copiar o SVG para suporte a escalonamento
    if [ -f "$PROJECT_ROOT/src/assets/icon.svg" ]; then
        mkdir -p "$TEMP_DIR/usr/share/icons/hicolor/scalable/apps"
        cp "$PROJECT_ROOT/src/assets/icon.svg" "$TEMP_DIR/usr/share/icons/hicolor/scalable/apps/$APP_NAME.svg"
        echo "  ✓ Copiado SVG para scalable"
    fi
else
    echo "AVISO: Diretório de ícones PNG não encontrado: $ICON_SOURCE_DIR"
    echo "Usando fallback com ícone SVG simples..."

    # Criar ícone SVG temporário como fallback
    mkdir -p "$TEMP_DIR/usr/share/icons/hicolor/scalable/apps"
    cat > "$TEMP_DIR/usr/share/icons/hicolor/scalable/apps/$APP_NAME.svg" << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 100 100">
  <rect width="100" height="100" fill="#3498db"/>
  <text x="50" y="55" font-family="Arial" font-size="40" fill="white" text-anchor="middle">VPN</text>
</svg>
SVGEOF
fi

# Ajustar permissões
chmod 644 "$TEMP_DIR/usr/share/applications/$APP_NAME.desktop"
# Aplicar permissões em todos os ícones instalados
find "$TEMP_DIR/usr/share/icons" -name "$APP_NAME.*" -exec chmod 644 {} \; 2>/dev/null || true

echo "Estrutura do pacote criada com sucesso. Arquivos:"
find "$TEMP_DIR" -type f | sort

echo "Criando pacote .deb..."
dpkg-deb --build --root-owner-group "$TEMP_DIR" "$BUILD_DIR/$DEBIAN_PACKAGE_NAME"

echo "Pacote .deb criado com sucesso: $BUILD_DIR/$DEBIAN_PACKAGE_NAME"
echo "Tamanho: $(du -h "$BUILD_DIR/$DEBIAN_PACKAGE_NAME" | cut -f1)"

# Limpar diretório temporário
rm -rf "$TEMP_DIR"

echo "Processo de empacotamento .deb concluído com sucesso!"
echo ""
echo "Para instalar o pacote, use:"
echo "  sudo dpkg -i $BUILD_DIR/$DEBIAN_PACKAGE_NAME"
echo ""
echo "Para resolver dependências após a instalação:"
echo "  sudo apt-get install -f"