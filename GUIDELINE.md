# AI Agent Guideline

새 스레드에서 AI가 따라야 할 운용 규칙. 산출물 색인은 [`ai-docs/INDEX.md`](ai-docs/INDEX.md), 현재 작업 상태는 [`ai-docs/context/current.md`](ai-docs/context/current.md).

## 1. 진입 순서

새 스레드는 항상 다음 순서로 두 파일만 읽고 시작한다:

1. [`ai-docs/INDEX.md`](ai-docs/INDEX.md) — 산출물 지도
2. [`ai-docs/context/current.md`](ai-docs/context/current.md) — 직전 작업 상태 / 다음 우선순위

전체 파일 풀텍스트 검색 금지. 위 두 파일에서 필요한 문서만 선택적으로 로드한다.

## 2. 파일 작성 위치 (SoT 매핑)

| 종류 | 파일 위치 | 색인 갱신 |
|---|---|---|
| 활성 태스크 | `ai-docs/task/active/${YYMMDD}_${title}.md` | `current.md` 활성 태스크 라인 |
| 완료 태스크 | `ai-docs/task/${YYMMDD}/${file}.md` | `task/archive.md` |
| 트러블슈팅 | `ai-docs/trouble/${YYMMDD}/${YYMMDD}_${title}_troubleshooting.md` | `trouble/index.md` |
| 아키텍처 / 인프라 | `ai-docs/context/architecture.md` 등 | `INDEX.md` |
| 명세 / 계획 | `ai-docs/spec/${file}.md` | `INDEX.md` |
| 다영역 협업 후속 TODO | `ai-docs/project_todo.md` 카테고리 섹션에 항목 추가 | `INDEX.md` (이미 색인됨) |
| 신규 영구 산출물 | 적절한 디렉터리 + `INDEX.md` 색인 | `INDEX.md` |
| 반복 태스크 절차 | `ai-docs/workflow/${name}.md` | `workflow/README.md` + `INDEX.md` |

**중복 금지**: 한 사실은 한 곳에만. 현재 상태는 `current.md`만, 산출물 위치는 `INDEX.md`만.

## 3. 컨텍스트 이어받기

큰 작업(기능 완료, 결함 수정, 구조 변경) 직후 [`context/current.md`](ai-docs/context/current.md)를 갱신한다. 다음 스레드가 `INDEX.md` + `current.md` 두 파일만 읽고 작업을 이어받을 수 있어야 한다.

## 4. 구현 반영

구현 완료된 기능은 다음 위치에 반영한다:
- `/README.md` (사용자 시점)
- `ai-docs/spec/` 내 해당 명세 문서 (개발 시점)

## 5. 자주 쓰는 명령

```bash
# 전체 스택 기동 (개발)
docker compose --env-file .env up --build -d

# 위키 동기화 (사람이 읽는 산출물 발행)
./wikidoc_publish.sh
```

## 6. 사람을 위한 산출물 (Wiki 병행)

`ai-docs/` 는 AI 컨텍스트 유지 전용(로컬 + git 제외). 사람이 읽을 산출물은 **반드시** `wiki/` 디렉터리(Docusaurus) 에 별도 작성하여 `wiki` 컨테이너로 발행한다. 두 산출물은 같은 사실을 다른 시점에서 기술하지만 **중복 작성이 아니라 청자 분리**다.

| 청자 | 산출물 | 운영 |
|---|---|---|
| AI / 다음 스레드 | `ai-docs/` | git ignore, 로컬 전용 |
| 사람 / 팀원 | `wiki/wiki-docs/` (Docusaurus) | git 커밋, `./wikidoc_publish.sh` 발행 |

## 7. 로컬 전용

`GUIDELINE.md`, `skill.md`, `ai-docs/` 는 git 에 커밋하지 않는다 (`.gitignore` 적용). AI 컨텍스트 유지 전용.
