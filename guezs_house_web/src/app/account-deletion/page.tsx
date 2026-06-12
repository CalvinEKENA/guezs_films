import type { Metadata } from "next";
import LegalPage from "@/components/legal/LegalPage";
import { accountDeletionContent } from "@/components/legal/content";

export const metadata: Metadata = {
  title: "Suppression des données | GUEZS HOUSE",
  description:
    "Procédure publique de suppression des comptes et données liés à GUEZS Films.",
};

export default function AccountDeletionPage() {
  return <LegalPage content={accountDeletionContent} />;
}
