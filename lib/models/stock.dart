class Stock {
  final String symbol;
  final String category;
  final String name;
  double price;

  Stock({
    required this.symbol,
    required this.category,
    required this.name,
    this.price = 0.0,
  });
}
