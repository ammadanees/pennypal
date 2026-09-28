import '../constants/app_categories.dart';

abstract final class ExpenseCategorizer {
  static const Map<ExpenseCategory, List<String>> _keywords = {
    ExpenseCategory.food: [
      'food',
      'lunch',
      'dinner',
      'breakfast',
      'meal',
      'burger',
      'pizza',
      'kfc',
      'mcdonald',
      'subway',
      'chai',
      'tea',
      'coffee',
      'cafe',
      'restaurant',
      'snack',
      'biryani',
      'grocery',
      'canteen',
      'sweets',
      'bakery',
      'shawarma',
      'roti',
      'paratha',
      'sandwich',
      'juice',
      'dhabba',
      'kebab',
      'bbq',
    ],
    ExpenseCategory.transport: [
      'transport',
      'uber',
      'indrive',
      'careem',
      'bykea',
      'bus',
      'metro',
      'speedo',
      'rickshaw',
      'taxi',
      'fuel',
      'petrol',
      'gasoline',
      'cng',
      'train',
      'railway',
      'fare',
      'toll',
      'parking',
      'bike',
      'flight',
    ],
    ExpenseCategory.education: [
      'education',
      'tuition',
      'fee',
      'books',
      'book',
      'semester',
      'course',
      'udemy',
      'coursera',
      'exam',
      'paper',
      'stationery',
      'notebook',
      'pen',
      'assignment',
      'project',
      'photocopy',
      'print',
      'printing',
      'library',
      'university',
      'college',
      'school',
      'academy',
      'degree',
    ],
    ExpenseCategory.shopping: [
      'shopping',
      'clothes',
      'shirt',
      'pants',
      'shoes',
      'dress',
      'zara',
      'outfitters',
      'khaadi',
      'daraz',
      'amazon',
      'aliexpress',
      'watch',
      'bag',
      'sunglasses',
      'accessories',
      'mall',
      'perfume',
      'makeup',
    ],
    ExpenseCategory.entertainment: [
      'entertainment',
      'movie',
      'cinema',
      'netflix',
      'spotify',
      'youtube',
      'gaming',
      'game',
      'playstation',
      'steam',
      'bowling',
      'party',
      'concert',
      'outing',
      'arcade',
      'match',
      'cricket',
      'snooker',
    ],
    ExpenseCategory.bills: [
      'bill',
      'bills',
      'electricity',
      'lesco',
      'k-electric',
      'iesco',
      'water',
      'gas',
      'sngpl',
      'ssgc',
      'wifi',
      'internet',
      'stormfiber',
      'nayatel',
      'ptcl',
      'jazz',
      'telenor',
      'zong',
      'ufone',
      'recharge',
      'mobile load',
      'package',
      'rent',
      'hostel',
      'maintenance',
    ],
    ExpenseCategory.savings: [
      'saving',
      'savings',
      'deposit',
      'piggy',
      'emergency',
      'reserve',
      'fund',
      'gold',
      'committee',
    ],
    ExpenseCategory.miscellaneous: [
      'misc',
      'other',
      'repair',
      'charity',
      'donation',
      'gift',
      'tip',
      'fine',
      'challan',
      'laundry',
      'haircut',
      'salon',
    ],
  };

  static ExpenseCategory? predictCategory(String text) {
    final clean = text.toLowerCase().trim();
    if (clean.isEmpty) return null;

    final words = clean.split(RegExp(r'[\s,._-]+'));

    ExpenseCategory? bestMatch;
    var maxScore = 0;

    for (final entry in _keywords.entries) {
      var score = 0;
      for (final keyword in entry.value) {
        if (words.contains(keyword)) {
          score += 3;
        } else if (clean.contains(keyword)) {
          score += 1;
        }
      }

      if (score > maxScore) {
        maxScore = score;
        bestMatch = entry.key;
      }
    }

    return maxScore > 0 ? bestMatch : null;
  }
}
