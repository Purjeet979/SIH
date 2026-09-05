---
name: Precision Hygiene
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daef'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f3ff'
  surface-container: '#e9edff'
  surface-container-high: '#e1e8fd'
  surface-container-highest: '#dce2f7'
  on-surface: '#141b2b'
  on-surface-variant: '#434655'
  inverse-surface: '#293040'
  inverse-on-surface: '#edf0ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#ab0b1c'
  on-tertiary: '#ffffff'
  tertiary-container: '#cf2c30'
  on-tertiary-container: '#ffecea'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3ad'
  on-tertiary-fixed: '#410004'
  on-tertiary-fixed-variant: '#930013'
  background: '#f9f9ff'
  on-background: '#141b2b'
  surface-variant: '#dce2f7'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.025em
  headline-xl-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0em
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: -0.005em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  space-2xs: 0.25rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1rem
  space-lg: 1.25rem
  space-xl: 1.5rem
  space-2xl: 2rem
  space-3xl: 2.5rem
  margin-mobile: 1rem
  margin-tablet: 1.5rem
  gutter: 1rem
---

## Brand & Style

This design system delivers a frictionless, clinical, yet reassuring compliance-monitoring experience. Designed primarily for mobile-first workflows, it balances technical rigor with visual serenity. The tone is authoritative, composed, and effortless—removing the anxiety typically associated with audits, policy infractions, and regulatory deadlines.

The aesthetic merges contemporary minimalism with subtle tactile warmth:
- **Tone:** Methodical, serene, crystalline, and dependable.
- **Visual Aesthetic:** Ultra-clean Scandinavian software design paired with Cupertino-level systemic discipline. Pure white surfaces rest on delicate cool-grey canvases, defined by hairline structural borders rather than heavy containers.
- **Feedback Philosophy:** Status-driven color interventions (sage greens, soft coral reds, amber warnings) punctuate an otherwise tranquil, monochrome structural layout to instantly communicate audit outcomes.

## Colors

The palette relies on high-luminance, pristine backgrounds layered with controlled functional accents. Ambient light greys construct depth, while hairline dividers enforce boundary discipline.

### Palette Roles
- **Canvas & Surfaces:**
  - `surface-base`: `#F8F9FA` (Primary app background, cool clean wash)
  - `surface-raised`: `#FFFFFF` (Primary card and modal background)
  - `surface-subtle`: `#F1F3F5` (Nested containers, scan viewfinders, input fills)
- **Text & Hierarchy:**
  - `text-primary`: `#111827` (Headings, primary metrics, active states)
  - `text-secondary`: `#4B5563` (Captions, sublabels, inactive tab labels)
  - `text-tertiary`: `#9CA3AF` (Placeholders, disabled metadata, timestamps)
- **Borders & Dividers:**
  - `border-subtle`: `#E5E7EB` (Standard hairline borders for cards and dividers)
  - `border-focus`: `#2563EB` (Active state rings, scanning crosshairs)
- **State Semantics:**
  - **Trust / Primary:** Primary blue `#2563EB` with tint `#EFF6FF` for selection tags, primary interactive elements, and scan triggers.
  - **Pass / Compliant:** Mint `#10B981` paired with wash `#D1FAE5` for verified rule sets, passing audit tags, and zero-violation badges.
  - **Violation / Critical:** Soft coral `#EF4444` paired with wash `#FEE2E2` for non-compliance alerts, failed checks, and immediate overrides.
  - **Pending / Warning:** Warm amber `#F59E0B` paired with wash `#FEF3C7` for syncing rules, processing states, and caution flags.

## Typography

Typography relies uniformly on **Inter** to maintain neutral, clinical legibility across high-density compliance data grids and quick-glance mobile viewports.

- Use negative tracking on headline sizes (`-0.01em` to `-0.025em`) to ensure titles appear tight, crisp, and authoritative.
- Numeric data, rule IDs, and compliance scores require tabular figures (`font-variant-numeric: tabular-nums`) to prevent layout jitter during live scanning streams.
- Labels and audit status badges utilize micro tracking (`+0.02em` to `+0.04em`) with medium or semibold weights for instant legibility at 11–12px scales.

## Layout & Spacing

The layout is built on a 4px/8px incremental rhythm configured primarily for high-utility handheld interaction.

### Breakpoints & Containers
- **Mobile (< 640px):** Single column fluid grid. Standard edge margin is `1rem` (16px), expanding to `1.25rem` (20px) on viewport heights exceeding 800px.
- **Tablet / Large Handheld (640px - 1024px):** 2-column card layout with `1.5rem` (24px) side margins and gutters.

### Layout Mechanics
- Vertical spacing between distinct operational blocks is standard `1.5rem` (24px).
- Internal card padding is consistently `1.25rem` (20px), tapering to `1rem` (16px) on compact sub-cards.
- Interactive tap zones are enforced at a strict minimum of 44×44px, surrounded by at least `0.5rem` (8px) of negative space.

## Elevation & Depth

Visual hierarchy uses ultra-soft ambient diffuse shadowing coupled with hairline boundaries. Strong drop shadows are prohibited to preserve a pure, distraction-free environment.

### Elevation Hierarchy
- **Level 0 (Flat Canvas):** `#F8F9FA`. Base layer containing scrollable background feeds.
- **Level 1 (Cards & Modules):** Pure white `#FFFFFF` surface bounded by a crisp 1px stroke of `#E5E7EB`. Casts an ambient shadow: `0px 2px 8px rgba(17, 24, 39, 0.04), 0px 1px 2px rgba(17, 24, 39, 0.02)`.
- **Level 2 (Dropdowns, Elevated Panels, Action Sheets):** `#FFFFFF` surface with `border: 1px solid #E5E7EB` and deep diffuse shadow: `0px 12px 24px -4px rgba(17, 24, 39, 0.08), 0px 4px 8px -2px rgba(17, 24, 39, 0.03)`.
- **Level 3 (Toasts, Floating Scan Trigger, Sticky Bottom Bars):** Lifted floating elements with subtle backdrop diffusion (`backdrop-filter: blur(16px)` on a `rgba(255, 255, 255, 0.88)` fill), framed by `border: 1px solid rgba(229, 231, 235, 0.8)` and `box-shadow: 0px 16px 32px -8px rgba(17, 24, 39, 0.12)`.

## Shapes

The geometric personality features modern, friendly curvature tempered by strict structural alignments. 

- **Primary Cards & Containers:** Radii strictly adhere to `16px` to `24px` (`rounded-xl` to `rounded-2xl`). This softens complex regulatory checklists into bite-sized, approachable units.
- **Controls & Form Elements:** Text inputs, inline select menus, and action sheets utilize `12px` to `16px` (`rounded-lg` to `rounded-xl`).
- **Interactive Badges, Pills & Buttons:** Full pill geometry (`rounded-full`, 9999px) is reserved for status badges, tags, scan triggers, and micro action chips to maximize tap affordance and visual contrast against square screen bounds.

## Components

### Buttons
- **Primary:** Full pill shape, `#2563EB` background with `#FFFFFF` text (`label-lg`). High tap feedback using a gentle scale-down transform (`scale(0.98)`).
- **Secondary:** White `#FFFFFF` surface, `1px solid #E5E7EB`, text `#111827`. Hover/active fill transitions to `#F8F9FA`.
- **Destructive:** Soft coral wash `#FEE2E2` surface with `#EF4444` text.
- **Floating Scan Action Button (FAB):** Central bottom anchor, 56px height, pill-extended with scan icon and "New Scan" text. Employs Level 3 elevation.

### Status Chips & Badges
- **Compliant:** `#D1FAE5` background, `#065F46` text, leading 6px circular dot in `#10B981`. Full pill radius, padding `4px 10px`.
- **Violation:** `#FEE2E2` background, `#991B1B` text, leading icon in `#EF4444`. Full pill radius, padding `4px 10px`.
- **Pending / In-Review:** `#FEF3C7` background, `#92400E` text, subtle pulse indicator. Full pill radius, padding `4px 10px`.

### Cards & Audit List Items
- Outer container wrapped in pure white (`#FFFFFF`) with a 1px `#E5E7EB` border and 16px corner radius.
- Standard layout: Left-hand state glyph or severity indicator, centered rule title (`label-lg`) over policy category (`body-sm`), right-hand trailing badge or disclosure chevron.
- Tapping an item opens an accordion-like panel or pushes a full-detail view with zero layout shifts.

### Inputs & Field Search
- Minimum 48px height. Background `#F1F3F5` in resting state; shifts to `#FFFFFF` with a 1.5px `#2563EB` ring when focused.
- Placeholder styled in `#9CA3AF`, inputs using `#111827` (`body-md`).
- Clear visual reset button (X) pinned inside the right boundary.

### Checkboxes & Selection Controls
- Rounded 6px square for checkboxes; full circular for radios.
- Inactive: 1.5px border `#D1D5DB`, background transparent.
- Active: Background `#2563EB` with pure white check/bullet icon. Unchecked tap area maintains minimum 44px hit bounds via transparent padding.

### Real-Time Scan Viewfinder (Specialized Component)
- Translucent viewport frame with high-precision corner tick marks colored `#2563EB`.
- Horizontal scanning beam rendered as an animated gradient (`linear-gradient(to bottom, rgba(37,99,235,0), rgba(37,99,235,0.4))`).
- Real-time detection pills float over recognized compliance targets displaying instant Pass/Fail indicators.