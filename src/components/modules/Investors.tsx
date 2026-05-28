"use client";
import { motion } from "framer-motion";
import Link from "next/link";

const PARTNERS = [
  { name: "Partenaire 1", logo: "/assets/logos/partner1.jpg" },
  { name: "Partenaire 2", logo: "/assets/logos/partner2.jpg" },
  { name: "Partenaire 3", logo: "/assets/logos/partner3.jpg" },
  { name: "Partenaire 4", logo: "/assets/logos/partner4.jpg" },
  { name: "Partenaire 5", logo: "/assets/logos/partner5.jpg" },
  { name: "Partenaire 6", logo: "/assets/logos/partner6.jpg" },
];

export default function Investors() {
  return (
    <section className="w-full relative flex flex-col justify-center overflow-hidden">
      
      {/* HEADER SECTION (Split Layout) */}
      <div className="container mx-auto px-6 md:px-12 mb-12 md:mb-16">
        <div className="flex flex-col md:flex-row relative">
          
          <div className="hidden md:block absolute left-1/2 top-4 bottom-[-60px] w-px bg-guezs-black/20 -translate-x-1/2" />

          {/* Left Column : Titles */}
          <div className="w-full md:w-1/2 md:pr-20 mb-12 md:mb-0">
             <span className="text-guezs-black/40 font-body uppercase tracking-[0.3em] text-[10px] md:text-xs mb-6 block">
               Ils nous font confiance
             </span>
             <h2 className="font-heading text-5xl md:text-7xl lg:text-8xl text-guezs-black leading-[0.9] tracking-tight">
               GUEZS
               <br/>
               <span className="italic">Invest</span>
             </h2>
          </div>

          {/* Right Column : Description */}
          <div className="w-full md:w-1/2 md:pl-20 flex flex-col justify-end">
             <p className="font-body text-guezs-black/70 text-sm md:text-base leading-relaxed mb-6 max-w-sm">
               Devenez acteur de l'excellence africaine. Rejoignez nos partenaires visionnaires et participez au rayonnement de la culture Afro-contemporaine mondiale.
             </p>
          </div>
        </div>
      </div>

      <div className="container mx-auto px-6 md:px-12 mb-16 md:mb-24">
        {/* Section Logos - Partenaires */}
        <div className="flex flex-wrap justify-center sm:justify-between items-center gap-8 md:gap-16 opacity-70 hover:opacity-100 transition-opacity duration-500">
          {PARTNERS.map((partner, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.1, duration: 0.6 }}
              className="group flex-shrink-0"
            >
              {/* Fallback box si le logo n'existe pas encore */}
              <div className="h-12 sm:h-16 md:h-20 w-32 md:w-40 border border-guezs-black/10 flex items-center justify-center grayscale group-hover:grayscale-0 transition-all duration-500">
                <span className="text-[10px] uppercase font-bold text-guezs-black/40 tracking-widest">{partner.name}</span>
              </div>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Section Investisseurs - Appel à l'action */}
      <div className="container mx-auto px-6 md:px-12">
        <motion.div 
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-50px" }}
          transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
          className="bg-[#111111] p-8 md:p-16 lg:p-24 relative overflow-hidden rounded-[40px] shadow-2xl"
        >
          {/* Fond subtil */}
          <div className="absolute inset-0 opacity-30 pointer-events-none bg-gradient-to-br from-[#D4AF37]/20 to-transparent" />
          
          {/* Cercles décoratifs */}
          <div className="absolute -top-20 -right-20 w-80 h-80 border-[1px] border-[#D4AF37]/15 rounded-full" />
          <div className="absolute -bottom-32 -left-32 w-[30rem] h-[30rem] border-[1px] border-[#D4AF37]/8 rounded-full" />
          
          <div className="relative z-10 grid grid-cols-1 md:grid-cols-2 gap-12 lg:gap-20 items-center">
            
            <div className="flex flex-col h-full justify-between">
              <div>
                <span className="text-[#D4AF37] font-body uppercase tracking-[0.3em] text-[10px] md:text-xs mb-6 block font-bold">
                  Opportunités d'Investissement
                </span>
                <h2 className="font-heading text-4xl md:text-5xl lg:text-6xl text-white mb-8 leading-tight">
                  Construisons <br className="hidden md:block"/> l'Avenir Ensemble
                </h2>
                <p className="text-white/90 font-body leading-relaxed mb-12 max-w-md text-sm md:text-base">
                  GUEZS HOUSE offre des opportunités uniques de sponsoring événementiel, de partenariats commerciaux et d'investissement direct dans l'immobilier et l'art de vivre premium.
                </p>
              </div>
              
              {/* Stats rapides */}
              <div className="grid grid-cols-3 gap-6 pt-8 border-t border-white/20">
                <div>
                  <span className="font-heading text-3xl md:text-4xl text-[#D4AF37] block mb-2">3</span>
                  <p className="text-white/80 text-[10px] uppercase tracking-widest font-bold">Pôles d'activité</p>
                </div>
                <div>
                  <span className="font-heading text-3xl md:text-4xl text-[#D4AF37] block mb-2">5+</span>
                  <p className="text-white/80 text-[10px] uppercase tracking-widest font-bold">Années d'expertise</p>
                </div>
                <div>
                  <span className="font-heading text-3xl md:text-4xl text-[#D4AF37] block mb-2">∞</span>
                  <p className="text-white/80 text-[10px] uppercase tracking-widest font-bold">Ambition</p>
                </div>
              </div>
            </div>
            
            <div className="flex flex-col justify-center space-y-6 md:pl-10">
              <motion.a 
                href="/assets/documents/deck-investisseur.pdf"
                target="_blank"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                className="flex items-center justify-between gap-4 bg-[#D4AF37] text-black font-bold py-5 px-8 rounded-full uppercase tracking-widest text-[10px] md:text-xs hover:bg-white transition-all shadow-lg group w-full"
              >
                <span>Télécharger le Pitch Deck</span>
                <span className="w-8 h-8 rounded-full bg-black/10 flex items-center justify-center group-hover:bg-black/5 transition-colors">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                  </svg>
                </span>
              </motion.a>

              <Link 
                href="/#contact"
                className="group relative overflow-hidden flex items-center justify-between gap-4 border border-white/20 text-white rounded-full py-5 px-8 uppercase tracking-widest text-[10px] md:text-xs transition-colors duration-500 hover:border-white w-full"
              >
                <div className="absolute inset-0 bg-white translate-y-[100%] group-hover:translate-y-0 transition-transform duration-500 ease-out z-0" />
                <span className="relative z-10 group-hover:text-black font-bold transition-colors">Planifier un Entretien</span>
                <span className="relative z-10 w-8 h-8 rounded-full bg-white/10 flex items-center justify-center group-hover:bg-black/10 transition-colors">
                  <svg className="w-4 h-4 group-hover:text-black" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                  </svg>
                </span>
              </Link>
              
              <p className="text-center md:text-left text-white/40 text-[10px] mt-4 uppercase tracking-widest pl-4">
                Réponse garantie sous 48h ouvrées
              </p>
            </div>

          </div>
        </motion.div>
      </div>

    </section>
  );
}
