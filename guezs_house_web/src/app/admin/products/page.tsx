"use client";

import { useState } from "react";
import AdminLayout from "@/components/admin/AdminLayout";
import { useCollection, FirestoreDocument } from "@/hooks/useFirestore";

interface Product extends FirestoreDocument {
  name: string;
  category: string;
  description: string;
  price: number;
  whatsappLink: string;
}

const WHATSAPP_NUMBER = "237697773548";

export default function AdminProductsPage() {
  const { documents: products, loading, addDocument, deleteDocument } = useCollection<Product>("products");
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    category: "Cosmétiques",
    description: "",
    price: "",
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const whatsappMessage = encodeURIComponent(`Bonjour, je suis intéressé(e) par le produit: ${formData.name}`);
    await addDocument({
      ...formData,
      price: Number(formData.price),
      whatsappLink: `https://wa.me/${WHATSAPP_NUMBER}?text=${whatsappMessage}`,
    });
    setFormData({ name: "", category: "Cosmétiques", description: "", price: "" });
    setShowForm(false);
  };

  const handleDelete = async (id: string) => {
    if (confirm("Supprimer ce produit ?")) {
      await deleteDocument(id);
    }
  };

  return (
    <AdminLayout title="Gestion Produits Style">
      <div className="flex justify-between items-center mb-6">
        <p className="text-gray-600">Gérez vos produits GUEZS Style & Beauté</p>
        <button
          onClick={() => setShowForm(!showForm)}
          className="bg-guezs-gold text-guezs-black px-6 py-2 text-sm font-bold uppercase tracking-wider hover:bg-guezs-gold/90"
        >
          {showForm ? "Annuler" : "+ Ajouter produit"}
        </button>
      </div>

      {showForm && (
        <form onSubmit={handleSubmit} className="bg-white p-6 shadow-sm mb-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Nom du produit</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full border border-gray-200 px-4 py-2 focus:outline-none focus:border-guezs-gold"
                required
              />
            </div>
            <div>
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Catégorie</label>
              <select
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                className="w-full border border-gray-200 px-4 py-2 focus:outline-none focus:border-guezs-gold"
              >
                <option value="Cosmétiques">Cosmétiques</option>
                <option value="Soins">Soins</option>
                <option value="Parfums">Parfums</option>
                <option value="Accessoires">Accessoires</option>
              </select>
            </div>
            <div>
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Prix (FCFA)</label>
              <input
                type="number"
                value={formData.price}
                onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                className="w-full border border-gray-200 px-4 py-2 focus:outline-none focus:border-guezs-gold"
                required
              />
            </div>
            <div>
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Description</label>
              <input
                type="text"
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                className="w-full border border-gray-200 px-4 py-2 focus:outline-none focus:border-guezs-gold"
              />
            </div>
          </div>
          <button
            type="submit"
            className="mt-6 bg-guezs-black text-guezs-gold px-8 py-3 text-sm font-bold uppercase tracking-wider hover:bg-gray-800"
          >
            Enregistrer
          </button>
        </form>
      )}

      <div className="bg-white shadow-sm">
        {loading ? (
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-guezs-gold mx-auto"></div>
          </div>
        ) : products.length === 0 ? (
          <div className="p-8 text-center text-gray-500">Aucun produit enregistré</div>
        ) : (
          <table className="w-full">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-bold uppercase tracking-wider text-gray-500">Produit</th>
                <th className="px-6 py-3 text-left text-xs font-bold uppercase tracking-wider text-gray-500">Catégorie</th>
                <th className="px-6 py-3 text-left text-xs font-bold uppercase tracking-wider text-gray-500">Prix</th>
                <th className="px-6 py-3 text-right text-xs font-bold uppercase tracking-wider text-gray-500">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {products.map((product) => (
                <tr key={product.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <p className="font-medium">{product.name}</p>
                    <p className="text-xs text-gray-500">{product.description}</p>
                  </td>
                  <td className="px-6 py-4">
                    <span className="px-2 py-1 text-xs bg-pink-100 text-pink-700 rounded">{product.category}</span>
                  </td>
                  <td className="px-6 py-4 text-guezs-gold font-bold">
                    {product.price?.toLocaleString()} FCFA
                  </td>
                  <td className="px-6 py-4 text-right space-x-3">
                    <a
                      href={product.whatsappLink}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-green-600 text-xs uppercase font-bold hover:text-green-800"
                    >
                      WhatsApp
                    </a>
                    <button
                      onClick={() => handleDelete(product.id)}
                      className="text-red-500 text-xs uppercase font-bold hover:text-red-700"
                    >
                      Supprimer
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </AdminLayout>
  );
}
