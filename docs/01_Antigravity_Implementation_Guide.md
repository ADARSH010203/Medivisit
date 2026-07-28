# MediVisit Pro — Implementation Guide for Google Antigravity

This guide tells you exactly how to turn your Stitch design export + your two planning documents into a real, running Flutter app using **Google Antigravity**. Read this once, then use `02_MASTER_BUILD_PROMPT.md` as the actual prompt you paste into the agent.

---

## 0. Audit — What's actually inside your zip

I opened `stitch_medivisit_pro_design_system.zip` and read every file. Here's the honest inventory:

| Category | Count | Notes |
|---|---|---|
| Mobile MR app screens (Stitch HTML+PNG) | ~50 | Portrait, ~706×1600px |
| Admin web console screens (Stitch HTML+PNG) | 11 | Widescreen, 1600×1280px |
| Design system docs (`DESIGN.md`) | 4 | Two *competing* mobile directions + 1 final mobile + 1 admin |
| Product docs (`admin_console_prd.txt`, `feature_expansion_strategy.md`) | 2 | Short PRD notes |
| Logo / 3D illustration assets | ~8 | Brand mark + hero illustrations |
| Duplicate/draft screens (same screen, multiple versions) | ~12 | e.g. 3 login variants, 4 splash variants, 3 onboarding-step-1 variants, 3 voice-search variants |

**App name:** MediVisit Pro. **Client/brand:** UMAKIND Pharma (confirmed from the actual logo file and login screen — the circular pill+leaf mark in blue→teal).

### ⚠️ The one thing you must decide before building: which design system is "final"

Your zip contains **three different visual directions** for the mobile app, generated at different times:

1. **"Clinical Precision"** (`clinical_precision_1/DESIGN.md`, `clinical_precision_2/DESIGN.md`) — flat blue (`#0053D3`) + teal (`#68FADD`) Material 3 style. **This is what ~45 of your 50 mobile screens actually use** (dashboard, doctor visits, attendance, leave, samples, expenses, products, profile, gamification, notifications, etc.) — even though their `DESIGN.md` files were never renamed.
2. **"Clinical Futurism"** (`clinical_futurism/DESIGN.md`) — glassmorphism, frosted-glass cards, mesh gradients, violet-to-teal gradient buttons. **Only 6 screens use this**: both login variants, both splash variants, register, and account-under-review.
3. **"Clinical Futurism Web"** (`clinical_futurism_admin/DESIGN.md`) — the dark, glowing, cyan/violet admin console theme. **All 11 admin screens consistently use this one** — no conflict here.

**My read on this:** Clinical Futurism is the more recent, more deliberate, more detailed design system (173 lines of carefully written component specs vs. a generic auto-generated token dump for Clinical Precision), and it has a matching, equally polished admin counterpart. It looks like your team redesigned the auth flow into the new direction first and hadn't propagated it to the rest of the app yet when the export was taken.

**Decision baked into the Master Prompt:** Treat **Clinical Futurism** (mobile) + **Clinical Futurism Web** (admin) as the single source of truth for the *entire* product, and have the agent re-skin every Clinical-Precision-era screen to match — while keeping each screen's actual layout, content, and information architecture exactly as designed (only the surface treatment changes: flat cards → glass cards, flat blue → gradient, sharp shadows → soft glow). If you actually preferred the flat blue/teal "Clinical Precision" look, tell the agent that on day one — it's a one-line change to the Master Prompt (Section 3).

I also found and resolved two smaller issues, documented in full in Section 6 of this guide:
- Several screens have generic leftover nav labels ("Patients", "Clinical Data", "Schedules") from whatever template Stitch started from — these get relabeled to MR-app-correct terms.
- The brand gradient is **not** the flat violet (`#4F378A`) sitting in the `DESIGN.md` color table — it's the literal gradient `linear-gradient(135deg, #4F378A 0%, #008080 100%)` pulled straight from your login screen's actual CSS, which matches your logo's blue→teal arc. The Master Prompt locks in the exact, correct value.

---

## 1. What Google Antigravity actually is (quick primer)

Antigravity is Google's agent-first development platform (built on a VS Code fork, powered by Gemini 3, also lets you switch to Claude Sonnet/Opus). The difference from Copilot/Cursor-style tools: you don't write code with it line by line — you hand it a brief, it plans, writes, runs, and **visually verifies its own work using a real embedded Chrome browser**, then reports back with screenshots and a walkthrough ("Artifact") for you to approve or correct.

Relevant for you specifically:
- **Dart & Flutter MCP server** — gives the agent real understanding of your Flutter project (widget tree, packages, errors), not just raw text files.
- **Browser Subagent** — this is the feature you'll lean on most: it can open your running app and compare what's rendered against a reference image. We use this to pixel-check every screen against your Stitch `screen.png` files.
- **Review-driven vs. Agent-driven mode** — on first launch Antigravity asks how much autonomy to give it. **Choose Review-driven development.** With 62 screens and real Firebase infrastructure on the line, you want to approve each command/phase rather than let it run fully unattended.
- **Artifacts** — every meaningful chunk of agent work produces a plan, a diff, and screenshots you can comment on directly. Use these comments instead of re-typing instructions from scratch.

---

## 2. One-time setup

### 2.1 Install Antigravity
Download from `antigravity.google/download` for your OS. On first run, select **Review-driven development**.

### 2.2 Install the Dart and Flutter extensions
Inside Antigravity: **Extensions** (left nav) → search "Dart" → Install → search "Flutter" → Install.

### 2.3 Install the Dart/Flutter MCP server
1. Open the Agent panel (`Cmd/Ctrl + L`).
2. Click the **`...`** menu (top-right of panel) → **MCP Servers** → **Manage MCP Servers**.
3. Search "Dart" in the MCP Store → **Install**.
4. Fully quit and reopen Antigravity so the server attaches. (Requires Dart 3.9+, which any current Flutter SDK ships with.)

### 2.4 Build the local project skeleton
Create this folder structure **before** opening Antigravity, so the agent has somewhere real to work and your design files are already sitting in the repo:

```
medivisit_pro/
├── design_reference/          ← unzip stitch_medivisit_pro_design_system.zip here, unchanged
├── docs/
│   ├── 01_Antigravity_Implementation_Guide.md   ← this file
│   ├── 02_MASTER_BUILD_PROMPT.md                ← paste-ready agent brief
│   ├── Medical_Representative_MR_App_Feature_Plan.md
│   └── Advanced_Features_and_Implementation_Strategies.md
├── packages/
│   └── core/                  ← shared Dart package: models, Firebase services, theme
└── apps/
    ├── mr_mobile/              ← Flutter app (Android/iOS) — the MR-facing app
    └── admin_web/              ← Flutter Web app — the admin console
```

Commands:
```bash
mkdir -p medivisit_pro/design_reference medivisit_pro/docs medivisit_pro/packages medivisit_pro/apps
cd medivisit_pro
unzip /path/to/stitch_medivisit_pro_design_system.zip -d design_reference
# copy this guide, the master prompt, and your two original .md files into docs/
```

Don't let the agent `flutter create` *inside* `design_reference/` — that folder is reference-only and should never ship in either app's bundle.

### 2.5 Set up Firebase (do this yourself, once, before the agent starts)
1. Create a Firebase project at console.firebase.google.com (e.g. `medivisit-pro-prod`, plus a second `medivisit-pro-dev` project if you want separate environments — recommended).
2. Enable: **Authentication** (Email/Password provider), **Cloud Firestore**, **Storage**, **Cloud Functions** (requires Blaze/pay-as-you-go plan), **Cloud Messaging**.
3. Upgrade to the **Blaze plan** — required for Cloud Functions and for calling Cloud Vision API (receipt OCR) and Maps/Routes API (route planner) from Functions. Set a budget alert immediately.
4. Get a **Google Maps Platform** API key (Maps SDK + Directions/Routes API) for the route planner and live-tracking map screens.
5. Don't run `flutterfire configure` yourself — instruct the agent to do it as part of Phase 0 once both Flutter apps exist, so the generated config files land in the right place automatically.

### 2.6 Open the project
In Antigravity: **File → Open Folder** → select `medivisit_pro/`. Open the Agent panel and you're ready for Section 3.

---

## 3. How to actually use the Master Prompt

`02_MASTER_BUILD_PROMPT.md` is written to be **pasted whole, as your first message**, into a new Agent task. It is long on purpose — it is the entire brief: design tokens, every screen mapped to a route, the full Firestore schema, business rules, and a phased plan. Don't summarize it before pasting; the agent reads markdown natively and uses the structure to navigate it.

Two ways to use it — do **both**:

1. **As a living reference file:** keep it at `docs/02_MASTER_BUILD_PROMPT.md` in the repo. Tell the agent in your first message: *"Read docs/02_MASTER_BUILD_PROMPT.md in full before doing anything else — this is your spec for the entire project."*
2. **As your literal first prompt:** also paste the file's contents directly into the Agent panel. This guarantees it's the first thing in the agent's context window, not just a file it might skim.

### Don't run all four phases in one task
Start a **new Agent task per phase** (Section 9 of the Master Prompt defines them). Asking for all 62 screens in one shot is how you get an agent that silently cuts corners on screen #40 because its context is full of screen #1–39. After Phase 1 is built, verified, and you're happy with it, open a fresh task and say:

> "Phase 1 is approved and merged. Continue with Phase 2 exactly as defined in docs/02_MASTER_BUILD_PROMPT.md Section 9. Re-read Sections 3–8 first for the design and data rules."

Repeat for Phase 3 and Phase 4.

### Reviewing Artifacts
After each significant step the agent will produce a plan or a walkthrough with screenshots. Don't just click Approve — actually compare the screenshot to `design_reference/<screen_folder>/screen.png` yourself once per screen, at least for Phase 1. Leave inline comments on the Artifact for anything off (spacing, color, missing icon) instead of writing a fresh prompt — Antigravity folds comments back into the same task's context.

---

## 4. Recommended build sequence with kickoff prompts

These are short prompts to fire **after** the previous phase is verified — they reference the Master Prompt so you don't have to retype specs.

**Phase 0 → Phase 1 (already your first message — see Master Prompt Section 12)**

**Phase 1 → Phase 2:**
> Phase 1 is verified and approved. Start Phase 2 per docs/02_MASTER_BUILD_PROMPT.md Section 9. Re-confirm the design tokens in Section 3 before writing any UI code, and re-use the existing `packages/core` theme — don't redefine it.

**Phase 2 → Phase 3:**
> Phase 2 is verified and approved. Start Phase 3 per Section 9 — this is the location/tracking/polish phase. Pay special attention to Section 8's offline-first and geofencing requirements; these are the hardest part of this phase.

**Phase 3 → Phase 4:**
> Phase 3 is verified and approved. Start Phase 4 (AI features) per Section 9. Where Section 5 describes "AI-driven" behavior, implement it as clearly-isolated, rule-based logic behind an interface (e.g. `RouteOptimizer`, `DoctorPriorityScorer`) so a real ML model can be swapped in later without touching UI code.

---

## 5. Verification workflow (how to make Antigravity actually match your design)

Antigravity's Browser Subagent can run your app (web target, or Flutter's web-renderer-in-browser preview for mobile layouts) and take real screenshots. Section 10 of the Master Prompt already instructs the agent to do this per screen, but if it ever skips it, prompt explicitly:

> Run the app, navigate to the [screen name] screen, take a screenshot with the Browser Subagent, and place it side-by-side with `design_reference/[folder_name]/screen.png`. List every visible difference in spacing, color, type, or iconography, then fix them and re-screenshot.

For native-only details Flutter web can't preview well (e.g. true iOS blur), use a simulator/emulator screenshot via `flutter run` instead and ask the agent to attach that to the Artifact.

---

## 6. Known issues in your source design & how the Master Prompt resolves them

| Issue found | Where | Resolution |
|---|---|---|
| Two competing design languages for the mobile app | Most screens vs. login/splash/register/account-review | Clinical Futurism wins everywhere (see Section 0 above) |
| Bottom nav labels/order differ screen to screen (`Home/Insights/Patients/Profile` vs `Dashboard/Visits/Inventory/Analytics/Settings` vs others) | `mr_dashboard_home`, `product_catalog_grid`, `leaderboard_screen`, etc. | Master Prompt Section 4.1 defines **one** canonical 5-tab nav: Home · Visits · Catalog · Insights · Profile |
| Admin sidebar says "Patients" and "Clinical Data" | All 11 admin screens | Relabeled to "Doctors" and "Reports & Analytics" — this is an MR/physician-engagement app, not a patient-facing clinical system; "Patients" was leftover template text |
| Title tags say "PulseConnect" or "UMAKIND Pharma" instead of "MediVisit Pro" | `login_updated_logo`, `register`, `onboarding_step_1_1`, `notifications_screen`, `achievements_badges_screen`, `leaderboard_screen` | These are earlier drafts — ignored in favor of their `_clinical_futurism` / canonical counterparts. Full list in Master Prompt Section 2.2 |
| Brand gradient ambiguous (prose says "blue to teal", token table says flat violet) | `clinical_futurism/DESIGN.md` | Resolved to the exact CSS found in the live login screen: `linear-gradient(135deg, #4F378A 0%, #008080 100%)` |
| 12 duplicate/draft screen folders | splash ×4, login ×3, onboarding-step-1 ×3, voice-search ×3, etc. | Master Prompt Section 2.2 tells the agent exactly which single folder is canonical per screen and to ignore the rest |

---

## 7. Troubleshooting & tips specific to this build

- **Geofencing won't test correctly on an emulator's default mock location.** Use Android Studio's Extended Controls → Location, or iOS Simulator's Features → Location → Custom Location, to simulate being inside/outside a clinic geofence. Tell the agent to add a debug-only "simulate location" override so you don't need real GPS hardware during development.
- **Cloud Vision OCR (expense receipts) costs money per call** even in dev. Ask the agent to add a feature flag that swaps in a fake/mock OCR response during local development.
- **Maps/Directions API also bills per request.** Cache route results client-side for the session and don't re-call on every rebuild.
- **MFA in Firebase Auth requires a verified phone provider and, for production, App Check.** This is a Phase 3 item per the Advanced Features doc — don't let the agent block Phase 1 login on it.
- **If you run two agent tasks in parallel** (Antigravity supports up to 5), don't point two agents at the same files at once — split by app (`mr_mobile` vs `admin_web`) or by module, never by screen within the same module.
- **Flutter Web ≠ pixel-perfect for `admin_web`.** It's the right choice here because it shares Dart models/services with the mobile app and matches your stated Flutter-only stack — but if your team later wants a fully bespoke marketing-grade web feel, a React/Next.js admin frontend consuming the same Firebase backend is the alternative; that's a bigger call than this guide should make for you.

---

## 8. After the MVP ships

- Both planning docs note a **Phase 2+ migration from Firebase to Node.js + PostgreSQL** for scale and custom logic. Don't start this until you have real usage data justifying it — Firestore comfortably handles a mid-size field-force (hundreds of MRs). Treat the data layer as an interface (`VisitRepository`, `DoctorRepository`, etc.) from day one specifically so this swap is possible later without a rewrite — this is already mandated in Master Prompt Section 7.
- Budget time for **Play Store / App Store submission** prep separately — privacy policy, data-safety forms (location + health-adjacent data triggers extra review), and signing configs aren't covered by the Master Prompt.
- The **ERP/CRM and LMS integrations** described in the Advanced Features doc (Section 4) are intentionally out of scope for the Master Prompt — they depend on systems specific to your company that no design file can specify. Treat them as a Phase 5 you write yourself once you know which systems you're integrating with.
