import type { Metadata } from "next";
import LegalPage from "@/components/legal/LegalPage";
import { siteCguContent } from "@/components/legal/content";

export const metadata: Metadata = {
  title: "CGU | GUEZS HOUSE",
  description:
    "Conditions générales d'utilisation du site GUEZS HOUSE et de ses formulaires publics.",
};

export default function CguPage() {
  return <LegalPage content={siteCguContent} />;
}
