import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../providers/providers.dart';

enum TransactionFilter { all, income, expense }

class TransactionState {
  final List<TransactionModel> transactions;
  final TransactionFilter filter;
  final bool isLoading;
  final String? errorMessage;
  final double totalIncome;
  final double totalExpense;

  const TransactionState({
    this.transactions = const [],
    this.filter = TransactionFilter.all,
    this.isLoading = false,
    this.errorMessage,
    this.totalIncome = 0,
    this.totalExpense = 0,
  });

  double get balance => totalIncome - totalExpense;

  List<TransactionModel> get filteredTransactions {
    switch (filter) {
      case TransactionFilter.income:
        return transactions
            .where((t) => t.type == TransactionType.income)
            .toList();
      case TransactionFilter.expense:
        return transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();
      case TransactionFilter.all:
        return transactions;
    }
  }

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    TransactionFilter? filter,
    bool? isLoading,
    String? errorMessage,
    double? totalIncome,
    double? totalExpense,
  }) =>
      TransactionState(
        transactions: transactions ?? this.transactions,
        filter: filter ?? this.filter,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        totalIncome: totalIncome ?? this.totalIncome,
        totalExpense: totalExpense ?? this.totalExpense,
      );
}

class TransactionViewModel extends StateNotifier<TransactionState> {
  final TransactionRepository _repo;
  final String _userId;
  final _uuid = const Uuid();

  TransactionViewModel(this._repo, this._userId)
      : super(const TransactionState());

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final transactions = await _repo.getTransactions(_userId);
      final summary = await _repo.getBalanceSummary(_userId);

      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
        totalIncome: summary['income'] ?? 0,
        totalExpense: summary['expense'] ?? 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar transações: ${e.toString()}',
      );
    }
  }

  Future<bool> addTransaction({
    required String title,
    required double amount,
    required DateTime date,
    required TransactionType type,
    required TransactionCategory category,
    String? description,
  }) async {
    try {
      final transaction = TransactionModel(
        id: _uuid.v4(),
        userId: _userId,
        title: title,
        amount: amount,
        date: date,
        type: type,
        category: category,
        description: description,
        createdAt: DateTime.now(),
      );

      await _repo.addTransaction(transaction);

      final updatedList = [transaction, ...state.transactions];
      final newIncome = type == TransactionType.income
          ? state.totalIncome + amount
          : state.totalIncome;
      final newExpense = type == TransactionType.expense
          ? state.totalExpense + amount
          : state.totalExpense;

      state = state.copyWith(
        transactions: updatedList,
        totalIncome: newIncome,
        totalExpense: newExpense,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao adicionar: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel updated) async {
    try {
      await _repo.updateTransaction(updated);

      final old = state.transactions.firstWhere((t) => t.id == updated.id);
      double newIncome = state.totalIncome;
      double newExpense = state.totalExpense;

      // Reverse old
      if (old.type == TransactionType.income) {
        newIncome -= old.amount;
      } else {
        newExpense -= old.amount;
      }
      // Apply new
      if (updated.type == TransactionType.income) {
        newIncome += updated.amount;
      } else {
        newExpense += updated.amount;
      }

      final updatedList = state.transactions
          .map((t) => t.id == updated.id ? updated : t)
          .toList();

      state = state.copyWith(
        transactions: updatedList,
        totalIncome: newIncome,
        totalExpense: newExpense,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao atualizar: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    try {
      final tx = state.transactions.firstWhere((t) => t.id == transactionId);
      await _repo.deleteTransaction(_userId, transactionId);

      final newIncome = tx.type == TransactionType.income
          ? state.totalIncome - tx.amount
          : state.totalIncome;
      final newExpense = tx.type == TransactionType.expense
          ? state.totalExpense - tx.amount
          : state.totalExpense;

      state = state.copyWith(
        transactions: state.transactions
            .where((t) => t.id != transactionId)
            .toList(),
        totalIncome: newIncome,
        totalExpense: newExpense,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao excluir: ${e.toString()}');
      return false;
    }
  }

  void setFilter(TransactionFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final transactionViewModelProvider =
    StateNotifierProvider.family<TransactionViewModel, TransactionState, String>(
        (ref, userId) {
  final vm = TransactionViewModel(
    ref.watch(transactionRepositoryProvider),
    userId,
  );
  vm.loadTransactions();
  return vm;
});
