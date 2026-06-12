const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');
admin.initializeApp();

const db = admin.firestore();
const fieldValue = admin.firestore.FieldValue;

/**
 * Génère des tokens à partir du titre et des métadonnées optionnelles.
 * Les variantes accentuées et sans accents restent indexées pour préserver les
 * anciennes recherches et préparer réalisateur, casting, pays, langue et tags.
 */
function generateSearchTokens(data) {
  const tokens = new Set();
  const values = [
    data.title,
    data.director,
    data.country,
    data.language,
    ...(Array.isArray(data.cast) ? data.cast : []),
    ...(Array.isArray(data.tags) ? data.tags : []),
  ];

  for (const value of values) {
    if (!value || typeof value !== 'string') continue;
    const raw = value.toLowerCase().trim().replace(/\s+/g, ' ');
    const folded = raw
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();

    for (const normalized of new Set([raw, folded])) {
      if (normalized.length < 2) continue;
      tokens.add(normalized);

      for (const word of normalized.split(/\s+/)) {
        if (word.length < 2) continue;
        for (let i = 2; i <= word.length; i++) {
          tokens.add(word.substring(0, i));
        }
      }
    }
  }

  return Array.from(tokens).slice(0, 400);
}

function normalizeAccessCode(code) {
  return String(code || '').trim().toUpperCase().replace(/\s+/g, '');
}

function accessCodeDocId(code) {
  return crypto.createHash('sha256').update(normalizeAccessCode(code)).digest('hex');
}

function normalizeWatchRequest(rawRequest) {
  const request = rawRequest || {};
  const contentType = request.contentType;
  if (contentType === 'film') {
    if (!request.filmId) throw new functions.https.HttpsError('invalid-argument', 'filmId requis.');
    return { contentType, filmId: String(request.filmId) };
  }
  if (contentType === 'episode') {
    if (!request.seriesId || !request.seasonId || !request.episodeId) {
      throw new functions.https.HttpsError('invalid-argument', 'seriesId, seasonId et episodeId requis.');
    }
    return {
      contentType,
      seriesId: String(request.seriesId),
      seasonId: String(request.seasonId),
      episodeId: String(request.episodeId),
    };
  }
  throw new functions.https.HttpsError('invalid-argument', 'contentType non supporté.');
}

function contentScopeKey(request) {
  if (request.contentType === 'global') return 'global';
  if (request.contentType === 'film') return `film_${request.filmId}`;
  if (request.contentType === 'series') return `series_${request.seriesId}`;
  return `episode_${request.seriesId}_${request.seasonId}_${request.episodeId}`;
}

function ruleIdsForRequest(request) {
  if (request.contentType === 'film') {
    return ['global', `film_${request.filmId}`];
  }
  return [
    'global',
    `series_${request.seriesId}`,
    `episode_${request.seriesId}_${request.seasonId}_${request.episodeId}`,
  ];
}

function timestampToDate(value) {
  if (!value) return null;
  if (value.toDate) return value.toDate();
  if (value instanceof Date) return value;
  if (typeof value === 'string') return new Date(value);
  return null;
}

function isWithinWindow(data, now = new Date()) {
  if (data.active === false) return false;
  const startsAt = timestampToDate(data.startsAt);
  const expiresAt = timestampToDate(data.expiresAt);
  if (startsAt && now < startsAt) return false;
  if (expiresAt && now >= expiresAt) return false;
  return true;
}

function scopeFromData(data) {
  return {
    contentType: data.contentType || 'global',
    filmId: data.filmId || null,
    seriesId: data.seriesId || null,
    seasonId: data.seasonId || null,
    episodeId: data.episodeId || null,
  };
}

function scopeMatchesRequest(scope, request) {
  if (scope.contentType === 'global') return true;
  if (scope.contentType === 'film') {
    return request.contentType === 'film' && scope.filmId === request.filmId;
  }
  if (scope.contentType === 'series') {
    return request.contentType === 'episode' && scope.seriesId === request.seriesId;
  }
  if (scope.contentType === 'episode') {
    return request.contentType === 'episode' &&
      scope.seriesId === request.seriesId &&
      scope.seasonId === request.seasonId &&
      scope.episodeId === request.episodeId;
  }
  return false;
}

function grantPayload(type, scope, sourceId, expiresAt) {
  return {
    type,
    contentType: scope.contentType || 'global',
    ...(scope.filmId ? { filmId: scope.filmId } : {}),
    ...(scope.seriesId ? { seriesId: scope.seriesId } : {}),
    ...(scope.seasonId ? { seasonId: scope.seasonId } : {}),
    ...(scope.episodeId ? { episodeId: scope.episodeId } : {}),
    ...(sourceId ? { sourceId } : {}),
    ...(expiresAt ? { expiresAt: expiresAt.toISOString() } : {}),
  };
}

function denied(status, message) {
  return { allowed: false, status, message };
}

async function deleteQueryDocuments(query) {
  while (true) {
    const snapshot = await query.limit(400).get();
    if (snapshot.empty) return;

    const batch = db.batch();
    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
  }
}

async function evaluateWatchAccess(uid, request) {
  if (!uid) {
    return denied('guest', 'Connectez-vous pour demander un accès vidéo.');
  }

  const now = new Date();
  const ruleRefs = ruleIdsForRequest(request).map((id) =>
    db.collection('content_access_rules').doc(id)
  );
  const ruleSnapshots = await db.getAll(...ruleRefs);
  const freeRule = ruleSnapshots.find((snapshot) => {
    if (!snapshot.exists) return false;
    const data = snapshot.data() || {};
    return data.accessMode === 'free' && isWithinWindow(data, now);
  });

  if (freeRule) {
    return {
      allowed: true,
      status: 'granted',
      message: 'Accès gratuit accordé.',
      grant: grantPayload('free', { contentType: 'global' }),
    };
  }

  const entitlements = await db.collection('user_entitlements')
    .where('uid', '==', uid)
    .where('active', '==', true)
    .get();

  for (const doc of entitlements.docs) {
    const data = doc.data() || {};
    if (!isWithinWindow(data, now)) continue;
    const scope = scopeFromData(data);
    if (!scopeMatchesRequest(scope, request)) continue;
    return {
      allowed: true,
      status: 'granted',
      message: 'Accès premium accordé.',
      grant: grantPayload(data.grantType || 'global', scope, data.sourceId, timestampToDate(data.expiresAt)),
    };
  }

  return denied('codeRequired', 'Ce contenu nécessite un accès valide.');
}

exports.validateAccessCode = functions.https.onCall(async (data, context) => {
  const uid = context.auth && context.auth.uid;
  if (!uid) return denied('guest', 'Connectez-vous pour valider un code.');

  const request = normalizeWatchRequest(data.request);
  const normalizedCode = normalizeAccessCode(data.code);
  if (!normalizedCode) {
    throw new functions.https.HttpsError('invalid-argument', 'Code requis.');
  }

  const codeRef = db.collection('access_codes').doc(accessCodeDocId(normalizedCode));
  const now = new Date();

  return db.runTransaction(async (transaction) => {
    const codeSnap = await transaction.get(codeRef);
    if (!codeSnap.exists) return denied('denied', 'Code invalide.');

    const code = codeSnap.data() || {};
    if (!isWithinWindow(code, now)) {
      return denied('expired', 'Ce code est expiré ou inactif.');
    }

    const maxUses = code.maxUses;
    const usedCount = code.usedCount || 0;
    if (typeof maxUses === 'number' && usedCount >= maxUses) {
      return denied('expired', 'Ce code a déjà atteint sa limite d’utilisation.');
    }

    const scope = scopeFromData(code);
    if (!scopeMatchesRequest(scope, request)) {
      return denied('denied', 'Ce code ne donne pas accès à ce contenu.');
    }

    const durationDays = typeof code.durationDays === 'number' ? code.durationDays : null;
    const expiresAt = code.entitlementExpiresAt
      ? timestampToDate(code.entitlementExpiresAt)
      : (durationDays ? new Date(now.getTime() + durationDays * 24 * 60 * 60 * 1000) : null);
    const entitlementId = `${uid}_${codeRef.id}_${contentScopeKey(scope)}`;
    const entitlementRef = db.collection('user_entitlements').doc(entitlementId);
    const entitlementSnap = await transaction.get(entitlementRef);

    if (!entitlementSnap.exists || !isWithinWindow(entitlementSnap.data() || {}, now)) {
      transaction.set(entitlementRef, {
        uid,
        active: true,
        grantType: code.grantType || 'ambassadorCode',
        source: 'access_code',
        sourceId: codeRef.id,
        contentType: scope.contentType || 'global',
        ...(scope.filmId ? { filmId: scope.filmId } : {}),
        ...(scope.seriesId ? { seriesId: scope.seriesId } : {}),
        ...(scope.seasonId ? { seasonId: scope.seasonId } : {}),
        ...(scope.episodeId ? { episodeId: scope.episodeId } : {}),
        createdAt: fieldValue.serverTimestamp(),
        updatedAt: fieldValue.serverTimestamp(),
        ...(expiresAt ? { expiresAt: admin.firestore.Timestamp.fromDate(expiresAt) } : {}),
      }, { merge: true });

      transaction.update(codeRef, {
        usedCount: fieldValue.increment(1),
        lastUsedAt: fieldValue.serverTimestamp(),
      });
    }

    return {
      allowed: true,
      status: 'granted',
      message: 'Accès accordé.',
      grant: grantPayload(code.grantType || 'ambassadorCode', scope, codeRef.id, expiresAt),
    };
  });
});

exports.createWatchSession = functions.https.onCall(async (data, context) => {
  const uid = context.auth && context.auth.uid;
  const request = normalizeWatchRequest(data.request);
  const access = await evaluateWatchAccess(uid, request);

  if (!access.allowed) return access;

  const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
  const sessionRef = await db.collection('watch_sessions').add({
    uid,
    contentType: request.contentType,
    ...(request.filmId ? { filmId: request.filmId } : {}),
    ...(request.seriesId ? { seriesId: request.seriesId } : {}),
    ...(request.seasonId ? { seasonId: request.seasonId } : {}),
    ...(request.episodeId ? { episodeId: request.episodeId } : {}),
    status: 'active',
    createdAt: fieldValue.serverTimestamp(),
    expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
    grant: access.grant || null,
  });

  return {
    ...access,
    sessionId: sessionRef.id,
    expiresAt: expiresAt.toISOString(),
    playbackUrl: null,
  };
});

exports.getSignedVideoUrl = functions.https.onCall(async () => {
  return {
    allowed: false,
    status: 'unavailable',
    message: 'La génération d’URL signée sera activée après configuration CDN/Storage.',
  };
});

exports.deleteMyAccount = functions.https.onCall(async (_, context) => {
  const uid = context.auth && context.auth.uid;
  if (!uid) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Une connexion est requise.',
    );
  }

  const authTimeSeconds = Number(context.auth.token.auth_time || 0);
  const authAgeMs = Date.now() - authTimeSeconds * 1000;
  if (!authTimeSeconds || authAgeMs > 10 * 60 * 1000) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Reconnectez-vous avant de supprimer votre compte.',
    );
  }

  await db.recursiveDelete(db.collection('users').doc(uid));
  await deleteQueryDocuments(
    db.collection('user_entitlements').where('uid', '==', uid),
  );
  await deleteQueryDocuments(
    db.collection('watch_sessions').where('uid', '==', uid),
  );

  try {
    await admin.auth().deleteUser(uid);
  } catch (error) {
    if (error.code !== 'auth/user-not-found') throw error;
  }

  return { deleted: true };
});

/**
 * Déclencheur Firestore : génère searchTokens sur write de films
 */
exports.generateFilmSearchTokens = functions.firestore
  .document('films/{filmId}')
  .onWrite(async (change) => {
    if (!change.after.exists) return null; // document supprimé
    const data = change.after.data();
    if (!data || !data.title) return null;

    const tokens = generateSearchTokens(data);

    // Éviter une boucle infinie : ne mettre à jour que si les tokens ont changé
    const existing = (data.searchTokens || []).slice().sort().join(',');
    const computed = tokens.slice().sort().join(',');
    if (existing === computed) return null;

    return change.after.ref.update({ searchTokens: tokens });
  });

/**
 * Déclencheur Firestore : génère searchTokens sur write de séries
 */
exports.generateSeriesSearchTokens = functions.firestore
  .document('series/{seriesId}')
  .onWrite(async (change) => {
    if (!change.after.exists) return null;
    const data = change.after.data();
    if (!data || !data.title) return null;

    const tokens = generateSearchTokens(data);

    const existing = (data.searchTokens || []).slice().sort().join(',');
    const computed = tokens.slice().sort().join(',');
    if (existing === computed) return null;

    return change.after.ref.update({ searchTokens: tokens });
  });
