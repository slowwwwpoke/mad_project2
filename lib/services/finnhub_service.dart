
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../models/news_article.dart';

class FinnhubService {
  static const String _apiKey = 'YOUR_API_KEY';
  static const String _baseUrl = 'https://finnhub.io/api/v1';

  static Future<Stock> fetchStockQuote(String symbol) async {
    final quoteUrl = '$_baseUrl/quote?symbol=$symbol&token=$_apiKey';
    final profileUrl = '$_baseUrl/stock/profile2?symbol=$symbol&token=$_apiKey';

    final quoteRes = await http.get(Uri.parse(quoteUrl));
    final profileRes = await http.get(Uri.parse(profileUrl));

    if (quoteRes.statusCode == 200 && profileRes.statusCode == 200) {
      final quote = json.decode(quoteRes.body);
      final profile = json.decode(profileRes.body);
      return Stock(
        symbol: symbol,
        name: profile['name'] ?? symbol,
        price: quote['c']?.toDouble() ?? 0.0,
        category: 'General',
      );
    } else {
      throw Exception('Failed to fetch stock quote');
    }
  }

  static Future<List<NewsArticle>> fetchNews(String symbol) async {
    final url = '$_baseUrl/company-news?symbol=$symbol&from=2024-04-01&to=2025-04-17&token=$_apiKey';
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return data.map((e) => NewsArticle.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch news');
    }
  }
}
