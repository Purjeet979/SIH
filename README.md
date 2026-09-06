# RuleScan - Smart India Hackathon 2026 (Team Kamchalau Coders)

> **Problem Statement:** SIH26034  
> **Tagline:** Scan it. Check it. Prove it.  
> **Vision:** An offline-first compliance assistant that turns packaged-commodity labels into explainable, evidence-backed decisions according to Legal Metrology (Packaged Commodities) Rules, 2011.

---

## 🏗️ System Architecture & Working Flow

RuleScan is designed to operate in low-connectivity environments (warehouses, godowns, remote fields). The core intelligence lives *on-device*, while analytics and reporting sync to the cloud when internet is available.

```mermaid
graph TD
    %% Mobile App Flow
    subgraph Mobile App [Android Field App - Offline]
        Camera[Camera Capture] --> MLKit[Google ML Kit OCR]
        MLKit --> Classifier[AI Category Classifier]
        Classifier --> RuleEngine[Dart JSON Rule Engine]
        RuleEngine --> LocalDB[(SQLite Local Database)]
    end

    %% Sync Flow
    LocalDB -- "Background Sync (When Online)" --> Supabase[(Supabase PostgreSQL)]

    %% Web Dashboard Flow
    subgraph Web App [Next.js Web Dashboard - Online]
        Supabase --> Analytics[Dynamic Analytics & Charts]
        Supabase --> Reports[A4 PDF Certificate Generation]
        Supabase --> RBAC[Role-Based Access Control]
    end
    
    %% Actors
    Officer((Field Officer)) --> Camera
    Admin((System Admin)) --> Web App
```

### How it Works (The Inspection Pipeline):
1. **Capture:** The Field Officer photographs a product label using the Android app.
2. **On-Device OCR & AI:** Google ML Kit extracts the text (English & Hindi) entirely offline. The local AI classifier categorizes the product (e.g., *Packaged Food, Cosmetics*).
3. **Rule Evaluation:** The native Dart engine parses LMPC rules from local JSON files and checks for missing mandatory declarations (MRP, Net Qty, Best Before, etc.).
4. **Offline Storage:** The inspection result, along with geotagged (GPS) photo evidence, is stored in a local SQLite database.
5. **Cloud Sync:** Once the officer's device connects to Wi-Fi/4G, the app silently bridges the data to the central Supabase database.
6. **Dashboard Overview:** Admins log into the Next.js web dashboard to see real-time compliance metrics, top violated rules, and download official PDF reports.

---

## 📂 Folder Structure

The repository is structured as a highly modular monorepo:

```text
SIH/rulescan/
│
├── app/rulescan_app/         # 📱 FLUTTER MOBILE APP (Field Officers)
│   ├── android/              # Native Android config (ProGuard rules, permissions)
│   ├── assets/               # Local JSON LMPC rules & offline ML models
│   └── lib/                  # Dart source code
│       ├── rule_engine.dart  # Native Dart offline rule parser
│       ├── sync_service.dart # Background SQLite -> Supabase bridge
│       └── pages/            # UI Screens (Scanner, Review, History, etc.)
│
├── web/                      # 💻 NEXT.JS WEB DASHBOARD (Admins & Viewers)
│   ├── src/app/              # App Router pages (Dashboard, Admin panel)
│   ├── src/context/          # Auth context (Supabase JWT integration)
│   └── src/lib/              # Utilities (PDF Generation, Supabase client)
│
├── backend/rule-engine/      # ⚙️ RULE ENGINE & ADAPTERS
│   ├── rules/                # Master JSON definition of LMPC rules
│   └── json_adapter.js       # Translates JSON into executable logic
│
├── ml/hf-classifier/         # 🧠 AI CATEGORY CLASSIFIER
│   └── classifier.py         # HuggingFace Transformer inference script
│
├── setup_supabase.js         # 🗄️ Database Schema & RLS policy setup script
└── README.md                 # You are here
```

---

## ⚠️ Hackathon Prototype vs. Production Reality

To deliver a working prototype within the hackathon timeframe, we made specific architectural choices for the demo. Here is a transparent breakdown of what is built for the demo vs. what the actual production implementation would entail:

### 1. AI Categorization (The `EcommerceClassifier` Dataset)
- **Demo State:** We are currently using a pre-trained Hugging Face transformer (`EcommerceClassifier`) as a Proof of Concept (PoC). This model was trained on generic e-commerce products (Amazon/Flipkart) and we use a script to map its 400+ generic buckets into LMPC-specific categories.
- **Production State:** In reality, the government would need a custom-trained lightweight TensorFlow Lite (TFLite) model specifically trained on Indian FMCG and Legal Metrology commodity classes, ensuring 99%+ accuracy for niche categories like "Paints & Varnishes" or "Cement".

### 2. Rule 7 Validation (Numeral & Letter Heights)
- **Demo State:** The current app uses OCR to extract text but relies on the officer's manual confirmation for font-size violations (e.g., checking if the MRP font is at least 4.0mm as mandated by Schedule Table 1).
- **Production State:** The production app will incorporate advanced Computer Vision (OpenCV). Officers will place a standard reference object (like an ID card or a 10-rupee coin) next to the label. The camera will use this reference to automatically calculate the exact millimeter height of the printed text, entirely automating Rule 7.

### 3. E-Commerce Declarations (Rule 6(10))
- **Demo State:** We simulate e-commerce compliance by allowing officers to upload a screenshot from an app like Blinkit or Amazon, which is then passed through the OCR engine.
- **Production State:** The production web dashboard will feature an automated Web Scraper API. Officers will simply paste an Amazon/Flipkart URL, and the system will scrape the listing to ensure mandatory declarations (Manufacturer details, Net Qty, MRP) are present on the digital product page before purchase.

### 4. Legal Notices & Workflow
- **Demo State:** The dashboard generates beautiful A4 PDF "Inspection Certificates".
- **Production State:** Integration with the state's actual e-Governance mail servers. When an Admin clicks "Flag Violation," the system will auto-generate a formal DOCX legal notice under the Legal Metrology Act and automatically dispatch it to the manufacturer's registered email address.

---

## ✅ Features Fully Implemented in this MVP

1. **100% Offline Mobile Core:** Camera, ML Kit OCR, and JSON Rule parsing work with zero internet.
2. **Local SQLite to Supabase Sync:** Graceful handling of network drops. Scans live on-device until internet is restored, then seamlessly push to the cloud.
3. **Role-Based Access Control (RBAC):** Supabase JWT authentication separating `ADMIN` (sees all state data) and `EMPLOYEE` (sees only their own field scans).
4. **Dynamic Next.js Analytics:** Web dashboard automatically calculates compliance rates, plots category distribution, and ranks "Top Violated Rules" in real-time based on synced mobile data.
5. **Barcode Integration:** ML Kit Barcode scanning instantly maps products to inspection logs.

---

## 🛠️ How to Run the App Locally

### 1. Database Setup
The backend runs on Supabase. To initialize the tables and Row Level Security (RLS) policies:
```bash
node setup_supabase.js
```

### 2. Mobile App (Flutter)
Ensure you have the Flutter SDK installed and an Android emulator running (or physical device connected via USB debugging).
```bash
cd app/rulescan_app/example
flutter pub get
flutter run
```
*Note: A compiled `rulescan.apk` is also available for direct download via the Web Dashboard.*

### 3. Web Dashboard (Next.js)
Ensure you have Node.js 18+ installed.
```bash
cd web
npm install
npm run dev
# Dashboard will be live at http://localhost:3000
```
