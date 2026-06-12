"use client";

import Image from "next/image";
import { AnimatePresence, motion } from "framer-motion";
import {
  BadgeCheck,
  Bath,
  BedDouble,
  Building2,
  Camera,
  Car,
  ChevronRight,
  Gem,
  Home,
  KeyRound,
  MapPin,
  PhoneCall,
  Ruler,
  Trees,
} from "lucide-react";
import { useMemo, useState } from "react";

type MenuFilter = "Tous" | "Vente" | "Location" | "VIP";

type GalleryImage = {
  src: string;
  label: string;
  alt: string;
  focus?: string;
};

type Listing = {
  id: string;
  title: string;
  location: string;
  price: string;
  type: "Vente" | "Location";
  surface: string;
  bedrooms: string;
  image: string;
  category: "VIP" | "Luxe" | "Business" | "Standard";
};

const FILTERS: Array<{
  label: MenuFilter;
  icon: typeof Home;
}> = [
  { label: "Tous", icon: Home },
  { label: "Vente", icon: KeyRound },
  { label: "Location", icon: Building2 },
  { label: "VIP", icon: Gem },
];

const FEATURED_IMAGES: GalleryImage[] = [
  {
    src: "/assets/images/febe-triplex-jardin.png",
    label: "Jardin",
    alt: "Jardin et façade du triplex Febe Village",
    focus: "center",
  },
  {
    src: "/assets/images/febe-triplex-facade-nuit.png",
    label: "Façade nuit",
    alt: "Façade de nuit du triplex Febe Village",
    focus: "center",
  },
  {
    src: "/assets/images/febe-triplex-entree.png",
    label: "Entrée",
    alt: "Entrée avec colonnes du triplex Febe Village",
    focus: "center",
  },
  {
    src: "/assets/images/febe-triplex-suite.png",
    label: "Suite",
    alt: "Suite intérieure avec balcon du triplex Febe Village",
    focus: "center",
  },
  {
    src: "/assets/images/febe-triplex-salle-de-bain.png",
    label: "Bain",
    alt: "Salle de bain moderne du triplex Febe Village",
    focus: "center",
  },
];

const VIP_DETAILS = [
  {
    title: "Sous-sol",
    text: "Buanderie, chambre et toilette indépendante.",
  },
  {
    title: "Rez-de-chaussée",
    text: "1 salon, 1 salle à manger, 1 chambre, 1 cuisine et 2 douches.",
  },
  {
    title: "Étage",
    text: "3 chambres, 3 salles de bain et 2 balcons.",
  },
  {
    title: "Dépendance",
    text: "1 salon, 2 chambres, 2 douches et 1 cuisine à l'étage.",
  },
];

const LISTINGS: Listing[] = [
  {
    id: "febe-triplex",
    title: "Triplex Hyper Chic",
    location: "Febe Village, Yaoundé",
    price: "550M FCFA",
    type: "Vente",
    surface: "800 m² titré",
    bedrooms: "6+ chambres",
    image: "/assets/images/febe-triplex-jardin.png",
    category: "VIP",
  },
  {
    id: "villa-horizon",
    title: "Villa Horizon",
    location: "Bastos, Yaoundé",
    price: "250M FCFA",
    type: "Vente",
    surface: "450 m2",
    bedrooms: "5 chambres",
    image: "/assets/images/villa1.jpg",
    category: "Luxe",
  },
  {
    id: "appartement-chic",
    title: "Appartement Chic",
    location: "Bonapriso, Douala",
    price: "800K FCFA",
    type: "Location",
    surface: "120 m2",
    bedrooms: "2 chambres",
    image: "/assets/images/appat1.jpg",
    category: "Business",
  },
  {
    id: "studio-moderne",
    title: "Studio Moderne",
    location: "Akwa, Douala",
    price: "350K FCFA",
    type: "Location",
    surface: "45 m2",
    bedrooms: "1 chambre",
    image: "/assets/images/studio1.jpg",
    category: "Standard",
  },
  {
    id: "duplex-prestige",
    title: "Duplex Prestige",
    location: "Omnisport, Yaounde",
    price: "95M FCFA",
    type: "Vente",
    surface: "200 m2",
    bedrooms: "3 chambres",
    image: "/assets/images/duplex1.jpg",
    category: "Luxe",
  },
  {
    id: "bureau-standing",
    title: "Bureau Standing",
    location: "Centre-ville, Douala",
    price: "1.5M FCFA",
    type: "Location",
    surface: "180 m2",
    bedrooms: "Open space",
    image: "/assets/images/bureau1.jpg",
    category: "Business",
  },
];

const statItems = [
  { icon: Ruler, label: "800 m² titré" },
  { icon: BedDouble, label: "6+ chambres" },
  { icon: Bath, label: "7 douches" },
  { icon: Trees, label: "Jardin privé" },
  { icon: Car, label: "Parking clôturé" },
];

export default function ImmobilierGrid() {
  const [filter, setFilter] = useState<MenuFilter>("Tous");
  const [activeImage, setActiveImage] = useState(0);

  const visibleListings = useMemo(() => {
    if (filter === "Tous") {
      return LISTINGS;
    }

    if (filter === "VIP") {
      return LISTINGS.filter((listing) => listing.category === "VIP");
    }

    return LISTINGS.filter((listing) => listing.type === filter);
  }, [filter]);

  const selectedImage = FEATURED_IMAGES[activeImage];

  return (
    <section className="relative w-full overflow-hidden bg-[#10100f] text-white">
      <div className="absolute inset-0 bg-[linear-gradient(120deg,rgba(212,175,55,0.12),transparent_34%,rgba(34,84,69,0.22)_68%,transparent)]" />
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-guezs-gold/70 to-transparent" />

      <div className="container relative mx-auto px-6 py-24 md:px-12 md:py-32">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.35 }}
          transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
          className="mb-14 grid gap-10 lg:grid-cols-[0.95fr_1.05fr] lg:items-end"
        >
          <div>
            <span className="mb-5 inline-flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.28em] text-guezs-gold">
              <Gem size={16} aria-hidden="true" />
              Menu immobilier VIP
            </span>
            <h2 className="font-heading text-5xl font-medium leading-[0.92] text-white md:text-7xl lg:text-8xl">
              Maisons à louer
              <span className="block italic text-guezs-gold">et à vendre</span>
            </h2>
          </div>

          <div className="lg:justify-self-end">
            <p className="max-w-xl text-sm leading-7 text-white/70 md:text-base">
              Sélection de résidences haut de gamme avec une mise en avant du
              triplex hyper chic et luxueux de Febe Village, disponible en visite
              sur rendez-vous.
            </p>

            <div className="mt-8 grid grid-cols-2 gap-2 rounded-lg border border-white/10 bg-white/[0.04] p-2 backdrop-blur md:flex md:w-max">
              {FILTERS.map(({ label, icon: Icon }) => {
                const isActive = filter === label;

                return (
                  <button
                    key={label}
                    type="button"
                    onClick={() => setFilter(label)}
                    className={`relative flex h-12 min-w-0 items-center justify-center gap-2 rounded-md px-4 text-xs font-semibold uppercase tracking-[0.14em] transition md:min-w-32 ${
                      isActive
                        ? "text-[#10100f]"
                        : "text-white/60 hover:bg-white/[0.06] hover:text-white"
                    }`}
                    aria-pressed={isActive}
                  >
                    {isActive && (
                      <motion.span
                        layoutId="vipFilter"
                        className="absolute inset-0 rounded-md bg-guezs-gold"
                        transition={{ type: "spring", stiffness: 350, damping: 30 }}
                      />
                    )}
                    <Icon className="relative z-10 h-4 w-4" aria-hidden="true" />
                    <span className="relative z-10 truncate">{label}</span>
                  </button>
                );
              })}
            </div>
          </div>
        </motion.div>

        <div className="grid gap-8 lg:grid-cols-[1.25fr_0.75fr]">
          <motion.div
            initial={{ opacity: 0, y: 32 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, amount: 0.25 }}
            transition={{ duration: 0.7, delay: 0.08, ease: [0.22, 1, 0.36, 1] }}
            className="relative overflow-hidden rounded-lg border border-white/10 bg-white/[0.03]"
          >
            <div className="relative aspect-[4/5] min-h-[520px] overflow-hidden md:aspect-[16/10]">
              <AnimatePresence mode="wait">
                <motion.div
                  key={selectedImage.src}
                  initial={{ opacity: 0, scale: 1.04 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 1.02 }}
                  transition={{ duration: 0.75, ease: [0.22, 1, 0.36, 1] }}
                  className="absolute inset-0"
                >
                  <Image
                    src={selectedImage.src}
                    alt={selectedImage.alt}
                    fill
                    sizes="(min-width: 1024px) 58vw, 100vw"
                    className="object-cover"
                    style={{ objectPosition: selectedImage.focus ?? "center" }}
                    priority={activeImage === 0}
                  />
                </motion.div>
              </AnimatePresence>

              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-black/10" />
              <motion.div
                className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-guezs-gold to-transparent"
                animate={{ x: ["-30%", "30%"], opacity: [0.45, 1, 0.45] }}
                transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
              />

              <div className="absolute left-5 top-5 flex flex-wrap gap-2 md:left-8 md:top-8">
                <span className="inline-flex items-center gap-2 rounded-md bg-black/55 px-3 py-2 text-xs font-semibold uppercase tracking-[0.16em] text-guezs-gold backdrop-blur">
                  <BadgeCheck size={15} aria-hidden="true" />
                  Titre foncier
                </span>
                <span className="rounded-md bg-guezs-gold px-3 py-2 text-xs font-bold uppercase tracking-[0.16em] text-[#10100f]">
                  Vente VIP
                </span>
              </div>

              <div className="absolute bottom-0 left-0 right-0 p-5 md:p-8">
                <div className="max-w-3xl">
                  <p className="mb-3 flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.22em] text-white/70">
                    <MapPin size={15} aria-hidden="true" />
                    Cameroun, Yaoundé, Febe Village
                  </p>
                  <h3 className="font-heading text-4xl font-medium leading-none text-white md:text-6xl">
                    Triplex hyper chic et luxueux
                  </h3>
                  <div className="mt-6 flex flex-wrap gap-2">
                    {statItems.map(({ icon: Icon, label }) => (
                      <span
                        key={label}
                        className="inline-flex h-10 items-center gap-2 rounded-md border border-white/10 bg-white/10 px-3 text-xs font-medium text-white/85 backdrop-blur"
                      >
                        <Icon size={15} className="text-guezs-gold" aria-hidden="true" />
                        {label}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-5 gap-2 border-t border-white/10 bg-black/35 p-2 md:gap-3 md:p-3">
              {FEATURED_IMAGES.map((image, index) => {
                const isSelected = index === activeImage;

                return (
                  <button
                    key={image.src}
                    type="button"
                    onClick={() => setActiveImage(index)}
                    className={`group relative aspect-[4/3] overflow-hidden rounded-md border transition ${
                      isSelected
                        ? "border-guezs-gold"
                        : "border-white/10 hover:border-white/45"
                    }`}
                    aria-label={`Afficher ${image.label}`}
                  >
                    <Image
                      src={image.src}
                      alt={image.alt}
                      fill
                      sizes="20vw"
                      className="object-cover transition duration-500 group-hover:scale-105"
                      style={{ objectPosition: image.focus ?? "center" }}
                    />
                    <span className="absolute inset-x-0 bottom-0 bg-black/65 px-1 py-1 text-[10px] font-semibold uppercase tracking-[0.08em] text-white/90">
                      {image.label}
                    </span>
                  </button>
                );
              })}
            </div>
          </motion.div>

          <motion.aside
            initial={{ opacity: 0, y: 32 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, amount: 0.25 }}
            transition={{ duration: 0.7, delay: 0.18, ease: [0.22, 1, 0.36, 1] }}
            className="rounded-lg border border-guezs-gold/25 bg-[#f7f1df] p-6 text-[#10100f] shadow-[0_24px_80px_rgba(0,0,0,0.24)] md:p-8"
          >
            <div className="mb-7 flex items-start justify-between gap-4 border-b border-[#10100f]/10 pb-6">
              <div>
                <span className="text-xs font-bold uppercase tracking-[0.2em] text-[#8c6b19]">
                  Prix demandé
                </span>
                <p className="mt-2 font-heading text-5xl leading-none text-[#10100f]">
                  550M
                </p>
                <p className="mt-1 text-xs font-semibold uppercase tracking-[0.18em] text-[#10100f]/55">
                  FCFA légèrement discutable
                </p>
              </div>
              <div className="flex h-14 w-14 items-center justify-center rounded-lg bg-[#10100f] text-guezs-gold">
                <Gem size={28} aria-hidden="true" />
              </div>
            </div>

            <div className="space-y-3">
              {VIP_DETAILS.map((detail, index) => (
                <motion.div
                  key={detail.title}
                  initial={{ opacity: 0, x: 20 }}
                  whileInView={{ opacity: 1, x: 0 }}
                  viewport={{ once: true, amount: 0.5 }}
                  transition={{ duration: 0.45, delay: index * 0.06 }}
                  className="rounded-lg border border-[#10100f]/10 bg-white/60 p-4"
                >
                  <div className="mb-2 flex items-center gap-2 text-xs font-bold uppercase tracking-[0.16em] text-[#8c6b19]">
                    <ChevronRight size={15} aria-hidden="true" />
                    {detail.title}
                  </div>
                  <p className="text-sm leading-6 text-[#10100f]/72">{detail.text}</p>
                </motion.div>
              ))}
            </div>

            <div className="mt-7 rounded-lg border border-[#10100f]/10 bg-[#10100f] p-5 text-white">
              <p className="mb-4 flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.18em] text-guezs-gold">
                <Camera size={15} aria-hidden="true" />
                Visites sur rendez-vous
              </p>
              <div className="grid gap-3 sm:grid-cols-2">
                <a
                  href="tel:+237697773548"
                  className="inline-flex h-12 items-center justify-center gap-2 rounded-md bg-guezs-gold px-4 text-xs font-bold uppercase tracking-[0.12em] text-[#10100f] transition hover:bg-white"
                >
                  <PhoneCall size={16} aria-hidden="true" />
                  697 773 548
                </a>
                <a
                  href="tel:+237676606503"
                  className="inline-flex h-12 items-center justify-center gap-2 rounded-md border border-white/20 px-4 text-xs font-bold uppercase tracking-[0.12em] text-white transition hover:border-guezs-gold hover:text-guezs-gold"
                >
                  <PhoneCall size={16} aria-hidden="true" />
                  676 606 503
                </a>
              </div>
            </div>
          </motion.aside>
        </div>

        <motion.div layout className="mt-14 grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          <AnimatePresence mode="popLayout">
            {visibleListings.map((listing, index) => (
              <motion.article
                key={listing.id}
                layout
                initial={{ opacity: 0, y: 24 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.97 }}
                transition={{ duration: 0.45, delay: index * 0.03, ease: [0.22, 1, 0.36, 1] }}
                className="group overflow-hidden rounded-lg border border-white/10 bg-white/[0.045] backdrop-blur"
              >
                <div className="relative aspect-[16/10] overflow-hidden">
                  <Image
                    src={listing.image}
                    alt={listing.title}
                    fill
                    sizes="(min-width: 1280px) 31vw, (min-width: 768px) 48vw, 100vw"
                    className="object-cover transition duration-700 group-hover:scale-105"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/75 via-black/5 to-transparent" />
                  <div className="absolute left-4 top-4 flex gap-2">
                    <span className="rounded-md bg-white/90 px-3 py-2 text-[10px] font-bold uppercase tracking-[0.14em] text-[#10100f]">
                      {listing.type}
                    </span>
                    <span className="rounded-md bg-guezs-gold px-3 py-2 text-[10px] font-bold uppercase tracking-[0.14em] text-[#10100f]">
                      {listing.category}
                    </span>
                  </div>
                </div>

                <div className="p-5">
                  <div className="mb-4 flex items-start justify-between gap-4">
                    <div>
                      <h3 className="font-heading text-3xl leading-none text-white transition group-hover:text-guezs-gold">
                        {listing.title}
                      </h3>
                      <p className="mt-2 flex items-center gap-2 text-xs uppercase tracking-[0.14em] text-white/50">
                        <MapPin size={14} aria-hidden="true" />
                        {listing.location}
                      </p>
                    </div>
                    <p className="shrink-0 text-right text-sm font-bold uppercase tracking-[0.1em] text-guezs-gold">
                      {listing.price}
                    </p>
                  </div>

                  <div className="flex flex-wrap gap-2 border-t border-white/10 pt-4 text-xs text-white/70">
                    <span className="inline-flex h-9 items-center gap-2 rounded-md bg-white/[0.06] px-3">
                      <Ruler size={14} className="text-guezs-gold" aria-hidden="true" />
                      {listing.surface}
                    </span>
                    <span className="inline-flex h-9 items-center gap-2 rounded-md bg-white/[0.06] px-3">
                      <BedDouble size={14} className="text-guezs-gold" aria-hidden="true" />
                      {listing.bedrooms}
                    </span>
                  </div>
                </div>
              </motion.article>
            ))}
          </AnimatePresence>
        </motion.div>
      </div>
    </section>
  );
}
