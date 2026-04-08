import admin from 'firebase-admin';

const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT || 'ceramic-app-aadcb';

async function main() {
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: PROJECT_ID,
    });
  }

  const db = admin.firestore();
  const [productsSnap, ordersSnap, usersSnap] = await Promise.all([
    db.collection('products').get(),
    db.collection('orders').get(),
    db.collection('users').get(),
  ]);

  const validSellerIds = new Set(['seller_demo']);
  for (const doc of usersSnap.docs) {
    const data = doc.data();
    const role = String(data.role || '');
    if (role !== 'seller' && role !== 'admin') continue;

    validSellerIds.add(doc.id);

    const email = String(data.email || '').toLowerCase();
    if (email === 'seller@ceramic.com') validSellerIds.add('seller_uid');
    if (email === 'seller2@ceramic.com') validSellerIds.add('seller_uid_2');
  }

  const productsBySeller = {};
  const unknownProductSellers = [];
  for (const doc of productsSnap.docs) {
    const sellerId = String(doc.data().sellerId || '').trim();
    if (!sellerId) {
      unknownProductSellers.push(doc.id);
      continue;
    }
    productsBySeller[sellerId] = (productsBySeller[sellerId] || 0) + 1;
    if (!validSellerIds.has(sellerId)) {
      unknownProductSellers.push(doc.id);
    }
  }

  const ordersBySeller = {};
  const unknownOrderSellers = [];
  for (const doc of ordersSnap.docs) {
    const sellerId = String(doc.data().sellerId || '').trim();
    if (!sellerId) {
      unknownOrderSellers.push(doc.id);
      continue;
    }
    ordersBySeller[sellerId] = (ordersBySeller[sellerId] || 0) + 1;
    if (!validSellerIds.has(sellerId)) {
      unknownOrderSellers.push(doc.id);
    }
  }

  console.log('[audit:sellers] summary');
  console.log(
    JSON.stringify(
      {
        productsTotal: productsSnap.size,
        ordersTotal: ordersSnap.size,
        validSellerIds: Array.from(validSellerIds),
        productsBySeller,
        ordersBySeller,
        unknownProductSellerDocs: unknownProductSellers,
        unknownOrderSellerDocs: unknownOrderSellers,
      },
      null,
      2,
    ),
  );

  if (unknownProductSellers.length > 0 || unknownOrderSellers.length > 0) {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error('[audit:sellers] failed:', error.message);
  process.exitCode = 1;
});
