import type { Metadata } from "next";
import { Cormorant_Garamond, Montserrat } from "next/font/google";
import "./globals.css";
import Navbar from "@/components/layout/Navbar";
import Footer from "@/components/layout/Footer";
import WhatsAppButton from "@/components/shared/WhatsAppButton";
import NoiseOverlay from "@/components/ui/NoiseOverlay";

const didotLike = Cormorant_Garamond({ 
  subsets: ["latin"], 
  weight: ["300", "400", "500", "600", "700"],
  variable: "--font-didot-like" 
});

const montserrat = Montserrat({ 
  subsets: ["latin"], 
  weight: ["300", "400", "500", "600", "700"],
  variable: "--font-montserrat" 
});

export const metadata: Metadata = {
  title: "GUEZS HOUSE | L'excellence Afro-Contemporaine",
  description: "Plateforme institutionnelle regroupant GUEZS Style, Immobilier et Piknik.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="fr" suppressHydrationWarning>
      <body 
        className={`${didotLike.variable} ${montserrat.variable} font-body bg-guezs-white text-guezs-black relative`}
        suppressHydrationWarning
      >
        <NoiseOverlay />
        <Navbar />
        <main>{children}</main>
        <Footer />
        <WhatsAppButton phoneNumber="237697773548" />
      </body>
    </html>
  );
}

