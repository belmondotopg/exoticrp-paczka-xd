/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'primary-400': "#7D51FB",
        'primary-500': "#6A38FA",
        "primary-600": "#38323E",
        'primary-800': "#29252D",
        'primary-900': "#242027",
        'primary-950': "#0A090B",
        'orange': {
          '400': '#FF8C42',
          '500': '#FF7A2F',
          '600': '#E66A1F',
        },
        'card': {
          'bg': '#141414',
          'dark': '#0E0E0E',
        }
      }
    },
  },
  plugins: [],
}