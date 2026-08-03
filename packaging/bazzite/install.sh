#!/bin/bash
# =============================================================================
#  Instalador do Cliente VPN IPsec para Bazzite (Fedora Atomic / OSTree)
# =============================================================================
#  O Bazzite é uma distro baseada em Fedora e imutável (rpm-ostree):
#    - /usr é somente-leitura: a GUI NÃO deve depender de libs em /usr.
#    - strongSwan precisa ser "layer"-ado via rpm-ostree (exige reboot).
#    - /etc e /var são graváveis e persistentes.
#  Este script instala strongSwan, cria um venv isolado com PySide6,
#  configura o sudo NOPASSWD para "ipsec" e instala o lançador do app.
#
#  Uso:  ./install.sh
# =============================================================================

set -e

APP_NAME="vpn-ipsec-client"
VENV_BASE="${XDG_DATA_HOME:-$HOME/.local/share}/vpn-ipsec-client"
VENV_DIR="$VENV_BASE/venv"
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$BUILD_DIR")")"

# --- Aviso de imutabilidade ---------------------------------------------------
echo "==> Verificando ambiente (rpm-ostree)..."
if ! command -v rpm-ostree >/dev/null 2>&1; then
    echo "ERRO: Este script é específico para Bazzite / Fedora Atomic (rpm-ostree)."
    echo "      Não encontrei o comando 'rpm-ostree'." >&2
    exit 1
fi

if [ "$(id -u)" != "0" ]; then
    echo "ERRO: Execute com sudo:  sudo $0" >&2
    exit 1
fi

export SUDO_USER="${SUDO_USER:-$USER}"
TARGET_USER="${SUDO_USER:-root}"

echo "============================================="
echo " Instalador VPN IPsec para Bazzite"
echo " Usuário alvo: $TARGET_USER"
echo "============================================="

# --- 1) strongSwan via rpm-ostree ---------------------------------------------
echo ""
echo "==> [1/4] Instalando strongSwan via rpm-ostree..."
PACKAGES=(strongswan strongswan-charon-nm)
MISSING=()
for p in "${PACKAGES[@]}"; do
    if ! rpm -q "$p" >/dev/null 2>&1; then
        MISSING+=("$p")
    fi
done

if [ "${#MISSING[@]}" -gt 0 ]; then
    echo "    Pacotes ausentes: ${MISSING[*]}"
    echo "    Executando: rpm-ostree install --apply-live ${MISSING[*]}"
    if rpm-ostree install --apply-live "${MISSING[@]}" >/dev/null 2>&1; then
        echo "    OK: strongSwan instalado (aplicado ao vivo)."
    else
        echo "    AVISO: '--apply-live' não disponível. Executando sem live..."
        rpm-ostree install "${MISSING[@]}"
        echo "    OK: strongSwan enfileirado para o boot."
        NEED_REBOOT=1
    fi
else
    echo "    strongSwan já está instalado."
fi

# Garantir PATH do ipsec (strongswan instala em /usr/sbin)
IPSEC_BIN="$(command -v ipsec || echo /usr/sbin/ipsec)"
echo "    Binário ipsec: $IPSEC_BIN"

# --- 2) Ambiente virtual com PySide6 ------------------------------------------
echo ""
echo "==> [2/4] Criando venv isolado em $VENV_DIR..."
mkdir -p "$VENV_DIR"
if [ ! -x "$VENV_DIR/bin/python" ]; then
    python3 -m venv "$VENV_DIR"
fi
"$VENV_DIR/bin/pip" install --upgrade pip >/dev/null 2>&1 || true
"$VENV_DIR/bin/pip" install -r "$PROJECT_ROOT/requirements.txt"

# --- 3) Regra sudo NOPASSWD para ipsec ----------------------------------------
echo ""
echo "==> [3/4] Configurando sudo NOPASSWD para $TARGET_USER..."
SUDOERS_FILE="/etc/sudoers.d/$APP_NAME"
cat > "${SUDOERS_FILE}.tmp" <<EOF
# Permite ao usuário executar o comando 'ipsec' sem senha (VPN Manager)
$TARGET_USER ALL=(ALL) NOPASSWD: $IPSEC_BIN
EOF
chmod 440 "${SUDOERS_FILE}.tmp"
if visudo -c -f "${SUDOERS_FILE}.tmp" >/dev/null 2>&1; then
    mv "${SUDOERS_FILE}.tmp" "$SUDOERS_FILE"
    echo "    OK: $SUDOERS_FILE"
else
    rm -f "${SUDOERS_FILE}.tmp"
    echo "    ERRO: regra de sudoers inválida. Configure manualmente:" >&2
    echo "         sudo visudo -f $SUDOERS_FILE" >&2
    echo "         $TARGET_USER ALL=(ALL) NOPASSWD: $IPSEC_BIN" >&2
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
cd "$PROJECT_ROOT"
exec "$VENV_DIR/bin/python" main.py "\$@"
EOF
chmod 755 /usr/local/bin/$APP_NAME

# Desktop entry para o usuário
if [ -d "$HOME/.local/share/applications" ]; then
    DESKTOP_DIR="$HOME/.local/share/applications"
else
    DESKTOP_DIR="/usr/share/applications"
fi
mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_DIR/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Name=VPN IPsec Client
Comment=Cliente VPN IPsec (Fortigate) para Linux
Exec=$APP_NAME
Terminal=false
Type=Application
Categories=Network;Utility;
StartupNotify=true
StartupWMClass=vpn-ipsec-client
Icon=vpn-ipsec-client
EOF
chmod 644 "$DESKTOP_DIR/$APP_NAME.desktop"

# Config de exemplo (não sobrescreve se já existir)
EXAMPLE_CONF="$PROJECT_ROOT/packaging/bazzite/example.ipsec.conf"
[ -f "$PROJECT_ROOT/src/assets/icon.svg" ] && cp "$PROJECT_ROOT/src/assets/icon.svg" /usr/share/pixmaps/$APP_NAME.svg 2>/dev/null || true

echo ""
echo "============================================="
echo " Instalação concluída!"
echo "============================================="
if [ -n "$NEED_REBOOT" ]; then
    echo " >>> Reinicie o sistema para ativar o strongSwan:  sudo systemctl reboot"
fi
echo ""
echo " Para configurar sua VPN, edite /etc/ipsec.conf (persiste no OSTree)."
echo " Exemplo em: packaging/bazzite/example.ipsec.conf"
echo " Para executar a GUI:  $APP_NAME"
echo "============================================="