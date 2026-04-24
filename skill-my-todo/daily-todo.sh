#!/bin/bash
# 매일 09:00 실행 — Claude Code로 오늘의 할일 생성
# cron: 0 9 * * 1-5 /Users/sy.im/.claude/scripts/daily-todo.sh

export PATH="/opt/homebrew/bin:$PATH"
export HOME="/Users/sy.im"

TODAY=$(date +%Y-%m-%d)
LOG_DIR="$HOME/.claude/scripts/logs"
LOG_FILE="$LOG_DIR/daily-todo-${TODAY}.log"

mkdir -p "$LOG_DIR"

echo "[$(date)] Starting daily-todo for $TODAY" >> "$LOG_FILE"

# Claude Code 실행 (--dangerously-skip-permissions: cron에서 interactive 불가)
claude --dangerously-skip-permissions \
  -p "/skill-my-todo $TODAY" \
  --max-turns 30 \
  >> "$LOG_FILE" 2>&1

EXIT_CODE=$?
echo "[$(date)] Finished with exit code $EXIT_CODE" >> "$LOG_FILE"

# 7일 이전 로그 정리
find "$LOG_DIR" -name "daily-todo-*.log" -mtime +7 -delete 2>/dev/null

exit $EXIT_CODE
