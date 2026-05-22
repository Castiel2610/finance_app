import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../services/firestore_service.dart';

class TransactionRepository {
  final DatabaseService _db;
  final FirestoreService _firestore;

  TransactionRepository({
    DatabaseService? db,
    FirestoreService? firestore,
  })  : _db = db ?? DatabaseService.instance,
        _firestore = firestore ?? FirestoreService();

  Future<List<TransactionModel>> getTransactions(String userId) async {
    // Try to sync from Firestore first
    try {
      final remoteTransactions = await _firestore.getTransactions(userId);
      if (remoteTransactions.isNotEmpty) {
        await _db.syncTransactions(userId, remoteTransactions);
        return remoteTransactions;
      }
    } catch (_) {
      // Firestore unavailable - use local data
    }

    return _db.getTransactionsByUser(userId);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _db.insertTransaction(transaction);

    try {
      await _firestore.addTransaction(transaction);
    } catch (_) {
      // Will sync later when connection is restored
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _db.updateTransaction(transaction);

    try {
      await _firestore.updateTransaction(transaction);
    } catch (_) {}
  }

  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _db.deleteTransaction(transactionId);

    try {
      await _firestore.deleteTransaction(userId, transactionId);
    } catch (_) {}
  }

  Future<Map<String, double>> getBalanceSummary(String userId) =>
      _db.getBalanceSummary(userId);

  Stream<List<TransactionModel>> watchTransactions(String userId) {
    return _firestore.watchTransactions(userId).handleError((_) {});
  }
}
