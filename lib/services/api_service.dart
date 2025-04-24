import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class ApiService {
  final String _baseUrl = 'https://finnhub.io/api/v1';
  final String _apiKey = 'd04pvu1r01qspgm4il1gd04pvu1r01qspgm4il20';

  Future<Map<String, dynamic>> getStockQuote(String symbol) async {
    final url = Uri.parse('$_baseUrl/quote?symbol=$symbol&token=$_apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch stock quote');
    }
  }

  Future<List<dynamic>> getStockNews(String symbol) async {
    final from = DateTime.now().subtract(Duration(days: 7)).toIso8601String().split('T').first;
    final to = DateTime.now().toIso8601String().split('T').first;
    final url = Uri.parse('$_baseUrl/company-news?symbol=$symbol&from=$from&to=$to&token=$_apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch news');
    }
  }

  Future<List<FlSpot>> getHistoricalData(String symbol) async {
    final to = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final from = (DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch / 1000).round();
    final url = Uri.parse('$_baseUrl/stock/candle?symbol=$symbol&resolution=D&from=$from&to=$to&token=$_apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['s'] != 'ok') throw Exception('Invalid data');
      return List.generate(data['c'].length, (i) => FlSpot(i.toDouble(), data['c'][i].toDouble()));
    } else {
      throw Exception('Failed to fetch chart data');
    }
  }
}