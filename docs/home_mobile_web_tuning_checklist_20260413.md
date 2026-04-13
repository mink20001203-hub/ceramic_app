# Home Mobile/Web Tuning Checklist (2026-04-13)

목적:
- 3번 범위(모바일/웹 최종 디테일 튜닝) 마감 전, 홈 화면 핵심 이슈를 캡처 기반으로 점검

## 캡처 저장 규칙

- 폴더: `C:\ceramic_app\captures\20260413_home_tuning`
- 파일명:
  - `01_home_mobile_top.png`
  - `02_home_mobile_categories.png`
  - `03_home_mobile_restock.png`
  - `04_home_web_top.png`
  - `05_home_web_categories.png`
  - `06_home_web_restock.png`
- 이슈가 있으면 `_issue` 접미사 추가
  - 예: `05_home_web_categories_issue.png`

## 캡처 포인트

1. 상단 히어로 카드
- 통계 3개 카드가 줄바꿈/겹침 없이 보이는지
- 텍스트가 카드 바깥으로 넘치지 않는지

2. 카테고리 칩
- 칩 라벨 잘림 여부
- 선택 상태(체크 아이콘 + 배경색) 정상 노출 여부
- 모바일에서 좌우 스크롤이 자연스러운지

3. 왜 OUD인가요 카드
- 모바일: 가로 스크롤 카드 높이/간격 균일
- 웹: 3열 카드 높이/여백 균일

4. 재입고 카드 하단
- 하단 태그 영역(`다음 업데이트`, `알림 신청`) 줄바꿈 시 overflow 없는지
- 카드 하단 잘림/경고 스트라이프 없는지

## 판정 기준

- PASS:
  - 텍스트 잘림 없음
  - overflow 경고 없음
  - 모바일/웹 모두 주요 블록 간격 일관
- FAIL:
  - 칩 라벨 일부 미노출
  - 재입고 카드 하단 overflow
  - 통계/태그 영역 겹침

## 후속 조치

- PASS면 4번(웹 재배포) 진행
- FAIL이면 해당 캡처 파일명과 위치를 `docs/e2e_execution_log_20260408.md`의 2026-04-13 섹션에 추가
