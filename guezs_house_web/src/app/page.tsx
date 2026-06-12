"use client";

import Hero from "@/components/modules/Hero";
import ImmobilierGrid from "@/components/modules/ImmobilierGrid";
import PiknikEvents from "@/components/modules/PiknikEvents";
import StyleLookbook from "@/components/modules/StyleLookbook";
import Investors from "@/components/modules/Investors";
import ProductCatalogue from "@/components/modules/ProductCatalogue";
import ComingSoon from "@/components/modules/ComingSoon";
import BeautyGallery from "@/components/modules/BeautyGallery";
import PromoterSection from "@/components/modules/PromoterSection";

export default function Home() {
  return (
    <main className="relative w-full min-h-screen bg-guezs-sand text-guezs-black font-body">

      <div id="about">
        <Hero />
      </div>

      <div id="promotrice">
        <PromoterSection />
      </div>

      <div className="flex flex-col space-y-12 md:space-y-16 bg-guezs-sand">
        <div id="immobilier">
          <ImmobilierGrid />
        </div>

        <div id="guezs-films">
          <ComingSoon />
        </div>

        <div id="piknik">
          <PiknikEvents />
        </div>

        <div id="beauty">
          <ProductCatalogue />
        </div>

        <div id="beauty-gallery">
          <BeautyGallery />
        </div>

        <div id="style">
          <StyleLookbook />
        </div>

        <div id="investisseurs">
          <Investors />
        </div>
      </div>
    </main>
  );
}
