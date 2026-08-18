---
title: "Controle de Versão"
description: "Modelo Git Flow, convenções de commit e processo de release"
date: 2026-08-18T15:30:00-03:00
updated: 2026-08-18T15:30:00-03:00
tags: [desenvolvimento, versionamento, git-flow, release]
aliases: [Versionamento, Git Flow, Controle de Versão]
related:
  - desenvolvimento/Contributing
  - empacotamento/Packaging-Overview
---

# Controle de Versão

O projeto usa **Git Flow** com SemVer e **Conventional Commits**.

---

## Branches

| Branch | Papel | Protegida |
|---|---|---|
| `main` | Código de produção. Só entra via merge de `release/*`. Tags aqui. | Sim |
| `develop` | Integração. Feature branches nascem daqui. | Não |
| `release/vX.Y.Z` | Preparação de release. Bumps de versão e fixes finais. | Não |
| `feature/*` | Funcionalidades novas. Nasce de `develop`, merge de volta. | Não |
| `hotfix/*` | Correção urgente em produção. Nasce de `main`, merge em `main` e `develop`. | Não |

---

## Fluxo de Release (Git Flow)

Etapa sequencial, sem atalhos:

### 1. Criar release branch

```bash
git checkout develop
git pull origin develop
git checkout -b release/vX.Y.Z
```

### 2. Bumps de versão

Atualizar versão em todos os pontos:
- `packaging/appimage/build.sh` → variável `APP_VERSION`
- `packaging/deb/build.sh` → variável `APP_VERSION`
- `packaging/rpm/SPECS/vpn-ipsec-client.spec` → campo `Version` e `%changelog`

Commit:
```
build: bump packaging version to vX.Y.Z
```

Push da branch de release:
```bash
git push origin release/vX.Y.Z
```

### 3. Testes finais

Buildar e validar artefatos:
```bash
# AppImage (local)
bash packaging/appimage/build.sh

# RPM (via container Fedora)
bash packaging/rpm/build.sh

# DEB (via container Debian)
podman run --rm -v "$(pwd):/workspace:z" -w /workspace debian:bookworm-slim bash -c \
  "apt-get update -qq && apt-get install -y -qq dpkg-dev python3 && bash packaging/deb/build.sh"
```

### 4. Merge em main + tag

```bash
git checkout main
git merge release/vX.Y.Z --no-ff -m "release: merge vX.Y.Z into main"
git tag vX.Y.Z
git push origin main --tags
```

> A tag é **imutável** — nunca mover ou recriar.

### 5. Publicar release no GitHub

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z - Descrição Curta" \
  --notes "..." \
  packaging/appimage/VPN-IPsec-Client-vX.Y.Z-x86_64.AppImage \
  packaging/deb/vpn-ipsec-client_vX.Y.Z_amd64.deb \
  packaging/vpn-ipsec-client-vX.Y.Z-1.x86_64.rpm
```

### 6. Merge de volta em develop

```bash
git checkout develop
git merge release/vX.Y.Z --no-edit
git push origin develop
```

### 7. Deletar release branch

```bash
git branch -d release/vX.Y.Z
git push origin --delete release/vX.Y.Z
```

---

## Conventional Commits

Formato: `<tipo>(escopo): descrição`

### Tipos

| Tipo | Uso |
|---|---|
| `feat` | Funcionalidade nova |
| `fix` | Correção de bug |
| `docs` | Documentação |
| `style` | Formatação (sem lógica) |
| `refactor` | Refatoração |
| `test` | Testes |
| `build` | Empacotamento, deps, CI |
| `chore` | Manutenção geral |
| `release` | Merge de release branch em main |

### Regras

- Subject ≤ 50 chars
- Body (quando necessário) separada por linha em branco
- **Nunca commitar sem preview** — sempre mostrar `git status` / `git diff` antes
- **Nunca push automático** — aguardar confirmação
- Staging só de arquivos intencionais — nunca secrets/keys

---

## Versionamento SemVer

```
MAJOR.MINOR.PATCH
  │      │     └─ Correções de bug, sem mudança de API
  │      └─────── Funcionalidades novas, compatível retroativamente
  └─────────────── Breaking changes
```

---

## Hotfix

Correção urgente sem esperar a próxima release:

```bash
git checkout main
git checkout -b hotfix/vX.Y.Z
# fix...
git commit -m "fix: ..."
git checkout main
git merge hotfix/vX.Y.Z --no-ff
git tag vX.Y.Z
git checkout develop
git merge hotfix/vX.Y.Z
git branch -d hotfix/vX.Y.Z
```

---

## Regras do Repo (AGENTS.md)

1. Comunicação em PT-BR
2. Fluxo SPATA (SPEC → PLAN → ANALYSIS → TASK → APPROVE) antes de código
3. Sem comentários internos no código
4. Nunca commitar sem aprovação
5. Nunca push sem confirmação explícita

---

*Última atualização: 2026-08-18*
