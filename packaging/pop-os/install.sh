#!/bin/bash
# =============================================================================
#  Instalador do Cliente VPN IPsec para Pop!_OS
# =============================================================================
#  Pop!_OS é baseado em Ubuntu/Debian e usa apt como gerenciador de pacotes.
#  Este script instala strongSwan, cria um venv isolado com PySide6,
#  configura o sudo NOPASSWD para "ipsec" e instala o lançador do app.
#
#  Uso:  sudo ./install.sh
# =============================================================================

set -e

APP_NAME="vpn-ipsec-client"
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$BUILD_DIR")")"

export SUDO_USER="${SUDO_USER:-$USER}"
TARGET_USER="${SUDO_USER:-root}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
TARGET_HOME="${TARGET_HOME:-/home/$TARGET_USER}"
VENV_BASE="${XDG_DATA_HOME:-$TARGET_HOME/.local/share}/vpn-ipsec-client"
VENV_DIR="$VENV_BASE/venv"

# --- Verificar ambiente Pop!_OS / Ubuntu / Debian --------------------------------
echo "==> Verificando ambiente (Pop!_OS / Ubuntu / Debian)..."
if ! command -v apt >/dev/null 2>&1; then
    echo "ERRO: Este script é para Pop!_OS / Ubuntu / Debian (apt)." >&2
    echo "      Não encontrei o comando 'apt'." >&2
    exit 1
fi

if [ "$(id -u)" != "0" ]; then
    echo "ERRO: Execute com sudo:  sudo $0" >&2
    exit 1
fi

echo "============================================="
echo " Instalador VPN IPsec para Pop!_OS"
echo " Usuário alvo: $TARGET_USER"
echo "============================================="

# --- 1) strongSwan via apt ---------------------------------------------------
echo ""
echo "==> [1/4] Instalando strongSwan via apt..."
apt-get update -qq

PACKAGES=(strongswan strongswan-pki strongswan-swanctl libstrongswan-extra-plugins python3.12-venv libxcb-cursor0 libxcb-xinerama0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-shape0 libxkbcommon-x11-0)
MISSING=()
for p in "${PACKAGES[@]}"; do
    if ! dpkg -s "$p" >/dev/null 2>&1; then
        MISSING+=("$p")
    fi
done

if [ "${#MISSING[@]}" -gt 0 ]; then
    echo "    Pacotes ausentes: ${MISSING[*]}"
    apt-get install -y -qq "${MISSING[@]}"
    echo "    OK: strongSwan instalado."
else
    echo "    strongSwan já está instalado."
fi

# Detectar binário ipsec
if ! IPSEC_BIN="$(command -v ipsec)"; then
    IPSEC_BIN="/usr/sbin/ipsec"
fi
echo "    Binário ipsec: $IPSEC_BIN"

# --- 2) Ambiente virtual com PySide6 ------------------------------------------
echo ""
echo "==> [2/4] Criando venv isolado em $VENV_DIR..."
mkdir -p "$VENV_BASE"
if [ ! -x "$VENV_DIR/bin/python" ]; then
    python3 -m venv "$VENV_DIR"
fi
chown -R "$TARGET_USER:$TARGET_USER" "$VENV_BASE"
"$VENV_DIR/bin/pip" install --upgrade pip >/dev/null 2>&1 || true
"$VENV_DIR/bin/pip" install -r "$PROJECT_ROOT/requirements.txt"

# --- 3) Regra sudo NOPASSWD para ipsec ----------------------------------------
echo ""
echo "==> [3/4] Configurando sudo NOPASSWD para $TARGET_USER..."
SUDOERS_FILE="/etc/sudoers.d/$APP_NAME"
SWANCTL_BIN="$(command -v swanctl || true)"
SUDO_CMDS="$IPSEC_BIN"
[ -n "$SWANCTL_BIN" ] && SUDO_CMDS="$SUDO_CMDS, $SWANCTL_BIN"
cat > "${SUDOERS_FILE}.tmp" <<EOF
# Permite ao usuário executar o comando 'ipsec' sem senha (VPN Manager)
$TARGET_USER ALL=(root) NOPASSWD: $SUDO_CMDS
EOF
chmod 440 "${SUDOERS_FILE}.tmp"
if visudo -c -f "${SUDOERS_FILE}.tmp" >/dev/null 2>&1; then
    mv "${SUDOERS_FILE}.tmp" "$SUDOERS_FILE"
    echo "    OK: $SUDOERS_FILE"
else
    rm -f "${SUDOERS_FILE}.tmp"
    echo "    ERRO: regra de sudoers inválida. Configure manualmente:" >&2
    echo "         sudo visudo -f $SUDOERS_FILE" >&2
    echo "         $TARGET_USER ALL=(root) NOPASSWD: $SUDO_CMDS" >&2
fi

# --- 4) Launcher + entrada no menu + config de exemplo ------------------------
echo ""
echo "==> [4/4] Instalando launcher e desktop entry..."

# Launcher em /usr/local/bin
cat > /usr/local/bin/$APP_NAME << EOF
#!/bin/bash
# Lança o VPN IPsec Client a partir do venv isolado.
export VPN_IPSEC_CONF="\${VPN_IPSEC_CONF:-/etc/ipsec.conf}"
export VPN_IPSEC_D_PATH="\${VPN_IPSEC_D_PATH:-/etc/ipsec.d}"
export VPN_IPSEC_BIN="\${VPN_IPSEC_BIN:-$IPSEC_BIN}"
cd "$PROJECT_ROOT"
exec "$VENV_DIR/bin/python" main.py "\$@"
EOF
chmod 755 /usr/local/bin/$APP_NAME

# Remover launchers órfãos
rm -f "$TARGET_HOME/.local/bin/$APP_NAME" "$TARGET_HOME/bin/$APP_NAME"
echo "    Launchers órfãos removidos (se existiam em ~/.local/bin ou ~/bin)."

# Desktop entry
if [ -d "$TARGET_HOME/.local/share/applications" ]; then
    DESKTOP_DIR="$TARGET_HOME/.local/share/applications"
else
    DESKTOP_DIR="/usr/share/applications"
fi
mkdir -p "$DESKTOP_DIR"

# Ícone
ICON_DIR="$TARGET_HOME/.local/share/icons/hicolor/scalable/apps"
mkdir -p "$ICON_DIR"
if [ -f "$PROJECT_ROOT/src/assets/icon.svg" ]; then
    cp "$PROJECT_ROOT/src/assets/icon.svg" "$ICON_DIR/$APP_NAME.svg" 2>/dev/null || true
fi
ICON_PATH="$ICON_DIR/$APP_NAME.svg"

# Ícones da bandeja
TRAY_ICON_DIR="$TARGET_HOME/.local/share/icons/hicolor/256x256/apps"
mkdir -p "$TRAY_ICON_DIR"
cp "$PROJECT_ROOT/src/assets/vpn-green.png" "$TRAY_ICON_DIR/$APP_NAME-green.png" 2>/dev/null || true
cp "$PROJECT_ROOT/src/assets/vpn-red.png" "$TRAY_ICON_DIR/$APP_NAME-red.png" 2>/dev/null || true
echo "    Ícones da bandeja copiados para $TRAY_ICON_DIR"

cat > "$DESKTOP_DIR/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Name=VPN IPsec Client
Comment=Cliente VPN IPsec (Fortigate) para Linux
Exec=/usr/local/bin/$APP_NAME
Terminal=false
Type=Application
Categories=Network;
StartupNotify=true
StartupWMClass=vpn-ipsec-client
Icon=$APP_NAME
EOF
chmod 644 "$DESKTOP_DIR/$APP_NAME.desktop"

# --- Habilitar e iniciar strongSwan -------------------------------------------
echo ""
echo "==> Habilitando serviço strongSwan..."
systemctl enable strongswan-starter 2>/dev/null || true
systemctl start strongswan-starter 2>/dev/null || true

echo ""
echo "============================================="
echo " Instalação concluída!"
echo "============================================="
echo ""
echo " Para configurar sua VPN, edite /etc/ipsec.conf."
echo " Exemplo em: packaging/pop-os/example.ipsec.conf"
echo ""
echo " Para executar a GUI:  $APP_NAME"
echo "============================================="
