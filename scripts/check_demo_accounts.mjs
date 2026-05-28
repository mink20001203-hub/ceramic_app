import admin from 'firebase-admin';

const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT || 'ceramic-app-aadcb';

const REQUIRED = [
  { key: 'admin', email: 'admin@ceramic.com', role: 'admin' },
  { key: 'seller', email: 'seller@ceramic.com', role: 'seller' },
  { key: 'seller2', email: 'seller2@ceramic.com', role: 'seller' },
  { key: 'user', email: 'user@ceramic.com', role: 'user' },
];

function statusLine(ok) {
  return ok ? 'PASS' : 'FAIL';
}

async function findUserDocByEmail(db, email) {
  const snapshot = await db.collection('users').where('email', '==', email).limit(1).get();
  if (snapshot.empty) return null;
  const doc = snapshot.docs[0];
  return { id: doc.id, data: doc.data() ?? {} };
}

async function main() {
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: PROJECT_ID,
    });
  }

  const db = admin.firestore();
  let allPass = true;

  for (const target of REQUIRED) {
    const found = await findUserDocByEmail(db, target.email);

    if (!found) {
      allPass = false;
      console.log(`[accounts] ${target.key}: ${statusLine(false)} email=${target.email} doc missing`);
      continue;
    }

    const role = String(found.data.role ?? '');
    const rolePass = role === target.role;
    if (!rolePass) allPass = false;

    console.log(
      `[accounts] ${target.key}: ${statusLine(rolePass)} uid=${found.id} email=${target.email} role=${role || '-'} expectedRole=${target.role}`,
    );
  }

  if (!allPass) {
    process.exitCode = 1;
    console.log('[accounts] result: FAIL');
    return;
  }

  console.log('[accounts] result: PASS');
}

main().catch((error) => {
  console.error('[accounts] failed:', error.message);
  process.exitCode = 1;
});
