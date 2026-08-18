#!/bin/bash

# Script principal para empacotar a aplicação VPN IPsec Client como AppImage
# Este script centraliza toda a lógica de empacotamento

set -e  # Sair se qualquer comando falhar

# Definir variáveis
APP_NAME="VPN-IPsec-Client"
APP_VERSION="0.7.0"
APP_DIR="AppDir"
APPIMAGE_NAME="${APP_NAME}-${APP_VERSION}-x86_64.AppImage"
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$BUILD_DIR")")"

# Caminho para o diretório do projeto
cd "$PROJECT_ROOT"

# Mudar para o diretório de build para manter tudo localizado
cd "$BUILD_DIR"

echo "Iniciando processo de empacotamento para AppImage..."

# Verificar se está rodando no Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Este script só pode ser executado no Linux"
    exit 1
fi

# Verificar se as dependências necessárias estão instaladas
command -v python3 >/dev/null 2>&1 || { echo "Python3 é necessário mas não está instalado. Abortando."; exit 1; }
command -v pip >/dev/null 2>&1 || { echo "pip é necessário mas não está instalado. Abortando."; exit 1; }

echo "Criando estrutura do AppDir..."
rm -rf ${APP_DIR}
mkdir -p ${APP_DIR}/usr/bin
mkdir -p ${APP_DIR}/usr/lib/python3/site-packages
mkdir -p ${APP_DIR}/usr/share/applications
mkdir -p ${APP_DIR}/usr/share/icons/hicolor/256x256/apps
mkdir -p ${APP_DIR}/usr/share/icons/hicolor/scalable/apps

echo "Copiando arquivos do projeto..."
cp -r "$PROJECT_ROOT/src" ${APP_DIR}/usr/bin/
cp "$PROJECT_ROOT/main.py" ${APP_DIR}/usr/bin/
cp "$PROJECT_ROOT/requirements.txt" ${APP_DIR}/usr/bin/ 2>/dev/null || echo "requirements.txt não encontrado"

# Copiar ícones da bandeja
mkdir -p ${APP_DIR}/usr/share/icons/hicolor/256x256/apps
cp "$PROJECT_ROOT/src/assets/vpn-green.png" ${APP_DIR}/usr/share/icons/hicolor/256x256/apps/vpn-ipsec-client-green.png 2>/dev/null || true
cp "$PROJECT_ROOT/src/assets/vpn-red.png" ${APP_DIR}/usr/share/icons/hicolor/256x256/apps/vpn-ipsec-client-red.png 2>/dev/null || true
echo "  ✓ Ícones da bandeja copiados"

echo "Criando atalho da aplicação..."
cat > ${APP_DIR}/usr/share/applications/${APP_NAME}.desktop << EOF
[Desktop Entry]
Name=VPN IPsec Client
Exec=VPN-IPsec-Client
Type=Application
Icon=vpn-ipsec-client
StartupWMClass=vpn-ipsec-client
Categories=Network;
Terminal=false
Comment=Cliente VPN IPsec para Linux
EOF

# Gerar ícones PNG se o gerador estiver disponível
ICON_GENERATOR="$PROJECT_ROOT/packaging/generate_icons.py"
if [ -f "$ICON_GENERATOR" ]; then
    echo "Gerando ícones PNG a partir do SVG..."
    if python3 "$ICON_GENERATOR" > /dev/null 2>&1; then
        echo "✓ Ícones PNG gerados com sucesso."
    else
        echo "⚠ AVISO: Falha ao gerar ícones automaticamente."
    fi
else
    echo "⚠ AVISO: Gerador de ícones não encontrado: $ICON_GENERATOR"
fi

echo "Instalando ícones no AppDir..."
# Copiar ícones PNG em múltiplos tamanhos
ICON_SIZES="16x16 24x24 32x32 48x48 64x64 128x128 256x256 512x512"
ICON_SOURCE_DIR="$PROJECT_ROOT/packaging/icons_output/icons/hicolor"

if [ -d "$ICON_SOURCE_DIR" ]; then
    for size in $ICON_SIZES; do
        SRC="$ICON_SOURCE_DIR/$size/apps/vpn-ipsec-client.png"
        if [ -f "$SRC" ]; then
            mkdir -p ${APP_DIR}/usr/share/icons/hicolor/$size/apps
            cp "$SRC" ${APP_DIR}/usr/share/icons/hicolor/$size/apps/
            echo "  ✓ Copiado ícone ${size}.png"
        fi
    done
else
    echo "  ⚠ Diretório de ícones PNG não encontrado, usando apenas SVG."
fi

# Copiar SVG para escalonamento (fallback)
if [ -f "$PROJECT_ROOT/src/assets/icon.svg" ]; then
    mkdir -p ${APP_DIR}/usr/share/icons/hicolor/scalable/apps
    cp "$PROJECT_ROOT/src/assets/icon.svg" ${APP_DIR}/usr/share/icons/hicolor/scalable/apps/vpn-ipsec-client.svg
    echo "  ✓ Copiado SVG para scalable"
else
    # Criar SVG de fallback
    cat > ${APP_DIR}/usr/share/icons/hicolor/scalable/apps/vpn-ipsec-client.svg << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 100 100">
  <rect width="100" height="100" fill="#3498db"/>
  <text x="50" y="55" font-family="Arial" font-size="40" fill="white" text-anchor="middle">VPN</text>
</svg>
EOF
fi

# Copiar ícone para o diretório raiz do AppDir (usar o 256x256 como principal)
if [ -f "$PROJECT_ROOT/packaging/icons_output/icons/hicolor/256x256/apps/vpn-ipsec-client.png" ]; then
    cp "$PROJECT_ROOT/packaging/icons_output/icons/hicolor/256x256/apps/vpn-ipsec-client.png" ${APP_DIR}/vpn-ipsec-client.png
else
    cp ${APP_DIR}/usr/share/icons/hicolor/scalable/apps/vpn-ipsec-client.svg ${APP_DIR}/vpn-ipsec-client.svg
fi

# Copiar o desktop file para o diretório raiz do AppDir
cp ${APP_DIR}/usr/share/applications/${APP_NAME}.desktop ${APP_DIR}/${APP_NAME}.desktop

echo "Instalando dependências no AppDir..."

# Instalar dependências diretamente no AppDir
pip install --target ${APP_DIR}/usr/lib/python3/site-packages -r "$PROJECT_ROOT/requirements.txt"

# Criar script de inicialização
cat > ${APP_DIR}/usr/bin/VPN-IPsec-Client << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PYLIB="${SCRIPT_DIR}/../lib/python3/site-packages"
export PYTHONPATH="${PYLIB}:${PYTHONPATH:-}"
cd "${SCRIPT_DIR}"
exec python3 main.py "$@"
EOF

chmod +x ${APP_DIR}/usr/bin/VPN-IPsec-Client

# Criar AppRun
cat > ${APP_DIR}/AppRun << 'EOF'
#!/bin/bash
APPDIR="$(dirname "$(readlink -f "$0")")"
cd "${APPDIR}/usr/bin"
exec "${APPDIR}/usr/bin/VPN-IPsec-Client" "$@"
EOF

chmod +x ${APP_DIR}/AppRun
chmod +x ${APP_DIR}/usr/bin/VPN-IPsec-Client

echo "Verificando appimagetool..."

# Verificar se o appimagetool existe ou baixar
if [ ! -f "appimagetool.AppImage" ]; then
    echo "Baixando appimagetool..."
    if command -v wget >/dev/null 2>&1; then
        wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" -O appimagetool.AppImage
    elif command -v curl >/dev/null 2>&1; then
        curl -L "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" -o appimagetool.AppImage
    else
        echo "wget ou curl são necessários para baixar o appimagetool. Abortando."
        exit 1
    fi
    chmod +x appimagetool.AppImage
fi

echo "Criando AppImage..."

# Tornar o appimagetool executável e criando o AppImage
chmod +x appimagetool.AppImage
./appimagetool.AppImage --appimage-extract-and-run ${APP_DIR} "${APPIMAGE_NAME}"

echo "AppImage criado com sucesso: ${APPIMAGE_NAME}"
echo "Tamanho: $(du -h "${APPIMAGE_NAME}" | cut -f1)"
echo "O AppImage está pronto para ser distribuído!"

# Limpar o AppDir temporário
rm -rf ${APP_DIR}

echo "Processo de empacotamento concluído com sucesso!"