# skill-stock

보유 주식 종목별 매매전략을 즉시 생성하는 Claude Code 스킬입니다. 뉴스·시세·펀더멘털·공시 4개 소스를 종합 분석하여 매매전략 보고서를 만들고, Notion 매매전략 페이지에 작성합니다.

---

## 개요

### 해결하는 문제

90+ 종목 포지션 + 50% 이상의 신용(융자) 비중을 운용하면서, 매일 아침 모든 종목의 매매전략을 직접 정리하는 일은 시간이 너무 오래 걸립니다. 이 스킬은 그 과정을 자동화합니다.

### 동작 방식

```
보유 스냅샷(holdings/*.csv) ─┐
잔고 스크린샷(KakaoTalk)     ─┤
매매일지(trades/매매일지.csv) ─┤
PER/PBR(per_pbr.csv)        ─┼─▶ Claude Code 4소스 종합분석 ─┬─ 매매전략 보고서
외부 정보(infomation/*)      ─┤  (뉴스·시세·펀더·공시)        ├─ Notion 매매전략 페이지
WebSearch/WebFetch          ─┘                              └─ 로컬 마크다운 파일
```

1. 보유 종목 데이터 로드 (CSV + KakaoTalk 잔고 스크린샷 OCR)
2. 4소스 종합분석 — 뉴스, 시세, 펀더멘털, 공시
3. 외부 정보 폴더(`infomation/`) 자동 참조 — 카카오톡·기사·전문가 코멘트 (-3일 이내 수정 파일)
4. (선택) 가상 "주식전문가팀 14인 패널" 토론 형식으로 심층 분석
5. Notion 매매전략 페이지에 작성 + 로컬 파일 저장

---

## 파일 구조

```
skill-stock/
├── README.md   # 이 문서
└── SKILL.md    # Claude Code 스킬 정의
```

## 사용법

```bash
# 오늘 날짜 기준
claude -p "/skill-stock"

# 특정 날짜 기준
claude -p "/skill-stock 2026-05-06"
```

자동 실행은 `daily_strategy.sh` (launchd 07:00, 별도 설정)에서 동일 로직을 호출합니다.

## 사전 요구 사항

- Claude Code CLI
- Notion MCP 서버 (매매전략 페이지 작성)
- WebSearch / WebFetch 도구 (뉴스·증권사 리포트 검색)
- `/Users/sy.im/Documents/내창고/주식/` 하위에 다음 디렉토리:
  - `holdings/` — 보유 스냅샷 CSV + KakaoTalk 잔고 스크린샷
  - `trades/매매일지.csv` — 최근 거래 내역
  - `holdings/per_pbr.csv` — KRX PER/PBR 데이터
  - `infomation/` — 외부 정보 자료 (카카오톡 캡처·기사 등)
  - `scripts/analyze_targets.py` + `scripts/.venv` — 분석 스크립트

## 주의

- **개인 투자 정보 포함**: SKILL.md 내부에 사용자 보유 섹터/종목, 위험 감내도, 신용 비중 등 매우 개인적인 정보가 포함되어 있습니다. 외부에 공유할 때 주의하세요.
- **신용(융자) 위험 강조**: 50% 이상 신용 비중을 가정하므로, 다른 사용자가 사용하려면 SKILL.md의 "사용자 프로파일" 섹션을 본인 상황에 맞게 수정해야 합니다.
