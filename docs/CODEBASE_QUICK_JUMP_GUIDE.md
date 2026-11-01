<style>
  @page {
    margin: 6mm 8mm !important;
    size: A4 portrait;
  }
  @media print {
    @page {
      margin: 6mm 8mm !important;
    }
    html, body, .markdown-body, .vscode-body, #write, div, article, section {
      margin: 0 !important;
      padding: 0 !important;
      width: 100% !important;
      max-width: 100% !important;
      background: #ffffff !important;
      color: #000000 !important;
    }
  }
  
  /* FORCE ALL TEXT TO PURE SOLID BLACK */
  *,
  *::before,
  *::after,
  html,
  body,
  .markdown-body,
  .vscode-body,
  .vscode-light,
  .vscode-dark,
  #write,
  h1, h2, h3, h4, h5, h6,
  p, span, div, a, li, ul, ol,
  td, th, table, tr, tbody, thead,
  code, pre, pre code, code *, pre *,
  strong, b, em, i,
  blockquote, blockquote p,
  .hljs, .hljs * {
    color: #000000 !important;
    -webkit-text-fill-color: #000000 !important;
  }

  html, body, .markdown-body, .vscode-body, #write {
    margin: 0 !important;
    padding: 0 !important;
    width: 100% !important;
    max-width: 100% !important;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif !important;
    font-size: 13px !important;
    line-height: 1.5 !important;
    background-color: #ffffff !important;
  }

  h1 { font-size: 17px !important; font-weight: 800 !important; margin: 10px 0 4px 0 !important; padding-bottom: 3px !important; border-bottom: 2px solid #000000 !important; }
  h2 { font-size: 14.5px !important; font-weight: 700 !important; margin: 10px 0 4px 0 !important; border-bottom: 1px solid #333333 !important; padding-bottom: 2px !important; }
  h3 { font-size: 13.5px !important; font-weight: 700 !important; margin: 8px 0 3px 0 !important; }
  p, ul, ol, table { margin: 0 0 8px 0 !important; }
  li { margin-bottom: 3px !important; }
  hr { margin: 10px 0 !important; border: none !important; border-top: 1px solid #555555 !important; }

  /* High contrast code styling */
  code {
    background-color: #e5e7eb !important;
    color: #000000 !important;
    padding: 2px 5px !important;
    border-radius: 4px !important;
    font-family: "JetBrains Mono", Consolas, monospace !important;
    font-size: 12px !important;
    font-weight: 600 !important;
    border: 1px solid #9ca3af !important;
  }

  pre {
    background-color: #f3f4f6 !important;
    border: 1.5px solid #6b7280 !important;
    padding: 8px 10px !important;
    border-radius: 6px !important;
    margin: 6px 0 !important;
    overflow-x: auto !important;
  }

  pre code {
    background: transparent !important;
    border: none !important;
    padding: 0 !important;
    font-weight: 600 !important;
  }

  /* High contrast table styling */
  table {
    border-collapse: collapse !important;
    width: 100% !important;
    margin-bottom: 12px !important;
  }

  th, td {
    border: 1.5px solid #000000 !important;
    padding: 6px 10px !important;
    text-align: left !important;
    font-size: 12px !important;
  }

  th {
    background-color: #e5e7eb !important;
    font-weight: 800 !important;
  }

  tr:nth-child(even) td {
    background-color: #f9fafb !important;
  }

  blockquote {
    border-left: 4px solid #000000 !important;
    background-color: #f3f4f6 !important;
    padding: 8px 12px !important;
    margin: 6px 0 !important;
  }
</style>

# PennyPal — Pro Code Navigator & Live Defense Guide
**Team:** TechBeast | **Center:** Aptech North Nazimabad | **Lead Presenter:** Muhammad Ammad Anees  
**Purpose:** Jump directly to any screen's code in 1 second during live viva defense and explain it like a senior developer.

---

## Rule #1: Never Browse Folders with Your Mouse
Real developers do not click through folders on the left sidebar. They use keyboard shortcuts.

When a judge asks: *"Can you show the code for this screen or feature?"*
1. Press **Ctrl + P** in VS Code (Quick Open).
2. Type 3 to 5 letters of the file name (for example: **home_sc** or **budget_sc**).
3. Press **Enter**. The file opens instantly in 1 second.
4. If asked for a specific word or function, press **Ctrl + F** and type the keyword.

Doing this gives judges immediate confidence that you wrote the codebase and know every file by name.

---

## Quick Jump Table: What to Type in Ctrl + P

| Screen / Feature | Type in Ctrl + P | File Path | What to Point to on Screen |
| :--- | :--- | :--- | :--- |
| **Main Dashboard & Header** | `home_screen` | `lib/features/dashboard/presentation/home_screen.dart` | `_HomeHeader` (Avatar & Bell), `_BalanceHero`, `_PaceRing` |
| **Monthly Budget & 1-Tap Copy** | `budget_screen` | `lib/features/budgets/presentation/budget_screen.dart` | `_copyPreviousMonthBudget()` method |
| **Add Expense & Gemini AI OCR** | `transaction_form` | `lib/features/transactions/presentation/transaction_form_screen.dart` | `_scanReceiptWithGemini()` or `_pickReceiptImage()` |
| **Offline Cache Engine** | `main.dart` | `lib/main.dart` (lines 62–65) | `persistenceEnabled: true` & `CACHE_SIZE_UNLIMITED` |
| **Savings Goals & Milestones** | `savings_screen` | `lib/features/savings/presentation/savings_screen.dart` | `_GoalCard` & progress calculation |
| **Split Bill** | `cards_screen` | `lib/features/cards/presentation/cards_screen.dart` | Bill splitting calculation and WhatsApp share |
| **Borrow & Lend (Debts)** | `debt_tracker` | `lib/features/debts/presentation/debt_tracker_screen.dart` | `_DebtCard` (Lent vs Borrowed) |
| **Subscriptions** | `subscriptions_screen` | `lib/features/subscriptions/presentation/subscriptions_screen.dart` | Monthly recurring list & total cost calculation |
| **Learning Hub & Lessons** | `learning_screen` | `lib/features/learning/presentation/learning_screen.dart` | Lesson cards and categories |
| **AI Assistant (Gemini Chat)** | `assistant_screen` | `lib/features/assistant/presentation/assistant_screen.dart` | Chat message stream & Gemini prompt handler |
| **Admin Panel** | `admin_dashboard` | `lib/features/admin/presentation/admin_dashboard_screen.dart` | Admin statistics cards & charts |
| **Navigation & Route Guards** | `router.dart` | `lib/app/router.dart` | Role check: student vs admin redirection |

---

## How Our Code is Structured (The 10-Second Architecture Pitch)

If judges ask: *"How did you structure your codebase?"*, say:

> *"We structured PennyPal using **Feature-Driven Architecture**.  
> Everything is inside `lib/features/`. Each feature has its own folder with:  
> • `presentation/` for UI screens and widgets.  
> • `domain/` for models and financial calculations.  
> • `data/` for Firebase repositories and API calls."*

---

## What to Say While Opening Code (Short & Natural)

Speak these simple sentences while your fingers type the shortcut:

- *"Sure, let me open that file directly."* (press **Ctrl + P**)
- *"Here is our presentation widget."*
- *"We separated UI from business logic."*
- *"State is handled through Riverpod providers."*
- *"Here is the calculation function."*

---

## The 3 Most Likely Code Questions & How to Answer

### Q1: "Show me how Offline Mode works in the code."
1. Press **Ctrl + P** ➔ type `main.dart` ➔ press **Enter**.
2. Scroll to lines 62–65:
```
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```
3. **What to say:**  
   > *"Right here in `main.dart`, we configure Firestore with `persistenceEnabled: true` and unlimited local cache. So every transaction writes to local device storage first, and syncs automatically when internet returns."*

---

### Q2: "Show me where you call Gemini AI for receipts."
1. Press **Ctrl + P** ➔ type `transaction_form` ➔ press **Enter**.
2. Press **Ctrl + F** ➔ type `gemini` or `scan`.
3. **What to say:**  
   > *"Here in `transaction_form_screen.dart`, when the user picks a receipt photo, we send the image bytes to Gemini Vision AI. It extracts the merchant name, date, and amount, and populates the text controllers automatically."*

---

### Q3: "Show me where the 1-Tap Quick Copy logic is."
1. Press **Ctrl + P** ➔ type `budget_screen` ➔ press **Enter**.
2. Press **Ctrl + F** ➔ type `copy`.
3. **What to say:**  
   > *"Here in `budget_screen.dart`, this function reads last month's budget documents from Firestore and creates duplicates for the current calendar month with one tap."*

---

## Quick Tips for Live Confidence
- **Practice 3 times now:** Press **Ctrl + P** and jump between `home_screen.dart`, `budget_screen.dart`, and `main.dart`.
- **Stay relaxed:** If you misspell a file name, just press **Backspace** and retype. Never panic.
- **Point with your finger or mouse:** Once the file opens, highlight the class name or function with your mouse so the judge's eyes follow your lead.

---

## 🗣️ Natural Fillers & Transition Phrases (Spoken Cheat Sheet)
*Use these short, easy-to-pronounce phrases whenever you switch screens, tap buttons, or open code. They fill pauses naturally without saying "umm" or "uhh":*

### 1. Moving to the Next Screen or Feature
- *"Now next, we have..."*
- *"Let's jump into the [Screen Name]..."*
- *"Moving forward to our next screen..."*
- *"From here, let's head over to..."*
- *"Next up, let me show you..."*
- *"Now, switching over to the..."*
- *"Let's take a look at our next key feature..."*

### 2. Introducing a Screen or UI Component
- *"This is our [XYZ] screen."*
- *"Right here on this screen, you can see..."*
- *"As you can see right in front of you..."*
- *"At first glance on this dashboard..."*
- *"This section is specifically built for..."*
- *"Here is where the student spends most of their time..."*
- *"Right at the top header, notice..."*

### 3. Demonstrating a Live Action
- *"Now, watch what happens when I tap this..."*
- *"Let me perform a live test right now..."*
- *"Notice how quickly this updates on screen..."*
- *"Let's see this in action..."*
- *"Just like that, it saves with zero delay."*
- *"Watch this: I will add a test transaction..."*
- *"Now observe how the numbers adjust immediately..."*

### 4. Opening & Pointing to Code
- *"Sure, let's jump right into the code for this."*
- *"Let me pull up the exact file for you."*
- *"Here is the exact method handling this logic."*
- *"Notice this function right here on line [X]..."*
- *"This is where the calculation happens under the hood."*
- *"As you can see in this controller..."*
- *"We kept this logic completely separate from the UI."*

### 5. Buying 2 to 3 Seconds to Think (Zero Panic)
- *"That is a very good question."*
- *"Let me explain the exact reason behind this..."*
- *"To put this in simple words..."*
- *"The main idea here was..."*
- *"Let me show you this directly on screen..."*
- *"From a practical student point of view..."*

### 6. Wrapping Up a Feature & Moving Ahead
- *"And that is basically how this works."*
- *"So, that wraps up this part."*
- *"Now, with that in place, let's look at..."*
- *"That completes the student side of this feature."*
