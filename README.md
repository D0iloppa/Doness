# Doness — Project Boilerplate
@Author : D0iloppa

> Docker 격리성 + AI/사람 이중 산출물 운용 규약을 골격으로 제공하는 보일러플레이트.
> 본 저장소는 **프로젝트 구현이 아니라 골격** 이다. 실제 코드는 클론 후 채워 넣는다.

---

## 핵심 철학

### 1. Docker 의 "격리성" 을 적극적으로 활용한다

본 보일러플레이트는 다음을 강제하기 위해 모든 런타임을 컨테이너로 분리한다:

- **의존성 격리**: 호스트에 Node·Python·Postgres 를 설치하지 않는다. 모든 언어 런타임/라이브러리는 각 서비스 이미지 안에서만 산다.
- **네트워크 격리**: 서비스 간 통신은 사용자 정의 브릿지 네트워크에서만 발생. 외부 노출은 GW(Nginx) 한 포트에 일원화.
- **볼륨 격리**: DB 데이터·업로드 콘텐츠·캐시는 각각 명시적 named volume. 호스트 디렉터리 직접 마운트는 개발 모드(Dockerfile.dev / HMR) 에서만.
- **환경 격리**: `.env` 한 파일로 dev/stg/prod 차이를 흡수. 코드는 환경 무관.
- **재현 격리**: `docker compose down -v` 한 줄로 모든 상태를 초기화하고 동일 결과를 재현할 수 있다.

> 호스트에 설치가 필요한 것은 오직 **Docker** 와 **Git** 뿐이라는 상태를 유지한다.

### 2. AI 와 사람을 위한 산출물을 분리해서 운용한다 (Wiki 병행)

코드만 잘 굴러간다고 끝이 아니다. 같은 시스템을 **두 청자** 가 읽는다:

| 청자 | 무엇을 보나 | 어디에 쓰나 |
|---|---|---|
| **AI 에이전트** (다음 스레드, 다른 클로드) | 산출물 지도 → 현재 상태 → 필요 문서만 선택 로드 | `ai-docs/` (git ignore, 로컬 전용) |
| **사람** (팀원, 신규 합류자, 운영자) | 친절한 설명·다이어그램·튜토리얼·접속 정보 | `wiki/wiki-docs/` (Docusaurus, git 커밋, `wiki` 컨테이너로 발행) |

**둘 중 하나만 운영하면 안 된다.**

- AI 만 운영하면 — 사람이 따라잡지 못한다. 신규 합류자가 헤맨다.
- Wiki 만 운영하면 — AI 컨텍스트 비용이 폭발한다. 매 스레드마다 처음부터 설명한다.

본 보일러플레이트는 두 산출물을 같은 git 트리(`ai-docs/` 는 ignore, `wiki/` 는 commit) 에 두되, **운영 규약을 [`GUIDELINE.md`](GUIDELINE.md) 한 곳에서 통제** 한다. AI 운영 절차는 [`ai-docs/INDEX.md`](ai-docs/INDEX.md), 사람 산출물 발행 절차는 [`ai-docs/workflow/wiki-update.md`](ai-docs/workflow/wiki-update.md) 참조.

---

## 추천 도커 구조

5개 서비스가 골격이다. 프로젝트 성격에 따라 일부만 사용해도 좋지만, **GW 와 wiki 는 항상 함께 둔다** (격리성 + 사람 산출물 원칙).

```
                ┌─────────────────────────────────────────┐
  외부 단일 진입 ──▶ │  GW (Nginx alpine)                       │
                │  /api/*  → BE                            │
                │  /wiki/* → wiki                          │
                │  /*      → FE                            │
                └──────┬───────────┬───────────┬──────────┘
                       │           │           │
              ┌────────▼──┐  ┌─────▼─────┐  ┌──▼──────────┐
              │ FE        │  │ BE        │  │ wiki         │
              │ (Vite)    │  │ (FastAPI) │  │ (Docusaurus) │
              └───────────┘  └─────┬─────┘  └──────────────┘
                                   │
                            ┌──────▼──────┐
                            │ DB          │
                            │ (Postgres)  │
                            └─────────────┘
```

| 서비스 | 역할 | 추천 이미지/기술 |
|---|---|---|
| **GW** | 단일 외부 진입점, 경로 라우팅, TLS, rate-limit | `nginx:alpine` |
| **FE** | 사용자 UI | Vite dev / `nginx:alpine` 정적 서빙 prod |
| **BE** | API, 비즈니스 로직 | FastAPI (Python 3.12) 또는 동급 |
| **DB** | 영속 데이터 | `postgres:15` (+ PostGIS 등 확장 선택) |
| **wiki** | 사람용 개발자/사용자 문서 포털 | Docusaurus 3 (별도 프로파일 권장) |

`wiki` 는 `docker compose --profile wiki up` 같이 별도 프로파일로 분리하여, 일상 개발 사이클에는 빠지고 발행 시점에만 기동되게 한다.

---

## 추천 버전

> 본 보일러플레이트는 다음 조합을 검증된 출발점으로 권장한다. 새 프로젝트 시작 시 그대로 사용하거나 일부만 교체해도 안정적이다.

### Frontend (React 계열)

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.26.0",
    "zustand": "^4.5.4",
    "i18next": "^26.1.0",
    "react-i18next": "^17.0.7",
    "lucide-react": "^1.16.0",
    "sonner": "^2.0.7",
    "flag-icons": "^7.5.0"
  },
  "devDependencies": {
    "typescript": "^5.5.3",
    "vite": "^5.4.0",
    "@vitejs/plugin-react": "^4.3.1",
    "@types/react": "^18.3.3",
    "@types/react-dom": "^18.3.0",
    "@types/node": "^25.7.0"
  }
}
```

> Vue 계열을 선택할 경우 `Vue 3` + `Pinia` + `TanStack Query (Vue Query)` + `TailwindCSS` 조합을 권장.

### Backend (FastAPI)

```
# requirements.txt
fastapi==0.115.5
uvicorn[standard]==0.32.0
asyncpg==0.30.0
sqlalchemy[asyncio]==2.0.36
passlib[bcrypt]==1.7.4
python-dotenv==1.0.1
python-multipart==0.0.20
httpx>=0.27
PyJWT==2.9.0
tzdata>=2024.1
```

Python 베이스 이미지: `python:3.12-slim`

### Database

- `postgres:15` (필요 시 `postgis/postgis:15-3.4`)
- 초기 스키마는 `database/init/${NNN}_${title}.sql` 순번 적용
- 컨테이너 최초 기동 시 `/docker-entrypoint-initdb.d/` 가 파일명 순서대로 실행

### Gateway

- `nginx:alpine`
- 설정은 `nginx/conf.d/default.conf` 한 파일에 라우팅 일원화

### Wiki

- Docusaurus 3 (Node 20 LTS 베이스)
- `wiki/wiki-docs/` 에 마크다운, `./wikidoc_publish.sh` 로 무중단 재빌드
- Private 문서는 Basic Auth 로 보호 (`.env` 의 `WIKI_AUTH_USER` / `WIKI_AUTH_PASS`)

---

## 디렉터리 골격 (이 보일러플레이트가 제공하는 부분)

```
Doness/
├── skill.md                  # AI 진입 시 규약 강제
├── GUIDELINE.md              # AI 운용 규칙 (로컬 전용)
├── README.md                 # 이 파일 (사용자 시점, git 커밋)
├── .gitignore
└── ai-docs/                  # AI 컨텍스트 (로컬 전용, git ignore)
    ├── INDEX.md              # 산출물 지도
    ├── context/
    │   └── current.md        # 세션 캐리오버
    ├── spec/                 # 명세 (프로젝트별 채워 넣기)
    ├── workflow/
    │   ├── README.md         # 워크플로우 인덱스
    │   ├── project-todo-management.md
    │   └── wiki-update.md    # 사람 산출물 발행 절차
    ├── task/
    │   ├── active/           # 진행 중 태스크
    │   └── archive.md        # 완료 태스크 색인
    ├── trouble/
    │   └── index.md          # 트러블슈팅 색인
    └── project_todo.md       # 다영역 협업 후속 TODO
```

프로젝트를 시작할 때 클론 받고:

1. **`.gitignore` 활성화** — 파일 하단의 `GUIDELINE.md` / `skill.md` / `ai-docs/` 3줄 주석을 해제하여 AI 컨텍스트 산출물을 git 추적에서 제외한다. (보일러플레이트 저장소 자체는 골격 제공을 위해 추적 유지)
2. `ai-docs/spec/` 에 프로젝트 명세를 적는다.
3. `ai-docs/context/current.md` 의 마지막 갱신 / 활성 태스크를 채운다.
4. `docker-compose.yml` 를 GW/FE/BE/DB/wiki 골격으로 작성한다.
5. `wiki/` 디렉터리를 만들어 Docusaurus 를 초기화한다.
6. 첫 활성 태스크를 `ai-docs/task/active/${YYMMDD}_${title}.md` 로 시작한다.

---

## 라이선스 / 사용

이 보일러플레이트는 여러 운영 경험에서 추출한 패턴이다. 자유롭게 fork 해서 사용 가능. 개선 사항은 PR 환영.
