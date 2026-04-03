#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';
import admin from 'firebase-admin';

const DEFAULT_INPUT = path.resolve('scripts', 'seed_products.sample.json');
const COLLECTION = 'products';

async function main() {
  const args = process.argv.slice(2);
  const inputArgIndex = args.findIndex((a) => a === '--input');
  const wipe = args.includes('--wipe');
  const inputPath =
    inputArgIndex >= 0 && args[inputArgIndex + 1]
      ? path.resolve(args[inputArgIndex + 1])
      : DEFAULT_INPUT;

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
  }

  const db = admin.firestore();
  const raw = await fs.readFile(inputPath, 'utf8');
  const items = JSON.parse(raw);

  if (!Array.isArray(items) || items.length === 0) {
    throw new Error('Seed JSON must be a non-empty array');
  }

  if (wipe) {
    const snapshot = await db.collection(COLLECTION).get();
    const batch = db.batch();
    snapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    console.log(`[seed] deleted ${snapshot.size} existing docs`);
  }

  for (const item of items) {
    const id = item.id || `p_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    const payload = {
      title: item.title ?? 'Untitled',
      subTitle: item.subTitle ?? '',
      price: Number(item.price ?? 0),
      salePrice: item.salePrice == null ? null : Number(item.salePrice),
      image: item.image ?? null,
      category: item.category ?? '기타',
      stock: Number(item.stock ?? 0),
      isNew: Boolean(item.isNew ?? false),
      isSale: Boolean(item.isSale ?? false),
      options: Array.isArray(item.options) ? item.options : [],
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection(COLLECTION).doc(id).set(payload, { merge: true });
    console.log(`[seed] upserted ${id}`);
  }

  console.log(`[seed] completed with ${items.length} items`);
}

main().catch((error) => {
  console.error('[seed] failed:', error.message);
  process.exitCode = 1;
});
