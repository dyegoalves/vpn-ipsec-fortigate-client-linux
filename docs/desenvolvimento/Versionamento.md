---
title: "Controle de Versão"
description: "Modelo GitHub Flow, convenções de commit e processo de release"
date: 2026-08-18T15:30:00-03:00
updated: 2026-08-18T16:40:00-03:00
tags: [desenvolvimento, versionamento, github-flow, release]
aliases: [Versionamento, GitHub Flow, Controle de Versão]
related:
  - desenvolvimento/Contributing
  - empacotamento/Packaging-Overview
---

# Controle de Versão

O projeto usa **GitHub Flow** com SemVer e **Conventional Commits**.

---

## Branches

| Branch | Papel | Protegida |
|---|---|---|
| `main` | Branch única. Todo desenvolvimento, produção e tags. | Sim |
| `feature/*` | Funcionalidades ou correções. Nasce de `main`, merge de volta. | Não |

> `develop` e `release/*` não são usados. Tudo flui por `main`.

---

## Fluxo de Desenvolvimento

Etapa sequencial:

### 1. Branch de trabalho a partir de `main`

```bash
git checkout main
git pull origin main
git checkout -b feature/nome-da-feature
```

### 2. Commits

Commits direto na branch de trabalho, seguindo Conventional Commits:

```
fix: corrige duplo clique na bandeja
feat: adiciona suporte a múltiplas conexões
```

### 3. Merge em `main`

```bash
git checkout main
git merge feature/nome-da-feature --no-ff
git push origin main
```

Após o merge, apagar a branch de trabalho (local e remoto).

---

## Fluxo de Release (GitHub Flow)

Release = tag em `main` + publicação com artefatos.

### 1. Garantir `main` atualizado

```bash
git checkout main
git pull origin main
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

### 3. Buildar artefatos

```bash
# AppImage (local)
bash packaging/appimage/build.sh

# RPM (via container Fedora)
bash packaging/rpm/build.sh

# DEB (via container Debian)
podman run --rm -v "$(pwd):/workspace:z" -w /workspace debian:bookworm-slim bash -c \
  "apt-get update -qq && apt-get install -y -qq dpkg-dev python3 && bash packaging/deb/build.sh"
```

### 4. Criar tag

```bash
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

## Regras do Repo (AGENTS.md)

1. Comunicação em PT-BR
2. Fluxo SPATA (SPEC → PLAN → ANALYSIS → TASK → APPROVE) antes de código
3. Sem comentários internos no código
4. Nunca commitar sem aprovação
5. Nunca push sem confirmação explícita
6. Commit direto em `main` ou via `feature/*` — sem branches intermediárias

---

*Última atualização: 2026-08-18*