"use client";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { motion } from "framer-motion";

// Schéma de validation conforme au contexte camerounais/africain
const contactSchema = z.object({
  name: z.string().min(2, "Le nom est requis"),
  email: z.string().email("Email invalide"),
  phone: z.string().min(9, "Numéro de téléphone invalide"),
  service: z.enum(["Immobilier", "Style", "Piknik", "Autre"]),
  message: z.string().min(10, "Votre message est trop court"),
});

type ContactFormData = z.infer<typeof contactSchema>;

export default function ContactForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<ContactFormData>({
    resolver: zodResolver(contactSchema),
  });

  const onSubmit = async (data: ContactFormData) => {
    // Simulation d'envoi vers Firebase ou une API
    await new Promise((resolve) => setTimeout(resolve, 2000));
    console.log("Données envoyées :", data);
    alert("Merci ! GUEZS HOUSE reviendra vers vous sous peu.");
  };

  return (
    <section className="py-24 bg-guezs-sand/30">
      <div className="max-w-4xl mx-auto px-6 bg-guezs-white p-12 shadow-2xl border border-guezs-gold/10">
        {/* En-tête */}
        <div className="text-center mb-12">
          <span className="text-guezs-gold font-body uppercase tracking-[0.3em] text-xs mb-4 block">
            Parlons de votre projet
          </span>
          <h2 className="font-heading text-3xl md:text-4xl text-guezs-black uppercase tracking-widest">
            Demande de Devis & Contact
          </h2>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* Nom complet */}
          <div className="flex flex-col">
            <label className="text-xs uppercase tracking-widest text-guezs-terracotta mb-3 font-body">
              Nom Complet
            </label>
            <input 
              {...register("name")}
              className={`p-4 bg-transparent border-b-2 ${errors.name ? 'border-red-500' : 'border-guezs-gold/30'} focus:border-guezs-black outline-none transition-colors font-body`}
              placeholder="Ex: Jean Essomba"
            />
            {errors.name && (
              <motion.span 
                initial={{ opacity: 0, y: -5 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-[10px] text-red-500 mt-2 uppercase tracking-wider"
              >
                {errors.name.message}
              </motion.span>
            )}
          </div>

          {/* Email */}
          <div className="flex flex-col">
            <label className="text-xs uppercase tracking-widest text-guezs-terracotta mb-3 font-body">
              Email Professionnel
            </label>
            <input 
              {...register("email")}
              type="email"
              className={`p-4 bg-transparent border-b-2 ${errors.email ? 'border-red-500' : 'border-guezs-gold/30'} focus:border-guezs-black outline-none transition-colors font-body`}
              placeholder="jean@exemple.cm"
            />
            {errors.email && (
              <motion.span 
                initial={{ opacity: 0, y: -5 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-[10px] text-red-500 mt-2 uppercase tracking-wider"
              >
                {errors.email.message}
              </motion.span>
            )}
          </div>

          {/* Téléphone (Crucial pour le contexte local) */}
          <div className="flex flex-col">
            <label className="text-xs uppercase tracking-widest text-guezs-terracotta mb-3 font-body">
              Téléphone (WhatsApp)
            </label>
            <input 
              {...register("phone")}
              type="tel"
              className={`p-4 bg-transparent border-b-2 ${errors.phone ? 'border-red-500' : 'border-guezs-gold/30'} focus:border-guezs-black outline-none transition-colors font-body`}
              placeholder="+237 6XX XXX XXX"
            />
            {errors.phone && (
              <motion.span 
                initial={{ opacity: 0, y: -5 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-[10px] text-red-500 mt-2 uppercase tracking-wider"
              >
                {errors.phone.message}
              </motion.span>
            )}
          </div>

          {/* Service concerné */}
          <div className="flex flex-col">
            <label className="text-xs uppercase tracking-widest text-guezs-terracotta mb-3 font-body">
              Service
            </label>
            <select 
              {...register("service")}
              className="p-4 bg-transparent border-b-2 border-guezs-gold/30 focus:border-guezs-black outline-none transition-colors font-body cursor-pointer"
            >
              <option value="Immobilier">GUEZS Immobilier</option>
              <option value="Style">GUEZS Style</option>
              <option value="Piknik">GUEZS Piknik</option>
              <option value="Autre">Autre demande</option>
            </select>
          </div>

          {/* Message */}
          <div className="flex flex-col md:col-span-2 mt-4">
            <label className="text-xs uppercase tracking-widest text-guezs-terracotta mb-3 font-body">
              Votre Projet / Message
            </label>
            <textarea 
              {...register("message")}
              rows={5}
              className={`p-4 bg-transparent border-2 ${errors.message ? 'border-red-500' : 'border-guezs-gold/30'} focus:border-guezs-black outline-none transition-colors font-body resize-none`}
              placeholder="Décrivez votre projet ou votre besoin..."
            />
            {errors.message && (
              <motion.span 
                initial={{ opacity: 0, y: -5 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-[10px] text-red-500 mt-2 uppercase tracking-wider"
              >
                {errors.message.message}
              </motion.span>
            )}
          </div>

          {/* Bouton Submit */}
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            disabled={isSubmitting}
            type="submit"
            className="md:col-span-2 bg-guezs-black text-guezs-gold py-5 uppercase tracking-[0.3em] font-bold mt-8 hover:bg-guezs-gold hover:text-guezs-black transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSubmitting ? (
              <span className="flex items-center justify-center gap-3">
                <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                </svg>
                Envoi en cours...
              </span>
            ) : (
              "Envoyer la demande"
            )}
          </motion.button>
        </form>
      </div>
    </section>
  );
}
