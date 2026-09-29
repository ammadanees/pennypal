# PennyPal Feature Implementation Log & Progress Tracker

> **Purpose:** This document tracks all features, architectural improvements, and visual polish added to **PennyPal** on a day-to-day basis. Each entry documents the implementation date, technical architecture, files involved, and student user experience impact.
>
> **Maintenance Rule:** As development progresses each day, prepend or append new entries under their respective implementation date with full technical and UX details.

---

## Quick Chronological Index

| Date | Category | Key Deliverables |
| :--- | :--- | :--- |
| **2026-09-29** | 💳 Payment Cards & UI | Dedicated `CardsScreen` (`/cards`), Edit Card & Palette Switcher, 3D Mockup |
| **2026-09-29** | 🤝 Student Features | Borrow & Lend Tracker ("Udhaar" / Debt Log) + WhatsApp/SMS Reminders |
| **2026-09-29** | 🔄 Student Features | Subscriptions & Fixed Expenses Tracker + 1-Tap "Pay & Log Expense" |
| **2026-09-29** | 💱 Core Financials | Global Currency Sync, Zero-Bug Formatting Audit, Cold-boot Persistence |
| **2026-09-29** | 🎉 Visual Polish | Milestone Confetti Celebration Dialog (Physics Particle System) |
| **2026-09-29** | 🛡️ Security & Cloud | Firestore Rules update for `/debts` & `/subscriptions` + Resilient Error States |
| **2026-09-29** | 🐛 Architecture Bug | Resolved Multiple Heroes / Duplicate Default FAB Tag Collision |

---

## [2026-09-29] Daily Progress & Feature Releases

### 1. 💳 Interactive 3D Payment Cards & Dedicated Management Screen
* **Problem Solved:** Students could previously only add cards during transaction entry with no way to customize existing cards, switch gradient palettes, view card details, or manage/delete them.
* **Architecture & Technical Details:**
  * **Domain:** Added `PaymentCard.copyWith()` and `PaymentCard.cardGradients` containing 5 curated gradients (`cyberEmerald`, `midnightBlue`, `crimsonObsidian`, `auroraPurple`, `sunsetGold`) in [payment_card.dart](file:///c:/flutterprojects/pennypal/lib/features/cards/domain/payment_card.dart).
  * **Edit Mode:** Upgraded [add_card_sheet.dart](file:///c:/flutterprojects/pennypal/lib/features/cards/presentation/add_card_sheet.dart) with `existingCard` parameter. Automatically pre-populates fields, shows dynamic title ("Edit Payment Card") and button ("Save Changes"), and preserves original card creation dates.
  * **Dedicated Cards Screen:** Created [cards_screen.dart](file:///c:/flutterprojects/pennypal/lib/features/cards/presentation/cards_screen.dart) (`/cards`). Features:
    * Realistic 3D glassmorphic card graphic with radial gradients, golden chip illustration, contactless waves icon, masked card digits (`•••• •••• •••• 4128`), and cardholder nickname.
    * Capacity indicator badge (e.g. "1 of 2 cards added") respecting `CardRepository.maxCardsPerUser`.
    * **Edit & Change Color** action: Opens live palette switcher and field editor.
    * **Remove Card** action: Built-in safety confirmation dialog (`confirmAction`) and instant deletion.
  * **Navigation Wiring:**
    * Registered `AppRoutes.cards` (`/cards`) in [routes.dart](file:///c:/flutterprojects/pennypal/lib/app/routes.dart) and [router.dart](file:///c:/flutterprojects/pennypal/lib/app/router.dart).
    * Added **Payment Cards & Wallets** tile in [more_screen.dart](file:///c:/flutterprojects/pennypal/lib/features/shell/presentation/more_screen.dart).
    * Added quick **Manage** button in [card_selector_view.dart](file:///c:/flutterprojects/pennypal/lib/features/cards/presentation/card_selector_view.dart) header.

---

### 2. 🤝 Student Borrow & Lend Tracker ("Udhaar" / Debt Log)
* **Problem Solved:** Campus life involves frequent informal loans between roommates, study groups, and classmates. Students lacked an organized way to track who owes what without awkward manual reminders.
* **Architecture & Technical Details:**
  * **Domain & Data:** Created [debt_record.dart](file:///c:/flutterprojects/pennypal/lib/features/debts/domain/debt_record.dart) and [debt_repository.dart](file:///c:/flutterprojects/pennypal/lib/features/debts/data/debt_repository.dart). Supports `DebtType.lent` and `DebtType.borrowed`, amounts, person names, dates, notes, and settled timestamps.
  * **User Interface:** Created [debt_tracker_screen.dart](file:///c:/flutterprojects/pennypal/lib/features/debts/presentation/debt_tracker_screen.dart) (`/debts`) and [add_debt_sheet.dart](file:///c:/flutterprojects/pennypal/lib/features/debts/presentation/add_debt_sheet.dart).
    * **Net Balance Hero Card:** Color-coded net indicator showing total money to receive vs. total money to pay.
    * **Filter Chips:** Easily toggle between *Active*, *Owed to You (Lent)*, *You Owe (Borrowed)*, and *Settled*.
    * **1-Tap WhatsApp/SMS Friendly Reminder:** Integrates `share_plus` (`Share.share`) to compose a polite, pre-formatted reminder including person name, exact amount with user currency, and note.
    * **1-Tap Settle:** Toggle debts as settled or reopen them with haptic feedback.
  * **Navigation:** Added to Quick Shortcuts on Home Screen and under Tools in More Screen.

---

### 3. 🔄 Subscriptions & Fixed Expenses Tracker
* **Problem Solved:** Recurring student commitments (hostel fees, campus bus passes, Spotify Student, 4G data packs) were easy to forget or required manual re-entry every month.
* **Architecture & Technical Details:**
  * **Domain & Data:** Created [subscription_record.dart](file:///c:/flutterprojects/pennypal/lib/features/subscriptions/domain/subscription_record.dart) and [subscription_repository.dart](file:///c:/flutterprojects/pennypal/lib/features/subscriptions/data/subscription_repository.dart).
  * **User Interface:** Created [subscriptions_screen.dart](file:///c:/flutterprojects/pennypal/lib/features/subscriptions/presentation/subscriptions_screen.dart) (`/subscriptions`) and [add_subscription_sheet.dart](file:///c:/flutterprojects/pennypal/lib/features/subscriptions/presentation/add_subscription_sheet.dart).
    * **Student Presets:** 1-tap template chips for *Spotify Student ($299)*, *Netflix ($800)*, *Hostel Rent ($15,000)*, *Bus Pass ($3,500)*, *Mobile Data ($1,200)*, and *Gym Pass ($2,500)*.
    * **Billing Status & Due Alerts:** Dynamic calculation of days until due (`Due in 3 days`, `Due today`, `Overdue by X days`, `Paid for this month`).
    * **1-Tap "Pay & Log Expense":** Automatically updates the subscription's `lastPaidDate` and creates a corresponding `FinanceTransaction` (expense) in PennyPal, immediately reflecting on monthly budgets and cashflow charts.
  * **Navigation:** Added to Quick Shortcuts on Home Screen and More Screen.

---

### 4. 💱 Global Currency Selection & Zero-Bug Formatting Audit
* **Problem Solved:** Resolved a bug where the Hero Card obscured balance showed hardcoded `Rs.` regardless of the selected currency, cold-boot preferences failed to load immediately, and negative numbers formatted awkwardly.
* **Architecture & Technical Details:**
  * **Cold-Boot Sync:** Updated [main.dart](file:///c:/flutterprojects/pennypal/lib/main.dart) to read `user_currency_preference` from `SharedPreferences` synchronously before building the widget tree, initializing `Formatters.currentCurrency`.
  * **Reactivity:** Updated [app.dart](file:///c:/flutterprojects/pennypal/lib/app/app.dart) to watch `currencyProvider`, triggering seamless app-wide re-renders when the student switches currency in Profile.
  * **Formatting Precision:** Fixed [formatters.dart](file:///c:/flutterprojects/pennypal/lib/core/utils/formatters.dart) so negative numbers render correctly as `-$250` instead of `$-250`.
  * **Obscured Hero Card:** Updated [home_screen.dart](file:///c:/flutterprojects/pennypal/lib/features/dashboard/presentation/home_screen.dart) to dynamically use `currency` rather than static `Rs.`.
  * **Input Sheets Prefix:** Updated transaction form, budget form, goal form, and contribution sheet text fields to use dynamic currency prefixes.

---

### 5. 🎉 Savings Goal Milestone Confetti Celebration Engine
* **Problem Solved:** Saving money on a tight student budget is challenging; lack of positive reinforcement reduces motivation.
* **Architecture & Technical Details:**
  * Created [milestone_celebration_dialog.dart](file:///c:/flutterprojects/pennypal/lib/shared/widgets/milestone_celebration_dialog.dart) featuring a built-in particle physics engine using Flutter's `CustomPainter` and `AnimationController` (avoiding unstable third-party confetti dependencies).
  * Wired [contribute_sheet.dart](file:///c:/flutterprojects/pennypal/lib/features/savings/presentation/contribute_sheet.dart) to compute pre- and post-contribution ratios:
    * Automatically triggers confetti dialogs when crossing milestone thresholds: **25%**, **50%**, **75%**, and **100% Goal Completion**.

---

### 6. 🛡️ Cloud Firestore Row-Level Security Rules & Resilient UI States
* **Problem Solved:** Adding `debts` and `subscriptions` collections triggered `[cloud_firestore/permission-denied]` errors when connected to live Firebase.
* **Architecture & Technical Details:**
  * **Security Rules:** Updated [firestore.rules](file:///c:/flutterprojects/pennypal/firestore.rules#L49-L50) to grant students strict owner-only row-level security (`isOwner(uid)`) on `/users/{uid}/debts/{id}` and `/users/{uid}/subscriptions/{id}`.
  * **Resilient UI States:** Enhanced [async_value_view.dart](file:///c:/flutterprojects/pennypal/lib/shared/widgets/async_value_view.dart) and [app_error_state.dart](file:///c:/flutterprojects/pennypal/lib/shared/widgets/app_error_state.dart) to automatically detect permission-denied errors, rendering a clear security instruction badge and a **Try Again** button rather than unhandled exception text.

---

### 7. 🦸 Multiple Heroes / Duplicate Default FAB Tag Resolution
* **Problem Solved:** When running the app on Chrome or native devices, Flutter threw `AssertionError: There are multiple heroes that share the same tag within a subtree: <default FloatingActionButton tag>`.
* **Architecture & Technical Details:**
  * Flutter assigns an internal `<default FloatingActionButton tag>` Hero to every FAB by default.
  * In PennyPal's `StatefulShellRoute.indexedStack`, multiple bottom navigation tab screens (e.g. `ActivityScreen` and `SavingsScreen`) reside simultaneously in the same PageRoute subtree. Additionally, pushed screens like `SubscriptionsScreen`, `DebtTrackerScreen`, `CardsScreen`, and `AdminContentScreen` also had FABs.
  * Explicitly configured `heroTag: null` on all 6 `FloatingActionButton` and `FloatingActionButton.extended` widgets across the codebase:
    * [activity_screen.dart](file:///c:/flutterprojects/pennypal/lib/features/transactions/presentation/activity_screen.dart#L163)
    * [savings_screen.dart](file:///c:/flutterprojects/pennypal/lib/features/savings/presentation/savings_screen.dart#L35)
    * [subscriptions_screen.dart](file:///c:/flutterprojects/pennypal/lib/features/subscriptions/presentation/subscriptions_screen.dart#L93)
    * [debt_tracker_screen.dart](file:///c:/flutterprojects/pennypal/lib/features/debts/presentation/debt_tracker_screen.dart#L75)
    * [cards_screen.dart](file:///c:/flutterprojects/pennypal/lib/features/cards/presentation/cards_screen.dart#L53)
    * [admin_content_screen.dart](file:///c:/flutterprojects/pennypal/lib/features/admin/presentation/admin_content_screen.dart#L235)
  * Completely eliminated the duplicate hero tag conflict and assertion crash.

---

## Guidelines for Future Entries

When adding features in upcoming sessions:
1. Add a new heading with the date: `### [YYYY-MM-DD] Feature Name`.
2. Document:
   * **Problem Solved / User Need**
   * **Technical & Domain Architecture** (classes, providers, schemas)
   * **Files Added & Modified** (with clickable markdown file links)
   * **Verification & Test Status**
