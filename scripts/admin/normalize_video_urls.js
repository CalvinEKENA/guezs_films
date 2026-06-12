#!/usr/bin/env node

const { initAdmin, parseArgs } = require('./_access_admin_utils');
const {
  inspectVideoUrlFields,
  printAuditReport,
  publicRecord,
  scanVideoDocuments,
} = require('./_video_url_admin_utils');

const TARGET_PROJECT_ID = 'guezs-films';
const CONFIRMATION_FLAG = 'confirm-normalize-video-urls';
const MAX_BATCH_SIZE = 400;

function usage() {
  console.log(`
Usage:
  node normalize_video_urls.js
  node normalize_video_urls.js --project guezs-films
  node normalize_video_urls.js --project guezs-films --confirm-normalize-video-urls

Sans --${CONFIRMATION_FLAG}, le script affiche uniquement le rapport avant
normalisation. Avec confirmation, il copie le premier champ alternatif valide
vers videoUrl sans supprimer ni modifier le champ historique.
`);
}

async function commitUpdates(db, records) {
  let updated = 0;
  let skipped = 0;

  for (let offset = 0; offset < records.length; offset += MAX_BATCH_SIZE) {
    const chunk = records.slice(offset, offset + MAX_BATCH_SIZE);
    const freshSnapshots = await Promise.all(
      chunk.map((record) => record.ref.get()),
    );
    const batch = db.batch();
    let writesInBatch = 0;

    for (const snapshot of freshSnapshots) {
      const inspection = inspectVideoUrlFields(snapshot.data() || {});
      if (inspection.canonicalConfigured || !inspection.alternateField) {
        skipped += 1;
        continue;
      }

      batch.set(
        snapshot.ref,
        { videoUrl: inspection.selectedUrl },
        { merge: true },
      );
      writesInBatch += 1;
    }

    if (writesInBatch > 0) {
      await batch.commit();
      updated += writesInBatch;
    }
  }

  return { updated, skipped };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help || args.h) {
    usage();
    return;
  }

  const projectId = String(args.project || TARGET_PROJECT_ID).trim();
  const confirmed = args[CONFIRMATION_FLAG] === true;
  console.log(`Projet Firebase cible: ${projectId}`);

  const db = initAdmin(projectId);
  const beforeRecords = await scanVideoDocuments(db);
  const before = printAuditReport(
    beforeRecords,
    'Rapport AVANT normalisation',
  );

  if (before.alternate.length === 0) {
    console.log('\nAucun document ne necessite de normalisation.');
    return;
  }

  if (!confirmed) {
    console.warn('\nAUCUNE MODIFICATION EFFECTUEE.');
    console.warn(
      `Relancez avec --${CONFIRMATION_FLAG} pour copier les champs alternatifs vers videoUrl.`,
    );
    return;
  }

  console.warn(
    `\nCONFIRMATION RECUE: ${before.alternate.length} document(s) peuvent etre modifies.`,
  );
  console.table(before.alternate.map(publicRecord));

  const result = await commitUpdates(db, before.alternate);
  const afterRecords = await scanVideoDocuments(db);
  const after = printAuditReport(
    afterRecords,
    'Rapport APRES normalisation',
  );

  console.log('\nResultat de la normalisation:');
  console.log(`Documents mis a jour: ${result.updated}`);
  console.log(`Documents ignores apres relecture: ${result.skipped}`);
  console.log(
    `Sources alternatives restantes: ${after.alternate.length}`,
  );
  console.log(`Sources toujours absentes: ${after.missing.length}`);
  console.log(
    'Les anciens champs ont ete conserves. Aucun champ source n a ete supprime.',
  );
}

main().catch((error) => {
  console.error(`Erreur: ${error.message}`);
  process.exitCode = 1;
});
