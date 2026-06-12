"use client";
import { motion, AnimatePresence } from "framer-motion";
import { useState } from "react";
import { StyleCollection } from "@/types/style";

const COLLECTIONS: StyleCollection[] = [
  {
    id: '1',
    title: "Héritage Royal",
    year: "2026",
    description: "Une fusion entre coupes modernes et textiles traditionnels africains.",
    mainImage: "/assets/images/style-1.jpg",
    gallery: ["/assets/images/style-1.jpg", "/assets/images/s1-1.jpg", "/assets/images/s1-2.jpg"],
    category: 'Afro GUEZS Style'
  },
  {
    id: '2',
    title: "Urban GUEZS",
    year: "2026",
    description: "Le lifestyle urbain sublimé par l'élégance contemporaine.",
    mainImage: "/assets/images/style-2.jpg",
    gallery: ["/assets/images/style-2.jpg", "/assets/images/s2-1.jpg", "/assets/images/s2-2.jpg"],
    category: 'GUEZS Style'
  },
  {
    id: 'vette-gallery',
    title: "Collection Signature",
    year: "2026",
    description: "La fondatrice elle-même met en lumière la vision GUEZS au travers de notre collection signature.",
    mainImage: "/assets/images/Yvette4.jpg",
    gallery: ["/assets/images/Yvette4.jpg", "/assets/images/Yvette5.jpg", "/assets/images/Yvette6.jpg"],
    category: 'Afro GUEZS Style'
  },
  {
    id: '3',
    title: "Terre d'Or",
    year: "2025",
    description: "Hommage aux terres africaines à travers des teintes chaudes et dorées.",
    mainImage: "/assets/images/style-3.jpg",
    gallery: ["/assets/images/style-3.jpg", "/assets/images/s3-1.jpg", "/assets/images/s3-2.jpg"],
    category: 'Afro GUEZS Style'
  },
  {
    id: '4',
    title: "Nuit de Gala",
    year: "2025",
    description: "L'élégance nocturne redéfinie avec des coupes sculpturales.",
    mainImage: "/assets/images/style-4.jpg",
    gallery: ["/assets/images/style-4.jpg", "/assets/images/s4-1.jpg", "/assets/images/s4-2.jpg"],
    category: 'GUEZS Style'
  }
];

export default function StyleLookbook() {
  const [selectedCollection, setSelectedCollection] = useState<StyleCollection | null>(null);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  const openGallery = (collection: StyleCollection) => {
    setSelectedCollection(collection);
    setCurrentImageIndex(0);
  };

  const closeGallery = () => {
    setSelectedCollection(null);
    setCurrentImageIndex(0);
  };

  const nextImage = () => {
    if (selectedCollection) {
      setCurrentImageIndex((prev) =>
        prev === selectedCollection.gallery.length - 1 ? 0 : prev + 1
      );
    }
  };

  const prevImage = () => {
    if (selectedCollection) {
      setCurrentImageIndex((prev) =>
        prev === 0 ? selectedCollection.gallery.length - 1 : prev - 1
      );
    }
  };

  return (
    <>
      <section className="w-full relative flex flex-col justify-center overflow-hidden">

        {/* HEADER SECTION (Split Layout) */}
        <div className="container mx-auto px-6 md:px-12 mb-12 md:mb-16">
          <div className="flex flex-col md:flex-row relative">

            <div className="hidden md:block absolute left-1/2 top-4 bottom-[-60px] w-px bg-guezs-black/20 -translate-x-1/2" />

            {/* Left Column : Titles */}
            <div className="w-full md:w-1/2 md:pr-20 mb-12 md:mb-0">
               <span className="text-guezs-black/40 font-body uppercase tracking-[0.3em] text-[10px] md:text-xs mb-6 block">
                 MODE & IDENTITÉ
               </span>
               <h2 className="font-heading text-5xl md:text-7xl lg:text-8xl text-guezs-black leading-[0.9] tracking-tight">
                 Afro GUEZS
                 <br/>
                 <span className="italic">Style</span>
               </h2>
            </div>

            {/* Right Column : Description & Actions */}
            <div className="w-full md:w-1/2 md:pl-20 flex flex-col justify-end">
               <p className="font-body text-guezs-black/70 text-sm md:text-base leading-relaxed mb-6 max-w-sm">
                 Vision • Valeurs • Créations Artistiques. Un lookbook qui célèbre nos racines et sculpte l'avenir de l'élégance.
               </p>

               {/* Navigation rapide & Indicateur de scroll */}
               <div className="flex items-center gap-4 mt-6">
                 <div className="flex items-center gap-3 text-guezs-black/50 group">
                   <span className="text-[10px] md:text-xs uppercase tracking-[0.2em] font-bold">Faire défiler</span>
                   <motion.div
                     animate={{ x: [0, 10, 0] }}
                     transition={{ repeat: Infinity, duration: 1.5, ease: "easeInOut" }}
                     className="flex items-center"
                   >
                     <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                       <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3" />
                     </svg>
                   </motion.div>
                 </div>
               </div>
            </div>
          </div>
        </div>

        {/* Lookbook Horizontal Scroll */}
        <div className="flex space-x-6 md:space-x-10 px-6 md:px-12 overflow-x-auto hide-scrollbar pb-10 cursor-grab active:cursor-grabbing scroll-smooth">
          {COLLECTIONS.map((item, index) => (
            <motion.div
              key={item.id}
              initial={{ opacity: 0, x: 50 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.8, delay: index * 0.1 }}
              className="min-w-[85vw] md:min-w-[45vw] lg:min-w-[35vw] group relative flex-shrink-0"
            >
              <div className="relative h-[550px] md:h-[650px] w-full rounded-[40px] overflow-hidden bg-black/5">
                <img
                  src={item.mainImage}
                  alt={item.title}
                  className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-105"
                />

                {/* Overlay gradient */}
                <div className="absolute inset-0 bg-gradient-to-t from-guezs-black/90 via-guezs-black/20 to-transparent group-hover:from-guezs-black transition-all duration-500" />

                {/* Badge } */}
                <div className="absolute top-8 left-8 bg-white/90 backdrop-blur-sm text-guezs-black px-4 py-2 text-[10px] font-bold uppercase tracking-widest rounded-full">
                  {item.category}
                </div>

                {/* Numéro } */}
                <div className="absolute top-8 right-8 font-heading text-4xl text-white/50">
                  {String(index + 1).padStart(2, '0')}
                </div>

                {/* Overlay Texte */}
                <div className="absolute bottom-0 left-0 right-0 p-8 md:p-12 text-white">
                  <span className="text-guezs-gold text-[10px] md:text-xs font-bold uppercase tracking-[0.3em] mb-3 block">
                    Collection {item.year}
                  </span>
                  <h3 className="font-heading text-4xl md:text-5xl mb-4 group-hover:text-guezs-gold transition-colors duration-300">
                    {item.title}
                  </h3>
                  <p className="text-white/70 text-sm max-w-sm mb-8 leading-relaxed">
                    {item.description}
                  </p>

                  <div className="flex items-center gap-4">
                    <button
                      onClick={() => openGallery(item)}
                      className="px-6 py-3 bg-guezs-gold text-black text-[10px] font-bold uppercase tracking-[0.2em] hover:bg-white rounded-full transition-colors cursor-pointer"
                    >
                      Voir Collection
                    </button>
                    <button
                      onClick={() => openGallery(item)}
                      className="flex items-center gap-2 text-[10px] uppercase tracking-widest px-6 py-3 border border-white/30 rounded-full text-white hover:border-white transition-colors cursor-pointer"
                    >
                      <span>Galerie</span>
                      <span className="text-white/60">({item.gallery.length})</span>
                    </button>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}

          {/* Card finale - CTA */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="min-w-[85vw] md:min-w-[45vw] lg:min-w-[35vw] flex-shrink-0 h-[550px] md:h-[650px] border border-guezs-black/10 rounded-[40px] flex items-center justify-center bg-white shadow-sm"
          >
            <div className="text-center p-12">
              <div className="w-20 h-20 border border-guezs-black/20 rounded-full flex flex-col items-center justify-center mx-auto mb-8 text-guezs-gold">
                <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                </svg>
              </div>
              <h3 className="font-heading text-3xl text-guezs-black mb-4">Toutes les Collections</h3>
              <p className="text-guezs-black/50 font-body text-sm mb-10 max-w-xs mx-auto leading-relaxed">
                Explorez l'ensemble de nos créations et plongez dans notre univers mode chic et contemporain.
              </p>
              <button className="px-8 py-4 bg-guezs-black text-white text-[10px] uppercase tracking-[0.2em] font-medium rounded-full hover:bg-guezs-gold transition-all shadow-md">
                Voir le Lookbook Complet
              </button>
            </div>
          </motion.div>
        </div>

        {/* Indicateur de collections */}
        <div className="container mx-auto px-6 md:px-12 mt-12 flex justify-end">
          <span className="text-[10px] md:text-xs text-guezs-black/40 font-bold uppercase tracking-[0.3em]">
            {COLLECTIONS.length} Collections Disponibles
          </span>
        </div>
      </section>

      {/* Modal Lightbox */}
      <AnimatePresence>
        {selectedCollection && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[200] bg-white/95 backdrop-blur-md flex flex-col items-center justify-center"
            onClick={closeGallery}
          >
            {/* Bouton Fermer */}
            <button
              onClick={closeGallery}
              className="absolute top-8 right-8 text-guezs-black/40 hover:text-guezs-gold transition-colors z-10"
            >
              <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>

            {/* Infos Collection */}
            <div className="absolute top-8 left-8 text-guezs-black z-10 hidden md:block">
              <span className="text-guezs-gold text-[10px] font-bold uppercase tracking-[0.3em] block mb-2">
                {selectedCollection.category}
              </span>
              <h3 className="font-heading text-4xl">{selectedCollection.title}</h3>
            </div>

            {/* Navigation Précédent */}
            <button
              onClick={(e) => { e.stopPropagation(); prevImage(); }}
              className="absolute left-4 md:left-12 top-1/2 -translate-y-1/2 w-12 h-12 rounded-full border border-guezs-black/20 flex items-center justify-center text-guezs-black hover:bg-guezs-black hover:text-white hover:border-guezs-black transition-all z-10 bg-white shadow-sm"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M15 19l-7-7 7-7" />
              </svg>
            </button>

            {/* Image Principale */}
            <motion.div
              key={currentImageIndex}
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              transition={{ duration: 0.3 }}
              className="w-full max-w-4xl h-[70vh] flex items-center justify-center px-4 md:px-32"
              onClick={(e) => e.stopPropagation()}
            >
              <img
                src={selectedCollection.gallery[currentImageIndex]}
                alt={`${selectedCollection.title} - Image ${currentImageIndex + 1}`}
                className="max-w-full max-h-full object-contain drop-shadow-2xl rounded-2xl"
              />
            </motion.div>

            {/* Navigation Suivant */}
            <button
              onClick={(e) => { e.stopPropagation(); nextImage(); }}
              className="absolute right-4 md:right-12 top-1/2 -translate-y-1/2 w-12 h-12 rounded-full border border-guezs-black/20 flex items-center justify-center text-guezs-black hover:bg-guezs-black hover:text-white hover:border-guezs-black transition-all z-10 bg-white shadow-sm"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M9 5l7 7-7 7" />
              </svg>
            </button>

            {/* Indicateur d'images et Compteur combinés */}
            <div className="absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-4">
               <div className="text-guezs-black/50 text-sm font-heading">
                 <span className="text-guezs-black text-xl">{currentImageIndex + 1}</span>
                 <span className="mx-2">/</span>
                 <span>{selectedCollection.gallery.length}</span>
               </div>
               <div className="flex items-center gap-3">
                 {selectedCollection.gallery.map((_, idx) => (
                   <button
                     key={idx}
                     onClick={(e) => { e.stopPropagation(); setCurrentImageIndex(idx); }}
                     className={`h-2 rounded-full transition-all ${
                       idx === currentImageIndex
                         ? 'bg-guezs-gold w-8'
                         : 'bg-guezs-black/20 w-2 hover:bg-guezs-black/40'
                     }`}
                   />
                 ))}
               </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
