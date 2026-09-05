# RuleScan: Deep Dive & Technical Implementation Details

This document provides an in-depth technical breakdown of how **RuleScan** (Team Kamchalau Coders) was built for the Smart India Hackathon. It explains the exact flow, technologies used, and how we solved the complex problem of digitizing Legal Metrology (LMPC) compliance checking offline.

---

## 1. The Core Philosophy: "Offline-First"
Field officers often operate in remote areas or factory godowns with zero internet connectivity. Therefore, our primary architecture rule was **Offline-First**. 
- The Mobile App does not rely on a backend to perform OCR.
- The Rule Engine logic evaluates locally on the device.
- Evidence (Photos + Geo-tags) is saved in local SQLite databases until a network connection is restored.

---

## 2. The Rule Engine: Translating Law into Code
The Legal Metrology (Packaged Commodities) Rules, 2011 (specifically Rules 6 and 7) dictate what declarations must exist on a package. Hardcoding these rules into mobile code is a bad practice because laws change.

### How we implemented it:
1. **`base.json` (The Master Rulebook):**
   We created a JSON schema that dictates the rules. For example, it defines that *all* products must have an MRP, but only `cosmetics_toiletries` need a "Veg/Non-Veg mark".
2. **Backend Node.js Adapter (`json_adapter.js`):**
   We wrote an adapter that parses `base.json` and feeds it into the `json-rules-engine` library. This allows the backend to validate server-side API requests using the exact same JSON file.
3. **Dart Native Parser (`lib/rule_engine.dart`):**
   To keep the mobile app offline, we wrote a Dart parser that reads `base.json` from the local assets folder. When OCR text is generated, the Dart engine evaluates conditions like `field: "mrp", check_type: "presence"` entirely on the phone's CPU.

---

## 3. Optical Character Recognition (OCR) Integration
We needed an OCR engine that was lightweight, fast, and supported Indian languages (specifically Hindi/Devanagari) locally.

### How we implemented it:
1. **Google ML Kit (Text Recognition v2):**
   We used the `google_mlkit_text_recognition` Flutter plugin. Unlike V1, V2 allows downloading language models directly to the device.
2. **Camera Flow & Memory Management:**
   Initially, continuous OCR on a live camera feed (`ResolutionPreset.high`) caused memory overflow and device freezing. We solved this by:
   - Downgrading the camera preview to `ResolutionPreset.medium`.
   - Replacing the continuous loop with a **Manual Capture** button. The OCR engine now receives a single, focused, static image, processes it in milliseconds, and immediately disposes of the heavy image from memory.
3. **ProGuard Minification Fix:**
   When compiling the Release APK, Android's R8 minifier stripped the ML Kit's Devanagari/Japanese classes because they are loaded via Java Reflection. We fixed this by writing custom `-keep` rules in `proguard-rules.pro`.

---

## 4. AI Category Classification
Different LMPC rules apply to different product categories. We needed to automate category detection.

### How we implemented it:
1. **Hugging Face Inference (`classifier.py`):**
   We wrote a Python pipeline utilizing `Maverick98/EcommerceClassifier`. This Transformer model is trained on 434 generic e-commerce categories.
2. **LMPC Mapping Dictionary:**
   The LMPC act only cares about ~15 broad buckets (e.g., Packaged Food, Cement, Textiles). We built a mapping function that intercepts the Transformer's output (e.g., `["lipstick", "foundation"]`) and maps it to the LMPC bucket (`"cosmetics_toiletries"`).
3. **MVP Integration:**
   For Phase 1 MVP, to keep the mobile app 100% offline without porting a heavy 500MB PyTorch model to TFLite, we provided a Manual Dropdown in the Officer Review Screen. The officer selects the category, and the Dart Rule engine triggers the appropriate JSON subset.

---

## 5. Evidence Collection & Geotagging
A violation notice is legally invalid without hard evidence.

### How we implemented it:
1. **SQLite Database (`db_helper.dart`):**
   Every completed scan is inserted into a local SQLite `inspections` table. It stores the category, the raw OCR text, the missing violations, and a timestamp.
2. **Geolocator (GPS):**
   We integrated the `geolocator` plugin. When an inspection is saved, it pulls the precise `latitude` and `longitude` of the officer's device. This prevents spoofing of inspection locations.
3. **Sync State:**
   Records are marked with `synced = 0`. When the "Sync Data" button is pressed (and internet is available), these records will be packaged into a REST API call to the backend, and then marked as `synced = 1`.

---

## 6. Next.js Web Dashboard
While the Mobile App is for the field officer, the Dashboard is for the Nodal Officer/Admin at the headquarters.

### How we implemented it:
- We migrated a basic HTML prototype into a modern **React / Next.js 14 App Router** architecture.
- Styled with pure CSS (no bloated UI libraries) for maximum speed.
- It includes a landing page to download the latest APK, and a Dashboard route to view aggregated compliance reports (currently stubbed, ready for Phase 2 API integration).

---
*Document prepared by Antigravity (AI Assistant) for Team Kamchalau Coders.*
