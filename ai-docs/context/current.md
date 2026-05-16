# 현재 상황 (Session Carry-Over)

> 다음 스레드가 이 파일만 읽고도 작업을 이어받을 수 있도록 작성.
> 큰 변경 후 갱신. **마지막 갱신**: {YYYY-MM-DD} (보일러플레이트 초기 상태)

## 활성 태스크

없음 — 새 작업을 시작하면 [`task/active/`](../task/active/) 에 `${YYMMDD}_${title}.md` 로 등록.

## 다음 우선순위

(프로젝트 시작 시 채워 넣기 — `spec/` 의 명세 또는 `project_todo.md` 항목을 참조)

## 최근 작업 이력

| 시각 | 작업 | 결과 |
|---|---|---|
| {YYYY-MM-DD} | 보일러플레이트 초기화 | `ai-docs/` 골격, `GUIDELINE.md`, `skill.md` 배치 완료 |

## 미해결 결함

현재 추적 중인 결함 없음. 발견 시 [`trouble/index.md`](../trouble/index.md) 에 색인 추가.

## 다음 스레드 진입 시 권장 순서

1. [INDEX.md](../INDEX.md) → 이 파일 (`current.md`) 확인
2. 다음 우선순위 항목에 해당하는 [`spec/`](../spec/) 문서 로드
3. 새 태스크는 `task/active/${YYMMDD}_${title}.md` 로 시작
