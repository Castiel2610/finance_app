class NewsSource {
  final String? id;
  final String name;

  const NewsSource({this.id, required this.name});

  factory NewsSource.fromJson(Map<String, dynamic> json) => NewsSource(
        id: json['id'] as String?,
        name: json['name'] as String? ?? 'Desconhecido',
      );
}

class NewsArticle {
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final NewsSource source;
  final String? content;

  const NewsArticle({
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    required this.source,
    this.content,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
        title: json['title'] as String? ?? 'Sem título',
        description: json['description'] as String?,
        url: json['url'] as String? ?? '',
        urlToImage: json['urlToImage'] as String?,
        publishedAt: json['publishedAt'] != null
            ? DateTime.tryParse(json['publishedAt'] as String)
            : null,
        source: NewsSource.fromJson(
            json['source'] as Map<String, dynamic>? ?? {'name': 'Desconhecido'}),
        content: json['content'] as String?,
      );
}
