/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                // DeenSphere Brand Colors
                gold: {
                    primary: '#F5B400',
                    highlight: '#FFD84D',
                    soft: '#E6A800',
                },
                dark: {
                    main: '#0B0B0B',
                    secondary: '#141414',
                    card: '#1C1C1C',
                    icon: '#2A2A2A',
                },
                light: {
                    primary: '#FFFFFF',
                    soft: '#F4F4F4',
                    muted: '#B3B3B3',
                },
                // Semantic colors
                iconBlack: '#000000',
                success: '#22C55E',
                error: '#EF4444',
                warning: '#F5B400',
            },
            fontFamily: {
                outfit: ['Outfit', 'sans-serif'],
            },
        },
    },
    plugins: [],
}
