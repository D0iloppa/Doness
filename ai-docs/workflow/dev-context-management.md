# 워크플로우 — __DEV Context 현행화

> **대상 테이블**: `__DEV_context`, `__DEV_features`, `__DEV_todos`  
> **관리 경로**: Admin Console `/admin/dev` 또는 API `/api/dev/*`  
> **목적**: 프로젝트 진행 상태를 DB로 관리하여 위키 홈·어드민·AI 컨텍스트에서 실시간 참조할 수 있게 한다.  
> **핵심 원칙**: 작업 시작/완료 시 반드시 갱신한다. md 파일이 아닌 DB가 진행 상태의 SoT(Source of Truth)이다.

---

## 테이블 구조

`__DEV` prefix를 사용하여 서비스 테이블과 명확히 분리한다. SQL은 `database/init/900_dev_context.sql` 참조.

| 테이블 | 역할 |
|---|---|
| `__DEV_context` | Key-Value 저장소. 현재 스프린트·포커스·블로커 등 한 줄 요약 |
| `__DEV_features` | 기능 목록. 카테고리별 그룹, 상태(PLANNED/IN_PROGRESS/DONE/DEFERRED) 추적 |
| `__DEV_todos` | 할일 관리. 우선순위(URGENT~LOW), 상태(TODO/IN_PROGRESS/DONE/BLOCKED), Feature 연결 |

---

## 트리거 시점

| 상황 | 해당 절차 |
|---|---|
| 새 기능 구현을 시작할 때 | [§1 Feature 등록/상태 변경](#1-feature-등록--상태-변경) |
| 구현 완료·보류 시 | [§1 Feature 상태 변경](#1-feature-등록--상태-변경) |
| 후속 할일을 발견했을 때 | [§2 Todo 등록](#2-todo-관리) |
| 할일을 처리하거나 블로커가 해소됐을 때 | [§2 Todo 상태 변경](#2-todo-관리) |
| 스프린트·포커스·마일스톤이 바뀔 때 | [§3 Context 갱신](#3-context-갱신) |
| 정기 점검 시 | [§4 점검 체크리스트](#4-점검-체크리스트) |

---

## 접근 방법

### 어드민 콘솔 (권장)

| 경로 | 기능 |
|---|---|
| `/admin/dev` | 전체 현황 대시보드 + 인라인 추가/삭제 |
| ↻ 버튼 | Feature·Todo 상태 순환 (한 클릭) |

### REST API

| 엔드포인트 | 메서드 | 용도 |
|---|---|---|
| `/api/dev/summary` | GET | 위키·대시보드용 통합 요약 |
| `/api/dev/context` | GET / PUT / DELETE | Context KV 조회·수정·삭제 |
| `/api/dev/features` | GET / POST / PATCH / DELETE | Feature CRUD |
| `/api/dev/todos` | GET / POST / PATCH / DELETE | Todo CRUD |

### 직접 SQL (초기 시드·벌크 갱신)

```bash
docker exec -i {DB컨테이너명} psql -U {유저} -d {DB명} < database/init/901_dev_context_seed.sql
```

---

## 1. Feature 등록 / 상태 변경

### 카테고리 규칙

프로젝트 도메인에 맞게 카테고리를 정의한다. 시드 파일(`901_dev_context_seed.sql`)에 예시가 있다.

| 카테고리 | 범위 (예시) |
|---|---|
| `infra` | Docker·Nginx·DB·위키·어드민 |
| `auth` | 온보딩·인증·세션 |
| `core` | 프로젝트 핵심 기능 (도메인에 맞게 분할) |
| `frontend` | SPA 뼈대·공통 UI·모바일 |

### 상태 전이

```
PLANNED → IN_PROGRESS → DONE
                ↓
            DEFERRED
```

| 상태 | 의미 | 전환 시점 |
|---|---|---|
| `PLANNED` | 명세에 정의됨, 미착수 | 초기 등록 시 |
| `IN_PROGRESS` | 구현 진행 중 | 활성 태스크 생성 시 |
| `DONE` | 구현 완료 + 기본 동작 확인 | 코드 머지 후 |
| `DEFERRED` | 의도적 보류 | 우선순위 밀림·외부 의존 시 |

---

## 2. Todo 관리

### 우선순위

| 값 | 기준 |
|---|---|
| `URGENT` | 다른 작업 차단 중, 즉시 해결 필요 |
| `HIGH` | 현 스프린트 내 반드시 처리 |
| `MEDIUM` | 다음 스프린트에 처리해도 무방 |
| `LOW` | 여유 있을 때 개선 |

### 상태 전이

```
TODO → IN_PROGRESS → DONE
           ↓
        BLOCKED
```

### Todo → Feature 연결

`feature_id`로 연결하면 Feature 단위로 Todo를 묶어 볼 수 있다. Feature 삭제 시 `feature_id`는 자동 NULL 처리.

---

## 3. Context 갱신

### 표준 키

| Key | 갱신 시점 |
|---|---|
| `current_sprint` | 스프린트 변경 시 |
| `current_focus` | 주 작업 방향이 바뀔 때 |
| `last_deploy` | 배포 후 |
| `blocker` | 블로커 발생/해소 시 |
| `next_milestone` | 다음 목표 설정 시 |

표준 키 외에 자유롭게 추가 가능. 위키 CLI 디스플레이에는 표준 5개 키만 표시된다.

---

## 4. 점검 체크리스트

다음 시점에 `/admin/dev` 를 열어 확인한다:
- 활성 태스크를 완료했을 때
- 스프린트 전환 시

| 점검 항목 | 조치 |
|---|---|
| `IN_PROGRESS` Feature 중 실제 작업이 안 되고 있는 건 없는가 | `PLANNED` 또는 `DEFERRED`로 변경 |
| `DONE` Feature에 남아있는 미완료 Todo가 있는가 | Todo 상태 갱신 또는 신규 Feature로 분리 |
| `BLOCKED` Todo의 차단 사유가 해소됐는가 | `TODO`로 환원 |
| `blocker` Context가 여전히 유효한가 | 해소 시 삭제 또는 값 갱신 |
| `current_sprint`·`current_focus`가 실제 작업과 일치하는가 | 불일치 시 갱신 |

---

## 5. 위키 연동

위키 홈의 CLI 프로그레스 디스플레이는 `/api/dev/summary`를 실시간 fetch한다.

- DB 갱신 즉시 위키에 반영 (위키 재빌드 불필요)
- API 서버 미기동 시 프로그레스 영역이 자동 숨김 (graceful degradation)
- 위키 컴포넌트 구현은 Saigon Rider의 `DevProgress.tsx`를 참고

---

## 6. 다른 워크플로우와의 관계

| 상황 | __DEV Context 조치 | 기존 워크플로우 조치 |
|---|---|---|
| 활성 태스크 생성 | 해당 Feature → `IN_PROGRESS` | `project-todo-management.md` §2 수행 |
| 활성 태스크 완료 | Feature → `DONE`, 관련 Todo → `DONE` | `project-todo-management.md` §3 수행 |
| 새 후속 작업 발견 | Todo 등록 | `project_todo.md`에 항목 등록 (다영역인 경우) |
| 스프린트 전환 | Context 5개 키 전부 갱신 | `context/current.md` 갱신 |

---

## 7. SQL 직접 갱신 (벌크)

```sql
-- Feature 일괄 상태 변경
UPDATE "__DEV_features" SET status = 'DONE', updated_at = NOW()
WHERE category = 'core' AND status = 'IN_PROGRESS';

-- 완료 Todo 일괄 삭제
DELETE FROM "__DEV_todos" WHERE status = 'DONE';

-- Context 갱신
INSERT INTO "__DEV_context" (key, value) VALUES ('current_sprint', '새 스프린트명')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();
```
