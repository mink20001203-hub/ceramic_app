import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
import test from 'node:test';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

const PROJECT_ID = 'demo-ceramic-app';
const RULES = readFileSync('../firestore.rules', 'utf8');

let testEnv;

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules: RULES },
  });

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await setDoc(doc(db, 'users/admin_uid'), {
      userName: '관리자',
      email: 'admin@ceramic.com',
      role: 'admin',
    });
    await setDoc(doc(db, 'users/seller_uid'), {
      userName: '판매자',
      email: 'seller@ceramic.com',
      role: 'seller',
    });
    await setDoc(doc(db, 'users/user_uid'), {
      userName: '구매자',
      email: 'user@ceramic.com',
      role: 'user',
    });

    await setDoc(doc(db, 'orders/order_1'), {
      id: 'order_1',
      buyerId: 'user_uid',
      sellerId: 'seller_uid',
      status: '결제완료',
      date: '2026-04-03T10:00:00.000Z',
      items: [],
      totalAmount: 10000,
      discountAmount: 0,
      mileageUsed: 0,
      addressSummary: '서울시 강남구',
      paymentMethodLabel: '신용카드',
      paymentStatus: '결제완료',
      agreementAccepted: true,
      statusLogs: [],
    });
  });
});

test.after(async () => {
  await testEnv.cleanup();
});

test('일반 사용자는 자기 role을 seller로 올릴 수 없다', async () => {
  const userDb = testEnv.authenticatedContext('user_uid').firestore();
  await assertFails(updateDoc(doc(userDb, 'users/user_uid'), { role: 'seller' }));
});

test('판매자는 products 문서를 생성할 수 있다', async () => {
  const sellerDb = testEnv.authenticatedContext('seller_uid').firestore();
  await assertSucceeds(
    setDoc(doc(sellerDb, 'products/p_test_1'), {
      sellerId: 'seller_uid',
      title: '테스트 상품',
      subTitle: 'rules test',
      price: 10000,
      category: '컵',
      stock: 3,
      isNew: true,
      isSale: false,
      options: [],
    }),
  );
});

test('일반 사용자는 products 문서를 생성할 수 없다', async () => {
  const userDb = testEnv.authenticatedContext('user_uid').firestore();
  await assertFails(
    setDoc(doc(userDb, 'products/p_test_2'), {
      sellerId: 'user_uid',
      title: '차단 상품',
      subTitle: 'rules test',
      price: 10000,
      category: '컵',
      stock: 3,
      isNew: true,
      isSale: false,
      options: [],
    }),
  );
});

test('구매자는 본인 주문을 취소요청으로 업데이트할 수 있다', async () => {
  const userDb = testEnv.authenticatedContext('user_uid').firestore();
  await assertSucceeds(
    updateDoc(doc(userDb, 'orders/order_1'), {
      status: '취소요청',
      cancelReason: '단순 변심',
    }),
  );
});

test('구매자는 본인 주문을 취소완료로 직접 업데이트할 수 없다', async () => {
  const userDb = testEnv.authenticatedContext('user_uid').firestore();
  await assertFails(
    updateDoc(doc(userDb, 'orders/order_1'), {
      status: '취소완료',
    }),
  );
});

test('판매자는 orders 컬렉션을 읽고 상태를 갱신할 수 있다', async () => {
  const sellerDb = testEnv.authenticatedContext('seller_uid').firestore();
  await assertSucceeds(getDoc(doc(sellerDb, 'orders/order_1')));
  await assertSucceeds(
    updateDoc(doc(sellerDb, 'orders/order_1'), {
      status: '취소완료',
      canceledAt: '2026-04-03T10:10:00.000Z',
    }),
  );
});

test('비로그인 사용자는 users 문서를 읽을 수 없다', async () => {
  const anonDb = testEnv.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(anonDb, 'users/user_uid')));
});

test('관리자는 다른 사용자 role을 변경할 수 있다', async () => {
  const adminDb = testEnv.authenticatedContext('admin_uid').firestore();
  await assertSucceeds(updateDoc(doc(adminDb, 'users/user_uid'), { role: 'seller' }));
  const userDb = testEnv.authenticatedContext('user_uid').firestore();
  await assertFails(updateDoc(doc(userDb, 'users/user_uid'), { role: 'admin' }));
  assert.ok(true);
});


test('사용자는 자신의 주소 서브컬렉션을 쓸 수 있다', async () => {
  const userDb = testEnv.authenticatedContext('user_uid').firestore();
  await assertSucceeds(
    setDoc(doc(userDb, 'users/user_uid/addresses/addr_1'), {
      id: 'addr_1',
      label: '집',
      recipient: '구매자',
      addressLine: '서울시 강남구',
      phone: '010-0000-0000',
      requestNote: '',
    }),
  );
});

test('다른 사용자는 타인의 주소 서브컬렉션을 쓸 수 없다', async () => {
  const sellerDb = testEnv.authenticatedContext('seller_uid').firestore();
  await assertFails(
    setDoc(doc(sellerDb, 'users/user_uid/addresses/addr_2'), {
      id: 'addr_2',
      label: '회사',
      recipient: '구매자',
      addressLine: '서울시 서초구',
      phone: '010-0000-0000',
      requestNote: '',
    }),
  );
});
