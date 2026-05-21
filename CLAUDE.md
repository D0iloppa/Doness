# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Operational Rules — MANDATORY ENTRY ORDER

**Every new session must begin by reading these two files before anything else:**

1. [`ai-docs/INDEX.md`](ai-docs/INDEX.md) — document map (what exists and where)
2. [`ai-docs/context/current.md`](ai-docs/context/current.md) — last session state and next priorities

Do not perform a full-text search of the codebase. Load only the files you need based on the index. Full operational rules are in [`GUIDELINE.md`](GUIDELINE.md).

## Architecture

Single-origin stack behind one Nginx gateway on port 18080. All services communicate over an internal Docker bridge network (`app-net`); nothing is exposed except through the gateway.

```
:18080 (nginx) ──┬── /* ────── FE  (React/Vite → nginx static)
                 ├── /api/* ── BE  (FastAPI, port 8080 internal)
                 ├── /admin/* ─ BE  (admin console routes)
                 └── /wiki/* ── wiki (Docusaurus, port 80 internal)
                               BE ── DB (PostgreSQL 15, port 5432 internal)
```

**Gateway** (`nginx/conf.d/default.conf`): single routing file; `/wiki/docs/private/` is Basic-Auth protected via `.htpasswd`.

**Frontend** (`frontend/`): React 18 + Vite + TypeScript. State via Zustand. Routing via react-router-dom v6. i18n via i18next. Two Dockerfiles — `Dockerfile` (prod multi-stage → nginx static), `Dockerfile.dev` (HMR).

**Backend** (`backend/app/main.py`): FastAPI + SQLAlchemy (async) + asyncpg. JWT auth via PyJWT. Entry point is `main.py`; uvicorn is the server.

**Database**: PostgreSQL 15. Init scripts run in filename order from `database/init/`. `__DEV_` prefixed tables (`__DEV_context`, `__DEV_features`, `__DEV_todos`) track project progress state — seeded by `901_dev_context_seed.sql`.

**Wiki** (`wiki/`): Docusaurus 3. Human-readable docs live in `wiki/wiki-docs/`. Published via `./wikidoc_publish.sh`.

## Commands

```bash
# Full stack (BE + DB included)
docker compose --env-file .env up --build -d

# Frontend + Gateway only (no BE/DB)
docker compose up --build -d

# Include wiki
docker compose --profile wiki up --build -d

# Publish wiki (non-destructive rebuild)
./wikidoc_publish.sh

# Tail logs
docker compose logs -f

# Rebuild a single service
docker compose up --build -d backend
```

Endpoints after startup: `http://localhost:18080/` (FE), `http://localhost:18080/api/health` (BE health), `http://localhost:18080/wiki/` (wiki).

## Environment Variables

`.env` and `.env.example` must always have **identical key sets**. `.env` is gitignored and never committed. `.env.example` is the committed interface template — secret values use `<change-me>`, public defaults use real values.

When adding/removing/renaming any key, update **both files simultaneously**. See `GUIDELINE.md §8` for the full security protocol.

## Document Management (SoT Mapping)

| Type | Location | Index to update |
|---|---|---|
| Active task | `ai-docs/task/active/${YYMMDD}_${title}.md` | `current.md` active task line |
| Completed task | `ai-docs/task/${YYMMDD}/${file}.md` | `task/archive.md` |
| Troubleshooting | `ai-docs/trouble/${YYMMDD}/${YYMMDD}_${title}_troubleshooting.md` | `trouble/index.md` |
| Architecture / infra | `ai-docs/context/architecture.md` etc. | `INDEX.md` |
| Spec / plan | `ai-docs/spec/${file}.md` | `INDEX.md` |
| Cross-domain TODO | `ai-docs/project_todo.md` category section | already indexed |
| Workflow procedures | `ai-docs/workflow/${name}.md` | `workflow/README.md` + `INDEX.md` |

One fact in one place. `current.md` owns current state; `INDEX.md` owns artifact locations.

After any significant change (feature complete, bug fixed, structural change), update `ai-docs/context/current.md` so the next session can pick up from INDEX.md + current.md alone.

## __DEV Context (Progress Tracking)

Project progress is tracked in the DB, not markdown files. After the DB is running:

- `__DEV_context`: key-value store (`current_focus`, `current_sprint`, `blocker`, `next_milestone`) with status emoji (🔧 in-progress / ✅ done / ⏸ waiting / ❌ cancelled)
- `__DEV_features`: feature-level status (`PLANNED → IN_PROGRESS → DONE / DEFERRED`)
- `__DEV_todos`: task-level status (`TODO → IN_PROGRESS → DONE / BLOCKED`)

**Report-first protocol**: update `current_focus` to in-progress *before* making changes; update to done *after* verification. Do not mark DONE simultaneously with implementation.

**Future direction**: consider extracting `__DEV Context` into a dedicated MCP container so Claude Code can read/write project state directly via MCP tool calls instead of going through the backend API. This would make progress tracking a first-class Claude Code integration rather than a side-channel. Implementation is out of scope for this boilerplate — note it in `ai-docs/project_todo.md` when the time comes.

## Git Hygiene

`GUIDELINE.md`, `skill.md`, and `ai-docs/` are **not committed** (`.gitignore` — uncomment those 3 lines after cloning for a real project). `.env` is never committed.
