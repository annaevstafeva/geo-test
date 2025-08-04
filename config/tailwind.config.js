const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
  ],
  theme: {
    extend: {
      fontFamily: {
      },
      gridTemplateColumns: {
        // Simple 16 column grid
        '16': 'repeat(16, minmax(0, 1fr))',
        // Simple 16 column grid
        '13': 'repeat(13, minmax(0, 1fr))',
        // Simple 14 column grid
        '14': 'repeat(14, minmax(0, 1fr))',
        // Simple 18 column grid
        '18': 'repeat(18, minmax(0, 1fr))',
        // Simple 19 column grid
        '19': 'repeat(19, minmax(0, 1fr))',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
