"use client";
import Image from "next/image";
import { motion } from "framer-motion";

export default function PromoterSection() {
  return (
    <section
      className="w-full relative bg-guezs-sand text-guezs-black py-24 md:py-32 overflow-hidden"
    >
      {/* Decorative Background Elements */}
      <div className="absolute top-0 right-0 w-1/3 h-full bg-gradient-to-l from-black/[0.02] to-transparent pointer-events-none" />
      <div className="absolute -left-20 top-20 w-64 h-64 border-[1px] border-guezs-gold/20 rounded-full blur-[1px] pointer-events-none" />

      <div className="container mx-auto px-6 md:px-12 relative z-10 lg:max-w-7xl">
        <div className="flex flex-col lg:flex-row items-center gap-12 lg:gap-24">

          {/* Aesthetic Photo Frame */}
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 1, ease: "easeOut" }}
            className="w-full lg:w-5/12 relative group shrink-0 mx-auto max-w-sm sm:max-w-md lg:max-w-none"
          >
            {/* Elegant outer frame */}
            <div className="absolute -inset-4 md:-inset-6 border-[0.5px] border-guezs-gold/40 rounded-t-[100px] md:rounded-t-[140px] rounded-b-[20px] transition-all duration-700 group-hover:border-guezs-gold/80 group-hover:scale-[1.02]" />
            <div className="absolute -inset-8 md:-inset-10 border border-black/5 rounded-t-[120px] md:rounded-t-[160px] rounded-b-[30px]" />

            {/* Image Container */}
            <div className="relative aspect-[3/4] md:aspect-[4/5] rounded-t-[80px] md:rounded-t-[120px] rounded-b-xl overflow-hidden shadow-[0_20px_50px_rgba(0,0,0,0.15)] bg-black/5">
              <Image
                src="/assets/images/Yvette6.jpg"
                alt="Yvette Germaine MENGUE - Fondatrice GUEZS HOUSE"
                fill
                className="object-cover object-center transition-transform duration-1000 group-hover:scale-105"
                sizes="(max-width: 1024px) 90vw, 40vw"
                quality={95}
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/30 via-transparent to-transparent pointer-events-none" />
            </div>

            {/* Name label that slightly overlaps */}
            <div className="absolute -right-2 md:-right-8 bottom-12 md:bottom-16 bg-white py-3 px-5 md:py-4 md:px-6 shadow-xl rounded-sm z-20 hidden sm:block">
               <span className="block text-[10px] md:text-xs uppercase tracking-[0.3em] font-body text-guezs-black/50 mb-1">Fondatrice</span>
               <span className="block font-heading text-lg md:text-xl text-guezs-black m-0 leading-none">Yvette MENGUE</span>
            </div>
          </motion.div>

          {/* Presentation Text */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 1, delay: 0.2, ease: "easeOut" }}
            className="w-full lg:w-7/12 flex flex-col justify-center"
          >
            <div className="mb-6 md:mb-8 flex items-center gap-4">
              <span className="w-8 md:w-12 h-[1px] bg-guezs-gold"></span>
              <span className="text-xs md:text-sm font-body uppercase tracking-[0.2em] text-guezs-black/60 font-medium">La Promotrice</span>
            </div>

            <h2 className="font-heading text-4xl md:text-5xl lg:text-7xl text-guezs-black leading-[1.05] mb-8 md:mb-10 text-balance tracking-tight">
              L'Âme Derrière <br />
              <span className="italic font-light text-guezs-gold">L'Excellence.</span>
            </h2>

            <div className="font-body text-sm md:text-base leading-relaxed text-guezs-black/80 space-y-5 md:space-y-6 max-w-2xl">
              <p className="text-lg md:text-xl text-guezs-black font-medium leading-relaxed">
                <strong className="font-heading font-semibold text-2xl md:text-3xl block mb-2">Yvette Germaine MENGUE</strong>
                Une jeune femme dynamique, portée par une vision audacieuse du management et la réalisation de projets novateurs.
              </p>

              <p>
                Fondatrice et promotrice visionnaire de <strong className="font-medium text-guezs-black">Guezs House</strong>, <strong className="font-medium text-guezs-black">Guezs Restaurants</strong>, et <strong className="font-medium text-guezs-black">Guezs Films</strong>, Yvette incarne l'alliance parfaite entre l'élégance contemporaine et l'ambition entrepreneuriale. Elle a su bâtir un écosystème prestigieux où chaque détail est pensé pour offrir une expérience inoubliable.
              </p>

              <div className="pl-6 border-l w-full border-guezs-gold/50 py-2 my-8 relative">
                <div className="absolute top-0 left-0 w-[1px] h-full bg-gradient-to-b from-guezs-gold via-guezs-gold/80 to-guezs-gold/20" />
                <p className="italic text-base md:text-lg lg:text-xl font-heading text-guezs-black/90 leading-relaxed">
                  "L'excellence n'est pas un acte, mais une habitude. Mon ambition est de créer des espaces et des expériences qui transcendent l'ordinaire."
                </p>
              </div>

              <p>
                De l'immobilier de haut standing à la production cinématographique, en passant par la gastronomie et l'événementiel, son approche globale du leadership fait de ses réalisations de véritables références. Passionnée par l'innovation et le raffinement, elle continue de repousser les limites pour redéfinir les standards du luxe et du bien-être afro-contemporain.
              </p>
            </div>
          </motion.div>

        </div>
      </div>
    </section>
  );
}
