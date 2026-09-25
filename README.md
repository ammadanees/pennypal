# PennyPal - Fresh All Along

Step 6: Admin portal, and Cloudinary-hosted receipt/profile photos, on top of steps 1-5.

## Run it right now (no Firebase needed)
```bash
flutter create . --platforms=android,ios,web --project-name pennypal
flutter pub get
flutter run            # or: flutter run -d chrome
flutter test
```
Without Firebase, debug builds start in **demo mode** (in-memory accounts,
nothing saved). The sign-in screen shows the demo logins:
- Student: alex@student.edu / PennyPal1
- Admin: admin@pennypal.app / Admin@1234

Release builds never fall back to demo mode.

## Connect Firebase (free Spark plan is enough)
1. Create a project at https://console.firebase.google.com
2. Build > Authentication > Sign-in method: enable **Email/Password**.
3. Build > Firestore Database: create a database (production mode).
4. Install the CLI tools, then in this folder run:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This overwrites `lib/firebase_options.dart` with your real settings.
5. Android only: in `android/app/build.gradle` set `minSdkVersion 23` (or
   `minSdk = 23`).
6. Publish the security rules: paste `firestore.rules` into
   Firestore > Rules and click Publish (or `firebase deploy --only firestore:rules`).
7. Create an admin: register a normal account in the app, then in the
   Firestore console open `users/<that uid>` and change `role` to `admin`.
   The app cannot grant this itself and the rules block students from
   editing their role.

## Flow
Splash > (first launch only) Welcome > Sign in / Register > Home.
Once the welcome screens are finished or skipped they never appear again.
Signed-in users skip straight to Home (students) or the admin portal.

## Design system
Everything visual lives in `lib/core/theme/`. Change
`AppColors.light.primary` and the whole app, including the splash, follows.

## Third-party packages
flutter_riverpod, go_router, firebase_core, firebase_auth, cloud_firestore,
shared_preferences, google_fonts, intl.
Fonts: Plus Jakarta Sans and Inter (via google_fonts).

## Data and offline
Transactions, budgets and savings goals live under `users/{uid}/...` in
Firestore with its offline cache switched on (`lib/main.dart`). Entering an
expense with no connection saves it on the device straight away and it is
sent to the cloud when the connection returns. Records get their id on the
device, so a retry can never create a duplicate. Home shows a notice while
changes are still waiting to sync. In demo mode the same screens run on an
in-memory store with sample data for Alex Khan.

## Reports and Learning
More > Reports shows income vs expenses, spending by category (donut with
legend), six-month spending, budget usage and savings progress for This
month, Last month, Last 3 months or This year. Charts are drawn with
Flutter's own painter, so there is no chart package to keep updated.
More > Learn has 10 built-in lessons across the six SRS topics, with a
per-student "read" tracker. Lessons can carry an `imageUrl` (for example a
Cloudinary link); without one they show a topic illustration.

## Images (Cloudinary)
Images will be hosted on Cloudinary instead of Firebase Storage, so the
Firebase Storage service and its rules are not needed. When receipts,
profile photos and admin-uploaded lesson images are added, they will use
Cloudinary *unsigned* uploads (a cloud name and an upload preset). Never put
the Cloudinary API secret in the app.

## Device Preview (web only)
On web the app runs inside `device_preview`: a toolbar lets you switch
phone, tablet and desktop frames, rotate, change text size and toggle dark
mode. Pick a tablet or desktop frame to see the navigation rail and sidebar
layouts. It is off on Android and iOS. To switch it off in a public web
build, run `flutter build web --dart-define=DEVICE_PREVIEW=false`.

## Admin portal
Sign in with an admin account (see "Connect Firebase" below for how to
create one, or use the demo admin login) to reach Dashboard, Users, Support
and Feedback tabs. Admins can read student profiles, support queries and
feedback, and reply to or close a support query — but never a student's
private transactions, budgets or savings goals (the Firestore rules block
that, not just the UI).

## Cloudinary (receipt and profile photos)
Fill in `lib/core/config/cloudinary_config.dart` with your cloud name and an
**unsigned** upload preset (Cloudinary dashboard > Settings > Upload >
Upload presets > Add preset > Signing mode: Unsigned). The API secret is
never used and must never be put in the app. Until it's configured, the
upload buttons show a friendly "not set up yet" message instead of failing
silently.
Used for: the expense form's optional receipt photo, and the profile
picture on the Profile screen.
