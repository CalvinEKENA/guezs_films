"use client";
import { motion } from "framer-motion";

const BEAUTY_PRODUCTS = [
  {
    id: "slim-the",
    name: "Slim GUEZS Thé",
    category: "Bien-être",
    description: "Thé amincissant Bio pour une détoxification profonde.",
    price: "Prix sur demande",
    image: "/assets/images/beauty_product9.jpeg",
    whatsappMsg: "Bonjour, je souhaite commander le Slim GUEZS Thé."
  },
  {
    id: "diamond-serum",
    name: "Sérum Diamond",
    category: "Soin Visage",
    description: "Actif tonifiant au collagène et vitamines pour un éclat immédiat.",
    price: "Prix sur demande",
    image: "/assets/images/beauty_product6.jpeg",
    whatsappMsg: "Bonjour, j'aimerais des informations sur le Sérum Diamond."
  },
  {
    id: "collagen-supp",
    name: "Food Supplement Collagen",
    category: "Complément",
    description: "Soin interne pour raffermir la peau et ressortir son éclat.",
    price: "Prix sur demande",
    image: "/assets/images/beauty_product1.jpeg",
    whatsappMsg: "Bonjour, je suis intéressé par le complément au Collagène."
  }
];

export default function ProductCatalogue() {
  const WHATSAPP_NUMBER = "237697773548";

  return (
    <section className="w-full relative flex flex-col justify-center overflow-hidden pb-24 md:pb-32">
      
      {/* HEADER SECTION (Split Layout) */}
      <div className="container mx-auto px-6 md:px-12 mb-12 md:mb-16">
        <div className="flex flex-col md:flex-row relative">
          
          <div className="hidden md:block absolute left-1/2 top-4 bottom-[-60px] w-px bg-guezs-black/20 -translate-x-1/2" />

          {/* Left Column : Titles */}
          <div className="w-full md:w-1/2 md:pr-20 mb-12 md:mb-0">
             <span className="text-guezs-black/40 font-body uppercase tracking-[0.3em] text-[10px] md:text-xs mb-6 block">
               BEAUTÉ & SOINS
             </span>
             <h2 className="font-heading text-5xl md:text-7xl lg:text-8xl text-guezs-black leading-[0.9] tracking-tight">
               GUEZS
               <br/>
               <span className="italic">Cosmétique</span>
             </h2>
          </div>

          {/* Right Column : Description & Actions */}
          <div className="w-full md:w-1/2 md:pl-20 flex flex-col justify-end">
             <p className="font-body text-guezs-black/70 text-sm md:text-base leading-relaxed mb-6 max-w-sm">
               L'excellence au service de votre peau. Des produits de soins haut de gamme formulés pour révéler votre éclat naturel.
             </p>
             
             {/* Navigation rapide */}
             <div className="flex items-center gap-4 mt-6">
               <a 
                 href={`mailto:contact@guezshouse.com`}
                 className="text-[10px] md:text-xs uppercase tracking-widest font-bold text-guezs-black/40 hover:text-guezs-gold transition-colors"
               >
                 Demander le catalogue PDF →
               </a>
             </div>
          </div>
        </div>
      </div>

      {/* CATALOGUE GRID */}
      <div className="container mx-auto px-6 md:px-12">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10 md:gap-14">
          {BEAUTY_PRODUCTS.map((product, index) => (
            <motion.div 
              key={product.id}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ delay: index * 0.1, duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
              className="bg-white group rounded-[40px] overflow-hidden shadow-sm hover:shadow-xl transition-all duration-500 border border-guezs-black/5 flex flex-col"
            >
              <div className="relative h-[22rem] overflow-hidden bg-black/5">
                <img 
                  src={product.image} 
                  alt={product.name}
                  className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110"
                />
                <div className="absolute inset-0 bg-guezs-black/5 group-hover:bg-guezs-black/0 transition-all duration-500" />
                
                {/* Badge Catégorie */}
                <div className="absolute top-6 left-6 bg-white/90 backdrop-blur-sm px-4 py-2 rounded-full text-[10px] font-bold uppercase tracking-widest text-guezs-black">
                  {product.category}
                </div>
              </div>
              
              <div className="p-8 md:p-10 flex flex-col flex-grow bg-white">
                <h3 className="font-heading text-3xl mb-4 text-guezs-black group-hover:text-guezs-gold transition-colors">{product.name}</h3>
                <p className="text-guezs-black/60 font-body text-sm mb-8 leading-relaxed flex-grow">
                  {product.description}
                </p>
                
                 <div className="flex flex-col gap-4 mt-auto border-t border-guezs-black/10 pt-8">
                  <div className="flex justify-between items-center mb-2">
                     <span className="text-[10px] uppercase tracking-widest text-guezs-black font-bold">Prix</span>
                     <span className="font-heading text-xl text-guezs-gold font-bold">{product.price}</span>
                  </div>
                  <a 
                    href={`https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent(product.whatsappMsg)}`}
                    target="_blank"
                    className="w-full bg-[#25D366] hover:bg-[#128C7E] text-white text-center py-4 rounded-full text-[10px] uppercase tracking-[0.2em] transition-all font-black shadow-lg flex items-center justify-center gap-2"
                  >
                    <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L0 24l6.335-1.662c1.72.937 3.659 1.432 5.631 1.433h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
                    Commander via WhatsApp
                  </a>
                  <button className="w-full border border-[#333333] text-[#333333] py-4 rounded-full text-[10px] uppercase tracking-[0.2em] hover:bg-[#333333] hover:text-white transition-all font-black">
                    Détails du produit
                  </button>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>

    </section>
  );
}
