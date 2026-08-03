---
title: "Pacote Debian (.deb)"
description: "Criação de pacote .deb para distribuições Debian/Ubuntu"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [empacotamento, deb, debian, ubuntu]
aliases: [DEB, Debian Package]
related:
  - README
  - empacotamento/Packaging-Overview
  - empacotamento/AppImage
---

# 📦 Pacote Debian (.deb)

**Formato:** Pacote DEB para distribuições Debian/Ubuntu

## Estrutura do Pacote

```
vpn-ipsec-client_1.0.0_amd64.deb
├── DEBIAN/
│   └── control           # Metadados do pacote
├── usr/
│   ├── bin/
│   │   └── vpn-ipsec-client → ../share/vpn-ipsec-client/main.py
│   └── share/
│       └── vpn-ipsec-client/
│           ├── main.py
│           ├── requirements.txt
│           └── src/
├── etc/
│   └── sudoers.d/
│       └── vpn-ipsec-client  # Permissões NOPASSWD para ipsec
└── usr/share/
    └── applications/
        └── vpn-ipsec-client.desktop
```

## Controle (DEBIAN/control)

```
Package: vpn-ipsec-client
Version: 1.0.0
Section: net
Priority: optional
Architecture: amd64
Maintainer: Seu Nome <email@example.com>
Description: Cliente VPN IPsec com interface gráfica para Linux
 Guias para conexões VPN IPsec usando StrongSwan/LibreSwan.
 .
 Funcionalidades:
  • Interface PySide6 com toggle de conexão
  • Suporte a strongSwan 5.x e 6+
  • Detecção automática de conexões
  • Monitoramento de status em tempo real
```

## Build Script (`packaging/deb/build.sh`)

```bash
#!/bin/bash
set -e

VERSION="1.0.0"
PACKAGE="vpn-ipsec-client"
ARCH="amd64"

# 1. Preparar diretório de build
rm -rf build
mkdir -p build/DEBIAN build/usr/bin build/usr/share/${PACKAGE}

# 2. Copiar arquivos
cp -r main.py src requirements.txt build/usr/share/${PACKAGE}/

# 3. Criar symlink
ln -s ../share/${PACKAGE}/main.py build/usr/bin/${PACKAGE}

# 4. Configurar sudoers
mkdir -p build/etc/sudoers.d
cat > build/etc/sudoers.d/${PACKAGE} << EOF
Cmnd_Alias VPN_CMDS = /usr/bin/ipsec *, /usr/bin/strongswan *, /usr/sbin/ipsec *
${USER} ALL=(root) NOPASSWD: VPN_CMDS
EOF

# 5. Desktop entry
mkdir -p build/usr/share/applications
cat > build/usr/share/applications/${PACKAGE}.desktop << EOF
[Desktop Entry]
Name=VPN IPsec Client
Comment=Gestão de conexões VPN IPsec
Exec=${PACKAGE}
Icon=${PACKAGE}
Terminal=false
Type=Application
Categories=Network;VPN;Security;
EOF

# 6. Copiar arquivos de configuração
cp debian/control build/DEBIAN/

# 7. Criar pacote
dpkg-deb --build build ${PACKAGE}_${VERSION}_${ARCH}.deb

echo "Pacote criado: ${PACKAGE}_${VERSION}_${ARCH}.deb"
```

## Instalação

```bash
# Testar o pacote
sudo dpkg -i vpn-ipsec-client_1.0.0_amd64.deb

# Verificar instalação
dpkg -L vpn-ipsec-client

# Remover
sudo dpkg -r vpn-ipsec-client
```

## Dependências Obrigatórias

O pacote deve declarar estas dependências no `control`:

```
Depends: python3 (>= 3.6),
         python3-pyqt5 | python3-pyside6,
         strongswan | ipsec,
         libxcb-cursor0,
         libxcb-xinerama0,
         libxcb-icccm4,
         libxcb-image0,
         libxcb-keysyms1,
         libxcb-render-util0,
         libxcb-shape0,
         libxkbcommon-x11-0
```

## Configuração Pós-instalação

```bash
# Verificar permissões sudo
sudo -l -U $USER | grep ipsec

# Reiniciar para garantir que sudoers foi aplicado
# (ou fazer novo login)

# Testar
vpn-ipsec-client
```

---
*[[README|← Voltar]] | [[empacotamento/Packaging-Overview|Empacotamento]] | [[empacotamento/AppImage|AppImage]]*