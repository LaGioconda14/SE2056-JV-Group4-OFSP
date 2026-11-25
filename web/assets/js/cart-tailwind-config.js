tailwind.config = {
    darkMode: 'class',
    theme: {
        extend: {
            colors: {
                'on-tertiary-container': '#fff1eb', 'secondary-fixed': '#d9e6dd',
                'inverse-on-surface': '#eef0ff', 'on-secondary-container': '#5b6760',
                'primary-container': '#15803d', 'on-tertiary-fixed-variant': '#783200',
                'inverse-primary': '#79db8d', 'on-tertiary-fixed': '#341100',
                'on-surface': '#131b2e', 'background': '#faf8ff',
                'surface-container-high': '#e2e7ff', 'on-error-container': '#93000a',
                'on-secondary-fixed': '#131e19', 'surface-container-highest': '#dae2fd',
                'secondary': '#55615a', 'surface-bright': '#faf8ff', 'error': '#ba1a1a',
                'on-secondary': '#ffffff', 'on-primary-fixed-variant': '#005323',
                'on-primary': '#ffffff', 'surface-container-low': '#f2f3ff',
                'on-primary-fixed': '#00210a', 'error-container': '#ffdad6',
                'surface-tint': '#006d30', 'tertiary-container': '#b85000',
                'primary-fixed-dim': '#79db8d', 'on-secondary-fixed-variant': '#3e4943',
                'on-surface-variant': '#3f493f', 'surface-dim': '#d2d9f4',
                'tertiary': '#913e00', 'primary-fixed': '#95f8a7',
                'outline-variant': '#becabc', 'secondary-fixed-dim': '#bdcac1',
                'secondary-container': '#d9e6dd', 'surface': '#faf8ff',
                'surface-container-lowest': '#ffffff', 'surface-container': '#eaedff',
                'on-tertiary': '#ffffff', 'on-primary-container': '#d3ffd5',
                'tertiary-fixed': '#ffdbca', 'outline': '#6f7a6e',
                'tertiary-fixed-dim': '#ffb690', 'on-error': '#ffffff',
                'surface-variant': '#dae2fd', 'primary': '#00652c',
                'on-background': '#131b2e', 'inverse-surface': '#283044'
            },
            borderRadius: {DEFAULT: '0.25rem', lg: '0.5rem', xl: '0.75rem', full: '9999px'},
            spacing: {
                'margin-sm': '1rem', 'space-xs': '0.25rem', 'space-lg': '1.5rem',
                'space-xl': '2.5rem', 'space-sm': '0.5rem', margin: '2rem',
                'space-md': '1rem', gutter: '1.5rem', 'margin-lg': '4rem', 'gutter-sm': '1rem'
            },
            fontFamily: {
                'label-caps': ['Plus Jakarta Sans', 'sans-serif'], 'body-lg': ['Plus Jakarta Sans', 'sans-serif'],
                'headline-md': ['Plus Jakarta Sans', 'sans-serif'], 'display-hero': ['Plus Jakarta Sans', 'sans-serif'],
                'body-md': ['Plus Jakarta Sans', 'sans-serif'], 'headline-lg': ['Plus Jakarta Sans', 'sans-serif'],
                'headline-lg-mobile': ['Plus Jakarta Sans', 'sans-serif'], 'body-sm': ['Plus Jakarta Sans', 'sans-serif'],
                'display-hero-mobile': ['Plus Jakarta Sans', 'sans-serif'], 'price-hero': ['Plus Jakarta Sans', 'sans-serif'],
                'headline-sm': ['Plus Jakarta Sans', 'sans-serif'], 'price-md': ['Plus Jakarta Sans', 'sans-serif']
            },
            fontSize: {
                'label-caps': ['11px', {lineHeight: '14px', letterSpacing: '0.06em', fontWeight: '700'}],
                'body-lg': ['16px', {lineHeight: '24px', letterSpacing: '-0.005em', fontWeight: '400'}],
                'headline-md': ['22px', {lineHeight: '28px', letterSpacing: '-0.015em', fontWeight: '700'}],
                'display-hero': ['48px', {lineHeight: '56px', letterSpacing: '-0.025em', fontWeight: '800'}],
                'body-md': ['14px', {lineHeight: '20px', letterSpacing: '0em', fontWeight: '400'}],
                'headline-lg': ['32px', {lineHeight: '40px', letterSpacing: '-0.02em', fontWeight: '700'}],
                'headline-lg-mobile': ['26px', {lineHeight: '32px', letterSpacing: '-0.015em', fontWeight: '700'}],
                'body-sm': ['12px', {lineHeight: '16px', letterSpacing: '0.01em', fontWeight: '500'}],
                'display-hero-mobile': ['34px', {lineHeight: '40px', letterSpacing: '-0.02em', fontWeight: '800'}],
                'price-hero': ['28px', {lineHeight: '32px', letterSpacing: '-0.02em', fontWeight: '800'}],
                'headline-sm': ['18px', {lineHeight: '24px', letterSpacing: '-0.01em', fontWeight: '600'}],
                'price-md': ['18px', {lineHeight: '22px', letterSpacing: '-0.01em', fontWeight: '700'}]
            }
        }
    }
};
