import type { Metadata } from "next";
import LegalPage from "@/components/legal/LegalPage";
import { filmsCguContent } from "@/components/legal/content";

export const metadata: Metadata = {
  title: "CGU GUEZS Films",
  description:
    "Conditions d'utilisation publiques de l'application mobile GUEZS Films.",
};

export default function GuezsFilmsCguPage() {
  return <LegalPage content={filmsCguContent} />;
}
