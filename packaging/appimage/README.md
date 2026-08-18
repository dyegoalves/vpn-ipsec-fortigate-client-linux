# Empacotamento AppImage

Este diretório contém os scripts e configurações necessários para empacotar a aplicação VPN IPsec Client como um AppImage.

## Estrutura

```
packaging/appimage/
├── build.sh          # Script principal para criar o AppImage
├── AppImageBuilder.yml # Configuração do AppImageBuilder (opcional)
└── README.md         # Este arquivo
```

## Como criar o AppImage

Execute o script de build:

```bash
cd packaging/appimage
./build.sh
```

O script irá:

1. Criar um diretório AppDir com a estrutura necessária
2. Copiar os arquivos da aplicação
3. Instalar as dependências Python no AppDir
4. Criar os arquivos necessários para o AppImage
5. Baixar o appimagetool se necessário
6. Gerar o AppImage final

O AppImage resultante será nomeado `VPN-IPsec-Client-<version>-x86_64.AppImage` e salvo no diretório `packaging/appimage/`.

## Ícones da bandeja

O build inclui os ícones da bandeja:

- `vpn-ipsec-client-green.png` — status conectado
- `vpn-ipsec-client-red.png` — status desconectado/erro

Esses ícones são copiados de `src/assets/vpn-green.png` e `src/assets/vpn-red.png` para `AppDir/usr/share/icons/hicolor/256x256/apps/`.

## Requisitos

- Linux
- Python 3.6+
- pip
- wget ou curl
- PySide6
- configparser
- cryptography
- strongswan (para funcionalidades de VPN)
- libstrongswan-extra-plugins (para funcionalidades de VPN)

## Notas

- O script automaticamente lida com permissões e dependências
- O AppImage gerado é portátil e pode ser executado em qualquer sistema Linux x86_64
- Todos os arquivos temporários são criados e mantidos dentro do diretório de empacotamento
