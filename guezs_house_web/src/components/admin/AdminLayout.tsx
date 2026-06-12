"use client";

import { ReactNode, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useAuth } from "@/hooks/useAuth";

const menuItems = [
  { label: "Dashboard", href: "/admin", icon: "📊" },
  { label: "Immobilier", href: "/admin/properties", icon: "🏠" },
  { label: "Événements", href: "/admin/events", icon: "🎉" },
  { label: "Produits", href: "/admin/products", icon: "💄" },
  { label: "Contacts", href: "/admin/leads", icon: "📬" },
];

// Mapping des emails vers les noms des admins
const adminNames: Record<string, string> = {
  "menyvguess@gmail.com": "Yvette MENGUE",
  "calvinekena4@gmail.com": "Calvin EKENA",
};

interface AdminLayoutProps {
  children: ReactNode;
  title: string;
}
export default function AdminLayout({ children, title }: AdminLayoutProps) {
  const { user, loading, signOut } = useAuth();
  const router = useRouter();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    if (!loading && !user) {
      router.push("/admin/login");
    }
  }, [user, loading, router]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-guezs-gold"></div>
      </div>
    );
  }

  if (!user) {
    return null;
  }

  return (
    <div className="min-h-screen bg-gray-100">
      {/* Mobile Header */}
      <div className="lg:hidden fixed top-0 left-0 right-0 z-40 p-4 flex items-center justify-between" style={{ backgroundColor: '#0A0A0A' }}>
        <img
          src="/assets/logos/logo_guezs_houses.png"
          alt="GUEZS HOUSE"
          className="h-8 object-contain"
        />
        <button
          onClick={() => setSidebarOpen(!sidebarOpen)}
          className="text-white p-2"
        >
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            {sidebarOpen ? (
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            ) : (
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            )}
          </svg>
        </button>
      </div>

      {/* Overlay for mobile */}
      {sidebarOpen && (
        <div
          className="lg:hidden fixed inset-0 bg-black/50 z-40"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`fixed h-full z-50 w-64 transform transition-transform duration-300 lg:translate-x-0 ${
          sidebarOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
        style={{ backgroundColor: '#0A0A0A' }}
      >
        <div className="p-6 border-b border-white/10">
          <img
            src="/assets/logos/logo_guezs_houses.png"
            alt="GUEZS HOUSE"
            className="h-12 object-contain mb-2"
          />
          <p className="text-xs text-gray-400 mt-1">Administration</p>
        </div>

        <nav className="mt-6">
          {menuItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setSidebarOpen(false)}
              className="flex items-center gap-3 px-6 py-3 text-sm text-white hover:bg-white/5 transition-colors border-l-2 border-transparent hover:border-guezs-gold"
            >
              <span>{item.icon}</span>
              <span>{item.label}</span>
            </Link>
          ))}
        </nav>

        <div className="absolute bottom-0 left-0 right-0 p-6 border-t border-white/10">
          <p className="text-sm text-white font-medium mb-1">
            {user.email ? adminNames[user.email] || user.email : "Admin"}
          </p>
          <p className="text-xs text-gray-500 mb-3">{user.email}</p>
          <button
            onClick={() => signOut()}
            className="w-full py-2 text-xs uppercase tracking-wider bg-red-600/20 text-red-400 hover:bg-red-600/30 transition-colors rounded"
          >
            Déconnexion
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="lg:ml-64 p-4 md:p-8 pt-20 lg:pt-8">
        <header className="mb-6 md:mb-8">
          <h2 className="text-xl md:text-2xl font-heading text-gray-800">{title}</h2>
          <div className="w-16 h-1 bg-guezs-gold mt-2"></div>
        </header>
        {children}
      </main>
    </div>
  );
}
