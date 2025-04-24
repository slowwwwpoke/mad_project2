import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stock_search_screen.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Watchlist')),
      body: user == null
          ? Center(child: Text('Please sign in to view your watchlist.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('watchlist')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                Map<String, List<QueryDocumentSnapshot>> categorizedStocks = {};

                for (var doc in docs) {
                  String category = doc['category'] ?? 'Uncategorized';
                  if (!categorizedStocks.containsKey(category)) {
                    categorizedStocks[category] = [];
                  }
                  categorizedStocks[category]!.add(doc);
                }

                return ListView(
                  children: categorizedStocks.entries.map((entry) {
                    return ExpansionTile(
                      title: Text(entry.key),
                      children: entry.value.map((stockDoc) {
                        final symbol = stockDoc['symbol'];
                        final price = stockDoc['price'];
                        return ListTile(
                          title: Text(symbol),
                          subtitle: Text('Price: \$$price'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await stockDoc.reference.delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$symbol removed.')));
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockSearchScreen(
                                  stockSymbol: symbol,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
