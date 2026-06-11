#!/usr/bin/env node

const admin = require('firebase-admin');
const {
  accessCodeDocId,
  initAdmin,
  normalizeAccessCode,
} = require('./_access_admin_utils');

const DEMO_CODE = 'DEMO-AMBASSADOR-2026';

async function main() {
  const db = initAdmin();
  const normalizedCode = normalizeAccessCode(DEMO_CODE);
  const codeId = accessCodeDocId(normalizedCode);
  const now = admin.firestore.FieldValue.serverTimestamp();

  console.log('Seed DEMO uniquement. Ne pas utiliser ces valeurs en production.');
  console.log(`Code de démonstration à saisir: ${DEMO_CODE}`);
  console.log(`Document hashé: access_codes/${codeId}`);

  const batch = db.batch();

  batch.set(
    db.collection('content_access_rules').doc('global'),
    {
      active: true,
      accessMode: 'free',
      contentType: 'global',
      updatedAt: now,
      demo: true,
    },
    { merge: true },
  );

  batch.set(
    db.collection('content_access_rules').doc('film_demo-code-required'),
    {
      active: true,
      accessMode: 'codeRequired',
      contentType: 'film',
      filmId: 'demo-code-required',
      updatedAt: now,
      demo: true,
    },
    { merge: true },
  );

  batch.set(
    db.collection('content_access_rules').doc('series_demo-premium'),
    {
      active: true,
      accessMode: 'premium',
      contentType: 'series',
      seriesId: 'demo-premium',
      updatedAt: now,
      demo: true,
    },
    { merge: true },
  );

  batch.set(
    db.collection('access_codes').doc(codeId),
    {
      label: 'DEMO ambassador access code',
      ambassadorName: 'DEMO ONLY',
      active: true,
      grantType: 'ambassadorCode',
      contentType: 'film',
      filmId: 'demo-code-required',
      maxUses: 25,
      usedCount: 0,
      durationDays: 7,
      createdAt: now,
      updatedAt: now,
      demo: true,
    },
    { merge: true },
  );

  await batch.commit();
  console.log('OK: documents de démonstration créés.');
}

main().catch((error) => {
  console.error(`Erreur: ${error.message}`);
  process.exitCode = 1;
});
