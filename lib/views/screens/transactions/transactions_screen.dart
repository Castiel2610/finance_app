import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/transaction_model.dart';
import '../../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/transaction_card.dart';
import '../../widgets/transaction_bottom_sheet.dart';
import '../../widgets/skeleton_widgets.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  final String userId;

  const TransactionsScreen({super.key, required this.userId});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditSheet(TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionBottomSheet(
        transaction: tx,
        onSave: ({
          required title,
          required amount,
          required date,
          required type,
          required category,
          description,
        }) async {
          await ref
              .read(transactionViewModelProvider(widget.userId).notifier)
              .updateTransaction(
                tx.copyWith(
                  title: title,
                  amount: amount,
                  date: date,
                  type: type,
                  category: category,
                  description: description,
                ),
              );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Transação atualizada!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
      ),
    );
  }

  void _deleteTransaction(String id) async {
    final success = await ref
        .read(transactionViewModelProvider(widget.userId).notifier)
        .deleteTransaction(id);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transação excluída'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionViewModelProvider(widget.userId));

    List<TransactionModel> displayedList = txState.filteredTransactions;
    if (_searchQuery.isNotEmpty) {
      displayedList = displayedList
          .where((tx) =>
              tx.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              tx.category.label
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transações'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar transações...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: Colors.white70),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.white30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter chips
                Row(
                  children: TransactionFilter.values.map((f) {
                    final isSelected = txState.filter == f;
                    final labels = {
                      TransactionFilter.all: 'Todas',
                      TransactionFilter.income: 'Receitas',
                      TransactionFilter.expense: 'Despesas',
                    };
                    final colors = {
                      TransactionFilter.all: Colors.white,
                      TransactionFilter.income: AppColors.income,
                      TransactionFilter.expense: AppColors.expense,
                    };

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => ref
                            .read(transactionViewModelProvider(widget.userId)
                                .notifier)
                            .setFilter(f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors[f]
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            labels[f]!,
                            style: TextStyle(
                              color: isSelected
                                  ? (f == TransactionFilter.all
                                      ? AppColors.primary
                                      : Colors.white)
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: txState.isLoading
          ? const SkeletonList(count: 6)
          : displayedList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 72, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Nenhum resultado para "$_searchQuery"'
                            : 'Nenhuma transação encontrada',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ).animate().fadeIn(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: displayedList.length,
                  itemBuilder: (_, i) => TransactionCard(
                    transaction: displayedList[i],
                    index: i,
                    onDelete: () => _deleteTransaction(displayedList[i].id),
                    onEdit: () => _openEditSheet(displayedList[i]),
                  ),
                ),
    );
  }
}
