"use client";
import { useState, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import ContactModal from '../shared/ContactModal';

export default function Navbar() {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMounted, setIsMounted] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [isContactModalOpen, setIsContactModalOpen] = useState(false);

  useEffect(() => {
    setIsMounted(true);
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 50);
    };
    handleScroll();
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, [isOpen]);

  const navLinks = [
    { name: "À propos", href: "/#about" },
    { name: "La Promotrice", href: "/#promotrice" },
    { name: "Immobilier", href: "/#immobilier" },
    { name: "GUEZS Films", href: "/#guezs-films" },
    { name: "Piknik", href: "/#piknik" },
    { name: "Beauté", href: "/#beauty" },
    { name: "Style", href: "/#style" },
    { name: "Investisseurs", href: "/#investisseurs" },
  ];

  // Transition from transparent header to beige background on scroll
  const navBg = isMounted && isScrolled 
    ? "bg-guezs-sand/98 backdrop-blur-lg border-b border-guezs-black/10 py-4 shadow-sm" 
    : "bg-transparent py-8";

  // Text color needs to be white if over dark hero, or dark if on light background
  const textColor = isMounted && isScrolled ? "text-[#333333]" : "text-white";
  const burgerColor = isMounted && isScrolled ? "bg-[#333333]" : "bg-white";

  return (
    <>
      <nav 
        className={`fixed top-0 w-full z-[99999] transition-all duration-500 flex items-center justify-between px-6 md:px-12 ${navBg}`}
        suppressHydrationWarning
      >
        {/* LEFT: Contact Us */}
        <div className="flex-1 flex items-center justify-start">
          <button
            onClick={() => setIsContactModalOpen(true)}
            className={`group relative flex items-center gap-2.5 font-body text-[10px] md:text-xs uppercase tracking-[0.2em] font-bold transition-all duration-500 px-4 md:px-5 py-2.5 rounded-full border overflow-hidden ${
              isMounted && isScrolled
                ? "border-guezs-black/40 text-guezs-black hover:text-white"
                : "border-white/40 text-white hover:border-white"
            }`}
          >
            <div className="absolute inset-0 bg-guezs-gold scale-x-0 group-hover:scale-x-100 transition-transform duration-400 origin-left rounded-full z-0" />
            <span className="absolute inset-0 rounded-full animate-pulse opacity-20 bg-guezs-gold pointer-events-none" />
            <span className="relative z-10 w-1.5 h-1.5 rounded-full bg-guezs-gold group-hover:bg-white transition-colors duration-300 flex-shrink-0" />
            <span className="relative z-10 hidden md:block">Contactez-nous</span>
          </button>
        </div>

        {/* CENTER: Hanging Logo Badge */}
        <div className="flex-1 flex justify-center">
            <Link 
              href="/" 
              className={`absolute top-0 flex flex-col items-center justify-center transition-all duration-700 ${
                isMounted && isScrolled 
                  ? "bg-white/95 backdrop-blur-sm w-24 h-28 md:w-32 md:h-34 rounded-b-xl border-x border-b border-guezs-black/5 shadow-lg" 
                  : "bg-transparent w-32 h-40 md:w-44 md:h-48"
              }`}
            >
              <div className={`relative transition-all duration-700 ${isScrolled ? 'w-16 h-16 md:w-20 md:h-20 mt-1' : 'w-24 h-24 md:w-32 md:h-32 mt-2'}`}>
                <Image
                  src="/assets/logos/logo_guezs_houses.png"
                  alt="GUEZS HOUSE Logo"
                  fill
                  className="object-contain"
                  priority
                />
              </div>
            </Link>
        </div>

        {/* RIGHT: Menu */}
        <div className="flex-1 flex items-center justify-end">
          <button 
            onClick={() => setIsOpen(true)}
            className={`group relative z-10 flex items-center gap-3 font-body text-xs md:text-sm uppercase tracking-[0.15em] transition-colors duration-300 hover:text-guezs-gold ${textColor}`}
            aria-label="Ouvrir le menu"
          >
            <span className="hidden md:block mt-0.5">Menu</span>
            <div className="flex flex-col gap-1.5 w-6">
              <span className={`block h-[2px] w-full transition-colors duration-300 ${burgerColor} group-hover:bg-guezs-gold`}></span>
              <span className={`block h-[2px] w-full transition-colors duration-300 ${burgerColor} group-hover:bg-guezs-gold`}></span>
              <span className={`block h-[2px] w-3 ml-auto transition-colors duration-300 ${burgerColor} group-hover:bg-guezs-gold`}></span>
            </div>
          </button>
        </div>
      </nav>

      {/* Menu Mobile/Full-Screen Layout Updates */}
      <AnimatePresence>
        {isOpen && (
            <motion.div 
              initial={{ opacity: 0, x: '100%' }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: '100%' }}
              transition={{ type: "spring", damping: 30, stiffness: 200 }}
              className="fixed inset-0 z-[100000] bg-[#F9F9F9] text-guezs-black flex flex-col pt-32 px-6 md:px-24 overflow-y-auto"
            >
            {/* Bouton Fermer */}
            <button 
              onClick={() => setIsOpen(false)}
              className="absolute top-8 right-6 md:right-12 text-guezs-black hover:text-guezs-gold text-xs md:text-sm uppercase tracking-widest flex items-center gap-3 transition-colors duration-300"
              aria-label="Fermer le menu"
            >
              <span>Fermer</span>
              <div className="relative w-6 h-6 flex items-center justify-center">
                 <span className="absolute block h-[1px] w-full bg-current rotate-45"></span>
                 <span className="absolute block h-[1px] w-full bg-current -rotate-45"></span>
              </div>
            </button>

            {/* Content Split: Navigation Links and Contact info */}
            <div className="flex flex-col md:flex-row h-full w-full max-w-7xl mx-auto mt-12 md:mt-24">
              
              <div className="flex-1 flex flex-col space-y-6 md:space-y-10">
                <span className="text-xs uppercase tracking-widest text-guezs-black/40 font-body mb-4">Navigation</span>
                {navLinks.map((link, index) => (
                  <motion.div
                    key={link.name}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.1 }}
                  >
                    <Link 
                      href={link.href}
                      onClick={() => setIsOpen(false)}
                      className="font-heading text-4xl md:text-6xl lg:text-7xl text-guezs-black hover:text-guezs-gold transition-colors block py-2"
                    >
                      {link.name}
                    </Link>
                  </motion.div>
                ))}
              </div>

              <motion.div 
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 }}
                className="flex-1 flex flex-col mt-20 md:mt-0 md:pl-24 justify-end"
              >
                 <span className="text-xs uppercase tracking-widest text-guezs-black/40 font-body mb-8">Contact</span>
                 <div className="flex flex-col space-y-3 mb-4">
                   <a href="mailto:contact@guezs-house.com" className="text-xl md:text-3xl font-heading text-guezs-black hover:text-guezs-gold transition-colors">
                     contact@guezs-house.com
                   </a>
                   <a href="mailto:yvette.mengue@guezshouse.com" className="text-xl md:text-3xl font-heading text-guezs-black hover:text-guezs-gold transition-colors">
                     yvette.mengue@guezshouse.com
                   </a>
                 </div>
                 <div className="font-body text-sm text-guezs-black/60 space-y-2 mt-8">
                   <p>Yaoundé, Cameroun</p>
                 </div>

                 {/* Réseaux sociaux */}
                 <div className="mt-16 pb-12 flex gap-8">
                   <a href="#" className="text-guezs-black/50 hover:text-guezs-gold transition-colors">
                     Facebook
                   </a>
                   <a href="#" className="text-guezs-black/50 hover:text-guezs-gold transition-colors">
                     Instagram
                   </a>
                   <a href="#" className="text-guezs-black/50 hover:text-guezs-gold transition-colors">
                     LinkedIn
                   </a>
                 </div>
              </motion.div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      <ContactModal 
        isOpen={isContactModalOpen} 
        onClose={() => setIsContactModalOpen(false)} 
      />
    </>
  );
}
