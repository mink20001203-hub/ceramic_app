import admin from 'firebase-admin';

const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT || 'ceramic-app-aadcb';
const DEMO_PASSWORD = process.env.DEMO_PASSWORD;

const TARGETS = [
  { email: 'admin@ceramic.com', role: 'admin', userName: '관리자' },
  { email: 'seller@ceramic.com', role: 'seller', userName: '판매자1' },
  { email: 'seller2@ceramic.com', role: 'seller', userName: '판매자2' },
  { email: 'user@ceramic.com', role: 'user', userName: '일반사용자' },
];

async function upsertAuthUser(auth, target) {
  try {
    const existing = await auth.getUserByEmail(target.email);
    await auth.updateUser(existing.uid, {
      password: DEMO_PASSWORD,
      displayName: target.userName,
      disabled: false,
    });
    return { uid: existing.uid, created: false };
  } catch (error) {
    if (error?.code !== 'auth/user-not-found') throw error;
    const created = await auth.createUser({
      email: target.email,
      password: DEMO_PASSWORD,
      displayName: target.userName,
      emailVerified: true,
      disabled: false,
    });
    return { uid: created.uid, created: true };
  }
}

async function main() {
  if (!DEMO_PASSWORD || DEMO_PASSWORD.length < 8) {
    throw new Error('Set DEMO_PASSWORD env var (8+ chars) before running this script.');
  }

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: PROJECT_ID,
    });
  }

  const auth = admin.auth();
  const db = admin.firestore();

  for (const target of TARGETS) {
    const result = await upsertAuthUser(auth, target);

    await db.collection('users').doc(result.uid).set(
      {
        userName: target.userName,
        email: target.email,
        role: target.role,
        mileage: 0,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    console.log(
      `[setup:accounts] ${result.created ? 'created' : 'updated'} ${target.email} uid=${result.uid} role=${target.role}`,
    );
  }

  console.log('[setup:accounts] completed');
}

main().catch((error) => {
  console.error('[setup:accounts] failed:', error.message);
  process.exitCode = 1;
});
