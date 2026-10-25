# **Dar al-Fajr Portal \- Six Documents**

System Specification & Software Requirement Documentation for **Dar al-Fajr Portal (بوابة دار الفجر)**.

# **1\. Product Requirements Document (PRD)**

* **Product name and one-sentence idea:** **Dar al-Fajr Portal (بوابة دار الفجر)** — A single-tenant management platform for the Dar al-Fajr Quran Center that digitizes Hifz weekly assignments, progress tracking, class schedules, and attendance across Arabic, Hebrew, and English.  
* **Target users:**  
  * **Dar al-Fajr Admins:** Manage the entire roster, classes, teacher assignments, and attendance audits from a desktop web browser.  
  * **Teachers:** Log group/1-on-1 attendance, grade weekly Hifz/Revision assignments, and write recitation feedback on mobile.  
  * **Parents:** Log in with a single email account to switch between all their enrolled children, check exact group and 1-on-1 arrival times, and track Quran memorization progress.  
  * **Students (with emails/phones):** View their own weekly Hifz homework, teacher notes, arrival schedule, and progress bars.  
* **Problem and current workaround:** Hifz assignments, evaluations, and attendance are currently tracked across fragmented spreadsheets, paper logs, and WhatsApp messages. Parents struggle to keep track of different arrival times across multiple children and tracks, and teachers spend too much time manually calculating student progress.  
* **Goal and success measure:** 100% of Dar al-Fajr Hifz students and teachers onboarded; 100% of weekly Hifz sessions and attendance logged in the app within 14 days of launch.  
* **Core features (v1.0 MVP):**  
  * **P0 \- Email Onboarding & First-Login Setup Gate:** Admin creates user accounts with an email and temporary password; on first login, the user is forced to set a new password and complete missing profile details.  
  * **P0 \- Admin Web Roster & Enrollment Manager:** Create Teachers, Parents, and Students (linked to Parents); create Groups across the 4 center tracks; assign group schedules and individual 1-on-1 arrival slots.  
  * **P0 \- Multi-Mode Attendance Tracker:** Teachers record Present (حاضر), Late (متأخر), or Absent (غائب) for group sessions and 1-on-1 slots.  
  * **P0 \- Hifz & Revision Assignment Engine:** Teachers assign weekly New Hifz (حفظ جديد) and Revision (مراجعة) by Surah and Ayah range, evaluate performance (Excellent / Good / Needs Repeat), and attach text notes for mistakes/feedback.  
  * **P1 \- Automated Progress Dashboard:** Calculates and displays memorized pages (out of 604), completed Surahs (out of 114), and Juz' progress (out of 30\) using local Quran metadata whenever a Hifz range is passed.  
  * **P1 \- Parent Child-Switcher & Arrival Schedule:** Unified chronological view showing a child's exact arrival times for both group classes and 1-on-1 sessions.  
  * **P1 \- Full Trilingual Localization:** Instant language switching between Arabic (ar), Hebrew (he), and English (en).  
* **Out of scope for version one:**  
  * Interactive Mushaf viewer and word/Ayah-level coordinate highlighting.  
  * Grading UIs for Qa'idah Nouraniah, Reading/Tajweed, and Tarbawi tracks.  
  * Google Sign-In OAuth and automated push notifications.

# **2\. Technical Requirements Document (TRD)**

| Component | Technical Specification |
| :---- | :---- |
| **Platforms** | Single Flutter codebase compiling to iOS, Android, and Responsive Web. |
| **Frontend and Hosting** | Flutter (Dart 3.x), flutter\_riverpod, go\_router, flutter\_localizations. Hosted via Firebase Hosting. |
| **Backend and Database** | Firebase Cloud Firestore (Single-tenant architecture). |
| **Authentication & Roles** | Firebase Auth Email & Password. Roles stored directly on the user's document in Firestore. |
| **External Services & APIs** | Local Quran Metadata Asset (`assets/data/quran_metadata.json`). |
| **Architecture** | Feature-first clean architecture. Secondary Firebase App Pattern for Admin account provisioning. |

# **3\. App Flow**

* **Entry points:** App Launch \-\> GoRouter Auth Guard \-\> Checks `FirebaseAuth.currentUser`.

## **Screen Inventory (v1.0)**

| Screen Name | Target Role | Primary Responsibility |
| :---- | :---- | :---- |
| **1\. LoginScreen** | All Users | Standard email and password authentication entry. |
| **2\. FirstLoginSetupScreen** | All New Users | Mandatory password reset and profile completion gate. |
| **3\. AdminShellScreen** | Admins | Web-optimized roster, group creation, and track assignments. |
| **4\. TeacherHomeScreen** | Teachers | Overview of assigned groups, daily schedules, and quick actions. |
| **5\. GroupDetailScreen** | Teachers | Class management, student list, and session entry. |
| **6\. AttendanceLoggingView** | Teachers | Multi-mode status entry (Present, Late, Absent). |
| **7\. StudentHifzModal** | Teachers | Interface to assign ranges, set grades, and attach notes. |
| **8\. ParentStudentHomeScreen** | Parents / Students | Consolidated view with child-switcher, schedule, and Hifz progress. |

# **4\. UI and UX Design Brief**

* **Audience and tone:** Community-focused, modern, trustworthy, and accessible.  
* **Color palette:**  
  * Primary Brand: Deep Forest / Emerald (`#0F2F28`, `#1A5342`)  
  * Accent: Muted Gold / Amber (`#D4AF37`)  
  * Backgrounds: Warm Neutral Slate (`#F8FAFC`, `#F0F4F2`)  
* **Typography:** Primary font Google Fonts **IBM Plex Sans** or **Rubik** for high-legibility multilingual support.  
* **Layout rules:** 100% Directional Layout mirroring to smoothly support Right-to-Left (Arabic, Hebrew) and Left-to-Right (English) dynamic rendering.

# **5\. Backend Schema (Cloud Firestore)**

* **Entities:**  
  1. `users`: Auth accounts containing user metadata and role flags.  
  2. `students`: Learner profiles, linking academic progress and personal information.  
  3. `groups`: Class structures organized by center track and assigned teacher.  
  4. `enrollments`: Mapping table linking individual students to specific groups and time slots.  
  5. `attendance_logs`: Daily/session-based records of attendance statuses.  
  6. `hifz_assignments`: Records of weekly Hifz and Revision ranges, evaluations, and teacher feedback.

# **6\. Implementation Plan (For Google Antigravity)**

## **Milestone Execution Breakdown**

* [x] **Milestone 1:** Project Foundation, Trilingual i18n Setup & Local Quran Engine integration.  
* [x] **Milestone 2:** Firebase Auth Configuration, Secondary App Provisioning & First-Login Setup Gate implementation.  
* [x] **Milestone 3:** Admin Web Portal Development (Roster management, Groups & Multi-Track Enrollments).  
* [x] **Milestone 4:** Teacher Workflows (Attendance Logging View & Hifz/Revision Assignment Engine).  
* [x] **Milestone 5:** Parent & Student Experience (Child Switcher, Chronological Arrival Schedule & Progress Dashboard UI).  
* [x] **Milestone 6:** Security & Deployment (Firestore Security Rules auditing, performance optimization, and Production Deployment).

## Git
For all Git, branching, and release operations, strictly follow the rules in ./GIT_WORKFLOW.md.
