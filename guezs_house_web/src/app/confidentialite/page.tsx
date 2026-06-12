import type { Metadata } from "next";
import LegalPage from "@/components/legal/LegalPage";
import { sitePrivacyContent } from "@/components/legal/content";

export const metadata: Metadata = {
  title: "Confidentialité | GUEZS HOUSE",
  description:
    "Politique de confidentialité du site GUEZS HOUSE et des parcours associés à GUEZS Films.",
};

export default function ConfidentialitePage() {
  return <LegalPage content={sitePrivacyContent} />;
}
