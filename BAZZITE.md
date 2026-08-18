# Port do Cliente VPN IPsec para Bazzite

Guia completo de instalação e funcionamento do **Cliente VPN IPsec (Fortigate)** no **Bazzite** — a Fedora imutável baseada em `rpm-ostree`.

---

## Por que Bazzite é diferente

| Aspecto | Distros tradicionais (ex.: Debian/Ubuntu) | Bazzite (Fedora Atomic / OSTree) |
|---|---|---|
| `/usr` | gravável | **somente-leitura** no boot |
| Instalar pacotes do sistema | `apt install` | `rpm-ostree install` (camada, exige reboot) |
| Config em `/etc` | normal | persistente, mas precisa atenção |
| GUI/Qt | libs do sistema | deve vir isolada (venv/AppImage) |
| Sudo | regras opcionais | necessário `NOPASSWD` para `ipsec` |

O app foi ajustado para funcionar nesse modelo:

- **`src/config/app_config.py`** — caminhos de config IPsec lidos de variáveis de ambiente
  (`VPN_IPSEC_CONF`, `VPN_IPSEC_D_PATH`), com fallback para `/etc/ipsec.conf` e `/etc/ipsec.d`.
- **`src/ipsec/ipsec_commander.py`** — removidos caminhos `/etc/ipsec*` hardcoded;
  usa os caminhos configuráveis.
- **Instalador dedicado** — `packaging/bazzite/install.sh`.

---

## Instalação

### Requisitos

- Bazzite (x86_64) com `sudo` habilitado.
- Python 3.12+ presente (padrão do Bazzite).
- Acesso à internet para `rpm-ostree` e `pip`.

### Passo a passo

```bash
# 1) Rodar o instalador (exige sudo)
sudo bash packaging/bazzite/install.sh

# 2) Se o strongSwan foi instalado via overlay (sem --apply-live), reiniciar
sudo systemctl reboot
```

O instalador executa:

1. **strongSwan via `rpm-ostree`** — instala `strongswan` e `strongswan-charon-nm`
   (tenta `--apply-live`; se falhar, enfileira para o próximo boot).
2. **venv isolado** — cria `~/.local/share/vpn-ipsec-client/venv` com PySide6
   (não depende das libs do sistema, contornando o `/usr` somente-leitura).
3. **sudo NOPASSWD** — cria `/etc/sudoers.d/vpn-ipsec-client` permitindo o usuário
   executar `/usr/sbin/ipsec` sem senha.
4. **Launcher** — instala `/usr/local/bin/vpn-ipsec-client` e a entrada `.desktop`.
   - O desktop entry usa **caminho absoluto** (`Exec=/usr/local/bin/vpn-ipsec-client`),
     garantindo que o menu do desktop nunca dependa do `PATH`.
   - Launchers órfãos em `~/.local/bin` ou `~/bin` (criados manualmente apontando
     para um diretório antigo) são **removidos** — eles viriam antes de
     `/usr/local/bin` no `PATH` do usuário e quebrariam o lançamento pelo menu.

> **⚠️ Importante:** o `install.sh` **não abre o app** — ele apenas instala.
> Para abrir a GUI use `vpn-ipsec-client` no terminal ou o menu de aplicativos.

---

## Configuração da VPN

```bash
# Copiar a config de exemplo
sudo cp packaging/bazzite/example.ipsec.conf /etc/ipsec.conf

# Editar segredos (PSK / EAP)
sudo nano /etc/ipsec.secrets

# Aplicar a config
sudo systemctl restart strongswan     # ou: sudo ipsec restart
```

> `/etc` persiste no OSTree, então a config sobrevive a updates do sistema.

### Exemplo de `/etc/ipsec.secrets`

```
: PSK "chave_compartilhada"
usuario_vpn : EAP "senha_da_vpn"
```

---

## Execução

```bash
# Direto do launcher (instalado pelo script)
vpn-ipsec-client

# Ou pelo menu de aplicativos do KDE / GNOME
# (Super -> "VPN IPsec Client" -> clique no ícone)
```

### Posição da janela

- A janela abre **centralizada na tela primária**.
- O app **lembra a posição e o tamanho** da janela (`QSettings`): mova a janela
  para onde preferir e, ao fechar, ela abre no mesmo lugar na próxima vez.
- Em setups com vários monitores, se a janela "sumir", arraste-a para o monitor
  desejado e feche — a posição será salva.

### Single-instance

O app é **single-instance**: rodar `vpn-ipsec-client` de novo (ou clicar no
menu) com o app já aberto apenas **traz a janela para frente** (mesmo que ela
esteja oculta na bandeja).

```bash
# Ou em modo dev, a partir do código-fonte
cd /home/dyegoalves/projetos/projeto-vpn-ipsec-fortigate-client-linux
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python main.py
```

---

## Bandeja do sistema (system tray)

O app roda na bandeja (ícone persistente ao lado do relógio):

- **Requisito:** o Bazzite GNOME já inclui a extensão **AppIndicator and
  KStatusNotifierItem Support** por padrão — o `QSystemTrayIcon` funciona sem
  configuração extra. Em desktops sem essa extensão, a bandeja é desabilitada
  e o app se comporta normalmente.
- **Ícone de status:** verde = conectado, âmbar = conectando, cinza =
  desconectado. O tooltip mostra conexão e estado.
- **Menu da bandeja:** Mostrar/Ocultar Janela, seleção da conexão,
  Conectar/Desconectar e Sair.
- **Fechar a janela (X):** minimiza para a bandeja — a **VPN permanece ativa**.
- **Sair (menu da bandeja):** desconecta a VPN antes de encerrar o app.
- **Notificações:** avisos de conectado/desconectado e de "VPN ativa na bandeja".

---

## Caminhos configuráveis (root imutável)

O app lê a config IPsec das seguintes variáveis (padrão OSTree):

| Variável           | Padrão            | Uso                                   |
|--------------------|-------------------|---------------------------------------|
| `VPN_IPSEC_CONF`   | `/etc/ipsec.conf` | arquivo de config principal           |
| `VPN_IPSEC_D_PATH` | `/etc/ipsec.d`    | diretório de configs adicionais       |

Exemplo apontando para um caminho em `/var` (persistente e gravável):

```bash
export VPN_IPSEC_CONF=/var/lib/ipsec/ipsec.conf
export VPN_IPSEC_D_PATH=/var/lib/ipsec/ipsec.d
vpn-ipsec-client
```

---

## AppImage

> **Atenção:** o AppImage gerado em ambientes com PySide6 quebrado (ex.: Zorin com
> NumPy 2 e `shiboken6` corrompido) falha no `import PySide6`. No Bazzite o caminho
> recomendado é o **venv isolado** do instalador — não o AppImage.

Se ainda assim quiser gerar um AppImage funcional, gere a partir de um venv saudável:

```bash
python3 -m venv /tmp/appimg-venv
source /tmp/appimg-venv/bin/activate
pip install -r requirements.txt
cd packaging/appimage && ./build.sh
```

O build usa `python3.10` fixo no `build.sh` (`/usr/lib/python3.10/site-packages`);
em máquinas com Python 3.12+ o caminho deve ser ajustado para o Python do venv
(ou usar `PySide6==6.6.1+`, que tem wheels para Python 3.12).

---

## Desinstalar

```bash
# Remover launcher e desktop entry
sudo rm -f /usr/local/bin/vpn-ipsec-client
sudo rm -f /usr/share/applications/vpn-ipsec-client.desktop

# Remover regra de sudo
sudo rm -f /etc/sudoers.d/vpn-ipsec-client

# Remover venv e configs
rm -rf ~/.local/share/vpn-ipsec-client
sudo rm -f /etc/ipsec.conf /etc/ipsec.secrets

# Remover strongSwan (se não for mais usado)
sudo rpm-ostree uninstall strongswan strongswan-charon-nm
```

---

## Solução de problemas

| Sintoma | Causa | Correção |
|---|---|---|
| App **não abre pelo menu** do desktop, mas abre no terminal | launcher órfão em `~/.local/bin` (ou `~/bin`) apontando para diretório antigo; o `PATH` do usuário prioriza esses diretórios sobre `/usr/local/bin` | rodar o instalador de novo (ele remove os órfãos) ou `rm -f ~/.local/bin/vpn-ipsec-client` |
| `cd: ...projeto-vpn-ipsec...: Arquivo ou diretório inexistente` | mesmo problema acima (launcher órfão) | remover o launcher órfão e usar o do `/usr/local/bin` |
| App abre **no monitor secundário** | posição salva de uma sessão anterior em outro monitor | mover a janela para o monitor desejado e fechar (a nova posição é salva) ou apagar `~/.config/VPN\ IPsec\ Client/` |
| `ipsec: command not found` | strongSwan não layer-ado | `sudo rpm-ostree install strongswan strongswan-charon-nm` e reiniciar |
| `sudo: a terminal is required` / `no tty present` | regra NOPASSWD ausente | rodar o instalador de novo ou criar `/etc/sudoers.d/vpn-ipsec-client` manualmente |
| App não abre (Qt falha) | PySide6 do sistema quebrado | usar o venv do instalador (já isolado) ou reinstalar PySide6 no venv |
| Config não é lida | caminho errado | definir `VPN_IPSEC_CONF`/`VPN_IPSEC_D_PATH` ou conferir `/etc/ipsec.conf` |
| Aplicação não persiste após update | arquivo em `/usr` | manter config em `/etc`/`/var` (nunca em `/usr`) |
| `connection not found` no status | config em arquivo fora dos caminhos | ajustar `VPN_IPSEC_D_PATH` para incluir o diretório |

---

## Estrutura dos arquivos do port

```
packaging/bazzite/
├── install.sh              # instalador principal (rpm-ostree + venv + sudoers)
├── example.ipsec.conf      # config de exemplo Fortigate
└── README.md               # doc específica do port

src/config/app_config.py    # caminhos IPsec configuráveis (env)
src/ipsec/ipsec_commander.py# usa os caminhos configuráveis
README.md                   # seção "Port para Bazzite"
```

---

## Status

- ✅ strongSwan via `rpm-ostree`
- ✅ GUI isolada em venv (PySide6 6.11.1)
- ✅ sudo NOPASSWD para `ipsec`
- ✅ caminhos de config configuráveis
- ✅ launcher + desktop entry (caminho absoluto, sem launchers órfãos)
- ✅ bandeja do sistema (system tray) com status e menu
- ✅ fechar (X) minimiza para a bandeja; Sair desconecta a VPN
- ✅ single-instance com FOCUS (janela volta mesmo oculta na bandeja)
- ✅ posição da janela persistida (tela primária por padrão)
- ✅ documentação completa
