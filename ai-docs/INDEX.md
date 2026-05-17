# {프로젝트명} — Document Map

> **이 파일은 산출물의 안정적 지도입니다.** 현재 작업 상태는 [`context/current.md`](context/current.md), 규칙은 [`/GUIDELINE.md`](../GUIDELINE.md).

## 📋 명세 / 계획

- (프로젝트 시작 시 `spec/` 에 명세 문서를 추가하고 이곳에 색인)
- [프로젝트 TODO 리스트](project_todo.md) — FE/BE/DB 등 다영역 협업이 필요한 후속 구현 항목 (운영 절차는 [`workflow/project-todo-management.md`](workflow/project-todo-management.md))

## 🏗 아키텍처 / 인프라

- (서비스 구성, 네트워크, 보안 레이어 문서는 `context/architecture.md` 등으로 추가)

## 🔄 워크플로우

> 반복 태스크의 절차·맥락. 필요할 때만 로드.

- [워크플로우 인덱스](workflow/README.md) — 등록된 워크플로우 목록
- [Project TODO 관리](workflow/project-todo-management.md) — `project_todo.md` 등록·착수·완료 아카이빙·보류 절차
- [Docusaurus 위키 현행화](workflow/wiki-update.md) — 사람 산출물 발행 절차
- [__DEV Context 현행화](workflow/dev-context-management.md) — DB 기반 진행 상태 관리 (Feature·Todo·Context), `__DEV` prefix 테이블 규약

## 📦 태스크 / 트러블슈팅 이력

- [활성 태스크](task/active/) — 현재 진행 중 (현황은 [`current.md`](context/current.md))
- [완료 태스크 아카이브](task/archive.md) — 날짜별 색인
- [트러블슈팅 인덱스](trouble/index.md) — 날짜별 색인

## 🌐 외부 자원

- [프로젝트 개요 (`/README.md`)](../README.md)
- Developer Wiki — `/wiki/` 경로 (Docusaurus, wiki 컨테이너 기동 필요)
- 위키 발행: 루트의 `./wikidoc_publish.sh`
