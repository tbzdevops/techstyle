# Day 12 — AI in DevOps (Projekt)

## Umfang
Zwei Lektionen (90 Min): AI-Review-Bot für die TechStyle-Pipeline.

| Schritt | Datei |
| --- | --- |
| 1 — Spec | `specs/ai-review.md` |
| 2 — Workflow (TODO 1–3 gelöst) | `.github/workflows/ai-review.yml` |
| 3 — Absicherung gegen Prompt und Script Injection | `.github/workflows/ai-review.yml` |
| 4 — ADR | `docs/adr/0001-ai-review-in-der-pipeline.md` |
| 5 — Reflexion | `AI_INTEGRATION.md` |

## Abnahmekriterien
- ✅ Spec mit Ziel, Anforderungen, Akzeptanzkriterien und Out of Scope
- ✅ AI-Workflow reagiert auf Pull Requests und ruft GitHub Models auf
- ✅ Nur Python-Diff, Fallback bei API-Fehler, AI-Hinweis im Kommentar
- ✅ Minimale Berechtigungen, keine PR-Inhalte direkt in `run:`
- ✅ ADR mit Status, Kontext, Entscheidung, Konsequenzen
- ✅ `AI_INTEGRATION.md` mit Grenzen und Security-Betrachtung

## Testen
1. Branch anlegen, eine `.py`-Datei ändern, Pull Request auf `main` öffnen.
2. Nach etwa einer Minute erscheint der Kommentar "🤖 AI Code Review".
3. Zweiten PR mit Injection-Kommentar öffnen (siehe Tagesplanung, Schritt 3).
