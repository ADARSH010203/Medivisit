# MediVisit Pro - Project Overview & Implementation Status
*Date: July 2026*

This document provides a comprehensive overview of everything implemented in the **MediVisit Pro** application suite up to the current state. Use this guide to understand the app's architecture, locate specific features, and trace potential bugs or errors.

---

## 🏗️ Architecture & Stack
- **Framework:** Flutter (Mobile + Web)
- **State Management:** GetX
- **Design Pattern:** Clean Architecture (separated into `apps/` and `packages/`)
- **Backend Services:** Firebase (Firestore database), Supabase (Edge Functions for notifications)
- **Maps:** `flutter_map` (OpenStreetMap) with Marker Clustering
- **Design System:** "Clinical Futurism" (Dark mode, Glassmorphism `GlassCard`, Mesh Gradients, Phosphor Icons)

---

## 📦 1. Core Package (`packages/core`)
*Location: `packages/core/lib/`*
This package contains all shared business logic, data models, and UI components used by both the Mobile and Admin apps.

### Data Models (`models/`)
- `Doctor` *(recently updated with `engagementRating`, `totalVisitsByMrs`, `sampleAcceptanceRate`)*
- `Visit`, `FilterModel`, `MrUser`, `Product`, `Attendance`, `LeaveRequest`, `Sample`, `Expense`, `NotificationModel`, `Territory`, `BadgeDefinition`, `LeaderboardEntry`.

### Repositories (`repositories/`)
- Abstract interfaces and `firebase/` concrete implementations for all data models.
- **Key Files:** `firebase_doctor_repository.dart`, `firebase_visit_repository.dart`, `firebase_auth_repository.dart`, etc.

### Services (`services/`)
- `AuthService`, `LocationService`, `GeofenceService`, `RouteOptimizer`, `OfflineSyncService`.
- `SupabaseFunctionService` *(handles push notifications and edge function triggers).*
- `CloudinaryService`, `OcrService`, `SeedDataService`.

### Shared UI & Theme (`theme/` & `widgets/`)
- **Theme:** `AppColors`, `AppTypography`, `MobileTheme`, `AdminTheme`.
- **Widgets:** `GlassCard` (glassmorphism), `MeshGradientBackground`, `GradientButton`, `SecondaryButton`, `PillBottomNav`, `KpiTile`, `AdminSidebar`.

---

## 📱 2. MR Mobile App (`apps/mr_mobile`)
*Location: `apps/mr_mobile/lib/features/`*
The main application used by Medical Representatives (MRs) in the field.

### Auth Module (`auth/`)
- Splash, Login, Register, Onboarding, and Pending Verification screens.

### Dashboard Module (`dashboard/`)
- **`DashboardScreen`:** Main landing page with a 2x2 Module Grid (Doctor Visits, Products, Attendance, Leave), Stats Tiles, and Recent Activity Feed.
- **`QuickLogActionSheet`:** Bottom sheet for rapid action logging.

### Doctor Discovery & Map (`discovery/`) - *[Recently Added]*
- **`DiscoveryMapScreen`:** Interactive map with `flutter_map_marker_cluster` to group nearby doctors. Includes inverted dark-mode map tiles for the Clinical Futurism aesthetic.
- **`FilterBottomSheet`:** Complex filtering by Specialty, Engagement Rating (3+, 4+), Distance (1-25km slider), Availability, and High Priority toggles.
- **`DoctorFilterController`:** Manages the map state and heavily filters the `DoctorRepository` locally.

### Visits & Logging Module (`visits/`)
- **`VisitsScreen`:** Day-by-day planner and history of visits. Features the "Discover Nearby Doctors" banner.
- **`DoctorQuickLogScreen`:** GPS-enforced visit logging. Validates that the MR is within **50 meters** of the clinic before allowing submission.
- **`DoctorQuickLogController`:** Handles creating self-reported visits and triggering Supabase Admin notifications. *(Includes safe `try/catch` error handling to prevent UI freezes if Supabase fails).*
- **`SmartRoutePlannerScreen`:** Optimizes travel routes between clinics.
- Other screens: `ConfirmLocationScreen`, `VisitSuccessScreen`, `DoctorRatingScreen`, `VisitHistoryScreen`.

### Gamification & Performance (`gamification/`)
- `AchievementsScreen`, `LeaderboardScreen`, `PerformanceScreen`.

### Administrative Modules
- **Products:** `ProductCatalogScreen`, `ProductDetailScreen`.
- **Attendance:** `MarkAttendanceScreen`, `AttendanceHistoryScreen`.
- **Leave:** `LeaveRequestScreen`, `LeaveHistoryScreen`.
- **Expenses:** `ExpenseSubmissionScreen`, `ExpenseHistoryScreen`.
- **Profile:** `ProfileScreen`, `EditProfileScreen`.

---

## 💻 3. Admin Web Portal (`apps/admin_web`)
*Location: `apps/admin_web/lib/features/`*
The dashboard used by regional managers and admins.

- **Admin Auth:** Managed by `AdminAuthController`.
- **Dashboard:** Uses `KpiTile` widgets (now properly utilizing `PhosphorIconData`) to display top-level metrics.
- **Reports & Audits:** Screens to review self-reported visits by MRs, approve new doctors, and track expenses.

---

## 🐛 Troubleshooting & Known Fixes
If you are hunting for bugs, note these recent architectural decisions and fixes:

1. **Icon Data Types:** The app relies on `PhosphorIcons`. We recently completed a massive refactor replacing standard Material `IconData` with `PhosphorIconData`. If a widget expects `IconData` and receives a Phosphor icon, it will crash. Ensure widgets use the `PhosphorIcon()` widget, not the standard `Icon()` widget.
2. **Const Constructors with Phosphor:** `PhosphorIcons.xxx()` is a method call, **not a constant**. You cannot use `const PhosphorIcon(...)` or place it inside a `const Row(...)`.
3. **Map Tiles (OSM):** We use OpenStreetMap. To match the dark theme, the `TileLayer` is wrapped in a `ColorFiltered` widget that inverts the colors. 
4. **Supabase Edge Functions:** `SupabaseFunctionService.notifyAdminSelfReport` triggers an external URL. If testing on web/localhost, this can throw CORS errors. It is wrapped in a `try/catch` in the controller so it doesn't break the app flow, but you will see a console error if it fails.
5. **Geofencing:** The strict GPS radius is set to `50` meters in `DoctorQuickLogController`. If you are testing in an emulator without mocking your GPS location exactly to the clinic, visit logging will trigger a warning dialog.
