"""
Configuration Module

This file contains all the constants and configuration settings for the VPN IPsec Client application.
"""

import os

# --- Application Info ---
APP_TITLE = "Cliente VPN IPsec Fortigate"
WINDOW_SIZE = (500, 650)

# Permite ao usuário escolher o backend Qt (ex.: wayland no Bazzite/GNOME)
# sem sobrescrever a escolha já feita no ambiente.
os.environ.setdefault("QT_QPA_PLATFORM", "xcb")

# --- UI Styles (CSS) ---
CONNECTION_STATES = {
    "CONNECTED": "Connected",
    "DISCONNECTED": "Disconnected",
    "CONNECTING": "Connecting...",
    "DISCONNECTING": "Disconnecting...",
    "NOT_CONFIGURED": "Not Configured",
    "NO_CONFIG": "No config",
    "UNAVAILABLE": "Unavailable",
    "ERROR": "Error",
}

# --- Default Messages ---
DEFAULT_MESSAGES = {
    "INIT": "vpn-ipsec-fortigate-client-linux initialized.",
    "CHECKING_CONFIG": "Checking for existing IPsec configurations...",
    "NO_IPSEC": "IPsec is not installed on this system.",
    "NO_CONFIGS": "No IPsec configurations found in system files.",
    "READY": "VPN IPsec Client ready",
}

# --- IPsec Configuration Paths ---
# Caminhos configuráveis via variáveis de ambiente (importante em distros
# imutáveis/OSTree como o Bazzite, onde /usr é somente-leitura).
#   VPN_IPSEC_CONF    -> arquivo de configuração principal (padrão /etc/ipsec.conf
#                        ou /etc/strongswan/ipsec.conf no strongSwan 6+/Fedora)
#   VPN_IPSEC_D_PATH  -> diretório de configs adicionais (padrão /etc/ipsec.d/)
#   VPN_IPSEC_BIN     -> binário do IPsec (padrão: 'strongswan' se disponível, senão 'ipsec')


def _detect_ipsec_bin() -> str:
    """Retorna o binário do IPsec disponível no sistema."""
    configured = os.environ.get("VPN_IPSEC_BIN", "").strip()
    if configured:
        return configured
    import shutil

    for candidate in ("strongswan", "ipsec"):
        path = shutil.which(candidate)
        if path:
            return path
    return "ipsec"


IPSEC_BIN = _detect_ipsec_bin()

# No strongSwan 6+ (Fedora) o config principal fica em /etc/strongswan/ipsec.conf
_strongswan_conf = "/etc/strongswan/ipsec.conf"
if "strongswan" in IPSEC_BIN and os.path.exists(_strongswan_conf):
    DEFAULT_CONF = _strongswan_conf
    DEFAULT_D_PATH = "/etc/strongswan/ipsec.d"
else:
    DEFAULT_CONF = "/etc/ipsec.conf"
    DEFAULT_D_PATH = "/etc/ipsec.d"

IPSEC_CONFIG_PATHS = [os.environ.get("VPN_IPSEC_CONF", DEFAULT_CONF)]
IPSEC_D_PATH = os.environ.get("VPN_IPSEC_D_PATH", DEFAULT_D_PATH)

# strongSwan 6+ usa o utilitário 'swanctl' (vici) em vez da interface 'stroke'
# do comando legado 'ipsec'/'strongswan up'. Detecta automaticamente.
def _detect_swanctl() -> str:
    configured = os.environ.get("VPN_SWANCTL_BIN", "").strip()
    if configured:
        return configured
    import shutil

    for candidate in ("swanctl", "swanctl-legacy"):
        path = shutil.which(candidate)
        if path:
            return path
    return ""

SWANCTL_BIN = _detect_swanctl()
# Se encontrou swanctl e o binário é strongswan, usa a interface vici (swanctl)
USE_SWANCTL = bool(SWANCTL_BIN) and "strongswan" in IPSEC_BIN

# --- Log File ---
# Usar um único arquivo de log organizado dentro de ~/.vpnlogs/
LOGS_DIR = os.path.expanduser("~/.vpnlogs")
os.makedirs(LOGS_DIR, mode=0o755, exist_ok=True)

LOG_FILE_PATH = os.path.join(LOGS_DIR, "vpn_ipsec_client.log")
