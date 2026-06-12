"use client";

import { useState } from "react";
import AdminLayout from "@/components/admin/AdminLayout";
import { useCollection, FirestoreDocument } from "@/hooks/useFirestore";

interface Property extends FirestoreDocument {
  title: string;
  price: number;
  location: string;
  type: string;
  category: string;
  features: string;
}

export default function AdminPropertiesPage() {
  const { documents: properties, loading, addDocument, deleteDocument } = useCollection<Property>("properties");
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    title: "",
    price: "",
    location: "",
    type: "Vente",
    category: "Luxe",
    features: "",
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await addDocument({
      ...formData,
      price: Number(formData.price),
    });
    setFormData({ title: "", price: "", location: "", type: "Vente", category: "Luxe", features: "" });
    setShowForm(false);
  };

  const handleDelete = async (id: string) => {
    if (confirm("Supprimer ce bien ?")) {
      await deleteDocument(id);
    }
  };

  return (
    <AdminLayout title="Gestion Immobilier">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <p className="text-gray-600">Gérez vos biens immobiliers</p>
        <button
          onClick={() => setShowForm(!showForm)}
          className="bg-guezs-gold text-guezs-black px-6 py-2 text-sm font-bold uppercase tracking-wider hover:bg-guezs-gold/90"
        >
          {showForm ? "Annuler" : "+ Ajouter un bien"}
        </button>
      </div>

      {/* Form */}
      {showForm && (
        <form onSubmit={handleSubmit} className="bg-white p-6 shadow-sm mb-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Titre</label>
              <input
                type="text"
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                className="w-full border border-gray-200 px-4 py-2 focus:outline-none focus:border-guezs-gold"
                required
              />
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
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Localisation</label>
              <input
                type="text"
                value={formData.location}
                onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                className="w-full border border-gray-200 px-4 py-2 focus:outline-none focus:border-guezs-gold"
                required
              />
            </div>
            <div>
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Type</label>
              <select
                value={formData.type}
                onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                className="w-full border border-gray-200 px-4 py-2 focus:outline-none focus:border-guezs-gold"
              >
                <option value="Vente">Vente</option>
                <option value="Location">Location</option>
                <option value="Promotion">Promotion</option>
              </select>
            </div>
            <div>
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Catégorie</label>
              <select
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                className="w-full border border-gray-200 px-4 py-2 focus:outline-none focus:border-guezs-gold"
              >
                <option value="Luxe">Luxe</option>
                <option value="Business">Business</option>
                <option value="Standard">Standard</option>
              </select>
            </div>
            <div>
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Caractéristiques</label>
              <input
                type="text"
                value={formData.features}
                onChange={(e) => setFormData({ ...formData, features: e.target.value })}
                placeholder="3 chambres, 2 SDB, Piscine..."
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

      {/* List */}
      <div className="bg-white shadow-sm">
        {loading ? (
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-guezs-gold mx-auto"></div>
          </div>
        ) : properties.length === 0 ? (
          <div className="p-8 text-center text-gray-500">
            Aucun bien immobilier enregistré
          </div>
        ) : (
          <table className="w-full">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-bold uppercase tracking-wider text-gray-500">Titre</th>
                <th className="px-6 py-3 text-left text-xs font-bold uppercase tracking-wider text-gray-500">Prix</th>
                <th className="px-6 py-3 text-left text-xs font-bold uppercase tracking-wider text-gray-500">Type</th>
                <th className="px-6 py-3 text-left text-xs font-bold uppercase tracking-wider text-gray-500">Catégorie</th>
                <th className="px-6 py-3 text-right text-xs font-bold uppercase tracking-wider text-gray-500">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {properties.map((property) => (
                <tr key={property.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <p className="font-medium text-gray-800">{property.title}</p>
                    <p className="text-xs text-gray-500">{property.location}</p>
                  </td>
                  <td className="px-6 py-4 text-guezs-gold font-bold">
                    {property.price?.toLocaleString()} FCFA
                  </td>
                  <td className="px-6 py-4">
                    <span className="px-2 py-1 text-xs bg-gray-100 rounded">{property.type}</span>
                  </td>
                  <td className="px-6 py-4">
                    <span className="px-2 py-1 text-xs bg-guezs-gold/20 text-guezs-gold rounded">{property.category}</span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button
                      onClick={() => handleDelete(property.id)}
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
