#!/bin/bash
# 매주 목요일 09:00 실행 — summary-team-weekly 자동 생성 + Confluence 업로드
# cron: 0 9 * * 4 /Users/sy.im/.claude/scripts/weekly-summary-team.sh

export PATH="/opt/homebrew/bin:$PATH"
export HOME="/Users/sy.im"

TODAY=$(date +%Y-%m-%d)
LOG_DIR="$HOME/.claude/scripts/logs"
LOG_FILE="$LOG_DIR/weekly-summary-team-${TODAY}.log"
OUTPUT_FILE="$HOME/Documents/내창고/위클리/팀/${TODAY}.md"

mkdir -p "$LOG_DIR" "$(dirname "$OUTPUT_FILE")"

echo "[$(date)] Start summary-team-weekly for ${TODAY}" >> "$LOG_FILE"

# skill이 로컬 파일 저장(Step 4) + Confluence 업로드(Step 5) + JDP 댓글(Step 6)을 모두 처리
claude --dangerously-skip-permissions \
  -p "/summary-team-weekly ${TODAY}" \
  --max-turns 80 \
  >> "$LOG_FILE" 2>&1

EXIT_CODE=$?
echo "[$(date)] summary-team-weekly exit=${EXIT_CODE}" >> "$LOG_FILE"

# 30일 이전 로그 정리
find "$LOG_DIR" -name "weekly-summary-team-*.log" -mtime +30 -delete 2>/dev/null

exit $EXIT_CODE
