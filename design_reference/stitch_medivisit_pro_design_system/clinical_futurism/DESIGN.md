---
name: Clinical Futurism
colors:
  surface: '#fdf7ff'
  surface-dim: '#ded8e0'
  surface-bright: '#fdf7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f2fa'
  surface-container: '#f2ecf4'
  surface-container-high: '#ece6ee'
  surface-container-highest: '#e6e0e9'
  on-surface: '#1d1b20'
  on-surface-variant: '#494551'
  inverse-surface: '#322f35'
  inverse-on-surface: '#f5eff7'
  outline: '#7a7582'
  outline-variant: '#cbc4d2'
  surface-tint: '#6750a4'
  primary: '#4f378a'
  on-primary: '#ffffff'
  primary-container: '#6750a4'
  on-primary-container: '#e0d2ff'
  inverse-primary: '#cfbcff'
  secondary: '#63597c'
  on-secondary: '#ffffff'
  secondary-container: '#e1d4fd'
  on-secondary-container: '#645a7d'
  tertiary: '#765b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#c9a74d'
  on-tertiary-container: '#503d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#cfbcff'
  on-primary-fixed: '#22005d'
  on-primary-fixed-variant: '#4f378a'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#cdc0e9'
  on-secondary-fixed: '#1f1635'
  on-secondary-fixed-variant: '#4b4263'
  tertiary-fixed: '#ffdf93'
  tertiary-fixed-dim: '#e7c365'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#fdf7ff'
  on-background: '#1d1b20'
  surface-variant: '#e6e0e9'
typography:
  display-hero:
    fontFamily: Inter
    fontSize: 72px
    fontWeight: '800'
    lineHeight: 80px
    letterSpacing: -0.04em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  title-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
  container-max: 1440px
---

## Brand & Style

This design system embodies the "Clinical Futurism" aesthetic—a precise intersection of healthcare reliability and cutting-edge software craft. It is designed for medical professionals who require data density without cognitive load, and premium visual polish that mirrors the sophistication of modern medical hardware.

The visual style is a hybrid of **Glassmorphism** and **Modern Corporate**. It utilizes high-fidelity transparency, backdrop blurs, and layered depth to create a UI that feels light, breathable, and physically present. Surfaces should feel like architectural glass panels—solid yet ethereal—providing a sense of "clean-room" sterility mixed with the warmth of a high-end startup interface.

## Colors

The palette is anchored by a high-performance primary gradient that transitions from a deep medical blue to a technological teal, echoing the hues found in the provided brand asset. 

- **Primary Brand:** Use the three-point gradient for hero actions, progress indicators, and significant brand moments. 
- **Intelligence Layer:** The Violet (#7C5CFF) is reserved exclusively for AI-driven insights, automated suggestions, and smart diagnostics.
- **Background Strategy:** Implement "Mesh Gradients" rather than flat fills. In light mode, use a soft transition between the base and glow colors. In dark mode, maintain a deep navy base with subtle radial glows of primary blue at the screen corners to simulate depth.

## Typography

This design system uses **Inter** exclusively to maintain a utilitarian, clinical feel, relying on extreme weight contrast and scale to establish hierarchy. 

**Hero Numbers & Metrics:** For clinical data, vitals, or large headlines, use the `display-hero` style with a "Semi-Bold" or "Bold" weight. These should often be rendered with the primary gradient fill to draw immediate focus.
**Readability:** Body text should maintain generous line heights (1.5x) to ensure legibility in fast-paced clinical environments.

## Layout & Spacing

The layout follows a **Fluid Grid** model with high-density padding within components but expansive margins between major sections.

- **Desktop:** 12-column grid with 24px gutters. Content should be centered with a max-width of 1440px.
- **Mobile:** Single column with 16px side margins. 
- **Rhythm:** Use a 4px base unit. All internal component padding should be multiples of 4 (e.g., 12px, 16px, 24px).
- **Floating Architecture:** The navigation and primary global actions do not sit flush against the screen edges; they float with a consistent 16px-24px margin from the viewport boundary.

## Elevation & Depth

Hierarchy is defined through a 4-level "Z-axis" system that combines backdrop-blur with tinted ambient shadows.

1.  **Level 0 (Base):** Mesh gradient background. No shadows.
2.  **Level 1 (Sub-Cards):** Semi-transparent white (50% opacity), 1px white inner-border, no shadow.
3.  **Level 2 (Standard Cards):** Glassmorphism effect (backdrop-blur: 20px, 70% opacity). Soft ambient shadow: `0 8px 32px rgba(0,0,0,0.04)`.
4.  **Level 3 (Floating Nav/Modals):** Full glass effect. Large, diffused shadow: `0 16px 48px rgba(0,0,0,0.08)`. Use a 1px "Light Leak" border on the top and left edges to simulate physical thickness.

## Shapes

The shape language is "Hyper-Softened Geometric." 

- **Cards:** Use a consistent `rounded-lg` (16px) or `rounded-xl` (24px) for main containers to evoke a friendly, modern feel.
- **Bottom Navigation:** Must be pill-shaped (`rounded-full` or 28px+).
- **Interactive Elements:** Buttons and input fields should follow the `rounded-lg` (16px) standard to match the card corners, creating a nested, harmonious look.

## Components

### Buttons
- **Primary:** Gradient background, white text, subtle outer glow matching the teal/blue hue of the gradient.
- **Secondary:** Glass background (white at 10% opacity) with a 1px stroke.
- **AI Action:** Solid Violet (#7C5CFF) with a 20% opacity violet glow halo.

### Cards & Sheets
- **Featured Cards:** Apply a thin 1.5px gradient border. Use backdrop-blur: 20px. 
- **Standard Cards:** Subtle 1px solid border (#E2E8F0) and background-blur.

### Floating Bottom Nav
- A pill-shaped bar detached from the bottom by 16px. 
- Use 28px corner radius and a high backdrop-blur (30px). 
- Active icons should feature a duotone primary color with a soft circular glow behind them.

### Input Fields
- Background: Very light grey (#F1F5F9) at 60% opacity. 
- Focus state: 1.5px Primary Blue border with a 4px soft outer blue glow.

### Icons
- Style: Duotone. Use the Primary Blue for the main stroke and the Teal/Green for the secondary "accent" shapes within the icon.
- Effects: Add a 2px blurred "halo" behind key icons to give them a glowing, holographic appearance.