import type { Metadata } from "next";
import LegalPage from "@/components/legal/LegalPage";
import { legalMentionsContent } from "@/components/legal/content";

export const metadata: Metadata = {
  title: "Mentions légales | GUEZS HOUSE",
  description:
    "Informations légales relatives au site GUEZS HOUSE et à la section GUEZS Films.",
};

export default function MentionsLegalesPage() {
  return <LegalPage content={legalMentionsContent} />;
}
