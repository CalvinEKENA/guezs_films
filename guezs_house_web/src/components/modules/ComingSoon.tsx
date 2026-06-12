import Image from "next/image";
import Link from "next/link";

const filmsUrl = "https://films.guezs-house.com";

export default function ComingSoon() {
  return (
    <section className="w-full py-8 md:py-12">
      <div className="container mx-auto px-6 md:px-12">
        <div className="mb-12 flex flex-col md:mb-16 md:flex-row">
          <div className="relative mb-10 w-full md:mb-0 md:w-1/2 md:pr-20">
            <div className="absolute bottom-[-60px] right-0 top-4 hidden w-px bg-guezs-black/20 md:block" />
            <span className="mb-6 block font-body text-[10px] uppercase tracking-[0.3em] text-guezs-black/40 md:text-xs">
              Maintenant en ligne
            </span>
            <h2 className="font-heading text-5xl leading-[0.9] tracking-tight text-guezs-black md:text-7xl lg:text-8xl">
              GUEZS
              <br />
              <span className="italic">FILMS</span>
            </h2>
          </div>

          <div className="flex w-full flex-col justify-end md:w-1/2 md:pl-20">
            <h3 className="mb-4 font-heading text-xl text-guezs-black md:text-2xl">
              Le cinéma africain, dans son plus bel écrin.
            </h3>
            <p className="mb-7 max-w-md font-body text-sm leading-relaxed text-guezs-black/70 md:text-base">
              Découvrez films, séries et créations originales dans une
              expérience cinéma pensée pour tous vos écrans.
            </p>
            <div className="flex flex-wrap gap-3">
              <a
                href={filmsUrl}
                className="inline-flex items-center gap-3 rounded-full bg-guezs-black px-6 py-3 text-[10px] font-semibold uppercase tracking-[0.22em] text-white transition-colors hover:bg-guezs-gold"
              >
                Ouvrir GUEZS FILMS
                <span aria-hidden="true">→</span>
              </a>
              <Link
                href="/guezs-films"
                className="inline-flex items-center rounded-full border border-guezs-black/15 bg-white/80 px-5 py-3 text-[10px] font-semibold uppercase tracking-[0.18em] text-guezs-black transition-colors hover:border-guezs-gold hover:text-guezs-gold"
              >
                Support et confidentialité
              </Link>
            </div>
          </div>
        </div>

        <a
          href={filmsUrl}
          aria-label="Accéder à la plateforme GUEZS FILMS"
          className="group relative flex min-h-[420px] w-full items-end overflow-hidden rounded-[32px] bg-[#0D0D0D] md:aspect-[21/9] md:min-h-0 md:rounded-[40px]"
        >
          <Image
            src="/assets/images/film1.jpeg"
            alt="Univers cinématographique GUEZS FILMS"
            fill
            className="object-cover opacity-55 saturate-75 transition-transform duration-700 group-hover:scale-[1.025]"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#050505] via-[#050505]/55 to-transparent" />
          <div className="relative z-10 max-w-2xl p-8 text-white md:p-14">
            <span className="mb-4 block font-body text-[10px] uppercase tracking-[0.28em] text-[#D4AF37] md:text-xs">
              films.guezs-house.com
            </span>
            <h3 className="mb-4 font-heading text-3xl leading-tight md:text-5xl">
              Votre salle privée est ouverte.
            </h3>
            <p className="max-w-xl font-body text-sm leading-relaxed text-white/75 md:text-base">
              Entrez dans l&apos;univers GUEZS FILMS et retrouvez vos histoires
              sur mobile comme sur le Web.
            </p>
          </div>
        </a>
      </div>
    </section>
  );
}
