import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class NewsException implements Exception {
  final String message;
  const NewsException(this.message);

  @override
  String toString() => message;
}

class NewsService {
  // Replace with your NewsAPI key from https://newsapi.org
  static const String _apiKey = 'YOUR_NEWSAPI_KEY_HERE';
  static const String _baseUrl = 'https://newsapi.org/v2';

  final http.Client _client;

  NewsService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<NewsArticle>> getFinancialNews({int pageSize = 10}) async {
    if (_apiKey == 'YOUR_NEWSAPI_KEY_HERE') {
      return _getMockNews();
    }

    try {
      final uri = Uri.parse('$_baseUrl/everything').replace(
        queryParameters: {
          'q': 'finanças OR investimento OR economia OR mercado financeiro',
          'language': 'pt',
          'sortBy': 'publishedAt',
          'pageSize': pageSize.toString(),
          'apiKey': _apiKey,
        },
      );

      final response = await _client.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final articles = json['articles'] as List<dynamic>? ?? [];
        return articles
            .map((a) => NewsArticle.fromJson(a as Map<String, dynamic>))
            .where((a) => a.title != '[Removed]' && a.url.isNotEmpty)
            .toList();
      } else if (response.statusCode == 401) {
        throw const NewsException('Chave de API inválida.');
      } else if (response.statusCode == 429) {
        throw const NewsException('Limite de requisições atingido.');
      } else {
        return _getMockNews();
      }
    } catch (e) {
      if (e is NewsException) rethrow;
      return _getMockNews();
    }
  }

  List<NewsArticle> _getMockNews() {
    return [
      NewsArticle(
        title: 'Ibovespa fecha em alta com otimismo sobre juros',
        description:
            'O principal índice da bolsa brasileira registrou ganhos nesta sessão, impulsionado pelas expectativas de queda da taxa Selic.',
        url: 'https://www.infomoney.com.br',
        urlToImage: null,
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        source: const NewsSource(name: 'InfoMoney'),
      ),
      NewsArticle(
        title: 'Dólar cai frente ao real com dados positivos da economia',
        description:
            'A moeda americana recuou após divulgação de dados do PIB acima das expectativas do mercado.',
        url: 'https://www.infomoney.com.br',
        urlToImage: null,
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
        source: const NewsSource(name: 'InfoMoney'),
      ),
      NewsArticle(
        title: 'Como montar uma carteira diversificada em 2024',
        description:
            'Especialistas recomendam diversificação entre renda fixa e variável para proteção contra volatilidade.',
        url: 'https://www.infomoney.com.br',
        urlToImage: null,
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        source: const NewsSource(name: 'Seu Dinheiro'),
      ),
      NewsArticle(
        title: 'Tesouro Direto: taxas sobem e atraem investidores',
        description:
            'Rentabilidade dos títulos públicos federais aumentou, tornando-os mais atrativos para perfis conservadores.',
        url: 'https://www.infomoney.com.br',
        urlToImage: null,
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        source: const NewsSource(name: 'Valor Econômico'),
      ),
      NewsArticle(
        title: '5 dicas para economizar dinheiro no dia a dia',
        description:
            'Pequenos hábitos financeiros podem gerar grande impacto no orçamento mensal. Veja como começar.',
        url: 'https://www.infomoney.com.br',
        urlToImage: null,
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        source: const NewsSource(name: 'G1 Economia'),
      ),
      NewsArticle(
        title: 'Fundo de emergência: quanto guardar e onde investir',
        description:
            'Ter uma reserva de emergência equivalente a 6 meses de gastos é recomendação básica das finanças pessoais.',
        url: 'https://www.infomoney.com.br',
        urlToImage: null,
        publishedAt: DateTime.now().subtract(const Duration(hours: 16)),
        source: const NewsSource(name: 'Exame'),
      ),
    ];
  }
}
