# 워크플로우 — Docusaurus 위키 현행화

> **발행 명령**: 프로젝트 루트에서 `./wikidoc_publish.sh`
> **확인 URL**: `http://localhost:{NGINX_PORT}/wiki/` (wiki 컨테이너 / 프로파일 기동 필요)
>
> **이 워크플로우의 존재 이유**: `ai-docs/` 는 AI 컨텍스트 전용(git ignore). 같은 사실을 사람이 읽을 수 있도록 **반드시** `wiki/wiki-docs/` 에 별도 작성하여 발행한다. 둘 중 하나만 운영하면 안 된다 (자세한 이유는 [`/README.md`](../../README.md) "AI 와 사람을 위한 산출물을 분리해서 운용한다" 섹션 참조).

---

## 자동 vs 수동

| 구분 | 대상 | 방법 |
|---|---|---|
| ✅ 자동 | 진척도·이슈 로그 등 정형 파일 | `./wikidoc_publish.sh` 실행 시 `wiki/wiki-docs/private/` 로 자동 복사 (스크립트에서 매핑 정의) |
| ✋ 수동 | 일반 wiki 문서 | 직접 편집 후 `./wikidoc_publish.sh` 실행 |

> 자동 동기화 매핑은 프로젝트별로 `wikidoc_publish.sh` 안에서 정의한다. 새 자동 동기화 대상이 생기면 본 워크플로우와 스크립트 양쪽을 함께 갱신.

---

## 변경 영역 → 업데이트 대상 매핑 (예시)

> 프로젝트 시작 시 본 표를 실제 wiki 디렉터리 구조에 맞춰 채워 넣는다.

| 작업 영역 | 수동 업데이트 파일 | 주요 업데이트 내용 |
|---|---|---|
| FE 스택·라이브러리 변경 | `wiki/wiki-docs/services/frontend.md` | 기술 스택 테이블 |
| BE 엔드포인트 추가·변경 | `wiki/wiki-docs/services/backend.md` | 엔드포인트 테이블 |
| DB 스키마 변경 | `wiki/wiki-docs/private/database.md` | 스키마 정의, ERD |
| 컨테이너·네트워크·보안 구조 변경 | `wiki/wiki-docs/private/architecture.md` | 컨테이너 구성, 보안 레이어 |
| 서비스 맵·포트·GW 라우팅 변경 | `wiki/wiki-docs/services/overview.md` | 아키텍처 다이어그램, 라우팅 테이블 |
| 프로젝트 전반 개요·접속 URL 변경 | `wiki/wiki-docs/intro.md` | 개요 테이블, 빠른 시작 |

---

## 절차

```
1. 작업 완료 (코드 / 인프라 변경)
   ↓
2. 위 매핑 표를 보고 영향 받는 wiki 파일 수동 편집
   ↓
3. 자동 동기화 대상 파일이 갱신되었는지 확인 (스크립트가 처리)
   ↓
4. ./wikidoc_publish.sh 실행 — 무중단 재빌드
   ↓
5. http://localhost:{NGINX_PORT}/wiki/ 에서 발행 결과 확인
   ↓
6. Public/Private 권한 영역에 맞게 노출되는지 확인
   - Public: 누구나
   - Private: Basic Auth (.env 의 WIKI_AUTH_USER / WIKI_AUTH_PASS)
```

---

## 발행 스크립트 옵션 (예시)

> 보일러플레이트에는 스크립트 본체가 포함되어 있지 않다. 프로젝트 초기화 시 saigon-rider 의 `wikidoc_publish.sh` 를 참고하여 작성한다.

```bash
./wikidoc_publish.sh              # 자동 동기화 + 무중단 발행
./wikidoc_publish.sh --sync-only  # 파일 복사만 (docker 명령 생략)
./wikidoc_publish.sh --no-build   # 재기동만 (이미지 재빌드 생략)
./wikidoc_publish.sh --help       # 도움말
```

---

## 점검 체크리스트

- [ ] 코드 변경이 사람에게 노출되어야 할 정보를 포함하는가?
- [ ] 위 매핑 표 중 해당 행이 있는가? 없으면 본 워크플로우에 행 추가.
- [ ] Private 영역에 들어가야 할 민감 정보가 Public 으로 노출되지 않는가?
- [ ] `./wikidoc_publish.sh` 실행 후 wiki 컨테이너가 정상 기동되는가?
