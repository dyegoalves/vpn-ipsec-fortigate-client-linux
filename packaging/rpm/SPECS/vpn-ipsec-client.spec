Name:           vpn-ipsec-client
Version:        0.6.0
Release:        1
Summary:        Cliente VPN IPsec para Linux com interface gráfica

License:        MIT
URL:            https://github.com/dyegoalves/vpn-ipsec-fortigate-client-linux
BuildArch:      noarch
Requires:       python3
Requires:       strongswan
Recommends:     python3-pyside6

%description
Cliente VPN IPsec com interface gráfica para Linux, construído com PySide6 (Qt).
Gerencia conexões VPN IPsec com toggle visual, monitoramento de status e suporte
a strongSwan 5.x (stroke) e 6+ (swanctl/vici).

%prep
cp -r %{_sourcedir}/../../../src .
cp -r %{_sourcedir}/../../../main.py .
cp -r %{_sourcedir}/../../../requirements.txt .
cp -r %{_sourcedir}/../../../src/assets .

%install
mkdir -p %{buildroot}/usr/lib/vpn-ipsec-client
cp -r src main.py requirements.txt %{buildroot}/usr/lib/vpn-ipsec-client/

mkdir -p %{buildroot}/usr/bin
printf '#!/bin/bash\ncd /usr/lib/vpn-ipsec-client\nexec python3 main.py "$@"\n' > %{buildroot}/usr/bin/vpn-ipsec-client
chmod +x %{buildroot}/usr/bin/vpn-ipsec-client

mkdir -p %{buildroot}/usr/share/applications
cat > %{buildroot}/usr/share/applications/vpn-ipsec-client.desktop << 'DESKTOP'
[Desktop Entry]
Name=VPN IPsec Client
Exec=vpn-ipsec-client
Type=Application
Icon=vpn-ipsec-client
Categories=Network;VPN;
Terminal=false
Comment=Cliente VPN IPsec para Linux
DESKTOP

mkdir -p %{buildroot}/usr/share/icons/hicolor/scalable/apps
cp src/assets/icon.svg %{buildroot}/usr/share/icons/hicolor/scalable/apps/vpn-ipsec-client.svg 2>/dev/null || true

%files
/usr/lib/vpn-ipsec-client/*
/usr/bin/vpn-ipsec-client
/usr/share/applications/vpn-ipsec-client.desktop
/usr/share/icons/hicolor/scalable/apps/vpn-ipsec-client.svg

%post
pip3 install --break-system-packages -r /usr/lib/vpn-ipsec-client/requirements.txt 2>/dev/null || true

%changelog
* Mon Aug 03 2026 VPN IPsec Team <dyegoalves@github> - 0.6.0
- Documentação Obsidian com 26 arquivos em 7 pastas
- Suporte a Bazzite/OSTree (strongSwan 6+, swanctl vici)
- Instância única via QLocalSocket
- Configuração de caminhos via VPN_IPSEC_CONF / VPN_IPSEC_D_PATH
