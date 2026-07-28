---
name: Clinical Futurism Admin
colors:
  surface: '#101221'
  surface-dim: '#101221'
  surface-bright: '#363848'
  surface-container-lowest: '#0b0d1b'
  surface-container-low: '#191b29'
  surface-container: '#1d1f2d'
  surface-container-high: '#272938'
  surface-container-highest: '#323443'
  on-surface: '#e1e1f6'
  on-surface-variant: '#b9cacb'
  inverse-surface: '#e1e1f6'
  inverse-on-surface: '#2e2f3f'
  outline: '#849495'
  outline-variant: '#3a494b'
  surface-tint: '#00dbe7'
  primary: '#e1fdff'
  on-primary: '#00363a'
  primary-container: '#00f2ff'
  on-primary-container: '#006a71'
  inverse-primary: '#00696f'
  secondary: '#d1bcff'
  on-secondary: '#3c0090'
  secondary-container: '#7000ff'
  on-secondary-container: '#ddcdff'
  tertiary: '#fff5f6'
  on-tertiary: '#66002c'
  tertiary-container: '#ffcfd8'
  on-tertiary-container: '#be0059'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#74f5ff'
  primary-fixed-dim: '#00dbe7'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#d1bcff'
  on-secondary-fixed: '#23005b'
  on-secondary-fixed-variant: '#5700c9'
  tertiary-fixed: '#ffd9e0'
  tertiary-fixed-dim: '#ffb1c3'
  on-tertiary-fixed: '#3f0019'
  on-tertiary-fixed-variant: '#8f0041'
  background: '#101221'
  on-background: '#e1e1f6'
  surface-variant: '#323443'
typography:
  display-xl:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-sm:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1'
    letterSpacing: 0.05em
  kpi-value:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: '1'
    letterSpacing: -0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-max: 1440px
  sidebar-width: 280px
  gutter: 24px
  margin-page: 40px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style
This design system adapts "Clinical Futurism" for high-density web administration. It merges the sterile precision of medical interfaces with the depth and vibrancy of futuristic glassmorphism. The aesthetic targets power users in biotech, high-tech infrastructure, or data-driven labs, evoking a sense of hyper-clean, high-performance intelligence.

The style is defined by **Glassmorphism** and **Minimalism**. It uses wide-open layouts, rigorous alignment, and translucent materials to create a multi-dimensional workspace. Visual interest is driven by "light-leaks" and mesh gradients that provide a biological, organic counterpoint to the sharp, systematic UI controls.

## Colors
The palette is rooted in a "Deep Space" navy neutral, providing a high-contrast foundation for glowing accents. 

- **Primary (Cyan/Teal):** Used for critical actions, active states, and "healthy" data metrics.
- **Secondary (Violet):** Used for specialized functions and secondary data paths.
- **Surface Strategy:** The background uses a solid `#03040A` to ensure maximum contrast for glass layers.
- **Data Visualization:** Charts must use the defined glowing gradients. Backgrounds of charts should remain transparent to leverage the underlying glass blur of the container.

## Typography
The system utilizes **Inter** for its systematic clarity and high legibility in complex data environments. For technical labels and monospaced data readouts, **Geist** is introduced to provide a developer-centric, "clinical" feel.

- **KPI Treatments:** Large numerical values use `kpi-value` with a linear gradient (Primary to Secondary) to draw immediate attention.
- **Hierarchy:** Use `label-sm` for section headers in the sidebar and table column headers to maintain a structured, "instrument panel" appearance.

## Layout & Spacing
The layout follows a **Fixed-Fluid** hybrid model. The Sidebar is fixed at 280px, while the main content area occupies the remaining width up to a maximum of 1440px to prevent excessive line lengths.

- **Grid:** Use a 12-column grid for the content area. 
- **Density:** Maintain generous white space (`stack-lg`) between major modules to reinforce the "Clinical" feel, while using tighter spacing (`stack-sm`) within data tables and control groups.
- **Sidebar:** Positioned on the left, using a full-height glass panel that stays pinned during scroll.

## Elevation & Depth
This design system rejects traditional shadows in favor of **Glassmorphism** and **Inner Glows**. Depth is communicated through variable blur and opacity.

- **Level 0 (Base):** Solid `#03040A`. Mesh "blobs" (Primary/Secondary colors) sit at 5% opacity behind everything.
- **Level 1 (Panels):** 10% white opacity, 20px backdrop blur. No border. Used for the background of the main content area or grouping large sections.
- **Level 2 (Cards/Modals):** 20% white opacity, 40px backdrop blur. Features a 1px solid border at 15% white opacity with an "Inner Glow" (0px 0px 8px 1px) using a faint Primary color tint.
- **Sidebar Layer:** `#0A0C1A` at 80% opacity with 30px blur. This creates a dense, premium "heavy glass" effect where mesh gradients are visible but heavily diffused.

## Shapes
Shapes are precise and intentional. We use a standard **0.5rem (8px)** corner radius for most UI elements to balance approachable design with a professional, structured feel.

- **Pills:** Search bars, filter chips, and status badges use "full rounded" (999px) settings to distinguish them from structural containers.
- **Interactions:** Hover states should slightly increase the inner glow intensity rather than changing the border-radius.

## Components

### Buttons & Inputs
- **Primary Action:** Solid gradient background (Primary to Secondary) with white text. High-glow on hover.
- **Secondary Action:** Level 2 glass treatment with a primary-colored border.
- **Inputs:** Darker glass (5% opacity) with a 1px bottom border. On focus, the border glows Primary Cyan.

### Sidebar
- **Navigation Items:** Transparent backgrounds. Active state uses a "glass-morphic inset" look: a 10% white background with a vertical glow strip on the left edge.
- **Icons:** Duotone style. The primary path is white, and the secondary/background path uses the Primary color with a subtle 4px outer glow.

### Cards & KPIs
- **Data Cards:** Use Level 2 glass. KPI values inside should be rendered with the `kpi-value` gradient.
- **Charts:** Remove all axes and grid lines where possible for a "floating" data look. Lines and bars must use the data-viz gradients with a 10px drop-shadow matching the line color to simulate a neon glow.

### Filters & Chips
- **Glass Pills:** Search bars and filters use 15% opacity glass with 100px border-radius. Text is small, tracked out (`label-sm`), and high-contrast.