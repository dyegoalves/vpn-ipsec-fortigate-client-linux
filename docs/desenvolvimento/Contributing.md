---
title: "Contribuindo"
description: "Como contribuir para o projeto VPN IPsec Client"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [desenvolvimento, contribuicao, colaboracao]
aliases: [Contributing, Como Contribuir]
related:
  - README
  - desenvolvimento/Development-Setup
  - desenvolvimento/Code-Structure
  - instalacao/Dependencies
---

# 🤝 Contribuindo

## Como Contribuir

1. Fork o repositório
2. Crie uma branch: `git checkout -b feature/nome-da-feature`
3. Faça suas alterações
4. Execute testes/lint
5. Commit: `git commit -m "feat: descrição"`
6. Push: `git push origin feature/nome-da-feature`
7. Abra um Pull Request

> Para releases e fluxo completo de branches, consulte [[Versionamento|Controle de Versão]].

## Padrões de Commit

```
feat:     Nova funcionalidade
fix:      Correção de bug
docs:     Documentação
style:    Formatação (sem mudança de lógica)
refactor: Refatoração de código
test:     Testes
chore:    Manutenção (build, deps, etc)
```

## Checklist de PR

- [ ] Código segue estilo do projeto
- [ ] Documentação atualizada (se necessário)
- [ ] Testes manuais passam
- [ ] Sem warnings do linter
- [ ] Commits seguem convenção

## Ideias para Contribuição

- [ ] Adicionar testes unitários
- [ ] Suporte a múltiplas conexões simultâneas
- [ ] Importar/exportar configurações
- [ ] Notificações do sistema (libnotify)
- [ ] Perfil de conexão (salvar favoritos)
- [ ] Tradução i18n
- [ ] Suporte a WireGuard/OpenVPN
- [ ] Melhorar tratamento de erros swanctl

## Reportando Bugs

Inclua:
- Sistema operacional / distro
- Versão do strongSwan (`ipsec version`)
- Logs relevantes (`~/.vpnlogs/vpn_ipsec_client.log`)
- Passos para reproduzir

## Código de Conduta

- Seja respeitoso
- Código aberto, mente aberta
- Feedback construtivo

---
*[[README|← Voltar]] | [[desenvolvimento/Development-Setup|Setup]] | [[desenvolvimento/Code-Structure|Estrutura de Código]] | [[desenvolvimento/Versionamento|Versionamento]]*