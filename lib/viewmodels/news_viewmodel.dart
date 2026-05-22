import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/news_model.dart';
import '../repositories/news_repository.dart';
import '../providers/providers.dart';

class NewsState {
  final List<NewsArticle> articles;
  final bool isLoading;
  final String? errorMessage;

  const NewsState({
    this.articles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NewsState copyWith({
    List<NewsArticle>? articles,
    bool? isLoading,
    String? errorMessage,
  }) =>
      NewsState(
        articles: articles ?? this.articles,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

class NewsViewModel extends StateNotifier<NewsState> {
  final NewsRepository _repo;

  NewsViewModel(this._repo) : super(const NewsState());

  Future<void> fetchNews() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final articles = await _repo.getFinancialNews(pageSize: 10);
      state = state.copyWith(articles: articles, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar notícias.',
      );
    }
  }

  Future<void> refresh() => fetchNews();
}

final newsViewModelProvider =
    StateNotifierProvider<NewsViewModel, NewsState>((ref) {
  final vm = NewsViewModel(ref.watch(newsRepositoryProvider));
  vm.fetchNews();
  return vm;
});
