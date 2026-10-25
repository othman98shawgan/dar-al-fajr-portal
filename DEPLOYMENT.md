# **Production Deployment & Security Guide**
### Dar al-Fajr Portal (بوابة دار الفجر لتعليم القرآن الكريم)

This document specifies the production security audit, deployment procedures, and performance optimization guidelines for **Dar al-Fajr Portal**.

---

## 1. Security & RBAC Configuration

### Firestore Security Rules (`firestore.rules`)
All database operations are governed by strict Role-Based Access Control (RBAC):
- **Admins:** Full access to manage users, groups, enrollments, and academic records.
- **Teachers:** Can log attendance and evaluate Hifz assignments; restricted to updating student progress arrays (`memorizedPages`, `completedSurahs`, `completedJuz`, `updatedAt`) without modifying user identities or parent relationships.
- **Parents:** Read-only access to linked children, attendance logs, and assignments; write access restricted strictly to signing weekly assignments (`parentAcknowledged` and `acknowledgedAt`).
- **Students:** Read-only access to their own assignments, arrival schedules, and memorization progress.

### Deploying Firestore Security Rules and Indexes
To deploy rules and composite query indexes:
```bash
firebase deploy --only firestore:rules,firestore:indexes
```

---

## 2. Web Production Build & Optimization

The web app is optimized for desktop administrative workflows (Admin Web Roster) and responsive mobile tabs for parents and teachers.

### Web Optimization Highlights
- **Service Worker & Cache Headers:** Static assets are cached immutably for 1 year (`assets/**`), while `index.html` and service workers are served with `no-cache` to ensure instant updates.
- **Typography & RTL:** Font preconnects for Google Fonts (`IBM Plex Sans Arabic`, `Rubik`) configured in `web/index.html` with native RTL layout support.
- **PWA Ready:** Manifest configured with high-resolution icons and `#0F2F28` theme branding.

### Building for Web Production
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build optimized Web release
flutter build web --release --base-href "/"
```

### Deploying to Firebase Hosting
```bash
# Deploy hosting
firebase deploy --only hosting
```
Hosting rewrites all route requests to `/index.html` to support client-side routing via GoRouter.

---

## 3. Mobile Production Builds

### Android (AAB / APK)
```bash
# Production Android App Bundle for Google Play
flutter build appbundle --release

# Production APK for direct distribution
flutter build apk --release
```

### iOS
```bash
# Production iOS Archive
flutter build ipa --release
```

---

## 4. Pre-Deployment Verification Checklist

Before releasing updates to production:
- [x] Run `flutter analyze` — ensure zero issues.
- [x] Run `flutter test` — ensure all unit and widget tests pass.
- [x] Verify Firebase options in `lib/firebase_options.dart`.
- [x] Audit `firestore.rules` against all new collections or fields.
- [x] Verify localized copy across Arabic, Hebrew, and English.
