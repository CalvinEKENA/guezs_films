#!/usr/bin/env node

const admin = require('firebase-admin');
const { initAdmin } = require('./_access_admin_utils');

const TARGET_PROJECT_ID = 'guezs-films';

async function main() {
  console.warn(
    'MVP only: cette règle rend tous les contenus accessibles aux utilisateurs connectés.',
  );
  console.warn(`Projet Firebase cible: ${TARGET_PROJECT_ID}`);

  const db = initAdmin(TARGET_PROJECT_ID);
  await db.collection('content_access_rules').doc('global').set(
    {
      accessMode: 'free',
      active: true,
      contentType: 'global',
      demo: false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  console.log('OK: content_access_rules/global configuré en mode free MVP.');
}

main().catch((error) => {
  console.error(`Erreur: ${error.message}`);
  process.exitCode = 1;
});
