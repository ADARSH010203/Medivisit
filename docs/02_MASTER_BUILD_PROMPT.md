# MediVisit Pro — Master Build Brief
### Paste this entire document as your first message to a new Antigravity Agent task.

---

## ROLE & OPERATING MODE

You are an autonomous senior Flutter + Firebase engineer building **MediVisit Pro**, a production-grade field-force app for medical representatives (MRs) and their managers, for the client **UMAKIND Pharma**. You have a complete, professionally designed UI reference (Stitch HTML/CSS exports + PNG screenshots) sitting in `design_reference/` in this repository, two product-requirement documents in `docs/`, and this brief, which is the single source of truth whenever those documents disagree with each other.

Operate in **review-driven mode**: before writing code for a new phase or module, produce a short plan Artifact and pause for my approval. Before running any destructive or irreversible command (`rm -rf`, force-push, dropping a Firestore collection, regenerating Firebase config), always ask first regardless of your autonomy setting. Never invent a screen, flow, or field that isn't specified somewhere in this document or in `design_reference/` — if you think something is missing, ask me instead of guessing.

Read this entire document before writing any code. Then read every `DESIGN.md` and a sample of `code.html` files referenced in Section 2 to confirm you understand the visual language before Phase 0.

---

## 1. PROJECT SUMMARY

**Product:** MediVisit Pro — a Flutter mobile app for medical representatives plus a Flutter Web admin console for their managers.

**What it does:** MRs log daily doctor visits (with mandatory GPS proof), mark attendance, request leave, browse a product catalog, track sample/promotional material distribution, submit expenses with receipt OCR, get an AI-optimized daily route, and engage with gamified performance tracking. Managers/admins verify new MR accounts, manage doctors and products, approve leave, watch live field activity on a map, and review analytics — all through a separate, visually distinct web console.

**Two physically separate Flutter apps sharing one Dart core package** (see Section 7):
- `apps/mr_mobile` — Android + iOS, MR-facing
- `apps/admin_web` — Flutter Web, manager/admin-facing

**Backend:** Firebase (Auth, Firestore, Storage, Cloud Functions, Cloud Messaging) for the entire build described in this brief. A future migration to Node.js + PostgreSQL is documented in the source PRDs as a *post-MVP scaling decision* — out of scope here. Build the data layer behind repository interfaces specifically so that migration doesn't require a rewrite (Section 7.4).

---

## 2. REPOSITORY & SOURCE-OF-TRUTH MAP

### 2.1 Folder structure to scaffold in Phase 0
```
medivisit_pro/
├── design_reference/        # read-only. Stitch export. Never ships in either app.
├── docs/                    # this brief + the two original PRDs
├── packages/
│   └── core/                # shared models, repositories, theme, Firebase services
└── apps/
    ├── mr_mobile/
    └── admin_web/
```

### 2.2 Which `design_reference/` folders are canonical (build these) vs. drafts (ignore these)

The export contains 12 superseded draft duplicates left over from earlier design iterations. **Build only the canonical folder for each screen.** Use the draft folders only if the canonical one is somehow missing a detail you need.

| Screen | ✅ Canonical folder | ❌ Ignore (drafts) |
|---|---|---|
| Splash | `splash_screen_clinical_futurism_2` | `splash_screen_animated`, `splash_screen_clinical_futurism_1`, `splash_screen_updated_logo` |
| Login | `login_clinical_futurism_2` | `login_animated`, `login_updated_logo`, `login_clinical_futurism_1` |
| Register | `register_clinical_futurism` | `register` |
| Onboarding step 1 | `onboarding_step_1_2` | `onboarding_step_1_1`, `onboarding_step_1_animated` |
| Onboarding step 2 | `onboarding_step_2_2` | `onboarding_step_2_1` |
| Onboarding step 3 | `onboarding_step_3_2` | `onboarding_step_3_1` |
| Voice/AI search | `ai_voice_search_actions_rebuilt` | `ai_voice_search_actions`, `ai_voice_search_actions_fixed` |

All other folders listed in Sections 4.1 and 4.2 below have exactly one version — build them as-is.

**Non-screen reference folders** (use only as style/asset references, not standalone screens to build): `clinical_precision_1/DESIGN.md`, `clinical_precision_2/DESIGN.md` (superseded design language — see Section 3), `clinical_futurism/DESIGN.md`, `clinical_futurism_admin/DESIGN.md` (these two ARE the canonical token references — read them fully), `medivisit_pro_logo/`, `logo_cmbxrtnq.jpeg/` (brand mark), and the seven `premium_3d_illustration_*` / `a_premium_3d_clinical_illustration_*` folders (decorative hero illustrations — use where a screen's design calls for one, e.g. splash and onboarding).

### 2.3 How to read each screen folder
Every canonical folder contains `code.html` (literal Tailwind/HTML the screen was generated as — use it as your exact spacing/typography/structure reference) and `screen.png` (rendered screenshot — use it for pixel-level visual verification per Section 10). Treat `code.html`'s DOM structure and Tailwind classes as a strong hint for widget structure (card nesting, spacing scale, font sizes) — don't just eyeball the PNG.

---

## 3. DESIGN SYSTEM — SINGLE SOURCE OF TRUTH

### 3.1 Why this section overrides some of what's in `design_reference/`
The export contains **three competing design directions**: two early ones called "Clinical Precision" (flat blue/teal, Material 3 default styling — used by ~45 of the early-generated mobile screens) and the final, more deliberate one, "Clinical Futurism" (glassmorphism, mesh gradients — used only by the auth-flow screens) plus its already-consistent web counterpart "Clinical Futurism Web" (used by all 11 admin screens, no conflict). 

**Rule: build every mobile screen — including the ~45 that currently exist only in the old Clinical Precision style — using Clinical Futurism tokens below.** Keep each screen's actual layout, card structure, content, and information hierarchy exactly as designed in its `code.html`; only restyle the *surface treatment* (flat → glass, solid shadow → soft ambient glow, flat color → gradient where specified).

If at any point you're unsure whether a value comes from "Clinical Futurism" (use it) or "Clinical Precision" (don't), the literal `clinical_futurism/DESIGN.md` and `clinical_futurism_admin/DESIGN.md` files win.

### 3.2 Brand
- Client: UMAKIND Pharma. Product: MediVisit Pro. The product name "MediVisit Pro" is the user-facing app name everywhere; the UMAKIND Pharma logo (`logo_cmbxrtnq.jpeg`) appears only on the splash screen and login screen, as in the reference.
- **Primary brand gradient** (use for primary buttons, hero progress rings, key brand moments): `linear-gradient(135deg, #4F378A 0%, #008080 100%)`. This exact value is pulled from the live login screen's CSS — don't substitute the flat `#4F378A` from the `DESIGN.md` color table alone; that table entry is a fallback solid, not the brand treatment.
- **AI/Intelligence accent:** Violet `#7C5CFF`, used *exclusively* for AI-driven features — the AI Suggested badge on the route planner, the voice-search sheet, AI-flagged "High Priority" doctor badges, content-recommendation cards. Never use this violet for default UI chrome.

### 3.3 Mobile app tokens — "Clinical Futurism" (apply to every `mr_mobile` screen)

**Color (light mode baseline — implement dark mode as a parallel token set per the elevation rules below):**

| Token | Value | Token | Value |
|---|---|---|---|
| background / surface | `#FDF7FF` | primary | `#4F378A` |
| surface-container-lowest | `#FFFFFF` | primary-container | `#6750A4` |
| surface-container-low | `#F8F2FA` | on-primary / on-primary-container | `#FFFFFF` / `#E0D2FF` |
| surface-container | `#F2ECF4` | secondary | `#63597C` |
| surface-container-high | `#ECE6EE` | secondary-container | `#E1D4FD` |
| surface-container-highest | `#E6E0E9` | tertiary (brand teal accent) | `#008080` |
| on-surface | `#1D1B20` | error / on-error | `#BA1A1A` / `#FFFFFF` |
| on-surface-variant | `#494551` | error-container | `#FFDAD6` |
| outline / outline-variant | `#7A7582` / `#CBC4D2` | AI accent (see 3.2) | `#7C5CFF` |

**Typography** — Inter, exclusively:
| Style | Size / Line height | Weight |
|---|---|---|
| display-hero (rare — splash/onboarding only) | 72/80, -0.04em | 800 |
| headline-lg (desktop admin only) | 32/40 | 700 |
| headline-lg-mobile (screen titles) | 24/32 | 700 |
| title-md (card titles, section headers) | 20/28 | 600 |
| body-lg (default body) | 16/24 | 400 |
| body-sm (secondary text, captions) | 14/20 | 400 |
| label-caps (eyebrow labels, nav labels) | 12/16, +0.05em tracking, UPPERCASE | 600 |

**Shape:** corner radius `rounded-lg` (16px) for cards/inputs/buttons; `rounded-xl` (24px) for featured/hero cards; bottom nav and pills always `rounded-full`.

**Spacing:** 4px base unit. Mobile side margins 16px. Card internal padding multiples of 4 (12/16/24px).

**Elevation (4-level glass system — implement as reusable widgets, don't hand-roll per screen):**
1. **Level 0 — base:** mesh-gradient background (soft multi-stop radial gradient blending surface + a hint of primary/teal/tertiary at low opacity — replicate the `mesh-gradient` CSS class found in `login_clinical_futurism_2/code.html`). No shadow.
2. **Level 1 — sub-cards:** white at 50% opacity, 1px white inner border, no shadow.
3. **Level 2 — standard cards:** `backdrop-blur: 20px`, white/surface at 70% opacity, shadow `0 8px 32px rgba(0,0,0,0.04)`.
4. **Level 3 — floating nav / modals / sheets:** full glass, shadow `0 16px 48px rgba(0,0,0,0.08)`, plus a 1px lighter "light-leak" border on the top and left edges only.

**Components:**
- Primary button: brand gradient fill (3.2), white text, subtle outer glow in the teal hue, `rounded-lg`, 14px vertical padding.
- Secondary button: glass background (white @10% opacity), 1px stroke, same radius.
- AI-action button/badge: solid `#7C5CFF` fill with a 20%-opacity violet glow halo — reserve for AI-attributed actions only.
- Bottom nav: pill-shaped, floating 16px off the bottom edge, 28px corner radius, `backdrop-blur: 30px`. Active tab = duotone primary icon with a soft circular glow behind it.
- Inputs: background `#F1F5F9` @60% opacity; focus state = 1.5px primary-blue border + 4px soft outer glow.
- Icons: duotone — primary stroke, teal/green secondary accent shapes; add a subtle 2px blurred halo behind icons used in hero/key moments (not every icon — that becomes noisy).

### 3.4 Admin web tokens — "Clinical Futurism Web" (apply to every `admin_web` screen)

**Color (dark-mode-only — this app has no light mode):**

| Token | Value | Token | Value |
|---|---|---|---|
| background / surface | `#101221` | primary (cyan) | `#00F2FF` (container) / `#E1FDFF` (on-dark text) |
| surface-container-lowest | `#0B0D1B` | on-primary | `#00363A` |
| surface-container-low | `#191B29` | secondary (violet) | `#7000FF` (container) / `#D1BCFF` |
| surface-container | `#1D1F2D` | on-secondary | `#3C0090` |
| surface-container-high | `#272938` | error | `#FFB4AB` / container `#93000A` |
| on-surface | `#E1E1F6` | sidebar layer | `#0A0C1A` @80% opacity, 30px blur |
| on-surface-variant | `#B9CACB` | true page background | solid `#03040A` (per the elevation rule below — not the lighter `#101221` token; mesh blobs sit on top of this) |

**Typography:** Inter for everything except technical/tabular labels and table column headers, which use **Geist**. Sizes: `display-xl` 48/1.1 weight 700 (rare hero numbers), `headline-lg` 32/1.2 weight 600, `headline-md` 24/1.3 weight 600, `body-lg` 18/1.6, `body-md` 16/1.5, `label-sm` 12/1, +0.05em tracking (sidebar section headers, table headers), `kpi-value` 40/1, -0.03em (large dashboard numbers — render with a primary→secondary linear gradient fill, not flat color).

**Layout:** fixed 280px sidebar (full-height, pinned glass panel) + fluid content area, max-width 1440px, 12-column grid, 24px gutters, 40px page margin. Generous `stack-lg` (32px) between major modules; tighter `stack-sm` (8px) inside data tables.

**Elevation:**
1. **Level 0:** solid `#03040A`. Mesh "blobs" (primary cyan + secondary violet) at 5% opacity behind everything, fixed/slow-moving.
2. **Level 1 — panels:** white @10% opacity, 20px blur, no border — used for big section-grouping containers.
3. **Level 2 — cards/modals/KPI tiles:** white @20% opacity, 40px blur, 1px solid border @15% white opacity, plus an inner glow `0 0 8px 1px` tinted with the primary cyan.

**Shape:** 8px (`0.5rem`) standard radius for structural elements; full-pill (999px) for search bars, filter chips, and status badges specifically (this contrast is intentional — keep it).

**Components:**
- Primary action: solid gradient (primary cyan → secondary violet), white text, glow intensifies on hover.
- Sidebar nav: transparent background; active item = 10% white inset background + a glowing vertical strip on the left edge. Icons duotone, white primary path + cyan secondary path with a 4px outer glow.
- Charts: no axis lines or gridlines — "floating" data look. Use the cyan→violet gradient for lines/bars with a 10px drop-shadow matching the line color (neon-glow effect). Backgrounds transparent so the glass container blur shows through.

### 3.5 Cross-cutting rules
- **Motion:** subtle, physical — scale-down (0.98) on button press, smooth crossfades between screens, no jarring slides. The visit-success screen (`visit_success_celebration`) is the one place a more expressive celebratory animation (confetti / animated checkmark) is appropriate — consider the `lottie` package for it rather than hand-built `AnimationController` choreography.
- **Dark mode (mobile app only — admin web is always dark):** implement as a true parallel token set behind a `ThemeExtension`, not by darkening colors at runtime. Use the `dark:` variants implied by the Material token names in `clinical_futurism/DESIGN.md` (e.g. `inverse-surface`, `inverse-on-surface`) as your dark-mode base.
- **Accessibility:** every text/background pairing must meet WCAG AA contrast even on glass surfaces — glass effects often fail this silently; check `on-surface`-on-blurred-background combinations specifically.

---

## 4. INFORMATION ARCHITECTURE

### 4.1 Mobile app (`mr_mobile`) — canonical navigation

Source screens use inconsistent nav bars (different tab sets/labels on almost every screen). **Build exactly one consistent nav for the whole app**, defined below — do not copy any single screen's nav bar literally.

**Bottom nav (5 tabs, always visible after login, pill-shaped per 3.3) + center FAB:**

| Tab | Icon | Lands on |
|---|---|---|
| Home | grid/dashboard | `mr_dashboard_home` |
| Visits | stethoscope | `doctor_visits_day_selector` |
| Catalog | medication/box | `product_catalog_grid` |
| Insights | trending-up | `performance_report_screen` |
| Profile | person | `mr_profile_screen` |
| *(center, floating)* FAB | + | Opens `quick_log_action_sheet` |

**Full screen → route map (mobile):**

| Design folder | Route | Reached from |
|---|---|---|
| `splash_screen_clinical_futurism_2` | `/splash` | App launch |
| `onboarding_step_1_2` / `_2_2` / `_3_2` | `/onboarding/1,2,3` | First launch only, skippable |
| `login_clinical_futurism_2` | `/login` | Splash / onboarding / logout |
| `register_clinical_futurism` | `/register` | Login → "Register here" |
| `pending_verification` | `/pending-verification` | Register submit, before admin approval |
| `account_under_review_clinical_futurism` | `/account-under-review` | Login attempt while `is_verified == false` |
| `mr_dashboard_home` | `/home` | Tab: Home |
| `doctor_visits_day_selector` | `/visits` | Tab: Visits |
| `doctor_profile_detail` | `/visits/doctor/:doctorId` | Tap a doctor card |
| `quick_log_action_sheet` | modal sheet, no route | FAB |
| `confirm_visit_location` | `/visits/:doctorId/confirm` | "Mark as Visited" |
| `visit_success_celebration` | `/visits/:visitId/success` | Confirm visit submit |
| `doctor_rating_feedback` | `/visits/:visitId/rate` | After success screen |
| `visit_history_log` | `/visits/history` | Icon on Visits tab |
| `visit_detail_audit_view` | `/visits/history/:visitId` | Tap a history row |
| `sample_log_screen` | `/samples` | From a visit's detail, or Home module grid |
| `smart_route_planner` | `/route-planner` | "AI Suggested" banner on Home |
| `manager_feedback_loop` | `/visits/:visitId/feedback` | Notification, or visit detail |
| `interactive_engagement_hub` | `/catalog/:productId/engage` | Product detail → "Interactive Aids" |
| `product_catalog_grid` | `/catalog` | Tab: Catalog |
| `product_detail_screen` | `/catalog/:productId` | Tap a product |
| `share_product_modal` | modal, no route | Product detail → Share |
| `mark_attendance_screen` | `/attendance` | Home module grid card "Attendance", or FAB |
| `attendance_history_calendar` | `/attendance/history` | Icon on attendance screen |
| `leave_request_form` | `/leave/new` | Home module grid card "Leave", or FAB |
| `leave_history_status` | `/leave/history` | Icon on leave screen |
| `expense_submission_ocr` | `/expenses/new` | Profile menu → "Expenses" |
| `expense_history` | `/expenses` | Profile menu → "Expenses" |
| `performance_report_screen` | `/insights` | Tab: Insights |
| `achievements_badges_screen` | `/insights/achievements` | Insights → "Achievements" |
| `leaderboard_screen` | `/insights/leaderboard` | Insights → "Leaderboard" |
| `notifications_screen` | `/notifications` | Bell icon, present on every top bar |
| `ai_voice_search_actions_rebuilt` | modal, no route | Search/mic icon, present on every top bar |
| `mr_profile_screen` | `/profile` | Tab: Profile |
| `edit_profile_screen` | `/profile/edit` | Profile → "Edit Profile" |

### 4.2 Admin web (`admin_web`) — canonical navigation

The source screens' sidebar uses generic leftover labels from whatever template Stitch started from. **Relabel as follows** (functionally these are the same screens, just correctly named for an MR/doctor engagement product, not a patient-facing clinical system):

| Source label | Use instead |
|---|---|
| "Patients" | "Doctors" |
| "Clinical Data" | "Reports & Analytics" |
| "Schedules" | "Leave Approvals" |
| "System Config" | "Settings" |

**Sidebar (fixed 280px, always visible, per 3.4):**

| Sidebar item | Design folder | Sub-routes |
|---|---|---|
| Dashboard | `admin_dashboard_overview` | — |
| MR Management | `mr_management_list` | `mr_verification_queue`, `mr_detail_tracking` |
| Doctor Management | `doctor_management` | — |
| Product Management | `product_management` | — |
| Leave Approvals | `leave_approval_screen` | — |
| Reports & Analytics | `reports_analytics` | — |
| Live Tracking | `live_location_tracking_map` | — |
| Notifications | `notification_sender` | — |
| Settings | *(no screen supplied — build a minimal settings page: org profile, admin user management, territory definitions; see Section 5.16)* | — |

`admin_login` is the unauthenticated entry route (`/admin/login`), outside the sidebar shell.

MR Management's badge/notification count should reflect `mr_verification_queue`'s pending count (see Section 5.1) — this is the "Pending Verifs." KPI already visible on `admin_dashboard_overview`.


---

## 5. FUNCTIONAL MODULES

For each module: build every screen listed, wire it to the data model in Section 6, and respect the business rules below exactly — they come from the two source PRDs plus details only visible in the actual screen designs.

### 5.1 Authentication, Onboarding & Verification
- Email/password auth via Firebase Auth. On register (`register_clinical_futurism`), capture name, email, phone, password, and **territory** (dropdown — territories are admin-defined, see 5.16).
- New MR accounts are created with `is_verified: false` and immediately routed to `pending_verification`. They **cannot** log in successfully until an admin approves them via `mr_verification_queue` — on login attempt while unverified, route to `account_under_review_clinical_futurism` instead of the dashboard, with a "Contact your regional admin" message, not a generic error.
- Admin accounts are **never** self-registered — they're created directly in the admin console by a super-admin (build a simple "Add Admin User" action under Settings; no public admin registration flow).
- Onboarding (3 steps) shown once on first install, skippable, stored as a local-only flag (not a server field) so reinstalling resets it.
- Secure token storage via `flutter_secure_storage`. Don't store the Firebase ID token yourself — let the Firebase SDK manage refresh; use secure storage only for the "remember me" / biometric-unlock flag.
- MFA (phone-based) and Firebase App Check are **Phase 3** hardening items — don't block Phase 1 login on them, but design the auth repository interface so they can be added without touching UI code.

### 5.2 MR Home Dashboard (`mr_dashboard_home`)
- Greeting ("Hi, {first name} 👋" + time-of-day-aware subtext), notification bell (badge count from unread `/notifications`).
- "Smart Health Pulse" banner: dynamic copy generated from today's visit count vs. completed count, e.g. *"You have {N} doctor visits planned today. {M} already completed!"* — this is template-generated text from real data, not literally AI-generated each time, in Phase 1; wire it to a real ML-influenced priority score only in Phase 4 (5.9).
- Three quick-stat tiles: Visits Today (`completed/planned`), Attendance (today's status as a check), This Week (rolling visit count).
- Module grid (4 cards): Doctor Visits, Products, Attendance, Leave — each routes per the table in 4.1.
- Recent Activity feed: last ~5 events merged from visits, attendance, and any other loggable action, newest first, with relative/absolute timestamps as shown in the design.
- Center FAB opens `quick_log_action_sheet` (3 actions: Mark Doctor Visit, Mark Attendance, Request Leave).

### 5.3 Doctor Visit Management — the core module
- **Day selector** (`doctor_visits_day_selector`): horizontal date strip (current week), filter chips (All / Pending / Visited), and a doctor list. Each doctor card shows name, specialty, clinic, scheduled time, and either "Mark as Visited" (pending) or a "Visited" checkmark state. Support a "High Priority" badge — Phase 1 this is a simple admin-settable flag on the doctor record; Phase 4 it becomes the AI score from 5.9.
- **Doctor profile** (`doctor_profile_detail`): full doctor record, visit history with this specific doctor, and a "visit streak" counter (consecutive period the MR has visited this doctor).
- **Visit marking flow** (exact sequence, mandatory — do not simplify):
  1. MR taps "Mark as Visited" → confirmation prompt ("Did you visit Dr. {name} today?").
  2. **Mandatory live GPS capture** (`confirm_visit_location`) — capture device location + timestamp. **Validate server-side** (Cloud Function, not just client-side) that the captured point falls within the doctor's clinic geofence (see 5.3.1) before the visit is allowed to save as `verified`. If outside the geofence, allow the MR to add a required justification note and flag the visit `geofence_verified: false` for admin review rather than silently blocking them — field reality means GPS drift happens.
  3. Optional notes field (discussion points, samples provided — link to 5.7 sample logging here).
  4. Confirm → animated checkmark (`visit_success_celebration`) → write to Firestore.
  5. Immediately offer the rating flow (`doctor_rating_feedback`): 1–5 stars + quick tag chips (e.g. "receptive", "busy", "interested in samples") + free-text note. This is MR-internal CRM data visible to admins, not shown to the doctor.
- **Visit history** (`visit_history_log`, filterable by date/doctor/status) and **audit detail** (`visit_detail_audit_view`, showing the exact GPS pin on a small embedded map plus all logged metadata) — both read-only views over the same `visits` collection.
- **5.3.1 Geofencing:** doctor records carry a clinic `GeoPoint` + radius (default configurable, e.g. 150m). Client does a fast pre-check with `geolocator` for instant UX feedback; the **Cloud Function on visit-write does the authoritative check** and is what sets `geofence_verified`. The same pattern applies to attendance (5.5).

### 5.4 Product Catalog
- Grid/list toggle, search, category filter chips (Tablets / Syrups / Injections / Capsules / Devices) — `product_catalog_grid`.
- Each card: image, name, category badge, stock-status pill (In Stock / Low Stock / Out of Stock, derived from `stock_level`).
- `product_detail_screen`: full description, dosage, availability, and an entry point into `interactive_engagement_hub` ("Interactive Visual Aids") — clinical trial data, mechanism-of-action video, efficacy stats, downloadable supporting materials (PDF, dosage calculator), and a **Share with Doctor** action.
- `share_product_modal`: share a generated brochure (PDF) or key-features summary via WhatsApp/email/native share sheet (`share_plus` package) — this directly implements the "Product Information Sharing" idea from the feature plan.
- "Request New" action on the catalog screen → simple in-app request logged for admin (not a full procurement flow in this phase).

### 5.5 Attendance
- `mark_attendance_screen`: single-tap check-in, mandatory GPS capture + geofence validation against the MR's **assigned territory office location** (not a doctor clinic — territories are admin-defined, see 5.16), timestamp written automatically.
- `attendance_history_calendar`: month calendar view, color-coded by status (Present / Absent / Leave), tap a day for detail.
- Attendance streak (consecutive present days) feeds the Home dashboard quick-stat and the gamification module (5.10).

### 5.6 Leave Management
- `leave_request_form`: type (Casual / Sick / Annual / Other), date range picker, reason text, submit.
- `leave_history_status`: list with status pills (Pending / Approved / Rejected), tap for the admin's response if rejected.
- Status changes trigger a push notification to the MR (5.11) and are only writable by an admin action in `leave_approval_screen` (5.18) — never directly by the MR.

### 5.7 Sample & Promotional Material Tracking (`sample_log_screen`)
- Total inventory counter (units currently in the MR's possession — decremented by logged drops, replenished by admin-side restock, which is out of scope for MR app and lives in 5.16/product management).
- "Log New Sample Drop": product dropdown, recipient-doctor dropdown, quantity stepper, optional link to the active/just-completed visit (`visit_id`).
- "Top Distributed" mini chart + "Recent Drops" list (last few, with relative timestamps).
- This is the same flow referenced inside the visit-marking notes step (5.3) — a sample drop can be logged either standalone from this tab or inline during a visit; both write to the same `samples` collection.

### 5.8 Expense Management with OCR (`expense_submission_ocr`, `expense_history`)
- "Scan Receipt" → camera/gallery capture (`image_picker`) → upload to Storage → trigger a Cloud Function that calls **Google Cloud Vision API** (per the Advanced Features doc) to extract amount, vendor, and date.
- Show extracted fields as **editable** form fields ("AI Extracted Details") with an `auto_awesome` indicator — the MR must confirm/correct before submit, never auto-submit OCR output unreviewed.
- Category dropdown (Client Meals & Entertainment / Travel & Transit / Medical Supplies / Other), business-purpose notes field, "Submit for Approval".
- `expense_history`: list with status pills, filterable by status/date range.
- **Cost control:** put the actual Cloud Vision call behind a feature flag that can swap in a mocked response in non-production builds (see implementation-guide Section 7) — don't let dev/test traffic hit a billed API by default.

### 5.9 Smart Route Planner — AI Tour Optimization (`smart_route_planner`)
- Given today's scheduled/pending doctor visits, produce a numbered, sequenced route (stop order, distance between stops, total distance, estimated time, time saved vs. unoptimized order), with a "Start Navigation" action that hands off to the device's native maps app or an embedded `google_maps_flutter` turn-by-turn view.
- **Phase 1–3 implementation:** a real but simple optimization (nearest-neighbor or 2-opt heuristic over the day's doctor GeoPoints using the Directions/Routes API for real travel times) — this is genuinely useful without needing ML.
- **Phase 4:** layer in the "AI Suggested" doctor-priority scoring described in 5.13 to influence stop *inclusion and ordering*, not just geographic distance. Implement this scoring behind a `DoctorPriorityScorer` interface so the heuristic-only Phase 1–3 version and a future ML-backed Phase 4 version are interchangeable without touching UI code.

### 5.10 Gamification — Achievements & Leaderboard
- `achievements_badges_screen`: badge grid (earned vs. locked, with "X more to unlock" progress copy), driven by a small static set of badge definitions (criteria: total visits, attendance streak, product knowledge quiz score from 5.12, etc.) — see Section 6.1 `badge_definitions`.
- `leaderboard_screen`: weekly/monthly toggle, ranked list by visit count (or whatever metric the admin configures — default: total visits this period), highlighting the current MR's own row ("You") and their rank delta.
- **Performance:** compute leaderboard rankings via a **scheduled Cloud Function** (e.g. hourly) writing a denormalized snapshot, not a live aggregation query on every screen open — Firestore can't efficiently rank 800+ MRs live.
- `performance_report_screen`: the MR's own detailed stats (completed vs. target visits, average doctor rating, attendance %) — this is the screen behind the "Insights" tab.

### 5.11 Notifications
- `notifications_screen` (MR inbox): grouped by Today/Earlier, types include inventory alerts, expense approvals, leave decisions, meeting reminders, compliance updates — "Mark all as read".
- Push delivery via Firebase Cloud Messaging; in-app list is the source of truth (Firestore), FCM is purely the delivery/wake-up mechanism.
- Admin-authored notifications come from `notification_sender` (5.20); system-generated ones (leave decision, expense approval, low-stock alert relevant to the MR's territory) are written by Cloud Functions triggered on the relevant document change.

### 5.12 Interactive Engagement Hub (`interactive_engagement_hub`)
- Per-product training/detailing content: clinical trial data summary, efficacy stat callout, mechanism-of-action video, downloadable patient-success-story PDF, an interactive dosage calculator, and "Share with Doctor".
- This doubles as the **product training/certification** surface mentioned in the Advanced Features doc — a per-product quiz can be layered on top of this same screen in Phase 4 without a new route.

### 5.13 AI Voice Search & Predicted Actions (`ai_voice_search_actions_rebuilt`)
- Mic-triggered modal: transcribe a spoken command (use on-device speech-to-text in Phase 1–3; a real intent-understanding model is a Phase 4 item), show the transcript, then surface 1–3 **predicted actions** as tappable rows (e.g. "Open Notes — Dr. Sharma", "Send [Product] PDF — To: Dr. Sharma") derived from simple keyword/entity matching against doctors and products in Phase 1–3.
- This is the same module that should eventually power "Smart Doctor Targeting" (Advanced Features doc 1.1) — keep the scoring/matching logic isolated behind an interface so it can be swapped for a real model later.

### 5.14 Manager Feedback Loop (`manager_feedback_loop`)
- Tied to a specific past visit: shows the MR's own visit summary (objective, samples disbursed, next steps) alongside the manager's **audio or text coaching note** (a short recorded clip + transcript "quick hits" tags like "Great engagement!", "Follow up on pricing") with an "Acknowledge" action.
- Manager records/writes this from the admin console (`mr_detail_tracking`, 5.19) — there is no MR-side authoring of this content, only viewing + acknowledging.

### 5.15 Profile & Settings (`mr_profile_screen`, `edit_profile_screen`)
- Stats header (total visits, avg rating, attendance %), territory display, then a menu list: Edit Profile, My Documents, Performance Report, Achievements & Badges, Language (English/Hindi toggle), Dark Mode toggle, Help & Support, About App (version), Logout.
- Localization: full Hindi + English string sets via `flutter_localizations`/`intl`, toggled here, persisted per-user (Firestore field, not just local prefs, so it follows the MR across devices).

### 5.16 Admin: Territory & Settings
- Not present as a Stitch screen — build a straightforward management screen under "Settings": create/edit territories (name, region, assigned office GeoPoint + radius for attendance geofencing, list of assigned MRs), plus basic admin-user management (invite/create another admin, assign role).

### 5.17 Admin: Dashboard (`admin_dashboard_overview`)
- KPI row: Total MRs, Visits Today, Samples Disbursed, Revenue Trend (if sales data is wired in this org), Pending Verifications (this count must badge the MR Management sidebar item).
- "Visit Trends" gradient line chart (this week, toggleable range), "Top 5 MRs" ranked bars, "Most Visited Doctors" table, "Export Report" (CSV/PDF) and "New Assignment" quick actions.

### 5.18 Admin: MR Management, Verification & Detail
- `mr_management_list`: searchable/sortable/filterable table — name, territory, status (Active in Field / Offline / On Leave), a performance % indicator, last-active time, row actions (view, block/unblock).
- `mr_verification_queue`: pending registrations with their submitted details; Approve sets `is_verified: true` and fires a notification to the MR; Reject requires a reason, also notified.
- `mr_detail_tracking`: full profile (contact info, Block Account action), tabs for Overview / Performance / Visits / Map (a territory heat/coverage visualization and recent-visits list), plus the entry point for recording a Manager Feedback Loop note (5.14) against a specific past visit.

### 5.19 Admin: Doctor Management (`doctor_management`)
- Full CRUD over the `doctors` collection: photo, specialty, clinic name/address (+ geocode to a `GeoPoint` for the geofence used in 5.3.1), phone, bio, available days/hours, active toggle, and a read-only "Total Visits" rollup.

### 5.20 Admin: Product Management (`product_management`)
- Full CRUD over `products`: name, category, description, dosage, image, price, stock level with a **Low Stock alert banner** when any product crosses its reorder threshold (visible directly on this screen, as designed).

### 5.21 Admin: Leave Approvals (`leave_approval_screen`)
- Tabbed Pending / Approved / Rejected table over `leave_requests`; approve/reject with an optional note, which updates the MR-side `leave_history_status` and fires a notification.

### 5.22 Admin: Reports & Analytics (`reports_analytics`)
- Date-range selector, "Visits by Territory" geospatial view, "Engagement Rate" and other aggregate metrics, exportable (CSV/PDF) — this is the admin-facing counterpart to the Advanced Features doc's "Customizable Dashboards & Reports" and, in Phase 4, the "AI-Driven Performance Insights" natural-language summary.

### 5.23 Admin: Live Location Tracking (`live_location_tracking_map`)
- Real-time map (Firestore listener, not polling) of currently-active MRs during working hours, with status markers; tapping a marker surfaces a mini-card linking to `mr_detail_tracking`. This is the screen with the highest privacy sensitivity in the app — see Section 8's data-minimization requirement (only show live position during the MR's own declared working hours, never store a continuous location trail beyond what attendance/visit/audit records already require).

### 5.24 Admin: Notification Sender (`notification_sender`)
- Compose title/body/optional image, target audience (All MRs / specific MR / territory group), send now or schedule, writes to `notifications` and triggers FCM fan-out via a Cloud Function.


---

## 6. DATA ARCHITECTURE

### 6.1 Firestore collections

Use `snake_case` field names throughout (the two source PRDs mix `snake_case` and `camelCase` inconsistently — standardize on `snake_case`).

| Collection | Key fields |
|---|---|
| `users/{uid}` | `name, email, phone, role(mr\|admin), is_verified, is_blocked, territory_id, profile_photo_url, language(en\|hi), dark_mode(bool), last_active, attendance_streak, total_visits, avg_rating, fcm_tokens(array), created_at, updated_at` |
| `doctors/{id}` | `name, specialty, qualification, clinic_name, clinic_address, clinic_location(GeoPoint), geofence_radius_m, phone, bio, photo_url, available_days(array), timing_start, timing_end, is_active, is_high_priority, total_visits, created_at, updated_at` |
| `products/{id}` | `name, category, description, dosage, image_url, brochure_url, is_available, stock_level, reorder_threshold, price, expiry_date, created_at, updated_at` |
| `visits/{id}` | `mr_id, doctor_id, doctor_name, visit_date, visit_time, day_of_week, notes, rating(1-5), feedback_tags(array), latitude, longitude, location_timestamp, geofence_verified(bool), out_of_geofence_reason, status(planned\|visited\|missed), created_at` |
| `attendance/{id}` | `mr_id, attendance_date, attendance_time, latitude, longitude, location_timestamp, geofence_verified, status(present\|absent\|leave), created_at` |
| `leave_requests/{id}` | `mr_id, leave_type, start_date, end_date, reason, status(pending\|approved\|rejected), requested_at, approved_by, approved_at, admin_note` |
| `samples/{id}` | `mr_id, product_id, product_name, doctor_id, doctor_name, quantity, visit_id(nullable), logged_at` |
| `expenses/{id}` | `mr_id, category, vendor, amount, currency, expense_date, receipt_image_url, ocr_raw_text, notes, status(pending\|approved\|rejected), approved_by, approved_at, created_at` |
| `notifications/{id}` | `title, body, image_url, type, sent_to(all\|mr_id\|territory_id), sent_by_admin, sent_at, scheduled_at` |
| `territories/{id}` | `name, region, office_location(GeoPoint), geofence_radius_m, assigned_mr_ids(array), created_at` |
| `training_content/{id}` | `product_id, title, type(video\|pdf\|interactive_tool), url, duration_seconds, specialty_tags(array), created_at` |
| `manager_feedback/{id}` | `visit_id, mr_id, manager_id, audio_url, text_quote, tags(array), acknowledged(bool), created_at` |
| `badge_definitions/{id}` | `name, icon, criteria_type(total_visits\|streak\|rating\|...), criteria_value` (static, admin-seeded) |
| `users/{uid}/badges/{badgeId}` | `earned_at` (subcollection — earned badges only) |
| `leaderboard_snapshots/{period}` | `period(weekly\|monthly), generated_at, rankings(array of {mr_id, name, territory, score})` — written by a scheduled Cloud Function, read-only to clients |

### 6.2 Security rules — principles (write the actual `firestore.rules`, this is the spec, not the syntax)
- Default deny. Every collection requires `request.auth != null`.
- An MR may create/read/update **only their own** documents in `visits`, `attendance`, `leave_requests`, `samples`, `expenses` (match `resource.data.mr_id == request.auth.uid` on read/update; on create, `request.resource.data.mr_id == request.auth.uid`). MRs can never set `status`/`approved_by`/`geofence_verified` fields directly — those are Cloud-Function-only writes (enforce via rules that reject client writes to those specific fields, or route all status changes through callable Functions instead of direct client writes).
- `doctors`, `products`, `training_content`, `badge_definitions`, `territories` are **read-only to MRs, full CRUD to admins** (check `get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'`).
- `users/{uid}`: a user may read/update their own non-privileged fields (`language`, `dark_mode`, `profile_photo_url`); only an admin may write `is_verified`, `is_blocked`, `role`.
- `leaderboard_snapshots`, and the `is_verified`/`is_blocked`/approval fields everywhere, are **never client-writable** — Cloud Functions use the Admin SDK, which bypasses rules, for all of these.
- Geofence validation itself must happen **server-side** in the Cloud Function that processes a visit/attendance write — client-set `geofence_verified: true` should be explicitly ignored/overwritten by the Function, never trusted.

### 6.3 Offline-first strategy
- `mr_mobile` must be fully usable offline for: marking a visit (location captured locally, queued), marking attendance, requesting leave, browsing the (locally cached) doctor/product catalog, viewing previously-synced history.
- Use **Hive** as the local cache + outbox: mirror `doctors` and `products` for the MR's territory on each successful sync; queue writes to `visits`/`attendance`/`leave_requests`/`samples`/`expenses` in a local outbox table when offline, with a background sync worker that flushes the outbox on connectivity restore (Firestore's own offline persistence handles simple cases, but the **mandatory geofence Cloud Function validation** means you need an explicit "pending sync" status visible to the MR until the server confirms, not silent optimistic-only writes).
- Image uploads (receipts, photos) queue the same way — store locally, upload on reconnect, show a clear "syncing" indicator on the relevant history rows.

### 6.4 Storage buckets
`storage/profile_photos/{uid}`, `storage/receipts/{uid}/{expenseId}`, `storage/doctor_photos/{doctorId}`, `storage/product_images/{productId}`, `storage/product_brochures/{productId}`, `storage/manager_feedback_audio/{visitId}` — mirror the same admin/owner-only write rules as 6.2.

---

## 7. TECHNICAL STACK & PROJECT STRUCTURE

### 7.1 Monorepo layout
```
medivisit_pro/
├── packages/core/
│   ├── lib/
│   │   ├── models/            # Doctor, Product, Visit, Attendance, LeaveRequest, Sample, Expense, MrUser, ...
│   │   ├── repositories/      # abstract interfaces (VisitRepository, DoctorRepository, ...)
│   │   ├── repositories/firebase/   # concrete Firestore implementations
│   │   ├── services/          # AuthService, GeofenceService, OfflineSyncService, NotificationService
│   │   ├── theme/             # ClinicalFuturismTheme, ClinicalFuturismWebTheme (Section 3 as code)
│   │   └── utils/
│   └── pubspec.yaml
├── apps/mr_mobile/   (standard Flutter app structure, feature-first under lib/features/<module>/)
└── apps/admin_web/   (same pattern, lib/features/<module>/)
```
Both apps depend on `packages/core` via a local `path:` dependency — no melos/workspace tooling needed for a project this size; keep it simple.

### 7.2 State management & routing
**GetX** for state management and dependency injection (per the source PRD's stated preference) — `GetxController` per feature, `Get.find()`/`Get.put()` for DI, GetX's own named routing (`GetPage`, `Get.toNamed`) for navigation rather than mixing in a second routing framework.

### 7.3 Key packages
`firebase_core, firebase_auth, cloud_firestore, firebase_storage, cloud_functions, firebase_messaging, firebase_crashlytics, firebase_performance` · `get` · `hive, hive_flutter` (offline cache/outbox) · `flutter_secure_storage` · `geolocator, google_maps_flutter` · `image_picker, cached_network_image` · `fl_chart` (mobile **and** web charts) · `share_plus` · `intl, flutter_localizations` (en/hi) · `connectivity_plus` (offline detection) · `lottie` (visit-success celebration only) · `pdf, printing` (admin export) · on-device speech-to-text package for the voice search transcript (Phase 1–3 placeholder ahead of a real NLU backend in Phase 4).

### 7.4 Repository-interface discipline (so a future Firebase → Postgres migration doesn't require a rewrite)
Every feature talks to an **abstract repository interface** in `packages/core/lib/repositories/`, never to `cloud_firestore` directly from UI/controller code. The Firestore implementation lives in `repositories/firebase/` and is the only place `FirebaseFirestore` is imported outside `core`'s internals. This is a hard rule, not a suggestion — it's what makes the documented Phase-2+ backend migration realistic later.

### 7.5 Theming implementation
Implement Sections 3.3 and 3.4 as two `ThemeExtension<T>` classes (`MediVisitMobileTheme`, `MediVisitAdminTheme`) consumed via `Theme.of(context).extension<...>()`, not as scattered hardcoded hex values in widgets. Glass-card and gradient-button treatments should be shared, reusable widgets (`GlassCard`, `GradientButton`, `PillBottomNav`, etc.) built once in `packages/core` or an app-level `widgets/` folder, not re-implemented per screen.

---

## 8. NON-NEGOTIABLE ENGINEERING CONSTRAINTS

1. **Security:** Firebase Auth handles password hashing; never store raw passwords or your own JWTs. All sensitive config (API keys for Maps, Cloud Vision) lives in environment-specific config, never hardcoded or committed.
2. **RBAC:** every admin-console route checks `role == 'admin'` server-side (security rules + Functions), not just by hiding UI on the client.
3. **Geofencing is authoritative server-side**, per Sections 5.3.1 and 6.2 — never trust a client-asserted "I was at the location" flag.
4. **Offline-first** per Section 6.3 — this is core to the product (field reps in low-connectivity areas), not a nice-to-have bolted on later.
5. **Data minimization for live tracking** (5.23): only surface real-time position during declared working hours; don't retain a raw continuous GPS trail beyond what the visit/attendance audit records already capture.
6. **Performance:** shimmer loaders on every list, pagination on long lists (MR list, doctor list, visit history), `cached_network_image` everywhere an image loads from Storage, lazy route loading.
7. **Error handling:** every network call has a user-friendly failure state (not a raw exception string), offline detection banners app-wide, Crashlytics wired from Phase 0.
8. **Localization:** every user-facing string in `mr_mobile` goes through `intl`/ARB files in English and Hindi from the start — retrofitting localization later is expensive; don't defer it past Phase 3 as "polish."
9. **Testing:** unit tests for repository implementations and the geofence/route-scoring logic specifically (these are the modules with real business-rule risk); widget tests are good-to-have but not blocking for Phase 1.

---

## 9. PHASED DELIVERY PLAN

Build and get explicit approval on each phase before starting the next — see the implementation guide (`docs/01_Antigravity_Implementation_Guide.md`) for how to structure this as separate Agent tasks.

### Phase 0 — Scaffold (do this first, in this same task)
Monorepo structure (7.1), `packages/core` with empty-but-typed models/repository interfaces for every Section 6.1 collection, both `ThemeExtension`s implemented from Section 3 (build a small internal "theme gallery" screen in each app to sanity-check every token before screen-building starts), `flutterfire configure` run for both apps, Firebase project wired (Auth/Firestore/Storage/Functions/Messaging clients initialized), Firestore security rules skeleton (6.2 principles, even if some collections are still empty), CI-friendly lint setup (`flutter analyze` clean).
**Exit criteria:** both apps boot to an empty themed shell; theme gallery screen visually matches the tokens in Section 3 when screenshotted.

### Phase 1 — MVP
Auth + verification flow (5.1, all 6 screens), MR dashboard (5.2), full doctor visit module including mandatory geofenced location capture (5.3, all 9 screens), product catalog **view-only** (5.4 minus admin CRUD), MR profile (5.15, view + edit), and on the admin side: admin login, dashboard overview, doctor CRUD (5.19), product CRUD (5.20), and MR verification queue + list (5.18, list + verification only — full detail/tracking view can wait for Phase 2).
**Exit criteria:** an MR can register, get verified by an admin, log in, see their dashboard, browse doctors, complete a full GPS-verified visit end to end, rate it, and an admin can manage doctors/products and approve new MRs — fully wired to real Firestore, no mock data left in the UI layer.

### Phase 2 — Expansion
Attendance (5.5), leave management both sides (5.6, 5.21), sample tracking (5.7), full admin MR management/detail/tracking (5.18 in full), notifications both sides (5.11, 5.24), gamification (5.10), push notifications wired end-to-end via Functions.
**Exit criteria:** every "Phase 2" item from the original Feature Plan doc's own roadmap is live and the admin console's sidebar (4.2) is fully navigable with no placeholder screens left.

### Phase 3 — Location, Offline & Polish
Live location tracking (5.23), full offline-first sync per Section 6.3 (retrofit Phase 1–2 modules with the outbox pattern if not already built that way), dark mode complete (mobile), Hindi localization complete, MFA + App Check hardening (5.1), expense management with real Cloud Vision OCR (5.8), reports & analytics (5.22), territory/settings admin (5.16), and a full visual-polish pass: every screen re-checked against Section 3's glass/elevation/motion rules (this is also when the celebratory animation on `visit_success_celebration` should get real craft, not a placeholder).
**Exit criteria:** app works correctly with airplane mode toggled mid-flow on every write-capable screen; every screen passes the Section 10 verification protocol with zero open visual deltas.

### Phase 4 — AI Layer
Smart route planner upgraded from heuristic to priority-scored (5.9), doctor priority/"High Priority" badge driven by a real scoring model (5.13), AI voice search with real intent matching (5.13), interactive engagement hub content recommendation logic, manager feedback loop (5.14), AI-driven natural-language performance summaries on the admin reports screen (5.22). Implement all of this behind the interfaces already established in 5.9/5.13 in earlier phases — this phase should mostly be "swap the implementation," not "redesign the UI."
**Exit criteria:** every AI-flagged UI element (violet `#7C5CFF` accent per 3.2) is backed by a real, even if simple, scoring/ranking implementation — not hardcoded or random placeholder data.


---

## 10. VERIFICATION PROTOCOL (mandatory, per screen)

For every screen you build:
1. Implement the widget tree.
2. Run `flutter analyze` — zero new warnings/errors before moving on.
3. Run the app (web-renderer preview for fast iteration; a real Android/iOS simulator pass at least once per module) and use the Browser Subagent to navigate to the screen and capture a screenshot.
4. Place that screenshot beside `design_reference/<canonical_folder>/screen.png` and explicitly list every visible difference (spacing, color, missing glass/blur effect, wrong icon, wrong type scale) — don't just say "looks close."
5. Fix the deltas, re-screenshot, repeat until there are no meaningful differences (minor anti-aliasing/font-rendering differences between a browser screenshot and Flutter's renderer are expected and fine — layout, color, spacing, and component-structure differences are not).
6. Include the before/after screenshots in the phase's Artifact walkthrough so I can review without re-running anything myself.

Do this for real interaction states too where the design shows them (e.g. an input's focus-glow state, a button's pressed state) — not just the static resting screenshot.

---

## 11. COLLABORATION PROTOCOL

- Before starting Phase 0 (and each subsequent phase), produce a short plan Artifact and **wait for my explicit approval** before writing code or running `flutter create`/`pub get`/Firebase setup commands.
- If `design_reference/`, this brief, or the two PRDs in `docs/` genuinely conflict on something not already resolved above, **stop and ask me** rather than picking one silently — flag it clearly, state the options, and let me decide.
- Don't invent screens, modules, or fields that aren't specified somewhere in this brief or in `design_reference/`.
- Use the realistic example data already visible in the design screenshots as your seed/mock data during development (e.g. "Dr. Sarah Jenkins — Cardiology", "CardioVax Plus", "LipoStat — Atorvastatin Calcium") rather than generic "Lorem ipsum"/"Test Doctor 1" placeholders — it makes visual verification against the reference screenshots far more meaningful.
- When you hit a genuinely ambiguous business rule with real consequences (e.g. "what exact geofence radius in meters") and no value is specified anywhere, propose a sensible default explicitly and flag it as a default I should confirm — don't silently bury the assumption in code.

---

## 12. FIRST TASK — START HERE

Begin with **Phase 0** exactly as defined in Section 9. Specifically:
1. Read every file in `design_reference/` referenced in Section 2, plus both PRDs in `docs/`, in full.
2. Produce a plan Artifact covering: the monorepo scaffold you're about to create, the full list of model classes and repository interfaces you'll stub in `packages/core`, and how you'll implement the two `ThemeExtension`s from Section 3 — including the theme-gallery verification screen for each app.
3. Pause for my approval.
4. Once approved, scaffold everything, run `flutterfire configure` for both apps (ask me for the Firebase project ID/credentials if you don't already have CLI access configured), and produce the Phase 0 Artifact with the theme-gallery screenshots compared against the design tokens in Section 3.
5. Stop there and wait for me to say "Phase 0 approved, start Phase 1" before touching any of the screens in Section 5.
