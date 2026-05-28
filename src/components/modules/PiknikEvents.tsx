"use client";
import { useState } from "react";
import { motion } from "framer-motion";
import { PiknikEvent } from "@/types/piknik";
import { db } from "@/lib/firebase";
import { collection, addDoc, serverTimestamp } from "firebase/firestore";
import { countries } from "@/lib/countries";
import Select from "react-select";

const EVENTS: PiknikEvent[] = [
  {
    id: '1',
    title: "Afro Summer Piknik",
    date: "15 Août 2026",
    location: "Espace GUEZS, Yaoundé",
    price: 15000,
    image: "/assets/images/piknik1.jpeg",
    status: 'À venir',
    description: "Une journée d'immersion culturelle et gastronomique avec des artisans locaux et des chefs renommés."
  },
  {
    id: '2',
    title: "Soirée Garden Chic",
    date: "22 Septembre 2026",
    location: "Bastos, Yaoundé",
    price: 25000,
    image: "/assets/images/piknik2.jpeg",
    status: 'À venir',
    description: "Networking et musique live dans un cadre d'exception sous les étoiles."
  },
  {
    id: '3',
    title: "Brunch Dominical",
    date: "06 Octobre 2026",
    location: "Bonapriso, Douala",
    price: 20000,
    image: "/assets/images/piknik3.jpeg",
    status: 'À venir',
    description: "Un moment de détente gourmand entre amis et famille, avec vue panoramique."
  },
  {
    id: '4',
    title: "Gala de Fin d'Année",
    date: "31 Décembre 2025",
    location: "Hilton Yaoundé",
    price: 50000,
    image: "/assets/images/piknik4.jpeg",
    status: 'Complet',
    description: "La soirée la plus attendue de l'année. Dress code : Élégance Afro-Chic."
  }
];

export default function PiknikEvents() {
  const [selectedEvent, setSelectedEvent] = useState<PiknikEvent | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);
  const [newsletterEmail, setNewsletterEmail] = useState("");
  const [newsletterSuccess, setNewsletterSuccess] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    countryCode: "+237",
    mobile: "",
    places: 1,
  });

  const handleNewsletterSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newsletterEmail) return;
    try {
      await addDoc(collection(db, "piknik_newsletter"), {
        email: newsletterEmail,
        createdAt: serverTimestamp(),
      });
      await addDoc(collection(db, "mail"), {
        to: "yvette.mengue@guezs-house.com",
        message: {
          subject: "Nouvelle inscription Newsletter GUEZS Piknik",
          html: `<p>Nouvelle inscription à la newsletter GUEZS Piknik :</p><p><strong>Email :</strong> ${newsletterEmail}</p>`,
        },
      });
      setNewsletterSuccess(true);
      setNewsletterEmail("");
      setTimeout(() => setNewsletterSuccess(false), 4000);
    } catch (error) {
      console.error("Erreur newsletter :", error);
      alert("Une erreur est survenue.");
    }
  };

  const handleOpenModal = (event: PiknikEvent) => {
    setSelectedEvent(event);
    setIsModalOpen(true);
    setSubmitSuccess(false);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setSelectedEvent(null);
    setSubmitSuccess(false);
    setFormData({ name: "", email: "", countryCode: "+237", mobile: "", places: 1 });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedEvent) return;
    setIsSubmitting(true);
    try {
      await addDoc(collection(db, "piknik_reservations"), {
        ...formData,
        eventId: selectedEvent.id,
        eventTitle: selectedEvent.title,
        eventDate: selectedEvent.date,
        eventLocation: selectedEvent.location,
        eventPrice: selectedEvent.price,
        totalPrice: selectedEvent.price * formData.places,
        createdAt: serverTimestamp(),
      });
      await addDoc(collection(db, "mail"), {
        to: "yvette.mengue@guezs-house.com",
        message: {
          subject: `Nouvelle réservation Piknik — ${selectedEvent.title}`,
          html: `<div style="font-family:sans-serif;max-width:600px;margin:0 auto">
            <h2 style="color:#D4AF37">Nouvelle Réservation GUEZS Piknik</h2>
            <table style="width:100%;border-collapse:collapse">
              <tr><td style="padding:8px;border-bottom:1px solid #eee;font-weight:bold">Événement</td><td style="padding:8px;border-bottom:1px solid #eee">${selectedEvent.title}</td></tr>
              <tr><td style="padding:8px;border-bottom:1px solid #eee;font-weight:bold">Date</td><td style="padding:8px;border-bottom:1px solid #eee">${selectedEvent.date}</td></tr>
              <tr><td style="padding:8px;border-bottom:1px solid #eee;font-weight:bold">Lieu</td><td style="padding:8px;border-bottom:1px solid #eee">${selectedEvent.location}</td></tr>
              <tr><td style="padding:8px;border-bottom:1px solid #eee;font-weight:bold">Nom</td><td style="padding:8px;border-bottom:1px solid #eee">${formData.name}</td></tr>
              <tr><td style="padding:8px;border-bottom:1px solid #eee;font-weight:bold">Email</td><td style="padding:8px;border-bottom:1px solid #eee">${formData.email}</td></tr>
              <tr><td style="padding:8px;border-bottom:1px solid #eee;font-weight:bold">Téléphone</td><td style="padding:8px;border-bottom:1px solid #eee">${formData.countryCode} ${formData.mobile}</td></tr>
              <tr><td style="padding:8px;border-bottom:1px solid #eee;font-weight:bold">Places</td><td style="padding:8px;border-bottom:1px solid #eee">${formData.places}</td></tr>
              <tr><td style="padding:8px;font-weight:bold;color:#D4AF37">Total</td><td style="padding:8px;font-weight:bold;color:#D4AF37">${(selectedEvent.price * formData.places).toLocaleString('fr-FR')} FCFA</td></tr>
            </table>
          </div>`,
        },
      });
      setSubmitSuccess(true);
      setTimeout(() => {
        handleCloseModal();
      }, 3000);
    } catch (error) {
      console.error("Erreur réservation :", error);
      alert("Une erreur est survenue.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <section className="w-full relative flex flex-col justify-center">
      
      {/* HEADER SECTION (Split Layout) */}
      <div className="container mx-auto px-6 md:px-12 mb-12 md:mb-16">
        <div className="flex flex-col md:flex-row relative">
          
          <div className="hidden md:block absolute left-1/2 top-4 bottom-[-60px] w-px bg-guezs-black/20 -translate-x-1/2" />

          {/* Left Column : Titles */}
          <div className="w-full md:w-1/2 md:pr-20 mb-12 md:mb-0">
             <span className="text-guezs-black/40 font-body uppercase tracking-[0.3em] text-[10px] md:text-xs mb-6 block">
               EXPÉRIENCES EXCLUSIVES
             </span>
             <h2 className="font-heading text-5xl md:text-7xl lg:text-8xl text-guezs-black leading-[0.9] tracking-tight">
               GUEZS
               <br/>
               <span className="italic">Piknik</span>
             </h2>
          </div>

          {/* Right Column : Description */}
          <div className="w-full md:w-1/2 md:pl-20 flex flex-col justify-end">
             <p className="font-body text-guezs-black/70 text-sm md:text-base leading-relaxed mb-12 max-w-sm">
               Rejoignez-nous pour des moments inoubliables où l'art de vivre Afro-Chic se mêle à une gastronomie raffinée et des rencontres inspirantes.
             </p>
             <p className="font-body text-guezs-black/40 text-[10px] uppercase tracking-[0.2em] font-medium">
               Événements & Loisirs culturels
             </p>
          </div>
        </div>
      </div>

      {/* EVENTS GRID */}
      <div className="container mx-auto px-6 md:px-12">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 lg:gap-16">
          {EVENTS.map((event, index) => (
            <motion.div 
              key={event.id}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ delay: index * 0.1, duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
              className="group relative flex flex-col bg-white rounded-[40px] overflow-hidden shadow-sm border border-guezs-black/5 transition-all duration-500 hover:shadow-xl hover:-translate-y-2"
            >
              {/* Image Container */}
              <div className="relative h-64 sm:h-80 w-full overflow-hidden">
                <img 
                  src={event.image} 
                  alt={event.title}
                  className="w-full h-full object-cover grayscale-[30%] group-hover:grayscale-0 transition-transform duration-1000 group-hover:scale-105"
                />
                <div className="absolute inset-0 bg-guezs-black/10 group-hover:bg-guezs-black/0 transition-all duration-500" />
                
                {/* Status Badge */}
                <div className="absolute top-6 left-6 flex gap-3 z-10">
                  <div className={`px-4 py-2 text-[10px] font-bold uppercase tracking-widest rounded-full ${
                    event.status === 'Complet' 
                      ? 'bg-guezs-terracotta text-white' 
                      : event.status === 'Passé'
                        ? 'bg-gray-300 text-gray-700'
                        : 'bg-guezs-gold text-white'
                  }`}>
                    {event.status}
                  </div>
                </div>
              </div>

              {/* Contenu textuel */}
              <div className="p-8 md:p-10 flex flex-col grow justify-between bg-white text-guezs-black">
                <div>
                  <div className="flex items-center gap-2 mb-4 text-guezs-gold">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    <span className="font-bold text-sm tracking-tight">{event.date}</span>
                  </div>
                  
                  <h3 className="font-heading text-3xl mb-4 group-hover:text-guezs-gold transition-colors">
                    {event.title}
                  </h3>
                  
                  <div className="flex items-center gap-2 mb-6 text-guezs-black/50 text-xs">
                    <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    <span className="uppercase tracking-wider">{event.location}</span>
                  </div>
                  
                  <p className="text-guezs-black/60 text-sm leading-relaxed decoration-clone">
                    {event.description}
                  </p>
                </div>
                
                {/* Footer Carte */}
                <div className="flex items-center justify-between border-t border-guezs-black/10 pt-6 mt-8">
                  <div>
                    <span className="text-[10px] text-guezs-black/40 uppercase tracking-widest block mb-1">À partir de</span>
                    <span className="font-heading text-xl md:text-2xl text-guezs-gold font-medium">{event.price.toLocaleString('fr-FR')} FCFA</span>
                  </div>
                  <button 
                    onClick={() => event.status === 'À venir' && handleOpenModal(event)}
                    disabled={event.status === 'Complet' || event.status === 'Passé'}
                    className={`px-6 py-3 rounded-full text-[10px] md:text-xs uppercase tracking-[0.2em] font-medium transition-all duration-300 border ${
                      event.status === 'Complet' || event.status === 'Passé'
                        ? 'border-gray-200 bg-gray-100 text-gray-400 cursor-not-allowed'
                        : 'border-[#D4AF37] text-[#D4AF37] hover:bg-[#D4AF37] hover:text-white cursor-pointer'
                    }`}
                  >
                    {event.status === 'Complet' ? 'Complet' : event.status === 'Passé' ? 'Terminé' : 'Réserver'}
                  </button>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* CTA Newsletter Section (Volta Skai style - simple clean layout) */}
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="mt-32 max-w-2xl mx-auto text-center"
        >
          <h3 className="font-heading text-3xl md:text-4xl text-guezs-black mb-6">Ne manquez aucun événement</h3>
          <p className="font-body text-guezs-black/60 text-sm md:text-base mb-10 leading-relaxed">
            Inscrivez-vous à notre newsletter pour recevoir en exclusivité nos prochaines dates et offres early-bird.
          </p>
          
          {newsletterSuccess ? (
            <div className="flex items-center justify-center gap-3 text-guezs-gold font-body text-sm py-4 bg-white rounded-full border border-guezs-gold/20">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" /></svg>
              Merci ! Vous êtes désormais inscrit(e).
            </div>
          ) : (
            <form onSubmit={handleNewsletterSubmit} className="flex flex-col sm:flex-row gap-4">
              <input 
                type="email" 
                required
                value={newsletterEmail}
                onChange={(e) => setNewsletterEmail(e.target.value)}
                placeholder="Votre adresse email" 
                className="flex-1 px-8 py-4 rounded-full bg-white border border-guezs-black/10 text-guezs-black placeholder:text-guezs-black/30 focus:border-guezs-gold focus:ring-1 focus:ring-guezs-gold outline-none transition-all font-body text-sm"
              />
              <button type="submit" className="px-10 py-4 rounded-full bg-guezs-black text-white font-medium text-[10px] md:text-xs uppercase tracking-[0.2em] hover:bg-guezs-gold transition-colors">
                S'inscrire
              </button>
            </form>
          )}
        </motion.div>
      </div>

      {/* Modal de réservation (Preserved Logic, updated styling) */}
      {isModalOpen && selectedEvent && (
        <div className="fixed inset-0 z-[99999] flex items-center justify-center px-4 backdrop-blur-md bg-black/60" onClick={handleCloseModal}>
          <div 
            className="relative w-full max-w-lg bg-white rounded-[30px] p-8 md:p-10 shadow-2xl animate-in fade-in zoom-in duration-300 text-guezs-black"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Bouton fermer */}
            <button 
              onClick={handleCloseModal}
              className="absolute top-6 right-6 text-guezs-black/40 hover:text-guezs-gold transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M6 18L18 6M6 6l12 12" /></svg>
            </button>

            {/* En-tête de la modale */}
            <div className="mb-8">
              <span className="text-guezs-black/40 text-[10px] md:text-xs uppercase tracking-[0.3em] font-body block mb-2">Réservation</span>
              <h3 className="font-heading text-3xl md:text-4xl text-guezs-black mb-4">{selectedEvent.title}</h3>
              <div className="flex flex-col sm:flex-row items-start sm:items-center gap-2 sm:gap-6 text-guezs-black/60 text-xs md:text-sm">
                <span className="flex items-center gap-2">
                  <svg className="w-4 h-4 text-guezs-gold" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                  {selectedEvent.date}
                </span>
                <span className="flex items-center gap-2">
                  <svg className="w-4 h-4 text-guezs-gold" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /></svg>
                  {selectedEvent.location}
                </span>
              </div>
              <div className="mt-6 pt-6 border-t border-guezs-black/10 flex justify-between items-end">
                <span className="text-guezs-black/40 text-[10px] md:text-xs uppercase tracking-widest block mb-1">Prix unitaire</span>
                <span className="text-guezs-black font-heading text-2xl">{selectedEvent.price.toLocaleString('fr-FR')} FCFA</span>
              </div>
            </div>
            
            {submitSuccess ? (
              <div className="text-center py-8">
                <div className="w-20 h-20 rounded-full bg-green-50 flex items-center justify-center mx-auto mb-6 border border-green-100">
                  <svg className="w-10 h-10 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" /></svg>
                </div>
                <p className="font-heading text-3xl text-guezs-black mb-3">Réservation confirmée</p>
                <p className="font-body text-guezs-black/60 text-sm">Vous recevrez un email de confirmation sous peu.</p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-5 text-left">
                <div>
                  <label className="block text-[10px] font-body text-guezs-black/60 uppercase tracking-wider mb-2">Nom complet</label>
                  <input required type="text" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} className="w-full bg-white border border-guezs-black/10 rounded-xl px-5 py-3.5 text-guezs-black focus:outline-none focus:border-guezs-gold focus:ring-1 focus:ring-guezs-gold transition-colors font-body text-sm shadow-sm" placeholder="Votre nom" />
                </div>
                <div>
                  <label className="block text-[10px] font-body text-guezs-black/60 uppercase tracking-wider mb-2">Email</label>
                  <input required type="email" value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})} className="w-full bg-white border border-guezs-black/10 rounded-xl px-5 py-3.5 text-guezs-black focus:outline-none focus:border-guezs-gold focus:ring-1 focus:ring-guezs-gold transition-colors font-body text-sm shadow-sm" placeholder="votre@email.com" />
                </div>
                <div className="flex gap-4">
                  <div className="w-[45%]">
                    <label className="block text-[10px] font-body text-guezs-black/60 uppercase tracking-wider mb-2">Pays</label>
                    <Select
                      options={countries.map(c => ({ value: c.code, label: `${c.flag} ${c.name} (${c.code})` }))}
                      value={{ value: formData.countryCode, label: formData.countryCode }}
                      onChange={(selected: any) => setFormData({...formData, countryCode: selected.value})}
                      placeholder="Pays..."
                      className="react-select-container text-sm font-body shadow-sm rounded-xl"
                      classNamePrefix="react-select"
                      styles={{
                        control: (base) => ({
                          ...base,
                          backgroundColor: '#FFF',
                          borderColor: 'rgba(0,0,0,0.1)',
                          minHeight: '50px',
                          borderRadius: '0.75rem',
                          boxShadow: 'none',
                          '&:hover': { borderColor: '#D4AF37' }
                        }),
                        menu: (base) => ({
                          ...base,
                          backgroundColor: '#FFF',
                          border: '1px solid rgba(0,0,0,0.1)',
                          zIndex: 9999,
                          borderRadius: '0.75rem',
                          overflow: 'hidden',
                          marginTop: '4px'
                        }),
                        option: (base, state) => ({
                          ...base,
                          backgroundColor: state.isFocused ? '#F9F9F9' : 'transparent',
                          color: '#333',
                          fontSize: '14px',
                          padding: '10px 14px'
                        }),
                        singleValue: (base) => ({ ...base, color: '#333' }),
                        input: (base) => ({ ...base, color: '#333' })
                      }}
                    />
                  </div>
                  <div className="w-[55%]">
                    <label className="block text-[10px] font-body text-guezs-black/60 uppercase tracking-wider mb-2">Mobile</label>
                    <input required type="tel" value={formData.mobile} onChange={e => setFormData({...formData, mobile: e.target.value})} className="w-full bg-white border border-guezs-black/10 rounded-xl px-5 py-3.5 text-guezs-black focus:outline-none focus:border-guezs-gold focus:ring-1 focus:ring-guezs-gold transition-colors font-body text-sm shadow-sm" placeholder="Numéro" />
                  </div>
                </div>
                <div>
                  <label className="block text-[10px] font-body text-guezs-black/60 uppercase tracking-wider mb-2">Nombre de places</label>
                  <div className="flex items-center justify-between p-3 border border-guezs-black/10 rounded-xl bg-white shadow-sm">
                    <div className="flex items-center gap-4">
                      <button type="button" onClick={() => setFormData({...formData, places: Math.max(1, formData.places - 1)})} className="w-10 h-10 rounded-lg hover:bg-gray-100 text-guezs-black transition-colors flex items-center justify-center text-xl font-body border border-gray-200">−</button>
                      <span className="font-heading text-2xl text-guezs-black w-8 text-center">{formData.places}</span>
                      <button type="button" onClick={() => setFormData({...formData, places: Math.min(10, formData.places + 1)})} className="w-10 h-10 rounded-lg hover:bg-gray-100 text-guezs-black transition-colors flex items-center justify-center text-xl font-body border border-gray-200">+</button>
                    </div>
                    <span className="text-guezs-gold font-heading text-xl md:text-2xl pr-2">{(selectedEvent.price * formData.places).toLocaleString('fr-FR')} FCFA</span>
                  </div>
                </div>
                <button disabled={isSubmitting} type="submit" className="w-full mt-6 flex items-center justify-center gap-3 bg-guezs-black text-white hover:bg-guezs-gold font-body uppercase tracking-[0.2em] text-[10px] md:text-xs font-medium py-5 rounded-xl transition-all shadow-[0_10px_30px_rgba(0,0,0,0.1)] hover:shadow-none disabled:opacity-50">
                  {isSubmitting ? "Réservation en cours..." : "Confirmer la réservation"}
                </button>
              </form>
            )}
          </div>
        </div>
      )}
    </section>
  );
}
