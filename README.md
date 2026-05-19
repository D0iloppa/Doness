# Doness — Project Boilerplate
@Author : D0iloppa

> Docker 격리성 + AI/사람 이중 산출물 운용 규약을 골격으로 제공하는 보일러플레이트.
> `docker compose up` 한 줄로 GW + FE + BE + DB 가 뜬다.

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/D0iloppa/Doness.git my-project
cd my-project

# 2. Environment
cp .env.example .env
# .env 의 <change-me> 항목을 실제 값으로 채운다 (예: openssl rand -hex 32)

# 3. .gitignore 활성화
# 파일 하단의 GUIDELINE.md / skill.md / ai-docs/ 3줄 주석을 해제

# 4. Run (FE + GW only — BE/DB 없이 프론트만 확인)
docker compose up --build -d

# 5. Run (Full stack — BE + DB 포함)
docker compose --profile backend up --build -d

# 6. Run (Wiki 포함)
docker compose --profile wiki up --build -d
```

**확인:**
- `http://localhost:18080/` — Frontend
- `http://localhost:18080/api/health` — Backend API (profile backend)
- `http://localhost:18080/wiki/` — Wiki (profile wiki)

---

## 핵심 철학

### 1. Docker 격리성

호스트에 필요한 건 **Docker + Git** 뿐. 모든 런타임은 컨테이너 안에서만 산다.

### 2. AI + 사람 이중 산출물

| 청자 | 산출물 | 위치 |
|---|---|---|
| AI 에이전트 | 컨텍스트 문서 | `ai-docs/` (git ignore) |
| 사람 | 개발자 위키 | `wiki/wiki-docs/` (git commit) |

둘 중 하나만 운영하면 안 된다. 규약은 [`GUIDELINE.md`](GUIDELINE.md) 에서 통제.

---

## 구조

```
              ┌──────────────────────────┐
 :18080 ───▶  │  GW (nginx:alpine)       │
              │  /*     → FE             │
              │  /api/* → BE             │
              │  /wiki/ → wiki           │
              └───┬──────┬──────┬────────┘
                  │      │      │
               FE(React) BE(FastAPI) wiki(Docusaurus)
                         │
                      DB(Postgres)
```

---

## 상세 문서

- **[docs/REFERENCE.md](docs/REFERENCE.md)** — 추천 버전, 환경변수 규약, __DEV Context, 디렉터리 골격
- **[GUIDELINE.md](GUIDELINE.md)** — AI 운용 규칙
- **[ai-docs/INDEX.md](ai-docs/INDEX.md)** — AI 산출물 지도

---

## License

자유롭게 fork 해서 사용 가능. 개선 사항은 PR 환영.
