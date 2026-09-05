# RuleScan --- Implementation Plan

## 1. Project Overview

**Project:** RuleScan --- Offline-First Legal Metrology Compliance
Suite\
**Problem Statement:** SIH26034\
**Purpose:** Build an offline-first software system that scans
packaged-commodity labels/images and checks their compliance with the
Legal Metrology (Packaged Commodities) Rules, 2011.

RuleScan converts a product label into an **explainable, evidence-backed
compliance result** rather than producing a generic pass/fail warning.

The implementation follows the proposed architecture:

`Capture → Image Pre-processing → OCR → Vision/AI → Rule Engine → Validation → Human Review → Offline Storage → Background Sync`

The core inspection flow must work without internet connectivity.
Connectivity is required only for synchronization, rule-bundle updates,
authentication/session refresh where applicable, and dashboard access.

------------------------------------------------------------------------

# 2. Objectives

## Primary Objectives

1.  Scan a packaged-product label using a mobile camera or gallery
    image.
2.  Extract declarations using OCR.
3.  Identify the product category using an on-device classifier.
4.  Detect/estimate the Principal Display Panel (PDP) and
    reference-object scale where possible.
5.  Validate extracted information against versioned LMPC rules.
6.  Generate rule-numbered findings with confidence scores.
7.  Store inspection evidence locally when offline.
8.  Synchronize saved inspections when connectivity returns.
9.  Provide a web dashboard for inspection history, reports, search and
    analytics.
10. Support e-commerce screenshots/listings through the same OCR +
    rule-validation pipeline.

## Governance Objective

AI should identify and explain potential non-compliance. The officer
remains responsible for the legally actionable decision.

------------------------------------------------------------------------

# 3. High-Level System Architecture

``` text
                         ┌──────────────────────────┐
                         │      Mobile App           │
                         │        Flutter            │
                         └────────────┬─────────────┘
                                      │
                    ┌─────────────────▼─────────────────┐
                    │             CAPTURE               │
                    │ Camera / Gallery / E-commerce     │
                    │ Screenshot / Barcode / QR         │
                    └─────────────────┬─────────────────┘
                                      │
                    ┌─────────────────▼─────────────────┐
                    │       IMAGE PRE-PROCESSING        │
                    │ Crop • Deskew • Denoise • Resize  │
                    └─────────────────┬─────────────────┘
                                      │
                    ┌─────────────────▼─────────────────┐
                    │                OCR                 │
                    │ ML Kit Text Recognition v2         │
                    │ PaddleOCR / Tesseract fallback     │
                    └─────────────────┬─────────────────┘
                                      │
             ┌────────────────────────▼────────────────────────┐
             │                 VISION + AI                     │
             │ Category Classifier • PDP Detection •          │
             │ Reference Object / Geometry Estimation         │
             └────────────────────────┬────────────────────────┘
                                      │
                    ┌─────────────────▼─────────────────┐
                    │          RULE ENGINE               │
                    │ Versioned LMPC JSON Rule Bundle    │
                    └─────────────────┬─────────────────┘
                                      │
                    ┌─────────────────▼─────────────────┐
                    │          VALIDATION                │
                    │ Rule 6 • Rule 7 • Rules 8–9       │
                    │ Rules 11–13 • Rule 26 + exemptions│
                    └─────────────────┬─────────────────┘
                                      │
                    ┌─────────────────▼─────────────────┐
                    │         REVIEW SCREEN              │
                    │ Pass / Flag / Uncertain            │
                    │ Confidence + Evidence              │
                    │ Officer Confirmation                │
                    └─────────────────┬─────────────────┘
                                      │
                         ┌────────────▼────────────┐
                         │   Local Database        │
                         │     Isar / SQLite       │
                         └────────────┬────────────┘
                                      │
                              Network Available?
                              /                 \
                            NO                   YES
                            │                     │
                      Keep Offline         Background Sync
                                                  │
                                    ┌─────────────▼─────────────┐
                                    │      REST Backend          │
                                    │ JWT/RBAC + PostgreSQL      │
                                    └─────────────┬─────────────┘
                                                  │
                               ┌──────────────────┼──────────────────┐
                               │                  │                  │
                         Repository           Reports            Analytics
                         Search/History       PDF/DOCX         Brand/Region
```

------------------------------------------------------------------------

# 4. Recommended Repository Structure

``` text
rulescan/
│
├── mobile/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   ├── errors/
│   │   │   ├── utils/
│   │   │   └── security/
│   │   │
│   │   ├── data/
│   │   │   ├── local/
│   │   │   │   ├── database/
│   │   │   │   └── dao/
│   │   │   ├── remote/
│   │   │   └── repositories/
│   │   │
│   │   ├── features/
│   │   │   ├── capture/
│   │   │   ├── preprocessing/
│   │   │   ├── ocr/
│   │   │   ├── vision/
│   │   │   ├── rules/
│   │   │   ├── validation/
│   │   │   ├── review/
│   │   │   ├── sync/
│   │   │   └── reports/
│   │   │
│   │   └── main.dart
│   │
│   └── assets/
│       ├── models/
│       └── rules/
│
├── backend/
│   ├── src/
│   │   ├── auth/
│   │   ├── inspections/
│   │   ├── rules/
│   │   ├── reports/
│   │   ├── analytics/
│   │   ├── search/
│   │   └── sync/
│   └── migrations/
│
├── dashboard/
│   ├── app/
│   ├── components/
│   ├── services/
│   └── public/
│
├── rules/
│   ├── lmpc/
│   │   ├── v1/
│   │   │   ├── rule6.json
│   │   │   ├── rule7.json
│   │   │   ├── rules8_9.json
│   │   │   ├── rules11_13.json
│   │   │   └── rule26.json
│   │   └── manifest.json
│
├── ml/
│   ├── training/
│   ├── datasets/
│   └── exported/
│
└── docs/
    ├── API.md
    ├── RULE_ENGINE.md
    └── TESTING.md
```

------------------------------------------------------------------------

# 5. Mobile Application

## 5.1 Technology

-   Flutter for Android/cross-platform mobile application.
-   ML Kit Text Recognition v2 for primary OCR.
-   PaddleOCR/Tesseract as fallback.
-   TensorFlow Lite for category classification.
-   Isar or SQLite for local storage.
-   WorkManager/background task mechanism for synchronization.

The mobile application is the primary inspection client.

------------------------------------------------------------------------

# 6. Inspection Workflow

## Step 1 --- Capture

The officer selects:

-   Camera
-   Gallery
-   E-commerce screenshot
-   Product URL where supported
-   Barcode/QR scan

The app creates an `InspectionSession`.

``` json
{
  "inspectionId": "UUID",
  "createdAt": "ISO-8601",
  "sourceType": "CAMERA",
  "status": "PROCESSING",
  "syncStatus": "PENDING"
}
```

The original image must be preserved as evidence.

------------------------------------------------------------------------

# 7. Image Pre-processing

Before OCR:

1.  Detect image orientation.
2.  Crop irrelevant background.
3.  Correct perspective where possible.
4.  Deskew text.
5.  Denoise.
6.  Improve readability.
7.  Resize according to OCR requirements.
8.  Generate focused crops for difficult declarations.

Recommended OCR crops:

``` text
FULL LABEL
   │
   ├── MRP crop
   ├── Quantity crop
   ├── Manufacturer/address crop
   ├── Date crop
   ├── Consumer-care crop
   └── Other declarations
```

For low-confidence results, allow the officer to manually crop and
retry.

------------------------------------------------------------------------

# 8. OCR Pipeline

## Primary OCR

Use ML Kit Text Recognition v2.

## Fallback

If OCR confidence is below threshold:

``` text
ML Kit
   │
   ├── confidence >= threshold → accept
   │
   └── confidence < threshold
                │
                ▼
        PaddleOCR / Tesseract
                │
                ▼
          Merge candidates
```

OCR output should preserve:

-   Text
-   Bounding box
-   Line/paragraph relationship
-   Confidence
-   Detected language/script

Example:

``` json
{
  "text": "MRP ₹120.00",
  "confidence": 0.96,
  "bbox": {
    "left": 120,
    "top": 450,
    "width": 320,
    "height": 70
  },
  "source": "ML_KIT"
}
```

------------------------------------------------------------------------

# 9. Declaration Extraction

OCR text must be normalized before validation.

## Normalization

Perform:

-   Unicode normalization
-   Whitespace normalization
-   Currency normalization
-   Unit normalization
-   Date normalization
-   OCR-error correction for known patterns
-   Hindi/English equivalent handling

Example:

``` text
"MRP Rs. 120/-"
        ↓
MRP = 120
currency = INR
```

Use deterministic parsers wherever possible.

Do not allow an LLM to directly decide legal compliance.

------------------------------------------------------------------------

# 10. Product Category Classification

Use a TensorFlow Lite classifier.

Example categories:

``` text
FOOD
COSMETIC
HOUSEHOLD
PERSONAL_CARE
ELECTRONICS
OTHER
```

The model should return:

``` json
{
  "category": "FOOD",
  "confidence": 0.91
}
```

If confidence is below the configured threshold:

``` text
AI category uncertain
        ↓
Show manual category selector
        ↓
Officer selects category
        ↓
Rule engine continues
```

This avoids cascading errors from incorrect category classification.

------------------------------------------------------------------------

# 11. PDP and Reference-Object Detection

The implementation should estimate:

-   Principal Display Panel (PDP) region.
-   Declaration bounding boxes.
-   Reference-object dimensions when available.
-   Relative letter height.
-   Relative width/height of characters.

The MVP should use a controlled/reference-object workflow where physical
scale is required.

Example:

``` text
Reference Object
      ↓
Pixel-to-real-world scale
      ↓
Character bounding-box height
      ↓
Estimated physical letter height
      ↓
Rule 7 validation
```

If reliable scale cannot be established, the result should be:

`UNCERTAIN — MANUAL VERIFICATION REQUIRED`

rather than a definitive violation.

------------------------------------------------------------------------

# 12. Rule Engine

The rule engine is the core legal-validation component.

Rules must be represented as versioned JSON rather than hard-coded
throughout the application.

## Example Rule Schema

``` json
{
  "ruleId": "LMPC-6-MRP",
  "ruleNumber": "6",
  "title": "Maximum Retail Price declaration",
  "version": "2011-amendments-v1",
  "category": ["ALL"],
  "checkType": "REQUIRED_DECLARATION",
  "field": "mrp",
  "severity": "HIGH",
  "enabled": true
}
```

------------------------------------------------------------------------

# 13. Rule Evaluation Model

Every rule should return a structured result.

``` json
{
  "ruleId": "LMPC-6-MRP",
  "status": "PASS",
  "confidence": 0.96,
  "message": "MRP declaration detected.",
  "evidence": {
    "text": "MRP ₹120.00",
    "bbox": [120, 450, 320, 70]
  }
}
```

Possible statuses:

``` text
PASS
FAIL
UNCERTAIN
NOT_APPLICABLE
MANUAL_REVIEW
```

The final inspection result should never simply be:

`COMPLIANT / NON-COMPLIANT`

Instead:

``` text
Overall status
+
individual rule results
+
confidence
+
evidence
+
officer decision
```

------------------------------------------------------------------------

# 14. Rule Coverage for MVP

The proposed implementation should prioritize the rules identified in
the solution architecture.

## Rule 6 --- Declarations

Check the presence/extraction of applicable declarations such as:

-   Name/address
-   Country of origin
-   MRP
-   Quantity
-   Relevant dates
-   Consumer-care information
-   Required GM-related declarations
-   Veg/non-veg declarations where applicable

## Rule 7 --- PDP / Font Requirements

Validate:

-   Letter-height requirements.
-   Width/height characteristics where applicable.
-   PDP-area relationship.
-   Special treatment for blown/molded surfaces where applicable.

## Rules 8--9

Validate:

-   Placement
-   Clear space
-   Legibility
-   Contrast
-   Hindi/English language requirements

## Rules 11--13

Validate:

-   Quantity units
-   Applicable Fourth Schedule unit types
-   Prohibited/misleading words

## Rule 26 + Exemptions

Determine:

-   Applicability
-   Exemption conditions
-   Rule 26-related checks
-   Relevant exemptions

## Rule 6(10)

For e-commerce mode, validate whether applicable declarations are
displayed in the listing.

The exact legal conditions should be maintained in the rule bundle and
updated when the governing requirements change.

------------------------------------------------------------------------

# 15. Rule Engine Execution

``` text
Inspection Input
      │
      ▼
Category
      │
      ▼
Applicability Resolver
      │
      ├── Exempt → mark NOT_APPLICABLE
      │
      └── Applicable
             │
             ▼
       Rule Selection
             │
             ▼
       Rule Evaluation
             │
       ┌─────┼─────────┐
       ▼     ▼         ▼
     PASS   FAIL    UNCERTAIN
       │     │         │
       └─────┴─────────┘
             │
             ▼
       Evidence Builder
             │
             ▼
       Confidence Scoring
```

------------------------------------------------------------------------

# 16. Confidence Scoring

Confidence should be based on measurable signals rather than a
subjective AI score.

Example:

``` text
OCR confidence                 40%
Field extraction confidence    20%
Bounding-box confidence        15%
Category confidence            10%
Rule-condition confidence      15%
```

Example calculation:

``` text
finalConfidence =
    0.40 * ocrConfidence +
    0.20 * extractionConfidence +
    0.15 * bboxConfidence +
    0.10 * categoryConfidence +
    0.15 * ruleConfidence
```

Thresholds:

``` text
>= 0.85  → High confidence
0.60–0.84 → Medium confidence
< 0.60   → Manual review
```

These values should remain configurable and must be calibrated using
validation data.

------------------------------------------------------------------------

# 17. Evidence Model

Every finding should retain evidence.

``` json
{
  "findingId": "UUID",
  "inspectionId": "UUID",
  "ruleId": "LMPC-6-MRP",
  "status": "FAIL",
  "confidence": 0.88,
  "evidence": {
    "imageId": "UUID",
    "crop": "mrp_crop.jpg",
    "ocrText": "MRP ₹120.00",
    "bbox": [100, 200, 300, 80]
  }
}
```

Evidence should also include:

-   Timestamp
-   GPS coordinates where permitted
-   Officer/device identifier
-   Rule-bundle version
-   Application version
-   Original image hash
-   Sync status

This makes inspection records auditable.

------------------------------------------------------------------------

# 18. Human Review

The review screen should display:

``` text
PRODUCT
Category: Food
OCR confidence: 94%

RULE RESULTS

✓ Rule 6 — MRP declaration
  PASS — 96%

✗ Rule 7 — Letter-height requirement
  FAIL — 82%

⚠ Rule 8 — Placement
  MANUAL REVIEW — 58%

[View Evidence]
[Accept Finding]
[Reject Finding]
[Request Re-scan]
```

The officer can:

-   Confirm
-   Reject
-   Mark for manual verification
-   Re-capture image
-   Change category
-   Add remarks

The AI must not issue an automatically legally actionable notice.

------------------------------------------------------------------------

# 19. Offline-First Storage

All critical inspection data must be stored locally.

Recommended local entities:

``` text
Inspection
ImageEvidence
OCRResult
Product
Declaration
RuleResult
OfficerDecision
SyncQueue
RuleBundle
```

## Sync Queue

``` json
{
  "operationId": "UUID",
  "entityType": "INSPECTION",
  "entityId": "UUID",
  "operation": "CREATE",
  "retryCount": 0,
  "status": "PENDING"
}
```

When network becomes available:

``` text
PENDING
   ↓
UPLOAD
   ↓
SERVER ACK
   ↓
SYNCED
```

Failed uploads should use retry with exponential backoff.

------------------------------------------------------------------------

# 20. Sync Conflict Handling

For multi-officer environments:

-   Use immutable inspection IDs.
-   Use server timestamps.
-   Use client-generated UUIDs.
-   Make upload operations idempotent.
-   Store a rule-bundle version with each inspection.
-   Never overwrite historical inspection evidence silently.

For duplicate sync requests:

``` text
same inspectionId
      ↓
server checks existing record
      ↓
already exists → return existing record
```

This prevents duplicate inspections during unstable connectivity.

------------------------------------------------------------------------

# 21. Rule Bundle Versioning

Rules should be distributed as signed/versioned JSON bundles.

``` text
Rule Bundle
├── bundleId
├── version
├── effectiveFrom
├── sourceReference
├── rules[]
└── checksum
```

Example:

``` json
{
  "bundleId": "LMPC",
  "version": "2026.01",
  "effectiveFrom": "2026-01-01",
  "checksum": "SHA256..."
}
```

The mobile application can continue using the last valid rule bundle
offline.

When connectivity returns:

``` text
Server
  ↓
New rule bundle available?
  ↓
Download
  ↓
Verify checksum/signature
  ↓
Store locally
  ↓
Activate
```

Historical inspections retain the rule version that was used when they
were performed.

------------------------------------------------------------------------

# 22. Backend

## Suggested Stack

``` text
REST API
PostgreSQL
JWT Authentication
RBAC
Object Storage
Search Index / PostgreSQL Full Text Search
```

## Core API

``` text
POST   /auth/login
GET    /rules/current
GET    /rules/{version}
POST   /sync/inspections
POST   /sync/evidence
GET    /inspections
GET    /inspections/{id}
GET    /inspections/{id}/report
GET    /analytics/brands
GET    /analytics/regions
GET    /search
```

------------------------------------------------------------------------

# 23. RBAC

Recommended roles:

``` text
OFFICER
ADMIN
REGULATOR
```

Example permissions:

  Action                     Officer   Admin   Regulator
  ------------------------ --------- ------- -----------
  Create inspection              Yes     Yes    Optional
  Review own inspections         Yes     Yes         Yes
  View all inspections            No     Yes         Yes
  Manage rule bundles             No     Yes         Yes
  View analytics             Limited     Yes         Yes
  Manage users                    No     Yes          No

------------------------------------------------------------------------

# 24. Database Design

## inspections

``` text
id
officer_id
product_id
source_type
category
captured_at
latitude
longitude
overall_status
officer_decision
rule_bundle_version
created_at
updated_at
```

## products

``` text
id
brand
product_name
manufacturer
category
quantity
mrp
origin
```

## rule_results

``` text
id
inspection_id
rule_id
rule_number
status
confidence
message
evidence_id
officer_override
remarks
```

## evidence

``` text
id
inspection_id
image_uri
image_hash
ocr_text
bbox_data
captured_at
```

------------------------------------------------------------------------

# 25. E-commerce Scanner

The same processing pipeline should be reused.

``` text
URL / Screenshot
       ↓
Page/List Image
       ↓
Image Extraction
       ↓
OCR
       ↓
Declaration Extraction
       ↓
Category
       ↓
Rule Engine
       ↓
Rule 6(10) + applicable checks
       ↓
Review
```

If URL ingestion is not reliable for the MVP, screenshot upload should
be implemented first.

For poor-quality listing images:

`Manual crop → OCR retry → review`

------------------------------------------------------------------------

# 26. Barcode / QR

Use the ML Kit Barcode API.

Barcode scanning should help:

-   Identify the product.
-   Link repeated inspections.
-   Speed up product retrieval.
-   Associate multiple images with one inspection.

Barcode data should be treated as an identifier, not as proof of legal
compliance.

------------------------------------------------------------------------

# 27. Reporting

Generate:

-   Inspection summary
-   Product details
-   Captured evidence
-   OCR extraction
-   Rule-by-rule results
-   Confidence scores
-   Officer decision
-   Remarks
-   Rule-bundle version
-   Timestamp/GPS metadata where applicable

Formats:

``` text
PDF
DOCX
```

Report structure:

``` text
1. Inspection Details
2. Product Information
3. Evidence Images
4. Extracted Declarations
5. Rule-wise Compliance
6. Uncertain/Manual Review Items
7. Officer Decision
8. Audit Metadata
```

------------------------------------------------------------------------

# 28. Dashboard

Dashboard modules:

``` text
┌─────────────────────────────────────┐
│ Overview                            │
├─────────────────────────────────────┤
│ Total Inspections                  │
│ Passed │ Failed │ Manual Review    │
├─────────────────────────────────────┤
│ Recent Inspections                 │
├─────────────────────────────────────┤
│ Brand / Category / Region Trends   │
├─────────────────────────────────────┤
│ Repeat Offender Insights           │
└─────────────────────────────────────┘
```

Search filters:

-   Date
-   Brand
-   Category
-   Region
-   Rule number
-   Compliance status
-   Officer
-   Product

------------------------------------------------------------------------

# 29. Security

Minimum requirements:

1.  JWT-based authentication.
2.  RBAC authorization.
3.  TLS for synchronization.
4.  Encrypted local sensitive data where appropriate.
5.  Evidence integrity using SHA-256 hashes.
6.  Audit logs for officer decisions and administrative changes.
7.  No silent modification of historical inspection results.
8.  Rule bundle integrity verification.
9.  Session expiration/refresh.
10. Server-side authorization on every protected API.

------------------------------------------------------------------------

# 30. Privacy

Only collect information required for inspection and auditing.

For location:

``` text
GPS → inspection metadata
```

The system should clearly distinguish:

-   Required inspection evidence
-   Optional metadata
-   Personally identifiable information

Access to inspection records should be controlled by RBAC.

------------------------------------------------------------------------

# 31. Error Handling

The app must remain useful even when individual components fail.

## OCR failure

``` text
OCR failed
 ↓
Fallback OCR
 ↓
Manual crop
 ↓
Manual review
```

## Category failure

``` text
Low category confidence
 ↓
Manual category selection
```

## Scale/PDP failure

``` text
Unable to establish scale
 ↓
Do not issue definitive font-size failure
 ↓
Manual verification
```

## Network failure

``` text
No internet
 ↓
Continue inspection
 ↓
Save locally
 ↓
Sync later
```

------------------------------------------------------------------------

# 32. MVP Implementation Order

## Phase 1 --- Core Demo

Implement first:

1.  Flutter camera/gallery.
2.  Image preprocessing.
3.  ML Kit OCR.
4.  Declaration extraction.
5.  Basic product category selection/classification.
6.  JSON rule engine.
7.  Rule 6 checks.
8.  Rule 26/exemption logic.
9.  Basic Rule 7 font-height workflow.
10. Local storage.
11. Inspection result screen.

This is the minimum end-to-end demonstrable system.

## Phase 2 --- Accuracy + Evidence

Add:

1.  PDP detection.
2.  Reference-object workflow.
3.  Improved confidence scoring.
4.  Evidence crops.
5.  Rules 8--9.
6.  Rules 11--13.
7.  Multi-script OCR improvements.
8.  Human-review workflow.

## Phase 3 --- Connected Platform

Add:

1.  REST backend.
2.  PostgreSQL.
3.  JWT/RBAC.
4.  Background sync.
5.  Rule bundle synchronization.
6.  Search/history.
7.  PDF/DOCX reports.
8.  Web dashboard.

## Phase 4 --- Advanced Features

Add:

1.  E-commerce URL/screenshot scanner.
2.  Barcode/QR.
3.  Batch self-audit.
4.  Multi-officer synchronization.
5.  Brand/category/region analytics.
6.  Repeat-offender insights.
7.  Citizen-facing layer where approved.
8.  Extensibility toward other compliance frameworks.

------------------------------------------------------------------------

# 33. Suggested Flutter Feature Modules

``` text
features/
├── capture/
│   ├── camera_screen.dart
│   ├── gallery_picker.dart
│   └── capture_controller.dart
│
├── ocr/
│   ├── ocr_service.dart
│   ├── mlkit_ocr.dart
│   ├── fallback_ocr.dart
│   └── ocr_result.dart
│
├── vision/
│   ├── pdp_detector.dart
│   ├── scale_estimator.dart
│   └── category_classifier.dart
│
├── rules/
│   ├── rule_engine.dart
│   ├── rule_loader.dart
│   ├── applicability_resolver.dart
│   └── models/
│
├── validation/
│   ├── declaration_validator.dart
│   ├── quantity_validator.dart
│   ├── mrp_validator.dart
│   ├── date_validator.dart
│   └── placement_validator.dart
│
├── review/
│   ├── result_screen.dart
│   ├── finding_card.dart
│   └── officer_decision.dart
│
└── sync/
    ├── sync_manager.dart
    ├── sync_queue.dart
    └── connectivity_service.dart
```

------------------------------------------------------------------------

# 34. Pseudocode --- End-to-End Scan

``` text
function inspectProduct(image):

    inspection = createInspection(image)

    processedImage = preprocess(image)

    ocrResult = runMLKitOCR(processedImage)

    if ocrResult.confidence < OCR_THRESHOLD:
        fallbackResult = runFallbackOCR(processedImage)
        ocrResult = mergeOCRResults(ocrResult, fallbackResult)

    declarations = extractDeclarations(ocrResult)

    category = classifyCategory(processedImage)

    if category.confidence < CATEGORY_THRESHOLD:
        category = requestManualCategory()

    pdp = detectPDP(processedImage)

    scale = estimateScale(processedImage, pdp)

    ruleBundle = loadLocalRuleBundle()

    applicability = resolveApplicability(
        category,
        declarations,
        ruleBundle
    )

    results = []

    for rule in applicableRules(ruleBundle, applicability):

        result = evaluateRule(
            rule,
            declarations,
            ocrResult,
            pdp,
            scale,
            category
        )

        results.append(result)

    confidence = calculateOverallConfidence(results)

    inspectionResult = buildInspectionResult(
        inspection,
        declarations,
        category,
        results,
        confidence
    )

    saveLocally(inspectionResult)

    queueForSync(inspectionResult)

    return inspectionResult
```

------------------------------------------------------------------------

# 35. Pseudocode --- Rule Engine

``` text
function evaluateRule(rule, context):

    if rule.condition == NOT_APPLICABLE:
        return NOT_APPLICABLE

    extractedValue = context.get(rule.field)

    if rule.type == REQUIRED_DECLARATION:

        if extractedValue exists:
            return PASS

        if extractionConfidence < threshold:
            return UNCERTAIN

        return FAIL

    if rule.type == NUMERIC_RANGE:
        return compare(extractedValue, rule.constraints)

    if rule.type == TEXT_PATTERN:
        return regexMatch(extractedValue, rule.pattern)

    if rule.type == PLACEMENT:
        return validatePlacement(
            context.boundingBox,
            rule.constraints
        )

    if rule.type == FONT_HEIGHT:
        if context.scale unavailable:
            return MANUAL_REVIEW

        return validateFontHeight(
            context.characterHeight,
            context.pdpArea,
            rule.constraints
        )
```

------------------------------------------------------------------------

# 36. Testing Strategy

## Unit Tests

Test:

-   OCR normalization
-   MRP parsing
-   Quantity parsing
-   Date parsing
-   Unit normalization
-   Rule evaluation
-   Applicability/exemption logic
-   Confidence scoring

## Integration Tests

Test:

``` text
Image → OCR → Extraction → Rule Engine → Result
```

## Offline Tests

Disable network and verify:

-   Scan works.
-   OCR works.
-   Rules execute.
-   Results are saved.
-   Evidence is retained.
-   Sync queue is populated.

## Sync Tests

Test:

-   Network recovery.
-   Duplicate uploads.
-   Failed upload retry.
-   Partial upload.
-   Rule-bundle update.
-   Multi-officer conflict cases.

## UI Tests

Test:

-   Camera permissions.
-   Capture.
-   Review.
-   Manual crop.
-   Manual category.
-   Officer confirmation.
-   Report generation.

------------------------------------------------------------------------

# 37. Accuracy Evaluation

Build a labeled test dataset containing:

``` text
Compliant labels
Non-compliant labels
Low-quality images
Reflective packaging
Curved packaging
Hindi/English labels
Mixed-script labels
Different product categories
E-commerce screenshots
```

Measure:

-   OCR character/word accuracy.
-   Declaration extraction precision/recall.
-   Category accuracy.
-   Rule-level precision/recall.
-   False-positive rate.
-   False-negative rate.
-   Manual-review rate.

The system should prioritize **explainability and controlled
uncertainty** over artificially high accuracy claims.

------------------------------------------------------------------------

# 38. Hackathon Demo Flow

Recommended live demo:

``` text
1. Open RuleScan
        ↓
2. Select/photograph packaged product
        ↓
3. Show OCR extraction
        ↓
4. Show detected category
        ↓
5. Show rule engine processing
        ↓
6. Show Rule 6 / Rule 7 findings
        ↓
7. Tap a finding
        ↓
8. Show exact evidence crop
        ↓
9. Show confidence score
        ↓
10. Officer confirms result
        ↓
11. Turn off internet
        ↓
12. Perform another scan
        ↓
13. Show that result is still generated
        ↓
14. Restore internet
        ↓
15. Show background synchronization
        ↓
16. Open web dashboard
        ↓
17. Search inspection
        ↓
18. Generate PDF report
```

This demonstrates the project's strongest differentiators:

-   Offline-first operation
-   Rule-numbered explainability
-   Evidence-backed findings
-   Human-in-the-loop validation
-   Searchable inspection history
-   Scalable backend

------------------------------------------------------------------------

# 39. Deployment

## Mobile

``` text
Android APK / AAB
```

The MVP should target Android first because the field-inspection use
case is mobile-centric.

## Backend

Deploy as:

``` text
API Server
+
PostgreSQL
+
Object Storage
```

## Dashboard

Deploy the React/Next.js dashboard separately from the API.

------------------------------------------------------------------------

# 40. Environment Configuration

``` text
.env

API_BASE_URL=
JWT_SECRET=
DATABASE_URL=
STORAGE_BUCKET=
RULE_BUNDLE_PUBLIC_KEY=
```

Secrets must never be committed to Git.

------------------------------------------------------------------------

# 41. Performance Targets for MVP

Target rather than claim as measured performance:

``` text
Image preprocessing       < 1–2 sec
OCR                       < 3–5 sec
Rule evaluation            < 1 sec
Local save                 < 500 ms
Total normal scan          ~5–10 sec
```

Actual values should be benchmarked on the target Android hardware.

------------------------------------------------------------------------

# 42. Key Design Decisions

## Decision 1 --- Deterministic Rule Engine

Legal requirements should be represented as explicit rules rather than
delegated to an LLM.

## Decision 2 --- AI as an Assistant

AI/OCR provides extraction, classification and visual estimates. The
rule engine determines the structured rule outcome.

## Decision 3 --- Human-in-the-Loop

Low-confidence findings require officer review.

## Decision 4 --- Offline by Default

Inspection should never depend on continuous internet access.

## Decision 5 --- Version Everything

Every inspection stores:

``` text
App version
Rule-bundle version
Model version
Inspection timestamp
Evidence hash
```

This is important for auditability.

------------------------------------------------------------------------

# 43. Final MVP Architecture

``` text
              ┌─────────────────────────┐
              │       Flutter App       │
              └────────────┬────────────┘
                           │
             ┌─────────────▼─────────────┐
             │ Camera / Gallery / Screen  │
             └─────────────┬─────────────┘
                           │
             ┌─────────────▼─────────────┐
             │ Preprocessing              │
             └─────────────┬─────────────┘
                           │
             ┌─────────────▼─────────────┐
             │ ML Kit OCR + Fallback      │
             └─────────────┬─────────────┘
                           │
             ┌─────────────▼─────────────┐
             │ Declaration Extraction     │
             │ + Category Classification  │
             └─────────────┬─────────────┘
                           │
             ┌─────────────▼─────────────┐
             │ PDP / Scale / Vision       │
             └─────────────┬─────────────┘
                           │
             ┌─────────────▼─────────────┐
             │ Versioned LMPC Rule Engine │
             └─────────────┬─────────────┘
                           │
             ┌─────────────▼─────────────┐
             │ Confidence + Evidence     │
             └─────────────┬─────────────┘
                           │
             ┌─────────────▼─────────────┐
             │ Officer Review             │
             └─────────────┬─────────────┘
                           │
                    ┌──────▼──────┐
                    │ Isar/SQLite │
                    └──────┬──────┘
                           │
                    Network Available
                           │
                    ┌──────▼──────┐
                    │ Sync API     │
                    └──────┬──────┘
                           │
              ┌────────────▼────────────┐
              │ Backend + PostgreSQL    │
              └────────────┬────────────┘
                           │
          ┌────────────────┼─────────────────┐
          │                │                 │
      Dashboard         Reports          Analytics
```

------------------------------------------------------------------------

# 44. Implementation Priority

If development time is limited, implement in this exact order:

``` text
P0 — Must Have
├── Flutter app
├── Camera/gallery
├── ML Kit OCR
├── OCR normalization
├── Declaration extraction
├── JSON rule engine
├── Rule 6
├── Basic Rule 7
├── Local database
└── Explainable result screen

P1 — Strong Demo Features
├── Confidence scoring
├── Evidence bounding boxes/crops
├── Offline mode
├── Manual review
├── Rule 26/exemptions
├── Hindi/English handling
└── Background sync

P2 — Platform Features
├── Backend
├── PostgreSQL
├── JWT/RBAC
├── Dashboard
├── PDF/DOCX reports
├── Search/history
└── Rule-bundle updates

P3 — Scale Features
├── Rules 8–9
├── Rules 11–13
├── E-commerce scanner
├── Barcode/QR
├── Batch self-audit
├── Analytics
└── Multi-officer sync
```

------------------------------------------------------------------------

# 45. Important Implementation Constraint

Do not present the prototype as a legal authority or claim that an
AI-generated result itself establishes a statutory violation.

The system should explicitly communicate:

> **RuleScan identifies and explains potential non-compliance. The
> authorized officer makes the legally actionable decision.**

This keeps the product architecture aligned with the governance
principle and reduces the risk of false-positive automated enforcement.

------------------------------------------------------------------------

# 46. Source Basis

This implementation plan is derived from the team's submitted RuleScan
concept and architecture, including the offline-first mobile pipeline,
rule-numbered LMPC engine, PDP/reference-object validation, e-commerce
scanning, human review, versioned rules, dashboard/backend architecture,
and phased MVP roadmap.

The source identifies the proposed mobile flow as Capture → Prep + OCR →
Vision + AI → Rule Engine → Validate → Review → Sync, with stages 01--06
executing on-device. It also specifies Flutter, ML Kit Text Recognition
v2, PaddleOCR/Tesseract fallback, TFLite, Isar/SQLite, React/Next.js,
JWT/RBAC, REST API, PostgreSQL/Firebase and PDF/DOCX reporting as the
proposed technology stack.

The submitted roadmap defines the MVP around offline scanning,
multi-script OCR, Rule 6 declarations, basic AI category classification,
Rule 3/26 exemptions, Rule 7 font-height checks, local storage and sync,
followed by scale-up and public rollout phases.
