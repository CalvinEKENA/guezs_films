// tailwind.config.ts
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // Palette "Premium Afro-Contemporaine" / Volta Skai structural match
        guezs: {
          gold: "#D4AF37",      // Or métallique demandé par l'utilisateur
          black: "#333333",     // Charcoal pour le texte (au lieu du noir profond)
          sand: "#F9F9F9",      // Off-white très clair pour le fond
          terracotta: "#A0522D",
          blue: "#003366",      // Navy blue
          white: "#FFFFFF",
          light: "#F2EFE9",     // Volta Skai beige reference
        },
      },
      fontFamily: {
        heading: ["var(--font-didot-like)", "serif"],
        body: ["var(--font-montserrat)", "sans-serif"],
      },
    },
  },
  plugins: [],
};
export default config;
