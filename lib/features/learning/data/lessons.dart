import '../domain/lesson.dart';

/// Built-in lessons. All content is educational and general; it is not
/// financial advice. Amounts are examples in rupees.
const List<Lesson> bundledLessons = [
  Lesson(
    id: 'what-is-a-budget',
    title: 'What is a budget?',
    topic: LearningTopic.budgeting,
    level: LessonLevel.beginner,
    readMinutes: 3,
    summary: 'A budget is a simple plan for your money, not a punishment.',
    sections: [
      LessonSection(
        'The idea',
        'A budget is a plan that shows what money comes in, what goes out, and what is left over. It answers one question before the month begins: where should my money go?\n\n'
        'It is not about spending less on everything. It is about choosing on purpose, so you are not surprised on the 20th.',
      ),
      LessonSection(
        'Three steps',
        '- Write down your income for the month.\n'
        '- List your expenses, starting with the ones you must pay.\n'
        '- Compare the two and adjust until spending is not more than income.',
      ),
      LessonSection(
        'Why it helps',
        'A budget shows problems early. If food is already 80% used by mid-month, you can slow down now instead of running out later. It also makes room for savings, because you plan for them instead of hoping something is left.',
      ),
    ],
    example: LessonExample(
      'Try it',
      'Income: Rs. 30,000. Plan: needs Rs. 15,000, wants Rs. 9,000, savings Rs. 6,000. Everything has a place, and the total still equals Rs. 30,000.',
    ),
  ),
  Lesson(
    id: 'fifty-thirty-twenty',
    title: 'The 50/30/20 guide',
    topic: LearningTopic.budgeting,
    level: LessonLevel.beginner,
    readMinutes: 3,
    summary: 'A popular starting point for splitting your money three ways.',
    sections: [
      LessonSection(
        'The split',
        '- 50% for needs, the things you must pay for.\n'
        '- 30% for wants, the things that make life enjoyable.\n'
        '- 20% for savings and goals.',
      ),
      LessonSection(
        'Make it fit you',
        'This is a guide, not a law. If your needs take 65% of your money, that is real, and it is fine to start with 65/20/15. What matters is that you look at the split and choose it deliberately.',
      ),
      LessonSection(
        'When money changes',
        'If your income goes up, try to give the extra to savings before your spending grows to match. If it goes down, protect needs first and trim wants.',
      ),
    ],
    example: LessonExample(
      'Try it',
      'With Rs. 40,000: needs Rs. 20,000, wants Rs. 12,000, savings Rs. 8,000. Now compare that with what you actually spent last month.',
    ),
  ),
  Lesson(
    id: 'first-monthly-budget',
    title: 'Set up your first monthly budget',
    topic: LearningTopic.budgeting,
    level: LessonLevel.beginner,
    readMinutes: 3,
    summary: 'Turn the idea into a working budget in PennyPal.',
    sections: [
      LessonSection(
        'Start with the total',
        'Open the Budget tab and create a budget for the month. Enter a total you are comfortable with, usually a little less than your income so something is left for savings.',
      ),
      LessonSection(
        'Add category limits',
        'Limits are optional but powerful. Give Food, Transport and Entertainment a number. When a category gets close to its limit, you will see it before it becomes a problem.',
      ),
      LessonSection(
        'Choose an alert level',
        'The alert level is when PennyPal marks a budget as "nearing your limit". 80% is a good start: early enough to change your habits, late enough to avoid constant warnings.',
      ),
      LessonSection(
        'Check in weekly',
        'Look at the Budget tab once a week. Small adjustments in week two are easier than big ones in week four.',
      ),
    ],
  ),
  Lesson(
    id: 'why-save-early',
    title: 'Why saving early helps',
    topic: LearningTopic.saving,
    level: LessonLevel.beginner,
    readMinutes: 3,
    summary: 'The habit matters more than the amount.',
    sections: [
      LessonSection(
        'Habit first',
        'Saving Rs. 1,000 every month teaches your brain that saving is normal. Starting small and staying consistent beats saving a large amount once and then stopping.',
      ),
      LessonSection(
        'Savings give you options',
        'Money set aside means a broken laptop charger or a sudden trip home is an inconvenience instead of a crisis. It also lets you say yes to opportunities, like a short course or a good internship that pays little.',
      ),
      LessonSection(
        'Give it a name',
        'A saving with a name and a date, like "New laptop by March", is easier to protect than money that is just "left over". Create a goal in the Savings tab to see progress.',
      ),
    ],
    example: LessonExample(
      'Try it',
      'Pick one thing you want in the next 6 months. Divide its cost by 6. That is your monthly amount.',
    ),
  ),
  Lesson(
    id: 'emergency-fund',
    title: 'Emergency fund basics',
    topic: LearningTopic.saving,
    level: LessonLevel.intermediate,
    readMinutes: 4,
    summary: 'A small cushion for surprises you did not plan for.',
    sections: [
      LessonSection(
        'What it is',
        'An emergency fund is money kept for unexpected, necessary costs: a phone repair, a medical visit, a sudden fee. It is not for sales or trips.',
      ),
      LessonSection(
        'How much to aim for',
        'A common first target is one month of basic needs. Later, many people build towards three months. Start with the first target and celebrate when you reach it.',
      ),
      LessonSection(
        'Where to keep it',
        'Keep it separate from your everyday money so you do not spend it by accident, but easy enough to reach when you truly need it.',
      ),
    ],
    example: LessonExample(
      'Try it',
      'If your basic needs cost Rs. 15,000 a month, a starter fund is Rs. 15,000. Saving Rs. 1,500 a month gets you there in 10 months.',
    ),
  ),
  Lesson(
    id: 'small-saving-habits',
    title: 'Small habits that grow savings',
    topic: LearningTopic.saving,
    level: LessonLevel.beginner,
    readMinutes: 3,
    summary: 'Easy routines that make saving automatic.',
    sections: [
      LessonSection(
        'Pay yourself first',
        'Set aside your saving as soon as money arrives, then spend what is left. Saving what remains at the end of the month rarely works.',
      ),
      LessonSection(
        'The 24-hour rule',
        'For a non-essential purchase, wait a day. If you still want it tomorrow and it fits your budget, buy it. Many impulse buys lose their shine overnight.',
      ),
      LessonSection(
        'Track the small stuff',
        'Snacks, rides and top-ups feel small but add up. Logging them for a month often shows an easy Rs. 2,000 to Rs. 3,000 you can redirect to a goal.',
      ),
    ],
  ),
  Lesson(
    id: 'know-your-income',
    title: 'Know your income',
    topic: LearningTopic.income,
    level: LessonLevel.beginner,
    readMinutes: 3,
    summary: 'Every budget starts with knowing what comes in.',
    sections: [
      LessonSection(
        'Where student money comes from',
        '- Allowance from family.\n'
        '- Scholarships or stipends.\n'
        '- Part-time work or internships.\n'
        '- Freelance projects.\n'
        '- One-off gifts.',
      ),
      LessonSection(
        'Regular or irregular',
        'A monthly allowance is regular. Freelance work usually is not. Mixing them up leads to overspending in a good month and stress in a slow one.',
      ),
      LessonSection(
        'Plan on the lower number',
        'If your income changes, base your budget on the lower, more certain amount. Treat anything extra as a bonus for savings or a goal.',
      ),
    ],
    example: LessonExample(
      'Try it',
      'Freelance income over three months: Rs. 5,000, Rs. 12,000, Rs. 0. Plan around Rs. 5,000 and save the rest in strong months.',
    ),
  ),
  Lesson(
    id: 'necessary-expenses',
    title: 'Needs: what you must pay for',
    topic: LearningTopic.necessary,
    level: LessonLevel.beginner,
    readMinutes: 3,
    summary: 'The costs that come first every month.',
    sections: [
      LessonSection(
        'The usual list',
        '- Basic food and groceries.\n'
        '- Transport to campus or work.\n'
        '- Tuition, books and required materials.\n'
        '- Rent and utility bills.\n'
        '- Health costs and essential phone or internet.',
      ),
      LessonSection(
        'Pay needs first',
        'When money arrives, cover needs before anything else. If needs are not covered, wants and even savings goals become stressful.',
      ),
      LessonSection(
        'Look for savings inside needs',
        'A need is not always a fixed price. A monthly bus pass may beat daily rides, and cooking at home costs less than daily takeaway. The need stays; the cost can shrink.',
      ),
    ],
  ),
  Lesson(
    id: 'needs-vs-wants',
    title: 'Needs vs wants: a quick test',
    topic: LearningTopic.needsVsWants,
    level: LessonLevel.beginner,
    readMinutes: 3,
    summary: 'Three questions that make spending decisions easier.',
    sections: [
      LessonSection(
        'The test',
        '- Do I need this to eat, get to class, stay healthy or study?\n'
        '- What happens if I go without it for a month?\n'
        '- Is there a cheaper way to meet the same need?',
      ),
      LessonSection(
        'The grey area',
        'Many things are part need and part want. You need a phone plan, but you may not need the most expensive one. Split the cost mentally: the basic version is the need, the upgrade is the want.',
      ),
      LessonSection(
        'Wants are allowed',
        'Wants are not bad. A budget with no fun tends to fail. The goal is to choose your wants, not to have them chosen by impulse.',
      ),
    ],
    example: LessonExample(
      'Try it',
      'Lunch at the cafeteria is a need. A daily takeaway coffee on top of it is a want. Keeping the coffee to three days a week can free up Rs. 2,000 a month.',
    ),
  ),
  Lesson(
    id: 'optional-spending',
    title: 'Optional spending without guilt',
    topic: LearningTopic.optional,
    level: LessonLevel.intermediate,
    readMinutes: 4,
    summary: 'Enjoy the extras, on purpose and within a limit.',
    sections: [
      LessonSection(
        'Set a fun budget',
        'Give entertainment, shopping and eating out a monthly limit. When you spend within it, there is nothing to feel guilty about. When it runs out, you wait for next month.',
      ),
      LessonSection(
        'Audit your subscriptions',
        'Music, video, apps and games often renew quietly. Once a quarter, list them and cancel anything you have not used in a month.',
      ),
      LessonSection(
        'Cost per use',
        'Divide the price by how often you will use something. A Rs. 6,000 pair of shoes worn 200 times costs Rs. 30 a wear. A Rs. 2,000 top worn twice costs Rs. 1,000 a wear.',
      ),
    ],
    example: LessonExample(
      'Try it',
      'Three subscriptions at Rs. 400 each is Rs. 1,200 a month, or Rs. 14,400 a year. Are all three still worth it?',
    ),
  ),
];
