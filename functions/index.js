const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Génère les tokens de recherche à partir d'un titre.
 * Chaque mot est décomposé en tous ses préfixes (min 2 chars).
 * Ex: "Black Panther" → ["bl","bla","blac","black","pa","pan","pant","panther","black panther"]
 */
function generateSearchTokens(title) {
  if (!title || typeof title !== 'string') return [];
  const tokens = new Set();
  const normalized = title.toLowerCase().trim();
  const words = normalized.split(/\s+/);

  for (const word of words) {
    if (word.length < 2) continue;
    for (let i = 2; i <= word.length; i++) {
      tokens.add(word.substring(0, i));
    }
    tokens.add(word);
  }

  // Ajouter le titre complet normalisé
  tokens.add(normalized);

  return Array.from(tokens);
}

/**
 * Déclencheur Firestore : génère searchTokens sur write de films
 */
exports.generateFilmSearchTokens = functions.firestore
  .document('films/{filmId}')
  .onWrite(async (change) => {
    if (!change.after.exists) return null; // document supprimé
    const data = change.after.data();
    if (!data || !data.title) return null;

    const tokens = generateSearchTokens(data.title);

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

    const tokens = generateSearchTokens(data.title);

    const existing = (data.searchTokens || []).slice().sort().join(',');
    const computed = tokens.slice().sort().join(',');
    if (existing === computed) return null;

    return change.after.ref.update({ searchTokens: tokens });
  });
