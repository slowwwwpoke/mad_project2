import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class StockSearchScreen extends StatefulWidget {
  final String? stockSymbol;

  const StockSearchScreen({Key? key, this.stockSymbol}) : super(key: key);

  @override
  _StockSearchScreenState createState() => _StockSearchScreenState();
}

class _StockSearchScreenState extends State<StockSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _apiKey = 'd04r0fhr01qspgm4ojqgd04r0fhr01qspgm4ojr0';  // Replace with your Finnhub API key

  bool _isLoading = false;
  String _stockPrice = '';
  String _dailyChange = '';
  String _searchResult = '';
  List<FlSpot> _chartData = [];

  @override
  void initState() {
    super.initState();
    if (widget.stockSymbol != null && widget.stockSymbol!.isNotEmpty) {
      _searchController.text = widget.stockSymbol!;
      searchStock();
    }
  }

  // Fetch stock quote and chart data
  Future<void> searchStock() async {
    final symbol = _searchController.text.trim().toUpperCase();
    if (symbol.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResult = '';
      _stockPrice = '';
      _dailyChange = '';
      _chartData = [];
    });

    try {
      final quoteUrl = 'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$_apiKey';
      final quoteResponse = await http.get(Uri.parse(quoteUrl));
      if (quoteResponse.statusCode == 200) {
        final quoteData = json.decode(quoteResponse.body);

        if (quoteData['c'] != null) {
          double currentPrice = quoteData['c'].toDouble();
          double openPrice = quoteData['o'].toDouble();
          double change = ((currentPrice - openPrice) / openPrice) * 100;

          setState(() {
            _stockPrice = currentPrice.toStringAsFixed(2);
            _dailyChange = '${change.toStringAsFixed(2)}%';
            _searchResult = symbol;
          });
        } else {
          setState(() {
            _stockPrice = 'No data found';
            _dailyChange = '';
          });
        }
      } else {
        throw Exception('Failed to load stock quote');
      }

      // Fetch historical data for the graph (last 10 days)
      final now = DateTime.now();
      final from = now.subtract(Duration(days: 10)).millisecondsSinceEpoch ~/ 1000;
      final to = now.millisecondsSinceEpoch ~/ 1000;

      final candleUrl = 'https://finnhub.io/api/v1/stock/candle?symbol=$symbol&resolution=D&from=$from&to=$to&token=$_apiKey';
      final candleResponse = await http.get(Uri.parse(candleUrl));

      if (candleResponse.statusCode == 200) {
        final candleData = json.decode(candleResponse.body);

        if (candleData['s'] == 'ok') {
          List<int> timestamps = List<int>.from(candleData['t']);
          List<dynamic> closes = candleData['c'];

          List<FlSpot> chartPoints = [];
          for (int i = 0; i < timestamps.length; i++) {
            chartPoints.add(FlSpot(i.toDouble(), closes[i].toDouble()));
          }

          setState(() {
            _chartData = chartPoints;
          });
        } else {
          setState(() {
            _chartData = [];
          });
        }
      } else {
        setState(() {
          _chartData = [];
        });
      }
    } catch (e) {
      setState(() {
        _stockPrice = 'Error fetching data';
        _dailyChange = '';
        _chartData = [];
      });
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Chart rendering
  Widget buildChart() {
    if (_chartData.isEmpty) return Text('No chart data');
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= _chartData.length) return Text('');
                final day = DateTime.now().subtract(Duration(days: _chartData.length - 1 - index));
                return Text('${day.month}/${day.day}', style: TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('\$${value.toStringAsFixed(0)}', style: TextStyle(fontSize: 10));
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _chartData,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter stock symbol (e.g., AAPL)',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchStock,
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_searchResult.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Symbol: $_searchResult',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('Price: \$$_stockPrice',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text('Daily Change: $_dailyChange',
                      style: TextStyle(
                        color: _dailyChange.startsWith('-') ? Colors.red : Colors.green,
                      )),
                  SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1.6,
                    child: buildChart(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
