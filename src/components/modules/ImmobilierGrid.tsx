"use client";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Property } from "@/types/immobilier";
import Link from "next/link";

const PROPERTIES: Property[] = [
  { 
    id: '7', 
    title: "Triplex Hyper Chic & Luxueux", 
    location: "Febe Village, Yaoundé", 
    price: 550000000, 
    type: 'Vente', 
    surface: 800, 
    bedrooms: 6, 
    image: "/assets/images/triplex_garden.jpg", 
    category: 'Luxe' 
  },
  { 
    id: '1', 
    title: "Villa Horizon", 
    location: "Bastos, Yaoundé", 
    price: 250000000, 
    type: 'Vente', 
    surface: 450, 
    bedrooms: 5, 
    image: "/assets/images/villa1.jpg", 
    category: 'Luxe' 
  },
  { 
    id: '2', 
    title: "Appartement Chic", 
    location: "Bonapriso, Douala", 
    price: 800000, 
    type: 'Location', 
    surface: 120, 
    bedrooms: 2, 
    image: "/assets/images/appat1.jpg", 
    category: 'Business' 
  },
  { 
    id: '3', 
    title: "Résidence Émeraude", 
    location: "Bonanjo, Douala", 
    price: 175000000, 
    type: 'Promotion', 
    surface: 280, 
    bedrooms: 4, 
    image: "/assets/images/residence1.jpg", 
    category: 'Luxe' 
  },
  { 
    id: '4', 
    title: "Studio Moderne", 
    location: "Akwa, Douala", 
    price: 350000, 
    type: 'Location', 
    surface: 45, 
    bedrooms: 1, 
    image: "/assets/images/studio1.jpg", 
    category: 'Standard' 
  },
  { 
    id: '5', 
    title: "Duplex Prestige", 
    location: "Omnisport, Yaoundé", 
    price: 95000000, 
    type: 'Vente', 
    surface: 200, 
    bedrooms: 3, 
    image: "/assets/images/duplex1.jpg", 
    category: 'Luxe' 
  },
  { 
    id: '6', 
    title: "Bureau Standing", 
    location: "Centre-ville, Douala", 
    price: 1500000, 
    type: 'Location', 
    surface: 180, 
    bedrooms: 0, 
    image: "/assets/images/bureau1.jpg", 
    category: 'Business' 
  },
];

export default function ImmobilierGrid() {
  const [filter, setFilter] = useState('Tous');

  const filteredProperties = filter === 'Tous' 
    ? PROPERTIES 
    : PROPERTIES.filter(p => p.type === filter);

  return (
    <section className="w-full relative flex flex-col justify-center">
      
      {/* HEADER SECTION (Split Layout) */}
      <div className="container mx-auto px-6 md:px-12 mb-12 md:mb-16">
        <div className="flex flex-col md:flex-row relative">
          
          {/* Ligne verticale de séparation (Volta Skai signature) */}
          <div className="hidden md:block absolute left-1/2 top-4 bottom-[-60px] w-px bg-guezs-black/20 -translate-x-1/2" />

          {/* Left Column : Titles */}
          <div className="w-full md:w-1/2 md:pr-20 mb-12 md:mb-0">
             <span className="text-guezs-black/40 font-body uppercase tracking-[0.3em] text-[10px] md:text-xs mb-6 block">
               IMMOBILIER D'EXCEPTION
             </span>
             <h2 className="font-heading text-5xl md:text-7xl lg:text-8xl text-guezs-black leading-[0.9] tracking-tight">
               Patrimoine
               <br/>
               <span className="italic">GUEZS</span>
             </h2>
          </div>

          {/* Right Column : Description & Actions */}
          <div className="w-full md:w-1/2 md:pl-20 flex flex-col justify-end">
             <p className="font-body text-guezs-black/70 text-sm md:text-base leading-relaxed mb-12 max-w-sm">
               Découvrez une sélection exclusive de résidences, appartements et bureaux haut de gamme, conçus pour allier confort absolu et prestige.
             </p>
             
             {/* Filtres Alignés à Gauche */}
             <div className="flex space-x-6 md:space-x-8 border-b border-guezs-black/10 pb-4 overflow-x-auto hide-scrollbar w-full sm:w-max">
                {['Tous', 'Vente', 'Location', 'Promotion'].map((cat) => (
                  <button 
                    key={cat}
                    onClick={() => setFilter(cat)}
                    className={`relative text-[10px] md:text-xs uppercase tracking-[0.2em] transition-all pb-1 ${
                      filter === cat 
                        ? 'text-guezs-gold font-bold' 
                        : 'text-guezs-black/40 hover:text-guezs-black'
                    }`}
                  >
                    {cat}
                    {filter === cat && (
                      <motion.div 
                        layoutId="filterIndicator"
                        className="absolute -bottom-4 left-0 right-0 h-px bg-guezs-gold"
                      />
                    )}
                  </button>
                ))}
             </div>
          </div>
        </div>
      </div>

      {/* GRID SECTION */}
      <div className="container mx-auto px-6 md:px-12">
        <motion.div layout className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-10 md:gap-x-16 md:gap-y-20">
          <AnimatePresence mode="popLayout">
            {filteredProperties.map((property) => {
              const propertyLink = property.id === '7' 
                ? '/immobilier/triplex-chic' 
                : property.id === '3' 
                ? '/immobilier/immo_property_3' 
                : '/#contact';

              return (
                <motion.div
                  layout
                  initial={{ opacity: 0, y: 40 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                  transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
                  key={property.id}
                  className="group cursor-pointer flex flex-col"
                >
                  <Link href={propertyLink} className="flex flex-col h-full w-full">
                    {/* Image Container with 40px radius */}
                    <div className="relative w-full aspect-[4/3] rounded-[40px] overflow-hidden mb-8 bg-black/5">
                      <img 
                        src={property.image} 
                        className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-105" 
                        alt={property.title}
                      />
                      
                      {/* Overlay au hover */}
                      <div className="absolute inset-0 bg-guezs-black/0 group-hover:bg-guezs-black/20 transition-all duration-500" />
                      
                      {/* Badges */}
                      <div className="absolute top-6 left-6 flex gap-3">
                        <div className="bg-white/90 backdrop-blur-sm text-guezs-black px-4 py-2 text-[10px] uppercase tracking-widest rounded-full font-medium">
                          {property.type}
                        </div>
                        <div className="bg-guezs-gold text-white px-4 py-2 text-[10px] uppercase tracking-widest rounded-full font-medium shadow-sm">
                          {property.category}
                        </div>
                      </div>
                    </div>

                    {/* Infos textuelles */}
                    <div className="px-2 flex-grow">
                      <div className="flex justify-between items-start mb-3">
                        <h3 className="font-heading text-2xl md:text-3xl text-guezs-black group-hover:text-guezs-gold transition-colors">
                          {property.title}
                        </h3>
                        <p className="font-body text-guezs-gold font-medium text-lg md:text-xl">
                          {property.price.toLocaleString('fr-FR')} FCFA
                        </p>
                      </div>

                      <p className="text-guezs-black/50 font-body text-xs md:text-sm uppercase tracking-widest mb-6">
                        {property.location}
                      </p>

                      <div className="flex gap-6 text-xs md:text-sm font-body text-guezs-black/60 pt-4 border-t border-guezs-black/10">
                        <span className="flex items-center gap-2">
                          <span className="w-1.5 h-1.5 rounded-full bg-guezs-gold"></span>
                          {property.surface} m²
                        </span>
                        {property.bedrooms > 0 && (
                          <span className="flex items-center gap-2">
                            <span className="w-1.5 h-1.5 rounded-full bg-guezs-gold"></span>
                            {property.bedrooms} Chambres
                          </span>
                        )}
                      </div>
                    </div>
                  </Link>
                </motion.div>
              );
            })}
          </AnimatePresence>
        </motion.div>

        {/* Bouton Voir Plus */}
        <div className="w-full flex justify-center mt-24">
          <button className="px-10 py-4 rounded-full border border-[#333333] text-[#333333] text-[10px] md:text-xs font-medium uppercase tracking-[0.2em] hover:bg-[#333333] hover:text-white transition-all duration-300">
            Découvrir tous nos biens
          </button>
        </div>
      </div>
    </section>
  );
}
