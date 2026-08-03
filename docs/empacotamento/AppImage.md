---
title: "AppImage"
description: "Criação de AppImage executável para distribuição"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [empacotamento, appimage, distribuicao]
aliases: [AppImage]
related:
  - README
  - empacotamento/Packaging-Overview
  - empacotamento/DEB
---

# 📱 AppImage

**Formato:** AppImage (portátil, não requer instalação)

## Características

- ✅ Portátil: Executa em qualquer sistema Linux x86_64
- ✅ Não requer instalação ou privilégios de root
- ✅ Contém todas as dependências (Python, PySide6, etc.)
- ✅ Auto-atualização opcional
- ✅ Assinatura digital disponível

## Estrutura do AppImage

```
vpn-ipsec-client.AppImage
├── squashfs-root/
│   ├── application/
│   │   ├── main.py
│   │   └── src/
│   ├── resources/
│   │   ├── icon.svg
│   │   └── styles/
│   ├── vpn-ipsec-client  # Desktop entry
│   └── AppRun            # Script de inicialização
```

## Build

```bash
cd packaging/appimage
./build.sh
```

## Uso

```bash
# Tornar executável (se necessário)
chmod +x vpn-ipsec-client-*.AppImage

# Executar
./vpn-ipsec-client-*.AppImage
```

## Integração com Sistema (opcional)

```bash
# Mover para local de aplicações
sudo mv vpn-ipsec-client-*.AppImage /opt/
sudo ln -s /opt/vpn-ipsec-client-*.AppImage /usr/local/bin/vpn-ipsec-client

# Criar entrada de menu (se desktop file incluído)
sudo desktop-file-install /opt/vpn-ipsec-client-*.desktop
```

## Solução de Problemas

| Problema | Solução |
|----------|---------|
| Permissão negada | `chmod +x arquivo.AppImage` |
| Faltando libfuse | `sudo apt install -y libfuse2` |
| Erro de tema | Exportar `QT_QPA_PLATFORM=xcb` antes de executar |
| Sem som/notificações | Verificar se dbus está disponível |

---
*[[README|← Voltar]] | [[empacotamento/Packaging-Overview|Empacotamento]]*