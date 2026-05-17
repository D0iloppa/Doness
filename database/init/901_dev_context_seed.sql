-- __DEV: 초기 시드 데이터 (템플릿)
-- 900_dev_context.sql 실행 후 적용
-- 프로젝트에 맞게 카테고리·기능명·할일을 수정하여 사용한다.

-- ── Context: 현재 진행 상태 ──────────────────────────────────────
INSERT INTO "__DEV_context" (key, value) VALUES
  ('current_sprint', '초기 셋업 + 핵심 기능 구현'),
  ('current_focus', '프로젝트 초기 구성'),
  ('last_deploy', '20XX-XX-XX'),
  ('blocker', '없음'),
  ('next_milestone', '첫 번째 마일스톤 설명')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();

-- ── Features: 전체 기능 리스트 ───────────────────────────────────
-- 카테고리는 프로젝트에 맞게 정의한다 (예: auth, home, feed, profile, settings, infra)
INSERT INTO "__DEV_features" (category, name, status, sort_order) VALUES
  -- Infra
  ('infra', 'Docker Compose 서비스 구성', 'DONE', 1),
  ('infra', 'Nginx 리버스 프록시 & 라우팅', 'DONE', 2),
  ('infra', 'PostgreSQL 스키마 초기화', 'DONE', 3),
  ('infra', 'Docusaurus 위키', 'PLANNED', 4),
  -- Auth (예시)
  ('auth', '회원가입/로그인', 'PLANNED', 1),
  ('auth', '세션 관리', 'PLANNED', 2),
  -- Core (프로젝트 핵심 기능 — 카테고리명을 변경하여 사용)
  ('core', '핵심 기능 A', 'PLANNED', 1),
  ('core', '핵심 기능 B', 'PLANNED', 2),
  -- Frontend
  ('frontend', 'SPA 뼈대', 'DONE', 1),
  ('frontend', '공통 레이아웃', 'PLANNED', 2)
ON CONFLICT DO NOTHING;

-- ── Todos: 현재 진행 중 & 예정 작업 ──────────────────────────────
INSERT INTO "__DEV_todos" (title, priority, status, feature_id) VALUES
  ('초기 DB 스키마 설계', 'HIGH', 'TODO', NULL),
  ('API 엔드포인트 설계', 'HIGH', 'TODO', NULL),
  ('프론트엔드 라우팅 구성', 'MEDIUM', 'TODO', NULL)
ON CONFLICT DO NOTHING;
