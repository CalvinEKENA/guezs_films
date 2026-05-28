import type { Metadata } from "next";
import LegalPage from "@/components/legal/LegalPage";
import { filmsHubContent } from "@/components/legal/content";

export const metadata: Metadata = {
  title: "GUEZS Films | Support officiel",
  description:
    "Centre officiel de support, confidentialité et conformité pour l'application mobile GUEZS Films.",
};

export default function GuezsFilmsHubPage() {
  return <LegalPage content={filmsHubContent} />;
}
