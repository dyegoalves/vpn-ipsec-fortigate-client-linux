"""Bandeja do sistema (system tray) do Cliente VPN IPsec."""

from PySide6.QtCore import QElapsedTimer, Signal
from PySide6.QtGui import QAction, QActionGroup
from PySide6.QtWidgets import QMenu, QSystemTrayIcon

from ..config.app_config import APP_TITLE, CONNECTION_STATES
from ..utils.tray_icons import TrayIconProvider


class SystemTray(QSystemTrayIcon):
    """Ícone persistente na bandeja com menu de contexto e status da VPN."""

    connection_selected = Signal(str)
    connect_requested = Signal()
    disconnect_requested = Signal()
    quit_requested = Signal()
    window_shown = Signal()
    window_hidden = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._provider = TrayIconProvider()
        self._connections = []
        self._current_connection = None
        self._is_connected = False
        self._status = CONNECTION_STATES["DISCONNECTED"]
        self._click_timer = QElapsedTimer()

        self.setIcon(self._provider.icon())
        self.setToolTip(APP_TITLE)
        self._rebuild_menu()
        self.activated.connect(self._on_activated)
        self.show()

    def _rebuild_menu(self):
        menu = QMenu()

        self.show_action = QAction("Mostrar Janela", menu)
        self.show_action.setCheckable(True)
        self.show_action.triggered.connect(self._on_show_toggled)
        menu.addAction(self.show_action)
        menu.addSeparator()

        connections_label = QAction("Conexão:", menu)
        connections_label.setEnabled(False)
        menu.addAction(connections_label)

        self.connection_group = QActionGroup(menu)
        self.connection_group.setExclusive(True)
        self._connection_actions = {}
        for conn in self._connections:
            self._add_connection_action(menu, conn)

        menu.addSeparator()

        self.connect_action = QAction("Conectar", menu)
        self.connect_action.triggered.connect(self.connect_requested)
        menu.addAction(self.connect_action)

        self.disconnect_action = QAction("Desconectar", menu)
        self.disconnect_action.triggered.connect(self.disconnect_requested)
        menu.addAction(self.disconnect_action)

        menu.addSeparator()

        self.quit_action = QAction("Sair", menu)
        self.quit_action.triggered.connect(self.quit_requested)
        menu.addAction(self.quit_action)

        self.setContextMenu(menu)
        self._apply_menu_status()

    def _add_connection_action(self, menu, conn_name: str):
        action = QAction(conn_name, menu)
        action.setCheckable(True)
        action.setChecked(conn_name == self._current_connection)
        action.triggered.connect(
            lambda checked=False, name=conn_name: self.connection_selected.emit(name)
        )
        self.connection_group.addAction(action)
        self._connection_actions[conn_name] = action
        menu.addAction(action)

    def _on_activated(self, reason):
        if reason == QSystemTrayIcon.Trigger:
            if self._click_timer.isValid() and self._click_timer.elapsed() < 300:
                self._click_timer.restart()
                self.show_action.trigger()
            else:
                self._click_timer.restart()

    def _on_show_toggled(self, checked):
        if checked:
            self.window_shown.emit()
        else:
            self.window_hidden.emit()

    def set_connections(self, connections, current=None):
        self._connections = list(connections)
        self._current_connection = current
        self._rebuild_menu()
        for action in self._connection_actions.values():
            action.setChecked(action.text() == current)

    def set_current_connection(self, conn_name):
        self._current_connection = conn_name
        for name, action in self._connection_actions.items():
            action.setChecked(name == conn_name)
        self._apply_menu_status()
        self._update_tooltip()

    def update_status(self, status: str, is_connected: bool):
        self._status = status
        self._is_connected = is_connected
        self.setIcon(self._provider.icon_for_status(status))
        self._update_tooltip()
        self._apply_menu_status()

    def set_window_visible(self, visible: bool):
        self.show_action.setChecked(visible)

    def notify(self, title: str, message: str):
        if self.isVisible():
            self.showMessage(title, message, self.icon(), 3000)

    def _apply_menu_status(self):
        has_connection = bool(self._current_connection) and self._current_connection not in (
            "No configurations found",
            "Not installed",
            CONNECTION_STATES["ERROR"],
        )
        self.connect_action.setEnabled(has_connection and not self._is_connected)
        self.disconnect_action.setEnabled(self._is_connected)

    def _update_tooltip(self):
        conn = self._current_connection or "Sem conexão"
        self.setToolTip(f"{APP_TITLE}\n{conn}: {self._status}")