import admin from 'firebase-admin';

const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT || 'ceramic-app-aadcb';
const COLLECTION = 'orders';
const TARGET_SELLERS = ['seller_uid', 'seller_uid_2'];
const BUYER_ID = 'user_uid';

function buildOrderPayload(product, sellerId) {
  const now = new Date();
  const unitPrice = Number(product.salePrice ?? product.price ?? 0);
  const quantity = 1;
  const totalAmount = unitPrice * quantity;
  const orderId = `e2e_order_${sellerId}`;

  return {
    id: orderId,
    buyerId: BUYER_ID,
    sellerId,
    items: [
      {
        product: {
          id: product.id,
          title: product.title ?? '상품',
          subTitle: product.subTitle ?? '',
          price: Number(product.price ?? 0),
          image: product.image ?? null,
          category: product.category ?? '기타',
          salePrice: product.salePrice ?? null,
          sellerId,
        },
        option: (Array.isArray(product.options) && product.options.length > 0)
          ? String(product.options[0])
          : '기본',
        quantity,
        unitPrice,
      },
    ],
    totalAmount,
    discountAmount: 0,
    mileageUsed: 0,
    couponTitle: null,
    addressSummary: '서울시 강남구 테헤란로 123 / 010-1111-2222 / 문 앞에 놓아주세요',
    paymentMethodLabel: '신용카드',
    paymentStatus: '승인완료',
    agreementAccepted: true,
    date: now.toISOString(),
    status: '결제완료',
    trackingNumber: null,
    shippingMemo: null,
    shippedAt: null,
    cancelReason: null,
    canceledAt: null,
    statusLogs: [
      {
        status: '결제완료',
        date: now.toISOString(),
        actor: '구매자',
      },
    ],
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

async function getProductsBySeller(db) {
  const snapshot = await db.collection('products').get();
  const bySeller = new Map();

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const sellerId = typeof data.sellerId === 'string' ? data.sellerId.trim() : '';
    if (!sellerId) continue;
    if (!bySeller.has(sellerId)) bySeller.set(sellerId, []);
    bySeller.get(sellerId).push({ id: doc.id, ...data });
  }

  return bySeller;
}

async function wipeE2EOrders(db) {
  const snapshot = await db.collection(COLLECTION).get();
  const batch = db.batch();
  let deleted = 0;

  for (const doc of snapshot.docs) {
    if (!doc.id.startsWith('e2e_order_')) continue;
    batch.delete(doc.ref);
    deleted += 1;
  }

  if (deleted > 0) {
    await batch.commit();
  }
  console.log(`[seed:orders] deleted ${deleted} e2e docs`);
}

async function main() {
  const wipe = process.argv.includes('--wipe');

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: PROJECT_ID,
    });
  }

  const db = admin.firestore();

  if (wipe) {
    await wipeE2EOrders(db);
  }

  const bySeller = await getProductsBySeller(db);

  for (const sellerId of TARGET_SELLERS) {
    const products = bySeller.get(sellerId) ?? [];
    if (products.length === 0) {
      console.log(`[seed:orders] skip ${sellerId}: no products`);
      continue;
    }

    const product = products[0];
    const payload = buildOrderPayload(product, sellerId);
    await db.collection(COLLECTION).doc(payload.id).set(payload, { merge: true });
    console.log(`[seed:orders] upserted ${payload.id} (product=${product.id})`);
  }

  console.log('[seed:orders] completed');
}

main().catch((error) => {
  console.error('[seed:orders] failed:', error.message);
  process.exitCode = 1;
});
