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

# Ou em modo dev, a partir do código-fonte
cd /home/dyegoalves/projetos/projeto-vpn-ipsec-fortigate-client-linux
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python main.py
```

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
- ✅ GUI isolada em venv (PySide6 6.8.3)
- ✅ sudo NOPASSWD para `ipsec`
- ✅ caminhos de config configuráveis
- ✅ launcher + desktop entry
- ✅ documentação completa
