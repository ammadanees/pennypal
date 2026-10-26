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
    }
  }
  html, body, .markdown-body, .vscode-body, #write {
    margin: 0 !important;
    padding: 0 !important;
    width: 100% !important;
    max-width: 100% !important;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif !important;
    font-size: 12.5px !important;
    line-height: 1.4 !important;
    color: #111 !important;
  }
  h1 { font-size: 15px !important; margin: 8px 0 2px 0 !important; padding-bottom: 2px !important; border-bottom: 1px solid #e5e7eb !important; }
  h2 { font-size: 13.5px !important; margin: 6px 0 2px 0 !important; }
  h3 { font-size: 12.5px !important; margin: 4px 0 2px 0 !important; }
  p, ul, ol { margin: 0 0 4px 0 !important; }
  li { margin-bottom: 1px !important; }
  hr { margin: 6px 0 !important; border: none !important; border-top: 1px solid #d1d5db !important; }
  strong { color: #000 !important; }
</style>

# PennyPal — TECHWIZ 7
## Presentation & Viva Script
**Team:** TechBeast | **Center:** Aptech North Nazimabad | **Category:** Multi-Platform App Computing  
**Project tagline:** Make Every Penny Count.

---

# Part 1 — Opening & Team Introduction

Good morning, everyone! First of all, thank you so much for giving us this opportunity to present our project. My name is Muhammad Ammad Anees, and I'm the team lead of Team TechBeast from Aptech North Nazimabad Center.

Before we get started, let me quickly introduce my team members who are here with me today: so, we have Muhammad Hadi, who worked on the UI design; Muhammad Sharjeel, who worked on the admin panel; and Abdul Qadir, who handled the project documentation.

Together, we developed an application called **PennyPal**, with one simple goal: to help students manage their money better. Our motto is: **Make Every Penny Count.** Today, I'll explain why we built PennyPal, how it works, and then I will share my screen and demonstrate all its main features live. So, let's get started!

---

# Part 2 — The Problem We're Solving
Now, let me give you a little background about why we chose this project. You know, in TECHWIZ, the management provided us with three project options, and our team picked PennyPal without hesitation. Because as students, this is a real problem we experience every single day.

Students have different sources of income. Some receive pocket money from home, some earn through freelancing or part-time jobs, and others receive scholarships or stipends. But regardless of where the money comes from, keeping track of daily spending is really difficult. You spend a little bit on food, a little on transport, maybe pay for a subscription... and basically, by the third week of the month, you wonder: *"Where did all my money go?"*

We wanted to make managing money simple and stress-free. That's why we chose PennyPal. It helps students record their daily income and expenses, set monthly budgets, track their savings, and understand their spending habits. And most importantly, we wanted the app to work even when the internet is unavailable, because in campus classrooms and basements, students don't always have a reliable connection. So, our goal was to create a simple, useful financial companion for student life.

---

# Part 3 — Technologies We Used
Now, before we jump into the live demo, let me briefly explain how we built PennyPal.

First, we used **Flutter** to develop the application with a smooth experience across multiple platforms from a single codebase. Second, for managing the app's state and real-time screen updates, we used **Riverpod**. It helps different screens get the exact data they need and update automatically whenever that data changes, without lag or crashes. Third, we used **Firebase Cloud Firestore** as our database. It stores our data online and also supports offline use through its local cache. And finally, we integrated **Google Gemini AI** to scan paper receipts and automatically extract details like the store name, date, and amount.

So, in simple words: Flutter builds the UI, Riverpod manages the state, Firestore stores and syncs the data, and Gemini helps with smart receipt scanning. Alright, now let me share my screen and show you PennyPal live in action!

---

# Part 4 — Live Application Demonstration

## Step 1: Login
*Action: Open the application, show the login screen, type demo credentials, and tap Sign In.*

Alright, so we start right here at the login screen. As you can see, we have secure authentication to protect student accounts. PennyPal also has a separate area for administrators. Now, let me type in our student credentials... and tap **Sign In**. And just like that, the app verifies the account and takes us straight to the main dashboard.

## Step 2: Dashboard (The Financial Command Center)
*Action: Point to Income, Expenses, Net Balance cards, Payment Mode badges, Central Budget Ring, Health Score, and Recent Activity list.*

Now, here we are on the student dashboard, which serves as the main command center of PennyPal.

Right at the top, you can see the three primary summary cards: Total Income for this month, Total Expenses, and the true Net Balance. And you know, students don't keep all their money in one single place. Some is physical cash in their pocket, some in a student bank card, and some in mobile wallets like Nayapay or EasyPaisa. PennyPal tracks running balances for all these payment modes separately, while combining them into one true net balance right here.

Now, take a closer look at this ring right in the center: this isn't just a static circle. It visually calculates the student's daily spending pace and burn rate in real time. If they are spending within safe limits, it stays green. If they reach 80 percent, it warns them in amber, and if they overspend, it turns coral red.

Right below that, we have the **Financial Health Score** and **Cash Runway Days**. It actually tells the student: based on how fast you are spending, your remaining cash will last for, say, 18 more days. This gives students an immediate reality check so they don't run out of pocket money before the month ends.

And down here, we have the **Quick Category Ribbon** and **Recent Transactions**, so students can see their latest expenses at a glance without digging through deep menus. So, basically, from just this one single screen, a student gets complete clarity over their entire financial situation.

## Step 3: Monthly Budgets
*Action: Tap the Budget section, point to category limits, then show the 1-Tap Quick Copy banner.*

Now, seeing your balance is good, but controlling spending is what really matters. So let's open the **Budget** section. Here, students can set spending limits for different categories, like food, transport, and education. And you know, student allowances and rent run on a monthly basis, so PennyPal organizes budgets strictly by calendar month.

Now, here is a really neat feature we built, called **1-Tap Quick Copy**. You see, when a new month begins, students don't want to type every single category limit all over again. With just one tap right here, PennyPal automatically copies last month's budget. So, this saves time and makes monthly planning super easy.

## Step 4: Add an Expense and Scan a Receipt
*Action: Tap Add Expense (+), show the 8 categories, then tap Attach Receipt / Scan.*

Now, once your budget is set, you need to record your daily spending. So let me tap this plus button to add an expense. As you can see, we have all 8 standard categories ready—like Food, Transport, and Bills. Normally, you can just type the amount and details manually.

But check this out: if a student has a paper receipt from the canteen or a bookstore, they don't even have to type! Let me tap **Scan Receipt**. Our Gemini AI reads the image, extracts the merchant name, the date, and the total amount, and fills in the form automatically. So, all the student has to do is review the information and tap **Save**.

## Step 5: Offline Mode (Key Feature Demonstration)
*Action: Pull down quick settings, turn ON Airplane Mode, add a test expense, tap Save, show it appearing, then turn OFF Airplane Mode.*

Now, I want to show you one of the most important features of PennyPal: our offline engine. Imagine a student is on campus, sitting in a basement classroom where the internet suddenly stops working. Let me demonstrate what happens:

Watch this—I'll turn on **Airplane Mode** right now. The phone has zero internet. Now, let's add a quick 15-dollar expense for campus lunch... tap Save... and look at that! As you can see, the expense appears in the application immediately. There is no waiting, no loading spinner, and no error.

And now, watch what happens when I turn Airplane Mode back off: as soon as the connection returns, Firestore automatically syncs the pending transaction with the cloud in the background. So, this helps students continue recording their expenses anytime, anywhere.

## Step 6: Savings Goals
*Action: Tap the Savings tab, open an active goal (like 'New Laptop'), and tap Contribute to add $20.*

Now, tracking daily expenses is important, but building good money habits also means saving for the future. So let's switch over to **Savings Goals**. You see, students often want to save for something big—for example, buying a laptop or paying for a professional certification. They can set a target amount, choose a deadline date, and track their progress.

Let me show you: I'll open this laptop goal, and let's add a 20-dollar contribution right now... Notice how the progress bar moves forward immediately, the app recalculates the remaining timeline, and it gives a motivational milestone to keep students encouraged.

## Step 7: Extra Student Features
*Action: From dashboard shortcuts, show Split Bill, Borrow & Lend, and Subscriptions.*

Now, beyond the basic requirements, we asked our classmates: *"What other money headaches do you face?"* And based on their feedback, we included three extra practical tools:
- First, **Split Bill**: when friends eat out together, this calculates exactly how much each person should pay, and lets you copy a payment reminder straight to WhatsApp in one tap.
- Second, **Borrow & Lend**: you know how we lend 10 or 20 bucks to a friend for tea or photocopies and then forget about it? This keeps a clear, honest record of money owed, so friendships stay stress-free.
- And third, **Subscriptions Manager**: this helps students remember recurring payments—like software subscriptions or gym memberships—so they don't secretly drain their monthly allowance.

## Step 8: Learning Hub and AI Assistant
*Action: Open a lesson in the Learning Hub, then show the AI Assistant.*

We also believe managing money is not just about recording numbers. It's about learning how to make better financial decisions. That's why we included a **Learning Hub** with quick, bite-sized lessons on topics like needs versus wants and emergency savings.

And right next to it, students can also open our **AI Assistant** and ask practical questions—like: *"How can I save 30 dollars this week?"*—and get instant, personalized guidance. Together, these features help students build lasting financial discipline.

## Step 9: Admin Panel
*Action: Sign out of the student account and sign in to the prepared demo admin account (admin@pennypal.com).*

And finally, let me show you the administrative side. Let me sign out and log in with our admin account. You see, while students manage their personal finances, college/institution administrators get a separate dedicated dashboard. From here, the admin can view registered students, monitor system analytics, respond to support tickets, and even publish new educational lessons using the built-in CMS. And that completes our live demonstration of PennyPal!

---

# Part 5 — Closing Statement
So, to summarize—PennyPal is much more than just an app for recording expenses. It brings together monthly budgeting, offline support, AI receipt scanning, savings goals, financial lessons, and everyday student utilities all in one simple, easy-to-use companion. We built it from our own real-world experience as students to help young people understand their spending, plan their money, and develop healthy financial habits for life.

On behalf of Team TechBeast and Aptech North Nazimabad Center, thank you so much for your time and guidance today. We are now ready to answer your questions!

---

# Part 6 — Technical Viva: Simple Answers
*Understand the meaning of each answer. Deliver clear, honest answers in simple words.*

**Q1. Why did you choose this project?**  
We chose PennyPal because managing money is a common challenge for students. We wanted to build something practical that helps them track expenses, plan budgets, and save money.

**Q2. What makes PennyPal different from other finance apps?**  
PennyPal combines expense tracking and budgeting with offline support, receipt scanning, savings goals, financial lessons, and student-focused features such as bill splitting and debt tracking.

**Q3. Why did you use Flutter?**  
Flutter lets us build applications for multiple platforms using one main codebase. This helps reduce duplicated development work.

**Q4. What is Firebase Firestore?**  
Firestore is a cloud database from Firebase. It stores our application data and allows the app to receive updates when connected to the internet.

**Q5. What is Riverpod, and why did you use it?**  
Riverpod helps us manage application state. It makes it easier for screens and other parts of the app to access data and respond to changes.

**Q6. How does offline mode work?**  
Firestore supports a local cache. When offline support is enabled and the relevant data is available locally, users can continue working, and pending changes can synchronize after the connection returns.

**Q7. Does every feature work offline?**  
Not necessarily. Features that depend on an online service, such as Gemini AI receipt scanning, generally need an internet connection. Standard logging, budgeting, and dashboard calculations work offline.

**Q8. How does AI receipt scanning work?**  
The user selects or captures a receipt image. We send it to Gemini Vision AI, which attempts to identify information such as the merchant, date, and total amount. The extracted information is used to fill the expense form.

**Q9. What happens if the AI service is unavailable?**  
If Gemini AI is offline or the connection times out, our app uses a built-in text pattern fallback. It scans the receipt on the device and looks for numbers and keywords to extract the total amount without crashing.

**Q10. How do you protect users' financial information?**  
We use Firebase Authentication and Firestore security rules to control access. Only authenticated students can access their own accounts. We also never store sensitive card details like CVVs and full card numbers.

**Q11. How do you prevent users from accessing each other's data?**  
We secure user data using Firestore Security Rules. Every document is saved under the student's unique User ID (`request.auth.uid`). This guarantees that one user can never read or edit another user's private financial records.

**Q12. How does monthly budgeting work?**  
Users set spending limits for categories in a particular month. PennyPal compares recorded expenses against those limits so users can understand their spending and remaining budget.

**Q13. How does the savings feature help students?**  
Users can set a savings target and record contributions. They can then track how much they have saved and how much remains to reach their goal.

**Q14. Why did you add Split Bill and Borrow & Lend?**  
Students often share expenses with friends or lend each other small amounts. These features help them calculate shared costs and keep track of money owed.

**Q15. What was your biggest challenge?**  
One of our main challenges was making sure the offline engine worked smoothly. We had to ensure that when a student logs an expense without internet, it saves locally right away and syncs to Firebase automatically once the connection is back.

**Q16. How did you test the application?**  
We tested the app thoroughly: first, manual testing across all screens and user flows, especially Airplane Mode. Second, we wrote automated unit tests for our calculation logic to make sure all financial math and budget percentages are completely accurate.

**Q17. Why did you create an admin panel?**  
The admin panel provides a separate area for administrative tasks, such as viewing system information, handling support requests, and managing educational content.

**Q18. Can PennyPal support more users in the future?**  
It can be developed further using cloud infrastructure, but growth would require testing database usage, security, performance, and operating costs. We would measure those areas before claiming a particular scale.

**Q19. What would you improve in the future?**  
We could improve the application through more testing, better financial insights, additional languages, more accessibility options, and carefully designed features based on student feedback.

**Q20. Why should students use PennyPal?**  
Because it brings their expenses, budgets, and savings goals together in one place. Our aim is to make managing money easier and help students build better financial habits.

---

# Part 7 — What to Say When You Need Help
*You do not need to panic if a judge speaks quickly or asks something unexpected. Use these phrases naturally:*
- **If you didn't hear the question:** “Sorry, could you please repeat the question?”
- **If the question is too fast:** “Could you please speak a little more slowly?”
- **If you need time to think:** “That's a good question. Let me think for a moment.”
- **If you understand only part of the question:** “Do you mean how we store the data, or how we keep it secure?”
- **If you don't know the answer:** “I haven't explored that part in enough detail yet, so I don't want to give you incorrect information. I will investigate it further.”
- **If a teammate knows the answer better:** “My teammate worked more closely on that part. May I ask him to explain the implementation?”
- **If the judge points to a teammate:** Let them answer. Don't interrupt or try to answer on their behalf unless the judge asks you to add something.

---

# Part 8 — Final Preparation Checklist
- Practise the opening until you can say it comfortably without reading.
- Make sure all four team members can introduce their contributions clearly.
- Prepare the application, test accounts, and sample data before the session.
- Test the offline demonstration in advance.
- Check which features require an internet connection.
- Confirm the admin panel and all demo features work as expected.
- Never display passwords or API keys during screen sharing.
- Be ready to explain any technical term you use in simple words.
- If you don't know something, be honest and explain how you would investigate it.