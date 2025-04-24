import 'package:flutter/material.dart';

class StockTile extends StatelessWidget {
  final String symbol;
  final double price;
  final VoidCallback onTap;

  StockTile({required this.symbol, required this.price, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(symbol),
      subtitle: Text('\$${price.toStringAsFixed(2)}'),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}