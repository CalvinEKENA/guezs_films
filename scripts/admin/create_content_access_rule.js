#!/usr/bin/env node

const admin = require('firebase-admin');
const {
  boolArg,
  initAdmin,
  parseArgs,
  ruleIdForScope,
  timestampArg,
  validateAccessMode,
  validateContentScope,
} = require('./_access_admin_utils');

function usage() {
  console.log(`
Usage:
  node create_content_access_rule.js --contentType film --filmId FILM_ID --accessMode codeRequired

Options:
  --contentType global|film|series|episode
  --accessMode free|codeRequired|premium|purchaseRequired
  --filmId FILM_ID
  --seriesId SERIES_ID
  --seasonId SEASON_ID
  --episodeId EPISODE_ID
  --active true|false
  --startsAt 2026-06-01T00:00:00Z
  --expiresAt 2026-07-01T00:00:00Z
  --dryRun
`);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help || args.h) {
    usage();
    return;
  }

  const scope = validateContentScope(args);
  const accessMode = validateAccessMode(args.accessMode);
  const active = boolArg(args.active, true);
  const startsAt = timestampArg(args.startsAt, 'startsAt');
  const expiresAt = timestampArg(args.expiresAt, 'expiresAt');
  const ruleId = args.ruleId || ruleIdForScope(scope);

  const payload = {
    active,
    accessMode,
    ...scope,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    ...(startsAt ? { startsAt } : {}),
    ...(expiresAt ? { expiresAt } : {}),
  };

  console.log(`Document: content_access_rules/${ruleId}`);

  if (args.dryRun) {
    console.log(JSON.stringify({ [ruleId]: payload }, null, 2));
    return;
  }

  const db = initAdmin();
  await db.collection('content_access_rules').doc(ruleId).set(payload, { merge: true });
  console.log(`OK: content_access_rules/${ruleId} créé ou mis à jour.`);
}

main().catch((error) => {
  console.error(`Erreur: ${error.message}`);
  process.exitCode = 1;
});
