# MediVisit Pro — FREE STACK Architecture (Rewrite)
### Replaces Sections 1, 5.8, 5.9, 6.4, 7.3, 8, 9 of `02_MASTER_BUILD_PROMPT.md`

---

> **Is document ko kaise use karo:** Yeh poora `02_MASTER_BUILD_PROMPT.md` ko replace nahi karta — sirf un sections ko **override** karta hai jo backend cost se related hain. Baaki sab (Section 2 screen mapping, Section 3 design tokens, Section 4 navigation, Section 5.1–5.7/5.10–5.24 business logic) **same rahega, koi change nahi**. Antigravity ko dono files do — `02_MASTER_BUILD_PROMPT.md` + yeh document — aur bolo "is overrides that".

---

## 0. ARCHITECTURE AT A GLANCE — Pehle vs Ab

```
PEHLE (Master Prompt v1 — Paid)              AB (Free Stack)
─────────────────────────────              ─────────────────────────────
Firebase Blaze Plan          ──────────►    Firebase Spark Plan (FREE)
Cloud Functions               ──────────►   Supabase Edge Functions (FREE)
Firebase Storage              ──────────►   Cloudinary (FREE — 25GB/mo)
Cloud Vision API (OCR)        ──────────►   On-Device ML Kit OCR (FREE, offline bhi)
Google Maps + Directions API  ──────────►   OpenStreetMap + Native App Handoff (FREE)
Scheduled Cloud Function       ──────────►  GitHub Actions Cron (FREE)
```

**Core insight jo poore design ko possible banata hai:** Supabase Edge Functions ek "trusted backend" ka kaam karta hai — bilkul waisa hi jaisa Firebase Cloud Functions karta. Edge Function ke paas Firebase ka **service account key** hota hai (secret ke taur pe stored), jisse woh Firestore ko REST API se directly likh sakta hai — security rules ko bypass karke, bilkul Cloud Functions Admin SDK jaisa. Matlab **"client kabhi geofence_verified field khud set nahi kar sakta"** wala rule abhi bhi 100% intact rehta hai — sirf trusted compute Google Cloud se Supabase pe shift hua hai.

---

## 1. UPDATED BACKEND SUMMARY (Replaces Master Prompt Section 1)

**Backend:** Hybrid free-tier architecture —
- **Firebase (Spark/Free):** Auth, Firestore (database), Cloud Messaging (push delivery)
- **Supabase (Free tier):** Edge Functions — ALL server-side trusted logic (geofence validation, leaderboard computation trigger, notification dispatch, route distance calculation)
- **Cloudinary (Free tier):** All file storage — profile photos, doctor photos, product images, receipts, brochures, manager feedback audio
- **GitHub Actions (Free):** Scheduled cron jobs — hourly leaderboard snapshot, daily notification digest checks
- **On-device:** OCR (ML Kit), basic routing math (haversine + free OSRM demo server for road-distance estimate)

No Firebase Blaze upgrade required. No Google Cloud billing account required. Zero credit card needed anywhere in this stack for MVP-scale usage (defined limits in Section 7 below).

---

## 2. SUPABASE EDGE FUNCTIONS — Cloud Functions Replacement

### 2.1 Setup (One-time)
```bash
# Install Supabase CLI
npm install -g supabase

# Login & init
supabase login
supabase init

# Create your Edge Functions
supabase functions new verify-visit
supabase functions new verify-attendance
supabase functions new send-notification
supabase functions new recompute-leaderboard
supabase functions new get-route-estimate

# Store Firebase service account as a secret (NEVER commit this file)
supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat firebase-service-account.json)"
supabase secrets set FCM_SERVER_KEY="your-fcm-server-key"

# Deploy
supabase functions deploy verify-visit
supabase functions deploy verify-attendance
supabase functions deploy send-notification
supabase functions deploy recompute-leaderboard
supabase functions deploy get-route-estimate
```

### 2.2 How each function replaces a Cloud Function

| Edge Function | Replaces (Master Prompt Section) | What it does |
|---|---|---|
| `verify-visit` | 5.3.1 geofence Cloud Function | Receives Firebase ID token + doctor_id + lat/lng. Verifies token, fetches doctor's clinic GeoPoint+radius from Firestore (REST), computes distance, writes `visits/{id}` doc with authoritative `geofence_verified` field via Firestore REST API using service account auth. |
| `verify-attendance` | 5.5 geofence Cloud Function | Same pattern, checks against MR's assigned territory office location instead of a doctor clinic. |
| `send-notification` | 5.11/5.20 trigger-based Functions | Called directly by admin actions (leave approve/reject, expense approve) right after the Firestore write — writes the `notifications/{id}` doc AND calls FCM HTTP v1 API in the same request. No need for a Firestore-trigger Cloud Function. |
| `recompute-leaderboard` | 5.10 scheduled Cloud Function | Called by the GitHub Actions cron (Section 4 below) hourly. Reads all MRs' visit counts for the period, writes `leaderboard_snapshots/{period}`. |
| `get-route-estimate` | 5.9 Directions API call | Calls the free OSRM demo router for road-distance/time between stops (see Section 5), returns sequenced stop order to the client. |

### 2.3 Example Edge Function — `verify-visit/index.ts`
```typescript
import { serve } from "https://deno.land/std/http/server.ts";
import { create, verify } from "https://deno.land/x/djwt/mod.ts";

serve(async (req) => {
  const { idToken, doctorId, lat, lng, visitId, notes } = await req.json();

  // 1. Verify the Firebase ID token (validates the MR is who they claim)
  const decodedToken = await verifyFirebaseToken(idToken);
  const mrId = decodedToken.user_id;

  // 2. Fetch doctor's clinic location via Firestore REST API
  const doctor = await firestoreGet(`doctors/${doctorId}`);
  const clinicLat = doctor.fields.clinic_location.geoPointValue.latitude;
  const clinicLng = doctor.fields.clinic_location.geoPointValue.longitude;
  const radiusM = doctor.fields.geofence_radius_m.integerValue;

  // 3. Calculate distance (Haversine formula)
  const distance = haversineDistance(lat, lng, clinicLat, clinicLng);
  const geofenceVerified = distance <= radiusM;

  // 4. Write the AUTHORITATIVE visit doc via Firestore REST (service account = trusted)
  await firestoreWrite(`visits/${visitId}`, {
    mr_id: mrId,
    doctor_id: doctorId,
    geofence_verified: geofenceVerified,
    distance_from_clinic_m: distance,
    location: { lat, lng },
    notes,
    status: geofenceVerified ? "verified" : "pending_review",
    created_at: new Date().toISOString(),
  });

  return new Response(JSON.stringify({ success: true, geofenceVerified }), {
    headers: { "Content-Type": "application/json" },
  });
});

function haversineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371000; // Earth radius in meters
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat/2)**2 + Math.cos(lat1*Math.PI/180) *
    Math.cos(lat2*Math.PI/180) * Math.sin(dLon/2)**2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
}
```

### 2.4 Flutter side — calling the Edge Function
```dart
// lib/core/services/geofence_service.dart
class GeofenceService {
  static const _supabaseUrl = 'https://YOUR_PROJECT.supabase.co/functions/v1';

  Future<bool> verifyVisit({
    required String doctorId,
    required double lat,
    required double lng,
    required String visitId,
    String? notes,
  }) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    final response = await http.post(
      Uri.parse('$_supabaseUrl/verify-visit'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'idToken': idToken,
        'doctorId': doctorId,
        'lat': lat,
        'lng': lng,
        'visitId': visitId,
        'notes': notes,
      }),
    );

    final result = jsonDecode(response.body);
    return result['geofenceVerified'];
  }
}
```

---

## 3. CLOUDINARY — Storage Replacement (Replaces Section 6.4)

### 3.1 Setup
```
1. cloudinary.com → free account banao
2. Dashboard se: Cloud Name, API Key, API Secret note karo
3. Upload preset banao: Settings → Upload → Add upload preset
   - Signing Mode: "Signed" (security ke liye — anonymous upload mat karo)
   - Folder: medivisit_pro/
```

### 3.2 Bucket mapping (old Firebase Storage paths → Cloudinary folders)
```
storage/profile_photos/{uid}        → medivisit_pro/profile_photos/{uid}
storage/receipts/{uid}/{expenseId}  → medivisit_pro/receipts/{uid}/{expenseId}
storage/doctor_photos/{doctorId}    → medivisit_pro/doctor_photos/{doctorId}
storage/product_images/{productId}  → medivisit_pro/product_images/{productId}
storage/product_brochures/{id}      → medivisit_pro/brochures/{id}
storage/manager_feedback_audio/{id} → medivisit_pro/feedback_audio/{id}
```

### 3.3 Upload flow — Signed uploads via Supabase Edge Function
Direct unsigned upload se koi bhi tumhare account mein upload kar sakta hai — isliye signed upload use karo. Ek aur Edge Function banao:

```bash
supabase functions new get-upload-signature
```

```typescript
// get-upload-signature/index.ts
import { createHash } from "https://deno.land/std/hash/mod.ts";

serve(async (req) => {
  const { folder } = await req.json();
  const timestamp = Math.floor(Date.now() / 1000);
  const apiSecret = Deno.env.get("CLOUDINARY_API_SECRET");

  const paramsToSign = `folder=${folder}&timestamp=${timestamp}${apiSecret}`;
  const signature = createHash("sha1").update(paramsToSign).toString();

  return new Response(JSON.stringify({
    signature, timestamp,
    apiKey: Deno.env.get("CLOUDINARY_API_KEY"),
    cloudName: Deno.env.get("CLOUDINARY_CLOUD_NAME"),
  }));
});
```

```dart
// lib/core/services/cloudinary_service.dart
class CloudinaryService {
  Future<String> uploadFile(File file, String folder) async {
    // 1. Get signed params from Supabase Edge Function
    final sigResponse = await http.post(
      Uri.parse('$_supabaseUrl/get-upload-signature'),
      body: jsonEncode({'folder': folder}),
    );
    final sig = jsonDecode(sigResponse.body);

    // 2. Upload directly to Cloudinary (signed)
    final uploadUrl = 'https://api.cloudinary.com/v1_1/${sig['cloudName']}/auto/upload';
    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..fields['api_key'] = sig['apiKey']
      ..fields['timestamp'] = sig['timestamp'].toString()
      ..fields['signature'] = sig['signature']
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = jsonDecode(await response.stream.bytesToString());
    return body['secure_url']; // store this URL in Firestore document
  }
}
```

**Free tier limit:** 25 monthly credits ≈ 25GB storage + bandwidth combined. Reports/receipts/photos ke liye yeh kaafi hai shuruaat mein (hundreds of MRs tak comfortably chalega).

---

## 4. GITHUB ACTIONS — Scheduled Jobs (Replaces scheduled Cloud Function)

### 4.1 Leaderboard recompute — hourly
```yaml
# .github/workflows/leaderboard.yml
name: Recompute Leaderboard

on:
  schedule:
    - cron: '0 * * * *'   # every hour
  workflow_dispatch:        # manual trigger button bhi milega

jobs:
  recompute:
    runs-on: ubuntu-latest
    steps:
      - name: Call Supabase Edge Function
        run: |
          curl -X POST \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_FUNCTION_SECRET }}" \
            -H "Content-Type: application/json" \
            https://YOUR_PROJECT.supabase.co/functions/v1/recompute-leaderboard
```

### 4.2 Daily notification digest (low stock alerts, leave reminders)
```yaml
# .github/workflows/daily-checks.yml
name: Daily Notification Checks

on:
  schedule:
    - cron: '0 3 * * *'   # 3 AM UTC daily (8:30 AM IST)
  workflow_dispatch:

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger notification check
        run: |
          curl -X POST \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_FUNCTION_SECRET }}" \
            https://YOUR_PROJECT.supabase.co/functions/v1/daily-notification-check
```

**Setup:** GitHub repo → Settings → Secrets and variables → Actions → `SUPABASE_FUNCTION_SECRET` add karo.

**Free limit:** Public repo = unlimited minutes. Private repo = 2000 min/month free — yeh cron jobs sirf seconds lete hain, mahine mein kabhi khatam nahi hoga.

---

## 5. ROUTE PLANNER — Replaces Section 5.9 (Google Maps Removed)

### Why change zaroori thi
Google Directions/Routes API ko **billing-enabled GCP project chahiye** — chahe $200/month free credit ho, phir bhi credit card daalni padti hai. Tumhare "sab kuch free" goal ke against jaata hai.

### Naya approach — Zero-cost, do-part solution

**Part A — In-app route preview (free, no API key):**
```
Package: flutter_map (already free, OpenStreetMap tiles)
+ latlong2 (distance calculations)

Stop ordering: Nearest-neighbor heuristic using haversine distance
(client-side ya Edge Function — straight-line distance, "as the crow
flies" — accurate enough for MR ka daily planning)
```

**Part B — Actual turn-by-turn navigation (free, native handoff):**
```dart
// "Start Navigation" button par — apne app mein navigation
// build NAHI karo, seedha Google Maps / Apple Maps app khol do

import 'package:url_launcher/url_launcher.dart';

Future<void> startNavigation(double lat, double lng) async {
  final url = Platform.isIOS
    ? 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d'
    : 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';

  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
```

Yeh actually **better UX bhi hai** — MR ko unka familiar Google Maps app milta hai with live traffic, voice navigation — jo tum khud kabhi utna achha nahi bana sakte free mein.

**Optional — Better road-distance estimate (still free):**
```
OSRM Demo Server: https://router.project-osrm.org
- Free public instance, no API key
- Rate-limited (fair use) — production ke liye apna OSRM self-host
  kar sakte ho Docker se (bilkul free, apne server pe)
- Use only for "estimated time" display, not for actual turn-by-turn
```

```dart
Future<Map> getRoadDistance(LatLng from, LatLng to) async {
  final url = 'https://router.project-osrm.org/route/v1/driving/'
    '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
    '?overview=false';
  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);
  return {
    'distance_m': data['routes'][0]['distance'],
    'duration_s': data['routes'][0]['duration'],
  };
}
```

### Updated pubspec dependency change
```diff
- google_maps_flutter: ^2.x
+ flutter_map: ^7.0.2
+ latlong2: ^0.9.1
+ url_launcher: ^6.3.0
```

---

## 6. OCR — Replaces Section 5.8 (Cloud Vision Removed)

### Why change behtar hai (sirf cost ka issue nahi)
Cloud Vision API har call ke liye internet chahiye + billing-enabled project. **On-device ML Kit** zero cost hai, **offline bhi kaam karta hai** — jo tumhare "offline-first" requirement (Section 6.3) ke saath perfectly fit baithta hai. Field rep kahin bhi receipt scan kar sakta hai bina network ke.

### Implementation
```yaml
# pubspec.yaml
dependencies:
  google_mlkit_text_recognition: ^0.13.0
```

```dart
// lib/core/services/ocr_service.dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final _textRecognizer = TextRecognizer();

  Future<ExtractedReceipt> scanReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    // Simple pattern matching for amount, date, vendor
    // (basic version — Phase 4 mein behtar NLP-based extraction layer add karo)
    final amount = _extractAmount(recognizedText.text);
    final date = _extractDate(recognizedText.text);
    final vendor = _extractVendorLine(recognizedText.text);

    return ExtractedReceipt(amount: amount, date: date, vendor: vendor);
  }

  double? _extractAmount(String text) {
    final regex = RegExp(r'(?:total|amount|₹|rs\.?)\s*:?\s*(\d+\.?\d*)',
      caseSensitive: false);
    final match = regex.firstMatch(text);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  // ... date/vendor extraction helpers
}
```

**Important:** Master Prompt ka yeh rule abhi bhi waisa hi rahega — "MR must confirm/correct before submit, never auto-submit OCR output unreviewed." On-device OCR thoda kam accurate ho sakta hai Cloud Vision se, isliye yeh editable-fields-with-review pattern aur bhi zaroori ho jaata hai.

---

## 7. UPDATED FREE-TIER LIMITS — Kab Upgrade Karna Padega

| Service | Free Limit | Kab tak chalega |
|---|---|---|
| Firestore (Spark) | 50K reads, 20K writes, 20K deletes /day | ~150-200 active MRs tak comfortably (daily visit+attendance+leave writes) |
| Firebase Auth | Unlimited users (free always) | Koi limit nahi |
| FCM | Unlimited (free always) | Koi limit nahi |
| Supabase Edge Functions | 500K invocations/month | ~500 MRs tak (har visit/attendance ek call) |
| Cloudinary | 25 credits/month (~25GB) | Photos/receipts ke liye 100+ MRs tak |
| GitHub Actions | 2000 min/month (private) | Cron jobs seconds lete hain — kabhi khatam nahi hoga |
| OSRM public demo | Rate-limited, fair-use | Dev/testing ke liye fine; production scale pe self-host karo (free, apna server) |

**Upgrade trigger:** Jab MR count ~150-200 cross kare, Firestore daily writes limit hit ho sakti hai — tab Firebase Blaze pe switch karna padega (pay-as-you-go, lekin tab tak revenue/funding hone ki ummeed hai).

---

## 8. UPDATED NON-NEGOTIABLE CONSTRAINTS (Replaces Section 8, item 3)

```diff
3. Geofencing is authoritative server-side, per Sections 5.3.1 and 6.2
-  — never trust a client-asserted "I was at the location" flag.
+  — implemented via Supabase Edge Functions (not Firebase Cloud
+  Functions) using a Firebase service account for trusted Firestore
+  writes. Never trust a client-asserted "I was at the location" flag
+  — the client only ever sends raw GPS coordinates; the Edge Function
+  computes and writes geofence_verified authoritatively.
```

All other constraints (RBAC, offline-first, data minimization, performance, error handling, localization, testing) **remain exactly as written** in the original Master Prompt — unaffected by this backend change.

---

## 9. UPDATED PHASE 0 SETUP STEPS (Replaces Implementation Guide Section 2.5)

```diff
2.5 Firebase / Cloud setup
1. Create a new Firebase project at console.firebase.google.com
2. Enable Auth (Email/Password), Firestore, and Cloud Messaging
-  3. Upgrade to the Blaze plan — required for Cloud Functions and for
-  calling Cloud Vision API (receipt OCR) and Maps/Routes API (route
-  planner) from Functions. Set a budget alert immediately.
-  4. Get a Google Maps Platform API key (Maps SDK + Directions/Routes
-  API) for the route planner and live-tracking map screens.
+  3. STAY ON SPARK (FREE) PLAN — no Blaze upgrade needed.
+  4. Create a Supabase project at supabase.com — free tier, no card
+  required. Note your project URL and anon key.
+  5. Generate a Firebase service account key (Project Settings →
+  Service Accounts → Generate new private key) — store as a Supabase
+  secret, never commit to git.
+  6. Create a Cloudinary account at cloudinary.com — free tier, no
+  card required. Note Cloud Name, API Key, API Secret.
+  7. No Google Maps API key needed — route planner uses flutter_map
+  (OpenStreetMap) + native app handoff (Section 5 above).
5. Don't run flutterfire configure yourself — instruct the agent to
   do it as part of Phase 0 once both Flutter apps exist.
```

---

## 10. UPDATED PACKAGES (Replaces Section 7.3)

```diff
firebase_core, firebase_auth, cloud_firestore, firebase_messaging,
firebase_crashlytics, firebase_performance
- firebase_storage, cloud_functions
+ http (for Supabase Edge Function + Cloudinary calls)
get · hive, hive_flutter · flutter_secure_storage
- geolocator, google_maps_flutter
+ geolocator, flutter_map, latlong2, url_launcher
image_picker, cached_network_image · fl_chart · share_plus
intl, flutter_localizations (en/hi) · connectivity_plus · lottie
pdf, printing (admin export)
- (Cloud Vision dependency removed — OCR is now on-device)
+ google_mlkit_text_recognition (on-device OCR)
```

---

## 11. UPDATED ANTIGRAVITY KICKOFF PROMPT (Add to Section 12 of Master Prompt)

Jab tum Antigravity ko first message do, yeh paragraph **add** karo `02_MASTER_BUILD_PROMPT.md` ke baad:

```
IMPORTANT BACKEND OVERRIDE: This project uses a free-tier-only stack,
documented in docs/03_FREE_STACK_ARCHITECTURE.md. Read that file in
full as well — it overrides Sections 1, 5.8, 5.9, 6.4, 7.3, 8(item 3),
and 9(Phase 0 setup steps) of the Master Build Prompt. Specifically:

- Firebase stays on the Spark (free) plan — no Blaze, no Cloud Functions
- All server-side trusted logic (geofence validation, leaderboard
  computation, notification dispatch) runs on Supabase Edge Functions
  instead of Firebase Cloud Functions
- File storage uses Cloudinary instead of Firebase Storage
- OCR uses on-device ML Kit instead of Cloud Vision API
- Route planning uses flutter_map (OpenStreetMap) + native app handoff
  for navigation instead of Google Maps/Directions API
- Scheduled jobs (leaderboard recompute) run via GitHub Actions cron
  calling Supabase Edge Functions, instead of a scheduled Cloud Function

Everything else in the Master Build Prompt (screens, navigation, design
tokens, Firestore schema, security rule principles, business logic)
remains unchanged — only the execution layer for server-side compute,
file storage, OCR, and maps has moved to free-tier equivalents.
```

---

## 12. FOLDER STRUCTURE UPDATE

```diff
medivisit_pro/
├── design_reference/
├── docs/
│   ├── 01_Antigravity_Implementation_Guide.md
│   ├── 02_MASTER_BUILD_PROMPT.md
+   ├── 03_FREE_STACK_ARCHITECTURE.md     ← yeh document
│   ├── Medical_Representative_MR_App_Feature_Plan.md
│   └── Advanced_Features_and_Implementation_Strategies.md
+├── supabase/
+│   └── functions/
+│       ├── verify-visit/
+│       ├── verify-attendance/
+│       ├── send-notification/
+│       ├── recompute-leaderboard/
+│       ├── get-route-estimate/
+│       └── get-upload-signature/
+├── .github/
+│   └── workflows/
+│       ├── leaderboard.yml
+│       └── daily-checks.yml
├── packages/core/
└── apps/
    ├── mr_mobile/
    └── admin_web/
```

---

## SUMMARY — Kya Karna Hai Ab

```
1. Is file ko docs/03_FREE_STACK_ARCHITECTURE.md ke naam se save karo
2. Supabase account banao (free, no card)
3. Cloudinary account banao (free, no card)
4. Firebase project Spark plan pe rakho — Blaze mat karo
5. Antigravity ko BOTH files do — 02_MASTER_BUILD_PROMPT.md +
   03_FREE_STACK_ARCHITECTURE.md — aur Section 11 ka override
   paragraph first message mein add karo
6. Baaki sab phases (0→1→2→3→4) bilkul same sequence follow karenge
```

Yeh poora stack **genuinely zero-cost** hai for MVP scale — kahin bhi credit card nahi chahiye, aur ~150-200 active MRs tak comfortably chalega bina kisi upgrade ke.

---

*MediVisit Pro — Free Stack Architecture v1.0*
*Overrides applied to: 02_MASTER_BUILD_PROMPT.md Sections 1, 5.8, 5.9, 6.4, 7.3, 8, 9, 12*
