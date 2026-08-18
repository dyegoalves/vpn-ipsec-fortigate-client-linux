<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **vpn-ipsec-fortigate-client-linux** (717 symbols, 883 relationships, 12 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? `npx gitnexus analyze` (npm 11 crash → `npm i -g gitnexus`; #1939).

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows. For regression review, compare against the default branch: `detect_changes({scope: "compare", base_ref: "main"})`.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `query({search_query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `context({name: "symbolName"})`.
- For security review, `explain({target: "fileOrSymbol"})` lists taint findings (source→sink flows; needs `analyze --pdg`).

## Never Do

- NEVER edit a function, class, or method without first running `impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit changes without running `detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/vpn-ipsec-fortigate-client-linux/context` | Codebase overview, check index freshness |
| `gitnexus://repo/vpn-ipsec-fortigate-client-linux/clusters` | All functional areas |
| `gitnexus://repo/vpn-ipsec-fortigate-client-linux/processes` | All execution flows |
| `gitnexus://repo/vpn-ipsec-fortigate-client-linux/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->

## Git rules

- **Never push automatically.** Do not run `git push` without explicit user confirmation.
- **Never commit without preview/confirmation.** Do not run `git commit` without first showing what will be committed and getting confirmation.
- Always stage only intended files. Never commit secrets or keys.

## Git Flow rules

Este projeto usa **Git Flow estrito** (documentado em `docs/desenvolvimento/Versionamento.md`). Regras obrigatórias:

- Commits de desenvolvimento vão **sempre** em `develop` (`git checkout develop` antes de commitar).
- `main` recebe conteúdo **apenas** via merge de `release/*` ou `hotfix/*`. Nunca fast-forward direto de `develop` para `main`.
- **Nunca** criar commites de "sync"/"align" manuais entre branches para "consertar" divergência visual. Em Git Flow, `main` e `develop` frequentemente ficam em commits diferentes com conteúdo idêntico — isso é o estado normal, não é bug.
- Criação de release: `release/vX.Y.Z` a partir de `develop` → bumps de versão → build de artefatos → merge em `main` + tag → merge em `develop` → deletar branch.
- Tags são imutáveis, nunca mover/recriar.
- Push sempre requer aprovação explícita do usuário.
- SemVer: `MAJOR.MINOR.PATCH` (fix → PATCH, feat → MINOR, breaking → MAJOR).
- Conventional Commits: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `build`, `chore`, `release`.
