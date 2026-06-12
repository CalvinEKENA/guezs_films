const VIDEO_URL_FIELDS = [
  'videoUrl',
  'videoURL',
  'video_url',
  'playbackUrl',
  'streamUrl',
  'sourceUrl',
  'url',
];

const ALTERNATE_VIDEO_URL_FIELDS = VIDEO_URL_FIELDS.filter(
  (field) => field !== 'videoUrl',
);

function validString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function inspectVideoUrlFields(data) {
  const declaredFields = VIDEO_URL_FIELDS.filter((field) =>
    Object.prototype.hasOwnProperty.call(data, field),
  );
  const populatedFields = VIDEO_URL_FIELDS.filter((field) =>
    validString(data[field]),
  );
  const selectedField = populatedFields[0] || null;
  const selectedUrl = selectedField ? data[selectedField].trim() : '';

  return {
    declaredFields,
    populatedFields,
    selectedField,
    selectedUrl,
    canonicalConfigured: validString(data.videoUrl),
    alternateField:
      ALTERNATE_VIDEO_URL_FIELDS.find((field) => validString(data[field])) ||
      null,
  };
}

function recordForDocument(kind, doc) {
  const data = doc.data() || {};
  const inspection = inspectVideoUrlFields(data);
  return {
    kind,
    path: doc.ref.path,
    title: String(data.title || data.name || '').trim() || '(sans titre)',
    status: inspection.canonicalConfigured
      ? 'canonical'
      : inspection.alternateField
        ? 'alternate'
        : 'missing',
    field: inspection.selectedField || '(aucun)',
    declaredFields: inspection.declaredFields.join(', ') || '(aucun)',
    ref: doc.ref,
    data,
    inspection,
  };
}

async function scanVideoDocuments(db) {
  const [filmsSnapshot, episodesSnapshot] = await Promise.all([
    db.collection('films').get(),
    db.collectionGroup('episodes').get(),
  ]);

  return [
    ...filmsSnapshot.docs.map((doc) => recordForDocument('film', doc)),
    ...episodesSnapshot.docs.map((doc) => recordForDocument('episode', doc)),
  ];
}

function publicRecord(record) {
  return {
    type: record.kind,
    path: record.path,
    title: record.title,
    status: record.status,
    field: record.field,
    declaredFields: record.declaredFields,
  };
}

function printAuditReport(records, label = 'Audit des sources video') {
  const films = records.filter((record) => record.kind === 'film');
  const episodes = records.filter((record) => record.kind === 'episode');
  const canonical = records.filter((record) => record.status === 'canonical');
  const alternate = records.filter((record) => record.status === 'alternate');
  const missing = records.filter((record) => record.status === 'missing');

  console.log(`\n${label}`);
  console.log('='.repeat(label.length));
  console.log(`Films scannes: ${films.length}`);
  console.log(`Episodes scannes: ${episodes.length}`);
  console.log(`videoUrl configure: ${canonical.length}`);
  console.log(`Champ alternatif detecte: ${alternate.length}`);
  console.log(`Source absente: ${missing.length}`);

  if (records.length > 0) {
    console.log('\nChamp effectivement utilise par contenu:');
    console.table(records.map(publicRecord));
  }

  if (missing.length > 0) {
    console.log('\nContenus sans URL video exploitable:');
    console.table(missing.map(publicRecord));
  }

  if (alternate.length > 0) {
    console.log('\nContenus normalisables depuis un champ alternatif:');
    console.table(alternate.map(publicRecord));
  }

  return { films, episodes, canonical, alternate, missing };
}

module.exports = {
  ALTERNATE_VIDEO_URL_FIELDS,
  VIDEO_URL_FIELDS,
  inspectVideoUrlFields,
  printAuditReport,
  publicRecord,
  scanVideoDocuments,
};
