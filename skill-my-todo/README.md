# skill-my-todo

매일 아침 Jira, Slack, Confluence, Google Calendar를 검색하여 오늘의 할일을 중요도별로 정리하고 Confluence에 자동 작성하는 Claude Code 스킬.

## 파일 구조

| 파일 | 설명 |
|------|------|
| `skill-my-todo.md` | Claude Code 스킬 정의 (`~/.claude/commands/`에 배치) |
| `daily-todo.sh` | 매일 09:00 cron 자동 실행 스크립트 (`~/.claude/scripts/`에 배치) |

## 설치

```bash
# 스킬 파일 복사
cp skill-my-todo.md ~/.claude/commands/
cp daily-todo.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/daily-todo.sh

# cron 등록 (매일 09:00)
(crontab -l 2>/dev/null; echo "0 9 * * * ~/.claude/scripts/daily-todo.sh") | crontab -
```

## 사용법

- **수동 실행**: Claude Code에서 `/skill-my-todo` 또는 `/skill-my-todo 2026-04-25`
- **자동 실행**: 매일 09:00 cron으로 자동 실행

## 출력

- **Confluence**: FIN 스페이스 TO-DO 페이지 하위에 `YYYY-MM-DD (요일)` 제목으로 페이지 생성
- **로컬 파일**: `~/Documents/지식창고/할일/YYYY-MM-DD.md`
