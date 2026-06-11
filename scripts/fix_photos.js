const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

/**
 * Script de réparation d'accès aux médias Guezs Films
 * ──────────────────────────────────────────────────
 * 1. Configure le CORS (indispensable pour le Web)
 * 2. Rend toutes les images du dossier series/ publiques
 */

const KEY_PATH = path.join(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(KEY_PATH)) {
  console.error('\n❌  Clé Firebase Admin introuvable dans scripts/');
  process.exit(1);
}

const serviceAccount = require(KEY_PATH);
const PROJECT_ID = serviceAccount.project_id;
const BUCKET_NAME = `${PROJECT_ID}.firebasestorage.app`;

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: BUCKET_NAME,
});

const bucket = admin.storage().bucket();

async function fix() {
  console.log('\n🚀 Démarrage de la réparation des photos...');
  console.log(`   Projet : ${PROJECT_ID}`);
  console.log(`   Bucket : ${BUCKET_NAME}\n`);

  // 1. Configurer CORS
  console.log('🌐 Configuration du CORS (All Origins)...');
  const corsConfiguration = [
    {
      origin: ['*'],
      method: ['GET'],
      maxAgeSeconds: 3600,
      responseHeader: ['Content-Type'],
    },
  ];
  
  try {
    await bucket.setCorsConfiguration(corsConfiguration);
    console.log('   ✅ CORS configuré avec succès');
  } catch (e) {
    console.error(`   ⚠️  Erreur lors de la config CORS : ${e.message}`);
  }

  // 2. Rendre les fichiers publics
  console.log('\n🔓 Renforcement des permissions publiques (ACL)...');
  try {
    const [files] = await bucket.getFiles({ prefix: 'series/' });
    
    let fixedCount = 0;
    for (const file of files) {
      if (file.name.match(/\.(jpg|jpeg|png|webp|mp4)$/i)) {
        await file.makePublic();
        fixedCount++;
        if (fixedCount % 5 === 0) {
          process.stdout.write('.'); // Progrès visuel
        }
      }
    }
    console.log(`\n   ✅ ${fixedCount} fichiers mis à jour en accès public`);
  } catch (e) {
    console.error(`   ❌ Erreur lors de la mise à jour des permissions : ${e.message}`);
  }
  
  console.log('\n✨ Réparation terminée !');
  console.log('   Rafraîchissez votre navigateur pour voir les photos.\n');
  process.exit(0);
}

fix().catch(err => {
  console.error('\n❌ Erreur fatale :', err.message || err);
  process.exit(1);
});
