"use client";
import { motion } from "framer-motion";
import Link from "next/link";

export default function AboutPage() {
  const poles = [
    {
      name: "Afro GUEZS Style",
      description: "Mode et identité. La célébration de l'élégance africaine contemporaine à travers des créations uniques.",
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01" />
        </svg>
      ),
      href: "/style",
      color: "guezs-gold"
    },
    {
      name: "GUEZS Immobilier",
      description: "Promotion et gestion. L'excellence immobilière au service de votre patrimoine.",
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
        </svg>
      ),
      href: "/immobilier",
      color: "guezs-terracotta"
    },
    {
      name: "GUEZS Piknik",
      description: "Événementiel et expériences. Des moments d'exception qui célèbrent l'art de vivre africain.",
      icon: (
        <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M21 15.546c-.523 0-1.046.151-1.5.454a2.704 2.704 0 01-3 0 2.704 2.704 0 00-3 0 2.704 2.704 0 01-3 0 2.704 2.704 0 00-3 0 2.704 2.704 0 01-3 0 2.701 2.701 0 00-1.5-.454M9 6v2m3-2v2m3-2v2M9 3h.01M12 3h.01M15 3h.01M21 21v-7a2 2 0 00-2-2H5a2 2 0 00-2 2v7h18zm-3-9v-2a2 2 0 00-2-2H8a2 2 0 00-2 2v2h12z" />
        </svg>
      ),
      href: "/piknik",
      color: "guezs-sand"
    }
  ];

  return (
    <main className="pt-32 pb-20 bg-guezs-white">
      {/* Section Histoire / Vision */}
      <section className="container mx-auto px-6 mb-24">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-16 items-center">
          <motion.div 
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
          >
            <span className="text-guezs-gold font-body uppercase tracking-[0.3em] text-xs mb-4 block">
              Notre Histoire
            </span>
            <h1 className="font-heading text-4xl md:text-6xl text-guezs-black mb-8">
              L'Essence de <br />
              <span className="text-guezs-gold">GUEZS HOUSE</span>
            </h1>
            <p className="font-body text-gray-700 leading-relaxed mb-6">
              GUEZS HOUSE est une marque ombrelle née de la volonté de fédérer l'excellence africaine sous une identité unique. 
              Nous croyons en un luxe qui respecte ses racines tout en embrassant la modernité contemporaine.
            </p>
            <p className="font-body text-gray-700 leading-relaxed mb-8">
              De l'immobilier à la mode, chaque pôle de la marque est animé par une quête de performance, de pérennité et d'adaptation au contexte africain.
            </p>
            <Link 
              href="/contact"
              className="inline-block px-8 py-4 bg-guezs-gold text-guezs-black font-bold uppercase tracking-widest text-sm hover:bg-guezs-black hover:text-guezs-gold transition-all duration-300"
            >
              Nous contacter
            </Link>
          </motion.div>
          
          <motion.div 
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="relative h-[500px] border-l-4 border-guezs-gold pl-4"
          >
            <img 
              src="/assets/images/about-vision.jpg" 
              alt="Vision GUEZS HOUSE" 
              className="w-full h-full object-cover grayscale hover:grayscale-0 transition-all duration-1000"
            />
            <div className="absolute -bottom-6 -right-6 bg-guezs-black text-guezs-gold p-6 font-heading text-xl">
              Depuis 2020
            </div>
          </motion.div>
        </div>
      </section>

      {/* Section Valeurs */}
      <section className="bg-guezs-black py-24 text-guezs-white">
        <div className="container mx-auto px-6 text-center mb-16">
          <span className="text-guezs-terracotta font-body uppercase tracking-[0.3em] text-xs mb-4 block">
            Ce qui nous guide
          </span>
          <h2 className="font-heading text-3xl md:text-4xl uppercase tracking-widest text-guezs-gold">
            Nos Valeurs Fondamentales
          </h2>
        </div>
        
        <div className="container mx-auto px-6 grid grid-cols-1 md:grid-cols-3 gap-12">
          {[
            { 
              title: "Excellence", 
              desc: "Une exigence de qualité supérieure dans tous nos services. Chaque détail compte.",
              num: "01"
            },
            { 
              title: "Identité Afro", 
              desc: "La valorisation de notre culture et de notre héritage à travers chaque création.",
              num: "02"
            },
            { 
              title: "Innovation", 
              desc: "Une approche moderne et professionnelle de l'entrepreneuriat africain.",
              num: "03"
            }
          ].map((val, i) => (
            <motion.div 
              key={i}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.2 }}
              className="group p-10 border border-guezs-gold/20 text-center hover:border-guezs-gold hover:bg-guezs-gold/5 transition-all duration-500"
            >
              <span className="font-heading text-5xl text-guezs-gold/20 group-hover:text-guezs-gold/40 transition-colors">
                {val.num}
              </span>
              <h3 className="font-heading text-2xl text-guezs-gold mb-4 mt-4">{val.title}</h3>
              <p className="text-guezs-sand/70 text-sm leading-loose">{val.desc}</p>
            </motion.div>
          ))}
        </div>
      </section>

      {/* Section Les Pôles */}
      <section className="py-24 bg-guezs-sand/20">
        <div className="container mx-auto px-6">
          <div className="text-center mb-16">
            <span className="text-guezs-gold font-body uppercase tracking-[0.3em] text-xs mb-4 block">
              Notre Écosystème
            </span>
            <h2 className="font-heading text-3xl md:text-4xl text-guezs-black uppercase tracking-widest mb-4">
              Les Pôles GUEZS HOUSE
            </h2>
            <p className="text-gray-600 max-w-2xl mx-auto">
              Trois univers complémentaires unis par une même vision de l'excellence africaine.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {poles.map((pole, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.15 }}
                className="group bg-guezs-white p-10 border border-guezs-gold/10 hover:border-guezs-gold/40 hover:shadow-2xl transition-all duration-500"
              >
                <div className="text-guezs-gold mb-6 group-hover:scale-110 transition-transform duration-300">
                  {pole.icon}
                </div>
                <h3 className="font-heading text-xl text-guezs-black mb-4 group-hover:text-guezs-gold transition-colors">
                  {pole.name}
                </h3>
                <p className="text-gray-600 text-sm leading-relaxed mb-6">
                  {pole.description}
                </p>
                <Link 
                  href={pole.href}
                  className="inline-flex items-center gap-2 text-xs uppercase tracking-widest text-guezs-gold font-bold group-hover:gap-4 transition-all"
                >
                  <span>Découvrir</span>
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 8l4 4m0 0l-4 4m4-4H3" />
                  </svg>
                </Link>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Section CTA */}
      <section className="py-20 bg-guezs-black">
        <div className="container mx-auto px-6 text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
          >
            <h2 className="font-heading text-3xl md:text-4xl text-guezs-gold mb-6">
              Prêt à rejoindre l'univers GUEZS ?
            </h2>
            <p className="text-guezs-sand/70 max-w-xl mx-auto mb-10">
              Que vous cherchiez un bien d'exception, une pièce de mode unique ou une expérience mémorable, nous sommes là pour vous.
            </p>
            <div className="flex flex-col md:flex-row gap-4 justify-center">
              <Link 
                href="/contact"
                className="px-10 py-4 bg-guezs-gold text-guezs-black font-bold uppercase tracking-widest hover:bg-guezs-white transition-colors"
              >
                Contactez-nous
              </Link>
              <Link 
                href="/"
                className="px-10 py-4 border border-guezs-sand text-guezs-sand font-bold uppercase tracking-widest hover:bg-guezs-sand hover:text-guezs-black transition-all"
              >
                Retour à l'accueil
              </Link>
            </div>
          </motion.div>
        </div>
      </section>
    </main>
  );
}
