"use client";
import { motion } from "framer-motion";

const BEAUTY_ASSETS = [
  { id: 1, src: "/assets/images/beauty_product1.jpeg", title: "Rituel Éclat" },
  { id: 2, src: "/assets/images/beauty_product2.jpeg", title: "Sérum Précieux" },
  { id: 3, src: "/assets/images/beauty_product3.jpeg", title: "Essence Florale" },
  { id: 4, src: "/assets/images/beauty_product4.jpeg", title: "Nuage de Karité" },
  { id: 5, src: "/assets/images/beauty_product5.jpeg", title: "Élixir Nuit" },
  { id: 6, src: "/assets/images/beauty_product6.jpeg", title: "Gamme Diamond" },
  { id: 7, src: "/assets/images/beauty_product7.jpeg", title: "Poudre de Soie" },
  { id: 8, src: "/assets/images/beauty_product8.jpeg", title: "Regard Intense" },
  { id: 9, src: "/assets/images/beauty_product9.jpeg", title: "Slim GUEZS Thé" },
  { id: 10, src: "/assets/images/beauty_product10.jpeg", title: "Hydra-Gold" },
  { id: 11, src: "/assets/images/beauty_product11.jpeg", title: "Baume Royal" },
  { id: 12, src: "/assets/images/beauty_product12.jpeg", title: "Gommage Divin" },
  { id: 13, src: "/assets/images/beauty_product13.jpeg", title: "Coffret Prestige" },
  { id: 14, src: "/assets/images/beauty_product14.jpeg", title: "Huile Sèche" },
  { id: 15, src: "/assets/images/beauty_product15.jpeg", title: "Signature GUEZS" },
];

export default function BeautyGallery() {
  return (
    <section className="w-full relative flex flex-col justify-center overflow-hidden pb-24 md:pb-32">
      
      {/* HEADER SECTION (Split Layout) */}
      <div className="container mx-auto px-6 md:px-12 mb-12 md:mb-16">
        <div className="flex flex-col md:flex-row relative">
          
          <div className="hidden md:block absolute left-1/2 top-4 bottom-[-60px] w-px bg-guezs-black/20 -translate-x-1/2" />

          {/* Left Column : Titles */}
          <div className="w-full md:w-1/2 md:pr-20 mb-12 md:mb-0">
             <span className="text-guezs-black/40 font-body uppercase tracking-[0.3em] text-[10px] md:text-xs mb-6 block">
               Galerie Beauté
             </span>
             <h2 className="font-heading text-5xl md:text-7xl lg:text-8xl text-guezs-black leading-[0.9] tracking-tight">
               L'Art de <br/> la Beauté
               <br/>
               <span className="italic">GUEZS</span>
             </h2>
          </div>

          {/* Right Column : Description */}
          <div className="w-full md:w-1/2 md:pl-20 flex flex-col justify-end">
             <p className="font-body text-guezs-black/70 text-sm md:text-base leading-relaxed mb-6 max-w-sm">
               Plongez dans l'univers visuel de nos cosmétiques premium. Une symphonie de textures et de couleurs célébrant le bien-être et l'identité Afro-contemporaine.
             </p>
             <p className="font-body text-[10px] md:text-xs font-bold uppercase tracking-widest text-guezs-black/40 mt-4">
               Cosmétique & Bien-Être
             </p>
          </div>
        </div>
      </div>

      <div className="container mx-auto px-6 md:px-12">
        {/* Grille Immersive Masonry */}
        <div className="columns-1 md:columns-2 lg:columns-3 gap-6 md:gap-8 space-y-6 md:space-y-8">
          {BEAUTY_ASSETS.map((asset, index) => (
            <motion.div
              key={asset.id}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.6, delay: (index % 3) * 0.1, ease: [0.22, 1, 0.36, 1] }}
              className="relative group cursor-pointer overflow-hidden rounded-[40px] break-inside-avoid bg-black/5 shadow-sm border border-black/5"
            >
              <div className="relative w-full overflow-hidden">
                <img 
                  src={asset.src} 
                  alt={asset.title}
                  className="w-full h-auto object-cover transition-transform duration-1000 group-hover:scale-110 will-change-transform"
                  loading="lazy"
                />
                
                {/* Overlay au Hover */}
                <div className="absolute inset-0 bg-guezs-black/40 backdrop-blur-sm opacity-0 group-hover:opacity-100 transition-all duration-500 flex items-center justify-center">
                  <div className="text-center p-8 transform translate-y-4 group-hover:translate-y-0 transition-transform duration-500">
                    <p className="text-white/60 font-body text-[10px] uppercase tracking-[0.2em] mb-3 font-bold">Découvrir</p>
                    <h3 className="text-white font-heading text-2xl md:text-3xl tracking-wide">{asset.title}</h3>
                    <div className="w-12 h-[1px] bg-white/50 mx-auto mt-6 scale-x-0 group-hover:scale-x-100 transition-transform duration-700 delay-100"></div>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Bouton Voir Plus */}
        <div className="flex justify-center mt-20 md:mt-24">
          <button className="px-10 py-5 bg-white border border-[#333333] rounded-full text-[#333333] font-medium uppercase tracking-[0.2em] text-[10px] md:text-xs hover:bg-[#333333] hover:text-white transition-all duration-300 shadow-md">
            Explorer toute la galerie
          </button>
        </div>
      </div>
    </section>
  );
}
