import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/services/api_service.dart'; // Make sure this path is correct

class StockDetailScreen extends StatefulWidget {
  final String symbol;
  StockDetailScreen({required this.symbol});

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  List<FlSpot> chartData = [];
  List<dynamic>? news;

  @override
  void initState() {
    super.initState();
    fetchChartData();
    fetchNews();
  }

  void fetchChartData() async {
    try {
      final data = await ApiService().getHistoricalData(widget.symbol);
      setState(() {
        chartData = data;
      });
    } catch (e) {
      print('Chart data error: $e');
    }
  }

  void fetchNews() async {
    try {
      final fetchedNews = await ApiService().getStockNews(widget.symbol);
      setState(() {
        news = fetchedNews;
      });
    } catch (e) {
      print('News fetch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.symbol} Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Stock Price Chart
            chartData.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: chartData,
                            isCurved: true,
                            color: Colors.blue, // ✅ FIXED: use 'color' not 'colors'
                            barWidth: 3,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(child: CircularProgressIndicator()),

            SizedBox(height: 24),

            // News Feed
            Text(
              'Recent News',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12),

            news != null
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: news!.length,
                    itemBuilder: (context, index) {
                      final article = news![index];
                      return ListTile(
                        title: Text(article['headline'] ?? 'No headline'),
                        subtitle: Text(article['source'] ?? ''),
                        onTap: () {
                          // You can add URL launcher to open news links
                        },
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
