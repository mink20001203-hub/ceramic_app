#!/usr/bin/env node
import admin from 'firebase-admin';

const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT || 'ceramic-app-aadcb';

async function buildProductSellerMap(db) {
  const snapshot = await db.collection('products').get();
  const map = new Map();
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const sellerId = typeof data.sellerId === 'string' ? data.sellerId.trim() : '';
    if (sellerId) map.set(doc.id, sellerId);
  }
  return map;
}

function resolveSellerId(orderData, productSellerMap) {
  const items = Array.isArray(orderData.items) ? orderData.items : [];
  for (const item of items) {
    const product = item?.product ?? {};
    const embeddedSellerId = typeof product.sellerId === 'string' ? product.sellerId.trim() : '';
    if (embeddedSellerId.length > 0) return embeddedSellerId;

    const productId = typeof product.id === 'string' ? product.id : '';
    if (productId && productSellerMap.has(productId)) {
      return productSellerMap.get(productId);
    }
  }
  return orderData.sellerId || 'seller_demo';
}

async function main() {
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: PROJECT_ID,
    });
  }

  const db = admin.firestore();
  const productSellerMap = await buildProductSellerMap(db);
  const snapshot = await db.collection('orders').get();

  let updated = 0;
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const nextSellerId = resolveSellerId(data, productSellerMap);
    if ((data.sellerId || '') === nextSellerId) continue;

    await doc.ref.set(
      {
        sellerId: nextSellerId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    updated += 1;
    console.log(`[migrate] ${doc.id} -> ${nextSellerId}`);
  }

  console.log(`[migrate] scanned=${snapshot.size}, updated=${updated}`);
}

main().catch((error) => {
  console.error('[migrate] failed:', error.message);
  process.exitCode = 1;
});
