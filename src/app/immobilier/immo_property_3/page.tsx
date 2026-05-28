"use client";
import { motion } from "framer-motion";
import Image from "next/image";
import ContactForm from "@/components/shared/ContactForm";

export default function PropertyDetail() {
  const property = {
    id: '3',
    title: "Résidence Émeraude",
    location: "Bonanjo, Douala",
    price: 175000000,
    type: 'Promotion',
    surface: 280,
    bedrooms: 4,
    image: "/assets/images/residence1.jpg",
    category: 'Luxe',
    description: "Magnifique résidence de standing situées dans le quartier prestigieux de Bonanjo. Construction haut de gamme avec finitions luxueuses.",
    amenities: [
      "Piscine privée",
      "Jardin aménagé",
      "Garage climatisé",
      "Système de sécurité 24/7",
      "Terrasse panoramique",
      "Cuisine équipée"
    ],
    details: {
      bathrooms: 3,
      livingRooms: 2,
      parking: 2,
      yearBuilt: 2023
    }
  };

  return (
    <main className="bg-guezs-white min-h-screen pt-32 pb-20">
      <div className="container mx-auto px-6">
        {/* En-tête */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="mb-12"
        >
          <div className="flex items-center gap-2 mb-4">
            <span className="text-guezs-gold font-body uppercase tracking-[0.3em] text-xs">
              {property.category}
            </span>
            <span className="px-3 py-1 bg-guezs-terracotta text-white text-xs uppercase rounded-full">
              {property.type}
            </span>
          </div>
          <h1 className="font-heading text-5xl text-guezs-black mb-4">
            {property.title}
          </h1>
          <p className="text-guezs-terracotta text-lg flex items-center gap-2">
            📍 {property.location}
          </p>
        </motion.div>

        {/* Grille principale */}
        <div className="grid md:grid-cols-3 gap-12 mb-20">
          {/* Image principale */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="md:col-span-2"
          >
            <div className="relative aspect-video rounded-lg overflow-hidden shadow-2xl">
              <Image
                src={property.image}
                alt={property.title}
                fill
                className="object-cover"
                priority
              />
            </div>
          </motion.div>

          {/* Informations et Prix */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, delay: 0.3 }}
            className="bg-guezs-black text-white p-8 rounded-lg h-fit"
          >
            <div className="mb-8">
              <p className="text-guezs-sand text-sm uppercase tracking-widest mb-2">Prix</p>
              <p className="text-4xl font-heading text-guezs-gold">
                {(property.price / 1000000).toFixed(0)}M XAF
              </p>
            </div>

            <div className="space-y-6 border-t border-guezs-sand/20 pt-6">
              <div className="flex justify-between items-center">
                <span className="text-guezs-sand">Surface</span>
                <span className="font-bold text-white">{property.surface} m²</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-guezs-sand">Chambres</span>
                <span className="font-bold text-white">{property.bedrooms}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-guezs-sand">Salles de bain</span>
                <span className="font-bold text-white">{property.details.bathrooms}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-guezs-sand">Année</span>
                <span className="font-bold text-white">{property.details.yearBuilt}</span>
              </div>
            </div>

            <button className="w-full mt-8 bg-guezs-gold text-guezs-black font-bold py-3 rounded-lg hover:bg-opacity-90 transition-all uppercase tracking-widest">
              Demander Une Visite
            </button>
          </motion.div>
        </div>

        {/* Description */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="mb-20"
        >
          <h2 className="font-heading text-3xl text-guezs-black mb-6">À Propos</h2>
          <p className="text-guezs-terracotta text-lg leading-relaxed max-w-3xl">
            {property.description}
          </p>
        </motion.section>

        {/* Équipements */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.5 }}
          className="mb-20"
        >
          <h2 className="font-heading text-3xl text-guezs-black mb-6">Équipements</h2>
          <div className="grid md:grid-cols-2 gap-4">
            {property.amenities.map((amenity, idx) => (
              <div key={idx} className="flex items-center gap-3 p-4 bg-guezs-black/5 rounded-lg">
                <span className="text-guezs-gold text-xl">✓</span>
                <span className="text-guezs-black">{amenity}</span>
              </div>
            ))}
          </div>
        </motion.section>

        {/* Formulaire de Contact */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.6 }}
          className="mb-20"
        >
          <h2 className="font-heading text-3xl text-guezs-black mb-10">Intéressé ?</h2>
          <div className="bg-guezs-black/5 p-12 rounded-lg">
            <ContactForm />
          </div>
        </motion.section>
      </div>
    </main>
  );
}
