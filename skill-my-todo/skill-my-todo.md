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

### Step 1: 멀티 플랫폼 동시 검색

아래 4개 검색을 **병렬**로 실행한다:

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
- 검색어: `to:me after:{3일전 날짜}`
- 추가 검색어: `@sy.im after:{3일전 날짜}` (멘션된 메시지)
- 각 메시지의 핵심 내용과 액션 아이템 추출

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

> **요약**: 미팅 N건, 액션아이템 N건, 참고사항 N건

---

## 오늘 일정

| 시간 | 일정 | 비고 |
|------|------|------|
| HH:MM-HH:MM | 일정명 | 역할(주관/참석), 장소 등 |

---

## 중요도 1 — 오늘 반드시 처리

| # | 할일 | 시간/출처 | 상세 |
|---|------|----------|------|
| 1 | **할일 내용** | 출처 | 상세 설명 |

---

## 중요도 2 — 오늘 중 확인/후속 조치

| # | 할일 | 출처 | 상세 |
|---|------|------|------|
| 1 | **할일 내용** | 출처 | 상세 설명 |

---

## 중요도 3 — 인지 사항

| # | 사항 | 출처 | 상세 |
|---|------|------|------|
| 1 | 내용 | 출처 | 상세 설명 |

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
- Slack: 최근 3일 메시지
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
