<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **vpn-ipsec-fortigate-client-linux** (762 symbols, 1053 relationships, 41 execution flows).

> Index stale? Run `node .gitnexus/run.cjs analyze --index-only` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? Bootstrap with `npx`, `bunx`, or `pnpm dlx` — e.g. `bunx gitnexus@latest analyze` (npm 11 npx crash; #1939).

## Always Do

- **MUST run impact before editing.** Use `impact({target: "symbolName", direction: "upstream"})` or `node .gitnexus/run.cjs impact "symbolName" --direction upstream --repo .`; report callers, processes, and risk. Never substitute grep for graph analysis.
- **MUST analyze graph changes before committing.** Use `detect_changes({scope: "all"})` (MCP) or `node .gitnexus/run.cjs detect-changes --scope all --repo .` (CLI fallback). `partial: true` or `truncated: true` is not a clean check — a zero means unseen, not unaffected; re-run it. For regression review: `detect_changes({scope: "compare", base_ref: "main"})` or `node .gitnexus/run.cjs detect-changes --scope compare --base-ref "main" --repo .`.
- MUST warn on HIGH/CRITICAL `risk` pre-edit; never use `riskSharedAxes` to waive a HIGH/CRITICAL `risk` warning. Compare File/symbol: MCP File omits axes; Graph-RAG expands File.
- **MUST treat `risk: UNKNOWN` as unresolved, not as low.** An empty caller set is not evidence the symbol is unused — it can also mean the callers are not resolvable by the index (plain-object property access, dynamic dispatch, cross-language calls). `impact` pairs `UNKNOWN` with a `riskNote` saying so. Confirm with a text search before treating the symbol as safe to change or delete; do not proceed on the strength of a zero.
- **MUST use `query({search_query: "concept"})` for concepts/flows, `context({name: "symbolName"})` for a named symbol, or `impact` for blast radius, on read-only callers, dependencies, imports, or execution flow.** Graph first; text search only for empty/`UNKNOWN`/literals.
- For security review, `explain({target: "fileOrSymbol"})` lists taint findings (source→sink flows; needs `analyze --pdg`).

## Never Do

- NEVER edit a function, class, or method before MCP/CLI impact analysis.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis, and never read `UNKNOWN` as an all-clear — it means the walk could not answer, which is the one verdict that requires confirming by other means.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit before MCP/CLI graph change analysis.

## Resources

| Resource | Use for |
| --- | --- |
| `gitnexus://repo/vpn-ipsec-fortigate-client-linux/context` | Codebase overview, check index freshness |
| `gitnexus://repo/vpn-ipsec-fortigate-client-linux/clusters` | All functional areas |
| `gitnexus://repo/vpn-ipsec-fortigate-client-linux/processes` | All execution flows |
| `gitnexus://repo/vpn-ipsec-fortigate-client-linux/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
| --- | --- |
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->

## Git rules

- **Never push automatically.** Do not run `git push` without explicit user confirmation.
- **Never commit without preview/confirmation.** Do not run `git commit` without first showing what will be committed and getting confirmation.
- Always stage only intended files. Never commit secrets or keys.

## GitHub Flow rules

Este projeto usa **GitHub Flow** (documentado em `docs/desenvolvimento/Versionamento.md`). Regras obrigatórias:

- **Branch única:** `main` é a única branch de longa duração. Todo desenvolvimento e produção flui por `main`.
- **Sempre criar `feature/*` branch** para código novo, fixes ou qualquer alteração — nunca commitar direto em `main`.
- Fluxo: `git checkout main` → `git checkout -b feature/nome` → commit → merge em `main` via `--no-ff` → deletar branch.
- **Nunca criar branches intermediárias** (`develop`, `release/*`, `hotfix/*`) — o projeto não usa Git Flow.
- Releases: tag em `main` → `gh release create` com artefatos.
- Tags são imutáveis, nunca mover/recriar.
- Push sempre requer aprovação explícita do usuário.
- SemVer: `MAJOR.MINOR.PATCH` (fix → PATCH, feat → MINOR, breaking → MAJOR).
- Conventional Commits: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `build`, `chore`.
