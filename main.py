"""
VPN IPsec Client Application - Main Entry Point

This module initializes and runs the Qt application.
"""

import sys
import os

# Adiciona o diretório pai (src) ao sys.path para permitir importações relativas
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from PySide6.QtWidgets import QApplication
from PySide6.QtCore import Qt
from PySide6.QtNetwork import QLocalSocket, QLocalServer
from src.ui.main_window import MainWindow
from src.utils.system_theme import get_system_color_scheme


def load_stylesheet(theme: str) -> str:
    """Carrega o stylesheet para o tema especificado."""
    script_dir = os.path.dirname(os.path.realpath(__file__))
    style_path = os.path.join(script_dir, "src", "assets", "styles", f"{theme}_theme.qss")
    if os.path.exists(style_path):
        with open(style_path, "r") as f:
            return f.read()
    return ""


def main() -> None:
    """
    Main entry point for the Qt application.
    """
    app = QApplication(sys.argv)

    # Verifica se já existe uma instância rodando
    socket_name = "vpn-ipsec-client-socket"
    local_socket = QLocalSocket()
    local_socket.connectToServer(socket_name)
    
    if local_socket.waitForConnected(500):
        # App já está aberto. Pede para a instância focar a janela.
        local_socket.write(b"FOCUS")
        local_socket.flush()
        local_socket.waitForBytesWritten(500)
        sys.exit(0)
        
    # App será a instância primária
    local_server = QLocalServer()
    # Limpa possíveis sockets órfãos (se o app fechou com erro anteriormente)
    if not local_server.listen(socket_name):
        QLocalServer.removeServer(socket_name)
        local_server.listen(socket_name)

    # Set application name for proper window class (WM_CLASS) association on Linux (X11/Wayland)
    app.setApplicationName("vpn-ipsec-client")

    # Set application desktop file name for proper desktop entry association
    app.setDesktopFileName("vpn-ipsec-client")

    # Set the application style to match the system theme (important for Deepin)
    app.setStyle("Fusion")

    # Detectar o tema do sistema e aplicar o stylesheet
    current_theme = get_system_color_scheme()
    if current_theme == "Dark":
        stylesheet = load_stylesheet("dark")
    else:
        stylesheet = load_stylesheet("light")
    app.setStyleSheet(stylesheet)

    # Create and show the main application window
    ex = MainWindow()
    app.main_window = ex  # Salva referência para focar via Socket

    # Com bandeja ativa, o app continua rodando mesmo sem janela visível
    if ex.has_system_tray():
        app.setQuitOnLastWindowClosed(False)

    ex.show()
    
    # Callback para tratar requisições de outras instâncias que tentarem abrir
    def on_new_connection():
        client = local_server.nextPendingConnection()
        if client:
            client.waitForReadyRead(500)
            data = client.readAll().data()
            if b"FOCUS" in data:
                app.main_window.show_window()
            client.disconnectFromServer()
            
    local_server.newConnection.connect(on_new_connection)

    # Execute the application's main loop
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
