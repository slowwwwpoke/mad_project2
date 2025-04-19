
class Stock {
  final String symbol;
  final String name;
  final double price;
  final String category;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.category,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'],
      name: json['description'] ?? json['symbol'],
      price: json['price'] ?? 0.0,
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'category': category,
    };
  }
}
