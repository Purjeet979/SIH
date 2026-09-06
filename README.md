# RuleScan (Team Kamchalau Coders) - SIH 2026

**The Idea:** Scan it. Check it. Prove it.  
An offline-first compliance assistant that turns packaged-commodity labels into explainable, evidence-backed decisions according to Legal Metrology (Packaged Commodities) Rules, 2011.

---

## 🏗️ Project Architecture & Tech Stack
Our project is organized as a monorepo containing:
1. **Mobile App:** Flutter (Android) for offline capture, Edge OCR, and rule parsing.
2. **Web Dashboard:** React / Next.js for reporting, analytics, and admin overview.
3. **Backend & Database:** Supabase (PostgreSQL) for real-time syncing, Role-Based Access Control (RBAC), and user authentication.
4. **AI Classifier:** Python (Hugging Face / TFLite) for category classification.

---

## ✅ Features Implemented (MVP)

### 1. Offline-First Mobile App Core (`app/rulescan_app`)
- **App Shell & Camera:** Flutter UI that captures label images without requiring internet.
- **On-Device OCR:** Integrated Google ML Kit (Text Recognition v2) to extract English and Devanagari (Hindi) text directly on the device.
- **Native Dart Rule Engine:** Created a local Dart parser (`lib/rule_engine.dart`) that reads the LMPC JSON rules locally, evaluating missing fields or violations (e.g., MRP, Net Quantity) entirely offline.
- **Geotagged Evidence & SQLite:** App automatically stores inspection reports in an offline SQLite database (`sqflite`), embedding GPS coordinates (`latitude/longitude`).
- **Background API Sync:** When internet is restored, the app silently bridges its local SQLite records to the cloud Supabase database, uploading evidence images and parsed violation data.

### 2. Live Web Dashboard (`web/`)
- **Next.js & Supabase Integration:** A fully functional React / Next.js 14 App Router project connected directly to Supabase.
- **Role-Based Access Control (RBAC):** Secure login flows separating **Field Officers** (viewing their own scans) and **Admins** (system-wide overview).
- **Dynamic Analytics:** Real-time calculation of compliance rates, category distribution shares, and "Top Violated LMPC Clauses" directly from synchronized mobile data.
- **Live Inspection Table:** A dynamic data grid displaying geotagged scans, rule outcomes, officer details, and 1-click A4 PDF certificate exports.

### 3. Rule-Numbered Compliance Engine (`backend/rule-engine`)
- **Versioned JSON Rules:** Mapped Rule 6 and Rule 7 into a dynamic `base.json` file.
- **JSON Adapter:** Node.js backend infrastructure translating `base.json` into conditional logic.

### 4. Media & E-Commerce Integrations
- **Barcode & QR Scanner:** Integrated Google ML Kit Barcode API. Scanned barcodes automatically map to inspections to identify products.
- **E-Commerce Image Uploads:** Added a "Gallery Upload" option to scan screenshots from Amazon/Flipkart/Blinkit directly through the OCR Rule Engine.

---

## 🚀 To-Do: Future Scope (Phase 2 & 3)

### Advanced Vision & Rules
- **Rule 7 Calibration (Computer Vision):** Implement OpenCV logic to measure font sizes (letter height/width) by comparing text bounding boxes against a known reference object (e.g., a coin or ID card).
- **Rule 8-9 Validation:** Check exact placement, free-space, and contrast of declarations on the Principal Display Panel (PDP).
- **E-Commerce Screen Scanner:** Allow officers to paste a URL of an e-commerce listing and parse it for Rule 6(10) online declarations automatically using web scrapers.
- **Automated Legal Notices:** Auto-generate PDF/DOCX legal notices dispatched to manufacturers from confirmed violations.

---

## 🛠️ How to Run the App

### Mobile App (Flutter)
```bash
cd app/rulescan_app/example
flutter pub get
flutter run # (ensure USB debugging is on, or run on an emulator)
```
*Note: You can also download the pre-compiled `rulescan.apk` directly from the Web Dashboard.*

### Web Dashboard (Next.js)
```bash
cd web
npm install
npm run dev
# Go to http://localhost:3000
```
