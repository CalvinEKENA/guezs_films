"use client";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Image from "next/image";
import ContactForm from "@/components/shared/ContactForm";
import {
  Building2,
  Maximize2,
  BedDouble,
  Bath,
  MapPin,
  Phone,
  Calendar,
  Compass,
  ArrowRight,
  ShieldCheck,
  ChevronLeft,
  ChevronRight,
  X,
  Volume2
} from "lucide-react";

// List of professional luxury images we copied
const GALLERY = [
  {
    url: "/assets/images/triplex_garden.jpg",
    title: "Le Jardin & Façade Principale",
    desc: "Un somptueux espace vert paysager agrémenté d'arbres d'ornement et de fleurs délicates."
  },
  {
    url: "/assets/images/triplex_entrance.jpg",
    title: "Entrée Colonnade",
    desc: "Une entrée majestueuse aux colonnes blanches impériales, ouvrant sur un sol en grès raffiné."
  },
  {
    url: "/assets/images/triplex_night.png",
    title: "Façade Extérieure de Nuit",
    desc: "Une mise en lumière nocturne haut de gamme révélant l'architecture contemporaine de la résidence."
  },
  {
    url: "/assets/images/triplex_bathroom.jpg",
    title: "Salle de Bain Royale",
    desc: "Finitions en grès gris noble, double vasque, verrière de douche italienne et plafond en teck chaleureux."
  },
  {
    url: "/assets/images/triplex_bedroom.jpg",
    title: "Chambre & Dressing",
    desc: "Des espaces de rangement intégrés blancs épurés mariés à un magnifique plafond lambrissé."
  }
];

export default function TriplexChicDetail() {
  const [activeImgIndex, setActiveImgIndex] = useState(0);
  const [fullscreenOpen, setFullscreenOpen] = useState(false);
  const [activeTab, setActiveTab] = useState("all");

  const nextImage = () => {
    setActiveImgIndex((prev) => (prev + 1) % GALLERY.length);
  };

  const prevImage = () => {
    setActiveImgIndex((prev) => (prev - 1 + GALLERY.length) % GALLERY.length);
  };

  const levels = [
    {
      id: "all",
      label: "Tout voir"
    },
    {
      id: "soussol",
      label: "Sous-sol",
      details: ["Buanderie équipée", "1 Chambre de service", "Toilette privée"]
    },
    {
      id: "rdc",
      label: "Rez-de-chaussée",
      details: [
        "1 Vaste Salon d'honneur baigné de lumière",
        "1 Salle à manger de prestige",
        "1 Suite d'invités climatisée",
        "1 Cuisine gastronomique entièrement aménagée",
        "2 Douches haut de gamme"
      ]
    },
    {
      id: "etage",
      label: "Étage VIP",
      details: [
        "3 Chambres majestueuses avec rangements intégrés",
        "3 Salles de bain en suite au style contemporain",
        "2 Balcons offrant une vue panoramique imprenable"
      ]
    },
    {
      id: "dependance",
      label: "Dépendance",
      details: [
        "Salon indépendant en étage",
        "2 Chambres spacieuses",
        "2 Douches modernes",
        "1 Cuisine aménagée"
      ]
    },
    {
      id: "exterieur",
      label: "Extérieur & Jardin",
      details: [
        "Beau jardin paysager fleuri avec pelouse soignée",
        "Parking sécurisé pouvant accueillir plusieurs véhicules",
        "Cour entièrement clôturée et sécurisée"
      ]
    }
  ];

  return (
    <main className="bg-guezs-sand min-h-screen pt-32 pb-20 font-body relative overflow-hidden">
      {/* Background gradients for VIP luxury depth */}
      <div className="absolute top-0 left-0 w-full h-[600px] bg-gradient-to-b from-[#003366]/5 via-[#D4AF37]/3 to-transparent pointer-events-none" />
      <div className="absolute top-[800px] right-0 w-[500px] h-[500px] bg-gradient-to-tr from-[#D4AF37]/5 to-transparent blur-[120px] pointer-events-none rounded-full" />
      <div className="absolute bottom-[300px] left-0 w-[500px] h-[500px] bg-gradient-to-br from-[#003366]/5 to-transparent blur-[120px] pointer-events-none rounded-full" />

      <div className="container mx-auto px-6 max-w-7xl relative z-10">

        {/* BREADCRUMB & BACK BUTTON */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.6 }}
          className="mb-8"
        >
          <a
            href="/#immobilier"
            className="group inline-flex items-center gap-3 text-xs uppercase tracking-[0.2em] text-guezs-black/60 hover:text-guezs-gold transition-colors duration-300"
          >
            <ChevronLeft className="w-4 h-4 transition-transform group-hover:-translate-x-1" />
            Retour aux biens d'exception
          </a>
        </motion.div>

        {/* HERO TITLE & PRICE */}
        <div className="flex flex-col lg:flex-row lg:justify-between lg:items-end gap-6 mb-12">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
          >
            <div className="flex items-center gap-3 mb-4">
              <span className="bg-gradient-to-r from-guezs-blue to-guezs-gold text-white px-4 py-1.5 text-[10px] uppercase tracking-[0.25em] rounded-full font-bold shadow-md">
                VIP / EXCLUSIVITÉ GUEZS
              </span>
              <span className="bg-white/80 border border-guezs-gold/20 text-guezs-gold px-4 py-1.5 text-[10px] uppercase tracking-[0.25em] rounded-full font-semibold">
                Vente
              </span>
            </div>
            <h1 className="font-heading text-4xl md:text-5xl lg:text-6xl text-guezs-black leading-tight tracking-tight">
              Triplex Hyper Chic
              <br/>
              <span className="italic font-light text-guezs-gold">et Luxueux</span>
            </h1>
            <p className="text-guezs-black/60 text-sm md:text-base mt-4 flex items-center gap-2 font-medium">
              <MapPin className="w-4 h-4 text-guezs-gold" />
              Cameroun : Yaoundé, Febe Village, Zone Résidentielle
            </p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.1, ease: [0.16, 1, 0.3, 1] }}
            className="lg:text-right"
          >
            <span className="text-[10px] md:text-xs uppercase tracking-[0.3em] text-guezs-black/40 block mb-2">Prix d'exception</span>
            <p className="text-4xl md:text-5xl font-heading text-guezs-gold font-bold">
              550 000 000 <span className="text-2xl font-body font-medium">FCFA</span>
            </p>
            <span className="text-xs italic text-guezs-black/50 mt-1 block">Légèrement discutable</span>
          </motion.div>
        </div>

        {/* INTERACTIVE GALLERY & SPECS CARD GRID */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-12 mb-24">

          {/* LEFT: GALLERY CAROUSEL (SPAN 2) */}
          <motion.div
            initial={{ opacity: 0, scale: 0.98 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="lg:col-span-2 flex flex-col gap-6"
          >
            <div className="relative aspect-[16/10] w-full rounded-[40px] overflow-hidden shadow-2xl group/gallery bg-guezs-black">
              {/* Active Image */}
              <AnimatePresence mode="wait">
                <motion.div
                  key={activeImgIndex}
                  initial={{ opacity: 0, scale: 1.05 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0 }}
                  transition={{ duration: 0.7 }}
                  className="absolute inset-0 cursor-pointer"
                  onClick={() => setFullscreenOpen(true)}
                >
                  <Image
                    src={GALLERY[activeImgIndex].url}
                    alt={GALLERY[activeImgIndex].title}
                    fill
                    className="object-cover transition-transform duration-[2000ms] hover:scale-105"
                    priority
                  />
                  {/* Subtle Gradient Overlay */}
                  <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/10 to-transparent" />
                </motion.div>
              </AnimatePresence>

              {/* Navigation Arrows */}
              <button
                onClick={prevImage}
                className="absolute left-6 top-1/2 -translate-y-1/2 w-12 h-12 rounded-full bg-white/10 backdrop-blur-md text-white flex items-center justify-center hover:bg-white hover:text-guezs-black transition-all duration-300"
              >
                <ChevronLeft className="w-6 h-6" />
              </button>
              <button
                onClick={nextImage}
                className="absolute right-6 top-1/2 -translate-y-1/2 w-12 h-12 rounded-full bg-white/10 backdrop-blur-md text-white flex items-center justify-center hover:bg-white hover:text-guezs-black transition-all duration-300"
              >
                <ChevronRight className="w-6 h-6" />
              </button>

              {/* Image Title / Indicator Bar */}
              <div className="absolute bottom-8 left-8 right-8 flex justify-between items-end text-white z-10 pointer-events-none">
                <div>
                  <h3 className="font-heading text-lg md:text-xl font-medium tracking-wide">
                    {GALLERY[activeImgIndex].title}
                  </h3>
                  <p className="text-xs text-white/70 mt-1 max-w-md hidden md:block">
                    {GALLERY[activeImgIndex].desc}
                  </p>
                </div>
                <div className="bg-black/40 backdrop-blur-md px-4 py-2 rounded-full text-xs font-semibold tracking-wider">
                  {activeImgIndex + 1} / {GALLERY.length}
                </div>
              </div>

              {/* Fullscreen Button */}
              <button
                onClick={() => setFullscreenOpen(true)}
                className="absolute top-6 right-6 w-10 h-10 rounded-full bg-black/40 backdrop-blur-md text-white flex items-center justify-center hover:bg-white hover:text-guezs-black transition-all duration-300"
                title="Plein écran"
              >
                <Maximize2 className="w-4 h-4" />
              </button>
            </div>

            {/* Thumbnail Navigation */}
            <div className="flex gap-4 overflow-x-auto hide-scrollbar py-2">
              {GALLERY.map((img, index) => (
                <button
                  key={index}
                  onClick={() => setActiveImgIndex(index)}
                  className={`relative flex-shrink-0 w-24 md:w-32 aspect-video rounded-2xl overflow-hidden transition-all duration-300 border-2 ${
                    activeImgIndex === index
                      ? "border-guezs-gold scale-105 shadow-md"
                      : "border-transparent opacity-60 hover:opacity-100"
                  }`}
                >
                  <Image
                    src={img.url}
                    alt={img.title}
                    fill
                    className="object-cover"
                  />
                </button>
              ))}
            </div>
          </motion.div>

          {/* RIGHT: VIP HIGHLIGHTS & AGENT CONTACT CARD */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.3 }}
            className="flex flex-col gap-8 justify-between"
          >
            {/* VIP highlights */}
            <div className="bg-guezs-white rounded-[40px] p-8 shadow-xl border border-guezs-gold/10 flex flex-col gap-6">
              <h3 className="font-heading text-2xl text-guezs-black tracking-wide border-b border-guezs-gold/20 pb-4">
                Caractéristiques VIP
              </h3>

              <div className="grid grid-cols-2 gap-6">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-2xl bg-guezs-gold/10 flex items-center justify-center text-guezs-gold">
                    <Maximize2 className="w-5 h-5" />
                  </div>
                  <div>
                    <span className="text-[10px] uppercase tracking-wider text-guezs-black/40 block">Surface</span>
                    <span className="font-bold text-sm text-guezs-black">800 m² titré</span>
                  </div>
                </div>

                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-2xl bg-guezs-gold/10 flex items-center justify-center text-guezs-gold">
                    <BedDouble className="w-5 h-5" />
                  </div>
                  <div>
                    <span className="text-[10px] uppercase tracking-wider text-guezs-black/40 block">Chambres</span>
                    <span className="font-bold text-sm text-guezs-black">7 Suites</span>
                  </div>
                </div>

                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-2xl bg-guezs-gold/10 flex items-center justify-center text-guezs-gold">
                    <Bath className="w-5 h-5" />
                  </div>
                  <div>
                    <span className="text-[10px] uppercase tracking-wider text-guezs-black/40 block">Douches</span>
                    <span className="font-bold text-sm text-guezs-black">9 Bain / Douches</span>
                  </div>
                </div>

                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-2xl bg-guezs-gold/10 flex items-center justify-center text-guezs-gold">
                    <Compass className="w-5 h-5" />
                  </div>
                  <div>
                    <span className="text-[10px] uppercase tracking-wider text-guezs-black/40 block">Dépendance</span>
                    <span className="font-bold text-sm text-guezs-black">En Étage</span>
                  </div>
                </div>
              </div>

              <div className="bg-guezs-blue/5 rounded-3xl p-5 border border-guezs-blue/10 mt-2">
                <span className="text-xs uppercase tracking-widest text-guezs-blue font-bold block mb-2">Les Atouts Uniques</span>
                <ul className="text-xs text-guezs-black/70 space-y-2">
                  <li className="flex items-center gap-2">✓ Magnifique jardin paysager privatif</li>
                  <li className="flex items-center gap-2">✓ Sous-sol complet aménagé</li>
                  <li className="flex items-center gap-2">✓ Grand parking dans l'enceinte sécurisée</li>
                  <li className="flex items-center gap-2">✓ Quartier résidentiel ultra-calme et prisé</li>
                </ul>
              </div>
            </div>

            {/* VIP Call-to-Action Card */}
            <div className="bg-[#003366] text-white rounded-[40px] p-8 shadow-2xl relative overflow-hidden flex flex-col justify-between h-[300px]">
              {/* Background elegant circles */}
              <div className="absolute top-0 right-0 w-32 h-32 bg-guezs-gold/10 rounded-full blur-xl pointer-events-none" />
              <div className="absolute -bottom-10 -left-10 w-40 h-40 bg-white/5 rounded-full pointer-events-none" />

              <div>
                <span className="text-guezs-gold text-[10px] uppercase tracking-[0.35em] font-bold block mb-2">CONSEILLER DÉDIÉ</span>
                <h4 className="font-heading text-2xl font-light leading-tight">
                  Prendre rendez-vous pour <span className="italic font-medium text-guezs-gold">une visite guidée</span>
                </h4>
                <p className="text-white/60 text-xs mt-3 leading-relaxed">
                  Bénéficiez d'un accompagnement sur-mesure pour découvrir ce chef-d'œuvre architectural.
                </p>
              </div>

              <div className="flex flex-col gap-3 mt-6">
                <a
                  href="https://wa.me/237697773548?text=Bonjour,%20je%20suis%20intéressé%20par%20le%20Triplex%20de%20prestige%20à%20Febe%20Village."
                  target="_blank"
                  rel="noopener noreferrer"
                  className="w-full bg-[#25D366] hover:bg-[#20ba56] text-white flex items-center justify-center gap-3 py-3 rounded-full text-xs uppercase tracking-widest font-bold transition-all duration-300 shadow-md"
                >
                  <Volume2 className="w-4 h-4 rotate-90" /> {/* WhatsApp phone-like feel */}
                  Discuter sur WhatsApp
                </a>
                <a
                  href="tel:00237676606503"
                  className="w-full bg-guezs-gold hover:bg-[#c29f2e] text-guezs-black flex items-center justify-center gap-3 py-3 rounded-full text-xs uppercase tracking-widest font-bold transition-all duration-300 shadow-md"
                >
                  <Phone className="w-4 h-4" />
                  Appeler le service VIP
                </a>
              </div>
            </div>

          </motion.div>
        </div>

        {/* INTERACTIVE DETAIL SPECIFICATIONS TABS */}
        <motion.section
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          className="mb-24"
        >
          <div className="flex flex-col md:flex-row md:justify-between md:items-end gap-6 mb-10 border-b border-guezs-black/10 pb-6">
            <div>
              <span className="text-guezs-gold font-body uppercase tracking-[0.3em] text-xs mb-3 block">RÉPARTITION DES ESPACES</span>
              <h2 className="font-heading text-3xl md:text-4xl text-guezs-black tracking-wide">
                Distribution Intérieure
              </h2>
            </div>

            {/* Tab Filters */}
            <div className="flex flex-wrap gap-2 md:gap-3">
              {levels.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`px-5 py-2.5 rounded-full text-[10px] md:text-xs uppercase tracking-wider font-semibold transition-all duration-300 ${
                    activeTab === tab.id
                      ? "bg-guezs-gold text-white shadow-md scale-105"
                      : "bg-white text-guezs-black/60 hover:text-guezs-black border border-guezs-black/5"
                  }`}
                >
                  {tab.label}
                </button>
              ))}
            </div>
          </div>

          {/* Specs Details Display */}
          <div className="bg-white rounded-[40px] p-8 md:p-12 shadow-xl border border-guezs-gold/5 min-h-[300px]">
            <AnimatePresence mode="wait">
              <motion.div
                key={activeTab}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                transition={{ duration: 0.4 }}
                className="grid grid-cols-1 md:grid-cols-2 gap-8 md:gap-12"
              >
                {/* Column 1: Descriptive text list */}
                <div className="flex flex-col gap-6">
                  {levels.map((lvl) => {
                    if (lvl.id === "all" || activeTab !== "all" && lvl.id !== activeTab) return null;
                    return (
                      <div key={lvl.id} className="flex flex-col gap-4">
                        <span className="text-xs uppercase tracking-widest text-guezs-gold font-bold flex items-center gap-2">
                          <Building2 className="w-4 h-4 text-guezs-blue" />
                          {lvl.label}
                        </span>
                        <div className="space-y-4">
                          {lvl.details?.map((detail, idx) => (
                            <motion.div
                              initial={{ opacity: 0, x: -10 }}
                              animate={{ opacity: 1, x: 0 }}
                              transition={{ delay: idx * 0.1 }}
                              key={idx}
                              className="flex items-start gap-4 p-4 bg-guezs-sand/60 rounded-2xl border border-guezs-black/5 hover:border-guezs-gold/20 transition-all duration-300"
                            >
                              <span className="text-guezs-gold font-bold text-sm mt-0.5">✓</span>
                              <span className="text-guezs-black/80 text-sm md:text-base leading-relaxed">{detail}</span>
                            </motion.div>
                          ))}
                        </div>
                      </div>
                    );
                  })}
                </div>

                {/* Column 2: Elegant quote / callout illustration */}
                <div className="relative rounded-3xl overflow-hidden aspect-video md:aspect-auto md:h-full bg-guezs-black/5 flex flex-col justify-center p-8 border border-guezs-gold/10 bg-gradient-to-tr from-[#003366]/5 via-[#D4AF37]/5 to-[#003366]/5">
                  <div className="absolute inset-0 mix-blend-overlay opacity-30 bg-[radial-gradient(#D4AF37_1px,transparent_1px)] [background-size:16px_16px]" />
                  <span className="text-[10px] uppercase tracking-[0.4em] text-guezs-gold font-bold block mb-4">L'IMMOBILIER D'EXCEPTION</span>
                  <p className="font-heading text-2xl md:text-3xl text-guezs-black/90 font-light leading-snug">
                    "Une alliance parfaite entre <span className="italic font-medium text-guezs-gold">prestige architectural</span> et art de vivre absolu."
                  </p>
                  <div className="flex gap-4 mt-8">
                    <div className="flex flex-col">
                      <span className="text-lg font-heading font-semibold text-guezs-black">800 m²</span>
                      <span className="text-[10px] uppercase tracking-wider text-guezs-black/40">Terrain titré</span>
                    </div>
                    <div className="w-px bg-guezs-black/10" />
                    <div className="flex flex-col">
                      <span className="text-lg font-heading font-semibold text-guezs-black">Febe Village</span>
                      <span className="text-[10px] uppercase tracking-wider text-guezs-black/40">Zone Résidentielle</span>
                    </div>
                  </div>
                </div>

              </motion.div>
            </AnimatePresence>
          </div>
        </motion.section>

        {/* PRÉCISIONS IMPORTANTE CALLOUT */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="bg-guezs-white border border-guezs-gold/20 rounded-[40px] p-8 md:p-12 mb-24 shadow-lg flex flex-col md:flex-row justify-between items-center gap-8 relative overflow-hidden"
        >
          <div className="absolute top-0 left-0 w-2 h-full bg-guezs-gold" />
          <div className="max-w-2xl">
            <span className="text-xs uppercase tracking-widest text-guezs-gold font-bold block mb-2">AUTRES PRÉCISIONS & VISITES</span>
            <p className="text-guezs-black/70 text-sm md:text-base leading-relaxed">
              Toutes les visites s'effectuent exclusivement sur rendez-vous. Pour obtenir des précisions supplémentaires, poser vos questions ou planifier une rencontre sur site, veuillez contacter notre équipe d'experts immobiliers.
            </p>
          </div>
          <div className="flex flex-wrap gap-4 justify-center">
            <a
              href="tel:00237697773548"
              className="flex items-center gap-3 px-6 py-4 rounded-full bg-guezs-black hover:bg-guezs-gold text-white hover:text-guezs-black transition-all duration-300 text-xs uppercase tracking-widest font-bold shadow-md"
            >
              <Phone className="w-4 h-4" />
              00237 697 773 548
            </a>
            <a
              href="tel:00237676606503"
              className="flex items-center gap-3 px-6 py-4 rounded-full border border-guezs-black/20 hover:border-guezs-gold hover:bg-guezs-gold/10 text-guezs-black transition-all duration-300 text-xs uppercase tracking-widest font-bold"
            >
              <Phone className="w-4 h-4" />
              00237 676 606 503
            </a>
          </div>
        </motion.div>

        {/* CONTACT SECTION */}
        <motion.section
          id="contact"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          className="mb-12"
        >
          <div className="bg-guezs-white/80 backdrop-blur-md rounded-[50px] overflow-hidden border border-guezs-gold/10 shadow-2xl p-6 md:p-12">
            <ContactForm />
          </div>
        </motion.section>
      </div>

      {/* FULLSCREEN IMAGE VIEWER MODAL */}
      <AnimatePresence>
        {fullscreenOpen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/95 z-[9999] flex flex-col justify-center items-center p-4"
          >
            {/* Topbar inside Fullscreen Modal */}
            <div className="absolute top-6 left-6 right-6 flex justify-between items-center text-white z-[10000]">
              <div className="flex flex-col">
                <span className="text-xs uppercase tracking-widest text-guezs-gold font-bold">Galerie Plein Écran</span>
                <span className="text-sm font-heading font-light mt-1">{GALLERY[activeImgIndex].title}</span>
              </div>
              <button
                onClick={() => setFullscreenOpen(false)}
                className="w-12 h-12 rounded-full bg-white/10 flex items-center justify-center hover:bg-white hover:text-black transition-all duration-300"
              >
                <X className="w-6 h-6" />
              </button>
            </div>

            {/* Main Fullscreen Image */}
            <div className="relative w-full max-w-6xl aspect-[16/10] md:max-h-[75vh] flex justify-center items-center">
              <motion.div
                key={activeImgIndex}
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95 }}
                transition={{ duration: 0.5 }}
                className="relative w-full h-full"
              >
                <Image
                  src={GALLERY[activeImgIndex].url}
                  alt={GALLERY[activeImgIndex].title}
                  fill
                  className="object-contain"
                  priority
                />
              </motion.div>

              {/* Navigation Arrows for fullscreen */}
              <button
                onClick={prevImage}
                className="absolute left-4 top-1/2 -translate-y-1/2 w-14 h-14 rounded-full bg-white/10 hover:bg-white hover:text-black text-white flex items-center justify-center transition-all duration-300"
              >
                <ChevronLeft className="w-8 h-8" />
              </button>
              <button
                onClick={nextImage}
                className="absolute right-4 top-1/2 -translate-y-1/2 w-14 h-14 rounded-full bg-white/10 hover:bg-white hover:text-black text-white flex items-center justify-center transition-all duration-300"
              >
                <ChevronRight className="w-8 h-8" />
              </button>
            </div>

            {/* Thumbnail selector inside Fullscreen Modal */}
            <div className="absolute bottom-8 flex gap-3 overflow-x-auto max-w-full px-6 hide-scrollbar">
              {GALLERY.map((img, index) => (
                <button
                  key={index}
                  onClick={() => setActiveImgIndex(index)}
                  className={`relative flex-shrink-0 w-20 md:w-28 aspect-video rounded-xl overflow-hidden transition-all duration-300 border-2 ${
                    activeImgIndex === index
                      ? "border-guezs-gold scale-105"
                      : "border-transparent opacity-40 hover:opacity-100"
                  }`}
                >
                  <Image
                    src={img.url}
                    alt={img.title}
                    fill
                    className="object-cover"
                  />
                </button>
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </main>
  );
}
