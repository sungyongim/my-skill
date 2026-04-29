# Skill My TODO — 오늘의 할일 생성/마무리

인자: `$ARGUMENTS`

**모드 분기 (인자 첫 토큰):**
- `morning` 또는 인자 없음 또는 첫 토큰이 `YYYY-MM-DD`만: **아침 모드** — Jira·Slack·Confluence·Google Calendar 검색하여 오늘의 할일을 중요도별로 정리, Confluence/로컬에 페이지 생성, 회의록 템플릿 생성. (Step 1~5)
- `evening`: **저녁 모드(23시 정리)** — 오늘 실제로 한 일을 카테고리별로 취합하여 같은 날짜 페이지를 update. (Step E1~E3, 아래 별도 섹션)

대상 날짜: 인자 중 `YYYY-MM-DD` 형식 토큰 (없으면 오늘). 예시:
- `/skill-my-todo` → 오늘 아침 모드
- `/skill-my-todo 2026-04-29` → 2026-04-29 아침 모드
- `/skill-my-todo evening` → 오늘 저녁 모드
- `/skill-my-todo evening 2026-04-29` → 2026-04-29 저녁 모드

## 설정

- **site**: `kurly0521.atlassian.net`
- **사용자 이메일**: `sy.im@kurlycorp.com`
- **Slack 사용자 ID**: `U04NNHQJDA8`
- **Confluence TO-DO 부모 페이지 ID**: `5858689612` (FIN 스페이스)
- **FIN 스페이스 ID**: `3938452937`
- **검색 범위**: 대상 날짜 기준 1일 전 ~ 당일 (Slack), 3일 전 ~ 당일 (Confluence/Jira)

## 실행 절차

### Step 1: 멀티 플랫폼 동시 검색 (오늘 + 어제)

아래 검색을 **병렬**로 실행한다:

#### 1-0. 어제 한 일 검색 (전일 활동 요약용)

대상 날짜의 전일(어제)에 대해 아래를 병렬 검색한다:

**Google Calendar**: `list_events`로 어제의 이벤트 조회
- 어제 참석/주관한 미팅 목록

**Slack**: `slack_search_public_and_private`로 어제 내가 보낸 메시지 검색
- 검색어: `from:<@U04NNHQJDA8> on:{어제 날짜}`
- 내가 어제 어떤 채널에서 어떤 소통을 했는지 파악

**Jira**: `searchJiraIssuesUsingJql`
- JQL: `assignee = currentUser() AND updated >= "{어제}" AND updated < "{오늘}"`
- 어제 업데이트한 이슈 목록

**Confluence**: `searchConfluenceUsingCql`
- CQL: `contributor = currentUser() AND lastModified >= "{어제}" AND lastModified < "{오늘}"`
- 어제 수정/작성한 페이지 목록

검색 결과를 종합하여 **"어제 한 일"** 섹션을 `- [x]` (완료 체크) 형식으로 작성한다.
카테고리: 미팅/일정, Slack 소통/처리, Confluence 문서 작업, Jira

#### 1-1. Google Calendar 검색

`list_events`로 대상 날짜 기준 3일 전 ~ 당일+1일 범위의 이벤트를 조회한다.
- 대상 날짜의 이벤트만 필터링하여 시간순 정렬
- 종일 이벤트와 시간대별 이벤트를 분리

#### 1-2. Jira 검색

`searchJiraIssuesUsingJql`로 아래 JQL 검색:
```
assignee = currentUser() AND status != Done AND updated >= -3d
```
- site: `kurly0521.atlassian.net`
- 추가로 아래 JQL도 실행:
```
assignee = currentUser() AND status != Done ORDER BY priority DESC
```

#### 1-3. Slack 검색

`slack_search_public_and_private`로 최근 1일간(어제~오늘) 나에게 관련된 메시지 검색:
- 검색어 1: `to:me after:{1일전 날짜}`
- 검색어 2: `<@U04NNHQJDA8> after:{1일전 날짜}` (멘션된 메시지)
- 검색어 3: `성용 after:{1일전 날짜} -from:<@U04NNHQJDA8>` (이름으로 언급된 메시지)
- 각 메시지의 핵심 내용과 액션 아이템 추출
- **Slack 소통 요약 섹션**에 사용할 메시지별 요약과 채널명 정리

#### 1-4. Confluence 검색

`searchConfluenceUsingCql`로 아래 CQL 검색:
```
contributor = currentUser() AND lastModified >= "{3일전 날짜}"
```
- site: `kurly0521.atlassian.net`
- 최근 수정/기여한 페이지 목록 확인

### Step 2: 할일 분류 및 정리

수집된 정보를 아래 중요도 기준으로 분류한다:

#### 중요도 1 — 오늘 반드시 처리 (긴급+중요)
- 오늘 일정에 있는 미팅 (특히 본인이 organizer인 미팅)
- Slack에서 승인/응답 요청이 온 것
- 마감이 오늘인 Jira 이슈
- 오늘 배포 예정 건

#### 중요도 2 — 오늘 중 확인/후속 조치 (중요)
- 오늘 일정의 일반 미팅 (참석자)
- Slack에서 확인/검토 요청이 온 것
- 진행 중인 Jira 이슈
- 최근 수정한 Confluence 페이지 중 후속 조치 필요한 것

#### 중요도 3 — 인지 사항 (참고)
- Slack에서 공유/참고용 메시지
- 종일 이벤트 (기념일, 만기 등)
- 최근 업데이트된 Confluence 문서 변경 사항
- 향후 일정 관련 사전 준비 사항

### Step 3: 출력 포맷 작성

아래 markdown 구조로 컨텐츠를 작성한다:

```markdown
# 오늘의 할일 — {대상날짜 YYYY-MM-DD (요일)}

> **요약**: 미팅 N건, 액션아이템 N건, 참고사항 N건, Slack 소통 N건

---

## 오늘 일정

| 시간 | 일정 | 비고 |
|------|------|------|
| HH:MM-HH:MM | 일정명 | 역할(주관/참석), 장소 등 |

---

## 중요도 1 — 오늘 반드시 처리

- [ ] **할일 내용** — 시간/출처 : 상세 설명
- [ ] **할일 내용** — 출처 : 상세 설명

---

## 중요도 2 — 오늘 중 확인/후속 조치

- [ ] **할일 내용** — 출처 : 상세 설명

---

## 중요도 3 — 인지 사항

- [ ] **인지 사항** — 출처 : 상세 설명

---

## Slack 소통 요약

### 카테고리명 (N건) — #채널명

- [ ] **발신자명** — 요약 내용 (관련 티켓/이슈)
- [ ] **발신자명** — 요약 내용

### 카테고리명 (N건)

- [ ] **발신자명** — 요약 내용 — #채널명

(Slack 메시지를 주제별로 그룹핑: 승인요청, 감사/보안, 인프라/개발, 기타 소통 등)

---

## 오늘 하루 흐름

| 시간 | 일정/할일 |
|------|----------|
| ~첫 미팅 전 | 사전 처리 할일 |
| HH:MM-HH:MM | 미팅/할일 |
| ... | ... |

---

## 어제 한 일 — {전일 YYYY-MM-DD (요일)}

### 미팅/일정 (N건)

- [x] **미팅명** — HH:MM-HH:MM, 역할(주관/참석), 장소

### Slack 소통/처리

- [x] **소통 내용 요약** — 상대방/채널, 처리 결과

### Confluence 문서 작업

- [x] **"페이지 제목" 작성/수정** — 상세 내용

### Jira

- [x] **이슈키 — 이슈 제목** — 상태 변경/코멘트 등
- (업데이트된 이슈가 없으면 "어제 업데이트된 담당 이슈 없음" 표시)

---

## 생성된 회의록 템플릿 (Step 6)

- `[2026-04-29_1400_fintech-weekly.md](path)` — 14:00-15:00 핀테크 위클리 (신규)
- `2026-04-29_1500_review.md` — 15:00-16:00 리뷰 미팅 (이미 존재, 스킵)

---

## 검색 출처
- Google Calendar: {대상날짜} 일정
- Slack: 어제 발신 메시지 N건 + 최근 1일 수신 멘션 N건
- Confluence: 어제 수정 페이지 N건 + 최근 3일 수정 페이지 N건
- Jira: 담당 이슈
```

### Step 4: Confluence 페이지 생성

`createConfluencePage`로 아래 설정으로 페이지를 생성한다:

- **spaceId**: `3938452937`
- **parentPageId**: `5858689612`
- **title**: `{대상날짜 YYYY-MM-DD (요일)}` (예: `2026-04-24 (목)`)
- **contentFormat**: `markdown`
- **content**: Step 3에서 작성한 markdown 내용

생성 완료 후 페이지 URL을 사용자에게 알려준다.

### Step 5: 미팅 회의록 템플릿 생성

Step 1-1에서 수집한 **대상 날짜의 캘린더 이벤트** 중 **시간이 정해진 미팅**(종일 이벤트 제외)에 대해 회의록 템플릿 파일을 미리 생성한다.

#### 5-1. 저장 경로 및 파일명

- **저장 디렉토리**: `/Users/sy.im/Documents/내창고/업무/회의록/` (없으면 생성)
- **파일명 형식**: `YYYY-MM-DD_HHMM_<slug>.md`
  - `HHMM`: 미팅 시작 시간 (예: 14:00 → `1400`)
  - `<slug>`: 캘린더 이벤트 제목을 kebab-case로 변환
    - 영문/숫자: 소문자로, 공백을 `-`로
    - 한글: 그대로 유지하되 공백을 `-`로
    - 특수문자(괄호·콜론·슬래시 등) 제거
  - 예: `핀테크 위클리 (정기)` → `2026-04-29_1400_핀테크-위클리.md`
  - 예: `1:1 with John` → `2026-04-29_1400_1-1-with-john.md`

#### 5-2. 중복 처리 (idempotent)

- 동일 파일이 **이미 존재하면 절대 덮어쓰지 않는다** (사용자가 작성 중일 수 있음)
- 존재 여부는 `Bash`의 `test -f` 또는 `Read` 시도로 확인
- 스킵한 파일은 출력 시 `(이미 존재, 스킵)`으로 표기

#### 5-3. 템플릿 내용

각 미팅마다 아래 markdown을 작성한다 (`Write` 도구 사용):

```markdown
---
title: <캘린더 이벤트 제목>
type: meeting
created: {대상날짜 YYYY-MM-DD}
date: {대상날짜 YYYY-MM-DD}
time: {HH:MM-HH:MM}
location: <장소 또는 회의 링크 — 캘린더 location 필드>
attendees:
  - 본인
  - <다른 참석자들 — 캘린더 attendees에서 추출>
organizer: <주관자 이름/이메일>
calendar_event_id: <캘린더 이벤트 ID>
tags: [meeting]
---

# <캘린더 이벤트 제목>

## 안건
- 

## 논의 내용
- 

## 결정 사항
- 

## 액션 아이템
- [ ] **담당자** — 내용 (마감)

## 다음 단계 / 후속 회의
- 
```

frontmatter 값은 캘린더 이벤트에서 추출한 실제 데이터로 채운다. 본문 섹션의 `-` 뒤는 비워두어 사용자가 미팅 후 직접 채울 수 있도록 한다.

#### 5-4. 결과 정리

생성 결과를 Step 3의 출력 포맷 중 **"생성된 회의록 템플릿"** 섹션에 정리한다:
- 신규 생성된 파일은 `(신규)` 표시
- 이미 존재한 파일은 `(이미 존재, 스킵)` 표시
- Step 4의 Confluence 페이지를 갱신할 때 이 섹션도 함께 포함된다.
- 본 단계는 Step 4 (Confluence 페이지 갱신) 전에 실행하여 결과 목록을 페이지에 반영한다.

### Step 6: 로컬 파일 저장 (Confluence 미러링)

Step 4에서 Confluence에 게시한 markdown 콘텐츠와 **완전히 동일한 내용**을 로컬에도 저장한다.

#### 6-1. 저장 경로 및 파일명

- **저장 디렉토리**: `/Users/sy.im/Documents/내창고/나의할일/` (없으면 `mkdir -p`로 생성)
- **파일명 형식**: `{대상날짜 YYYY-MM-DD}.md` (예: `2026-04-29.md` — 요일·괄호 없이 단순 날짜)

#### 6-2. 동작 규칙

- 회의록(Step 5)과 달리, 동일 파일이 이미 존재해도 **덮어쓴다** (Confluence 페이지와 항상 동기화 유지).
- 저장하는 본문은 **Step 3의 markdown 그대로** — Confluence와 로컬이 단일 진실 공급원(SSoT)을 공유하도록 한다.
- 저장 완료 후 파일 절대경로를 사용자에게 알려준다.

#### 6-3. 출력 포맷에 표기

Step 3 markdown의 **"검색 출처"** 섹션 아래에 한 줄 추가하지 않는다. 대신 **로컬 파일 저장 자체는 사용자 응답(터미널 출력)에서만 안내**한다 — Confluence 페이지와 로컬 파일이 완전히 동일한 본문이어야 하므로 자기 참조 정보는 본문에 넣지 않는다.

---

# 저녁 모드(23시 정리) 실행 절차

저녁 모드는 **이미 존재하는 같은 날짜의 todo 페이지를 update**한다. 새 페이지를 만들지 않는다.

전제: 아침 모드가 같은 날에 이미 실행되어 Confluence 페이지(`{대상날짜 YYYY-MM-DD (요일)}`)와 로컬 파일(`/Users/sy.im/Documents/내창고/나의할일/{대상날짜}.md`)이 존재한다.

### Step E1: 오늘 실제로 한 일 — 멀티 소스 병렬 검색

대상 날짜 = 오늘. 아래 7개 소스를 **병렬**로 검색한다:

#### E1-1. Google Calendar
`list_events`로 **대상 날짜에 종료된 이벤트** 조회 — 실제 참석한 미팅 목록.

#### E1-2. Slack — 발신 메시지
`slack_search_public_and_private`:
- 검색어: `from:<@U04NNHQJDA8> on:{대상날짜}`
- 봇 호출(`/줌`, `/줄` 같은 슬래시 커맨드)·"네", "감사합니다" 류 짧은 응답은 카운트하되 본문 요약에서는 제외하고, **의미 있는 소통**만 추출.

#### E1-3. Jira
`searchJiraIssuesUsingJql`:
- JQL: `assignee = currentUser() AND updated >= "{대상날짜}" AND updated < "{대상날짜+1일}"`
- 오늘 본인이 업데이트한 이슈만.

#### E1-4. Confluence
`searchConfluenceUsingCql`:
- CQL: `contributor = currentUser() AND lastModified >= "{대상날짜}" AND lastModified < "{대상날짜+1일}"`
- 오늘 작성·수정한 페이지만 (어제 만든 것이 lastModified만 갱신된 경우는 제목/내용으로 판별).

#### E1-5. 회의록 (로컬)
`find /Users/sy.im/Documents/내창고/업무/회의록 -name "{대상날짜}_*.md"`로 오늘 미팅 회의록 파일 목록 확인. 각 파일의 본문에서 사용자가 채운 **결정 사항·액션 아이템**이 있는지 확인하여 요약.

#### E1-6. 내창고 wiki (로컬)
`find /Users/sy.im/Documents/내창고/wiki -type f -mtime -1`로 오늘 변경된 wiki 파일 목록 추출. 신규/갱신 구분 후 카테고리(people/concepts/projects/notes)별로 정리.

#### E1-7. Claude Code 대화
`find /Users/sy.im/.claude/projects/-Users-sy-im -maxdepth 1 -type f -name "*.jsonl" -mtime -1`로 오늘 활성 세션 추출. 각 세션 파일에서 사용자 prompt(`{"type":"user", ...}`)를 추출하여 주제별로 요약 — "스킬 수정", "위클리 작성", "위키 정리", "회의록 분석" 등 굵직한 작업을 파악.

### Step E2: 출력 본문 작성 — "오늘 한 일" 섹션

아침 모드에서 만든 본문 구조의 **"오늘 하루 흐름"과 "어제 한 일"** 사이에 신규 `## 오늘 한 일 (저녁 갱신 — HH:MM)` 섹션을 삽입한다.

섹션 구조:

```markdown
## 오늘 한 일 — {대상날짜 YYYY-MM-DD (요일)} (저녁 갱신 — HH:MM)

### 미팅/일정 (N건 참석)
- [x] **미팅명** — HH:MM-HH:MM, 역할(주관/참석), 핵심 결과 1줄

### Slack 소통/처리 (N건)
- [x] **상대방** — 요약 내용 (관련 티켓/링크) — #채널명

### Confluence 문서 작업 (N건)
- [x] **"페이지 제목" 작성/수정** — 한 줄 요약
- (오늘 신규 작성한 페이지를 우선 표기, lastModified만 갱신된 어제분은 별도 표기)

### Jira (N건)
- [x] **이슈키 — 이슈 제목** — 상태 변경/코멘트 등
- (없으면 "오늘 업데이트한 담당 이슈 없음")

### 회의록 작성 (N건)
- [x] **회의록 파일명** — 사용자가 채운 핵심 결정/액션 (있는 경우만)

### 내창고 wiki 변경 (N건)
- [x] **카테고리/파일명** — 신규/갱신, 한 줄 설명

### Claude Code 작업 (N건)
- [x] **세션 주제** — 한 줄 요약 (예: "skill-my-todo evening 모드 추가")
```

각 항목은 `- [x]` 완료 체크박스 형식으로 작성한다 (다음 날 아침 모드에서 "어제 한 일" 섹션으로 자연스럽게 인용 가능).

### Step E3: 페이지 update (Confluence + 로컬)

#### E3-1. 기존 페이지 본문 가져오기

- Confluence: `getConfluencePage`로 현재 페이지(title=`{대상날짜 YYYY-MM-DD (요일)}`, parent=`5858689612`) 본문 가져오기. 이미 "오늘 한 일" 섹션이 있으면 **덮어쓴다** (저녁 모드 재실행 시 최신화).
- 로컬: `Read`로 `/Users/sy.im/Documents/내창고/나의할일/{대상날짜}.md` 본문 가져오기.

#### E3-2. 본문에 섹션 삽입/교체

- 위치: "## 오늘 하루 흐름" 섹션 끝(다음 `---`) 직후, "## 어제 한 일" 직전
- 기존 "## 오늘 한 일 ..." 섹션이 있으면 통째로 교체, 없으면 신규 삽입

#### E3-3. 두 곳 모두 update

- Confluence: `updateConfluencePage` (versionMessage: `Evening update — 오늘 한 일 reflected`)
- 로컬: `Write`로 `/Users/sy.im/Documents/내창고/나의할일/{대상날짜}.md` 덮어쓰기

업데이트 완료 후 페이지 URL과 로컬 파일 경로를 사용자에게 알린다.
