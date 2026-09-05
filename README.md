# RuleScan (Team Kamchalau Coders)

**The Idea:** Scan it. Check it. Prove it.  
An offline-first compliance assistant that turns packaged-commodity labels into explainable, evidence-backed decisions according to Legal Metrology (LMPC) Rules.

## 🏗️ Project Architecture & Tech Stack
Our project is organized as a monorepo containing:
1. **Mobile App:** Flutter (Android) for offline capture, OCR, and rules.
2. **Web Dashboard:** React / Next.js for reporting and analytics.
3. **Backend Engine:** Node.js for JSON rule validation and sync APIs.
4. **AI Classifier:** Python (Hugging Face / TFLite) for category classification.

---

## ✅ Progress: What Has Been Implemented (Phase 1 MVP)

### 1. Offline-First Mobile App Core (`app/rulescan_app`)
- **App Shell & Camera:** Flutter UI that captures label images without requiring internet.
- **On-Device OCR:** Integrated Google ML Kit (Text Recognition v2) to extract English and Devanagari (Hindi) text directly on the device.
- **Native Dart Rule Engine:** Created a local Dart parser (`lib/rule_engine.dart`) that reads the LMPC JSON rules locally, evaluating missing fields or violations (e.g., MRP, Net Quantity) entirely offline.
- **Officer Review Screen:** A manual Category dropdown allows the officer to override or confirm compliance flags.
- **Geotagged Evidence & SQLite:** App automatically stores inspection reports in an offline SQLite database (`sqflite`), embedding GPS coordinates (`latitude/longitude`) via the `geolocator` plugin.
- **ProGuard Fixes:** Adjusted `proguard-rules.pro` to ensure the app compiles properly in Release mode without R8 minifier breaking the ML Kit.

### 2. Rule-Numbered Compliance Engine (`backend/rule-engine`)
- **Versioned JSON Rules:** Mapped Rule 6 and Rule 7 into a dynamic `base.json` file.
- **JSON Adapter:** Wrote a Node.js adapter (`json_adapter.js`) that translates `base.json` into conditional logic that the `json-rules-engine` can execute. 

### 3. Web Dashboard (`web/`)
- **Next.js Migration:** Successfully migrated the vanilla HTML dashboard to a fully functional React / Next.js 14 App Router project.
- **Routing & Assets:** Consolidated `globals.css`, routing for Landing Page and Dashboard, and placed the demo APK for direct download.

### 4. AI Category Classifier (`ml/hf-classifier`)
- **Transformer Script:** Created a Python inference script (`classifier.py`) that uses the Hugging Face `Maverick98/EcommerceClassifier`.
- **LMPC Mapping:** Added a dictionary to map the model's 400+ generic e-commerce buckets into our required LMPC categories (e.g., `cosmetics_toiletries`, `packaged_food`) using confidence thresholds.

### 5. Media & Offline Evidence Sync
- **Image Geotagging & Database:** Updated local SQLite DB and App permissions to capture and save base64 encoded photo evidence.
- **Background API Sync:** Node.js backend seamlessly handles high-payload syncing for field inspections images when internet is restored.
- **E-Commerce Image Uploads:** Added a "Gallery Upload" option to scan screenshots from Amazon/Flipkart/Blinkit directly through the OCR Rule Engine.

### 6. Product Identification & Reporting
- **Barcode & QR Scanner:** Integrated Google ML Kit Barcode API. Scanned barcodes automatically map to inspections to identify products.
- **Instant A4 PDF Reports:** Use `pdf` and `printing` plugins on mobile for 1-click sharing of Compliance/Violation Reports.
- **Web Dashboard PDF Export:** Dashboard uses `@media print` CSS for lightweight, zero-dependency data exporting.

---

## 🚀 To-Do: What Needs to be Implemented Next (Phase 2 & 3)

### Phase 8: Advanced Web Dashboard & Admin Capabilities
- **Analytics Overview:** Build graphical charts on the Next.js dashboard for Total Inspections (Passed vs Failed vs Manual Review).
- **Authentication:** Implement Firebase Auth / JWT with RBAC (Role-Based Access Control) for Officer vs Admin roles.
- **Pagination & Filters:** Allow filtering Dashboard data by Date, Category, and Officer ID.

### Phase 3: Advanced Vision & Rules
- **Rule 7 Calibration (Computer Vision):** Implement OpenCV logic to measure font sizes (letter height/width) by comparing text bounding boxes against a known reference object (e.g., a coin or ID card).
- **Rule 8-9 Validation:** Check exact placement, free-space, and contrast of declarations on the Principal Display Panel (PDP).
- **E-Commerce Screen Scanner:** Allow officers to paste a URL or screenshot of an e-commerce listing and parse it for Rule 6(10) online declarations.
- **Reporting:** Auto-generate PDF/DOCX legal notices from confirmed violations.

---

## 🛠️ How to Run the App (Current State)

### Mobile App
```bash
cd app/rulescan_app/example
flutter pub get
flutter run # (ensure USB debugging is on)
```

### Web Dashboard
```bash
cd web
npm install
npm run dev
# Go to http://localhost:3000
```
