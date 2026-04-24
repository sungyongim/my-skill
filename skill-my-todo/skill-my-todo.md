# Skill My TODO — 오늘의 할일 생성

대상 날짜: `$ARGUMENTS` (인자가 없으면 오늘 날짜 사용)

Jira, Slack, Confluence, Google Calendar을 검색하여 오늘의 할일을 중요도별로 정리하고, Confluence에 페이지로 작성한다.

## 설정

- **site**: `kurly0521.atlassian.net`
- **사용자 이메일**: `sy.im@kurlycorp.com`
- **Slack 사용자 ID**: `U04NNHQJDA8`
- **Confluence TO-DO 부모 페이지 ID**: `5858689612` (FIN 스페이스)
- **FIN 스페이스 ID**: `3938452937`
- **검색 범위**: 대상 날짜 기준 3일 전 ~ 당일

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

**로컬 파일**: `find ~/Documents/지식창고 -type f -mtime -2` 등으로 어제 변경된 로컬 문서 확인

검색 결과를 종합하여 **"어제 한 일"** 섹션을 `- [x]` (완료 체크) 형식으로 작성한다.
카테고리: 미팅/일정, Slack 소통/처리, Confluence 문서 작업, Jira, 로컬 문서

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

`slack_search_public_and_private`로 최근 3일간 나에게 관련된 메시지 검색:
- 검색어 1: `to:me after:{3일전 날짜}`
- 검색어 2: `<@U04NNHQJDA8> after:{3일전 날짜}` (멘션된 메시지)
- 검색어 3: `성용 after:{3일전 날짜} -from:<@U04NNHQJDA8>` (이름으로 언급된 메시지)
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

## 어제 한 일 — {전일 YYYY-MM-DD (요일)}

### 미팅/일정 (N건)

- [x] **미팅명** — HH:MM-HH:MM, 역할(주관/참석), 장소
- [x] **미팅명** — HH:MM-HH:MM, 참석

### Slack 소통/처리

- [x] **소통 내용 요약** — 상대방/채널, 처리 결과
- [x] **소통 내용 요약** — 상대방/채널, 처리 결과

### Confluence 문서 작업

- [x] **"페이지 제목" 작성/수정** — 상세 내용

### Jira

- [x] **이슈키 — 이슈 제목** — 상태 변경/코멘트 등
- (업데이트된 이슈가 없으면 "어제 업데이트된 담당 이슈 없음" 표시)

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

## 검색 출처
- Google Calendar: {대상날짜} 일정
- Slack: 최근 3일 메시지 (멘션 N건 + 추가 검색 N건)
- Confluence: 최근 3일 수정 페이지
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

### Step 5: 로컬 파일 저장

아래 경로에도 markdown 파일로 저장한다:

```
/Users/sy.im/Documents/지식창고/할일/{대상날짜}.md
```

저장 완료 후 파일 경로를 사용자에게 알려준다.
