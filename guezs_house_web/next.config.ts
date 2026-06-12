import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "export", // Export statique pour Firebase Hosting
  reactCompiler: true,
  images: {
    unoptimized: true, // Nécessaire pour l'export statique
    qualities: [75, 95],
  },
  trailingSlash: true, // Meilleures URLs pour le hosting statique
};

export default nextConfig;
