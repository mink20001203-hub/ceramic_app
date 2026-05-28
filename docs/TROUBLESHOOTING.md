# Troubleshooting

## 1. Flutter analyze 실행 지연/권한 문제

### 증상

- `flutter analyze`가 오래 걸리거나 멈춤
- `%APPDATA%\.dart-tool` 접근 권한 오류 발생

### 원인

Windows 환경에서 Dart/Flutter 캐시 경로 권한 문제가 발생했습니다.

### 해결

- 임시 `APPDATA` 경로를 프로젝트 내부로 지정
- 직접 Dart SDK 경로를 확인
- 필요 시 Flutter SDK를 `Downloads`가 아닌 안정적인 개발 경로로 이동

관련 문서: [analyze_environment_troubleshooting.md](analyze_environment_troubleshooting.md)

## 2. Firestore permission-denied

### 증상

- 로그인 상태인데 사용자 데이터 또는 주문 데이터 접근 실패
- 판매자/관리자 화면에서 데이터가 보이지 않음

### 확인한 원인

- `users/{uid}.role` 값이 없거나 기대 role과 다름
- 주문 문서의 `buyerId`, `sellerId`가 현재 로그인 사용자와 일치하지 않음
- rules에서 허용하지 않는 상태 변경 시도

### 해결

- demo 계정 role 확인 스크립트 실행
- 주문 무결성 감사 스크립트 실행
- Firestore rules test로 권한 정책 검증

```powershell
cd scripts
npm run check:accounts
npm run audit:orders
npm run audit:sellers
npm run test:rules
```

## 3. 판매자 주문 노출 범위 오류

### 증상

- 판매자 화면에서 다른 판매자의 주문이 보일 가능성
- legacy seed 데이터의 sellerId가 현재 UID와 다름

### 해결

- `currentSellerScopeIds()` 기준으로 현재 UID와 legacy alias를 함께 처리
- `audit_seller_partition.mjs`로 sellerId 분포 점검
- Firestore rules에서 sellerId 기준 접근 제한

관련 문서: [seller_order_filter_verification.md](seller_order_filter_verification.md)

## 4. Flutter UI overflow / 텍스트 잘림

### 증상

- 홈 화면 하단 overflow
- 카테고리 pill/chip 텍스트 잘림
- 좁은 웹/모바일 화면에서 카드 높이 불안정

### 해결

- 고정 높이 wrapper 제거
- 좁은 화면에서 가로 스크롤 레이아웃 적용
- 상태 안내 문구와 주문 화면 copy 정리

관련 로그: [e2e_execution_log_20260408.md](e2e_execution_log_20260408.md)

## 5. 한글 인코딩 깨짐

### 증상

- 일부 Dart/Markdown 파일에서 한글 주석 또는 문자열이 깨져 보임
- QA 문서 일부 내용이 읽기 어려움

### 현재 대응

- `audit_mojibake_strings.mjs`로 의심 문자열 점검
- README와 신규 면접용 문서는 UTF-8 기준으로 재작성

### 남은 작업

- `pubspec.yaml`, 일부 Dart 파일, 일부 QA 문서의 깨진 한글 정리
- 문서 저장 인코딩을 UTF-8로 통일

## 6. GitHub Pages 배포 산출물 관리

### 증상

- 루트에 `main.dart.js`, `canvaskit/`, `flutter_service_worker.js` 등 빌드 산출물이 함께 존재
- 소스 레포 구조가 복잡해 보일 수 있음

### 현재 상태

- GitHub Pages 배포를 위해 산출물이 일부 추적 중입니다.

### 개선 계획

- 소스 브랜치와 배포 브랜치 분리
- 소스 브랜치에서는 빌드 산출물 추적 최소화
- README에 배포 방식 명확히 설명

## 확인 필요

| 항목 | 이유 |
| --- | --- |
| 최신 GitHub Pages 배포 성공 여부 | 실제 배포 페이지 확인 필요 |
| Firebase 콘솔에 배포된 rules 최신성 | 콘솔/배포 로그 확인 필요 |
| 모든 QA 캡처 최신화 여부 | 일부 체크리스트에 미완료 항목 존재 |
