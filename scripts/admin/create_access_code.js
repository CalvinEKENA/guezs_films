#!/usr/bin/env node

const admin = require('firebase-admin');
const {
  accessCodeDocId,
  boolArg,
  initAdmin,
  intArg,
  normalizeAccessCode,
  parseArgs,
  requireValue,
  timestampArg,
  validateContentScope,
  validateGrantType,
} = require('./_access_admin_utils');

function usage() {
  console.log(`
Usage:
  node create_access_code.js --code RAW_CODE --ambassadorName "Nom" [options]

Options:
  --grantType ambassadorCode|pass|purchase|global|free
  --contentType global|film|series|episode
  --filmId FILM_ID
  --seriesId SERIES_ID
  --seasonId SEASON_ID
  --episodeId EPISODE_ID
  --maxUses 500
  --durationDays 30
  --active true|false
  --startsAt 2026-06-01T00:00:00Z
  --expiresAt 2026-07-01T00:00:00Z
  --dryRun

Le code brut n'est jamais stocké dans Firestore. L'ID document est sha256(code normalisé).
`);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help || args.h) {
    usage();
    return;
  }

  const rawCode = requireValue(args, 'code', '--code est requis.');
  const normalizedCode = normalizeAccessCode(rawCode);
  if (!normalizedCode) throw new Error('Le code normalisé est vide.');

  const docId = accessCodeDocId(normalizedCode);
  const scope = validateContentScope(args);
  const grantType = validateGrantType(args.grantType);
  const active = boolArg(args.active, true);
  const maxUses = intArg(args.maxUses, 'maxUses');
  const durationDays = intArg(args.durationDays, 'durationDays');
  const startsAt = timestampArg(args.startsAt, 'startsAt');
  const expiresAt = timestampArg(args.expiresAt, 'expiresAt');

  const payload = {
    label: args.label || args.ambassadorName || `Access code ${docId.slice(0, 8)}`,
    ambassadorName: args.ambassadorName || null,
    active,
    grantType,
    ...scope,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    usedCount: admin.firestore.FieldValue.increment(0),
    ...(maxUses !== undefined ? { maxUses } : {}),
    ...(durationDays !== undefined ? { durationDays } : {}),
    ...(startsAt ? { startsAt } : {}),
    ...(expiresAt ? { expiresAt } : {}),
  };

  console.log(`Code normalisé: ${normalizedCode}`);
  console.log(`Document: access_codes/${docId}`);
  console.log('Le code brut ne sera pas stocké.');

  if (args.dryRun) {
    console.log(JSON.stringify({ [docId]: payload }, null, 2));
    return;
  }

  const db = initAdmin();
  await db.collection('access_codes').doc(docId).set(payload, { merge: true });
  console.log(`OK: access_codes/${docId} créé ou mis à jour.`);
}

main().catch((error) => {
  console.error(`Erreur: ${error.message}`);
  process.exitCode = 1;
});
