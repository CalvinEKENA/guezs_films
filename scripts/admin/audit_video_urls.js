#!/usr/bin/env node

const { initAdmin, parseArgs } = require('./_access_admin_utils');
const {
  printAuditReport,
  scanVideoDocuments,
} = require('./_video_url_admin_utils');

const TARGET_PROJECT_ID = 'guezs-films';

function usage() {
  console.log(`
Usage:
  node audit_video_urls.js
  node audit_video_urls.js --project guezs-films

Ce script analyse Firestore en lecture seule. Il ne modifie aucun document.
`);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help || args.h) {
    usage();
    return;
  }

  const projectId = String(args.project || TARGET_PROJECT_ID).trim();
  console.log(`Projet Firebase cible: ${projectId}`);
  console.log('Mode: lecture seule');

  const db = initAdmin(projectId);
  const records = await scanVideoDocuments(db);
  const report = printAuditReport(records);

  if (report.missing.length > 0) {
    console.warn(
      `ATTENTION: ${report.missing.length} contenu(s) sans source video exploitable.`,
    );
  }
}

main().catch((error) => {
  console.error(`Erreur: ${error.message}`);
  process.exitCode = 1;
});
