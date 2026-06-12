"use client";

import { AuthProvider } from "@/hooks/useAuth";
import { ReactNode } from "react";

export default function AdminRootLayout({ children }: { children: ReactNode }) {
  return (
    <AuthProvider>
      <div className="admin-wrapper">
        <style jsx global>{`
          .admin-wrapper ~ nav,
          .admin-wrapper ~ .whatsapp-button,
          body > nav,
          body > .fixed.bottom-6 {
            display: none !important;
          }
        `}</style>
        {children}
      </div>
    </AuthProvider>
  );
}
