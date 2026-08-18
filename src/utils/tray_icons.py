"""Geração de ícones de bandeja (system tray) tintados conforme o status da VPN."""

import os

from PySide6.QtCore import QByteArray, Qt
from PySide6.QtGui import QColor, QIcon, QPainter, QPixmap
from PySide6.QtSvg import QSvgRenderer


class TrayIconProvider:
    """Gera e cacheia ícones de bandeja monocromáticos na cor do status."""

    STATE_COLORS = {
        "connected": "#2ECC71",
        "disconnected": "#95A5A6",
        "connecting": "#F39C12",
    }

    _SIZES = (16, 22, 24, 32, 48, 64)
    _cache = {}

    def __init__(self):
        script_dir = os.path.dirname(os.path.realpath(__file__))
        svg_path = os.path.join(script_dir, "..", "assets", "icon.svg")
        with open(svg_path, "rb") as f:
            self._svg_data = QByteArray(f.read())
        self._renderer = QSvgRenderer(self._svg_data)

    def icon_for_state(self, state: str) -> QIcon:
        color = self.STATE_COLORS.get(state, self.STATE_COLORS["disconnected"])
        if color not in self._cache:
            self._cache[color] = self._build_icon(color)
        return self._cache[color]

    def _build_icon(self, color: str) -> QIcon:
        icon = QIcon()
        for size in self._SIZES:
            pixmap = QPixmap(size, size)
            pixmap.fill(Qt.transparent)
            painter = QPainter(pixmap)
            painter.setRenderHint(QPainter.Antialiasing)
            self._renderer.render(painter, pixmap.rect())
            painter.setCompositionMode(QPainter.CompositionMode_SourceIn)
            painter.fillRect(pixmap.rect(), QColor(color))
            painter.end()
            icon.addPixmap(pixmap)
        return icon