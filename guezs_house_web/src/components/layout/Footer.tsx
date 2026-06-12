// src/components/layout/Footer.tsx
import Link from 'next/link';
import { Facebook, Instagram, Linkedin, Twitter } from 'lucide-react';

export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer id="contact" className="relative z-[50] bg-[#050505] text-white pt-24 pb-20 border-t border-white/5 rounded-t-[40px]">
      <div className="container mx-auto px-6 md:px-12 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-16 lg:gap-12">
        {/* Colonne 1: Marque */}
        <div className="flex flex-col items-center md:items-start text-center md:text-left space-y-6">
             <div className="relative">
                <img src="/assets/logos/logo_guezs_houses.png" alt="GUEZS HOUSE" className="h-16 object-contain" />
             </div>
          <p className="text-white/85 font-body text-sm leading-relaxed max-w-xs mt-4">
            L&apos;excellence africaine réinventée. Immobilier, Mode,
            Événementiel & Innovation.
          </p>
          <div className="flex space-x-4 pt-6">
            <SocialLink href="#" icon={<Facebook size={18} />} label="Facebook" />
            <SocialLink href="#" icon={<Instagram size={18} />} label="Instagram" />
            <SocialLink href="#" icon={<Linkedin size={18} />} label="LinkedIn" />
            <SocialLink href="#" icon={<Twitter size={18} />} label="Twitter" />
          </div>
        </div>

        {/* Colonne 2: Exploration */}
        <div className="text-center md:text-left">
          <h4 className="font-heading text-guezs-gold mb-8 uppercase tracking-[0.2em] text-[10px] md:text-xs">Exploration</h4>
          <ul className="space-y-4 text-sm font-body text-white/85">
            <li><FooterLink href="/#about">Notre Histoire</FooterLink></li>
            <li><FooterLink href="/#immobilier">Immobilier de Luxe</FooterLink></li>
            <li>
              <a
                href="https://films.guezs-house.com"
                className="hover:text-guezs-gold transition-colors duration-300"
              >
                GUEZS Films
              </a>
            </li>
            <li><FooterLink href="/#style">GUEZS Style</FooterLink></li>
            <li><FooterLink href="/#piknik">GUEZS Piknik</FooterLink></li>
            <li><FooterLink href="/#investisseurs">Investisseurs</FooterLink></li>
          </ul>
        </div>

        {/* Colonne 3: Contact */}
        <div className="text-center md:text-left">
          <h4 className="font-heading text-guezs-gold mb-8 uppercase tracking-[0.2em] text-[10px] md:text-xs">Nous Contacter</h4>
          <ul className="space-y-6 text-sm font-body text-white/85">
            <li className="flex flex-col md:block">
              <span className="font-bold text-white/40 uppercase tracking-widest text-[10px] block mb-2">Siège Social</span>
              Yaoundé, Cameroun
            </li>
            <li className="flex flex-col md:block">
               <span className="font-bold text-white/40 uppercase tracking-widest text-[10px] block mb-2">Téléphone</span>
               <a href="tel:+237697773548" className="hover:text-guezs-gold transition-colors">+237 697 77 35 48</a>
            </li>
            <li className="flex flex-col md:block">
               <span className="font-bold text-white/40 uppercase tracking-widest text-[10px] block mb-2">Email</span>
               <div className="flex flex-col space-y-2">
                 <a href="mailto:contact@guezshouse.com" className="hover:text-guezs-gold transition-colors">
                   contact@guezshouse.com
                 </a>
                 <a href="mailto:yvette.mengue@guezshouse.com" className="hover:text-guezs-gold transition-colors">
                   yvette.mengue@guezshouse.com
                 </a>
               </div>
            </li>
          </ul>
        </div>

        {/* Colonne 4: Newsletter */}
        <div className="text-center md:text-left">
          <h4 className="font-heading text-guezs-gold mb-8 uppercase tracking-[0.2em] text-[10px] md:text-xs">Newsletter</h4>
          <p className="text-white/80 font-body text-sm mb-6 leading-relaxed">
            Rejoignez notre cercle privé pour recevoir nos exclusivités.
          </p>
          <form className="flex flex-col space-y-4">
            <div className="relative group">
                <input
                    type="email"
                    placeholder="Votre adresse email"
                    className="w-full bg-white/5 border border-white/10 rounded-full text-white px-6 py-4 font-body text-sm focus:outline-none focus:border-guezs-gold transition-all placeholder:text-white/30"
                />
            </div>
            <button className="bg-[#D4AF37] hover:bg-white text-black rounded-full px-8 py-5 text-[11px] font-black uppercase tracking-[0.25em] transition-all duration-300 shadow-[0_0_20px_rgba(212,175,55,0.4)] hover:shadow-[0_0_30px_rgba(255,255,255,0.5)] active:scale-95 leading-none">
              S&apos;inscrire
            </button>
          </form>
        </div>
      </div>

      {/* Copyright */}
      <div className="container mx-auto px-6 md:px-12 mt-20 pt-8 border-t border-white/20 flex flex-col md:flex-row justify-between items-center text-[10px] text-white/70 font-bold uppercase tracking-[0.15em] gap-6 text-center md:text-left">
        <p>© {currentYear} GUEZS HOUSE. Tous droits réservés.</p>
        <div className="flex flex-wrap justify-center md:justify-end gap-6 md:gap-8">
            <Link href="/mentions-legales" className="hover:text-guezs-gold transition-colors">Mentions Légales</Link>
            <Link href="/cgu" className="hover:text-guezs-gold transition-colors">CGU</Link>
            <Link href="/confidentialite" className="hover:text-guezs-gold transition-colors">Confidentialité</Link>
            <Link href="/guezs-films/suppression-des-donnees" className="hover:text-guezs-gold transition-colors">Suppression des données</Link>
        </div>
      </div>
    </footer>
  );
}

function SocialLink({ href, icon, label }: { href: string, icon: React.ReactNode, label: string }) {
    return (
        <a
            href={href}
            className="w-10 h-10 rounded-full border border-white/10 flex items-center justify-center text-white/60 hover:border-guezs-gold hover:text-guezs-gold hover:bg-white/5 transition-all duration-300"
            aria-label={label}
        >
            {icon}
        </a>
    )
}

function FooterLink({ href, children }: { href: string, children: React.ReactNode }) {
    return (
        <Link href={href} className="group inline-flex items-center hover:text-guezs-gold transition-colors duration-300">
            <span className="w-0 group-hover:w-4 h-[1px] bg-guezs-gold mr-0 group-hover:mr-3 transition-all duration-300 opacity-0 group-hover:opacity-100 hidden md:block"></span>
            {children}
        </Link>
    )
}
