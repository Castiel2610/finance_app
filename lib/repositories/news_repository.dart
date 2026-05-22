import '../models/news_model.dart';
import '../services/news_service.dart';

class NewsRepository {
  final NewsService _newsService;

  NewsRepository({NewsService? newsService})
      : _newsService = newsService ?? NewsService();

  Future<List<NewsArticle>> getFinancialNews({int pageSize = 10}) =>
      _newsService.getFinancialNews(pageSize: pageSize);
}
