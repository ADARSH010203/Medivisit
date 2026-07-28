---
name: Clinical Precision
colors:
  surface: '#f9f9fc'
  surface-dim: '#dadadc'
  surface-bright: '#f9f9fc'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f6'
  surface-container: '#eeeef0'
  surface-container-high: '#e8e8ea'
  surface-container-highest: '#e2e2e5'
  on-surface: '#1a1c1e'
  on-surface-variant: '#424753'
  inverse-surface: '#2f3133'
  inverse-on-surface: '#f0f0f3'
  outline: '#737784'
  outline-variant: '#c3c6d5'
  surface-tint: '#1a5abe'
  primary: '#003d8e'
  on-primary: '#ffffff'
  primary-container: '#0d54b8'
  on-primary-container: '#bdcfff'
  inverse-primary: '#afc6ff'
  secondary: '#006970'
  on-secondary: '#ffffff'
  secondary-container: '#83f3fe'
  on-secondary-container: '#006f77'
  tertiary: '#004d0f'
  on-tertiary: '#ffffff'
  tertiary-container: '#006818'
  on-tertiary-container: '#7be878'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d9e2ff'
  primary-fixed-dim: '#afc6ff'
  on-primary-fixed: '#001943'
  on-primary-fixed-variant: '#004398'
  secondary-fixed: '#83f3fe'
  secondary-fixed-dim: '#65d7e1'
  on-secondary-fixed: '#002022'
  on-secondary-fixed-variant: '#004f54'
  tertiary-fixed: '#8dfb89'
  tertiary-fixed-dim: '#71de70'
  on-tertiary-fixed: '#002203'
  on-tertiary-fixed-variant: '#005311'
  background: '#f9f9fc'
  on-background: '#1a1c1e'
  surface-variant: '#e2e2e5'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 80px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
---

## Brand & Style

This design system is defined by "Clinical Precision," a visual narrative rooted in pharmaceutical reliability, scientific clarity, and human-centric care. It targets healthcare professionals and patients who require immediate trust and error-free interaction. 

The aesthetic is a hybrid of **Modern Corporate** and **Minimalism**. It utilizes expansive white space to denote cleanliness and a high-contrast palette derived directly from the brand's logo to ensure legibility and authority. The mood is sterile yet supportive, prioritizing information density and functional transparency over decorative elements.

## Colors

The palette is extracted from the new brand mark to maintain institutional consistency.
- **Primary (Deep Cobalt):** Used for primary actions, headers, and core brand identifiers. It conveys stability and pharmaceutical authority.
- **Secondary (Teal):** Used for supportive actions, progress indicators, and accenting medical data.
- **Tertiary (Leaf Green):** Reserved for "natural" or "wellness" indicators, success states, and botanical-related product categories.
- **Neutral:** A range of cool grays and deep charcoals to maintain a high-contrast environment, ensuring all clinical data is easily parsable. 
- **Surface:** A crisp, stark white (#FFFFFF) is the standard background to reinforce the "clinical" feel.

## Typography

The typography strategy focuses on hierarchy and technical legibility. 
- **Manrope** is used for headlines, providing a modern, balanced, and approachable yet professional tone.
- **Inter** serves as the workhorse for all body copy and interface elements, chosen for its neutral, systematic clarity.
- **JetBrains Mono** is utilized sparingly for labels, SKU numbers, dosages, and technical data points to evoke a sense of scientific precision and data-driven accuracy.

## Layout & Spacing

The design system employs a **Fixed Grid** philosophy for desktop to maintain a strictly controlled information architecture, transitioning to a fluid model for mobile.

- **Desktop:** 12-column grid, 1140px max-width, 24px gutters.
- **Tablet:** 8-column grid, 24px margins.
- **Mobile:** 4-column grid, 16px margins.

Spacing follows a strict 8px base unit. In clinical views (data tables/dashboards), the spacing rhythm is tightened (sm/xs) to increase information density, while marketing or landing pages utilize "lg" and "xl" steps to create a premium, breathable experience.

## Elevation & Depth

Depth is handled through **Low-Contrast Outlines** and **Tonal Layers** rather than heavy shadows, maintaining a flat, modern, and clinical aesthetic.

- **Level 0 (Base):** Standard background surfaces.
- **Level 1 (Cards):** Defined by a 1px border (#E2E8F0) with no shadow.
- **Level 2 (Interactive/Hover):** A subtle, ultra-diffused shadow (0px 4px 12px rgba(13, 84, 184, 0.08)) is used to indicate interactivity.
- **Level 3 (Modals):** Backdrop blur (8px) with a prominent border to separate critical interactions from the background data.

## Shapes

The shape language is "Soft" (0.25rem base). This subtle rounding moves away from the aggressive sharpness of industrial design while avoiding the overly "bubbly" feel of consumer apps. It strikes a balance of professional rigor and modern accessibility. Large containers like cards should use `rounded-lg` (0.5rem) to soften the overall interface grid.

## Components

- **Logo Integration:** The primary brand mark must appear in the top-left of the Global Navigation. In compact views, the "Pill & Hand" icon may be used independently, but the full logotype is preferred for desktop.
- **Buttons:** Primary buttons use the Cobalt Blue (#0D54B8) with white text. Secondary buttons use a Teal (#27A7B1) outline. All buttons use 4px (Soft) corners.
- **Inputs:** Text fields use a 1px neutral-gray border. Upon focus, the border transitions to the Primary Cobalt with a subtle 2px outer glow in the same color at 10% opacity.
- **Chips/Status:** Use the Leaf Green (#50BC53) for "In Stock" or "Safe" states. Use the brand's secondary Teal for informational tags.
- **Cards:** White background, 1px light gray border, 8px corner radius. No shadow unless in a hovered state.
- **Data Tables:** High-density, using Inter for values and JetBrains Mono for units/measurements. Row stripes use a very faint gray (1% opacity of Primary) for legibility.