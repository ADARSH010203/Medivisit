---
name: Clinical Precision
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daea'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eefe'
  surface-container-high: '#e2e8f8'
  surface-container-highest: '#dce2f3'
  on-surface: '#151c27'
  on-surface-variant: '#424655'
  inverse-surface: '#2a313d'
  inverse-on-surface: '#ebf1ff'
  outline: '#727687'
  outline-variant: '#c2c6d8'
  surface-tint: '#0055d5'
  primary: '#0053d3'
  on-primary: '#ffffff'
  primary-container: '#1a6bff'
  on-primary-container: '#fffeff'
  inverse-primary: '#b3c5ff'
  secondary: '#006b5c'
  on-secondary: '#ffffff'
  secondary-container: '#68fadd'
  on-secondary-container: '#007261'
  tertiary: '#575c76'
  on-tertiary: '#ffffff'
  tertiary-container: '#707490'
  on-tertiary-container: '#fffeff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae1ff'
  primary-fixed-dim: '#b3c5ff'
  on-primary-fixed: '#001849'
  on-primary-fixed-variant: '#003fa4'
  secondary-fixed: '#68fadd'
  secondary-fixed-dim: '#44ddc1'
  on-secondary-fixed: '#00201a'
  on-secondary-fixed-variant: '#005145'
  tertiary-fixed: '#dde1ff'
  tertiary-fixed-dim: '#c1c5e3'
  on-tertiary-fixed: '#151a31'
  on-tertiary-fixed-variant: '#41455f'
  background: '#f9f9ff'
  on-background: '#151c27'
  surface-variant: '#dce2f3'
typography:
  display:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 21px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  stats-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  edge: 20px
  card-padding: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style
The design system is engineered for high-stakes medical sales environments where speed, reliability, and clarity are paramount. The aesthetic merges **Corporate / Modern** professional standards with **Fintech-inspired polish**, ensuring the interface feels like a high-performance tool rather than a generic utility.

The personality is authoritative yet approachable—evoking the trust of a medical institution while maintaining the agility of a modern SaaS platform. It prioritizes information density without sacrificing legibility, utilizing high-contrast elements and purposeful whitespace to guide the user through complex sales workflows and data-heavy product catalogs.

## Colors
The palette is rooted in "Medical Blue" and "Trust Teal," optimized for both clinical environments and bright outdoor field use. 

- **Primary & Action:** #1A6BFF is used for primary actions, navigation states, and brand presence.
- **Surface Strategy:** In light mode, surfaces use pure white against a light grey-blue background to create distinct layering. In dark mode, a deep navy base (#0B1220) is paired with slightly lighter surface cards (#151B2C) to reduce eye strain during late-night charting.
- **Semantic Feedback:** Standardized status colors (Error, Warning, Success) are used sparingly but boldly to signal critical medical or sales updates.

## Typography
The system exclusively uses **Inter** for its neutral, systematic character and exceptional legibility. 

- **Headings:** Utilize semi-bold and bold weights with tight letter spacing (-1% to -2%) to create a compact, professional appearance.
- **Body:** Set at a 1.5 line height to ensure readability of long-form medical notes and product descriptions.
- **Data & Metrics:** For numerical values, use `font-variant-numeric: tabular-nums`. This ensures that numbers align vertically in lists and dashboards, facilitating quick comparison of sales figures or inventory levels.

## Layout & Spacing
This design system employs a **4px base unit** grid. 

- **Mobile Constraints:** On handheld devices, a 20px safe-area margin is maintained at the screen edges. 
- **Card Layouts:** Information is grouped into cards with 16px internal padding.
- **Vertical Rhythm:** Spacing between related items should be 8px (stack-sm), while distinct sections should be separated by 24px (stack-lg).
- **Responsive Behavior:** The layout uses a fluid-width approach for mobile, transitioning to a centered 12-column grid on tablet and desktop (max-width 1200px).

## Elevation & Depth
Depth is communicated through a combination of subtle shadows and tonal layering.

- **Light Mode:** Uses "Ambient Shadows." High-level containers (cards) feature a `0px 2px 8px rgba(0,0,0,0.06)` shadow. This provides a soft lift from the #F7F9FC background without looking heavy.
- **Dark Mode:** Shadows are largely discarded in favor of "Tonal Layers" and "Low-contrast Outlines." Surfaces are differentiated by a 1px hairline border (#2A3349) and slight variations in background hex values. 
- **Floating Actions:** The "Quick Log" action button uses a more pronounced shadow to indicate it sits on the highest Z-index above the bottom navigation bar.

## Shapes
The shape language balances modern softness with professional structure.

- **Cards/Containers:** Use a 12px radius to feel modern and approachable.
- **Interactive Elements:** Buttons, text inputs, and dropdowns use an 8px radius, providing a crisp, functional appearance.
- **Status & Pills:** All badges and tags use a fully rounded (999px) pill shape to distinguish them clearly from interactive buttons.

## Components
- **Buttons:** 
  - *Primary:* Solid #1A6BFF with white text. 
  - *Secondary:* Outlined with a 1px border.
  - *Sizing:* Height is standardized to 48px for easy thumb tapping in the field.
- **Bottom Navigation:** Fixed height of 64px. Icons use an outline style for inactive states and a solid/filled style for the active state. The center "Quick Log" button is a 56px circle floating slightly above the bar.
- **Status Badges:** Pill-shaped. Use a 10% opacity background of the semantic color (e.g., 10% Success Green) with a 100% opacity text color for optimal contrast and "tinted" aesthetic.
- **Input Fields:** 8px rounded corners. In focus state, the border shifts to Primary Blue with a 2px outer glow. Labels are always visible above the field in `label-sm` style.
- **Lists:** Clean rows with 1px dividers (#E5E9F2). Each row has a 16px vertical padding to accommodate rapid scrolling.