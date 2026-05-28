"use client";

import { useState } from "react";
import AdminLayout from "@/components/admin/AdminLayout";
import { useCollection, FirestoreDocument } from "@/hooks/useFirestore";

interface Event extends FirestoreDocument {
  title: string;
  date: string;
  location: string;
  price: number;
  capacity: number;
  status: string;
}

export default function AdminEventsPage() {
  const { documents: events, loading, addDocument, deleteDocument } = useCollection<Event>("events");
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    title: "",
    date: "",
    location: "",
    price: "",
    capacity: "",
    status: "À venir",
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await addDocument({
      ...formData,
      price: Number(formData.price),
      capacity: Number(formData.capacity),
    });
    setFormData({ title: "", date: "", location: "", price: "", capacity: "", status: "À venir" });
    setShowForm(false);
  };

  const handleDelete = async (id: string) => {
    if (confirm("Supprimer cet événement ?")) {
      await deleteDocument(id);
    }
  };

  return (
    <AdminLayout title="Gestion Événements Piknik">
      <div className="flex justify-between items-center mb-6">
        <p className="text-gray-600">Gérez vos événements GUEZS Piknik</p>
        <button
          onClick={() => setShowForm(!showForm)}
          className="bg-guezs-gold text-guezs-black px-6 py-2 text-sm font-bold uppercase tracking-wider hover:bg-guezs-gold/90"
        >
          {showForm ? "Annuler" : "+ Créer événement"}
        </button>
      </div>

      {showForm && (
        <form onSubmit={handleSubmit} className="bg-white p-6 shadow-sm mb-8">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
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
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Date</label>
              <input
                type="date"
                value={formData.date}
                onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                className="w-full border border-gray-200 px-4 py-2 focus:outline-none focus:border-guezs-gold"
                required
              />
            </div>
            <div>
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Lieu</label>
              <input
                type="text"
                value={formData.location}
                onChange={(e) => setFormData({ ...formData, location: e.target.value })}
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
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Capacité</label>
              <input
                type="number"
                value={formData.capacity}
                onChange={(e) => setFormData({ ...formData, capacity: e.target.value })}
                className="w-full border border-gray-200 px-4 py-2 focus:outline-none focus:border-guezs-gold"
                required
              />
            </div>
            <div>
              <label className="block text-xs uppercase tracking-wider text-gray-500 mb-2">Statut</label>
              <select
                value={formData.status}
                onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                className="w-full border border-gray-200 px-4 py-2 focus:outline-none focus:border-guezs-gold"
              >
                <option value="À venir">À venir</option>
                <option value="Complet">Complet</option>
                <option value="Terminé">Terminé</option>
              </select>
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
        ) : events.length === 0 ? (
          <div className="p-8 text-center text-gray-500">Aucun événement enregistré</div>
        ) : (
          <table className="w-full">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-bold uppercase tracking-wider text-gray-500">Événement</th>
                <th className="px-6 py-3 text-left text-xs font-bold uppercase tracking-wider text-gray-500">Date</th>
                <th className="px-6 py-3 text-left text-xs font-bold uppercase tracking-wider text-gray-500">Prix</th>
                <th className="px-6 py-3 text-left text-xs font-bold uppercase tracking-wider text-gray-500">Statut</th>
                <th className="px-6 py-3 text-right text-xs font-bold uppercase tracking-wider text-gray-500">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {events.map((event) => (
                <tr key={event.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <p className="font-medium">{event.title}</p>
                    <p className="text-xs text-gray-500">{event.location}</p>
                  </td>
                  <td className="px-6 py-4 text-sm">{event.date}</td>
                  <td className="px-6 py-4 text-guezs-gold font-bold">
                    {event.price?.toLocaleString()} FCFA
                  </td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 text-xs rounded ${
                      event.status === "À venir" ? "bg-green-100 text-green-700" :
                      event.status === "Complet" ? "bg-orange-100 text-orange-700" :
                      "bg-gray-100 text-gray-700"
                    }`}>
                      {event.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button
                      onClick={() => handleDelete(event.id)}
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
