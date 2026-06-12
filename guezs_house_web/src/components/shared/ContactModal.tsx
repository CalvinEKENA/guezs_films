"use client";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

interface ContactModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function ContactModal({ isOpen, onClose }: ContactModalProps) {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    message: ""
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setError("");

    try {
      const response = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error("Erreur de communication avec le serveur.");
      }

      setIsSuccess(true);
      setTimeout(() => {
        setIsSuccess(false);
        setFormData({ name: "", email: "", phone: "", message: "" });
        onClose();
      }, 3000);
    } catch (err) {
      console.error("Error submitting contact form:", err);
      setError("Une erreur est survenue lors de l'envoi de votre message. Veuillez réessayer.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop Blur */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 z-[100000] bg-black/60 backdrop-blur-md"
          />

          {/* Modal Container */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-[100001] w-full max-w-4xl p-4 md:p-6"
          >
            <div className="bg-[#F9F9F9] rounded-2xl md:rounded-[40px] overflow-hidden shadow-2xl flex flex-col md:flex-row relative">

              {/* Close Button */}
              <button
                onClick={onClose}
                className="absolute top-4 right-4 md:top-6 md:right-6 w-10 h-10 bg-white/50 hover:bg-white rounded-full flex items-center justify-center transition-colors z-10 shadow-sm"
              >
                <svg className="w-5 h-5 text-guezs-black" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>

              {/* Left Column - Image & Context */}
              <div className="w-full md:w-5/12 relative aspect-[4/3] md:aspect-auto">
                <div className="absolute inset-0 bg-guezs-black/20 z-[1]"></div>
                <div className="absolute inset-0 bg-gradient-to-t from-guezs-black/90 via-guezs-black/40 to-transparent z-[2]"></div>
                <img
                  src="/assets/images/contact-bg.jpg"
                  alt="Contact GUEZS HOUSE"
                  className="w-full h-full object-cover"
                  onError={(e) => {
                    // Fallback à une autre image si celle-ci n'existe pas
                    (e.target as HTMLImageElement).src = "/assets/images/residence1.jpg";
                  }}
                />
                <div className="absolute bottom-0 left-0 p-8 z-10">
                  <span className="text-guezs-gold text-[10px] md:text-xs uppercase tracking-[0.3em] font-bold block mb-4">
                    Privilège & Écoute
                  </span>
                  <h3 className="font-heading text-2xl md:text-3xl text-white mb-2 leading-tight">
                    Nous sommes à votre disposition
                  </h3>
                  <p className="font-body text-white/70 text-sm">
                    Prenez contact directement avec la direction GUEZS HOUSE.
                  </p>
                </div>
              </div>

              {/* Right Column - Form */}
              <div className="w-full md:w-7/12 p-8 md:p-12 lg:p-16 flex flex-col justify-center bg-white relative">

                {/* Decorative Elements */}
                <div className="absolute right-0 top-0 w-32 h-32 bg-guezs-gold/5 rounded-bl-full pointer-events-none" />

                <h2 className="font-heading text-3xl md:text-4xl text-guezs-black mb-2">Discutons de vos projets</h2>
                <p className="font-body text-guezs-black/50 text-sm mb-8">
                  Remplissez ce formulaire et notre équipe reviendra vers vous dans les plus brefs délais.
                </p>

                {isSuccess ? (
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="flex flex-col items-center justify-center py-12 text-center"
                  >
                    <div className="w-16 h-16 rounded-full bg-green-50 flex items-center justify-center mb-6">
                      <svg className="w-8 h-8 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
                      </svg>
                    </div>
                    <h3 className="font-heading text-2xl text-guezs-black mb-2">Message envoyé</h3>
                    <p className="text-guezs-black/60 text-sm">Nous traiterons votre demande dans les plus brefs délais.</p>
                  </motion.div>
                ) : (
                  <form onSubmit={handleSubmit} className="space-y-5 relative z-10">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                      <div>
                        <label className="block text-xs uppercase tracking-widest text-guezs-black/40 mb-2 font-medium">Nom complet</label>
                        <input
                          type="text"
                          required
                          value={formData.name}
                          onChange={(e) => setFormData({...formData, name: e.target.value})}
                          className="w-full px-4 py-3 bg-[#F9F9F9] border border-[#9CA3AF] text-guezs-black rounded-xl text-sm focus:outline-none focus:border-guezs-gold focus:ring-1 focus:ring-guezs-gold transition-all"
                          placeholder="Votre nom"
                        />
                      </div>
                      <div>
                        <label className="block text-xs uppercase tracking-widest text-guezs-black/40 mb-2 font-medium">Téléphone</label>
                        <input
                          type="tel"
                          required
                          value={formData.phone}
                          onChange={(e) => setFormData({...formData, phone: e.target.value})}
                          className="w-full px-4 py-3 bg-[#F9F9F9] border border-[#9CA3AF] text-guezs-black rounded-xl text-sm focus:outline-none focus:border-guezs-gold focus:ring-1 focus:ring-guezs-gold transition-all"
                          placeholder="+237 ..."
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-xs uppercase tracking-widest text-guezs-black/40 mb-2 font-medium">Email</label>
                      <input
                        type="email"
                        required
                        value={formData.email}
                        onChange={(e) => setFormData({...formData, email: e.target.value})}
                        className="w-full px-4 py-3 bg-[#F9F9F9] border border-[#9CA3AF] text-guezs-black rounded-xl text-sm focus:outline-none focus:border-guezs-gold focus:ring-1 focus:ring-guezs-gold transition-all"
                        placeholder="votre@email.com"
                      />
                    </div>

                    <div>
                      <label className="block text-xs uppercase tracking-widest text-guezs-black/40 mb-2 font-medium">Votre message</label>
                      <textarea
                        required
                        rows={4}
                        value={formData.message}
                        onChange={(e) => setFormData({...formData, message: e.target.value})}
                        className="w-full px-4 py-3 bg-[#F9F9F9] border border-[#9CA3AF] text-guezs-black rounded-xl text-sm focus:outline-none focus:border-guezs-gold focus:ring-1 focus:ring-guezs-gold transition-all resize-none"
                        placeholder="Comment pouvons-nous vous aider ?"
                      />
                    </div>

                    {error && (
                      <p className="text-red-500 text-xs">{error}</p>
                    )}

                    <button
                      type="submit"
                      disabled={isSubmitting}
                      className="w-full py-4 bg-[#333333] text-white rounded-xl text-xs uppercase tracking-[0.2em] font-medium hover:bg-[#D4AF37] transition-all duration-300 disabled:opacity-50 mt-4"
                    >
                      {isSubmitting ? "Envoi en cours..." : "Envoyer le message"}
                    </button>
                  </form>
                )}
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
