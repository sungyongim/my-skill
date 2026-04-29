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

# 1) 위클리 파일 생성
claude --dangerously-skip-permissions \
  -p "/summary-team-weekly ${TODAY}" \
  --max-turns 60 \
  >> "$LOG_FILE" 2>&1

GEN_EXIT=$?
echo "[$(date)] summary-team-weekly exit=${GEN_EXIT}" >> "$LOG_FILE"

if [ $GEN_EXIT -ne 0 ]; then
  exit $GEN_EXIT
fi

if [ ! -f "$OUTPUT_FILE" ]; then
  echo "[$(date)] Output file not found: $OUTPUT_FILE" >> "$LOG_FILE"
  exit 1
fi

# 2) Confluence 업로드 (동일 제목 페이지 존재 시 업데이트)
PROMPT="Read markdown file at ${OUTPUT_FILE} and use Atlassian MCP on kurly0521.atlassian.net to ensure a child page exists under parent page ID 5858689612 with title ${TODAY}-summary-team-weekly. If the page already exists, update it. If not, create it. Use markdown content from the file as-is. Return only the final page URL."

claude --dangerously-skip-permissions \
  -p "$PROMPT" \
  --max-turns 40 \
  >> "$LOG_FILE" 2>&1

UPLOAD_EXIT=$?
echo "[$(date)] confluence upload exit=${UPLOAD_EXIT}" >> "$LOG_FILE"

# 30일 이전 로그 정리
find "$LOG_DIR" -name "weekly-summary-team-*.log" -mtime +30 -delete 2>/dev/null

exit $UPLOAD_EXIT
