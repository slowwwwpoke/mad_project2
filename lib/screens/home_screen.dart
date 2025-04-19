
import 'package:flutter/material.dart';
import 'watchlist_screen.dart';
import 'news_screen.dart';
import '../services/firebase_service.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  void _logout(BuildContext context) async {
    await FirebaseService.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock Tracker"),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: () => _logout(context))],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text("Watchlist"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WatchlistScreen())),
          ),
          ListTile(
            title: Text("News Feed"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsScreen())),
          ),
        ],
      ),
    );
  }
}
