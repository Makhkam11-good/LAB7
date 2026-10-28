String money(int cents) =>
    '\$${(cents / 100).toStringAsFixed(cents % 100 == 0 ? 0 : 2)}';
String shortDate(DateTime date) =>
    '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.day}, ${date.year}';
