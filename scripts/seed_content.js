/**
 * Guezs Films — Script de seed Firebase
 * ─────────────────────────────────────────────────────────────────────────────
 * Ce script :
 *   1. Upload les 17 photos d'épisodes vers Firebase Storage
 *   2. Upload les médias de "ELLE ET MOA" vers Firebase Storage
 *   3. Crée les documents Firestore :
 *      - Série "L'EPOUSE DU MBENGUISTE" (+ 1 saison + 17 épisodes)
 *      - Série "ELLE ET MOA"
 *
 * Pré-requis :
 *   • npm install  (dans le dossier scripts/)
 *   • Placer votre clé Firebase Admin sous scripts/serviceAccountKey.json
 *     (Firebase Console → Project Settings → Service accounts → Generate new private key)
 *
 * Usage de démonstration uniquement :
 *   node seed_content.js --confirm-public-media
 * ─────────────────────────────────────────────────────────────────────────────
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

if (!process.argv.includes('--confirm-public-media')) {
  console.error(
    'Seed bloqué: ce script publie des médias. Ajoutez --confirm-public-media uniquement pour un environnement de démonstration.',
  );
  process.exit(1);
}

// ─── Vérification de la clé de service ───────────────────────────────────────
const KEY_PATH = path.join(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(KEY_PATH)) {
  console.error('\n❌  Clé Firebase Admin introuvable.');
  console.error('   Téléchargez-la depuis :');
  console.error('   Firebase Console → guezs-films → Project Settings → Service accounts');
  console.error('   → "Generate new private key"');
  console.error(`   → Sauvegardez sous : ${KEY_PATH}\n`);
  process.exit(1);
}

const serviceAccount = require(KEY_PATH);
const PROJECT_ID     = serviceAccount.project_id;
// Les projets Firebase récents utilisent .firebasestorage.app (depuis 2024)
// Les anciens projets utilisent .appspot.com
// Modifiez si nécessaire :
const BUCKET_NAME    = `${PROJECT_ID}.firebasestorage.app`;

// ─── Initialisation Firebase Admin ───────────────────────────────────────────
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: BUCKET_NAME,
});

const db      = admin.firestore();
const bucket  = admin.storage().bucket();
const ASSETS  = path.join(__dirname, '..', 'assets', 'images', 'medias_films');

// ─── Utilitaires ─────────────────────────────────────────────────────────────

/** Génère les tokens de recherche full-text (compatibles Cloud Functions existantes) */
function generateSearchTokens(text) {
  const lower = text.toLowerCase();
  const words = lower.split(/\s+/).filter(Boolean);
  const tokens = new Set();
  for (const word of words) {
    for (let i = 1; i <= word.length; i++) {
      tokens.add(word.substring(0, i));
    }
  }
  return Array.from(tokens);
}

/** 
 * Gère intelligemment un asset : 
 * 1. Priorité au fichier Local (s'il existe, on l'upload)
 * 2. Sinon, vérifie si le fichier existe déjà à la destination (Storage)
 * 3. Sinon, vérifie si le fichier existe à l'ancien emplacement (Migration)
 */
async function ensureAsset(localPath, storagePath, oldStoragePath, contentType) {
  const fileName = localPath ? path.basename(localPath) : 'cloud-asset';
  const destinationFile = bucket.file(storagePath);
  
  // 1. Essai Local
  if (localPath && fs.existsSync(localPath)) {
    console.log(`   ⬆️  Upload (Local) : ${fileName} → ${storagePath}`);
    await bucket.upload(localPath, {
      destination: storagePath,
      metadata: { contentType },
      public: true,
    });
    return `https://storage.googleapis.com/${BUCKET_NAME}/${storagePath}`;
  }

  // 2. Vérification Destination existante
  const [existsNew] = await destinationFile.exists();
  if (existsNew) {
    console.log(`   💎 Existant (Storage) : ${storagePath}`);
    return `https://storage.googleapis.com/${BUCKET_NAME}/${storagePath}`;
  }

  // 3. Migration Cloud-to-Cloud (depuis l'ancien dossier)
  if (oldStoragePath) {
    const oldFile = bucket.file(oldStoragePath);
    const [existsOld] = await oldFile.exists();
    
    if (existsOld) {
      console.log(`   🔄 Migration (Cloud-to-Cloud) : ${oldStoragePath} → ${storagePath}`);
      await oldFile.copy(destinationFile);
      await destinationFile.makePublic();
      
      // Suppression de l'ancien fichier après copie réussie
      try {
        await oldFile.delete();
        console.log(`      🗑️  Nettoyage : ancien fichier supprimé`);
      } catch (e) {
        console.warn(`      ⚠️  Impossible de supprimer l'ancien fichier : ${e.message}`);
      }
      
      return `https://storage.googleapis.com/${BUCKET_NAME}/${storagePath}`;
    }
  }

  console.warn(`   ❌ Asset introuvable : ${fileName} (ni local, ni cloud)`);
  return '';
}

/** 
 * Supprime récursivement un document Firestore et ses sous-collections
 */
async function deleteFirestoreDoc(docPath) {
  const docRef = db.doc(docPath);
  const collections = await docRef.listCollections();
  
  for (const collection of collections) {
    const snapshots = await collection.get();
    for (const doc of snapshots.docs) {
      await deleteFirestoreDoc(`${docPath}/${collection.id}/${doc.id}`);
    }
  }
  
  await docRef.delete();
}

/** Formate le numéro d'épisode en 2 chiffres */
function pad(n) {
  return n.toString().padStart(2, '0');
}

// ─── Seed principal ───────────────────────────────────────────────────────────
async function main() {
  console.log(`\n🎬  Guezs Films — Seed Firebase`);
  console.log(`   Projet : ${PROJECT_ID}`);
  console.log(`   Bucket : ${BUCKET_NAME}\n`);

  // ── 1. Upload des 17 images d'épisodes ──────────────────────────────────────
  console.log('📸  Upload des images d\'épisodes...');
  const episodeThumbnailUrls = {};

  const imageExtensions = ['JPG', 'jpg', 'jpeg', 'JPEG', 'png', 'PNG'];

  for (let i = 1; i <= 17; i++) {
    // Cherche le bon fichier (extension majuscule ou minuscule)
    let localFile = null;
    for (const ext of imageExtensions) {
      const candidate = path.join(ASSETS, `${i}.${ext}`);
      if (fs.existsSync(candidate)) {
        localFile = candidate;
        break;
      }
    }
    // (Le script continuera vers ensureAsset même si localFile est null pour tenter une migration)

    const storagePath = `series/femme-mbenguiste/episodes/ep${pad(i)}.jpg`;
    const oldStoragePath = `series/epouse-mbenguiste/episodes/ep${pad(i)}.jpg`;
    
    episodeThumbnailUrls[i] = await ensureAsset(localFile, storagePath, oldStoragePath, 'image/jpeg');
  }

  // ── 1.bis Nettoyage Firestore (Optionnel mais recommandé) ──────────────
  console.log('\n🧹  Nettoyage Firestore (Ancienne série)...');
  try {
    const OLD_SERIES_ID = 'epouse-mbenguiste';
    const oldDocRef = db.collection('series').doc(OLD_SERIES_ID);
    const [oldExists] = await Promise.all([(await oldDocRef.get()).exists]);
    
    if (oldExists) {
      console.log(`   🗑️  Suppression de l'ancienne série : ${OLD_SERIES_ID}`);
      await deleteFirestoreDoc(`series/${OLD_SERIES_ID}`);
      console.log('      ✅ Nettoyage terminé');
    } else {
      console.log('   ✨ Rien à nettoyer (déjà supprimé)');
    }
  } catch (e) {
    console.warn(`   ⚠️  Erreur lors du nettoyage Firestore : ${e.message}`);
  }

  // ── 2. Upload des médias "ELLE ET MOA" (fichiers locaux historiques) ───────
  console.log('\n🎥  Upload des médias "ELLE ET MOA"...');
  const VIDEOS_DIR = path.join(ASSETS, 'videos');
  const elleThumbs = {};
  const elleVideos = {};

  for (let i = 1; i <= 4; i++) {
    // Affiche
    const affichePath = path.join(VIDEOS_DIR, `elle et moi affiche${i}.png`);
    const afficheLocal = fs.existsSync(affichePath) ? affichePath : null;
    elleThumbs[i] = await ensureAsset(
      afficheLocal,
      `series/elle-et-moi/affiches/affiche${pad(i)}.png`,
      null, // Pas de migration de chemin Storage (déjà OK)
      'image/png'
    );

    // Vidéo épisode
    const epPath = path.join(VIDEOS_DIR, `elle et moi episode${pad(i)}.mp4`);
    const videoLocal = fs.existsSync(epPath) ? epPath : null;
    elleVideos[i] = await ensureAsset(
      videoLocal,
      `series/elle-et-moi/episodes/episode${pad(i)}.mp4`,
      null,
      'video/mp4'
    );
  }
  console.log('   ✅ Médias "ELLE ET MOA" uploadés');

  // ── 3. Seed Firestore — Série "L'EPOUSE DU MBENGUISTE" ─────────────────────
  console.log('\n🗄️   Seed Firestore — Série...');
  const SERIES_ID  = 'femme-mbenguiste';
  const SEASON_ID  = 'saison-1';
  const SERIES_TITLE = "L'EPOUSE DU MBENGUISTE";

  const seriesDoc = {
    title:           SERIES_TITLE,
    description:     "Plongez dans l'histoire captivante de L'EPOUSE DU MBENGUISTE — amour, trahison et rebondissements au fil de 17 épisodes inoubliables.",
    posterUrl:       episodeThumbnailUrls[1] || '',
    backdropUrl:     episodeThumbnailUrls[1] || '',
    genres:          ['Drame', 'Romance', 'Africain'],
    year:            2024,
    numberOfSeasons: 1,
    isFeatured:      true,
    isNew:           true,
    searchTokens:    generateSearchTokens(SERIES_TITLE),
    createdAt:       admin.firestore.FieldValue.serverTimestamp(),
  };

  await db.collection('series').doc(SERIES_ID).set(seriesDoc);
  console.log(`   ✅ Série créée : ${SERIES_TITLE}`);

  // ── 4. Seed Firestore — Saison 1 ────────────────────────────────────────────
  const seasonDoc = {
    seriesId:     SERIES_ID,
    seasonNumber: 1,
    title:        'Saison 1',
  };
  await db.collection('series').doc(SERIES_ID)
          .collection('seasons').doc(SEASON_ID)
          .set(seasonDoc);
  console.log('   ✅ Saison 1 créée');

  // ── 5. Seed Firestore — 17 Épisodes ─────────────────────────────────────────
  console.log('\n📋  Seed Firestore — Épisodes...');
  const batch = db.batch();

  for (let i = 1; i <= 17; i++) {
    const episodeId  = `ep${pad(i)}`;
    const episodeRef = db.collection('series').doc(SERIES_ID)
                         .collection('seasons').doc(SEASON_ID)
                         .collection('episodes').doc(episodeId);

    batch.set(episodeRef, {
      seriesId:      SERIES_ID,
      seasonId:      SEASON_ID,
      episodeNumber: i,
      title:         `Épisode ${i}`,
      description:   `L'EPOUSE DU MBENGUISTE — Épisode ${i}. Découvrez la suite des aventures dans ce nouvel épisode.`,
      thumbnailUrl:  episodeThumbnailUrls[i] || '',
      videoUrl:      '',
      durationSec:   0,
      airDate:       admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`   ✅ Épisode ${i} seedé`);
  }

  await batch.commit();
  console.log('   ✅ Batch commit — 17 épisodes enregistrés');

  // ── 6. Seed Firestore — Série "ELLE ET MOA" (4 épisodes) ───────────────────
  console.log('\n🎬  Seed Firestore — Série "ELLE ET MOA"...');
  const ELLE_ID      = 'elle-et-moi';
  const ELLE_TITLE   = 'ELLE ET MOA';
  const ELLE_SEASON  = 'saison-1';

  await db.collection('series').doc(ELLE_ID).set({
    title:           ELLE_TITLE,
    description:     "Une série touchante qui explore avec sensibilité les complexités des relations modernes, entre passion et réalité. En 4 épisodes captivants.",
    posterUrl:       elleThumbs[1] || '',
    backdropUrl:     elleThumbs[2] || elleThumbs[1] || '',
    genres:          ['Drame', 'Romance'],
    year:            2024,
    numberOfSeasons: 1,
    isFeatured:      true,
    isNew:           true,
    searchTokens:    generateSearchTokens(ELLE_TITLE),
    createdAt:       admin.firestore.FieldValue.serverTimestamp(),
  });

  await db.collection('series').doc(ELLE_ID)
          .collection('seasons').doc(ELLE_SEASON)
          .set({ seriesId: ELLE_ID, seasonNumber: 1, title: 'Saison 1' });

  const elleBatch = db.batch();
  for (let i = 1; i <= 4; i++) {
    const epRef = db.collection('series').doc(ELLE_ID)
                    .collection('seasons').doc(ELLE_SEASON)
                    .collection('episodes').doc(`ep${pad(i)}`);
    elleBatch.set(epRef, {
      seriesId:      ELLE_ID,
      seasonId:      ELLE_SEASON,
      episodeNumber: i,
      title:         `Épisode ${i}`,
      description:   `ELLE ET MOA — Épisode ${i}. Une nouvelle page de cette histoire bouleversante.`,
      thumbnailUrl:  elleThumbs[i] || '',
      videoUrl:      elleVideos[i] || '',
      durationSec:   0,
      airDate:       admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`   ✅ Épisode ${i} seedé`);
  }
  await elleBatch.commit();
  console.log(`   ✅ Série créée : ${ELLE_TITLE} (4 épisodes)`);

  // ── Résumé ──────────────────────────────────────────────────────────────────
  console.log('\n─────────────────────────────────────────────────────');
  console.log('✅  Seed terminé avec succès !');
  console.log('');
  console.log("   📺  Série 1 : L'EPOUSE DU MBENGUISTE (17 épisodes)");
  console.log('   📺  Série 2 : ELLE ET MOA (4 épisodes)');
  console.log('');
  console.log('   Lancez votre app Flutter pour voir le résultat.');
  console.log('─────────────────────────────────────────────────────\n');

  process.exit(0);
}

main().catch((err) => {
  console.error('\n❌  Erreur lors du seed :', err.message || err);
  process.exit(1);
});
