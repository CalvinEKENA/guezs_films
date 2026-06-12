"use client";
import { useState } from "react";
import AdminLayout from "@/components/admin/AdminLayout";
import ImageUploader from "@/components/admin/ImageUploader";
import { useAuth } from "@/hooks/useAuth";
import { db } from "@/lib/firebase";
import { collection, addDoc, serverTimestamp } from "firebase/firestore";

// Mapping des emails vers les noms des admins
const adminNames: Record<string, string> = {
  "menyvguess@gmail.com": "Yvette MENGUE",
  "calvinekena4@gmail.com": "Calvin EKENA",
};

export default function AdminPage() {
  const { user } = useAuth();
  const [formData, setFormData] = useState({
    name: "",
    category: "Style",
    description: "",
    price: "",
    image: ""
  });

  const [isSaving, setIsSaving] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.image) return alert("Veuillez uploader une image d'abord.");

    setIsSaving(true);
    try {
      await addDoc(collection(db, "products"), {
        ...formData,
        createdAt: serverTimestamp(),
      });
      alert("Produit ajouté avec succès au catalogue GUEZS !");
      setFormData({ name: "", category: "Style", description: "", price: "", image: "" });
    } catch (error) {
      console.error("Erreur Firestore:", error);
    } finally {
      setIsSaving(false);
    }
  };

  const adminName = user?.email ? adminNames[user.email] || user.email : "Admin";

  return (
    <AdminLayout title="Nouveau Produit">
      {/* Message de bienvenue */}
      <div className="mb-8 p-6 bg-gradient-to-r from-guezs-gold/10 to-transparent border-l-4 border-guezs-gold">
        <p className="text-lg text-gray-800">
          Bienvenue, <span className="font-heading text-guezs-gold">{adminName}</span> 👋
        </p>
        <p className="text-sm text-gray-500 mt-1">Gestion GUEZS Style & Cosmétique</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Section Upload & Formulaire */}
        <div className="lg:col-span-2 space-y-8">
          <section className="bg-white p-6 md:p-8 shadow-sm border border-gray-100">
            <h2 className="font-heading text-xl mb-6 text-gray-800">Ajouter un Produit</h2>

            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="flex flex-col">
                  <label className="text-[10px] uppercase font-bold text-gray-500 mb-2">Nom du produit</label>
                  <input
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({...formData, name: e.target.value})}
                    className="border-b border-gray-200 focus:border-guezs-gold outline-none py-2 text-sm text-gray-800 bg-transparent"
                    placeholder="Ex: Sérum Diamond"
                  />
                </div>
                <div className="flex flex-col">
                  <label className="text-[10px] uppercase font-bold text-gray-500 mb-2">Catégorie</label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({...formData, category: e.target.value})}
                    className="border-b border-gray-200 focus:border-guezs-gold outline-none py-2 text-sm text-gray-800 bg-transparent"
                  >
                    <option value="Style">GUEZS Style (Mode)</option>
                    <option value="Cosmétique">GUEZS Style (Cosmétique)</option>
                    <option value="Piknik">GUEZS Piknik (Évènements)</option>
                  </select>
                </div>
              </div>

              <div className="flex flex-col">
                <label className="text-[10px] uppercase font-bold text-gray-500 mb-2">Prix (FCFA)</label>
                <input
                  type="number"
                  value={formData.price}
                  onChange={(e) => setFormData({...formData, price: e.target.value})}
                  className="border-b border-gray-200 focus:border-guezs-gold outline-none py-2 text-sm text-gray-800 bg-transparent"
                  placeholder="Ex: 15000"
                />
              </div>

              <div className="flex flex-col">
                <label className="text-[10px] uppercase font-bold text-gray-500 mb-2">Description</label>
                <textarea
                  required
                  rows={3}
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                  className="border border-gray-200 p-3 focus:border-guezs-gold outline-none text-sm text-gray-800 bg-transparent rounded"
                  placeholder="Description du produit..."
                />
              </div>

              <div className="space-y-2">
                <label className="text-[10px] uppercase font-bold text-gray-500">Visuel du produit</label>
                <ImageUploader onUploadComplete={(url) => setFormData({...formData, image: url})} />
                {formData.image && (
                  <p className="text-[10px] text-green-600 font-bold uppercase">✓ Image prête pour la publication</p>
                )}
              </div>

              <button
                disabled={isSaving}
                type="submit"
                className="w-full bg-guezs-black text-guezs-gold py-4 font-bold uppercase tracking-[0.2em] text-xs hover:bg-guezs-gold hover:text-guezs-black transition-all disabled:opacity-50"
              >
                {isSaving ? "Synchronisation..." : "Publier sur le site"}
              </button>
            </form>
          </section>
        </div>

        {/* Sidebar de prévisualisation */}
        <div className="lg:col-span-1">
          <div className="sticky top-24 bg-gray-50 p-6 border border-gray-200 rounded">
            <h3 className="font-heading text-lg mb-4 text-gray-800">Aperçu direct</h3>
            {formData.image ? (
              <div className="bg-white p-4 shadow-sm rounded">
                <img src={formData.image} alt="Preview" className="w-full h-48 object-cover mb-4 rounded" />
                <p className="font-bold text-sm uppercase text-gray-800">{formData.name || "Nom du produit"}</p>
                <p className="text-[10px] text-guezs-gold mt-1 uppercase">{formData.category}</p>
                {formData.price && (
                  <p className="text-sm font-bold text-gray-700 mt-2">{Number(formData.price).toLocaleString()} FCFA</p>
                )}
              </div>
            ) : (
              <div className="h-64 border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 text-[10px] uppercase tracking-widest text-center px-4 rounded">
                L'aperçu s'affichera ici après l'upload de l'image
              </div>
            )}
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
