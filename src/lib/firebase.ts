import { initializeApp, getApps } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyAEqXCXN7AE2Y9LmFHJcVOFfimphDXp1Mw",
  authDomain: "guezs-house.firebaseapp.com",
  projectId: "guezs-house",
  storageBucket: "guezs-house.firebasestorage.app",
  messagingSenderId: "163844972748",
  appId: "1:163844972748:web:5a2a05f2c831eb6bf92269"
};

// Initialize Firebase (évite la double initialisation)
const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];

// Services Firebase
export const db = getFirestore(app);
export const storage = getStorage(app);
export const auth = getAuth(app);

export default app;

