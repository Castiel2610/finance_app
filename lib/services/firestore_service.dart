import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTransactions(String userId) =>
      _firestore.collection('users').doc(userId).collection('transactions');

  Future<void> addTransaction(TransactionModel transaction) async {
    await _userTransactions(transaction.userId)
        .doc(transaction.id)
        .set(transaction.toFirestore());
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _userTransactions(transaction.userId)
        .doc(transaction.id)
        .update(transaction.toFirestore());
  }

  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _userTransactions(userId).doc(transactionId).delete();
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    final snapshot = await _userTransactions(userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data()))
        .toList();
  }

  Stream<List<TransactionModel>> watchTransactions(String userId) {
    return _userTransactions(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => TransactionModel.fromMap(doc.data())).toList());
  }

  Future<void> syncUserTransactions(
      String userId, List<TransactionModel> transactions) async {
    final batch = _firestore.batch();
    for (final tx in transactions) {
      final ref = _userTransactions(userId).doc(tx.id);
      batch.set(ref, tx.toFirestore());
    }
    await batch.commit();
  }
}
