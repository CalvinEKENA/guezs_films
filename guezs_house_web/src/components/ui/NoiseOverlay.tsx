"use client";

export default function NoiseOverlay() {
  const noiseSvg = `
    <svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
      <filter id="noiseFilter">
        <feTurbulence
          type="fractalNoise"
          baseFrequency="0.8"
          numOctaves="3"
          stitchTiles="stitch" />
      </filter>
      <rect width="100%" height="100%" filter="url(#noiseFilter)" />
    </svg>
  `;

  const encodedSvg = `data:image/svg+xml;base64,${btoa(noiseSvg.trim())}`;

  return (
    <div
      className="pointer-events-none fixed inset-0 z-[9999] opacity-[0.03] mix-blend-overlay"
      style={{
        backgroundImage: `url(${encodedSvg})`,
        backgroundRepeat: 'repeat',
        backgroundSize: '128px 128px'
      }}
    />
  );
}
