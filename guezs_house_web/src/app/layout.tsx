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
  metadataBase: new URL("https://guezs-house.com"),
  title: {
    default: "GUEZS HOUSE | L'excellence Afro-Contemporaine",
    template: "%s | GUEZS HOUSE",
  },
  description:
    "Plateforme institutionnelle regroupant GUEZS Films, Style, Immobilier, Beauté et Piknik.",
  alternates: {
    canonical: "/",
  },
  openGraph: {
    type: "website",
    locale: "fr_FR",
    url: "/",
    siteName: "GUEZS HOUSE",
    title: "GUEZS HOUSE | L'excellence Afro-Contemporaine",
    description:
      "Découvrez l'univers GUEZS HOUSE et accédez à GUEZS FILMS, sa plateforme cinéma dédiée.",
  },
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
