
class NewsArticle {
  final String headline;
  final String source;
  final String url;
  final DateTime datetime;

  NewsArticle({
    required this.headline,
    required this.source,
    required this.url,
    required this.datetime,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      headline: json['headline'],
      source: json['source'],
      url: json['url'],
      datetime: DateTime.fromMillisecondsSinceEpoch(json['datetime'] * 1000),
    );
  }
}
