"use client";

import AdminLayout from "@/components/admin/AdminLayout";
import { useCollection, FirestoreDocument } from "@/hooks/useFirestore";

interface Lead extends FirestoreDocument {
  name: string;
  email: string;
  phone: string;
  message: string;
  source: string;
  status: string;
  createdAt: { seconds: number };
}

export default function AdminLeadsPage() {
  const { documents: leads, loading, updateDocument, deleteDocument } = useCollection<Lead>("leads");

  const handleStatusChange = async (id: string, newStatus: string) => {
    await updateDocument(id, { status: newStatus });
  };

  const handleDelete = async (id: string) => {
    if (confirm("Supprimer ce contact ?")) {
      await deleteDocument(id);
    }
  };

  const formatDate = (timestamp: { seconds: number } | undefined) => {
    if (!timestamp) return "—";
    return new Date(timestamp.seconds * 1000).toLocaleDateString("fr-FR", {
      day: "numeric",
      month: "short",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  return (
    <AdminLayout title="Gestion Contacts & Leads">
      <div className="mb-6">
        <p className="text-gray-600">Centralisez et gérez vos demandes de contact</p>
      </div>

      <div className="bg-white shadow-sm">
        {loading ? (
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-guezs-gold mx-auto"></div>
          </div>
        ) : leads.length === 0 ? (
          <div className="p-8 text-center text-gray-500">
            <p className="text-4xl mb-4">📬</p>
            <p>Aucun contact reçu pour le moment</p>
            <p className="text-xs mt-2">Les demandes via le formulaire de contact apparaîtront ici</p>
          </div>
        ) : (
          <div className="divide-y divide-gray-100">
            {leads.map((lead) => (
              <div key={lead.id} className="p-6 hover:bg-gray-50">
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <h3 className="font-medium">{lead.name || "Anonyme"}</h3>
                      <span className={`px-2 py-1 text-[10px] rounded uppercase font-bold ${
                        lead.status === "Nouveau" ? "bg-blue-100 text-blue-700" :
                        lead.status === "Traité" ? "bg-green-100 text-green-700" :
                        "bg-gray-100 text-gray-700"
                      }`}>
                        {lead.status || "Nouveau"}
                      </span>
                      <span className="px-2 py-1 text-[10px] bg-guezs-gold/20 text-guezs-gold rounded">
                        {lead.source || "Site"}
                      </span>
                    </div>

                    <div className="flex gap-6 text-sm text-gray-600 mb-3">
                      {lead.email && (
                        <a href={`mailto:${lead.email}`} className="hover:text-guezs-gold">
                          📧 {lead.email}
                        </a>
                      )}
                      {lead.phone && (
                        <a href={`tel:${lead.phone}`} className="hover:text-guezs-gold">
                          📱 {lead.phone}
                        </a>
                      )}
                    </div>

                    {lead.message && (
                      <p className="text-sm text-gray-700 bg-gray-50 p-3 rounded">
                        {lead.message}
                      </p>
                    )}

                    <p className="text-xs text-gray-400 mt-3">
                      Reçu le {formatDate(lead.createdAt)}
                    </p>
                  </div>

                  <div className="flex flex-col gap-2 ml-4">
                    <select
                      value={lead.status || "Nouveau"}
                      onChange={(e) => handleStatusChange(lead.id, e.target.value)}
                      className="text-xs border border-gray-200 px-2 py-1 focus:outline-none focus:border-guezs-gold"
                    >
                      <option value="Nouveau">Nouveau</option>
                      <option value="En cours">En cours</option>
                      <option value="Traité">Traité</option>
                    </select>
                    <button
                      onClick={() => handleDelete(lead.id)}
                      className="text-red-500 text-xs uppercase font-bold hover:text-red-700"
                    >
                      Supprimer
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
