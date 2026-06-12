"use client";

import { motion } from "framer-motion";
import { Mail, Phone, MapPin, Send } from "lucide-react";

export default function Contact() {
  return (
    <main className="min-h-screen bg-[#F9F9F9] text-[#333333] pt-32 pb-24 font-body">
      <div className="container mx-auto px-6 md:px-12 lg:px-24">
        {/* En-tête avec animation */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="text-center mb-20"
        >
          <h1 className="font-heading text-4xl md:text-6xl text-[#D4AF37] mb-6 uppercase tracking-widest leading-tight">
            Contact & Support
          </h1>
          <div className="w-24 h-[1px] bg-[#D4AF37] mx-auto mb-8 opacity-50"></div>
          <p className="max-w-2xl mx-auto text-gray-500 text-lg">
            Notre conciergerie est à votre entière disposition pour toute demande d&apos;assistance ou information complémentaire.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 max-w-6xl mx-auto">
          {/* Informations de contact */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="space-y-12"
          >
            <h2 className="font-heading text-3xl text-[#333333] mb-8">Coordonnées</h2>

            <div className="space-y-8">
              <ContactInfoItem
                icon={<Mail className="text-[#D4AF37]" size={24} />}
                title="Email Support"
                content="support@guezshouse.com"
                link="mailto:support@guezshouse.com"
              />
              <ContactInfoItem
                icon={<Phone className="text-[#D4AF37]" size={24} />}
                title="Téléphone & WhatsApp"
                content="+237 697 77 35 48"
                link="tel:+237697773548"
              />
              <ContactInfoItem
                icon={<MapPin className="text-[#D4AF37]" size={24} />}
                title="Siège Social"
                content="Quartier Bastos, Yaoundé, Cameroun"
              />
            </div>

            <div className="pt-8 border-t border-gray-100">
              <p className="text-[#D4AF37] font-heading text-xl mb-4 italic">L&apos;excellence à votre service</p>
              <p className="text-gray-500">Ouvert du Lundi au Samedi, de 08h00 à 20h00.</p>
            </div>
          </motion.div>

          {/* Formulaire de contact */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="bg-white p-8 md:p-12 rounded-[40px] shadow-[0_20px_60px_rgba(0,0,0,0.05)] border border-gray-100"
          >
            <form className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-xs uppercase tracking-widest font-black text-gray-400">Nom Complet</label>
                  <input
                    type="text"
                    placeholder="Votre nom"
                    className="w-full bg-gray-50 border border-gray-100 rounded-2xl px-6 py-4 focus:outline-none focus:border-[#D4AF37] transition-all"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-xs uppercase tracking-widest font-black text-gray-400">Email</label>
                  <input
                    type="email"
                    placeholder="votre@email.com"
                    className="w-full bg-gray-50 border border-gray-100 rounded-2xl px-6 py-4 focus:outline-none focus:border-[#D4AF37] transition-all"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-xs uppercase tracking-widest font-black text-gray-400">Sujet</label>
                <select className="w-full bg-gray-50 border border-gray-100 rounded-2xl px-6 py-4 focus:outline-none focus:border-[#D4AF37] transition-all appearance-none cursor-pointer">
                  <option>Support Application Mobile</option>
                  <option>Demande Immobilière</option>
                  <option>GUEZS Piknik Reservation</option>
                  <option>Collaboration & Investissement</option>
                  <option>Autre</option>
                </select>
              </div>

              <div className="space-y-2">
                <label className="text-xs uppercase tracking-widest font-black text-gray-400">Message</label>
                <textarea
                  rows={5}
                  placeholder="Comment pouvons-nous vous aider ?"
                  className="w-full bg-gray-50 border border-gray-100 rounded-2xl px-6 py-4 focus:outline-none focus:border-[#D4AF37] transition-all resize-none"
                />
              </div>

              <button className="w-full bg-[#D4AF37] hover:bg-black text-white rounded-2xl py-5 font-black uppercase tracking-[0.2em] transition-all duration-300 flex items-center justify-center gap-3 group">
                Envoyer le Message
                <Send size={18} className="group-hover:translate-x-1 group-hover:-translate-y-1 transition-transform" />
              </button>
            </form>
          </motion.div>
        </div>
      </div>
    </main>
  );
}

function ContactInfoItem({ icon, title, content, link }: { icon: React.ReactNode, title: string, content: string, link?: string }) {
  return (
    <div className="flex items-start gap-6">
      <div className="w-12 h-12 rounded-2xl bg-white shadow-lg flex items-center justify-center flex-shrink-0">
        {icon}
      </div>
      <div>
        <h3 className="text-xs uppercase tracking-widest font-black text-gray-400 mb-1">{title}</h3>
        {link ? (
          <a href={link} className="text-lg text-[#333333] hover:text-[#D4AF37] transition-colors leading-tight block">
            {content}
          </a>
        ) : (
          <p className="text-lg text-[#333333] leading-tight block">
            {content}
          </p>
        )}
      </div>
    </div>
  );
}
