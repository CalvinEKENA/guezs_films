"use client";
import { useEffect, useRef, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { db } from "@/lib/firebase";
import { collection, addDoc, serverTimestamp } from "firebase/firestore";
import { countries } from "@/lib/countries";
import Select, { type SingleValue } from "react-select";

gsap.registerPlugin(ScrollTrigger);

const LAUNCH_DATE = new Date("2026-06-06T00:00:00+01:00").getTime();

interface TimeLeft {
  days: number;
  hours: number;
  minutes: number;
  seconds: number;
}

function getTimeLeft(): TimeLeft {
  const now = Date.now();
  const diff = Math.max(LAUNCH_DATE - now, 0);
  return {
    days: Math.floor(diff / (1000 * 60 * 60 * 24)),
    hours: Math.floor((diff / (1000 * 60 * 60)) % 24),
    minutes: Math.floor((diff / (1000 * 60)) % 60),
    seconds: Math.floor((diff / 1000) % 60),
  };
}

// Composant Particules flottantes
function FloatingParticles() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let animId: number;
    const particles: { x: number; y: number; r: number; vx: number; vy: number; alpha: number; pulse: number }[] = [];

    const resize = () => {
      canvas.width = canvas.offsetWidth;
      canvas.height = canvas.offsetHeight;
    };
    resize();
    window.addEventListener("resize", resize);

    for (let i = 0; i < 40; i++) {
      particles.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        r: Math.random() * 2 + 0.5,
        vx: (Math.random() - 0.5) * 0.3,
        vy: (Math.random() - 0.5) * 0.3,
        alpha: Math.random() * 0.5 + 0.1,
        pulse: Math.random() * Math.PI * 2,
      });
    }

    const draw = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      particles.forEach((p) => {
        p.x += p.vx;
        p.y += p.vy;
        p.pulse += 0.02;

        if (p.x < 0) p.x = canvas.width;
        if (p.x > canvas.width) p.x = 0;
        if (p.y < 0) p.y = canvas.height;
        if (p.y > canvas.height) p.y = 0;

        const a = p.alpha * (0.5 + 0.5 * Math.sin(p.pulse));
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(212, 175, 55, ${a})`;
        ctx.fill();
      });
      animId = requestAnimationFrame(draw);
    };
    draw();

    return () => {
      cancelAnimationFrame(animId);
      window.removeEventListener("resize", resize);
    };
  }, []);

  return <canvas ref={canvasRef} className="absolute inset-0 w-full h-full pointer-events-none z-0" />;
}

// Composant carte du countdown
function CountdownCard({ value, label }: { value: number; label: string }) {
  return (
    <div className="flex flex-col items-center">
      <div className="relative w-14 h-16 md:w-20 md:h-24 rounded-xl overflow-hidden group">
        <div className="absolute inset-0 bg-white/[0.04] backdrop-blur-md border border-white/[0.08] rounded-xl" />
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-3/4 h-[1px] bg-gradient-to-r from-transparent via-[#D4AF37]/60 to-transparent" />
        <div className="relative z-10 flex items-center justify-center h-full">
          <span className="font-heading text-xl md:text-3xl text-[#D4AF37] tabular-nums drop-shadow-[0_0_15px_rgba(212,175,55,0.3)]">
            {String(value).padStart(2, "0")}
          </span>
        </div>
      </div>
      <span className="mt-3 text-[8px] md:text-[10px] text-white/50 uppercase tracking-[0.25em] font-body">
        {label}
      </span>
    </div>
  );
}

export default function ComingSoon() {
  const [timeLeft, setTimeLeft] = useState<TimeLeft>(getTimeLeft);
  const [mounted, setMounted] = useState(false);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    countryCode: "+33",
    mobile: "",
    email: "",
  });

  const handleOpenModal = () => setIsModalOpen(true);
  const handleCloseModal = () => setIsModalOpen(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      await addDoc(collection(db, "guezs_films_avantpremiere"), {
        ...formData,
        createdAt: serverTimestamp(),
      });
      await addDoc(collection(db, "mail"), {
        to: "yvette.mengue@guezs-house.com",
        message: {
          subject: "Nouvelle inscription Avant-Première GUEZS Films",
          html: `<p>Nouvelle inscription :</p><ul><li>Nom: ${formData.name}</li><li>Email: ${formData.email}</li><li>Téléphone: ${formData.countryCode} ${formData.mobile}</li></ul>`,
        },
      });
      
      setSubmitSuccess(true);
      setTimeout(() => {
        setIsModalOpen(false);
        setSubmitSuccess(false);
        setFormData({ name: "", countryCode: "+33", mobile: "", email: "" });
      }, 3000);
    } catch (error) {
      console.error("Erreur lors de l'envoi :", error);
      alert("Une erreur est survenue.");
    } finally {
      setIsSubmitting(false);
    }
  };

  useEffect(() => {
    setMounted(true);
    const timer = setInterval(() => {
      setTimeLeft(getTimeLeft());
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  return (
    <section className="w-full relative flex flex-col justify-center">
      
      {/* HEADER SECTION (Split Layout) */}
      <div className="container mx-auto px-6 md:px-12 mb-12 md:mb-16">
        <div className="flex flex-col md:flex-row relative">
          
          <div className="hidden md:block absolute left-1/2 top-4 bottom-[-60px] w-px bg-guezs-black/20 -translate-x-1/2" />

          {/* Left Column : Titles */}
          <div className="w-full md:w-1/2 md:pr-20 mb-12 md:mb-0">
             <span className="text-guezs-black/40 font-body uppercase tracking-[0.3em] text-[10px] md:text-xs mb-6 block">
               BIENTÔT
             </span>
             <h2 className="font-heading text-5xl md:text-7xl lg:text-8xl text-guezs-black leading-[0.9] tracking-tight">
               GUEZS
               <br/>
               <span className="italic">FILMS</span>
             </h2>
          </div>

          {/* Right Column : Description */}
          <div className="w-full md:w-1/2 md:pl-20 flex flex-col justify-end">
             <h3 className="font-heading text-xl md:text-2xl text-guezs-black mb-4">
               L&apos;Épouse du{" "}
               <span className="text-guezs-gold italic">Mbenguiste</span>
             </h3>
             <p className="font-body text-guezs-black/70 text-sm md:text-base leading-relaxed mb-6 max-w-sm">
               Une plongée fascinante au cœur des réalités de la diaspora africaine. Préparez-vous pour le lancement événementiel.
             </p>
             <p className="font-body text-guezs-black/40 text-[10px] uppercase tracking-[0.2em] font-medium">
               Sortie prévue le 06 Juin 2026
             </p>
             <div className="mt-6">
               <Link
                 href="/guezs-films"
                 className="inline-flex items-center gap-3 rounded-full border border-guezs-black/10 bg-white/80 px-5 py-3 text-[10px] font-semibold uppercase tracking-[0.22em] text-guezs-black transition-colors hover:border-guezs-gold hover:text-guezs-gold"
               >
                 Infos, support et confidentialité
                 <span aria-hidden="true">→</span>
               </Link>
             </div>
          </div>
        </div>
      </div>

      {/* BLOCK SECTION (with dark cinematic styling and 40px radius) */}
      <div className="container mx-auto px-6 md:px-12">
        <div className="relative w-full aspect-[4/3] md:aspect-[21/9] rounded-[40px] overflow-hidden bg-[#0D0D0D] flex flex-col items-center justify-center">
            
            {/* Image de fond principale */}
            <div className="absolute inset-0 z-0">
               <Image 
                 src="/assets/images/film1.jpeg" 
                 alt="Guezs Films Background" 
                 fill 
                 className="object-cover opacity-30 contrast-125 saturate-50"
               />
               <div className="absolute inset-0 bg-gradient-to-t from-[#0D0D0D] via-[#0D0D0D]/60 to-transparent" />
            </div>

            {/* Particules flottantes */}
            <div className="relative z-[1] h-full w-full pointer-events-none absolute inset-0">
              <FloatingParticles />
            </div>

            {/* Countdown */}
            <div className="relative z-10 flex gap-4 md:gap-8 mb-12">
              <CountdownCard value={mounted ? timeLeft.days : 0} label="Jours" />
              <CountdownCard value={mounted ? timeLeft.hours : 0} label="Heures" />
              <CountdownCard value={mounted ? timeLeft.minutes : 0} label="Minutes" />
              <CountdownCard value={mounted ? timeLeft.seconds : 0} label="Secondes" />
            </div>

            {/* Bouton d'intérêt */}
            <div className="relative z-10">
              <button onClick={handleOpenModal} className="group relative text-center mx-auto inline-flex items-center gap-3 px-8 py-4 border border-[#D4AF37]/40 text-[#D4AF37] text-[10px] md:text-xs uppercase tracking-[0.2em] font-body overflow-hidden transition-all duration-500 hover:border-[#D4AF37] hover:shadow-[0_0_30px_rgba(212,175,55,0.2)] rounded-full bg-black/40 backdrop-blur-sm">
                <span className="relative z-10">
                  S&apos;inscrire à l&apos;Avant-Première
                </span>
                <svg className="relative z-10 w-4 h-4 transition-transform duration-300 group-hover:translate-x-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3" />
                </svg>
              </button>
            </div>

        </div>
      </div>

      {/* Popup Formulaire */}
      {isModalOpen && (
        <div className="fixed inset-0 z-[99999] flex items-center justify-center px-4 backdrop-blur-md bg-black/60">
          <div className="relative w-full max-w-md bg-[#0D0D0D] border border-[#D4AF37]/30 rounded-[30px] p-8 shadow-[0_0_50px_rgba(212,175,55,0.15)] animate-in fade-in zoom-in duration-300">
            <button 
              onClick={handleCloseModal}
              className="absolute top-6 right-6 text-white/50 hover:text-[#D4AF37] transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M6 18L18 6M6 6l12 12" /></svg>
            </button>
            <h3 className="font-heading text-2xl text-[#D4AF37] mb-2">Accès Exclusif</h3>
            <p className="font-body text-white/70 text-sm mb-6">Laissez vos coordonnées pour être informé en priorité de la sortie officielle et des événements exclusifs.</p>
            
            {submitSuccess ? (
              <div className="text-center py-8">
                <div className="w-16 h-16 rounded-full bg-[#D4AF37]/20 flex items-center justify-center mx-auto mb-4 border border-[#D4AF37]/40">
                   <svg className="w-8 h-8 text-[#D4AF37]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" /></svg>
                </div>
                <p className="font-body text-white text-lg">Merci pour votre intérêt !</p>
                <p className="font-body text-white/60 text-sm mt-2">Votre demande a bien été enregistrée.</p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-4 text-left">
                <div>
                  <label className="block text-[10px] font-body text-[#D4AF37] uppercase tracking-wider mb-1.5">Nom complet</label>
                  <input required type="text" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-[#D4AF37]/50 focus:bg-white/10 transition-colors font-body text-sm" placeholder="Votre nom" />
                </div>
                <div className="flex gap-3">
                   <div className="w-[45%]">
                     <label className="block text-[10px] font-body text-[#D4AF37] uppercase tracking-wider mb-1.5">Pays</label>
                     <div className="relative">
                       <Select
                         options={countries.map(c => ({ value: c.code, label: `${c.flag} ${c.name} (${c.code})` }))}
                         value={{ value: formData.countryCode, label: formData.countryCode }}
                         onChange={(
                           selected: SingleValue<{ value: string; label: string }>
                         ) =>
                           setFormData({
                             ...formData,
                             countryCode: selected?.value ?? formData.countryCode,
                           })
                         }
                         className="react-select-container text-sm font-body"
                         classNamePrefix="react-select"
                         styles={{
                           control: (base) => ({
                             ...base,
                             backgroundColor: 'rgba(255, 255, 255, 0.05)',
                             borderColor: 'rgba(255, 255, 255, 0.1)',
                             minHeight: '46px',
                             borderRadius: '0.75rem',
                             boxShadow: 'none',
                           }),
                           menu: (base) => ({
                             ...base,
                             backgroundColor: '#0D0D0D',
                             border: '1px solid rgba(212, 175, 55, 0.3)',
                             zIndex: 9999
                           }),
                           option: (base, state) => ({
                             ...base,
                             backgroundColor: state.isFocused ? 'rgba(212, 175, 55, 0.2)' : 'transparent',
                             color: '#F5F5DC'
                           }),
                           singleValue: (base) => ({
                             ...base,
                             color: '#F5F5DC'
                           })
                         }}
                       />
                     </div>
                   </div>
                   <div className="w-[55%]">
                     <label className="block text-[10px] font-body text-[#D4AF37] uppercase tracking-wider mb-1.5">Mobile</label>
                     <input required type="tel" value={formData.mobile} onChange={e => setFormData({...formData, mobile: e.target.value})} className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-[#D4AF37]/50 focus:bg-white/10 transition-colors font-body text-sm" placeholder="Numéro" />
                   </div>
                </div>
                <div>
                  <label className="block text-[10px] font-body text-[#D4AF37] uppercase tracking-wider mb-1.5">Email</label>
                  <input required type="email" value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})} className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-white focus:outline-none focus:border-[#D4AF37]/50 focus:bg-white/10 transition-colors font-body text-sm" placeholder="votre@email.com" />
                </div>
                <button disabled={isSubmitting} type="submit" className="w-full mt-8 flex items-center justify-center gap-2 bg-[#D4AF37] text-black font-body uppercase tracking-[0.2em] text-xs font-semibold py-4 rounded-xl transition-all hover:bg-[#D4AF37]/90 hover:shadow-[0_0_20px_rgba(212,175,55,0.4)] disabled:opacity-50">
                  {isSubmitting ? "Envoi en cours..." : "Valider"}
                </button>
                <p className="text-xs leading-5 text-white/55">
                  En validant, vous acceptez d&apos;être recontacté au sujet de
                  GUEZS Films. Consultez notre{" "}
                  <Link
                    href="/guezs-films/confidentialite"
                    className="text-[#D4AF37] underline underline-offset-4 hover:text-white"
                  >
                    politique de confidentialité
                  </Link>
                  .
                </p>
              </form>
            )}
          </div>
        </div>
      )}
    </section>
  );
}
