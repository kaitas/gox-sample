/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        'gox-black': '#0a0a0a',
        'gox-gold': '#d4af37',
        'gox-gold-light': '#f4d03f',
        'gox-purple': '#8b5cf6',
        'gox-cyan': '#22d3d1',
      },
      fontFamily: {
        display: ['Orbitron', 'sans-serif'],
        body: ['Noto Sans JP', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
