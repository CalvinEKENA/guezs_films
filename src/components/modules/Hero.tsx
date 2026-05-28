"use client";
import { useEffect, useRef, useState } from "react";
import gsap from "gsap";
import MagneticButton from "@/components/ui/MagneticButton";

const HERO_IMAGES = [
  "/assets/images/style-2.jpg",
  "/assets/images/s1-1.jpg",
  "/assets/images/film1.jpeg",
  "/assets/images/film3.jpeg",
  "/assets/images/about-vision.jpg",
  "/assets/images/bout-vision.jpg",
  "/assets/images/piknik4.jpeg",
  "/assets/images/Yvette4.jpg",
  "/assets/images/Yvette5.jpg",
];

export default function Hero() {
  const heroRef = useRef(null);
  const titleRef = useRef(null);
  const subtitleRef = useRef(null);
  const ctaRef = useRef(null);

  const [currentIndex, setCurrentIndex] = useState(0);
  const [prevIndex, setPrevIndex] = useState<number | null>(null);
  const [isTransitioning, setIsTransitioning] = useState(false);

  // Auto-advance slideshow every 7 seconds for a slower, softer feel
  useEffect(() => {
    const interval = setInterval(() => {
      setPrevIndex(currentIndex);
      setIsTransitioning(true);
      setCurrentIndex((prev) => (prev + 1) % HERO_IMAGES.length);
      setTimeout(() => {
        setIsTransitioning(false);
        setPrevIndex(null);
      }, 2000); // Slower crossfade
    }, 7000);
    return () => clearInterval(interval);
  }, [currentIndex]);

  // GSAP entrance animation
  useEffect(() => {
    const tl = gsap.timeline({ defaults: { ease: "power4.out" } });
    tl.fromTo(titleRef.current,
      { x: -100, opacity: 0, skewX: 5 },
      { x: 0, opacity: 1, skewX: 0, duration: 1.5, delay: 0.4 }
    )
    .fromTo(subtitleRef.current,
      { x: -50, opacity: 0 },
      { x: 0, opacity: 1, duration: 1.2 },
      "-=1.0"
    )
    .fromTo(ctaRef.current,
      { x: -30, opacity: 0 },
      { x: 0, opacity: 1, duration: 1 },
      "-=0.8"
    );
  }, []);

  return (
    <section id="hero" ref={heroRef} className="w-full h-screen min-h-[600px] relative flex items-center justify-center overflow-hidden bg-guezs-black">

      {/* Previous image (fading out) */}
      {prevIndex !== null && (
        <div
          key={`prev-${prevIndex}`}
          className="absolute inset-0 z-0 opacity-30"
          style={{
            backgroundImage: `url(${HERO_IMAGES[prevIndex]})`,
            backgroundSize: "cover",
            backgroundPosition: HERO_IMAGES[prevIndex].includes('Yvette') ? "top center" : "center",
          }}
        />
      )}

      {/* Current image */}
      <div
        key={`current-${currentIndex}`}
        className="absolute inset-0 z-[1]"
        style={{
          backgroundImage: `url(${HERO_IMAGES[currentIndex]})`,
          backgroundSize: "cover",
          backgroundPosition: HERO_IMAGES[currentIndex].includes('Yvette') ? "top center" : "center",
          animation: "kenburns 12s ease-in-out infinite alternate",
        }}
      />

      {/* Strong overlay for text readability */}
      <div className="absolute inset-0 z-[2] bg-gradient-to-r from-black/90 via-black/60 to-black/30" />
      <div className="absolute inset-0 z-[2] bg-gradient-to-t from-black/70 via-transparent to-black/30" />

      {/* Main content */}
      <div className="container mx-auto px-6 md:px-12 z-10 w-full flex flex-col items-start justify-center h-full relative pt-24">

        <div className="overflow-hidden mb-8 pl-1">
          <div className="relative inline-flex items-center justify-center px-6 py-2.5">
            {/* Strong dark background block to guarantee text visibility over any image */}
            <div className="absolute inset-0 rounded-full bg-black/70 backdrop-blur-md border border-guezs-gold/40 shadow-[0_4px_25px_rgba(0,0,0,0.8)] pointer-events-none" />
            <div className="absolute inset-x-4 bottom-0 h-[1px] bg-gradient-to-r from-transparent via-guezs-gold/80 to-transparent" />
            
            <span 
              ref={subtitleRef} 
              className="text-[#D4AF37] text-xs md:text-sm lg:text-base font-heading tracking-[0.2em] md:tracking-[0.3em] uppercase font-bold relative z-10 drop-shadow-2xl" 
            >
              L'Excellence Afro-Contemporaine
            </span>
          </div>
        </div>

        <div className="relative mb-10">
          <h1
            ref={titleRef}
            className="font-heading font-medium text-[12vw] leading-[0.85] text-white tracking-tight"
            style={{ textShadow: "0 4px 30px rgba(0,0,0,0.6)" }}
          >
            GUEZS
            <br />
            <span className="text-guezs-gold italic font-light ml-[10vw]">HOUSE</span>
          </h1>
        </div>

        <div ref={ctaRef} className="flex flex-col sm:flex-row gap-6 items-start sm:items-center mt-6">
          <MagneticButton variant="primary">
            Exploration Globale
          </MagneticButton>
          <p className="text-white/80 font-body text-xs uppercase tracking-[0.2em] max-w-[220px] text-left leading-relaxed" style={{ textShadow: "0 2px 10px rgba(0,0,0,0.8)" }}>
            Mode, Immobilier, Cinéma &amp; Événements Prestigieux
          </p>
        </div>
      </div>

      {/* Slideshow Dots */}
      <div className="absolute bottom-28 right-8 md:right-12 z-10 flex flex-col gap-2">
        {HERO_IMAGES.map((_, idx) => (
          <button
            key={idx}
            onClick={() => {
              setPrevIndex(currentIndex);
              setIsTransitioning(true);
              setCurrentIndex(idx);
              setTimeout(() => { setIsTransitioning(false); setPrevIndex(null); }, 1200);
            }}
            className={`block rounded-full transition-all duration-500 ${
              idx === currentIndex
                ? "w-[2px] h-8 bg-guezs-gold shadow-[0_0_8px_rgba(212,175,55,0.8)]"
                : "w-[2px] h-3 bg-white/40 hover:bg-white/70"
            }`}
          />
        ))}
      </div>

      {/* Scroll indicator */}
      <div className="absolute bottom-10 left-1/2 -translate-x-1/2 flex flex-col items-center gap-3 z-10">
        <span className="text-white text-[10px] md:text-xs uppercase tracking-[0.3em] font-body font-bold" style={{ textShadow: "0 2px 10px rgba(0,0,0,0.9)" }}>Découvrir</span>
        <div className="w-[1px] h-16 bg-gradient-to-b from-white via-white/60 to-transparent origin-top animate-[pulse_2s_ease-in-out_infinite]" />
      </div>

      {/* Ken Burns CSS */}
      <style jsx>{`
        @keyframes kenburns {
          0%   { transform: scale(1) translate(0, 0); }
          100% { transform: scale(1.08) translate(-1%, -1%); }
        }
      `}</style>
    </section>
  );
}
