import type { Metadata } from "next";
import LegalPage from "@/components/legal/LegalPage";
import { filmsHubContent } from "@/components/legal/content";

export const metadata: Metadata = {
  title: "GUEZS Films | Support officiel",
  description:
    "Accès à la plateforme GUEZS FILMS et centre officiel de support, confidentialité et conformité.",
  alternates: {
    canonical: "/guezs-films/",
  },
};

export default function GuezsFilmsHubPage() {
  return <LegalPage content={filmsHubContent} />;
}
