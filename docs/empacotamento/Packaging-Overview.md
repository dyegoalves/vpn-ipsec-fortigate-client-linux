---
title: "Empacotamento"
description: "Visão geral dos formatos de empacotamento disponíveis"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [empacotamento, build, distribuicao]
aliases: [Packaging, Empacotamento]
related:
  - README
  - instalacao/Quick-Start
  - empacotamento/AppImage
  - empacotamento/DEB
---

# 📦 Empacotamento - Visão Geral

A aplicação pode ser empacotada em diferentes formatos para distribuição.

## Menu Interativo

```bash
# Executar o menu de empacotamento
./packaging/menu_build.sh
```

### Opções do Menu

```
=============================================
  Menu de Empacotamento - VPN IPsec Client
=============================================
  Selecione o formato do pacote:

  1) AppImage   - Cria um AppImage executável
  2) Deb        - Cria um pacote .deb
  3) Todos      - Cria todos os pacotes

  4) Sair
=============================================
Digite sua escolha [1-4]:
```

## Formatos Suportados

| Formato | Descrição | Distribuições |
|---------|-----------|---------------|
| **AppImage** | Portátil, não requer instalação | Qualquer Linux x86_64 |
| **DEB** | Pacote Debian/Ubuntu | Ubuntu, Debian, Mint, etc. |
| **RPM** | Pacote Fedora/RHEL | Fedora, RHEL, CentOS |

## Estrutura de Empacotamento

```
packaging/
├── appimage/          # Scripts e config para AppImage
├── deb/               # Scripts e config para .deb
├── bazzite/           # Instalador para Bazzite/Fedora Atomic
├── generate_icons.py  # Gerador de ícones
└── menu_build.sh      # Menu interativo principal
```

## Requisitos de Build

```bash
# Para AppImage
sudo apt install -y appimagetool

# Para .deb
sudo apt install -y dpkg-dev fakeroot

# Para todos
sudo apt install -y python3-pip python3-venv
```

## Build Automatizado

```bash
# Build AppImage apenas
cd packaging/appimage
./build.sh

# Build .deb apenas
cd packaging/deb
./build.sh

# Build todos via menu
./packaging/menu_build.sh
```

## Build via Container (Fedora/Bazzite - sem dpkg/rpmbuild local)

```bash
# Build .deb em container Debian
podman run --rm -v "$PWD:/workspace:z" -w /workspace debian:bookworm bash -c "
  apt-get update -qq && apt-get install -y -qq dpkg-dev python3 >/dev/null &&
  cd packaging/deb && bash build.sh
"

# Build .rpm em container Fedora (ou use o script pronto)
./packaging/rpm/build.sh
```

## Publicar Artefatos na Release

```bash
# Anexar artefatos à release existente
gh release upload v0.6.0 \
  packaging/appimage/VPN-IPsec-Client-0.6.0-x86_64.AppImage \
  packaging/deb/vpn-ipsec-client_0.6.0_amd64.deb \
  packaging/vpn-ipsec-client-0.6.0-1.noarch.rpm

# Verificar artefatos
gh release view v0.6.0 --json assets --jq '.assets[].name'
```

## Release Notes Padrão

```bash
gh release create v0.6.0 --title "v0.6.0 - <descrição>" --notes "
## v0.6.0
### Novo
- ...
### Features
- ...
"
```

## Variáveis de Build

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `VERSION` | Versão do pacote | `1.0.0` |
| `BUILD_DIR` | Diretório de build | `./build` |
| `OUTPUT_DIR` | Diretório de saída | `./dist` |

## Testes Pós-Build

```bash
# Testar AppImage
chmod +x dist/vpn-ipsec-client-*.AppImage
./dist/vpn-ipsec-client-*.AppImage

# Testar .deb (em container/VM)
sudo dpkg -i dist/vpn-ipsec-client_*.deb
vpn-ipsec-client
```

---
*[[README|← Voltar]] | [[empacotamento/AppImage|AppImage]] | [[empacotamento/DEB|DEB]]*