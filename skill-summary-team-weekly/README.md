# skill-summary-team-weekly

핀테크트라이브 개발/기획팀 위클리를 통합 요약하고, 결과를 로컬 파일 및 Confluence에 저장하는 Claude Code 스킬 패키지입니다.

## 파일 구조

```
skill-summary-team-weekly/
├── README.md
├── SKILL.md
├── summary-team-weekly.md
└── weekly-summary-team.sh
```

## 설치

```bash
cp /Users/sy.im/my-skill/skill-summary-team-weekly/summary-team-weekly.md ~/.claude/commands/
mkdir -p ~/.claude/scripts
cp /Users/sy.im/my-skill/skill-summary-team-weekly/weekly-summary-team.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/weekly-summary-team.sh
```

## 사용법

수동 실행:

```bash
claude --dangerously-skip-permissions -p "/summary-team-weekly"
```

자동 실행(cron, 매주 목요일 09:00):

```bash
(crontab -l 2>/dev/null; echo "0 9 * * 4 /Users/sy.im/.claude/scripts/weekly-summary-team.sh") | crontab -
```

## 자동화 동작

매주 목요일 09:00에 LaunchAgent가 `weekly-summary-team.sh`를 실행하면 `/summary-team-weekly YYYY-MM-DD` 한 번 호출로 아래가 모두 진행됩니다.

1. **로컬 파일 저장** — `/Users/sy.im/Documents/내창고/위클리/팀/YYYY-MM-DD.md`
2. **Confluence 페이지 생성/업데이트** — `TO-DO`(parent: `5858689612`) 하위에 `YYYY-MM-DD-summary-team-weekly` 제목 (동일 제목 있으면 업데이트)
3. **JDP 티켓 댓글 추가** — 매칭된 XPJPD 이슈에 위클리 요약 댓글
