import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stock_search_screen.dart'; // Import StockSearchScreen

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<DocumentSnapshot> watchlist = [];

  @override
  void initState() {
    super.initState();
    fetchWatchlist();
  }

  Future<void> fetchWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .get();

    setState(() {
      watchlist = querySnapshot.docs;
    });
  }

  Future<void> deleteFromWatchlist(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock removed from watchlist')));
    fetchWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Watchlist')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: watchlist.length,
          itemBuilder: (context, index) {
            final stock = watchlist[index];
            return ListTile(
              title: Text(stock['symbol']),
              subtitle: Text('Price: \$${stock['price']}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => deleteFromWatchlist(stock.id),
              ),
              onTap: () {
                // Navigate to StockSearchScreen with selected stock symbol
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockSearchScreen(stockSymbol: stock['symbol']),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
