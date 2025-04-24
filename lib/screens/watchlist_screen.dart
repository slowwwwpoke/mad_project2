import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stock_search_screen.dart'; // Import StockSearchScreen

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _watchlistStream;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _watchlistStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('watchlist')
          .snapshots();
    }
  }

  // Delete a stock from watchlist
  Future<void> _deleteStock(String docId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('watchlist')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Watchlist')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _watchlistStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No stocks in your watchlist.'));
          }

          final stocks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              final symbol = stock['symbol'];
              final price = stock['price'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockSearchScreen(stockSymbol: symbol),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(symbol),
                  subtitle: Text('Price: \$${price}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteStock(stock.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
