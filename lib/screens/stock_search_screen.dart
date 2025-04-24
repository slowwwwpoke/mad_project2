import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class StockSearchScreen extends StatefulWidget {
  final String? stockSymbol;

  StockSearchScreen({this.stockSymbol});

  @override
  _StockSearchScreenState createState() => _StockSearchScreenState();
}

class _StockSearchScreenState extends State<StockSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchResult = '';
  String _stockPrice = '';
  String _dailyChange = '';
  List<FlSpot> _chartData = [];
  List<dynamic> _newsArticles = [];
  bool _isLoading = false;

  final String _apiKey = 'd04r0fhr01qspgm4ojqgd04r0fhr01qspgm4ojr0';

  @override
  void initState() {
    super.initState();
    if (widget.stockSymbol != null) {
      _searchController.text = widget.stockSymbol!.toUpperCase();
      searchStock();
    }
  }

  Future<void> searchStock() async {
    final symbol = _searchController.text.trim().toUpperCase();
    if (symbol.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final quoteUrl = 'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$_apiKey';
    final newsUrl = 'https://finnhub.io/api/v1/company-news?symbol=$symbol&from=2024-04-01&to=2025-04-24&token=$_apiKey';

    try {
      final quoteResponse = await http.get(Uri.parse(quoteUrl));
      final newsResponse = await http.get(Uri.parse(newsUrl));

      if (quoteResponse.statusCode == 200) {
        final data = json.decode(quoteResponse.body);
        double currentPrice = data['c'].toDouble();
        double openPrice = data['o'].toDouble();

        double change = (currentPrice - openPrice) / openPrice * 100;

        _generateChartData(currentPrice);

        setState(() {
          _searchResult = symbol;
          _stockPrice = currentPrice.toStringAsFixed(2);
          _dailyChange = change.toStringAsFixed(2) + '%';
        });
      }

      if (newsResponse.statusCode == 200) {
        final newsData = json.decode(newsResponse.body);
        setState(() {
          _newsArticles = newsData;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
      setState(() {
        _isLoading = false;
        _stockPrice = 'Error';
        _dailyChange = '';
        _newsArticles = [];
      });
    }
  }

  void _generateChartData(double currentPrice) {
    List<FlSpot> data = [];
    for (int i = 0; i < 7; i++) {
      data.add(FlSpot(i.toDouble(), currentPrice + (i % 2 == 0 ? 1 : -1) * (i + 1)));
    }
    setState(() {
      _chartData = data;
    });
  }

  Future<void> addToWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _searchResult.isEmpty || _stockPrice.isEmpty) return;

    String? category = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController _categoryController = TextEditingController();
        return AlertDialog(
          title: Text('Choose or Create Category'),
          content: TextField(
            controller: _categoryController,
            decoration: InputDecoration(hintText: 'Enter category'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _categoryController.text.trim()),
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (category == null || category.isEmpty) return;

    final watchlistCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watchlist');

    await watchlistCollection.add({
      'symbol': _searchResult,
      'price': _stockPrice,
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to watchlist under "$category"')));
  }

  Future<void> _launchArticleUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search for Stocks')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Enter stock symbol'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: searchStock,
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_searchResult.isNotEmpty)
              Expanded(
                child: ListView(
                  children: [
                    Text('Stock: $_searchResult', style: Theme.of(context).textTheme.headlineMedium),
                    Text('Current Price: \$$_stockPrice', style: Theme.of(context).textTheme.bodyLarge),
                    Text('Daily Change: $_dailyChange', style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _chartData,
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 4,
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: addToWatchlist,
                      child: Text('Add to Watchlist'),
                    ),
                    SizedBox(height: 20),
                    Text('News', style: Theme.of(context).textTheme.titleLarge),
                    ..._newsArticles.map((article) => ListTile(
                          title: Text(article['headline'] ?? 'No headline'),
                          subtitle: Text(article['source'] ?? ''),
                          onTap: () => _launchArticleUrl(article['url']),
                        )),
                  ],
                ),
              )
            else
              Text('Enter a stock symbol to get started.', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
