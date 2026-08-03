import os
import subprocess
import re
from typing import Tuple

from ..config.app_config import (
    IPSEC_CONFIG_PATHS,
    IPSEC_D_PATH,
    IPSEC_BIN,
    SWANCTL_BIN,
    USE_SWANCTL,
)


class IPsecCommander:
    """
    Responsável por executar comandos IPsec e interpretar suas saídas.

    Suporta duas interfaces:
      - strongSwan 6+ / Fedora: usa 'swanctl' (protocolo vici), com config em
        /etc/strongswan/swanctl/conf.d/*.conf
      - strongSwan 5.x / legado: usa o comando 'ipsec' (protocolo stroke), com
        config em ipsec.conf
    """

    def connect_connection(self, conn_name: str) -> Tuple[bool, str]:
        """
        Inicia uma conexão IPsec.
        """
        try:
            if USE_SWANCTL:
                result = subprocess.run(
                    ["sudo", "-n", SWANCTL_BIN, "--initiate", "--child", conn_name],
                    capture_output=True,
                    text=True,
                    check=False,
                )
            else:
                result = subprocess.run(
                    ["sudo", "-n", IPSEC_BIN, "up", conn_name],
                    capture_output=True,
                    text=True,
                    check=False,
                )
            # O comando pode retornar 0 mesmo quando o processo de conexão é iniciado
            # ou pode retornar outro código mesmo após iniciar o processo
            success_outputs = (
                "initiate completed successfully",
                "connection 'fortigate-vpn' established successfully",
                "initiating",
                "ESTABLISHED",
            )
            if (
                result.returncode == 0
                or any(s in result.stdout for s in success_outputs)
                or "established" in result.stdout.lower()
            ):
                return True, f'Conexão IPsec "{conn_name}" iniciada com sucesso. Verifique o status para confirmação.'
            else:
                error_msg = result.stderr.strip() or result.stdout.strip()
                if self._is_sudo_error(error_msg):
                    return False, f'Falha ao iniciar conexão "{conn_name}": Privilégios de sudo não configurados. Por favor, verifique se as regras de sudo foram instaladas corretamente (pacote vpn-ipsec-client).'
                else:
                    return False, f'Falha ao iniciar conexão "{conn_name}": {error_msg}'
        except FileNotFoundError:
            return (
                False,
                f"Erro: Comando '{IPSEC_BIN}' não encontrado. Verifique se o StrongSwan/LibreSwan está instalado e no PATH.",
            )
        except Exception as e:
            return False, f"Erro inesperado ao iniciar conexão: {str(e)}"

    def disconnect_connection(self, conn_name: str) -> Tuple[bool, str]:
        """
        Termina uma conexão IPsec.
        """
        try:
            if USE_SWANCTL:
                result = subprocess.run(
                    ["sudo", "-n", SWANCTL_BIN, "--terminate", "--ike", conn_name],
                    capture_output=True,
                    text=True,
                    check=False,
                )
            else:
                result = subprocess.run(
                    ["sudo", "-n", IPSEC_BIN, "down", conn_name],
                    capture_output=True,
                    text=True,
                    check=False,
                )
            # O comando pode retornar 0 mesmo quando o processo de desconexão é iniciado
            # ou pode retornar outro código mesmo após iniciar o processo
            if (
                result.returncode == 0
                or "terminate completed successfully" in result.stdout
                or "deleting IKE_SA" in result.stdout
                or "closed successfully" in result.stdout
            ):
                return True, f'Conexão IPsec "{conn_name}" terminada com sucesso. Verifique o status para confirmação.'
            else:
                error_msg = result.stderr.strip() or result.stdout.strip()
                if self._is_sudo_error(error_msg):
                    return False, f'Falha ao terminar conexão "{conn_name}": Privilégios de sudo não configurados. Por favor, verifique se as regras de sudo foram instaladas corretamente (pacote vpn-ipsec-client).'
                else:
                    return False, f'Falha ao terminar conexão "{conn_name}": {error_msg}'
        except FileNotFoundError:
            return (
                False,
                f"Erro: Comando '{IPSEC_BIN}' não encontrado. Verifique se o StrongSwan/LibreSwan está instalado e no PATH.",
            )
        except Exception as e:
            return False, f"Erro inesperado ao terminar conexão: {str(e)}"

    def get_connection_status(self, conn_name: str) -> Tuple[str, bool]:
        """
        Obtém o status de uma conexão IPsec específica.
        """
        try:
            if USE_SWANCTL:
                result = subprocess.run(
                    ["sudo", "-n", SWANCTL_BIN, "--list-sas"],
                    capture_output=True,
                    text=True,
                    check=False,
                )
            else:
                result = subprocess.run(
                    ["sudo", "-n", IPSEC_BIN, "status"],
                    capture_output=True,
                    text=True,
                    check=False,
                )

            # Verificar se o comando foi executado com sucesso
            if result.returncode != 0:
                error_msg = result.stderr.strip() or result.stdout.strip()
                if self._is_sudo_error(error_msg):
                    return "Erro de permissão: Privilégios de sudo não configurados. Por favor, execute: sudo usermod -aG sudo $USER (e reinicie o sistema)", False
                if self._is_connection_configured(conn_name):
                    return "Desconectado", False
                else:
                    return f"Erro ao obter status: {error_msg}", False

            status_output = result.stdout

            # Buscar a seção da conexão no output
            conn_section = self._extract_connection_section(status_output, conn_name)
            if conn_section is None:
                if self._is_connection_configured(conn_name):
                    return "Desconectado", False
                return "Não configurado", False

            if "ESTABLISHED" in conn_section or "INSTALLED" in conn_section:
                return "Conectado", True

            if (
                "CONNECTING" in conn_section
                or "IKE_AUTH" in conn_section
                or "CHILD_CREATE" in conn_section
                or "initiating" in conn_section.lower()
                or "establishing" in conn_section.lower()
            ):
                return "Conectando", False

            # A conexão está listada mas não ativa
            if self._is_connection_configured(conn_name):
                return "Desconectado", False
            else:
                return "Não configurado", False

        except FileNotFoundError:
            return f"Erro: Comando '{IPSEC_BIN}' não encontrado.", False
        except Exception as e:
            if self._is_connection_configured(conn_name):
                return "Desconectado", False
            else:
                return f"Erro inesperado ao obter status: {str(e)}", False

    def _extract_connection_section(
        self, status_output: str, conn_name: str
    ) -> str:
        """
        Extrai o bloco de saída referente a uma conexão específica.
        Suporta o formato do 'swanctl --list-sas' e do 'ipsec status'.
        """
        lines = status_output.splitlines()
        section_lines = []
        in_section = False
        for line in lines:
            # Formato swanctl: "fortigate-vpn: #3, ESTABLISHED, IKEv2, ..."
            if re.match(rf"^\s*{re.escape(conn_name)}\s*:", line):
                in_section = True
                section_lines.append(line)
                continue
            # Formato legado: "Security Associations (1 up, 0 connecting):"
            # ou linhas com "fortigate-vpn[1]:" etc.
            if in_section:
                # Uma nova linha no topo (sem indentação) encerra a seção,
                # exceto no formato swanctl onde as SAs começam no início da linha.
                if not line.startswith((" ", "\t")) and not line.strip():
                    break
                section_lines.append(line)
        return "\n".join(section_lines).strip() if section_lines else ""

    def _is_sudo_error(self, error_msg: str) -> bool:
        return (
            "sudo: a terminal is required" in error_msg
            or "sudo: password is required" in error_msg
            or "sudo: no tty present" in error_msg
            or "uma senha é necessária" in error_msg
            or "password is required" in error_msg
        )

    def _is_connection_configured(self, conn_name: str) -> bool:
        """
        Verifica se uma conexão está configurada em algum arquivo de configuração do IPsec.
        """
        try:
            # Procurar por definições de conexão em arquivos de configuração

            # Verificar nos arquivos de configuração principais
            for config_file in IPSEC_CONFIG_PATHS:
                if os.path.exists(config_file):
                    with open(config_file, "r") as f:
                        content = f.read()
                        if re.search(rf"^\s*conn\s+{re.escape(conn_name)}\b", content, re.MULTILINE | re.IGNORECASE):
                            return True

            # Verificar nos arquivos do diretório ipsec.d
            ipsec_d_path = IPSEC_D_PATH
            try:
                if os.path.exists(ipsec_d_path) and os.path.isdir(ipsec_d_path):
                    for file_name in os.listdir(ipsec_d_path):
                        if file_name.endswith(('.conf', '.ipsec', '.cfg')):
                            file_path = os.path.join(ipsec_d_path, file_name)
                            if os.path.isfile(file_path):
                                with open(file_path, "r") as f:
                                    content = f.read()
                                    if re.search(rf"^\s*conn\s+{re.escape(conn_name)}\b", content, re.MULTILINE | re.IGNORECASE):
                                        return True
            except PermissionError:
                pass

            # strongSwan 6+ / swanctl: procurar em /etc/strongswan/swanctl/conf.d/
            for dir_path in (
                "/etc/strongswan/swanctl/conf.d/",
                os.path.join(os.path.dirname(os.path.dirname(IPSEC_D_PATH)), "swanctl", "conf.d"),
            ):
                try:
                    if os.path.isdir(dir_path):
                        for file_name in os.listdir(dir_path):
                            if file_name.endswith(".conf"):
                                file_path = os.path.join(dir_path, file_name)
                                with open(file_path, "r") as f:
                                    content = f.read()
                                    if re.search(
                                        rf"^\s*{re.escape(conn_name)}\s*{{",
                                        content,
                                        re.MULTILINE,
                                    ):
                                        return True
                except PermissionError:
                    pass
            return False
        except Exception:
            # Se houver qualquer erro ao ler os arquivos de configuração, assumir que não está configurada
            return False
