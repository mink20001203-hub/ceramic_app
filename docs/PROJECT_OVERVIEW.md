# Project Overview

## 프로젝트 목적

OUD는 도자기 상품 커머스를 가정한 Flutter/Firebase 포트폴리오 프로젝트입니다.

목표는 단순 상품 목록 앱이 아니라, 구매자·판매자·관리자 역할을 나누고 각 역할에 맞는 화면, 데이터 접근, 주문 상태 흐름을 구현하는 것입니다.

## 핵심 사용자

| 사용자 | 목적 |
| --- | --- |
| 구매자 | 상품 탐색, 장바구니, 주문, 주문 상태 확인, 리뷰/마일리지 관리 |
| 판매자 | 본인 상품/주문 확인, 배송 상태 변경, 취소 요청 처리 |
| 관리자 | 사용자 역할 관리, 정책/FAQ 등 운영 콘텐츠 관리 |

## 주요 기능

- 상품 목록, 카테고리, 검색, 상세 화면
- 장바구니, 주문 생성, 주문 완료
- 주문 목록/상세, 주문 상태 로그
- 쿠폰, 마일리지, 리뷰 관리
- 판매자 주문 관리 및 배송/취소 처리
- 관리자 사용자 역할 관리
- 정책/FAQ 운영 콘텐츠 관리
- Firestore rules 기반 권한 분리
- Firebase rules 테스트 및 데이터 감사 스크립트

## 기술 스택

| 영역 | 기술 |
| --- | --- |
| App | Flutter, Dart |
| State | Provider |
| Backend | Firebase Authentication, Cloud Firestore |
| Hosting | GitHub Pages |
| Local Data | SharedPreferences, Hive |
| Script/Test | Node.js, Firebase CLI, Firebase Admin SDK |
| QA | Flutter analyze, Firestore rules test, manual QA checklist |

## 현재 상태

| 항목 | 상태 |
| --- | --- |
| 구매자 기본 플로우 | 구현 |
| 판매자 주문 처리 | 구현 |
| 관리자 역할 관리 | 구현 |
| 정책/FAQ 관리 | 구현 |
| Firestore rules | 구현 |
| rules 테스트 스크립트 | 구현 |
| 포트폴리오용 최신 스크린샷 | 확인 필요 |
| 실제 결제 PG 연동 | 개선 예정 |
| 한글 인코딩 깨짐 정리 | 개선 예정 |

## 개선 계획

- 깨진 한글 문자열과 문서 인코딩 정리
- 최신 포트폴리오 스크린샷 추가
- 소스 코드와 GitHub Pages 빌드 산출물 분리
- 주문, 리뷰, 알림 흐름 테스트 보강
- Firestore 인덱스와 운영 데이터 초기화 절차 문서화
- 실제 결제 연동은 별도 개선 과제로 분리

## 관련 문서

- [FEATURES.md](FEATURES.md)
- [FIRESTORE_SCHEMA.md](FIRESTORE_SCHEMA.md)
- [AI_WORKFLOW.md](AI_WORKFLOW.md)
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- [QA_CHECKLIST.md](QA_CHECKLIST.md)
