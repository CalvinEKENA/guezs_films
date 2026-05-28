import type { Metadata } from "next";
import LegalPage from "@/components/legal/LegalPage";
import { filmsPrivacyContent } from "@/components/legal/content";

export const metadata: Metadata = {
  title: "Politique de confidentialité GUEZS Films",
  description:
    "Politique de confidentialité publique de l'application mobile GUEZS Films.",
};

export default function GuezsFilmsPrivacyPage() {
  return <LegalPage content={filmsPrivacyContent} />;
}
