/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        // Chart Colors
        customMain: '#2c2d2d',
        customSecondary: '#474646',
        customWhite: '#FFFFFF',
        customBlack: '#000000',
        customBrightRed: '#DB0000',
        customPurple: '#583c9b',
        customYellow: '#f0b63a',
        customGrey: '#f3f4f6',

        // Chart Colors
        'chart-blue': '#4A90E2',
        'chart-red': '#E94E77',
        'chart-orange': '#F9A825',
        'chart-yellow': '#F6E05E',
        'chart-green': '#4CAF50',
        'chart-indigo': '#667EEA',
        'chart-violet': '#9D48B9',
      },
    },
  },
  plugins: [],
}
