const crypto = require('crypto');
const admin = require('firebase-admin');

const VALID_CONTENT_TYPES = new Set(['global', 'film', 'series', 'episode']);
const VALID_GRANT_TYPES = new Set([
  'ambassadorCode',
  'pass',
  'purchase',
  'global',
  'free',
]);
const VALID_ACCESS_MODES = new Set([
  'free',
  'codeRequired',
  'premium',
  'purchaseRequired',
]);

function parseArgs(argv) {
  const args = {};
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    if (!token.startsWith('--')) continue;
    const key = token.slice(2);
    const next = argv[index + 1];
    if (!next || next.startsWith('--')) {
      args[key] = true;
      continue;
    }
    args[key] = next;
    index += 1;
  }
  return args;
}

function normalizeAccessCode(code) {
  return String(code || '').trim().toUpperCase().replace(/\s+/g, '');
}

function accessCodeDocId(code) {
  return crypto.createHash('sha256').update(normalizeAccessCode(code)).digest('hex');
}

function boolArg(value, defaultValue = false) {
  if (value === undefined) return defaultValue;
  if (typeof value === 'boolean') return value;
  return ['1', 'true', 'yes', 'y', 'on'].includes(String(value).toLowerCase());
}

function intArg(value, fieldName) {
  if (value === undefined || value === null || value === '') return undefined;
  const parsed = Number.parseInt(String(value), 10);
  if (!Number.isFinite(parsed)) {
    throw new Error(`${fieldName} doit être un entier.`);
  }
  return parsed;
}

function timestampArg(value, fieldName) {
  if (!value) return undefined;
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    throw new Error(`${fieldName} doit être une date ISO valide.`);
  }
  return admin.firestore.Timestamp.fromDate(date);
}

function requireValue(args, key, message) {
  const value = args[key];
  if (value === undefined || value === null || String(value).trim().length === 0) {
    throw new Error(message || `Argument requis: --${key}`);
  }
  return String(value).trim();
}

function validateContentScope(args) {
  const contentType = String(args.contentType || 'global');
  if (!VALID_CONTENT_TYPES.has(contentType)) {
    throw new Error(`contentType invalide: ${contentType}`);
  }

  if (contentType === 'film') {
    requireValue(args, 'filmId', '--filmId est requis pour contentType=film.');
  }
  if (contentType === 'series') {
    requireValue(args, 'seriesId', '--seriesId est requis pour contentType=series.');
  }
  if (contentType === 'episode') {
    requireValue(args, 'seriesId', '--seriesId est requis pour contentType=episode.');
    requireValue(args, 'seasonId', '--seasonId est requis pour contentType=episode.');
    requireValue(args, 'episodeId', '--episodeId est requis pour contentType=episode.');
  }

  return {
    contentType,
    ...(args.filmId ? { filmId: String(args.filmId) } : {}),
    ...(args.seriesId ? { seriesId: String(args.seriesId) } : {}),
    ...(args.seasonId ? { seasonId: String(args.seasonId) } : {}),
    ...(args.episodeId ? { episodeId: String(args.episodeId) } : {}),
  };
}

function validateGrantType(value) {
  const grantType = String(value || 'ambassadorCode');
  if (!VALID_GRANT_TYPES.has(grantType)) {
    throw new Error(`grantType invalide: ${grantType}`);
  }
  return grantType;
}

function validateAccessMode(value) {
  const accessMode = String(value || 'codeRequired');
  if (!VALID_ACCESS_MODES.has(accessMode)) {
    throw new Error(`accessMode invalide: ${accessMode}`);
  }
  return accessMode;
}

function ruleIdForScope(scope) {
  switch (scope.contentType) {
    case 'global':
      return 'global';
    case 'film':
      return `film_${scope.filmId}`;
    case 'series':
      return `series_${scope.seriesId}`;
    case 'episode':
      return `episode_${scope.seriesId}_${scope.seasonId}_${scope.episodeId}`;
    default:
      throw new Error(`contentType invalide: ${scope.contentType}`);
  }
}

function initAdmin(projectId) {
  if (admin.apps.length === 0) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      ...(projectId ? { projectId } : {}),
    });
  }
  const activeProjectId = admin.app().options.projectId;
  if (projectId && activeProjectId && activeProjectId !== projectId) {
    throw new Error(
      `Projet Firebase inattendu: ${activeProjectId}. Projet requis: ${projectId}.`,
    );
  }
  return admin.firestore();
}

module.exports = {
  accessCodeDocId,
  boolArg,
  initAdmin,
  intArg,
  normalizeAccessCode,
  parseArgs,
  requireValue,
  ruleIdForScope,
  timestampArg,
  validateAccessMode,
  validateContentScope,
  validateGrantType,
};
