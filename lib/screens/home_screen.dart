import 'package:flutter/material.dart';
import 'watchlist_screen.dart';  
import 'stock_search_screen.dart'; 

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock Tracker Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the Stock Tracker App!',
              style: Theme.of(context).textTheme.displayMedium, 
            ),
            SizedBox(height: 20),
            Text(
              'What would you like to do today?',
              style: Theme.of(context).textTheme.bodyLarge, 
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockSearchScreen(), // Navigate to StockSearchScreen
                  ),
                );
              },
              child: Text("Search Stocks"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchlistScreen(), // Navigate to WatchlistScreen
                  ),
                );
              },
              child: Text("View Watchlist"),
            ),
          ],
        ),
      ),
    );
  }
}
