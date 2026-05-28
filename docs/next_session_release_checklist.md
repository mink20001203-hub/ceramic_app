# Next Session Release Checklist

이 문서는 다음 작업 세션에서 바로 이어서 사용할 운영 체크리스트다.

## 1. Rules Test

작업 위치:

- `C:\ceramic_app\scripts`

실행 순서:

```powershell
cd C:\ceramic_app\scripts
npm install
npm run test:rules:localjdk
```

확인 항목:

- 일반 사용자는 자기 `role`을 `seller` 또는 `admin`으로 변경할 수 없어야 한다.
- 판매자는 `products` 문서를 생성/수정할 수 있어야 한다.
- 일반 사용자는 `products` 문서를 생성/수정할 수 없어야 한다.
- 구매자는 자기 주문에 대해서만 `취소요청` 상태 변경이 가능해야 한다.
- 구매자는 `취소완료`를 직접 처리할 수 없어야 한다.
- 판매자 또는 관리자는 주문 상태를 업데이트할 수 있어야 한다.

## 2. Rules Deploy

사전 조건:

- Firebase CLI 사용 가능 상태
- 로그인 완료 상태

실행 예시:

```powershell
cd C:\ceramic_app
npx firebase deploy --only firestore:rules --project ceramic-app-aadcb
```

배포 후 확인:

- Firebase Console > Firestore Database > Rules에서 최신 내용 반영 여부 확인

## 3. E2E Verification

테스트 계정:

- `user`
- `seller`
- `admin`

구매자 점검:

- 상품 조회
- 장바구니 담기
- 주문 생성
- 주문 상세 진입
- `취소 요청` 실행
- 취소 사유 저장 확인

판매자 점검:

- 판매자 데모/주문 관리 진입
- 주문 목록에서 신규 주문 확인
- 주문 상세에서 송장번호 입력
- 배송 메모 입력
- `발송 처리` 실행
- `취소완료` 처리 실행
- 상태 로그 반영 확인

관리자 점검:

- 마이페이지 > 판매자 권한 관리 진입
- 사용자 목록 확인
- 특정 사용자를 `seller`로 변경
- 변경 후 재로그인 또는 새로고침 시 메뉴 노출 확인

## 4. Git Hygiene

커밋 제외 대상:

- `keys/`
- `scripts/node_modules/`
- `docs/stitch_/`

확인 명령:

```powershell
cd C:\ceramic_app
git status --short
```

## 5. Next Implementation Candidates

우선순위:

1. `products`에 `sellerId` 명시 저장
2. 주문 생성 시 실제 상품 기준 `sellerId` 연결
3. 판매자 주문 목록을 담당 주문만 보이도록 필터링
4. 관리자 화면에 검색/필터 추가
5. Rules 테스트 CI 또는 반복 실행 스크립트 정리

## 6. Deployed URL

- Web app: `https://mink20001203-hub.github.io/ceramic_app/`
