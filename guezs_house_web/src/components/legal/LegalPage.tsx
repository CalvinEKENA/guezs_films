import Link from "next/link";
import type { ReactNode } from "react";

export type LegalHighlight = {
  label: string;
  value: ReactNode;
};

export type LegalQuickLink = {
  label: string;
  href: string;
  description: string;
};

export type LegalSection = {
  title: string;
  paragraphs?: ReactNode[];
  bullets?: ReactNode[];
  note?: ReactNode;
};

export type LegalPageContent = {
  eyebrow: string;
  title: string;
  intro: ReactNode;
  lastUpdated: string;
  highlights?: LegalHighlight[];
  quickLinks?: LegalQuickLink[];
  sections: LegalSection[];
  footer?: ReactNode;
};

export default function LegalPage({
  content,
}: {
  content: LegalPageContent;
}) {
  return (
    <main className="min-h-screen bg-guezs-light pt-32 pb-24 text-guezs-black">
      <div className="container mx-auto px-6 md:px-12">
        <header className="rounded-[36px] border border-guezs-black/10 bg-white/80 px-6 py-10 shadow-[0_20px_80px_rgba(0,0,0,0.05)] backdrop-blur md:px-10 md:py-12">
          <p className="mb-4 text-[10px] font-semibold uppercase tracking-[0.35em] text-guezs-gold">
            {content.eyebrow}
          </p>
          <div className="grid gap-8 lg:grid-cols-[minmax(0,1fr)_320px] lg:items-end">
            <div>
              <h1 className="max-w-4xl font-heading text-4xl leading-none text-guezs-black md:text-6xl">
                {content.title}
              </h1>
              <div className="mt-6 max-w-3xl text-sm leading-7 text-guezs-black/75 md:text-base">
                {content.intro}
              </div>
            </div>
            <div className="rounded-[28px] border border-guezs-gold/25 bg-guezs-black px-6 py-5 text-guezs-sand shadow-[0_20px_60px_rgba(0,0,0,0.18)]">
              <p className="text-[10px] font-semibold uppercase tracking-[0.3em] text-guezs-gold/80">
                Dernière mise à jour
              </p>
              <p className="mt-3 font-heading text-2xl leading-tight">
                {content.lastUpdated}
              </p>
            </div>
          </div>
        </header>

        <div className="mt-10 grid gap-8 lg:grid-cols-[320px_minmax(0,1fr)]">
          <aside className="space-y-6 lg:sticky lg:top-28 lg:h-fit">
            {content.highlights && content.highlights.length > 0 ? (
              <div className="rounded-[28px] border border-guezs-black/10 bg-white/85 p-6 shadow-[0_12px_40px_rgba(0,0,0,0.04)]">
                <h2 className="text-[10px] font-semibold uppercase tracking-[0.3em] text-guezs-gold">
                  Repères utiles
                </h2>
                <div className="mt-5 space-y-5">
                  {content.highlights.map((item) => (
                    <div key={item.label}>
                      <p className="text-[10px] font-semibold uppercase tracking-[0.28em] text-guezs-black/40">
                        {item.label}
                      </p>
                      <div className="mt-2 text-sm leading-6 text-guezs-black/80">
                        {item.value}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ) : null}

            {content.quickLinks && content.quickLinks.length > 0 ? (
              <div className="rounded-[28px] border border-guezs-black/10 bg-guezs-black p-6 text-guezs-sand shadow-[0_20px_60px_rgba(0,0,0,0.18)]">
                <h2 className="text-[10px] font-semibold uppercase tracking-[0.3em] text-guezs-gold/90">
                  Liens directs
                </h2>
                <div className="mt-5 space-y-3">
                  {content.quickLinks.map((item) => (
                    <Link
                      key={item.href}
                      href={item.href}
                      className="group block rounded-[22px] border border-white/10 bg-white/5 p-4 transition-colors hover:border-guezs-gold/50 hover:bg-white/8"
                    >
                      <div className="flex items-start justify-between gap-4">
                        <div>
                          <p className="text-sm font-semibold text-white transition-colors group-hover:text-guezs-gold">
                            {item.label}
                          </p>
                          <p className="mt-2 text-xs leading-5 text-white/60">
                            {item.description}
                          </p>
                        </div>
                        <span className="mt-1 text-guezs-gold transition-transform group-hover:translate-x-1">
                          →
                        </span>
                      </div>
                    </Link>
                  ))}
                </div>
              </div>
            ) : null}
          </aside>

          <div className="space-y-6">
            {content.sections.map((section) => (
              <section
                key={section.title}
                className="rounded-[30px] border border-guezs-black/10 bg-white/90 p-6 shadow-[0_16px_50px_rgba(0,0,0,0.04)] md:p-8"
              >
                <div className="mb-6 h-px w-16 bg-guezs-gold/60" />
                <h2 className="font-heading text-3xl text-guezs-black">
                  {section.title}
                </h2>

                {section.paragraphs && section.paragraphs.length > 0 ? (
                  <div className="mt-5 space-y-4 text-sm leading-7 text-guezs-black/75 md:text-base">
                    {section.paragraphs.map((paragraph, index) => (
                      <div key={index}>{paragraph}</div>
                    ))}
                  </div>
                ) : null}

                {section.bullets && section.bullets.length > 0 ? (
                  <ul className="mt-5 space-y-3">
                    {section.bullets.map((bullet, index) => (
                      <li
                        key={index}
                        className="flex gap-3 text-sm leading-7 text-guezs-black/75 md:text-base"
                      >
                        <span className="mt-3 h-1.5 w-1.5 shrink-0 rounded-full bg-guezs-gold" />
                        <span>{bullet}</span>
                      </li>
                    ))}
                  </ul>
                ) : null}

                {section.note ? (
                  <div className="mt-6 rounded-[24px] border border-guezs-gold/20 bg-guezs-gold/8 p-4 text-sm leading-6 text-guezs-black/80">
                    {section.note}
                  </div>
                ) : null}
              </section>
            ))}
          </div>
        </div>

        {content.footer ? (
          <div className="mt-10 rounded-[28px] border border-guezs-black/10 bg-white/70 px-6 py-6 text-sm leading-7 text-guezs-black/70 shadow-[0_12px_40px_rgba(0,0,0,0.03)] md:px-8">
            {content.footer}
          </div>
        ) : null}
      </div>
    </main>
  );
}
