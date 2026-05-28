import type { Metadata } from "next";
import LegalPage from "@/components/legal/LegalPage";
import { accountDeletionContent } from "@/components/legal/content";

export const metadata: Metadata = {
  title: "Suppression des données GUEZS Films",
  description:
    "URL publique de suppression des comptes et données liés à l'application GUEZS Films.",
};

export default function GuezsFilmsAccountDeletionPage() {
  return <LegalPage content={accountDeletionContent} />;
}
