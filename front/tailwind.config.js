/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        'main': '#2c3e50',
        'secondary': '#E5E7EB',

        'error': '#e74c3c',

        'chart-blue': '#4A90E2',
        'chart-red': '#E94E77',
        'chart-orange': '#F9A825',
        'chart-yellow': '#F6E05E',
        'chart-green': '#4CAF50',
        'chart-indigo': '#667EEA',
        'chart-violet': '#9D48B9',
      }
    },
  },
  plugins: [],
}
