#!/usr/bin/env python3
"""
Utilitário para gerar ícones PNG em múltiplos tamanhos a partir do SVG.
Usa PySide6/Qt para renderização de alta qualidade.
"""

import sys
from pathlib import Path

# Adicionar src ao path para importações
script_dir = Path(__file__).parent.resolve()
sys.path.insert(0, str(script_dir.parent))

try:
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtSvg import QSvgRenderer
    from PySide6.QtGui import QPixmap, QPainter
    from PySide6.QtCore import QByteArray, Qt
except ImportError as e:
    print(f"ERRO: Não foi possível importar PySide6: {e}")
    print("Instale com: pip install pyside6")
    sys.exit(1)


def generate_png_from_svg(svg_path: str, output_dir: str, sizes: list = None):
    """
    Gera PNGs em múltiplos tamanhos a partir de um arquivo SVG.

    Args:
        svg_path: Caminho para o arquivo SVG de entrada
        output_dir: Diretório onde os PNGs serão salvos
        sizes: Lista de tamanhos (largura/altura em pixels). Se None, usa padrões.
    """
    if sizes is None:
        sizes = [16, 24, 32, 48, 64, 128, 256, 512]

    svg_path = Path(svg_path).resolve()
    output_dir = Path(output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    if not svg_path.exists():
        print(f"ERRO: Arquivo SVG não encontrado: {svg_path}")
        return False

    print(f"Gerando ícones PNG a partir de: {svg_path}")
    print(f"Diretório de saída: {output_dir}")

    # Ler o SVG
    with open(svg_path, 'rb') as f:
        svg_data = f.read()

    renderer = QSvgRenderer(QByteArray(svg_data))

    if not renderer.isValid():
        print(f"ERRO: SVG inválido ou não pode ser renderizado: {svg_path}")
        return False

    # Obter tamanho original do SVG
    default_size = renderer.defaultSize()
    svg_width = default_size.width() if default_size.isValid() else 1024
    svg_height = default_size.height() if default_size.isValid() else 1024

    print(f"Tamanho original do SVG: {svg_width}x{svg_height}")

    success = True
    for size in sizes:
        try:
            # Criar pixmap com o tamanho desejado
            pixmap = QPixmap(size, size)
            pixmap.fill(Qt.transparent)

            # Renderizar o SVG no pixmap
            painter = QPainter(pixmap)
            painter.setRenderHint(QPainter.Antialiasing, True)
            painter.setRenderHint(QPainter.SmoothPixmapTransform, True)

            # Renderizar o SVG preenchendo o pixmap inteiro
            renderer.render(painter)

            # Finalizar painter antes de salvar
            painter.end()

            # Salvar como PNG
            output_path = output_dir / f"{size}x{size}.png"
            if pixmap.save(str(output_path), "PNG"):
                print(f"  ✓ Gerado: {output_path.name}")
            else:
                print(f"  ✗ Falha ao salvar: {output_path.name}")
                success = False

        except Exception as e:
            print(f"  ✗ Erro ao gerar ícone {size}x{size}: {e}")
            success = False

    print(f"\nGeração de ícones concluída: {'SUCESSO' if success else 'COM ERROS'}")
    return success


def generate_freedesktop_icon_dirs(base_icon_name: str, output_base_dir: str):
    """
    Gera a estrutura de diretórios de ícones para o padrão FreeDesktop.

    Args:
        base_icon_name: Nome base do ícone (sem extensão)
        output_base_dir: Diretório base onde criar a estrutura de ícones
    """
    base_dir = Path(output_base_dir).resolve()
    icon_dir = base_dir / "icons" / "hicolor"

    # Tamanhos e diretórios correspondentes
    icon_sizes = [
        (16, "16x16"),
        (24, "24x24"),
        (32, "32x32"),
        (48, "48x48"),
        (64, "64x64"),
        (128, "128x128"),
        (256, "256x256"),
        (512, "512x512"),
    ]

    print(f"Criando estrutura de ícones FreeDesktop em: {icon_dir}")

    for size, subdir in icon_sizes:
        size_dir = icon_dir / subdir / "apps"
        size_dir.mkdir(parents=True, exist_ok=True)
        source_png = base_dir / f"{size}x{size}.png"
        dest_png = size_dir / f"{base_icon_name}.png"

        if source_png.exists():
            import shutil
            shutil.copy2(source_png, dest_png)
            print(f"  ✓ Copiado para: {dest_png}")
        else:
            print(f"  ✗ Faltando: {source_png}")

    # Manter o SVG no diretório scalable
    scalable_dir = icon_dir / "scalable" / "apps"
    scalable_dir.mkdir(parents=True, exist_ok=True)
    print(f"  ✓ Diretório scalable criado: {scalable_dir}")

    print("\nEstrutura de ícones criada com sucesso!")


if __name__ == "__main__":
    # Inicializar QApplication (necessário para QPixmap)
    app = QGuiApplication(sys.argv)

    # Determinar caminhos
    project_root = script_dir.parent
    svg_path = project_root / "src" / "assets" / "icon.svg"
    output_dir = project_root / "packaging" / "icons_output"

    print("=" * 60)
    print("  Gerador de Ícones PNG para VPN IPsec Client")
    print("=" * 60)
    print()

    if not svg_path.exists():
        print(f"ERRO: SVG não encontrado em: {svg_path}")
        print("Certifique-se de que o arquivo icon.svg existe em src/assets/")
        sys.exit(1)

    # Gerar PNGs
    success = generate_png_from_svg(str(svg_path), str(output_dir))

    if success:
        # Criar estrutura de diretórios FreeDesktop
        generate_freedesktop_icon_dirs("vpn-ipsec-client", str(output_dir))

    print("\nConcluído!")
