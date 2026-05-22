import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/news_repository.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/firestore_service.dart';
import '../services/news_service.dart';

// ---- Services ----
final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService.instance,
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(),
);

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

final newsServiceProvider = Provider<NewsService>(
  (ref) => NewsService(),
);

// ---- Repositories ----
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(authService: ref.watch(authServiceProvider)),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(
    db: ref.watch(databaseServiceProvider),
    firestore: ref.watch(firestoreServiceProvider),
  ),
);

final newsRepositoryProvider = Provider<NewsRepository>(
  (ref) => NewsRepository(newsService: ref.watch(newsServiceProvider)),
);
