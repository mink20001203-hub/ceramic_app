# Firestore products 자동 시드 스크립트

## 준비

1. Node.js 18+ 설치
2. 프로젝트 루트에서 의존성 설치

```bash
npm i firebase-admin
```

3. 서비스 계정 키 JSON 발급 후 환경변수 설정

PowerShell:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\service-account.json"
```

## 실행

기본 샘플(JSON)으로 upsert:

```bash
node scripts/seed_products_firestore.mjs
```

기존 products 문서 삭제 후 재시드:

```bash
node scripts/seed_products_firestore.mjs --wipe
```

다른 입력 파일 사용:

```bash
node scripts/seed_products_firestore.mjs --input scripts/my_products.json
```

## 입력 파일 형식

- 파일: `scripts/seed_products.sample.json`
- 배열 형태 JSON
- 각 항목 필드: `id,title,subTitle,price,salePrice,image,category,stock,isNew,isSale,options`

## 참고

- 이 스크립트는 Admin SDK를 사용하므로 Firestore Rules를 우회합니다.
- 운영 프로젝트에서 실행 전, 대상 프로젝트/키 파일을 반드시 확인하세요.
