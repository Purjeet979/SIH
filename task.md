# Phase 5: E-commerce Scanner (Section 25)
- [x] **Flutter Permissions**: Update `AndroidManifest.xml` and iOS `Info.plist` to allow picking images from the device gallery.
- [x] **Gallery Upload UI**: Add a new "Upload E-commerce Screenshot" button on the `home_page.dart` screen.
- [x] **Integration**: Use `image_picker` to select the screenshot, run it through the existing ML Kit OCR pipeline, and forward it to `ReviewPage` as Evidence.

# Phase 6: Barcode / QR Identification (Section 26)
- [x] **Barcode Scanner UI**: Add a "Scan Barcode" button in the App.
- [x] **ML Kit Integration**: Integrate Google ML Kit Barcode Scanning API to quickly fetch basic product metadata (Brand, Name) before doing OCR on the label.

# Phase 7: Reporting & PDF Generation (Section 27)
- [x] **PDF Generator Service**: Use Flutter's `pdf` or `printing` package to generate an A4 size "Inspection Summary" report.
- [x] **Report Structure**: Include Inspection Details, Product Information, Evidence Images, Extracted Declarations, Rule-wise Compliance, and Officer Decision.
- [x] **Export Options**: Add a "Download PDF" button in both the Flutter App's `HistoryPage` and the Next.js Web Dashboard.

# Phase 8: Advanced Web Dashboard (Section 28)
- [ ] **Analytics Overview**: Build graphical charts on the Next.js dashboard for Total Inspections (Passed vs Failed vs Manual Review).
- [ ] **Trend Tracking**: Add charts showing Brand, Category, and Region trends using a charting library like `chart.js` or `recharts`.
- [ ] **Search & Filters**: Implement search bars to filter inspections by Date, Category, Rule Number, or Officer ID.

# Phase 9: Security & Authentication (Section 29)
- [x] **JWT & Auth**: Implement Login page on the Next.js Dashboard and Flutter App with hardcoded Demo accounts and Supabase integration.
- [ ] **Backend Middleware**: Update `server.js` to require and verify JWT tokens for all `/api/*` endpoints.
- [x] **RBAC (Role Based Access Control)**: Add user roles (Officer vs Admin) with dedicated dashboard views and access restrictions.

# Phase 10: Error Handling & Edge Cases (Section 31)
- [ ] **Manual Fallbacks**: Implement manual crop UI if OCR fails on the first pass (for blurry images).
- [ ] **Graceful Degradation**: Ensure the app shows helpful UI error messages when ML Kit categorization confidence is too low.

# Phase 11: Final Hackathon Demo Polish (Section 38 & 41)
- [ ] **Performance Audit**: Ensure camera load time, OCR extraction, and rule evaluation occur within the 5-10 second benchmark.
- [ ] **UI/UX Cleanup**: Apply consistent colors, smooth transitions, and "Wow Factor" elements in the Flutter app and Next.js Dashboard.
- [ ] **Dry Run**: Conduct a full end-to-end demo exactly as described in Section 38 (Offline scan -> Turn off Wifi -> Verify -> Turn on Wifi -> Sync -> Dashboard).
