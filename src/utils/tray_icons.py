"""Ícone de bandeja (system tray) do Cliente VPN IPsec."""

import os

from PySide6.QtCore import QByteArray, Qt
from PySide6.QtGui import QIcon, QPainter, QPixmap
from PySide6.QtSvg import QSvgRenderer


class TrayIconProvider:
    """Renderiza o ícone do app (icon.svg) nos tamanhos usados na bandeja.

    O ícone da bandeja é o MESMO da janela/menu (escudo azul com cadeado),
    sem tintagem por estado — o status é informado pelo tooltip e menu.
    """

    _SIZES = (16, 22, 24, 32, 48, 64)
    _icon = None

    def __init__(self):
        script_dir = os.path.dirname(os.path.realpath(__file__))
        svg_path = os.path.join(script_dir, "..", "assets", "icon.svg")
        with open(svg_path, "rb") as f:
            self._svg_data = QByteArray(f.read())
        self._renderer = QSvgRenderer(self._svg_data)

    def icon(self) -> QIcon:
        """Retorna o QIcon do ícone do app renderizado em vários tamanhos."""
        if TrayIconProvider._icon is None:
            TrayIconProvider._icon = self._build_icon()
        return TrayIconProvider._icon

    def _build_icon(self) -> QIcon:
        icon = QIcon()
        for size in self._SIZES:
            pixmap = QPixmap(size, size)
            pixmap.fill(Qt.transparent)
            painter = QPainter(pixmap)
            painter.setRenderHint(QPainter.Antialiasing)
            self._renderer.render(painter, pixmap.rect())
            painter.end()
            icon.addPixmap(pixmap)
        return icon

    def icon_for_status(self, status: str) -> QIcon:
        normalized = status.strip().lower()
        if normalized == "conectado":
            return self._load_png_icon("vpn-green.png")
        if normalized in ("desconectado", "erro"):
            return self._load_png_icon("vpn-red.png")
        return self.icon()

    def _load_png_icon(self, filename: str) -> QIcon:
        path = os.path.join(
            os.path.dirname(os.path.realpath(__file__)), "..", "assets", filename
        )
        return QIcon(path)