# skill-my-todo

매일 아침 **Jira, Slack, Confluence, Google Calendar, 로컬 파일**을 동시에 검색하여 **어제 한 일 요약** + **오늘의 할일을 중요도별로 분류** + **Slack 소통 요약**까지 정리하고, 결과를 **Confluence 페이지**와 **로컬 파일**로 자동 저장하는 Claude Code 스킬입니다.

---

## 개요

### 해결하는 문제

업무 도구가 분산되어 있으면 아침마다 여러 플랫폼을 돌아다니며 오늘 할 일을 파악해야 합니다. 이 스킬은 그 과정을 자동화합니다.

### 동작 방식

```
Google Calendar ─┐
Jira            ─┤                          ┌─ 어제 한 일 요약
Slack           ─┼─▶ Claude Code 분석/분류 ─┤─ 오늘 할일 (중요도별 체크리스트)
Confluence      ─┤                          ├─ Slack 소통 요약
로컬 파일        ─┘                          ├─ Confluence 페이지
                                            └─ 로컬 마크다운 파일
```

1. 5개 소스를 **병렬 검색** (대상일 기준 최근 3일 + 전일 활동)
2. **어제 한 일** 자동 요약 (미팅, Slack 소통, 문서 작업, Jira)
3. 수집된 정보를 **중요도 3단계**로 자동 분류 (체크박스 형식)
4. **Slack 소통 요약** — 멘션/DM 메시지를 주제별 그룹핑
5. **시간순 하루 흐름표** 생성
6. Confluence 페이지 생성 + 로컬 파일 저장

---

## 파일 구조

```
skill-my-todo/
├── README.md              # 이 문서
├── skill-my-todo.md       # Claude Code 스킬 정의 (~/.claude/commands/에 배치)
└── daily-todo.sh          # cron 자동 실행 스크립트 (~/.claude/scripts/에 배치)
```

---

## 설치

### 1. 스킬 파일 배치

```bash
# 저장소 클론
git clone https://github.com/sungyongim/my-skill.git
cd my-skill/skill-my-todo

# Claude Code 스킬 디렉토리에 복사
cp skill-my-todo.md ~/.claude/commands/

# 자동 실행 스크립트 복사
mkdir -p ~/.claude/scripts
cp daily-todo.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/daily-todo.sh
```

### 2. cron 등록 (자동 실행)

```bash
# 매일 09:00 실행
(crontab -l 2>/dev/null; echo "0 9 * * * ~/.claude/scripts/daily-todo.sh") | crontab -

# 평일만 실행하려면
(crontab -l 2>/dev/null; echo "0 9 * * 1-5 ~/.claude/scripts/daily-todo.sh") | crontab -

# 등록 확인
crontab -l
```

### 3. (선택) GitHub 자동 동기화 Hook

스킬 파일 수정 시 자동으로 GitHub에 commit & push하려면, `~/.claude/settings.json`에 아래 hooks를 추가합니다:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$TOOL_INPUT\" | grep -q 'skill-my-todo'; then ~/.claude/scripts/sync-skill-to-github.sh 'Update skill-my-todo' 2>/dev/null & fi"
          }
        ]
      }
    ]
  }
}
```

---

## 사용법

### 수동 실행

Claude Code 대화에서 슬래시 커맨드로 실행합니다:

```
# 오늘 날짜 기준
/skill-my-todo

# 특정 날짜 지정
/skill-my-todo 2026-04-25
```

### 자동 실행 (cron)

설치 시 등록한 cron이 매일 09:00에 자동 실행합니다.

```bash
# 로그 확인
cat ~/.claude/scripts/logs/daily-todo-$(date +%Y-%m-%d).log

# 수동으로 스크립트 직접 실행
~/.claude/scripts/daily-todo.sh
```

---

## 검색 대상 및 쿼리

### Google Calendar

| 항목 | 값 |
|------|---|
| API | `list_events` |
| 범위 | 대상일 기준 3일 전 ~ 당일+1일 |
| 필터 | 대상일 이벤트만 추출, 시간순 정렬 |

### Jira

| 항목 | 값 |
|------|---|
| API | `searchJiraIssuesUsingJql` |
| JQL 1 | `assignee = currentUser() AND status != Done AND updated >= -3d` |
| JQL 2 | `assignee = currentUser() AND status != Done ORDER BY priority DESC` |

### Slack

| 항목 | 값 |
|------|---|
| API | `slack_search_public_and_private` |
| 오늘 할일 검색 1 | `to:me after:{3일전}` (DM 및 멘션) |
| 오늘 할일 검색 2 | `<@U04NNHQJDA8> after:{3일전}` (멘션 메시지) |
| 오늘 할일 검색 3 | `성용 after:{3일전} -from:<@U04NNHQJDA8>` (이름 언급) |
| 어제 한 일 검색 | `from:<@U04NNHQJDA8> on:{전일}` (내가 보낸 메시지) |

### Confluence

| 항목 | 값 |
|------|---|
| API | `searchConfluenceUsingCql` |
| 오늘 할일 CQL | `contributor = currentUser() AND lastModified >= "{3일전}"` |
| 어제 한 일 CQL | `contributor = currentUser() AND lastModified >= "{전일}" AND lastModified < "{대상일}"` |

### 로컬 파일

| 항목 | 값 |
|------|---|
| 명령 | `find ~/Documents/지식창고 -type f -mtime -2` |
| 용도 | 어제 변경된 로컬 문서 확인 |

---

## 중요도 분류 기준

### 중요도 1 — 오늘 반드시 처리

긴급하고 중요한 항목. 즉시 처리가 필요합니다.

| 조건 | 출처 |
|------|------|
| 본인이 organizer인 미팅 | Google Calendar |
| 승인/응답 요청 메시지 | Slack |
| 마감이 오늘인 이슈 | Jira |
| 오늘 배포 예정 건 | Slack / Confluence |

### 중요도 2 — 오늘 중 확인/후속 조치

중요하지만 긴급하지 않은 항목. 업무 시간 내 처리합니다.

| 조건 | 출처 |
|------|------|
| 참석자로 초대된 미팅 | Google Calendar |
| 확인/검토 요청 메시지 | Slack |
| 진행 중인 담당 이슈 | Jira |
| 후속 조치 필요한 문서 | Confluence |

### 중요도 3 — 인지 사항

참고만 하면 되는 항목. 시간 날 때 확인합니다.

| 조건 | 출처 |
|------|------|
| 공유/참고용 메시지 | Slack |
| 종일 이벤트 (기념일, 만기 등) | Google Calendar |
| 최근 변경된 문서 | Confluence |
| 향후 일정 사전 준비 사항 | Google Calendar |

---

## 출력 형식

### Confluence 페이지

| 항목 | 값 |
|------|---|
| 위치 | FIN 스페이스 > TO-DO 페이지 하위 |
| 제목 | `YYYY-MM-DD (요일)` (예: `2026-04-24 (목)`) |
| 형식 | Markdown |

페이지 구조:

```
오늘의 할일 — 2026-04-24 (목)
├── 요약 (미팅 N건, 액션아이템 N건, 참고사항 N건, Slack 소통 N건)
├── 어제 한 일 (미팅/일정, Slack 소통/처리, Confluence 문서, Jira) ← NEW
├── 오늘 일정 (시간순 테이블)
├── 중요도 1 — 오늘 반드시 처리 (체크박스)
├── 중요도 2 — 오늘 중 확인/후속 조치 (체크박스)
├── 중요도 3 — 인지 사항 (체크박스)
├── Slack 소통 요약 (주제별 그룹핑, 체크박스) ← NEW
├── 오늘 하루 흐름 (타임라인)
└── 검색 출처
```

### 로컬 파일

```
~/Documents/지식창고/할일/YYYY-MM-DD.md
```

Confluence 페이지와 동일한 내용을 로컬에도 저장합니다.

---

## 설정값 (커스터마이징)

`skill-my-todo.md` 상단의 설정 섹션에서 아래 값을 변경할 수 있습니다:

| 설정 | 기본값 | 설명 |
|------|--------|------|
| `site` | `kurly0521.atlassian.net` | Atlassian 사이트 |
| `사용자 이메일` | `sy.im@kurlycorp.com` | Jira/Confluence 계정 |
| `Slack 사용자 ID` | `U04NNHQJDA8` | Slack 멘션 검색용 |
| `Confluence 부모 페이지 ID` | `5858689612` | TO-DO 페이지 하위에 생성 |
| `FIN 스페이스 ID` | `3938452937` | Confluence 스페이스 |
| `검색 범위` | 3일 | 대상일 기준 과거 검색 일수 |

---

## 사전 요구 사항

### Claude Code CLI

```bash
# 설치 확인
claude --version
```

### MCP 서버 연결

이 스킬은 아래 MCP 서버가 Claude Code에 연결되어 있어야 합니다:

| MCP 서버 | 용도 | 필수 |
|----------|------|------|
| Atlassian | Jira 이슈 검색, Confluence 페이지 읽기/생성 | O |
| Slack | 메시지 검색 | O |
| Google Calendar | 일정 조회 | O |

### cron 실행 시 주의사항

- `daily-todo.sh`는 `--dangerously-skip-permissions` 플래그를 사용합니다 (비대화형 환경에서 MCP 도구 승인 프롬프트를 건너뛰기 위함)
- Mac이 절전/종료 상태이면 cron이 실행되지 않습니다 — 09시에 Mac이 켜져 있어야 합니다
- 로그 파일은 7일 후 자동 삭제됩니다

---

## 트러블슈팅

### cron이 실행되지 않음

```bash
# cron 등록 확인
crontab -l

# Mac 터미널에 전체 디스크 접근 권한 확인
# 시스템 설정 > 개인 정보 보호 및 보안 > 전체 디스크 접근 > cron 허용

# 수동 실행으로 오류 확인
~/.claude/scripts/daily-todo.sh
```

### MCP 도구 에러

```bash
# 로그 파일에서 에러 확인
cat ~/.claude/scripts/logs/daily-todo-$(date +%Y-%m-%d).log

# Claude Code에서 MCP 서버 상태 확인
claude mcp list
```

### Confluence 페이지가 생성되지 않음

- 부모 페이지 ID(`5858689612`)가 유효한지 확인
- FIN 스페이스에 페이지 생성 권한이 있는지 확인
- 동일 제목의 페이지가 이미 존재하면 생성 실패할 수 있음

---

## 라이선스

Private 용도. 개인 업무 자동화 목적.
