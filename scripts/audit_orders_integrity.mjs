import admin from 'firebase-admin';

const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT || 'ceramic-app-aadcb';
const STATUS = {
  paid: '\uACB0\uC81C\uC644\uB8CC',
  preparing: '\uBC30\uC1A1\uC900\uBE44',
  shipping: '\uBC30\uC1A1\uC911',
  delivered: '\uBC30\uC1A1\uC644\uB8CC',
  cancelRequested: '\uCDE8\uC18C\uC694\uCCAD',
  canceled: '\uCDE8\uC18C\uC644\uB8CC',
};
const VALID = new Set(Object.values(STATUS));

function isValidDateString(value) {
  if (typeof value !== 'string' || value.trim() === '') return false;
  return !Number.isNaN(Date.parse(value));
}

function checkOrder(orderId, data) {
  const issues = [];
  const warnings = [];

  if (typeof data.buyerId !== 'string' || data.buyerId.trim() === '') {
    issues.push('buyerId missing');
  }
  if (typeof data.sellerId !== 'string' || data.sellerId.trim() === '') {
    issues.push('sellerId missing');
  }
  if (!VALID.has(data.status)) {
    issues.push(`invalid status: ${String(data.status)}`);
  }
  if (!Array.isArray(data.items) || data.items.length === 0) {
    issues.push('items missing');
  }
  if (typeof data.totalAmount !== 'number' || data.totalAmount < 0) {
    issues.push(`invalid totalAmount: ${String(data.totalAmount)}`);
  }
  if (!Array.isArray(data.statusLogs) || data.statusLogs.length === 0) {
    issues.push('statusLogs missing');
  } else {
    const last = data.statusLogs[data.statusLogs.length - 1];
    if (last?.status !== data.status) {
      warnings.push('latest statusLog does not match current status');
    }
  }

  if (data.status === STATUS.shipping && (!data.trackingNumber || String(data.trackingNumber).trim() === '')) {
    warnings.push('shipping status without trackingNumber');
  }
  if (data.status === STATUS.canceled && (!data.cancelReason || String(data.cancelReason).trim() === '')) {
    warnings.push('canceled status without cancelReason');
  }
  if (data.shippedAt && !isValidDateString(data.shippedAt)) {
    issues.push('invalid shippedAt');
  }
  if (data.canceledAt && !isValidDateString(data.canceledAt)) {
    issues.push('invalid canceledAt');
  }

  return { orderId, issues, warnings };
}

async function main() {
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: PROJECT_ID,
    });
  }

  const db = admin.firestore();
  const snapshot = await db.collection('orders').get();

  const issues = [];
  const warnings = [];

  for (const doc of snapshot.docs) {
    const result = checkOrder(doc.id, doc.data());
    if (result.issues.length > 0) {
      issues.push(result);
    } else if (result.warnings.length > 0) {
      warnings.push(result);
    }
  }

  console.log(`[audit:orders] total=${snapshot.size} issueOrders=${issues.length} warningOrders=${warnings.length}`);

  for (const item of issues) {
    console.log(`[issue] ${item.orderId} :: ${item.issues.join(' | ')}`);
  }
  for (const item of warnings) {
    console.log(`[warning] ${item.orderId} :: ${item.warnings.join(' | ')}`);
  }

  if (issues.length > 0) {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error('[audit:orders] failed:', error.message);
  process.exitCode = 1;
});
